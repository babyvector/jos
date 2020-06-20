
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 3c 00 00 00       	call   80006d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 10                	je     800050 <umain+0x1d>
		cprintf("eflags wrong\n");
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	68 00 1e 80 00       	push   $0x801e00
  800048:	e8 13 01 00 00       	call   800160 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800050:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800055:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80005a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	68 0e 1e 80 00       	push   $0x801e0e
  800063:	e8 f8 00 00 00       	call   800160 <cprintf>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800078:	e8 77 0a 00 00       	call   800af4 <sys_getenvid>
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x2d>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b9:	e8 30 0e 00 00       	call   800eee <close_all>
	sys_env_destroy(0);
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	6a 00                	push   $0x0
  8000c3:	e8 eb 09 00 00       	call   800ab3 <sys_env_destroy>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d7:	8b 13                	mov    (%ebx),%edx
  8000d9:	8d 42 01             	lea    0x1(%edx),%eax
  8000dc:	89 03                	mov    %eax,(%ebx)
  8000de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ea:	75 1a                	jne    800106 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	68 ff 00 00 00       	push   $0xff
  8000f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f7:	50                   	push   %eax
  8000f8:	e8 79 09 00 00       	call   800a76 <sys_cputs>
		b->idx = 0;
  8000fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800103:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800106:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 cd 00 80 00       	push   $0x8000cd
  80013e:	e8 54 01 00 00       	call   800297 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	e8 1e 09 00 00       	call   800a76 <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 9d ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 1c             	sub    $0x1c,%esp
  80017d:	89 c7                	mov    %eax,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800190:	bb 00 00 00 00       	mov    $0x0,%ebx
  800195:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800198:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80019b:	39 d3                	cmp    %edx,%ebx
  80019d:	72 05                	jb     8001a4 <printnum+0x30>
  80019f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a2:	77 45                	ja     8001e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 18             	pushl  0x18(%ebp)
  8001aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c3:	e8 98 19 00 00       	call   801b60 <__udivdi3>
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	52                   	push   %edx
  8001cc:	50                   	push   %eax
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	89 f8                	mov    %edi,%eax
  8001d1:	e8 9e ff ff ff       	call   800174 <printnum>
  8001d6:	83 c4 20             	add    $0x20,%esp
  8001d9:	eb 18                	jmp    8001f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	56                   	push   %esi
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	ff d7                	call   *%edi
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 03                	jmp    8001ec <printnum+0x78>
  8001e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ec:	83 eb 01             	sub    $0x1,%ebx
  8001ef:	85 db                	test   %ebx,%ebx
  8001f1:	7f e8                	jg     8001db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	83 ec 04             	sub    $0x4,%esp
  8001fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800200:	ff 75 dc             	pushl  -0x24(%ebp)
  800203:	ff 75 d8             	pushl  -0x28(%ebp)
  800206:	e8 85 1a 00 00       	call   801c90 <__umoddi3>
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	0f be 80 32 1e 80 00 	movsbl 0x801e32(%eax),%eax
  800215:	50                   	push   %eax
  800216:	ff d7                	call   *%edi
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800226:	83 fa 01             	cmp    $0x1,%edx
  800229:	7e 0e                	jle    800239 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 02                	mov    (%edx),%eax
  800234:	8b 52 04             	mov    0x4(%edx),%edx
  800237:	eb 22                	jmp    80025b <getuint+0x38>
	else if (lflag)
  800239:	85 d2                	test   %edx,%edx
  80023b:	74 10                	je     80024d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80023d:	8b 10                	mov    (%eax),%edx
  80023f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800242:	89 08                	mov    %ecx,(%eax)
  800244:	8b 02                	mov    (%edx),%eax
  800246:	ba 00 00 00 00       	mov    $0x0,%edx
  80024b:	eb 0e                	jmp    80025b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80024d:	8b 10                	mov    (%eax),%edx
  80024f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 02                	mov    (%edx),%eax
  800256:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800263:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800267:	8b 10                	mov    (%eax),%edx
  800269:	3b 50 04             	cmp    0x4(%eax),%edx
  80026c:	73 0a                	jae    800278 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	88 02                	mov    %al,(%edx)
}
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800280:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800283:	50                   	push   %eax
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	e8 05 00 00 00       	call   800297 <vprintfmt>
	va_end(ap);
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 2c             	sub    $0x2c,%esp
  8002a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a9:	eb 12                	jmp    8002bd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	0f 84 d3 03 00 00    	je     800686 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	53                   	push   %ebx
  8002b7:	50                   	push   %eax
  8002b8:	ff d6                	call   *%esi
  8002ba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002bd:	83 c7 01             	add    $0x1,%edi
  8002c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c4:	83 f8 25             	cmp    $0x25,%eax
  8002c7:	75 e2                	jne    8002ab <vprintfmt+0x14>
  8002c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d4:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e7:	eb 07                	jmp    8002f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f0:	8d 47 01             	lea    0x1(%edi),%eax
  8002f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f6:	0f b6 07             	movzbl (%edi),%eax
  8002f9:	0f b6 c8             	movzbl %al,%ecx
  8002fc:	83 e8 23             	sub    $0x23,%eax
  8002ff:	3c 55                	cmp    $0x55,%al
  800301:	0f 87 64 03 00 00    	ja     80066b <vprintfmt+0x3d4>
  800307:	0f b6 c0             	movzbl %al,%eax
  80030a:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800314:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800318:	eb d6                	jmp    8002f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031d:	b8 00 00 00 00       	mov    $0x0,%eax
  800322:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800325:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800328:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80032c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80032f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800332:	83 fa 09             	cmp    $0x9,%edx
  800335:	77 39                	ja     800370 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800337:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80033a:	eb e9                	jmp    800325 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80033c:	8b 45 14             	mov    0x14(%ebp),%eax
  80033f:	8d 48 04             	lea    0x4(%eax),%ecx
  800342:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800345:	8b 00                	mov    (%eax),%eax
  800347:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034d:	eb 27                	jmp    800376 <vprintfmt+0xdf>
  80034f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800352:	85 c0                	test   %eax,%eax
  800354:	b9 00 00 00 00       	mov    $0x0,%ecx
  800359:	0f 49 c8             	cmovns %eax,%ecx
  80035c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800362:	eb 8c                	jmp    8002f0 <vprintfmt+0x59>
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800367:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036e:	eb 80                	jmp    8002f0 <vprintfmt+0x59>
  800370:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800373:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800376:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037a:	0f 89 70 ff ff ff    	jns    8002f0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800380:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80038d:	e9 5e ff ff ff       	jmp    8002f0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800392:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800398:	e9 53 ff ff ff       	jmp    8002f0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	53                   	push   %ebx
  8003aa:	ff 30                	pushl  (%eax)
  8003ac:	ff d6                	call   *%esi
			break;
  8003ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b4:	e9 04 ff ff ff       	jmp    8002bd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 50 04             	lea    0x4(%eax),%edx
  8003bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	99                   	cltd   
  8003c5:	31 d0                	xor    %edx,%eax
  8003c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c9:	83 f8 0f             	cmp    $0xf,%eax
  8003cc:	7f 0b                	jg     8003d9 <vprintfmt+0x142>
  8003ce:	8b 14 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%edx
  8003d5:	85 d2                	test   %edx,%edx
  8003d7:	75 18                	jne    8003f1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003d9:	50                   	push   %eax
  8003da:	68 4a 1e 80 00       	push   $0x801e4a
  8003df:	53                   	push   %ebx
  8003e0:	56                   	push   %esi
  8003e1:	e8 94 fe ff ff       	call   80027a <printfmt>
  8003e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ec:	e9 cc fe ff ff       	jmp    8002bd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 11 22 80 00       	push   $0x802211
  8003f7:	53                   	push   %ebx
  8003f8:	56                   	push   %esi
  8003f9:	e8 7c fe ff ff       	call   80027a <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800404:	e9 b4 fe ff ff       	jmp    8002bd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800414:	85 ff                	test   %edi,%edi
  800416:	b8 43 1e 80 00       	mov    $0x801e43,%eax
  80041b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800422:	0f 8e 94 00 00 00    	jle    8004bc <vprintfmt+0x225>
  800428:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042c:	0f 84 98 00 00 00    	je     8004ca <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 c8             	pushl  -0x38(%ebp)
  800438:	57                   	push   %edi
  800439:	e8 d0 02 00 00       	call   80070e <strnlen>
  80043e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800441:	29 c1                	sub    %eax,%ecx
  800443:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800446:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800449:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800450:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800453:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	eb 0f                	jmp    800466 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	ff 75 e0             	pushl  -0x20(%ebp)
  80045e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	83 ef 01             	sub    $0x1,%edi
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	85 ff                	test   %edi,%edi
  800468:	7f ed                	jg     800457 <vprintfmt+0x1c0>
  80046a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800470:	85 c9                	test   %ecx,%ecx
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	0f 49 c1             	cmovns %ecx,%eax
  80047a:	29 c1                	sub    %eax,%ecx
  80047c:	89 75 08             	mov    %esi,0x8(%ebp)
  80047f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800485:	89 cb                	mov    %ecx,%ebx
  800487:	eb 4d                	jmp    8004d6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800489:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048d:	74 1b                	je     8004aa <vprintfmt+0x213>
  80048f:	0f be c0             	movsbl %al,%eax
  800492:	83 e8 20             	sub    $0x20,%eax
  800495:	83 f8 5e             	cmp    $0x5e,%eax
  800498:	76 10                	jbe    8004aa <vprintfmt+0x213>
					putch('?', putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 0c             	pushl  0xc(%ebp)
  8004a0:	6a 3f                	push   $0x3f
  8004a2:	ff 55 08             	call   *0x8(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	eb 0d                	jmp    8004b7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	ff 75 0c             	pushl  0xc(%ebp)
  8004b0:	52                   	push   %edx
  8004b1:	ff 55 08             	call   *0x8(%ebp)
  8004b4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b7:	83 eb 01             	sub    $0x1,%ebx
  8004ba:	eb 1a                	jmp    8004d6 <vprintfmt+0x23f>
  8004bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bf:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c8:	eb 0c                	jmp    8004d6 <vprintfmt+0x23f>
  8004ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cd:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d6:	83 c7 01             	add    $0x1,%edi
  8004d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dd:	0f be d0             	movsbl %al,%edx
  8004e0:	85 d2                	test   %edx,%edx
  8004e2:	74 23                	je     800507 <vprintfmt+0x270>
  8004e4:	85 f6                	test   %esi,%esi
  8004e6:	78 a1                	js     800489 <vprintfmt+0x1f2>
  8004e8:	83 ee 01             	sub    $0x1,%esi
  8004eb:	79 9c                	jns    800489 <vprintfmt+0x1f2>
  8004ed:	89 df                	mov    %ebx,%edi
  8004ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f5:	eb 18                	jmp    80050f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	6a 20                	push   $0x20
  8004fd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ff:	83 ef 01             	sub    $0x1,%edi
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	eb 08                	jmp    80050f <vprintfmt+0x278>
  800507:	89 df                	mov    %ebx,%edi
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	85 ff                	test   %edi,%edi
  800511:	7f e4                	jg     8004f7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800516:	e9 a2 fd ff ff       	jmp    8002bd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051b:	83 fa 01             	cmp    $0x1,%edx
  80051e:	7e 16                	jle    800536 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 08             	lea    0x8(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 50 04             	mov    0x4(%eax),%edx
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800531:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800534:	eb 32                	jmp    800568 <vprintfmt+0x2d1>
	else if (lflag)
  800536:	85 d2                	test   %edx,%edx
  800538:	74 18                	je     800552 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800548:	89 c1                	mov    %eax,%ecx
  80054a:	c1 f9 1f             	sar    $0x1f,%ecx
  80054d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800550:	eb 16                	jmp    800568 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800560:	89 c1                	mov    %eax,%ecx
  800562:	c1 f9 1f             	sar    $0x1f,%ecx
  800565:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800568:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800574:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800579:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80057d:	0f 89 b0 00 00 00    	jns    800633 <vprintfmt+0x39c>
				putch('-', putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	6a 2d                	push   $0x2d
  800589:	ff d6                	call   *%esi
				num = -(long long) num;
  80058b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80058e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800591:	f7 d8                	neg    %eax
  800593:	83 d2 00             	adc    $0x0,%edx
  800596:	f7 da                	neg    %edx
  800598:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a6:	e9 88 00 00 00       	jmp    800633 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 70 fc ff ff       	call   800223 <getuint>
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005be:	eb 73                	jmp    800633 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c3:	e8 5b fc ff ff       	call   800223 <getuint>
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	6a 58                	push   $0x58
  8005d4:	ff d6                	call   *%esi
			putch('X', putdat);
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 58                	push   $0x58
  8005dc:	ff d6                	call   *%esi
			putch('X', putdat);
  8005de:	83 c4 08             	add    $0x8,%esp
  8005e1:	53                   	push   %ebx
  8005e2:	6a 58                	push   $0x58
  8005e4:	ff d6                	call   *%esi
			goto number;
  8005e6:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005e9:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005ee:	eb 43                	jmp    800633 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 30                	push   $0x30
  8005f6:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f8:	83 c4 08             	add    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 78                	push   $0x78
  8005fe:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	ba 00 00 00 00       	mov    $0x0,%edx
  800610:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800613:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800616:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800619:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80061e:	eb 13                	jmp    800633 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800620:	8d 45 14             	lea    0x14(%ebp),%eax
  800623:	e8 fb fb ff ff       	call   800223 <getuint>
  800628:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80062e:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800633:	83 ec 0c             	sub    $0xc,%esp
  800636:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80063a:	52                   	push   %edx
  80063b:	ff 75 e0             	pushl  -0x20(%ebp)
  80063e:	50                   	push   %eax
  80063f:	ff 75 dc             	pushl  -0x24(%ebp)
  800642:	ff 75 d8             	pushl  -0x28(%ebp)
  800645:	89 da                	mov    %ebx,%edx
  800647:	89 f0                	mov    %esi,%eax
  800649:	e8 26 fb ff ff       	call   800174 <printnum>
			break;
  80064e:	83 c4 20             	add    $0x20,%esp
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800654:	e9 64 fc ff ff       	jmp    8002bd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	51                   	push   %ecx
  80065e:	ff d6                	call   *%esi
			break;
  800660:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800666:	e9 52 fc ff ff       	jmp    8002bd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 25                	push   $0x25
  800671:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	eb 03                	jmp    80067b <vprintfmt+0x3e4>
  800678:	83 ef 01             	sub    $0x1,%edi
  80067b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067f:	75 f7                	jne    800678 <vprintfmt+0x3e1>
  800681:	e9 37 fc ff ff       	jmp    8002bd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800686:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800689:	5b                   	pop    %ebx
  80068a:	5e                   	pop    %esi
  80068b:	5f                   	pop    %edi
  80068c:	5d                   	pop    %ebp
  80068d:	c3                   	ret    

0080068e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068e:	55                   	push   %ebp
  80068f:	89 e5                	mov    %esp,%ebp
  800691:	83 ec 18             	sub    $0x18,%esp
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	74 26                	je     8006d5 <vsnprintf+0x47>
  8006af:	85 d2                	test   %edx,%edx
  8006b1:	7e 22                	jle    8006d5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b3:	ff 75 14             	pushl  0x14(%ebp)
  8006b6:	ff 75 10             	pushl  0x10(%ebp)
  8006b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	68 5d 02 80 00       	push   $0x80025d
  8006c2:	e8 d0 fb ff ff       	call   800297 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	eb 05                	jmp    8006da <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e5:	50                   	push   %eax
  8006e6:	ff 75 10             	pushl  0x10(%ebp)
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	ff 75 08             	pushl  0x8(%ebp)
  8006ef:	e8 9a ff ff ff       	call   80068e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800701:	eb 03                	jmp    800706 <strlen+0x10>
		n++;
  800703:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070a:	75 f7                	jne    800703 <strlen+0xd>
		n++;
	return n;
}
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800714:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	ba 00 00 00 00       	mov    $0x0,%edx
  80071c:	eb 03                	jmp    800721 <strnlen+0x13>
		n++;
  80071e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	39 c2                	cmp    %eax,%edx
  800723:	74 08                	je     80072d <strnlen+0x1f>
  800725:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800729:	75 f3                	jne    80071e <strnlen+0x10>
  80072b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800739:	89 c2                	mov    %eax,%edx
  80073b:	83 c2 01             	add    $0x1,%edx
  80073e:	83 c1 01             	add    $0x1,%ecx
  800741:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800745:	88 5a ff             	mov    %bl,-0x1(%edx)
  800748:	84 db                	test   %bl,%bl
  80074a:	75 ef                	jne    80073b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074c:	5b                   	pop    %ebx
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800756:	53                   	push   %ebx
  800757:	e8 9a ff ff ff       	call   8006f6 <strlen>
  80075c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075f:	ff 75 0c             	pushl  0xc(%ebp)
  800762:	01 d8                	add    %ebx,%eax
  800764:	50                   	push   %eax
  800765:	e8 c5 ff ff ff       	call   80072f <strcpy>
	return dst;
}
  80076a:	89 d8                	mov    %ebx,%eax
  80076c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	56                   	push   %esi
  800775:	53                   	push   %ebx
  800776:	8b 75 08             	mov    0x8(%ebp),%esi
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077c:	89 f3                	mov    %esi,%ebx
  80077e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800781:	89 f2                	mov    %esi,%edx
  800783:	eb 0f                	jmp    800794 <strncpy+0x23>
		*dst++ = *src;
  800785:	83 c2 01             	add    $0x1,%edx
  800788:	0f b6 01             	movzbl (%ecx),%eax
  80078b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078e:	80 39 01             	cmpb   $0x1,(%ecx)
  800791:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800794:	39 da                	cmp    %ebx,%edx
  800796:	75 ed                	jne    800785 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800798:	89 f0                	mov    %esi,%eax
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	56                   	push   %esi
  8007a2:	53                   	push   %ebx
  8007a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ac:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	74 21                	je     8007d3 <strlcpy+0x35>
  8007b2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b6:	89 f2                	mov    %esi,%edx
  8007b8:	eb 09                	jmp    8007c3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ba:	83 c2 01             	add    $0x1,%edx
  8007bd:	83 c1 01             	add    $0x1,%ecx
  8007c0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c3:	39 c2                	cmp    %eax,%edx
  8007c5:	74 09                	je     8007d0 <strlcpy+0x32>
  8007c7:	0f b6 19             	movzbl (%ecx),%ebx
  8007ca:	84 db                	test   %bl,%bl
  8007cc:	75 ec                	jne    8007ba <strlcpy+0x1c>
  8007ce:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d3:	29 f0                	sub    %esi,%eax
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e2:	eb 06                	jmp    8007ea <strcmp+0x11>
		p++, q++;
  8007e4:	83 c1 01             	add    $0x1,%ecx
  8007e7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ea:	0f b6 01             	movzbl (%ecx),%eax
  8007ed:	84 c0                	test   %al,%al
  8007ef:	74 04                	je     8007f5 <strcmp+0x1c>
  8007f1:	3a 02                	cmp    (%edx),%al
  8007f3:	74 ef                	je     8007e4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f5:	0f b6 c0             	movzbl %al,%eax
  8007f8:	0f b6 12             	movzbl (%edx),%edx
  8007fb:	29 d0                	sub    %edx,%eax
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	89 c3                	mov    %eax,%ebx
  80080b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080e:	eb 06                	jmp    800816 <strncmp+0x17>
		n--, p++, q++;
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800816:	39 d8                	cmp    %ebx,%eax
  800818:	74 15                	je     80082f <strncmp+0x30>
  80081a:	0f b6 08             	movzbl (%eax),%ecx
  80081d:	84 c9                	test   %cl,%cl
  80081f:	74 04                	je     800825 <strncmp+0x26>
  800821:	3a 0a                	cmp    (%edx),%cl
  800823:	74 eb                	je     800810 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800825:	0f b6 00             	movzbl (%eax),%eax
  800828:	0f b6 12             	movzbl (%edx),%edx
  80082b:	29 d0                	sub    %edx,%eax
  80082d:	eb 05                	jmp    800834 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800841:	eb 07                	jmp    80084a <strchr+0x13>
		if (*s == c)
  800843:	38 ca                	cmp    %cl,%dl
  800845:	74 0f                	je     800856 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	0f b6 10             	movzbl (%eax),%edx
  80084d:	84 d2                	test   %dl,%dl
  80084f:	75 f2                	jne    800843 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800862:	eb 03                	jmp    800867 <strfind+0xf>
  800864:	83 c0 01             	add    $0x1,%eax
  800867:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80086a:	38 ca                	cmp    %cl,%dl
  80086c:	74 04                	je     800872 <strfind+0x1a>
  80086e:	84 d2                	test   %dl,%dl
  800870:	75 f2                	jne    800864 <strfind+0xc>
			break;
	return (char *) s;
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	57                   	push   %edi
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800880:	85 c9                	test   %ecx,%ecx
  800882:	74 36                	je     8008ba <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800884:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088a:	75 28                	jne    8008b4 <memset+0x40>
  80088c:	f6 c1 03             	test   $0x3,%cl
  80088f:	75 23                	jne    8008b4 <memset+0x40>
		c &= 0xFF;
  800891:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800895:	89 d3                	mov    %edx,%ebx
  800897:	c1 e3 08             	shl    $0x8,%ebx
  80089a:	89 d6                	mov    %edx,%esi
  80089c:	c1 e6 18             	shl    $0x18,%esi
  80089f:	89 d0                	mov    %edx,%eax
  8008a1:	c1 e0 10             	shl    $0x10,%eax
  8008a4:	09 f0                	or     %esi,%eax
  8008a6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a8:	89 d8                	mov    %ebx,%eax
  8008aa:	09 d0                	or     %edx,%eax
  8008ac:	c1 e9 02             	shr    $0x2,%ecx
  8008af:	fc                   	cld    
  8008b0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b2:	eb 06                	jmp    8008ba <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b7:	fc                   	cld    
  8008b8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ba:	89 f8                	mov    %edi,%eax
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5f                   	pop    %edi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	57                   	push   %edi
  8008c5:	56                   	push   %esi
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cf:	39 c6                	cmp    %eax,%esi
  8008d1:	73 35                	jae    800908 <memmove+0x47>
  8008d3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d6:	39 d0                	cmp    %edx,%eax
  8008d8:	73 2e                	jae    800908 <memmove+0x47>
		s += n;
		d += n;
  8008da:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008dd:	89 d6                	mov    %edx,%esi
  8008df:	09 fe                	or     %edi,%esi
  8008e1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e7:	75 13                	jne    8008fc <memmove+0x3b>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 0e                	jne    8008fc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ee:	83 ef 04             	sub    $0x4,%edi
  8008f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
  8008f7:	fd                   	std    
  8008f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fa:	eb 09                	jmp    800905 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fc:	83 ef 01             	sub    $0x1,%edi
  8008ff:	8d 72 ff             	lea    -0x1(%edx),%esi
  800902:	fd                   	std    
  800903:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800905:	fc                   	cld    
  800906:	eb 1d                	jmp    800925 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800908:	89 f2                	mov    %esi,%edx
  80090a:	09 c2                	or     %eax,%edx
  80090c:	f6 c2 03             	test   $0x3,%dl
  80090f:	75 0f                	jne    800920 <memmove+0x5f>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 0a                	jne    800920 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800916:	c1 e9 02             	shr    $0x2,%ecx
  800919:	89 c7                	mov    %eax,%edi
  80091b:	fc                   	cld    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 05                	jmp    800925 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	ff 75 08             	pushl  0x8(%ebp)
  800935:	e8 87 ff ff ff       	call   8008c1 <memmove>
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
  800947:	89 c6                	mov    %eax,%esi
  800949:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094c:	eb 1a                	jmp    800968 <memcmp+0x2c>
		if (*s1 != *s2)
  80094e:	0f b6 08             	movzbl (%eax),%ecx
  800951:	0f b6 1a             	movzbl (%edx),%ebx
  800954:	38 d9                	cmp    %bl,%cl
  800956:	74 0a                	je     800962 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800958:	0f b6 c1             	movzbl %cl,%eax
  80095b:	0f b6 db             	movzbl %bl,%ebx
  80095e:	29 d8                	sub    %ebx,%eax
  800960:	eb 0f                	jmp    800971 <memcmp+0x35>
		s1++, s2++;
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800968:	39 f0                	cmp    %esi,%eax
  80096a:	75 e2                	jne    80094e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	53                   	push   %ebx
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80097c:	89 c1                	mov    %eax,%ecx
  80097e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800981:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800985:	eb 0a                	jmp    800991 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800987:	0f b6 10             	movzbl (%eax),%edx
  80098a:	39 da                	cmp    %ebx,%edx
  80098c:	74 07                	je     800995 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	39 c8                	cmp    %ecx,%eax
  800993:	72 f2                	jb     800987 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800995:	5b                   	pop    %ebx
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a4:	eb 03                	jmp    8009a9 <strtol+0x11>
		s++;
  8009a6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a9:	0f b6 01             	movzbl (%ecx),%eax
  8009ac:	3c 20                	cmp    $0x20,%al
  8009ae:	74 f6                	je     8009a6 <strtol+0xe>
  8009b0:	3c 09                	cmp    $0x9,%al
  8009b2:	74 f2                	je     8009a6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b4:	3c 2b                	cmp    $0x2b,%al
  8009b6:	75 0a                	jne    8009c2 <strtol+0x2a>
		s++;
  8009b8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c0:	eb 11                	jmp    8009d3 <strtol+0x3b>
  8009c2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c7:	3c 2d                	cmp    $0x2d,%al
  8009c9:	75 08                	jne    8009d3 <strtol+0x3b>
		s++, neg = 1;
  8009cb:	83 c1 01             	add    $0x1,%ecx
  8009ce:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d9:	75 15                	jne    8009f0 <strtol+0x58>
  8009db:	80 39 30             	cmpb   $0x30,(%ecx)
  8009de:	75 10                	jne    8009f0 <strtol+0x58>
  8009e0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e4:	75 7c                	jne    800a62 <strtol+0xca>
		s += 2, base = 16;
  8009e6:	83 c1 02             	add    $0x2,%ecx
  8009e9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ee:	eb 16                	jmp    800a06 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f0:	85 db                	test   %ebx,%ebx
  8009f2:	75 12                	jne    800a06 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fc:	75 08                	jne    800a06 <strtol+0x6e>
		s++, base = 8;
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0e:	0f b6 11             	movzbl (%ecx),%edx
  800a11:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a14:	89 f3                	mov    %esi,%ebx
  800a16:	80 fb 09             	cmp    $0x9,%bl
  800a19:	77 08                	ja     800a23 <strtol+0x8b>
			dig = *s - '0';
  800a1b:	0f be d2             	movsbl %dl,%edx
  800a1e:	83 ea 30             	sub    $0x30,%edx
  800a21:	eb 22                	jmp    800a45 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a23:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a26:	89 f3                	mov    %esi,%ebx
  800a28:	80 fb 19             	cmp    $0x19,%bl
  800a2b:	77 08                	ja     800a35 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a2d:	0f be d2             	movsbl %dl,%edx
  800a30:	83 ea 57             	sub    $0x57,%edx
  800a33:	eb 10                	jmp    800a45 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a35:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a38:	89 f3                	mov    %esi,%ebx
  800a3a:	80 fb 19             	cmp    $0x19,%bl
  800a3d:	77 16                	ja     800a55 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a3f:	0f be d2             	movsbl %dl,%edx
  800a42:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a45:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a48:	7d 0b                	jge    800a55 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a4a:	83 c1 01             	add    $0x1,%ecx
  800a4d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a51:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a53:	eb b9                	jmp    800a0e <strtol+0x76>

	if (endptr)
  800a55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a59:	74 0d                	je     800a68 <strtol+0xd0>
		*endptr = (char *) s;
  800a5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5e:	89 0e                	mov    %ecx,(%esi)
  800a60:	eb 06                	jmp    800a68 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a62:	85 db                	test   %ebx,%ebx
  800a64:	74 98                	je     8009fe <strtol+0x66>
  800a66:	eb 9e                	jmp    800a06 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a68:	89 c2                	mov    %eax,%edx
  800a6a:	f7 da                	neg    %edx
  800a6c:	85 ff                	test   %edi,%edi
  800a6e:	0f 45 c2             	cmovne %edx,%eax
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
  800a87:	89 c3                	mov    %eax,%ebx
  800a89:	89 c7                	mov    %eax,%edi
  800a8b:	89 c6                	mov    %eax,%esi
  800a8d:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5f                   	pop    %edi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa4:	89 d1                	mov    %edx,%ecx
  800aa6:	89 d3                	mov    %edx,%ebx
  800aa8:	89 d7                	mov    %edx,%edi
  800aaa:	89 d6                	mov    %edx,%esi
  800aac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800abc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac9:	89 cb                	mov    %ecx,%ebx
  800acb:	89 cf                	mov    %ecx,%edi
  800acd:	89 ce                	mov    %ecx,%esi
  800acf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ad1:	85 c0                	test   %eax,%eax
  800ad3:	7e 17                	jle    800aec <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad5:	83 ec 0c             	sub    $0xc,%esp
  800ad8:	50                   	push   %eax
  800ad9:	6a 03                	push   $0x3
  800adb:	68 3f 21 80 00       	push   $0x80213f
  800ae0:	6a 23                	push   $0x23
  800ae2:	68 5c 21 80 00       	push   $0x80215c
  800ae7:	e8 1a 0f 00 00       	call   801a06 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800afa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aff:	b8 02 00 00 00       	mov    $0x2,%eax
  800b04:	89 d1                	mov    %edx,%ecx
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	89 d7                	mov    %edx,%edi
  800b0a:	89 d6                	mov    %edx,%esi
  800b0c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_yield>:

void
sys_yield(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b23:	89 d1                	mov    %edx,%ecx
  800b25:	89 d3                	mov    %edx,%ebx
  800b27:	89 d7                	mov    %edx,%edi
  800b29:	89 d6                	mov    %edx,%esi
  800b2b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b3b:	be 00 00 00 00       	mov    $0x0,%esi
  800b40:	b8 04 00 00 00       	mov    $0x4,%eax
  800b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4e:	89 f7                	mov    %esi,%edi
  800b50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b52:	85 c0                	test   %eax,%eax
  800b54:	7e 17                	jle    800b6d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	50                   	push   %eax
  800b5a:	6a 04                	push   $0x4
  800b5c:	68 3f 21 80 00       	push   $0x80213f
  800b61:	6a 23                	push   $0x23
  800b63:	68 5c 21 80 00       	push   $0x80215c
  800b68:	e8 99 0e 00 00       	call   801a06 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 05                	push   $0x5
  800b9e:	68 3f 21 80 00       	push   $0x80213f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 5c 21 80 00       	push   $0x80215c
  800baa:	e8 57 0e 00 00       	call   801a06 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 df                	mov    %ebx,%edi
  800bd2:	89 de                	mov    %ebx,%esi
  800bd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	7e 17                	jle    800bf1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 06                	push   $0x6
  800be0:	68 3f 21 80 00       	push   $0x80213f
  800be5:	6a 23                	push   $0x23
  800be7:	68 5c 21 80 00       	push   $0x80215c
  800bec:	e8 15 0e 00 00       	call   801a06 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c07:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	89 df                	mov    %ebx,%edi
  800c14:	89 de                	mov    %ebx,%esi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 08                	push   $0x8
  800c22:	68 3f 21 80 00       	push   $0x80213f
  800c27:	6a 23                	push   $0x23
  800c29:	68 5c 21 80 00       	push   $0x80215c
  800c2e:	e8 d3 0d 00 00       	call   801a06 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 09                	push   $0x9
  800c64:	68 3f 21 80 00       	push   $0x80213f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 5c 21 80 00       	push   $0x80215c
  800c70:	e8 91 0d 00 00       	call   801a06 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 df                	mov    %ebx,%edi
  800c98:	89 de                	mov    %ebx,%esi
  800c9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 17                	jle    800cb7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 0a                	push   $0xa
  800ca6:	68 3f 21 80 00       	push   $0x80213f
  800cab:	6a 23                	push   $0x23
  800cad:	68 5c 21 80 00       	push   $0x80215c
  800cb2:	e8 4f 0d 00 00       	call   801a06 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cc5:	be 00 00 00 00       	mov    $0x0,%esi
  800cca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ceb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 cb                	mov    %ecx,%ebx
  800cfa:	89 cf                	mov    %ecx,%edi
  800cfc:	89 ce                	mov    %ecx,%esi
  800cfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7e 17                	jle    800d1b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 0d                	push   $0xd
  800d0a:	68 3f 21 80 00       	push   $0x80213f
  800d0f:	6a 23                	push   $0x23
  800d11:	68 5c 21 80 00       	push   $0x80215c
  800d16:	e8 eb 0c 00 00       	call   801a06 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	05 00 00 00 30       	add    $0x30000000,%eax
  800d2e:	c1 e8 0c             	shr    $0xc,%eax
}
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	05 00 00 00 30       	add    $0x30000000,%eax
  800d3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d43:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d50:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d55:	89 c2                	mov    %eax,%edx
  800d57:	c1 ea 16             	shr    $0x16,%edx
  800d5a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d61:	f6 c2 01             	test   $0x1,%dl
  800d64:	74 11                	je     800d77 <fd_alloc+0x2d>
  800d66:	89 c2                	mov    %eax,%edx
  800d68:	c1 ea 0c             	shr    $0xc,%edx
  800d6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d72:	f6 c2 01             	test   $0x1,%dl
  800d75:	75 09                	jne    800d80 <fd_alloc+0x36>
			*fd_store = fd;
  800d77:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7e:	eb 17                	jmp    800d97 <fd_alloc+0x4d>
  800d80:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d85:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d8a:	75 c9                	jne    800d55 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d8c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d92:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d9f:	83 f8 1f             	cmp    $0x1f,%eax
  800da2:	77 36                	ja     800dda <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800da4:	c1 e0 0c             	shl    $0xc,%eax
  800da7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	c1 ea 16             	shr    $0x16,%edx
  800db1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db8:	f6 c2 01             	test   $0x1,%dl
  800dbb:	74 24                	je     800de1 <fd_lookup+0x48>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	c1 ea 0c             	shr    $0xc,%edx
  800dc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc9:	f6 c2 01             	test   $0x1,%dl
  800dcc:	74 1a                	je     800de8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd1:	89 02                	mov    %eax,(%edx)
	return 0;
  800dd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd8:	eb 13                	jmp    800ded <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ddf:	eb 0c                	jmp    800ded <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de6:	eb 05                	jmp    800ded <fd_lookup+0x54>
  800de8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 08             	sub    $0x8,%esp
  800df5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df8:	ba e8 21 80 00       	mov    $0x8021e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dfd:	eb 13                	jmp    800e12 <dev_lookup+0x23>
  800dff:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e02:	39 08                	cmp    %ecx,(%eax)
  800e04:	75 0c                	jne    800e12 <dev_lookup+0x23>
			*dev = devtab[i];
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e10:	eb 2e                	jmp    800e40 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e12:	8b 02                	mov    (%edx),%eax
  800e14:	85 c0                	test   %eax,%eax
  800e16:	75 e7                	jne    800dff <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e18:	a1 04 40 80 00       	mov    0x804004,%eax
  800e1d:	8b 40 48             	mov    0x48(%eax),%eax
  800e20:	83 ec 04             	sub    $0x4,%esp
  800e23:	51                   	push   %ecx
  800e24:	50                   	push   %eax
  800e25:	68 6c 21 80 00       	push   $0x80216c
  800e2a:	e8 31 f3 ff ff       	call   800160 <cprintf>
	*dev = 0;
  800e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 10             	sub    $0x10,%esp
  800e4a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e53:	50                   	push   %eax
  800e54:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e5a:	c1 e8 0c             	shr    $0xc,%eax
  800e5d:	50                   	push   %eax
  800e5e:	e8 36 ff ff ff       	call   800d99 <fd_lookup>
  800e63:	83 c4 08             	add    $0x8,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	78 05                	js     800e6f <fd_close+0x2d>
	    || fd != fd2)
  800e6a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e6d:	74 0c                	je     800e7b <fd_close+0x39>
		return (must_exist ? r : 0);
  800e6f:	84 db                	test   %bl,%bl
  800e71:	ba 00 00 00 00       	mov    $0x0,%edx
  800e76:	0f 44 c2             	cmove  %edx,%eax
  800e79:	eb 41                	jmp    800ebc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e81:	50                   	push   %eax
  800e82:	ff 36                	pushl  (%esi)
  800e84:	e8 66 ff ff ff       	call   800def <dev_lookup>
  800e89:	89 c3                	mov    %eax,%ebx
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 1a                	js     800eac <fd_close+0x6a>
		if (dev->dev_close)
  800e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e95:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e98:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	74 0b                	je     800eac <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	56                   	push   %esi
  800ea5:	ff d0                	call   *%eax
  800ea7:	89 c3                	mov    %eax,%ebx
  800ea9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	56                   	push   %esi
  800eb0:	6a 00                	push   $0x0
  800eb2:	e8 00 fd ff ff       	call   800bb7 <sys_page_unmap>
	return r;
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	89 d8                	mov    %ebx,%eax
}
  800ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecc:	50                   	push   %eax
  800ecd:	ff 75 08             	pushl  0x8(%ebp)
  800ed0:	e8 c4 fe ff ff       	call   800d99 <fd_lookup>
  800ed5:	83 c4 08             	add    $0x8,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	78 10                	js     800eec <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	6a 01                	push   $0x1
  800ee1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee4:	e8 59 ff ff ff       	call   800e42 <fd_close>
  800ee9:	83 c4 10             	add    $0x10,%esp
}
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <close_all>:

