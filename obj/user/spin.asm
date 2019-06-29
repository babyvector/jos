
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  80003a:	68 40 10 80 00       	push   $0x801040
  80003f:	e8 5c 01 00 00       	call   8001a0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 d8 0c 00 00       	call   800d21 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 b8 10 80 00       	push   $0x8010b8
  800058:	e8 43 01 00 00       	call   8001a0 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 68 10 80 00       	push   $0x801068
  80006c:	e8 2f 01 00 00       	call   8001a0 <cprintf>
	sys_yield();
  800071:	e8 dd 0a 00 00       	call   800b53 <sys_yield>
	sys_yield();
  800076:	e8 d8 0a 00 00       	call   800b53 <sys_yield>
	sys_yield();
  80007b:	e8 d3 0a 00 00       	call   800b53 <sys_yield>
	sys_yield();
  800080:	e8 ce 0a 00 00       	call   800b53 <sys_yield>
	sys_yield();
  800085:	e8 c9 0a 00 00       	call   800b53 <sys_yield>
	sys_yield();
  80008a:	e8 c4 0a 00 00       	call   800b53 <sys_yield>
	sys_yield();
  80008f:	e8 bf 0a 00 00       	call   800b53 <sys_yield>
	sys_yield();
  800094:	e8 ba 0a 00 00       	call   800b53 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 90 10 80 00 	movl   $0x801090,(%esp)
  8000a0:	e8 fb 00 00 00       	call   8001a0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 46 0a 00 00       	call   800af3 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 6f 0a 00 00       	call   800b34 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 eb 09 00 00       	call   800af3 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	75 1a                	jne    800146 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	68 ff 00 00 00       	push   $0xff
  800134:	8d 43 08             	lea    0x8(%ebx),%eax
  800137:	50                   	push   %eax
  800138:	e8 79 09 00 00       	call   800ab6 <sys_cputs>
		b->idx = 0;
  80013d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800143:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 0d 01 80 00       	push   $0x80010d
  80017e:	e8 54 01 00 00       	call   8002d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 1e 09 00 00       	call   800ab6 <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 1c             	sub    $0x1c,%esp
  8001bd:	89 c7                	mov    %eax,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001db:	39 d3                	cmp    %edx,%ebx
  8001dd:	72 05                	jb     8001e4 <printnum+0x30>
  8001df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e2:	77 45                	ja     800229 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 18             	pushl  0x18(%ebp)
  8001ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ed:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f0:	53                   	push   %ebx
  8001f1:	ff 75 10             	pushl  0x10(%ebp)
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800200:	ff 75 d8             	pushl  -0x28(%ebp)
  800203:	e8 98 0b 00 00       	call   800da0 <__udivdi3>
  800208:	83 c4 18             	add    $0x18,%esp
  80020b:	52                   	push   %edx
  80020c:	50                   	push   %eax
  80020d:	89 f2                	mov    %esi,%edx
  80020f:	89 f8                	mov    %edi,%eax
  800211:	e8 9e ff ff ff       	call   8001b4 <printnum>
  800216:	83 c4 20             	add    $0x20,%esp
  800219:	eb 18                	jmp    800233 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	ff d7                	call   *%edi
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	eb 03                	jmp    80022c <printnum+0x78>
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f e8                	jg     80021b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	ff 75 dc             	pushl  -0x24(%ebp)
  800243:	ff 75 d8             	pushl  -0x28(%ebp)
  800246:	e8 85 0c 00 00       	call   800ed0 <__umoddi3>
  80024b:	83 c4 14             	add    $0x14,%esp
  80024e:	0f be 80 e0 10 80 00 	movsbl 0x8010e0(%eax),%eax
  800255:	50                   	push   %eax
  800256:	ff d7                	call   *%edi
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800266:	83 fa 01             	cmp    $0x1,%edx
  800269:	7e 0e                	jle    800279 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 02                	mov    (%edx),%eax
  800274:	8b 52 04             	mov    0x4(%edx),%edx
  800277:	eb 22                	jmp    80029b <getuint+0x38>
	else if (lflag)
  800279:	85 d2                	test   %edx,%edx
  80027b:	74 10                	je     80028d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	ba 00 00 00 00       	mov    $0x0,%edx
  80028b:	eb 0e                	jmp    80029b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ac:	73 0a                	jae    8002b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	88 02                	mov    %al,(%edx)
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c3:	50                   	push   %eax
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ca:	ff 75 08             	pushl  0x8(%ebp)
  8002cd:	e8 05 00 00 00       	call   8002d7 <vprintfmt>
	va_end(ap);
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 2c             	sub    $0x2c,%esp
  8002e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e9:	eb 12                	jmp    8002fd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	0f 84 d3 03 00 00    	je     8006c6 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	53                   	push   %ebx
  8002f7:	50                   	push   %eax
  8002f8:	ff d6                	call   *%esi
  8002fa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fd:	83 c7 01             	add    $0x1,%edi
  800300:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800304:	83 f8 25             	cmp    $0x25,%eax
  800307:	75 e2                	jne    8002eb <vprintfmt+0x14>
  800309:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800314:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80031b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	eb 07                	jmp    800330 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8d 47 01             	lea    0x1(%edi),%eax
  800333:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800336:	0f b6 07             	movzbl (%edi),%eax
  800339:	0f b6 c8             	movzbl %al,%ecx
  80033c:	83 e8 23             	sub    $0x23,%eax
  80033f:	3c 55                	cmp    $0x55,%al
  800341:	0f 87 64 03 00 00    	ja     8006ab <vprintfmt+0x3d4>
  800347:	0f b6 c0             	movzbl %al,%eax
  80034a:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800354:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800358:	eb d6                	jmp    800330 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035d:	b8 00 00 00 00       	mov    $0x0,%eax
  800362:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800365:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800368:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80036c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80036f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800372:	83 fa 09             	cmp    $0x9,%edx
  800375:	77 39                	ja     8003b0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800377:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037a:	eb e9                	jmp    800365 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 48 04             	lea    0x4(%eax),%ecx
  800382:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800385:	8b 00                	mov    (%eax),%eax
  800387:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038d:	eb 27                	jmp    8003b6 <vprintfmt+0xdf>
  80038f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800392:	85 c0                	test   %eax,%eax
  800394:	b9 00 00 00 00       	mov    $0x0,%ecx
  800399:	0f 49 c8             	cmovns %eax,%ecx
  80039c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a2:	eb 8c                	jmp    800330 <vprintfmt+0x59>
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ae:	eb 80                	jmp    800330 <vprintfmt+0x59>
  8003b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b3:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ba:	0f 89 70 ff ff ff    	jns    800330 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003cd:	e9 5e ff ff ff       	jmp    800330 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d8:	e9 53 ff ff ff       	jmp    800330 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	53                   	push   %ebx
  8003ea:	ff 30                	pushl  (%eax)
  8003ec:	ff d6                	call   *%esi
			break;
  8003ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 04 ff ff ff       	jmp    8002fd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 50 04             	lea    0x4(%eax),%edx
  8003ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800402:	8b 00                	mov    (%eax),%eax
  800404:	99                   	cltd   
  800405:	31 d0                	xor    %edx,%eax
  800407:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800409:	83 f8 08             	cmp    $0x8,%eax
  80040c:	7f 0b                	jg     800419 <vprintfmt+0x142>
  80040e:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800415:	85 d2                	test   %edx,%edx
  800417:	75 18                	jne    800431 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800419:	50                   	push   %eax
  80041a:	68 f8 10 80 00       	push   $0x8010f8
  80041f:	53                   	push   %ebx
  800420:	56                   	push   %esi
  800421:	e8 94 fe ff ff       	call   8002ba <printfmt>
  800426:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042c:	e9 cc fe ff ff       	jmp    8002fd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800431:	52                   	push   %edx
  800432:	68 01 11 80 00       	push   $0x801101
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 7c fe ff ff       	call   8002ba <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800444:	e9 b4 fe ff ff       	jmp    8002fd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800454:	85 ff                	test   %edi,%edi
  800456:	b8 f1 10 80 00       	mov    $0x8010f1,%eax
  80045b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80045e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800462:	0f 8e 94 00 00 00    	jle    8004fc <vprintfmt+0x225>
  800468:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046c:	0f 84 98 00 00 00    	je     80050a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 c8             	pushl  -0x38(%ebp)
  800478:	57                   	push   %edi
  800479:	e8 d0 02 00 00       	call   80074e <strnlen>
  80047e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800481:	29 c1                	sub    %eax,%ecx
  800483:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800489:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800490:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800493:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	eb 0f                	jmp    8004a6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	53                   	push   %ebx
  80049b:	ff 75 e0             	pushl  -0x20(%ebp)
  80049e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	83 ef 01             	sub    $0x1,%edi
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	85 ff                	test   %edi,%edi
  8004a8:	7f ed                	jg     800497 <vprintfmt+0x1c0>
  8004aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ad:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b0:	85 c9                	test   %ecx,%ecx
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	0f 49 c1             	cmovns %ecx,%eax
  8004ba:	29 c1                	sub    %eax,%ecx
  8004bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bf:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c5:	89 cb                	mov    %ecx,%ebx
  8004c7:	eb 4d                	jmp    800516 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cd:	74 1b                	je     8004ea <vprintfmt+0x213>
  8004cf:	0f be c0             	movsbl %al,%eax
  8004d2:	83 e8 20             	sub    $0x20,%eax
  8004d5:	83 f8 5e             	cmp    $0x5e,%eax
  8004d8:	76 10                	jbe    8004ea <vprintfmt+0x213>
					putch('?', putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	6a 3f                	push   $0x3f
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb 0d                	jmp    8004f7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	52                   	push   %edx
  8004f1:	ff 55 08             	call   *0x8(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f7:	83 eb 01             	sub    $0x1,%ebx
  8004fa:	eb 1a                	jmp    800516 <vprintfmt+0x23f>
  8004fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ff:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800502:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800505:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800508:	eb 0c                	jmp    800516 <vprintfmt+0x23f>
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800516:	83 c7 01             	add    $0x1,%edi
  800519:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051d:	0f be d0             	movsbl %al,%edx
  800520:	85 d2                	test   %edx,%edx
  800522:	74 23                	je     800547 <vprintfmt+0x270>
  800524:	85 f6                	test   %esi,%esi
  800526:	78 a1                	js     8004c9 <vprintfmt+0x1f2>
  800528:	83 ee 01             	sub    $0x1,%esi
  80052b:	79 9c                	jns    8004c9 <vprintfmt+0x1f2>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	eb 18                	jmp    80054f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	6a 20                	push   $0x20
  80053d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053f:	83 ef 01             	sub    $0x1,%edi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb 08                	jmp    80054f <vprintfmt+0x278>
  800547:	89 df                	mov    %ebx,%edi
  800549:	8b 75 08             	mov    0x8(%ebp),%esi
  80054c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054f:	85 ff                	test   %edi,%edi
  800551:	7f e4                	jg     800537 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800556:	e9 a2 fd ff ff       	jmp    8002fd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055b:	83 fa 01             	cmp    $0x1,%edx
  80055e:	7e 16                	jle    800576 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 08             	lea    0x8(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 50 04             	mov    0x4(%eax),%edx
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800571:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800574:	eb 32                	jmp    8005a8 <vprintfmt+0x2d1>
	else if (lflag)
  800576:	85 d2                	test   %edx,%edx
  800578:	74 18                	je     800592 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 50 04             	lea    0x4(%eax),%edx
  800580:	89 55 14             	mov    %edx,0x14(%ebp)
  800583:	8b 00                	mov    (%eax),%eax
  800585:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800588:	89 c1                	mov    %eax,%ecx
  80058a:	c1 f9 1f             	sar    $0x1f,%ecx
  80058d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800590:	eb 16                	jmp    8005a8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005a0:	89 c1                	mov    %eax,%ecx
  8005a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005ab:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b4:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005bd:	0f 89 b0 00 00 00    	jns    800673 <vprintfmt+0x39c>
				putch('-', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	53                   	push   %ebx
  8005c7:	6a 2d                	push   $0x2d
  8005c9:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005ce:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005d1:	f7 d8                	neg    %eax
  8005d3:	83 d2 00             	adc    $0x0,%edx
  8005d6:	f7 da                	neg    %edx
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005de:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e6:	e9 88 00 00 00       	jmp    800673 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 70 fc ff ff       	call   800263 <getuint>
  8005f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005f9:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005fe:	eb 73                	jmp    800673 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800600:	8d 45 14             	lea    0x14(%ebp),%eax
  800603:	e8 5b fc ff ff       	call   800263 <getuint>
  800608:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 58                	push   $0x58
  800614:	ff d6                	call   *%esi
			putch('X', putdat);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 58                	push   $0x58
  80061c:	ff d6                	call   *%esi
			putch('X', putdat);
  80061e:	83 c4 08             	add    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 58                	push   $0x58
  800624:	ff d6                	call   *%esi
			goto number;
  800626:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800629:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80062e:	eb 43                	jmp    800673 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 30                	push   $0x30
  800636:	ff d6                	call   *%esi
			putch('x', putdat);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 78                	push   $0x78
  80063e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	ba 00 00 00 00       	mov    $0x0,%edx
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800656:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800659:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80065e:	eb 13                	jmp    800673 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 fb fb ff ff       	call   800263 <getuint>
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80066e:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800673:	83 ec 0c             	sub    $0xc,%esp
  800676:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80067a:	52                   	push   %edx
  80067b:	ff 75 e0             	pushl  -0x20(%ebp)
  80067e:	50                   	push   %eax
  80067f:	ff 75 dc             	pushl  -0x24(%ebp)
  800682:	ff 75 d8             	pushl  -0x28(%ebp)
  800685:	89 da                	mov    %ebx,%edx
  800687:	89 f0                	mov    %esi,%eax
  800689:	e8 26 fb ff ff       	call   8001b4 <printnum>
			break;
  80068e:	83 c4 20             	add    $0x20,%esp
  800691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800694:	e9 64 fc ff ff       	jmp    8002fd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	51                   	push   %ecx
  80069e:	ff d6                	call   *%esi
			break;
  8006a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a6:	e9 52 fc ff ff       	jmp    8002fd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 25                	push   $0x25
  8006b1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 03                	jmp    8006bb <vprintfmt+0x3e4>
  8006b8:	83 ef 01             	sub    $0x1,%edi
  8006bb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006bf:	75 f7                	jne    8006b8 <vprintfmt+0x3e1>
  8006c1:	e9 37 fc ff ff       	jmp    8002fd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c9:	5b                   	pop    %ebx
  8006ca:	5e                   	pop    %esi
  8006cb:	5f                   	pop    %edi
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 18             	sub    $0x18,%esp
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	74 26                	je     800715 <vsnprintf+0x47>
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	7e 22                	jle    800715 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f3:	ff 75 14             	pushl  0x14(%ebp)
  8006f6:	ff 75 10             	pushl  0x10(%ebp)
  8006f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fc:	50                   	push   %eax
  8006fd:	68 9d 02 80 00       	push   $0x80029d
  800702:	e8 d0 fb ff ff       	call   8002d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800707:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 05                	jmp    80071a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800725:	50                   	push   %eax
  800726:	ff 75 10             	pushl  0x10(%ebp)
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	ff 75 08             	pushl  0x8(%ebp)
  80072f:	e8 9a ff ff ff       	call   8006ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073c:	b8 00 00 00 00       	mov    $0x0,%eax
  800741:	eb 03                	jmp    800746 <strlen+0x10>
		n++;
  800743:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	75 f7                	jne    800743 <strlen+0xd>
		n++;
	return n;
}
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800754:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	ba 00 00 00 00       	mov    $0x0,%edx
  80075c:	eb 03                	jmp    800761 <strnlen+0x13>
		n++;
  80075e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800761:	39 c2                	cmp    %eax,%edx
  800763:	74 08                	je     80076d <strnlen+0x1f>
  800765:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800769:	75 f3                	jne    80075e <strnlen+0x10>
  80076b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	53                   	push   %ebx
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800779:	89 c2                	mov    %eax,%edx
  80077b:	83 c2 01             	add    $0x1,%edx
  80077e:	83 c1 01             	add    $0x1,%ecx
  800781:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800785:	88 5a ff             	mov    %bl,-0x1(%edx)
  800788:	84 db                	test   %bl,%bl
  80078a:	75 ef                	jne    80077b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078c:	5b                   	pop    %ebx
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800796:	53                   	push   %ebx
  800797:	e8 9a ff ff ff       	call   800736 <strlen>
  80079c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	01 d8                	add    %ebx,%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 c5 ff ff ff       	call   80076f <strcpy>
	return dst;
}
  8007aa:	89 d8                	mov    %ebx,%eax
  8007ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	56                   	push   %esi
  8007b5:	53                   	push   %ebx
  8007b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bc:	89 f3                	mov    %esi,%ebx
  8007be:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	89 f2                	mov    %esi,%edx
  8007c3:	eb 0f                	jmp    8007d4 <strncpy+0x23>
		*dst++ = *src;
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	0f b6 01             	movzbl (%ecx),%eax
  8007cb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ce:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d4:	39 da                	cmp    %ebx,%edx
  8007d6:	75 ed                	jne    8007c5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	74 21                	je     800813 <strlcpy+0x35>
  8007f2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f6:	89 f2                	mov    %esi,%edx
  8007f8:	eb 09                	jmp    800803 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fa:	83 c2 01             	add    $0x1,%edx
  8007fd:	83 c1 01             	add    $0x1,%ecx
  800800:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800803:	39 c2                	cmp    %eax,%edx
  800805:	74 09                	je     800810 <strlcpy+0x32>
  800807:	0f b6 19             	movzbl (%ecx),%ebx
  80080a:	84 db                	test   %bl,%bl
  80080c:	75 ec                	jne    8007fa <strlcpy+0x1c>
  80080e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800810:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800813:	29 f0                	sub    %esi,%eax
}
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800822:	eb 06                	jmp    80082a <strcmp+0x11>
		p++, q++;
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082a:	0f b6 01             	movzbl (%ecx),%eax
  80082d:	84 c0                	test   %al,%al
  80082f:	74 04                	je     800835 <strcmp+0x1c>
  800831:	3a 02                	cmp    (%edx),%al
  800833:	74 ef                	je     800824 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800835:	0f b6 c0             	movzbl %al,%eax
  800838:	0f b6 12             	movzbl (%edx),%edx
  80083b:	29 d0                	sub    %edx,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 c3                	mov    %eax,%ebx
  80084b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084e:	eb 06                	jmp    800856 <strncmp+0x17>
		n--, p++, q++;
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800856:	39 d8                	cmp    %ebx,%eax
  800858:	74 15                	je     80086f <strncmp+0x30>
  80085a:	0f b6 08             	movzbl (%eax),%ecx
  80085d:	84 c9                	test   %cl,%cl
  80085f:	74 04                	je     800865 <strncmp+0x26>
  800861:	3a 0a                	cmp    (%edx),%cl
  800863:	74 eb                	je     800850 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 00             	movzbl (%eax),%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
  80086d:	eb 05                	jmp    800874 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800881:	eb 07                	jmp    80088a <strchr+0x13>
		if (*s == c)
  800883:	38 ca                	cmp    %cl,%dl
  800885:	74 0f                	je     800896 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800887:	83 c0 01             	add    $0x1,%eax
  80088a:	0f b6 10             	movzbl (%eax),%edx
  80088d:	84 d2                	test   %dl,%dl
  80088f:	75 f2                	jne    800883 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a2:	eb 03                	jmp    8008a7 <strfind+0xf>
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 04                	je     8008b2 <strfind+0x1a>
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	75 f2                	jne    8008a4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c0:	85 c9                	test   %ecx,%ecx
  8008c2:	74 36                	je     8008fa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ca:	75 28                	jne    8008f4 <memset+0x40>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 23                	jne    8008f4 <memset+0x40>
		c &= 0xFF;
  8008d1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d5:	89 d3                	mov    %edx,%ebx
  8008d7:	c1 e3 08             	shl    $0x8,%ebx
  8008da:	89 d6                	mov    %edx,%esi
  8008dc:	c1 e6 18             	shl    $0x18,%esi
  8008df:	89 d0                	mov    %edx,%eax
  8008e1:	c1 e0 10             	shl    $0x10,%eax
  8008e4:	09 f0                	or     %esi,%eax
  8008e6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008e8:	89 d8                	mov    %ebx,%eax
  8008ea:	09 d0                	or     %edx,%eax
  8008ec:	c1 e9 02             	shr    $0x2,%ecx
  8008ef:	fc                   	cld    
  8008f0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f2:	eb 06                	jmp    8008fa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f7:	fc                   	cld    
  8008f8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fa:	89 f8                	mov    %edi,%eax
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5f                   	pop    %edi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	57                   	push   %edi
  800905:	56                   	push   %esi
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090f:	39 c6                	cmp    %eax,%esi
  800911:	73 35                	jae    800948 <memmove+0x47>
  800913:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800916:	39 d0                	cmp    %edx,%eax
  800918:	73 2e                	jae    800948 <memmove+0x47>
		s += n;
		d += n;
  80091a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091d:	89 d6                	mov    %edx,%esi
  80091f:	09 fe                	or     %edi,%esi
  800921:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800927:	75 13                	jne    80093c <memmove+0x3b>
  800929:	f6 c1 03             	test   $0x3,%cl
  80092c:	75 0e                	jne    80093c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80092e:	83 ef 04             	sub    $0x4,%edi
  800931:	8d 72 fc             	lea    -0x4(%edx),%esi
  800934:	c1 e9 02             	shr    $0x2,%ecx
  800937:	fd                   	std    
  800938:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093a:	eb 09                	jmp    800945 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093c:	83 ef 01             	sub    $0x1,%edi
  80093f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800942:	fd                   	std    
  800943:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800945:	fc                   	cld    
  800946:	eb 1d                	jmp    800965 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	89 f2                	mov    %esi,%edx
  80094a:	09 c2                	or     %eax,%edx
  80094c:	f6 c2 03             	test   $0x3,%dl
  80094f:	75 0f                	jne    800960 <memmove+0x5f>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0a                	jne    800960 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800956:	c1 e9 02             	shr    $0x2,%ecx
  800959:	89 c7                	mov    %eax,%edi
  80095b:	fc                   	cld    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 05                	jmp    800965 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800960:	89 c7                	mov    %eax,%edi
  800962:	fc                   	cld    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096c:	ff 75 10             	pushl  0x10(%ebp)
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	ff 75 08             	pushl  0x8(%ebp)
  800975:	e8 87 ff ff ff       	call   800901 <memmove>
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 55 0c             	mov    0xc(%ebp),%edx
  800987:	89 c6                	mov    %eax,%esi
  800989:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098c:	eb 1a                	jmp    8009a8 <memcmp+0x2c>
		if (*s1 != *s2)
  80098e:	0f b6 08             	movzbl (%eax),%ecx
  800991:	0f b6 1a             	movzbl (%edx),%ebx
  800994:	38 d9                	cmp    %bl,%cl
  800996:	74 0a                	je     8009a2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800998:	0f b6 c1             	movzbl %cl,%eax
  80099b:	0f b6 db             	movzbl %bl,%ebx
  80099e:	29 d8                	sub    %ebx,%eax
  8009a0:	eb 0f                	jmp    8009b1 <memcmp+0x35>
		s1++, s2++;
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a8:	39 f0                	cmp    %esi,%eax
  8009aa:	75 e2                	jne    80098e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	53                   	push   %ebx
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009bc:	89 c1                	mov    %eax,%ecx
  8009be:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c5:	eb 0a                	jmp    8009d1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c7:	0f b6 10             	movzbl (%eax),%edx
  8009ca:	39 da                	cmp    %ebx,%edx
  8009cc:	74 07                	je     8009d5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	39 c8                	cmp    %ecx,%eax
  8009d3:	72 f2                	jb     8009c7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e4:	eb 03                	jmp    8009e9 <strtol+0x11>
		s++;
  8009e6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e9:	0f b6 01             	movzbl (%ecx),%eax
  8009ec:	3c 20                	cmp    $0x20,%al
  8009ee:	74 f6                	je     8009e6 <strtol+0xe>
  8009f0:	3c 09                	cmp    $0x9,%al
  8009f2:	74 f2                	je     8009e6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f4:	3c 2b                	cmp    $0x2b,%al
  8009f6:	75 0a                	jne    800a02 <strtol+0x2a>
		s++;
  8009f8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800a00:	eb 11                	jmp    800a13 <strtol+0x3b>
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	75 08                	jne    800a13 <strtol+0x3b>
		s++, neg = 1;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a13:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a19:	75 15                	jne    800a30 <strtol+0x58>
  800a1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1e:	75 10                	jne    800a30 <strtol+0x58>
  800a20:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a24:	75 7c                	jne    800aa2 <strtol+0xca>
		s += 2, base = 16;
  800a26:	83 c1 02             	add    $0x2,%ecx
  800a29:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2e:	eb 16                	jmp    800a46 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	75 12                	jne    800a46 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a34:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a39:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3c:	75 08                	jne    800a46 <strtol+0x6e>
		s++, base = 8;
  800a3e:	83 c1 01             	add    $0x1,%ecx
  800a41:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4e:	0f b6 11             	movzbl (%ecx),%edx
  800a51:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 09             	cmp    $0x9,%bl
  800a59:	77 08                	ja     800a63 <strtol+0x8b>
			dig = *s - '0';
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 30             	sub    $0x30,%edx
  800a61:	eb 22                	jmp    800a85 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 08                	ja     800a75 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 57             	sub    $0x57,%edx
  800a73:	eb 10                	jmp    800a85 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 19             	cmp    $0x19,%bl
  800a7d:	77 16                	ja     800a95 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a85:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a88:	7d 0b                	jge    800a95 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a91:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a93:	eb b9                	jmp    800a4e <strtol+0x76>

	if (endptr)
  800a95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a99:	74 0d                	je     800aa8 <strtol+0xd0>
		*endptr = (char *) s;
  800a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9e:	89 0e                	mov    %ecx,(%esi)
  800aa0:	eb 06                	jmp    800aa8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	74 98                	je     800a3e <strtol+0x66>
  800aa6:	eb 9e                	jmp    800a46 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aa8:	89 c2                	mov    %eax,%edx
  800aaa:	f7 da                	neg    %edx
  800aac:	85 ff                	test   %edi,%edi
  800aae:	0f 45 c2             	cmovne %edx,%eax
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	89 c7                	mov    %eax,%edi
  800acb:	89 c6                	mov    %eax,%esi
  800acd:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ada:	ba 00 00 00 00       	mov    $0x0,%edx
  800adf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae4:	89 d1                	mov    %edx,%ecx
  800ae6:	89 d3                	mov    %edx,%ebx
  800ae8:	89 d7                	mov    %edx,%edi
  800aea:	89 d6                	mov    %edx,%esi
  800aec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800afc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b01:	b8 03 00 00 00       	mov    $0x3,%eax
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	89 cb                	mov    %ecx,%ebx
  800b0b:	89 cf                	mov    %ecx,%edi
  800b0d:	89 ce                	mov    %ecx,%esi
  800b0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b11:	85 c0                	test   %eax,%eax
  800b13:	7e 17                	jle    800b2c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b15:	83 ec 0c             	sub    $0xc,%esp
  800b18:	50                   	push   %eax
  800b19:	6a 03                	push   $0x3
  800b1b:	68 24 13 80 00       	push   $0x801324
  800b20:	6a 23                	push   $0x23
  800b22:	68 41 13 80 00       	push   $0x801341
  800b27:	e8 23 02 00 00       	call   800d4f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_yield>:

void
sys_yield(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b63:	89 d1                	mov    %edx,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	89 d7                	mov    %edx,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b7b:	be 00 00 00 00       	mov    $0x0,%esi
  800b80:	b8 04 00 00 00       	mov    $0x4,%eax
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8e:	89 f7                	mov    %esi,%edi
  800b90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b92:	85 c0                	test   %eax,%eax
  800b94:	7e 17                	jle    800bad <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 04                	push   $0x4
  800b9c:	68 24 13 80 00       	push   $0x801324
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 41 13 80 00       	push   $0x801341
  800ba8:	e8 a2 01 00 00       	call   800d4f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 05                	push   $0x5
  800bde:	68 24 13 80 00       	push   $0x801324
  800be3:	6a 23                	push   $0x23
  800be5:	68 41 13 80 00       	push   $0x801341
  800bea:	e8 60 01 00 00       	call   800d4f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c05:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 df                	mov    %ebx,%edi
  800c12:	89 de                	mov    %ebx,%esi
  800c14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 06                	push   $0x6
  800c20:	68 24 13 80 00       	push   $0x801324
  800c25:	6a 23                	push   $0x23
  800c27:	68 41 13 80 00       	push   $0x801341
  800c2c:	e8 1e 01 00 00       	call   800d4f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c47:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 df                	mov    %ebx,%edi
  800c54:	89 de                	mov    %ebx,%esi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 08                	push   $0x8
  800c62:	68 24 13 80 00       	push   $0x801324
  800c67:	6a 23                	push   $0x23
  800c69:	68 41 13 80 00       	push   $0x801341
  800c6e:	e8 dc 00 00 00       	call   800d4f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 09                	push   $0x9
  800ca4:	68 24 13 80 00       	push   $0x801324
  800ca9:	6a 23                	push   $0x23
  800cab:	68 41 13 80 00       	push   $0x801341
  800cb0:	e8 9a 00 00 00       	call   800d4f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 cb                	mov    %ecx,%ebx
  800cf8:	89 cf                	mov    %ecx,%edi
  800cfa:	89 ce                	mov    %ecx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0c                	push   $0xc
  800d08:	68 24 13 80 00       	push   $0x801324
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 41 13 80 00       	push   $0x801341
  800d14:	e8 36 00 00 00       	call   800d4f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d27:	68 5b 13 80 00       	push   $0x80135b
  800d2c:	6a 51                	push   $0x51
  800d2e:	68 4f 13 80 00       	push   $0x80134f
  800d33:	e8 17 00 00 00       	call   800d4f <_panic>

00800d38 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d3e:	68 5a 13 80 00       	push   $0x80135a
  800d43:	6a 58                	push   $0x58
  800d45:	68 4f 13 80 00       	push   $0x80134f
  800d4a:	e8 00 00 00 00       	call   800d4f <_panic>

00800d4f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d54:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d57:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d5d:	e8 d2 fd ff ff       	call   800b34 <sys_getenvid>
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	ff 75 08             	pushl  0x8(%ebp)
  800d6b:	56                   	push   %esi
  800d6c:	50                   	push   %eax
  800d6d:	68 70 13 80 00       	push   $0x801370
  800d72:	e8 29 f4 ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d77:	83 c4 18             	add    $0x18,%esp
  800d7a:	53                   	push   %ebx
  800d7b:	ff 75 10             	pushl  0x10(%ebp)
  800d7e:	e8 cc f3 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  800d83:	c7 04 24 d4 10 80 00 	movl   $0x8010d4,(%esp)
  800d8a:	e8 11 f4 ff ff       	call   8001a0 <cprintf>
  800d8f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d92:	cc                   	int3   
  800d93:	eb fd                	jmp    800d92 <_panic+0x43>
  800d95:	66 90                	xchg   %ax,%ax
  800d97:	66 90                	xchg   %ax,%ax
  800d99:	66 90                	xchg   %ax,%ax
  800d9b:	66 90                	xchg   %ax,%ax
  800d9d:	66 90                	xchg   %ax,%ax
  800d9f:	90                   	nop

00800da0 <__udivdi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800daf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800db7:	85 f6                	test   %esi,%esi
  800db9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dbd:	89 ca                	mov    %ecx,%edx
  800dbf:	89 f8                	mov    %edi,%eax
  800dc1:	75 3d                	jne    800e00 <__udivdi3+0x60>
  800dc3:	39 cf                	cmp    %ecx,%edi
  800dc5:	0f 87 c5 00 00 00    	ja     800e90 <__udivdi3+0xf0>
  800dcb:	85 ff                	test   %edi,%edi
  800dcd:	89 fd                	mov    %edi,%ebp
  800dcf:	75 0b                	jne    800ddc <__udivdi3+0x3c>
  800dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd6:	31 d2                	xor    %edx,%edx
  800dd8:	f7 f7                	div    %edi
  800dda:	89 c5                	mov    %eax,%ebp
  800ddc:	89 c8                	mov    %ecx,%eax
  800dde:	31 d2                	xor    %edx,%edx
  800de0:	f7 f5                	div    %ebp
  800de2:	89 c1                	mov    %eax,%ecx
  800de4:	89 d8                	mov    %ebx,%eax
  800de6:	89 cf                	mov    %ecx,%edi
  800de8:	f7 f5                	div    %ebp
  800dea:	89 c3                	mov    %eax,%ebx
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
  800e00:	39 ce                	cmp    %ecx,%esi
  800e02:	77 74                	ja     800e78 <__udivdi3+0xd8>
  800e04:	0f bd fe             	bsr    %esi,%edi
  800e07:	83 f7 1f             	xor    $0x1f,%edi
  800e0a:	0f 84 98 00 00 00    	je     800ea8 <__udivdi3+0x108>
  800e10:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	89 c5                	mov    %eax,%ebp
  800e19:	29 fb                	sub    %edi,%ebx
  800e1b:	d3 e6                	shl    %cl,%esi
  800e1d:	89 d9                	mov    %ebx,%ecx
  800e1f:	d3 ed                	shr    %cl,%ebp
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	d3 e0                	shl    %cl,%eax
  800e25:	09 ee                	or     %ebp,%esi
  800e27:	89 d9                	mov    %ebx,%ecx
  800e29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2d:	89 d5                	mov    %edx,%ebp
  800e2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e33:	d3 ed                	shr    %cl,%ebp
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	d3 e2                	shl    %cl,%edx
  800e39:	89 d9                	mov    %ebx,%ecx
  800e3b:	d3 e8                	shr    %cl,%eax
  800e3d:	09 c2                	or     %eax,%edx
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	89 ea                	mov    %ebp,%edx
  800e43:	f7 f6                	div    %esi
  800e45:	89 d5                	mov    %edx,%ebp
  800e47:	89 c3                	mov    %eax,%ebx
  800e49:	f7 64 24 0c          	mull   0xc(%esp)
  800e4d:	39 d5                	cmp    %edx,%ebp
  800e4f:	72 10                	jb     800e61 <__udivdi3+0xc1>
  800e51:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e6                	shl    %cl,%esi
  800e59:	39 c6                	cmp    %eax,%esi
  800e5b:	73 07                	jae    800e64 <__udivdi3+0xc4>
  800e5d:	39 d5                	cmp    %edx,%ebp
  800e5f:	75 03                	jne    800e64 <__udivdi3+0xc4>
  800e61:	83 eb 01             	sub    $0x1,%ebx
  800e64:	31 ff                	xor    %edi,%edi
  800e66:	89 d8                	mov    %ebx,%eax
  800e68:	89 fa                	mov    %edi,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	31 ff                	xor    %edi,%edi
  800e7a:	31 db                	xor    %ebx,%ebx
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
  800e90:	89 d8                	mov    %ebx,%eax
  800e92:	f7 f7                	div    %edi
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	89 c3                	mov    %eax,%ebx
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	89 fa                	mov    %edi,%edx
  800e9c:	83 c4 1c             	add    $0x1c,%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	39 ce                	cmp    %ecx,%esi
  800eaa:	72 0c                	jb     800eb8 <__udivdi3+0x118>
  800eac:	31 db                	xor    %ebx,%ebx
  800eae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800eb2:	0f 87 34 ff ff ff    	ja     800dec <__udivdi3+0x4c>
  800eb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ebd:	e9 2a ff ff ff       	jmp    800dec <__udivdi3+0x4c>
  800ec2:	66 90                	xchg   %ax,%ax
  800ec4:	66 90                	xchg   %ax,%ax
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	66 90                	xchg   %ax,%ax
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__umoddi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 1c             	sub    $0x1c,%esp
  800ed7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800edb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800edf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ee7:	85 d2                	test   %edx,%edx
  800ee9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ef1:	89 f3                	mov    %esi,%ebx
  800ef3:	89 3c 24             	mov    %edi,(%esp)
  800ef6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efa:	75 1c                	jne    800f18 <__umoddi3+0x48>
  800efc:	39 f7                	cmp    %esi,%edi
  800efe:	76 50                	jbe    800f50 <__umoddi3+0x80>
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	f7 f7                	div    %edi
  800f06:	89 d0                	mov    %edx,%eax
  800f08:	31 d2                	xor    %edx,%edx
  800f0a:	83 c4 1c             	add    $0x1c,%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    
  800f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	77 52                	ja     800f70 <__umoddi3+0xa0>
  800f1e:	0f bd ea             	bsr    %edx,%ebp
  800f21:	83 f5 1f             	xor    $0x1f,%ebp
  800f24:	75 5a                	jne    800f80 <__umoddi3+0xb0>
  800f26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f2a:	0f 82 e0 00 00 00    	jb     801010 <__umoddi3+0x140>
  800f30:	39 0c 24             	cmp    %ecx,(%esp)
  800f33:	0f 86 d7 00 00 00    	jbe    801010 <__umoddi3+0x140>
  800f39:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f41:	83 c4 1c             	add    $0x1c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	85 ff                	test   %edi,%edi
  800f52:	89 fd                	mov    %edi,%ebp
  800f54:	75 0b                	jne    800f61 <__umoddi3+0x91>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f7                	div    %edi
  800f5f:	89 c5                	mov    %eax,%ebp
  800f61:	89 f0                	mov    %esi,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f5                	div    %ebp
  800f67:	89 c8                	mov    %ecx,%eax
  800f69:	f7 f5                	div    %ebp
  800f6b:	89 d0                	mov    %edx,%eax
  800f6d:	eb 99                	jmp    800f08 <__umoddi3+0x38>
  800f6f:	90                   	nop
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	83 c4 1c             	add    $0x1c,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	8b 34 24             	mov    (%esp),%esi
  800f83:	bf 20 00 00 00       	mov    $0x20,%edi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	29 ef                	sub    %ebp,%edi
  800f8c:	d3 e0                	shl    %cl,%eax
  800f8e:	89 f9                	mov    %edi,%ecx
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	d3 ea                	shr    %cl,%edx
  800f94:	89 e9                	mov    %ebp,%ecx
  800f96:	09 c2                	or     %eax,%edx
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	89 14 24             	mov    %edx,(%esp)
  800f9d:	89 f2                	mov    %esi,%edx
  800f9f:	d3 e2                	shl    %cl,%edx
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fab:	d3 e8                	shr    %cl,%eax
  800fad:	89 e9                	mov    %ebp,%ecx
  800faf:	89 c6                	mov    %eax,%esi
  800fb1:	d3 e3                	shl    %cl,%ebx
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	89 d0                	mov    %edx,%eax
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	09 d8                	or     %ebx,%eax
  800fbd:	89 d3                	mov    %edx,%ebx
  800fbf:	89 f2                	mov    %esi,%edx
  800fc1:	f7 34 24             	divl   (%esp)
  800fc4:	89 d6                	mov    %edx,%esi
  800fc6:	d3 e3                	shl    %cl,%ebx
  800fc8:	f7 64 24 04          	mull   0x4(%esp)
  800fcc:	39 d6                	cmp    %edx,%esi
  800fce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fd2:	89 d1                	mov    %edx,%ecx
  800fd4:	89 c3                	mov    %eax,%ebx
  800fd6:	72 08                	jb     800fe0 <__umoddi3+0x110>
  800fd8:	75 11                	jne    800feb <__umoddi3+0x11b>
  800fda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fde:	73 0b                	jae    800feb <__umoddi3+0x11b>
  800fe0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fe4:	1b 14 24             	sbb    (%esp),%edx
  800fe7:	89 d1                	mov    %edx,%ecx
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fef:	29 da                	sub    %ebx,%edx
  800ff1:	19 ce                	sbb    %ecx,%esi
  800ff3:	89 f9                	mov    %edi,%ecx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	d3 e0                	shl    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	d3 ea                	shr    %cl,%edx
  800ffd:	89 e9                	mov    %ebp,%ecx
  800fff:	d3 ee                	shr    %cl,%esi
  801001:	09 d0                	or     %edx,%eax
  801003:	89 f2                	mov    %esi,%edx
  801005:	83 c4 1c             	add    $0x1c,%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	29 f9                	sub    %edi,%ecx
  801012:	19 d6                	sbb    %edx,%esi
  801014:	89 74 24 04          	mov    %esi,0x4(%esp)
  801018:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80101c:	e9 18 ff ff ff       	jmp    800f39 <__umoddi3+0x69>