void
close_all(void)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	53                   	push   %ebx
  800ef2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800efa:	83 ec 0c             	sub    $0xc,%esp
  800efd:	53                   	push   %ebx
  800efe:	e8 c0 ff ff ff       	call   800ec3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f03:	83 c3 01             	add    $0x1,%ebx
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	83 fb 20             	cmp    $0x20,%ebx
  800f0c:	75 ec                	jne    800efa <close_all+0xc>
		close(i);
}
  800f0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f11:	c9                   	leave  
  800f12:	c3                   	ret    

00800f13 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 2c             	sub    $0x2c,%esp
  800f1c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f1f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f22:	50                   	push   %eax
  800f23:	ff 75 08             	pushl  0x8(%ebp)
  800f26:	e8 6e fe ff ff       	call   800d99 <fd_lookup>
  800f2b:	83 c4 08             	add    $0x8,%esp
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	0f 88 c1 00 00 00    	js     800ff7 <dup+0xe4>
		return r;
	close(newfdnum);
  800f36:	83 ec 0c             	sub    $0xc,%esp
  800f39:	56                   	push   %esi
  800f3a:	e8 84 ff ff ff       	call   800ec3 <close>

	newfd = INDEX2FD(newfdnum);
  800f3f:	89 f3                	mov    %esi,%ebx
  800f41:	c1 e3 0c             	shl    $0xc,%ebx
  800f44:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f4a:	83 c4 04             	add    $0x4,%esp
  800f4d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f50:	e8 de fd ff ff       	call   800d33 <fd2data>
  800f55:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f57:	89 1c 24             	mov    %ebx,(%esp)
  800f5a:	e8 d4 fd ff ff       	call   800d33 <fd2data>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f65:	89 f8                	mov    %edi,%eax
  800f67:	c1 e8 16             	shr    $0x16,%eax
  800f6a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f71:	a8 01                	test   $0x1,%al
  800f73:	74 37                	je     800fac <dup+0x99>
  800f75:	89 f8                	mov    %edi,%eax
  800f77:	c1 e8 0c             	shr    $0xc,%eax
  800f7a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f81:	f6 c2 01             	test   $0x1,%dl
  800f84:	74 26                	je     800fac <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	25 07 0e 00 00       	and    $0xe07,%eax
  800f95:	50                   	push   %eax
  800f96:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f99:	6a 00                	push   $0x0
  800f9b:	57                   	push   %edi
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 d2 fb ff ff       	call   800b75 <sys_page_map>
  800fa3:	89 c7                	mov    %eax,%edi
  800fa5:	83 c4 20             	add    $0x20,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 2e                	js     800fda <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800faf:	89 d0                	mov    %edx,%eax
  800fb1:	c1 e8 0c             	shr    $0xc,%eax
  800fb4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc3:	50                   	push   %eax
  800fc4:	53                   	push   %ebx
  800fc5:	6a 00                	push   $0x0
  800fc7:	52                   	push   %edx
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 a6 fb ff ff       	call   800b75 <sys_page_map>
  800fcf:	89 c7                	mov    %eax,%edi
  800fd1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fd4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd6:	85 ff                	test   %edi,%edi
  800fd8:	79 1d                	jns    800ff7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	53                   	push   %ebx
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 d2 fb ff ff       	call   800bb7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fe5:	83 c4 08             	add    $0x8,%esp
  800fe8:	ff 75 d4             	pushl  -0x2c(%ebp)
  800feb:	6a 00                	push   $0x0
  800fed:	e8 c5 fb ff ff       	call   800bb7 <sys_page_unmap>
	return r;
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	89 f8                	mov    %edi,%eax
}
  800ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5e                   	pop    %esi
  800ffc:	5f                   	pop    %edi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	53                   	push   %ebx
  801003:	83 ec 14             	sub    $0x14,%esp
  801006:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801009:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100c:	50                   	push   %eax
  80100d:	53                   	push   %ebx
  80100e:	e8 86 fd ff ff       	call   800d99 <fd_lookup>
  801013:	83 c4 08             	add    $0x8,%esp
  801016:	89 c2                	mov    %eax,%edx
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 6d                	js     801089 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80101c:	83 ec 08             	sub    $0x8,%esp
  80101f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801022:	50                   	push   %eax
  801023:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801026:	ff 30                	pushl  (%eax)
  801028:	e8 c2 fd ff ff       	call   800def <dev_lookup>
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	78 4c                	js     801080 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801034:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801037:	8b 42 08             	mov    0x8(%edx),%eax
  80103a:	83 e0 03             	and    $0x3,%eax
  80103d:	83 f8 01             	cmp    $0x1,%eax
  801040:	75 21                	jne    801063 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801042:	a1 04 40 80 00       	mov    0x804004,%eax
  801047:	8b 40 48             	mov    0x48(%eax),%eax
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	53                   	push   %ebx
  80104e:	50                   	push   %eax
  80104f:	68 ad 21 80 00       	push   $0x8021ad
  801054:	e8 07 f1 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801061:	eb 26                	jmp    801089 <read+0x8a>
	}
	if (!dev->dev_read)
  801063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801066:	8b 40 08             	mov    0x8(%eax),%eax
  801069:	85 c0                	test   %eax,%eax
  80106b:	74 17                	je     801084 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80106d:	83 ec 04             	sub    $0x4,%esp
  801070:	ff 75 10             	pushl  0x10(%ebp)
  801073:	ff 75 0c             	pushl  0xc(%ebp)
  801076:	52                   	push   %edx
  801077:	ff d0                	call   *%eax
  801079:	89 c2                	mov    %eax,%edx
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	eb 09                	jmp    801089 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801080:	89 c2                	mov    %eax,%edx
  801082:	eb 05                	jmp    801089 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801084:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801089:	89 d0                	mov    %edx,%eax
  80108b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	8b 7d 08             	mov    0x8(%ebp),%edi
  80109c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80109f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a4:	eb 21                	jmp    8010c7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	89 f0                	mov    %esi,%eax
  8010ab:	29 d8                	sub    %ebx,%eax
  8010ad:	50                   	push   %eax
  8010ae:	89 d8                	mov    %ebx,%eax
  8010b0:	03 45 0c             	add    0xc(%ebp),%eax
  8010b3:	50                   	push   %eax
  8010b4:	57                   	push   %edi
  8010b5:	e8 45 ff ff ff       	call   800fff <read>
		if (m < 0)
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 10                	js     8010d1 <readn+0x41>
			return m;
		if (m == 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	74 0a                	je     8010cf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c5:	01 c3                	add    %eax,%ebx
  8010c7:	39 f3                	cmp    %esi,%ebx
  8010c9:	72 db                	jb     8010a6 <readn+0x16>
  8010cb:	89 d8                	mov    %ebx,%eax
  8010cd:	eb 02                	jmp    8010d1 <readn+0x41>
  8010cf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 14             	sub    $0x14,%esp
  8010e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	53                   	push   %ebx
  8010e8:	e8 ac fc ff ff       	call   800d99 <fd_lookup>
  8010ed:	83 c4 08             	add    $0x8,%esp
  8010f0:	89 c2                	mov    %eax,%edx
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 68                	js     80115e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f6:	83 ec 08             	sub    $0x8,%esp
  8010f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801100:	ff 30                	pushl  (%eax)
  801102:	e8 e8 fc ff ff       	call   800def <dev_lookup>
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 47                	js     801155 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80110e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801111:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801115:	75 21                	jne    801138 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801117:	a1 04 40 80 00       	mov    0x804004,%eax
  80111c:	8b 40 48             	mov    0x48(%eax),%eax
  80111f:	83 ec 04             	sub    $0x4,%esp
  801122:	53                   	push   %ebx
  801123:	50                   	push   %eax
  801124:	68 c9 21 80 00       	push   $0x8021c9
  801129:	e8 32 f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801136:	eb 26                	jmp    80115e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801138:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80113b:	8b 52 0c             	mov    0xc(%edx),%edx
  80113e:	85 d2                	test   %edx,%edx
  801140:	74 17                	je     801159 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801142:	83 ec 04             	sub    $0x4,%esp
  801145:	ff 75 10             	pushl  0x10(%ebp)
  801148:	ff 75 0c             	pushl  0xc(%ebp)
  80114b:	50                   	push   %eax
  80114c:	ff d2                	call   *%edx
  80114e:	89 c2                	mov    %eax,%edx
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	eb 09                	jmp    80115e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801155:	89 c2                	mov    %eax,%edx
  801157:	eb 05                	jmp    80115e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801159:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80115e:	89 d0                	mov    %edx,%eax
  801160:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801163:	c9                   	leave  
  801164:	c3                   	ret    

00801165 <seek>:

int
seek(int fdnum, off_t offset)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80116b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80116e:	50                   	push   %eax
  80116f:	ff 75 08             	pushl  0x8(%ebp)
  801172:	e8 22 fc ff ff       	call   800d99 <fd_lookup>
  801177:	83 c4 08             	add    $0x8,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	78 0e                	js     80118c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80117e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801181:	8b 55 0c             	mov    0xc(%ebp),%edx
  801184:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801187:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    

0080118e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	53                   	push   %ebx
  801192:	83 ec 14             	sub    $0x14,%esp
  801195:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801198:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	53                   	push   %ebx
  80119d:	e8 f7 fb ff ff       	call   800d99 <fd_lookup>
  8011a2:	83 c4 08             	add    $0x8,%esp
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 65                	js     801210 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b5:	ff 30                	pushl  (%eax)
  8011b7:	e8 33 fc ff ff       	call   800def <dev_lookup>
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 44                	js     801207 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ca:	75 21                	jne    8011ed <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011cc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011d1:	8b 40 48             	mov    0x48(%eax),%eax
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	53                   	push   %ebx
  8011d8:	50                   	push   %eax
  8011d9:	68 8c 21 80 00       	push   $0x80218c
  8011de:	e8 7d ef ff ff       	call   800160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011eb:	eb 23                	jmp    801210 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f0:	8b 52 18             	mov    0x18(%edx),%edx
  8011f3:	85 d2                	test   %edx,%edx
  8011f5:	74 14                	je     80120b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	ff 75 0c             	pushl  0xc(%ebp)
  8011fd:	50                   	push   %eax
  8011fe:	ff d2                	call   *%edx
  801200:	89 c2                	mov    %eax,%edx
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	eb 09                	jmp    801210 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801207:	89 c2                	mov    %eax,%edx
  801209:	eb 05                	jmp    801210 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80120b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801210:	89 d0                	mov    %edx,%eax
  801212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	53                   	push   %ebx
  80121b:	83 ec 14             	sub    $0x14,%esp
  80121e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801221:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	ff 75 08             	pushl  0x8(%ebp)
  801228:	e8 6c fb ff ff       	call   800d99 <fd_lookup>
  80122d:	83 c4 08             	add    $0x8,%esp
  801230:	89 c2                	mov    %eax,%edx
  801232:	85 c0                	test   %eax,%eax
  801234:	78 58                	js     80128e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123c:	50                   	push   %eax
  80123d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801240:	ff 30                	pushl  (%eax)
  801242:	e8 a8 fb ff ff       	call   800def <dev_lookup>
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 37                	js     801285 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80124e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801251:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801255:	74 32                	je     801289 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801257:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80125a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801261:	00 00 00 
	stat->st_isdir = 0;
  801264:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80126b:	00 00 00 
	stat->st_dev = dev;
  80126e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801274:	83 ec 08             	sub    $0x8,%esp
  801277:	53                   	push   %ebx
  801278:	ff 75 f0             	pushl  -0x10(%ebp)
  80127b:	ff 50 14             	call   *0x14(%eax)
  80127e:	89 c2                	mov    %eax,%edx
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	eb 09                	jmp    80128e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801285:	89 c2                	mov    %eax,%edx
  801287:	eb 05                	jmp    80128e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801289:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80128e:	89 d0                	mov    %edx,%eax
  801290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	6a 00                	push   $0x0
  80129f:	ff 75 08             	pushl  0x8(%ebp)
  8012a2:	e8 dc 01 00 00       	call   801483 <open>
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 1b                	js     8012cb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	ff 75 0c             	pushl  0xc(%ebp)
  8012b6:	50                   	push   %eax
  8012b7:	e8 5b ff ff ff       	call   801217 <fstat>
  8012bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8012be:	89 1c 24             	mov    %ebx,(%esp)
  8012c1:	e8 fd fb ff ff       	call   800ec3 <close>
	return r;
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	89 f0                	mov    %esi,%eax
}
  8012cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	56                   	push   %esi
  8012d6:	53                   	push   %ebx
  8012d7:	89 c6                	mov    %eax,%esi
  8012d9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012db:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e2:	75 12                	jne    8012f6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012e4:	83 ec 0c             	sub    $0xc,%esp
  8012e7:	6a 01                	push   $0x1
  8012e9:	e8 fe 07 00 00       	call   801aec <ipc_find_env>
  8012ee:	a3 00 40 80 00       	mov    %eax,0x804000
  8012f3:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012f6:	6a 07                	push   $0x7
  8012f8:	68 00 50 80 00       	push   $0x805000
  8012fd:	56                   	push   %esi
  8012fe:	ff 35 00 40 80 00    	pushl  0x804000
  801304:	e8 a0 07 00 00       	call   801aa9 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801309:	83 c4 0c             	add    $0xc,%esp
  80130c:	6a 00                	push   $0x0
  80130e:	53                   	push   %ebx
  80130f:	6a 00                	push   $0x0
  801311:	e8 36 07 00 00       	call   801a4c <ipc_recv>
}
  801316:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801319:	5b                   	pop    %ebx
  80131a:	5e                   	pop    %esi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	8b 40 0c             	mov    0xc(%eax),%eax
  801329:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80132e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801331:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801336:	ba 00 00 00 00       	mov    $0x0,%edx
  80133b:	b8 02 00 00 00       	mov    $0x2,%eax
  801340:	e8 8d ff ff ff       	call   8012d2 <fsipc>
}
  801345:	c9                   	leave  
  801346:	c3                   	ret    

00801347 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80134d:	8b 45 08             	mov    0x8(%ebp),%eax
  801350:	8b 40 0c             	mov    0xc(%eax),%eax
  801353:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801358:	ba 00 00 00 00       	mov    $0x0,%edx
  80135d:	b8 06 00 00 00       	mov    $0x6,%eax
  801362:	e8 6b ff ff ff       	call   8012d2 <fsipc>
}
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	53                   	push   %ebx
  80136d:	83 ec 04             	sub    $0x4,%esp
  801370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801373:	8b 45 08             	mov    0x8(%ebp),%eax
  801376:	8b 40 0c             	mov    0xc(%eax),%eax
  801379:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80137e:	ba 00 00 00 00       	mov    $0x0,%edx
  801383:	b8 05 00 00 00       	mov    $0x5,%eax
  801388:	e8 45 ff ff ff       	call   8012d2 <fsipc>
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 2c                	js     8013bd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	68 00 50 80 00       	push   $0x805000
  801399:	53                   	push   %ebx
  80139a:	e8 90 f3 ff ff       	call   80072f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80139f:	a1 80 50 80 00       	mov    0x805080,%eax
  8013a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013aa:	a1 84 50 80 00       	mov    0x805084,%eax
  8013af:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013d7:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013dc:	50                   	push   %eax
  8013dd:	ff 75 0c             	pushl  0xc(%ebp)
  8013e0:	68 08 50 80 00       	push   $0x805008
  8013e5:	e8 d7 f4 ff ff       	call   8008c1 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ef:	b8 04 00 00 00       	mov    $0x4,%eax
  8013f4:	e8 d9 fe ff ff       	call   8012d2 <fsipc>
	//panic("devfile_write not implemented");
}
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    

008013fb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	56                   	push   %esi
  8013ff:	53                   	push   %ebx
  801400:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	8b 40 0c             	mov    0xc(%eax),%eax
  801409:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80140e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801414:	ba 00 00 00 00       	mov    $0x0,%edx
  801419:	b8 03 00 00 00       	mov    $0x3,%eax
  80141e:	e8 af fe ff ff       	call   8012d2 <fsipc>
  801423:	89 c3                	mov    %eax,%ebx
  801425:	85 c0                	test   %eax,%eax
  801427:	78 51                	js     80147a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801429:	39 c6                	cmp    %eax,%esi
  80142b:	73 19                	jae    801446 <devfile_read+0x4b>
  80142d:	68 f8 21 80 00       	push   $0x8021f8
  801432:	68 ff 21 80 00       	push   $0x8021ff
  801437:	68 80 00 00 00       	push   $0x80
  80143c:	68 14 22 80 00       	push   $0x802214
  801441:	e8 c0 05 00 00       	call   801a06 <_panic>
	assert(r <= PGSIZE);
  801446:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80144b:	7e 19                	jle    801466 <devfile_read+0x6b>
  80144d:	68 1f 22 80 00       	push   $0x80221f
  801452:	68 ff 21 80 00       	push   $0x8021ff
  801457:	68 81 00 00 00       	push   $0x81
  80145c:	68 14 22 80 00       	push   $0x802214
  801461:	e8 a0 05 00 00       	call   801a06 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801466:	83 ec 04             	sub    $0x4,%esp
  801469:	50                   	push   %eax
  80146a:	68 00 50 80 00       	push   $0x805000
  80146f:	ff 75 0c             	pushl  0xc(%ebp)
  801472:	e8 4a f4 ff ff       	call   8008c1 <memmove>
	return r;
  801477:	83 c4 10             	add    $0x10,%esp
}
  80147a:	89 d8                	mov    %ebx,%eax
  80147c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	83 ec 20             	sub    $0x20,%esp
  80148a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80148d:	53                   	push   %ebx
  80148e:	e8 63 f2 ff ff       	call   8006f6 <strlen>
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80149b:	7f 67                	jg     801504 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80149d:	83 ec 0c             	sub    $0xc,%esp
  8014a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	e8 a1 f8 ff ff       	call   800d4a <fd_alloc>
  8014a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ac:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 57                	js     801509 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	53                   	push   %ebx
  8014b6:	68 00 50 80 00       	push   $0x805000
  8014bb:	e8 6f f2 ff ff       	call   80072f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c3:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d0:	e8 fd fd ff ff       	call   8012d2 <fsipc>
  8014d5:	89 c3                	mov    %eax,%ebx
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	79 14                	jns    8014f2 <open+0x6f>
		
		fd_close(fd, 0);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	6a 00                	push   $0x0
  8014e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e6:	e8 57 f9 ff ff       	call   800e42 <fd_close>
		return r;
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	89 da                	mov    %ebx,%edx
  8014f0:	eb 17                	jmp    801509 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f8:	e8 26 f8 ff ff       	call   800d23 <fd2num>
  8014fd:	89 c2                	mov    %eax,%edx
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	eb 05                	jmp    801509 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801504:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801509:	89 d0                	mov    %edx,%eax
  80150b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801516:	ba 00 00 00 00       	mov    $0x0,%edx
  80151b:	b8 08 00 00 00       	mov    $0x8,%eax
  801520:	e8 ad fd ff ff       	call   8012d2 <fsipc>
}
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	56                   	push   %esi
  80152b:	53                   	push   %ebx
  80152c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	ff 75 08             	pushl  0x8(%ebp)
  801535:	e8 f9 f7 ff ff       	call   800d33 <fd2data>
  80153a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	68 2b 22 80 00       	push   $0x80222b
  801544:	53                   	push   %ebx
  801545:	e8 e5 f1 ff ff       	call   80072f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80154a:	8b 46 04             	mov    0x4(%esi),%eax
  80154d:	2b 06                	sub    (%esi),%eax
  80154f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801555:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80155c:	00 00 00 
	stat->st_dev = &devpipe;
  80155f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801566:	30 80 00 
	return 0;
}
  801569:	b8 00 00 00 00       	mov    $0x0,%eax
  80156e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	53                   	push   %ebx
  801579:	83 ec 0c             	sub    $0xc,%esp
  80157c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80157f:	53                   	push   %ebx
  801580:	6a 00                	push   $0x0
  801582:	e8 30 f6 ff ff       	call   800bb7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801587:	89 1c 24             	mov    %ebx,(%esp)
  80158a:	e8 a4 f7 ff ff       	call   800d33 <fd2data>
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	50                   	push   %eax
  801593:	6a 00                	push   $0x0
  801595:	e8 1d f6 ff ff       	call   800bb7 <sys_page_unmap>
}
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	57                   	push   %edi
  8015a3:	56                   	push   %esi
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 1c             	sub    $0x1c,%esp
  8015a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015ab:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015bb:	e8 65 05 00 00       	call   801b25 <pageref>
  8015c0:	89 c3                	mov    %eax,%ebx
  8015c2:	89 3c 24             	mov    %edi,(%esp)
  8015c5:	e8 5b 05 00 00       	call   801b25 <pageref>
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	39 c3                	cmp    %eax,%ebx
  8015cf:	0f 94 c1             	sete   %cl
  8015d2:	0f b6 c9             	movzbl %cl,%ecx
  8015d5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015d8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015de:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015e1:	39 ce                	cmp    %ecx,%esi
  8015e3:	74 1b                	je     801600 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015e5:	39 c3                	cmp    %eax,%ebx
  8015e7:	75 c4                	jne    8015ad <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015e9:	8b 42 58             	mov    0x58(%edx),%eax
  8015ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ef:	50                   	push   %eax
  8015f0:	56                   	push   %esi
  8015f1:	68 32 22 80 00       	push   $0x802232
  8015f6:	e8 65 eb ff ff       	call   800160 <cprintf>
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	eb ad                	jmp    8015ad <_pipeisclosed+0xe>
	}
}
  801600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5f                   	pop    %edi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	57                   	push   %edi
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	83 ec 28             	sub    $0x28,%esp
  801614:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801617:	56                   	push   %esi
  801618:	e8 16 f7 ff ff       	call   800d33 <fd2data>
  80161d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	bf 00 00 00 00       	mov    $0x0,%edi
  801627:	eb 4b                	jmp    801674 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801629:	89 da                	mov    %ebx,%edx
  80162b:	89 f0                	mov    %esi,%eax
  80162d:	e8 6d ff ff ff       	call   80159f <_pipeisclosed>
  801632:	85 c0                	test   %eax,%eax
  801634:	75 48                	jne    80167e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801636:	e8 d8 f4 ff ff       	call   800b13 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80163b:	8b 43 04             	mov    0x4(%ebx),%eax
  80163e:	8b 0b                	mov    (%ebx),%ecx
  801640:	8d 51 20             	lea    0x20(%ecx),%edx
  801643:	39 d0                	cmp    %edx,%eax
  801645:	73 e2                	jae    801629 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801647:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80164e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801651:	89 c2                	mov    %eax,%edx
  801653:	c1 fa 1f             	sar    $0x1f,%edx
  801656:	89 d1                	mov    %edx,%ecx
  801658:	c1 e9 1b             	shr    $0x1b,%ecx
  80165b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80165e:	83 e2 1f             	and    $0x1f,%edx
  801661:	29 ca                	sub    %ecx,%edx
  801663:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801667:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80166b:	83 c0 01             	add    $0x1,%eax
  80166e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801671:	83 c7 01             	add    $0x1,%edi
  801674:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801677:	75 c2                	jne    80163b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801679:	8b 45 10             	mov    0x10(%ebp),%eax
  80167c:	eb 05                	jmp    801683 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801686:	5b                   	pop    %ebx
  801687:	5e                   	pop    %esi
  801688:	5f                   	pop    %edi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	57                   	push   %edi
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	83 ec 18             	sub    $0x18,%esp
  801694:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801697:	57                   	push   %edi
  801698:	e8 96 f6 ff ff       	call   800d33 <fd2data>
  80169d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a7:	eb 3d                	jmp    8016e6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016a9:	85 db                	test   %ebx,%ebx
  8016ab:	74 04                	je     8016b1 <devpipe_read+0x26>
				return i;
  8016ad:	89 d8                	mov    %ebx,%eax
  8016af:	eb 44                	jmp    8016f5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016b1:	89 f2                	mov    %esi,%edx
  8016b3:	89 f8                	mov    %edi,%eax
  8016b5:	e8 e5 fe ff ff       	call   80159f <_pipeisclosed>
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	75 32                	jne    8016f0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016be:	e8 50 f4 ff ff       	call   800b13 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016c3:	8b 06                	mov    (%esi),%eax
  8016c5:	3b 46 04             	cmp    0x4(%esi),%eax
  8016c8:	74 df                	je     8016a9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ca:	99                   	cltd   
  8016cb:	c1 ea 1b             	shr    $0x1b,%edx
  8016ce:	01 d0                	add    %edx,%eax
  8016d0:	83 e0 1f             	and    $0x1f,%eax
  8016d3:	29 d0                	sub    %edx,%eax
  8016d5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016dd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016e0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e3:	83 c3 01             	add    $0x1,%ebx
  8016e6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016e9:	75 d8                	jne    8016c3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ee:	eb 05                	jmp    8016f5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016f0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5f                   	pop    %edi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	56                   	push   %esi
  801701:	53                   	push   %ebx
  801702:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801705:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801708:	50                   	push   %eax
  801709:	e8 3c f6 ff ff       	call   800d4a <fd_alloc>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	89 c2                	mov    %eax,%edx
  801713:	85 c0                	test   %eax,%eax
  801715:	0f 88 2c 01 00 00    	js     801847 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	68 07 04 00 00       	push   $0x407
  801723:	ff 75 f4             	pushl  -0xc(%ebp)
  801726:	6a 00                	push   $0x0
  801728:	e8 05 f4 ff ff       	call   800b32 <sys_page_alloc>
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	89 c2                	mov    %eax,%edx
  801732:	85 c0                	test   %eax,%eax
  801734:	0f 88 0d 01 00 00    	js     801847 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	e8 04 f6 ff ff       	call   800d4a <fd_alloc>
  801746:	89 c3                	mov    %eax,%ebx
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	0f 88 e2 00 00 00    	js     801835 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801753:	83 ec 04             	sub    $0x4,%esp
  801756:	68 07 04 00 00       	push   $0x407
  80175b:	ff 75 f0             	pushl  -0x10(%ebp)
  80175e:	6a 00                	push   $0x0
  801760:	e8 cd f3 ff ff       	call   800b32 <sys_page_alloc>
  801765:	89 c3                	mov    %eax,%ebx
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	85 c0                	test   %eax,%eax
  80176c:	0f 88 c3 00 00 00    	js     801835 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	ff 75 f4             	pushl  -0xc(%ebp)
  801778:	e8 b6 f5 ff ff       	call   800d33 <fd2data>
  80177d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177f:	83 c4 0c             	add    $0xc,%esp
  801782:	68 07 04 00 00       	push   $0x407
  801787:	50                   	push   %eax
  801788:	6a 00                	push   $0x0
  80178a:	e8 a3 f3 ff ff       	call   800b32 <sys_page_alloc>
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	0f 88 89 00 00 00    	js     801825 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80179c:	83 ec 0c             	sub    $0xc,%esp
  80179f:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a2:	e8 8c f5 ff ff       	call   800d33 <fd2data>
  8017a7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017ae:	50                   	push   %eax
  8017af:	6a 00                	push   $0x0
  8017b1:	56                   	push   %esi
  8017b2:	6a 00                	push   $0x0
  8017b4:	e8 bc f3 ff ff       	call   800b75 <sys_page_map>
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	83 c4 20             	add    $0x20,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 55                	js     801817 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017c2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017cb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017d7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f2:	e8 2c f5 ff ff       	call   800d23 <fd2num>
  8017f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017fc:	83 c4 04             	add    $0x4,%esp
  8017ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801802:	e8 1c f5 ff ff       	call   800d23 <fd2num>
  801807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80180a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	eb 30                	jmp    801847 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	56                   	push   %esi
  80181b:	6a 00                	push   $0x0
  80181d:	e8 95 f3 ff ff       	call   800bb7 <sys_page_unmap>
  801822:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801825:	83 ec 08             	sub    $0x8,%esp
  801828:	ff 75 f0             	pushl  -0x10(%ebp)
  80182b:	6a 00                	push   $0x0
  80182d:	e8 85 f3 ff ff       	call   800bb7 <sys_page_unmap>
  801832:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801835:	83 ec 08             	sub    $0x8,%esp
  801838:	ff 75 f4             	pushl  -0xc(%ebp)
  80183b:	6a 00                	push   $0x0
  80183d:	e8 75 f3 ff ff       	call   800bb7 <sys_page_unmap>
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801847:	89 d0                	mov    %edx,%eax
  801849:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184c:	5b                   	pop    %ebx
  80184d:	5e                   	pop    %esi
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	ff 75 08             	pushl  0x8(%ebp)
  80185d:	e8 37 f5 ff ff       	call   800d99 <fd_lookup>
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	78 18                	js     801881 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801869:	83 ec 0c             	sub    $0xc,%esp
  80186c:	ff 75 f4             	pushl  -0xc(%ebp)
  80186f:	e8 bf f4 ff ff       	call   800d33 <fd2data>
	return _pipeisclosed(fd, p);
  801874:	89 c2                	mov    %eax,%edx
  801876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801879:	e8 21 fd ff ff       	call   80159f <_pipeisclosed>
  80187e:	83 c4 10             	add    $0x10,%esp
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801893:	68 4a 22 80 00       	push   $0x80224a
  801898:	ff 75 0c             	pushl  0xc(%ebp)
  80189b:	e8 8f ee ff ff       	call   80072f <strcpy>
	return 0;
}
  8018a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	57                   	push   %edi
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018b8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018be:	eb 2d                	jmp    8018ed <devcons_write+0x46>
		m = n - tot;
  8018c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018c3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018c5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018c8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018cd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018d0:	83 ec 04             	sub    $0x4,%esp
  8018d3:	53                   	push   %ebx
  8018d4:	03 45 0c             	add    0xc(%ebp),%eax
  8018d7:	50                   	push   %eax
  8018d8:	57                   	push   %edi
  8018d9:	e8 e3 ef ff ff       	call   8008c1 <memmove>
		sys_cputs(buf, m);
  8018de:	83 c4 08             	add    $0x8,%esp
  8018e1:	53                   	push   %ebx
  8018e2:	57                   	push   %edi
  8018e3:	e8 8e f1 ff ff       	call   800a76 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e8:	01 de                	add    %ebx,%esi
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	89 f0                	mov    %esi,%eax
  8018ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018f2:	72 cc                	jb     8018c0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	5f                   	pop    %edi
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801907:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80190b:	74 2a                	je     801937 <devcons_read+0x3b>
  80190d:	eb 05                	jmp    801914 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80190f:	e8 ff f1 ff ff       	call   800b13 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801914:	e8 7b f1 ff ff       	call   800a94 <sys_cgetc>
  801919:	85 c0                	test   %eax,%eax
  80191b:	74 f2                	je     80190f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 16                	js     801937 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801921:	83 f8 04             	cmp    $0x4,%eax
  801924:	74 0c                	je     801932 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801926:	8b 55 0c             	mov    0xc(%ebp),%edx
  801929:	88 02                	mov    %al,(%edx)
	return 1;
  80192b:	b8 01 00 00 00       	mov    $0x1,%eax
  801930:	eb 05                	jmp    801937 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801932:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801945:	6a 01                	push   $0x1
  801947:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80194a:	50                   	push   %eax
  80194b:	e8 26 f1 ff ff       	call   800a76 <sys_cputs>
}
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <getchar>:

int
getchar(void)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80195b:	6a 01                	push   $0x1
  80195d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801960:	50                   	push   %eax
  801961:	6a 00                	push   $0x0
  801963:	e8 97 f6 ff ff       	call   800fff <read>
	if (r < 0)
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 0f                	js     80197e <getchar+0x29>
		return r;
	if (r < 1)
  80196f:	85 c0                	test   %eax,%eax
  801971:	7e 06                	jle    801979 <getchar+0x24>
		return -E_EOF;
	return c;
  801973:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801977:	eb 05                	jmp    80197e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801979:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801986:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	ff 75 08             	pushl  0x8(%ebp)
  80198d:	e8 07 f4 ff ff       	call   800d99 <fd_lookup>
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	85 c0                	test   %eax,%eax
  801997:	78 11                	js     8019aa <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a2:	39 10                	cmp    %edx,(%eax)
  8019a4:	0f 94 c0             	sete   %al
  8019a7:	0f b6 c0             	movzbl %al,%eax
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <opencons>:

int
opencons(void)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b5:	50                   	push   %eax
  8019b6:	e8 8f f3 ff ff       	call   800d4a <fd_alloc>
  8019bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8019be:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 3e                	js     801a02 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019c4:	83 ec 04             	sub    $0x4,%esp
  8019c7:	68 07 04 00 00       	push   $0x407
  8019cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cf:	6a 00                	push   $0x0
  8019d1:	e8 5c f1 ff ff       	call   800b32 <sys_page_alloc>
  8019d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 23                	js     801a02 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019df:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ed:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	50                   	push   %eax
  8019f8:	e8 26 f3 ff ff       	call   800d23 <fd2num>
  8019fd:	89 c2                	mov    %eax,%edx
  8019ff:	83 c4 10             	add    $0x10,%esp
}
  801a02:	89 d0                	mov    %edx,%eax
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a0b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a0e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a14:	e8 db f0 ff ff       	call   800af4 <sys_getenvid>
  801a19:	83 ec 0c             	sub    $0xc,%esp
  801a1c:	ff 75 0c             	pushl  0xc(%ebp)
  801a1f:	ff 75 08             	pushl  0x8(%ebp)
  801a22:	56                   	push   %esi
  801a23:	50                   	push   %eax
  801a24:	68 58 22 80 00       	push   $0x802258
  801a29:	e8 32 e7 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a2e:	83 c4 18             	add    $0x18,%esp
  801a31:	53                   	push   %ebx
  801a32:	ff 75 10             	pushl  0x10(%ebp)
  801a35:	e8 d5 e6 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801a3a:	c7 04 24 43 22 80 00 	movl   $0x802243,(%esp)
  801a41:	e8 1a e7 ff ff       	call   800160 <cprintf>
  801a46:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a49:	cc                   	int3   
  801a4a:	eb fd                	jmp    801a49 <_panic+0x43>

00801a4c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a54:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	ff 75 0c             	pushl  0xc(%ebp)
  801a5d:	e8 80 f2 ff ff       	call   800ce2 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	85 f6                	test   %esi,%esi
  801a67:	74 1c                	je     801a85 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a69:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6e:	8b 40 78             	mov    0x78(%eax),%eax
  801a71:	89 06                	mov    %eax,(%esi)
  801a73:	eb 10                	jmp    801a85 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	68 7c 22 80 00       	push   $0x80227c
  801a7d:	e8 de e6 ff ff       	call   800160 <cprintf>
  801a82:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a85:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8a:	8b 50 74             	mov    0x74(%eax),%edx
  801a8d:	85 d2                	test   %edx,%edx
  801a8f:	74 e4                	je     801a75 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a91:	85 db                	test   %ebx,%ebx
  801a93:	74 05                	je     801a9a <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a95:	8b 40 74             	mov    0x74(%eax),%eax
  801a98:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9f:	8b 40 70             	mov    0x70(%eax),%eax

}
  801aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	57                   	push   %edi
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801abb:	85 db                	test   %ebx,%ebx
  801abd:	75 13                	jne    801ad2 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801abf:	6a 00                	push   $0x0
  801ac1:	68 00 00 c0 ee       	push   $0xeec00000
  801ac6:	56                   	push   %esi
  801ac7:	57                   	push   %edi
  801ac8:	e8 f2 f1 ff ff       	call   800cbf <sys_ipc_try_send>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	eb 0e                	jmp    801ae0 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801ad2:	ff 75 14             	pushl  0x14(%ebp)
  801ad5:	53                   	push   %ebx
  801ad6:	56                   	push   %esi
  801ad7:	57                   	push   %edi
  801ad8:	e8 e2 f1 ff ff       	call   800cbf <sys_ipc_try_send>
  801add:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	75 d7                	jne    801abb <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ae4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae7:	5b                   	pop    %ebx
  801ae8:	5e                   	pop    %esi
  801ae9:	5f                   	pop    %edi
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801afa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b00:	8b 52 50             	mov    0x50(%edx),%edx
  801b03:	39 ca                	cmp    %ecx,%edx
  801b05:	75 0d                	jne    801b14 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b07:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b0a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b0f:	8b 40 48             	mov    0x48(%eax),%eax
  801b12:	eb 0f                	jmp    801b23 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b14:	83 c0 01             	add    $0x1,%eax
  801b17:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b1c:	75 d9                	jne    801af7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2b:	89 d0                	mov    %edx,%eax
  801b2d:	c1 e8 16             	shr    $0x16,%eax
  801b30:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3c:	f6 c1 01             	test   $0x1,%cl
  801b3f:	74 1d                	je     801b5e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b41:	c1 ea 0c             	shr    $0xc,%edx
  801b44:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b4b:	f6 c2 01             	test   $0x1,%dl
  801b4e:	74 0e                	je     801b5e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b50:	c1 ea 0c             	shr    $0xc,%edx
  801b53:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b5a:	ef 
  801b5b:	0f b7 c0             	movzwl %ax,%eax
}
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b77:	85 f6                	test   %esi,%esi
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	75 3d                	jne    801bc0 <__udivdi3+0x60>
  801b83:	39 cf                	cmp    %ecx,%edi
  801b85:	0f 87 c5 00 00 00    	ja     801c50 <__udivdi3+0xf0>
  801b8b:	85 ff                	test   %edi,%edi
  801b8d:	89 fd                	mov    %edi,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f7                	div    %edi
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	89 cf                	mov    %ecx,%edi
  801ba8:	f7 f5                	div    %ebp
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	89 fa                	mov    %edi,%edx
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	90                   	nop
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 ce                	cmp    %ecx,%esi
  801bc2:	77 74                	ja     801c38 <__udivdi3+0xd8>
  801bc4:	0f bd fe             	bsr    %esi,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0x108>
  801bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	89 c5                	mov    %eax,%ebp
  801bd9:	29 fb                	sub    %edi,%ebx
  801bdb:	d3 e6                	shl    %cl,%esi
  801bdd:	89 d9                	mov    %ebx,%ecx
  801bdf:	d3 ed                	shr    %cl,%ebp
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	09 ee                	or     %ebp,%esi
  801be7:	89 d9                	mov    %ebx,%ecx
  801be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bed:	89 d5                	mov    %edx,%ebp
  801bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bf3:	d3 ed                	shr    %cl,%ebp
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	89 d9                	mov    %ebx,%ecx
  801bfb:	d3 e8                	shr    %cl,%eax
  801bfd:	09 c2                	or     %eax,%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	89 ea                	mov    %ebp,%edx
  801c03:	f7 f6                	div    %esi
  801c05:	89 d5                	mov    %edx,%ebp
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	f7 64 24 0c          	mull   0xc(%esp)
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	72 10                	jb     801c21 <__udivdi3+0xc1>
  801c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e6                	shl    %cl,%esi
  801c19:	39 c6                	cmp    %eax,%esi
  801c1b:	73 07                	jae    801c24 <__udivdi3+0xc4>
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	75 03                	jne    801c24 <__udivdi3+0xc4>
  801c21:	83 eb 01             	sub    $0x1,%ebx
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	89 fa                	mov    %edi,%edx
  801c2a:	83 c4 1c             	add    $0x1c,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c38:	31 ff                	xor    %edi,%edi
  801c3a:	31 db                	xor    %ebx,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	f7 f7                	div    %edi
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	89 fa                	mov    %edi,%edx
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 ce                	cmp    %ecx,%esi
  801c6a:	72 0c                	jb     801c78 <__udivdi3+0x118>
  801c6c:	31 db                	xor    %ebx,%ebx
  801c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c72:	0f 87 34 ff ff ff    	ja     801bac <__udivdi3+0x4c>
  801c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c7d:	e9 2a ff ff ff       	jmp    801bac <__udivdi3+0x4c>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f3                	mov    %esi,%ebx
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	75 1c                	jne    801cd8 <__umoddi3+0x48>
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	76 50                	jbe    801d10 <__umoddi3+0x80>
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	f7 f7                	div    %edi
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	77 52                	ja     801d30 <__umoddi3+0xa0>
  801cde:	0f bd ea             	bsr    %edx,%ebp
  801ce1:	83 f5 1f             	xor    $0x1f,%ebp
  801ce4:	75 5a                	jne    801d40 <__umoddi3+0xb0>
  801ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	39 0c 24             	cmp    %ecx,(%esp)
  801cf3:	0f 86 d7 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	85 ff                	test   %edi,%edi
  801d12:	89 fd                	mov    %edi,%ebp
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 c8                	mov    %ecx,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	eb 99                	jmp    801cc8 <__umoddi3+0x38>
  801d2f:	90                   	nop
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	8b 34 24             	mov    (%esp),%esi
  801d43:	bf 20 00 00 00       	mov    $0x20,%edi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	29 ef                	sub    %ebp,%edi
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 f9                	mov    %edi,%ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	d3 ea                	shr    %cl,%edx
  801d54:	89 e9                	mov    %ebp,%ecx
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 14 24             	mov    %edx,(%esp)
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	d3 e3                	shl    %cl,%ebx
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d8                	or     %ebx,%eax
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	f7 34 24             	divl   (%esp)
  801d84:	89 d6                	mov    %edx,%esi
  801d86:	d3 e3                	shl    %cl,%ebx
  801d88:	f7 64 24 04          	mull   0x4(%esp)
  801d8c:	39 d6                	cmp    %edx,%esi
  801d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	72 08                	jb     801da0 <__umoddi3+0x110>
  801d98:	75 11                	jne    801dab <__umoddi3+0x11b>
  801d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d9e:	73 0b                	jae    801dab <__umoddi3+0x11b>
  801da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801da4:	1b 14 24             	sbb    (%esp),%edx
  801da7:	89 d1                	mov    %edx,%ecx
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801daf:	29 da                	sub    %ebx,%edx
  801db1:	19 ce                	sbb    %ecx,%esi
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e0                	shl    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	d3 ee                	shr    %cl,%esi
  801dc1:	09 d0                	or     %edx,%eax
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	83 c4 1c             	add    $0x1c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 f9                	sub    %edi,%ecx
  801dd2:	19 d6                	sbb    %edx,%esi
  801dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddc:	e9 18 ff ff ff       	jmp    801cf9 <__umoddi3+0x69>
