
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 e8 0a 00 00       	call   800b28 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 f9 0c 00 00       	call   800d57 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 40 1e 80 00       	push   $0x801e40
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 51 1e 80 00       	push   $0x801e51
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 18 0d 00 00       	call   800db4 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 77 0a 00 00       	call   800b28 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 09 0f 00 00       	call   800ffb <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 eb 09 00 00       	call   800ae7 <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 79 09 00 00       	call   800aaa <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 54 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 1e 09 00 00       	call   800aaa <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 a4 19 00 00       	call   801ba0 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 91 1a 00 00       	call   801cd0 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 72 1e 80 00 	movsbl 0x801e72(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 d3 03 00 00    	je     8006ba <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	ff d6                	call   *%esi
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	83 c7 01             	add    $0x1,%edi
  8002f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f8:	83 f8 25             	cmp    $0x25,%eax
  8002fb:	75 e2                	jne    8002df <vprintfmt+0x14>
  8002fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800301:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800308:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 07                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 07             	movzbl (%edi),%eax
  80032d:	0f b6 c8             	movzbl %al,%ecx
  800330:	83 e8 23             	sub    $0x23,%eax
  800333:	3c 55                	cmp    $0x55,%al
  800335:	0f 87 64 03 00 00    	ja     80069f <vprintfmt+0x3d4>
  80033b:	0f b6 c0             	movzbl %al,%eax
  80033e:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034c:	eb d6                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800360:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800363:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800366:	83 fa 09             	cmp    $0x9,%edx
  800369:	77 39                	ja     8003a4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 48 04             	lea    0x4(%eax),%ecx
  800376:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800381:	eb 27                	jmp    8003aa <vprintfmt+0xdf>
  800383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800386:	85 c0                	test   %eax,%eax
  800388:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038d:	0f 49 c8             	cmovns %eax,%ecx
  800390:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800396:	eb 8c                	jmp    800324 <vprintfmt+0x59>
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a2:	eb 80                	jmp    800324 <vprintfmt+0x59>
  8003a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a7:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	0f 89 70 ff ff ff    	jns    800324 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003c1:	e9 5e ff ff ff       	jmp    800324 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cc:	e9 53 ff ff ff       	jmp    800324 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	ff 30                	pushl  (%eax)
  8003e0:	ff d6                	call   *%esi
			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e8:	e9 04 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	99                   	cltd   
  8003f9:	31 d0                	xor    %edx,%eax
  8003fb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fd:	83 f8 0f             	cmp    $0xf,%eax
  800400:	7f 0b                	jg     80040d <vprintfmt+0x142>
  800402:	8b 14 85 20 21 80 00 	mov    0x802120(,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	75 18                	jne    800425 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040d:	50                   	push   %eax
  80040e:	68 8a 1e 80 00       	push   $0x801e8a
  800413:	53                   	push   %ebx
  800414:	56                   	push   %esi
  800415:	e8 94 fe ff ff       	call   8002ae <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800420:	e9 cc fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800425:	52                   	push   %edx
  800426:	68 61 22 80 00       	push   $0x802261
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 7c fe ff ff       	call   8002ae <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	e9 b4 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800448:	85 ff                	test   %edi,%edi
  80044a:	b8 83 1e 80 00       	mov    $0x801e83,%eax
  80044f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	0f 8e 94 00 00 00    	jle    8004f0 <vprintfmt+0x225>
  80045c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800460:	0f 84 98 00 00 00    	je     8004fe <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	ff 75 c8             	pushl  -0x38(%ebp)
  80046c:	57                   	push   %edi
  80046d:	e8 d0 02 00 00       	call   800742 <strnlen>
  800472:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800481:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800484:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800487:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	eb 0f                	jmp    80049a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	ff 75 e0             	pushl  -0x20(%ebp)
  800492:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	83 ef 01             	sub    $0x1,%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 ff                	test   %edi,%edi
  80049c:	7f ed                	jg     80048b <vprintfmt+0x1c0>
  80049e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ab:	0f 49 c1             	cmovns %ecx,%eax
  8004ae:	29 c1                	sub    %eax,%ecx
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	89 cb                	mov    %ecx,%ebx
  8004bb:	eb 4d                	jmp    80050a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c1:	74 1b                	je     8004de <vprintfmt+0x213>
  8004c3:	0f be c0             	movsbl %al,%eax
  8004c6:	83 e8 20             	sub    $0x20,%eax
  8004c9:	83 f8 5e             	cmp    $0x5e,%eax
  8004cc:	76 10                	jbe    8004de <vprintfmt+0x213>
					putch('?', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 0c             	pushl  0xc(%ebp)
  8004d4:	6a 3f                	push   $0x3f
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb 0d                	jmp    8004eb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	52                   	push   %edx
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004eb:	83 eb 01             	sub    $0x1,%ebx
  8004ee:	eb 1a                	jmp    80050a <vprintfmt+0x23f>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	eb 0c                	jmp    80050a <vprintfmt+0x23f>
  8004fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800501:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800504:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800507:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050a:	83 c7 01             	add    $0x1,%edi
  80050d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800511:	0f be d0             	movsbl %al,%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	74 23                	je     80053b <vprintfmt+0x270>
  800518:	85 f6                	test   %esi,%esi
  80051a:	78 a1                	js     8004bd <vprintfmt+0x1f2>
  80051c:	83 ee 01             	sub    $0x1,%esi
  80051f:	79 9c                	jns    8004bd <vprintfmt+0x1f2>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	eb 18                	jmp    800543 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	6a 20                	push   $0x20
  800531:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 08                	jmp    800543 <vprintfmt+0x278>
  80053b:	89 df                	mov    %ebx,%edi
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	85 ff                	test   %edi,%edi
  800545:	7f e4                	jg     80052b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054a:	e9 a2 fd ff ff       	jmp    8002f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 fa 01             	cmp    $0x1,%edx
  800552:	7e 16                	jle    80056a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 50 04             	mov    0x4(%eax),%edx
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800565:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800568:	eb 32                	jmp    80059c <vprintfmt+0x2d1>
	else if (lflag)
  80056a:	85 d2                	test   %edx,%edx
  80056c:	74 18                	je     800586 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057c:	89 c1                	mov    %eax,%ecx
  80057e:	c1 f9 1f             	sar    $0x1f,%ecx
  800581:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800584:	eb 16                	jmp    80059c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80059f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a8:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ad:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005b1:	0f 89 b0 00 00 00    	jns    800667 <vprintfmt+0x39c>
				putch('-', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 2d                	push   $0x2d
  8005bd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005c2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005c5:	f7 d8                	neg    %eax
  8005c7:	83 d2 00             	adc    $0x0,%edx
  8005ca:	f7 da                	neg    %edx
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005da:	e9 88 00 00 00       	jmp    800667 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 70 fc ff ff       	call   800257 <getuint>
  8005e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005f2:	eb 73                	jmp    800667 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f7:	e8 5b fc ff ff       	call   800257 <getuint>
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 58                	push   $0x58
  800608:	ff d6                	call   *%esi
			putch('X', putdat);
  80060a:	83 c4 08             	add    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 58                	push   $0x58
  800610:	ff d6                	call   *%esi
			putch('X', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 58                	push   $0x58
  800618:	ff d6                	call   *%esi
			goto number;
  80061a:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80061d:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800622:	eb 43                	jmp    800667 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 30                	push   $0x30
  80062a:	ff d6                	call   *%esi
			putch('x', putdat);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 78                	push   $0x78
  800632:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	ba 00 00 00 00       	mov    $0x0,%edx
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800652:	eb 13                	jmp    800667 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800654:	8d 45 14             	lea    0x14(%ebp),%eax
  800657:	e8 fb fb ff ff       	call   800257 <getuint>
  80065c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800662:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800667:	83 ec 0c             	sub    $0xc,%esp
  80066a:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80066e:	52                   	push   %edx
  80066f:	ff 75 e0             	pushl  -0x20(%ebp)
  800672:	50                   	push   %eax
  800673:	ff 75 dc             	pushl  -0x24(%ebp)
  800676:	ff 75 d8             	pushl  -0x28(%ebp)
  800679:	89 da                	mov    %ebx,%edx
  80067b:	89 f0                	mov    %esi,%eax
  80067d:	e8 26 fb ff ff       	call   8001a8 <printnum>
			break;
  800682:	83 c4 20             	add    $0x20,%esp
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800688:	e9 64 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	51                   	push   %ecx
  800692:	ff d6                	call   *%esi
			break;
  800694:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80069a:	e9 52 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 25                	push   $0x25
  8006a5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 03                	jmp    8006af <vprintfmt+0x3e4>
  8006ac:	83 ef 01             	sub    $0x1,%edi
  8006af:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006b3:	75 f7                	jne    8006ac <vprintfmt+0x3e1>
  8006b5:	e9 37 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006bd:	5b                   	pop    %ebx
  8006be:	5e                   	pop    %esi
  8006bf:	5f                   	pop    %edi
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 18             	sub    $0x18,%esp
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 26                	je     800709 <vsnprintf+0x47>
  8006e3:	85 d2                	test   %edx,%edx
  8006e5:	7e 22                	jle    800709 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e7:	ff 75 14             	pushl  0x14(%ebp)
  8006ea:	ff 75 10             	pushl  0x10(%ebp)
  8006ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f0:	50                   	push   %eax
  8006f1:	68 91 02 80 00       	push   $0x800291
  8006f6:	e8 d0 fb ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800701:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 05                	jmp    80070e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800709:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800716:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800719:	50                   	push   %eax
  80071a:	ff 75 10             	pushl  0x10(%ebp)
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	ff 75 08             	pushl  0x8(%ebp)
  800723:	e8 9a ff ff ff       	call   8006c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800730:	b8 00 00 00 00       	mov    $0x0,%eax
  800735:	eb 03                	jmp    80073a <strlen+0x10>
		n++;
  800737:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073e:	75 f7                	jne    800737 <strlen+0xd>
		n++;
	return n;
}
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800748:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	ba 00 00 00 00       	mov    $0x0,%edx
  800750:	eb 03                	jmp    800755 <strnlen+0x13>
		n++;
  800752:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800755:	39 c2                	cmp    %eax,%edx
  800757:	74 08                	je     800761 <strnlen+0x1f>
  800759:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80075d:	75 f3                	jne    800752 <strnlen+0x10>
  80075f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076d:	89 c2                	mov    %eax,%edx
  80076f:	83 c2 01             	add    $0x1,%edx
  800772:	83 c1 01             	add    $0x1,%ecx
  800775:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800779:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077c:	84 db                	test   %bl,%bl
  80077e:	75 ef                	jne    80076f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	53                   	push   %ebx
  80078b:	e8 9a ff ff ff       	call   80072a <strlen>
  800790:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	01 d8                	add    %ebx,%eax
  800798:	50                   	push   %eax
  800799:	e8 c5 ff ff ff       	call   800763 <strcpy>
	return dst;
}
  80079e:	89 d8                	mov    %ebx,%eax
  8007a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	89 f3                	mov    %esi,%ebx
  8007b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b5:	89 f2                	mov    %esi,%edx
  8007b7:	eb 0f                	jmp    8007c8 <strncpy+0x23>
		*dst++ = *src;
  8007b9:	83 c2 01             	add    $0x1,%edx
  8007bc:	0f b6 01             	movzbl (%ecx),%eax
  8007bf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c8:	39 da                	cmp    %ebx,%edx
  8007ca:	75 ed                	jne    8007b9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007cc:	89 f0                	mov    %esi,%eax
  8007ce:	5b                   	pop    %ebx
  8007cf:	5e                   	pop    %esi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8007e0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	74 21                	je     800807 <strlcpy+0x35>
  8007e6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ea:	89 f2                	mov    %esi,%edx
  8007ec:	eb 09                	jmp    8007f7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	83 c1 01             	add    $0x1,%ecx
  8007f4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f7:	39 c2                	cmp    %eax,%edx
  8007f9:	74 09                	je     800804 <strlcpy+0x32>
  8007fb:	0f b6 19             	movzbl (%ecx),%ebx
  8007fe:	84 db                	test   %bl,%bl
  800800:	75 ec                	jne    8007ee <strlcpy+0x1c>
  800802:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800804:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800807:	29 f0                	sub    %esi,%eax
}
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800816:	eb 06                	jmp    80081e <strcmp+0x11>
		p++, q++;
  800818:	83 c1 01             	add    $0x1,%ecx
  80081b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081e:	0f b6 01             	movzbl (%ecx),%eax
  800821:	84 c0                	test   %al,%al
  800823:	74 04                	je     800829 <strcmp+0x1c>
  800825:	3a 02                	cmp    (%edx),%al
  800827:	74 ef                	je     800818 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800829:	0f b6 c0             	movzbl %al,%eax
  80082c:	0f b6 12             	movzbl (%edx),%edx
  80082f:	29 d0                	sub    %edx,%eax
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083d:	89 c3                	mov    %eax,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800842:	eb 06                	jmp    80084a <strncmp+0x17>
		n--, p++, q++;
  800844:	83 c0 01             	add    $0x1,%eax
  800847:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80084a:	39 d8                	cmp    %ebx,%eax
  80084c:	74 15                	je     800863 <strncmp+0x30>
  80084e:	0f b6 08             	movzbl (%eax),%ecx
  800851:	84 c9                	test   %cl,%cl
  800853:	74 04                	je     800859 <strncmp+0x26>
  800855:	3a 0a                	cmp    (%edx),%cl
  800857:	74 eb                	je     800844 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800859:	0f b6 00             	movzbl (%eax),%eax
  80085c:	0f b6 12             	movzbl (%edx),%edx
  80085f:	29 d0                	sub    %edx,%eax
  800861:	eb 05                	jmp    800868 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800868:	5b                   	pop    %ebx
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800875:	eb 07                	jmp    80087e <strchr+0x13>
		if (*s == c)
  800877:	38 ca                	cmp    %cl,%dl
  800879:	74 0f                	je     80088a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	0f b6 10             	movzbl (%eax),%edx
  800881:	84 d2                	test   %dl,%dl
  800883:	75 f2                	jne    800877 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800896:	eb 03                	jmp    80089b <strfind+0xf>
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089e:	38 ca                	cmp    %cl,%dl
  8008a0:	74 04                	je     8008a6 <strfind+0x1a>
  8008a2:	84 d2                	test   %dl,%dl
  8008a4:	75 f2                	jne    800898 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	57                   	push   %edi
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b4:	85 c9                	test   %ecx,%ecx
  8008b6:	74 36                	je     8008ee <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008be:	75 28                	jne    8008e8 <memset+0x40>
  8008c0:	f6 c1 03             	test   $0x3,%cl
  8008c3:	75 23                	jne    8008e8 <memset+0x40>
		c &= 0xFF;
  8008c5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c9:	89 d3                	mov    %edx,%ebx
  8008cb:	c1 e3 08             	shl    $0x8,%ebx
  8008ce:	89 d6                	mov    %edx,%esi
  8008d0:	c1 e6 18             	shl    $0x18,%esi
  8008d3:	89 d0                	mov    %edx,%eax
  8008d5:	c1 e0 10             	shl    $0x10,%eax
  8008d8:	09 f0                	or     %esi,%eax
  8008da:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008dc:	89 d8                	mov    %ebx,%eax
  8008de:	09 d0                	or     %edx,%eax
  8008e0:	c1 e9 02             	shr    $0x2,%ecx
  8008e3:	fc                   	cld    
  8008e4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e6:	eb 06                	jmp    8008ee <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008eb:	fc                   	cld    
  8008ec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ee:	89 f8                	mov    %edi,%eax
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5f                   	pop    %edi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	57                   	push   %edi
  8008f9:	56                   	push   %esi
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800903:	39 c6                	cmp    %eax,%esi
  800905:	73 35                	jae    80093c <memmove+0x47>
  800907:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090a:	39 d0                	cmp    %edx,%eax
  80090c:	73 2e                	jae    80093c <memmove+0x47>
		s += n;
		d += n;
  80090e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800911:	89 d6                	mov    %edx,%esi
  800913:	09 fe                	or     %edi,%esi
  800915:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091b:	75 13                	jne    800930 <memmove+0x3b>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 0e                	jne    800930 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800922:	83 ef 04             	sub    $0x4,%edi
  800925:	8d 72 fc             	lea    -0x4(%edx),%esi
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fd                   	std    
  80092c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092e:	eb 09                	jmp    800939 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800930:	83 ef 01             	sub    $0x1,%edi
  800933:	8d 72 ff             	lea    -0x1(%edx),%esi
  800936:	fd                   	std    
  800937:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800939:	fc                   	cld    
  80093a:	eb 1d                	jmp    800959 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093c:	89 f2                	mov    %esi,%edx
  80093e:	09 c2                	or     %eax,%edx
  800940:	f6 c2 03             	test   $0x3,%dl
  800943:	75 0f                	jne    800954 <memmove+0x5f>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 0a                	jne    800954 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80094a:	c1 e9 02             	shr    $0x2,%ecx
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	fc                   	cld    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 05                	jmp    800959 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800954:	89 c7                	mov    %eax,%edi
  800956:	fc                   	cld    
  800957:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800959:	5e                   	pop    %esi
  80095a:	5f                   	pop    %edi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800960:	ff 75 10             	pushl  0x10(%ebp)
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	ff 75 08             	pushl  0x8(%ebp)
  800969:	e8 87 ff ff ff       	call   8008f5 <memmove>
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097b:	89 c6                	mov    %eax,%esi
  80097d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800980:	eb 1a                	jmp    80099c <memcmp+0x2c>
		if (*s1 != *s2)
  800982:	0f b6 08             	movzbl (%eax),%ecx
  800985:	0f b6 1a             	movzbl (%edx),%ebx
  800988:	38 d9                	cmp    %bl,%cl
  80098a:	74 0a                	je     800996 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80098c:	0f b6 c1             	movzbl %cl,%eax
  80098f:	0f b6 db             	movzbl %bl,%ebx
  800992:	29 d8                	sub    %ebx,%eax
  800994:	eb 0f                	jmp    8009a5 <memcmp+0x35>
		s1++, s2++;
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099c:	39 f0                	cmp    %esi,%eax
  80099e:	75 e2                	jne    800982 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009b0:	89 c1                	mov    %eax,%ecx
  8009b2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b9:	eb 0a                	jmp    8009c5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bb:	0f b6 10             	movzbl (%eax),%edx
  8009be:	39 da                	cmp    %ebx,%edx
  8009c0:	74 07                	je     8009c9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	39 c8                	cmp    %ecx,%eax
  8009c7:	72 f2                	jb     8009bb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d8:	eb 03                	jmp    8009dd <strtol+0x11>
		s++;
  8009da:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	3c 20                	cmp    $0x20,%al
  8009e2:	74 f6                	je     8009da <strtol+0xe>
  8009e4:	3c 09                	cmp    $0x9,%al
  8009e6:	74 f2                	je     8009da <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e8:	3c 2b                	cmp    $0x2b,%al
  8009ea:	75 0a                	jne    8009f6 <strtol+0x2a>
		s++;
  8009ec:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f4:	eb 11                	jmp    800a07 <strtol+0x3b>
  8009f6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009fb:	3c 2d                	cmp    $0x2d,%al
  8009fd:	75 08                	jne    800a07 <strtol+0x3b>
		s++, neg = 1;
  8009ff:	83 c1 01             	add    $0x1,%ecx
  800a02:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a07:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0d:	75 15                	jne    800a24 <strtol+0x58>
  800a0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a12:	75 10                	jne    800a24 <strtol+0x58>
  800a14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a18:	75 7c                	jne    800a96 <strtol+0xca>
		s += 2, base = 16;
  800a1a:	83 c1 02             	add    $0x2,%ecx
  800a1d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a22:	eb 16                	jmp    800a3a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a24:	85 db                	test   %ebx,%ebx
  800a26:	75 12                	jne    800a3a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a28:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a30:	75 08                	jne    800a3a <strtol+0x6e>
		s++, base = 8;
  800a32:	83 c1 01             	add    $0x1,%ecx
  800a35:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a42:	0f b6 11             	movzbl (%ecx),%edx
  800a45:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	80 fb 09             	cmp    $0x9,%bl
  800a4d:	77 08                	ja     800a57 <strtol+0x8b>
			dig = *s - '0';
  800a4f:	0f be d2             	movsbl %dl,%edx
  800a52:	83 ea 30             	sub    $0x30,%edx
  800a55:	eb 22                	jmp    800a79 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a57:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a5a:	89 f3                	mov    %esi,%ebx
  800a5c:	80 fb 19             	cmp    $0x19,%bl
  800a5f:	77 08                	ja     800a69 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a61:	0f be d2             	movsbl %dl,%edx
  800a64:	83 ea 57             	sub    $0x57,%edx
  800a67:	eb 10                	jmp    800a79 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a69:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 19             	cmp    $0x19,%bl
  800a71:	77 16                	ja     800a89 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a73:	0f be d2             	movsbl %dl,%edx
  800a76:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a79:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a7c:	7d 0b                	jge    800a89 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a7e:	83 c1 01             	add    $0x1,%ecx
  800a81:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a85:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a87:	eb b9                	jmp    800a42 <strtol+0x76>

	if (endptr)
  800a89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8d:	74 0d                	je     800a9c <strtol+0xd0>
		*endptr = (char *) s;
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	89 0e                	mov    %ecx,(%esi)
  800a94:	eb 06                	jmp    800a9c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a96:	85 db                	test   %ebx,%ebx
  800a98:	74 98                	je     800a32 <strtol+0x66>
  800a9a:	eb 9e                	jmp    800a3a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a9c:	89 c2                	mov    %eax,%edx
  800a9e:	f7 da                	neg    %edx
  800aa0:	85 ff                	test   %edi,%edi
  800aa2:	0f 45 c2             	cmovne %edx,%eax
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	89 c3                	mov    %eax,%ebx
  800abd:	89 c7                	mov    %eax,%edi
  800abf:	89 c6                	mov    %eax,%esi
  800ac1:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ace:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad8:	89 d1                	mov    %edx,%ecx
  800ada:	89 d3                	mov    %edx,%ebx
  800adc:	89 d7                	mov    %edx,%edi
  800ade:	89 d6                	mov    %edx,%esi
  800ae0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800af0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af5:	b8 03 00 00 00       	mov    $0x3,%eax
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	89 cb                	mov    %ecx,%ebx
  800aff:	89 cf                	mov    %ecx,%edi
  800b01:	89 ce                	mov    %ecx,%esi
  800b03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b05:	85 c0                	test   %eax,%eax
  800b07:	7e 17                	jle    800b20 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	50                   	push   %eax
  800b0d:	6a 03                	push   $0x3
  800b0f:	68 7f 21 80 00       	push   $0x80217f
  800b14:	6a 23                	push   $0x23
  800b16:	68 9c 21 80 00       	push   $0x80219c
  800b1b:	e8 f3 0f 00 00       	call   801b13 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b33:	b8 02 00 00 00       	mov    $0x2,%eax
  800b38:	89 d1                	mov    %edx,%ecx
  800b3a:	89 d3                	mov    %edx,%ebx
  800b3c:	89 d7                	mov    %edx,%edi
  800b3e:	89 d6                	mov    %edx,%esi
  800b40:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_yield>:

void
sys_yield(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b6f:	be 00 00 00 00       	mov    $0x0,%esi
  800b74:	b8 04 00 00 00       	mov    $0x4,%eax
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b82:	89 f7                	mov    %esi,%edi
  800b84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b86:	85 c0                	test   %eax,%eax
  800b88:	7e 17                	jle    800ba1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 04                	push   $0x4
  800b90:	68 7f 21 80 00       	push   $0x80217f
  800b95:	6a 23                	push   $0x23
  800b97:	68 9c 21 80 00       	push   $0x80219c
  800b9c:	e8 72 0f 00 00       	call   801b13 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 17                	jle    800be3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 05                	push   $0x5
  800bd2:	68 7f 21 80 00       	push   $0x80217f
  800bd7:	6a 23                	push   $0x23
  800bd9:	68 9c 21 80 00       	push   $0x80219c
  800bde:	e8 30 0f 00 00       	call   801b13 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	89 df                	mov    %ebx,%edi
  800c06:	89 de                	mov    %ebx,%esi
  800c08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	7e 17                	jle    800c25 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	50                   	push   %eax
  800c12:	6a 06                	push   $0x6
  800c14:	68 7f 21 80 00       	push   $0x80217f
  800c19:	6a 23                	push   $0x23
  800c1b:	68 9c 21 80 00       	push   $0x80219c
  800c20:	e8 ee 0e 00 00       	call   801b13 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	89 df                	mov    %ebx,%edi
  800c48:	89 de                	mov    %ebx,%esi
  800c4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 17                	jle    800c67 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 08                	push   $0x8
  800c56:	68 7f 21 80 00       	push   $0x80217f
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 9c 21 80 00       	push   $0x80219c
  800c62:	e8 ac 0e 00 00       	call   801b13 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 df                	mov    %ebx,%edi
  800c8a:	89 de                	mov    %ebx,%esi
  800c8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 17                	jle    800ca9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	6a 09                	push   $0x9
  800c98:	68 7f 21 80 00       	push   $0x80217f
  800c9d:	6a 23                	push   $0x23
  800c9f:	68 9c 21 80 00       	push   $0x80219c
  800ca4:	e8 6a 0e 00 00       	call   801b13 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	89 de                	mov    %ebx,%esi
  800cce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7e 17                	jle    800ceb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd4:	83 ec 0c             	sub    $0xc,%esp
  800cd7:	50                   	push   %eax
  800cd8:	6a 0a                	push   $0xa
  800cda:	68 7f 21 80 00       	push   $0x80217f
  800cdf:	6a 23                	push   $0x23
  800ce1:	68 9c 21 80 00       	push   $0x80219c
  800ce6:	e8 28 0e 00 00       	call   801b13 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cf9:	be 00 00 00 00       	mov    $0x0,%esi
  800cfe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d24:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 cb                	mov    %ecx,%ebx
  800d2e:	89 cf                	mov    %ecx,%edi
  800d30:	89 ce                	mov    %ecx,%esi
  800d32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 17                	jle    800d4f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 0d                	push   $0xd
  800d3e:	68 7f 21 80 00       	push   $0x80217f
  800d43:	6a 23                	push   $0x23
  800d45:	68 9c 21 80 00       	push   $0x80219c
  800d4a:	e8 c4 0d 00 00       	call   801b13 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d5f:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	e8 a9 ff ff ff       	call   800d16 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	85 f6                	test   %esi,%esi
  800d72:	74 1c                	je     800d90 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  800d74:	a1 04 40 80 00       	mov    0x804004,%eax
  800d79:	8b 40 78             	mov    0x78(%eax),%eax
  800d7c:	89 06                	mov    %eax,(%esi)
  800d7e:	eb 10                	jmp    800d90 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	68 aa 21 80 00       	push   $0x8021aa
  800d88:	e8 07 f4 ff ff       	call   800194 <cprintf>
  800d8d:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  800d90:	a1 04 40 80 00       	mov    0x804004,%eax
  800d95:	8b 50 74             	mov    0x74(%eax),%edx
  800d98:	85 d2                	test   %edx,%edx
  800d9a:	74 e4                	je     800d80 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  800d9c:	85 db                	test   %ebx,%ebx
  800d9e:	74 05                	je     800da5 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  800da0:	8b 40 74             	mov    0x74(%eax),%eax
  800da3:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  800da5:	a1 04 40 80 00       	mov    0x804004,%eax
  800daa:	8b 40 70             	mov    0x70(%eax),%eax

}
  800dad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  800dc6:	85 db                	test   %ebx,%ebx
  800dc8:	75 13                	jne    800ddd <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  800dca:	6a 00                	push   $0x0
  800dcc:	68 00 00 c0 ee       	push   $0xeec00000
  800dd1:	56                   	push   %esi
  800dd2:	57                   	push   %edi
  800dd3:	e8 1b ff ff ff       	call   800cf3 <sys_ipc_try_send>
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	eb 0e                	jmp    800deb <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  800ddd:	ff 75 14             	pushl  0x14(%ebp)
  800de0:	53                   	push   %ebx
  800de1:	56                   	push   %esi
  800de2:	57                   	push   %edi
  800de3:	e8 0b ff ff ff       	call   800cf3 <sys_ipc_try_send>
  800de8:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  800deb:	85 c0                	test   %eax,%eax
  800ded:	75 d7                	jne    800dc6 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  800def:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dfd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e02:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e05:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e0b:	8b 52 50             	mov    0x50(%edx),%edx
  800e0e:	39 ca                	cmp    %ecx,%edx
  800e10:	75 0d                	jne    800e1f <ipc_find_env+0x28>
			return envs[i].env_id;
  800e12:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e15:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e1a:	8b 40 48             	mov    0x48(%eax),%eax
  800e1d:	eb 0f                	jmp    800e2e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e1f:	83 c0 01             	add    $0x1,%eax
  800e22:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e27:	75 d9                	jne    800e02 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e50:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	c1 ea 16             	shr    $0x16,%edx
  800e67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	74 11                	je     800e84 <fd_alloc+0x2d>
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	c1 ea 0c             	shr    $0xc,%edx
  800e78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7f:	f6 c2 01             	test   $0x1,%dl
  800e82:	75 09                	jne    800e8d <fd_alloc+0x36>
			*fd_store = fd;
  800e84:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 17                	jmp    800ea4 <fd_alloc+0x4d>
  800e8d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e92:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e97:	75 c9                	jne    800e62 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e99:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e9f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eac:	83 f8 1f             	cmp    $0x1f,%eax
  800eaf:	77 36                	ja     800ee7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb1:	c1 e0 0c             	shl    $0xc,%eax
  800eb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb9:	89 c2                	mov    %eax,%edx
  800ebb:	c1 ea 16             	shr    $0x16,%edx
  800ebe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec5:	f6 c2 01             	test   $0x1,%dl
  800ec8:	74 24                	je     800eee <fd_lookup+0x48>
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	c1 ea 0c             	shr    $0xc,%edx
  800ecf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed6:	f6 c2 01             	test   $0x1,%dl
  800ed9:	74 1a                	je     800ef5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800edb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ede:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	eb 13                	jmp    800efa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eec:	eb 0c                	jmp    800efa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef3:	eb 05                	jmp    800efa <fd_lookup+0x54>
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f05:	ba 38 22 80 00       	mov    $0x802238,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0a:	eb 13                	jmp    800f1f <dev_lookup+0x23>
  800f0c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f0f:	39 08                	cmp    %ecx,(%eax)
  800f11:	75 0c                	jne    800f1f <dev_lookup+0x23>
			*dev = devtab[i];
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1d:	eb 2e                	jmp    800f4d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1f:	8b 02                	mov    (%edx),%eax
  800f21:	85 c0                	test   %eax,%eax
  800f23:	75 e7                	jne    800f0c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f25:	a1 04 40 80 00       	mov    0x804004,%eax
  800f2a:	8b 40 48             	mov    0x48(%eax),%eax
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	51                   	push   %ecx
  800f31:	50                   	push   %eax
  800f32:	68 bc 21 80 00       	push   $0x8021bc
  800f37:	e8 58 f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 10             	sub    $0x10,%esp
  800f57:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f67:	c1 e8 0c             	shr    $0xc,%eax
  800f6a:	50                   	push   %eax
  800f6b:	e8 36 ff ff ff       	call   800ea6 <fd_lookup>
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 05                	js     800f7c <fd_close+0x2d>
	    || fd != fd2)
  800f77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7a:	74 0c                	je     800f88 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7c:	84 db                	test   %bl,%bl
  800f7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f83:	0f 44 c2             	cmove  %edx,%eax
  800f86:	eb 41                	jmp    800fc9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 36                	pushl  (%esi)
  800f91:	e8 66 ff ff ff       	call   800efc <dev_lookup>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 1a                	js     800fb9 <fd_close+0x6a>
		if (dev->dev_close)
  800f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	74 0b                	je     800fb9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	56                   	push   %esi
  800fb2:	ff d0                	call   *%eax
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	56                   	push   %esi
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 27 fc ff ff       	call   800beb <sys_page_unmap>
	return r;
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	89 d8                	mov    %ebx,%eax
}
  800fc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd9:	50                   	push   %eax
  800fda:	ff 75 08             	pushl  0x8(%ebp)
  800fdd:	e8 c4 fe ff ff       	call   800ea6 <fd_lookup>
  800fe2:	83 c4 08             	add    $0x8,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 10                	js     800ff9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	6a 01                	push   $0x1
  800fee:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff1:	e8 59 ff ff ff       	call   800f4f <fd_close>
  800ff6:	83 c4 10             	add    $0x10,%esp
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <close_all>:

void
close_all(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	53                   	push   %ebx
  80100b:	e8 c0 ff ff ff       	call   800fd0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801010:	83 c3 01             	add    $0x1,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	83 fb 20             	cmp    $0x20,%ebx
  801019:	75 ec                	jne    801007 <close_all+0xc>
		close(i);
}
  80101b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
  801026:	83 ec 2c             	sub    $0x2c,%esp
  801029:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102f:	50                   	push   %eax
  801030:	ff 75 08             	pushl  0x8(%ebp)
  801033:	e8 6e fe ff ff       	call   800ea6 <fd_lookup>
  801038:	83 c4 08             	add    $0x8,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	0f 88 c1 00 00 00    	js     801104 <dup+0xe4>
		return r;
	close(newfdnum);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	56                   	push   %esi
  801047:	e8 84 ff ff ff       	call   800fd0 <close>

	newfd = INDEX2FD(newfdnum);
  80104c:	89 f3                	mov    %esi,%ebx
  80104e:	c1 e3 0c             	shl    $0xc,%ebx
  801051:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801057:	83 c4 04             	add    $0x4,%esp
  80105a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105d:	e8 de fd ff ff       	call   800e40 <fd2data>
  801062:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801064:	89 1c 24             	mov    %ebx,(%esp)
  801067:	e8 d4 fd ff ff       	call   800e40 <fd2data>
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801072:	89 f8                	mov    %edi,%eax
  801074:	c1 e8 16             	shr    $0x16,%eax
  801077:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107e:	a8 01                	test   $0x1,%al
  801080:	74 37                	je     8010b9 <dup+0x99>
  801082:	89 f8                	mov    %edi,%eax
  801084:	c1 e8 0c             	shr    $0xc,%eax
  801087:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	74 26                	je     8010b9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801093:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a2:	50                   	push   %eax
  8010a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a6:	6a 00                	push   $0x0
  8010a8:	57                   	push   %edi
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 f9 fa ff ff       	call   800ba9 <sys_page_map>
  8010b0:	89 c7                	mov    %eax,%edi
  8010b2:	83 c4 20             	add    $0x20,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 2e                	js     8010e7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bc:	89 d0                	mov    %edx,%eax
  8010be:	c1 e8 0c             	shr    $0xc,%eax
  8010c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d0:	50                   	push   %eax
  8010d1:	53                   	push   %ebx
  8010d2:	6a 00                	push   $0x0
  8010d4:	52                   	push   %edx
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 cd fa ff ff       	call   800ba9 <sys_page_map>
  8010dc:	89 c7                	mov    %eax,%edi
  8010de:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e3:	85 ff                	test   %edi,%edi
  8010e5:	79 1d                	jns    801104 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	53                   	push   %ebx
  8010eb:	6a 00                	push   $0x0
  8010ed:	e8 f9 fa ff ff       	call   800beb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f2:	83 c4 08             	add    $0x8,%esp
  8010f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 ec fa ff ff       	call   800beb <sys_page_unmap>
	return r;
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	89 f8                	mov    %edi,%eax
}
  801104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	53                   	push   %ebx
  801110:	83 ec 14             	sub    $0x14,%esp
  801113:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801116:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	53                   	push   %ebx
  80111b:	e8 86 fd ff ff       	call   800ea6 <fd_lookup>
  801120:	83 c4 08             	add    $0x8,%esp
  801123:	89 c2                	mov    %eax,%edx
  801125:	85 c0                	test   %eax,%eax
  801127:	78 6d                	js     801196 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112f:	50                   	push   %eax
  801130:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801133:	ff 30                	pushl  (%eax)
  801135:	e8 c2 fd ff ff       	call   800efc <dev_lookup>
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	78 4c                	js     80118d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801141:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801144:	8b 42 08             	mov    0x8(%edx),%eax
  801147:	83 e0 03             	and    $0x3,%eax
  80114a:	83 f8 01             	cmp    $0x1,%eax
  80114d:	75 21                	jne    801170 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114f:	a1 04 40 80 00       	mov    0x804004,%eax
  801154:	8b 40 48             	mov    0x48(%eax),%eax
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	53                   	push   %ebx
  80115b:	50                   	push   %eax
  80115c:	68 fd 21 80 00       	push   $0x8021fd
  801161:	e8 2e f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116e:	eb 26                	jmp    801196 <read+0x8a>
	}
	if (!dev->dev_read)
  801170:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801173:	8b 40 08             	mov    0x8(%eax),%eax
  801176:	85 c0                	test   %eax,%eax
  801178:	74 17                	je     801191 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	ff 75 10             	pushl  0x10(%ebp)
  801180:	ff 75 0c             	pushl  0xc(%ebp)
  801183:	52                   	push   %edx
  801184:	ff d0                	call   *%eax
  801186:	89 c2                	mov    %eax,%edx
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	eb 09                	jmp    801196 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	eb 05                	jmp    801196 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801191:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801196:	89 d0                	mov    %edx,%eax
  801198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    

0080119d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	eb 21                	jmp    8011d4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	89 f0                	mov    %esi,%eax
  8011b8:	29 d8                	sub    %ebx,%eax
  8011ba:	50                   	push   %eax
  8011bb:	89 d8                	mov    %ebx,%eax
  8011bd:	03 45 0c             	add    0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	57                   	push   %edi
  8011c2:	e8 45 ff ff ff       	call   80110c <read>
		if (m < 0)
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 10                	js     8011de <readn+0x41>
			return m;
		if (m == 0)
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	74 0a                	je     8011dc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d2:	01 c3                	add    %eax,%ebx
  8011d4:	39 f3                	cmp    %esi,%ebx
  8011d6:	72 db                	jb     8011b3 <readn+0x16>
  8011d8:	89 d8                	mov    %ebx,%eax
  8011da:	eb 02                	jmp    8011de <readn+0x41>
  8011dc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 14             	sub    $0x14,%esp
  8011ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	53                   	push   %ebx
  8011f5:	e8 ac fc ff ff       	call   800ea6 <fd_lookup>
  8011fa:	83 c4 08             	add    $0x8,%esp
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 68                	js     80126b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801209:	50                   	push   %eax
  80120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120d:	ff 30                	pushl  (%eax)
  80120f:	e8 e8 fc ff ff       	call   800efc <dev_lookup>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	78 47                	js     801262 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801222:	75 21                	jne    801245 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801224:	a1 04 40 80 00       	mov    0x804004,%eax
  801229:	8b 40 48             	mov    0x48(%eax),%eax
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	53                   	push   %ebx
  801230:	50                   	push   %eax
  801231:	68 19 22 80 00       	push   $0x802219
  801236:	e8 59 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801243:	eb 26                	jmp    80126b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801245:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801248:	8b 52 0c             	mov    0xc(%edx),%edx
  80124b:	85 d2                	test   %edx,%edx
  80124d:	74 17                	je     801266 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	ff 75 10             	pushl  0x10(%ebp)
  801255:	ff 75 0c             	pushl  0xc(%ebp)
  801258:	50                   	push   %eax
  801259:	ff d2                	call   *%edx
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	eb 09                	jmp    80126b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801262:	89 c2                	mov    %eax,%edx
  801264:	eb 05                	jmp    80126b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801266:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126b:	89 d0                	mov    %edx,%eax
  80126d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <seek>:

int
seek(int fdnum, off_t offset)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801278:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 22 fc ff ff       	call   800ea6 <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 0e                	js     801299 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801291:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	53                   	push   %ebx
  80129f:	83 ec 14             	sub    $0x14,%esp
  8012a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	53                   	push   %ebx
  8012aa:	e8 f7 fb ff ff       	call   800ea6 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 65                	js     80131d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	ff 30                	pushl  (%eax)
  8012c4:	e8 33 fc ff ff       	call   800efc <dev_lookup>
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 44                	js     801314 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d7:	75 21                	jne    8012fa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012de:	8b 40 48             	mov    0x48(%eax),%eax
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	53                   	push   %ebx
  8012e5:	50                   	push   %eax
  8012e6:	68 dc 21 80 00       	push   $0x8021dc
  8012eb:	e8 a4 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f8:	eb 23                	jmp    80131d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fd:	8b 52 18             	mov    0x18(%edx),%edx
  801300:	85 d2                	test   %edx,%edx
  801302:	74 14                	je     801318 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	ff 75 0c             	pushl  0xc(%ebp)
  80130a:	50                   	push   %eax
  80130b:	ff d2                	call   *%edx
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	eb 09                	jmp    80131d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801314:	89 c2                	mov    %eax,%edx
  801316:	eb 05                	jmp    80131d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801318:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131d:	89 d0                	mov    %edx,%eax
  80131f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	53                   	push   %ebx
  801328:	83 ec 14             	sub    $0x14,%esp
  80132b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 75 08             	pushl  0x8(%ebp)
  801335:	e8 6c fb ff ff       	call   800ea6 <fd_lookup>
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 58                	js     80139b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	ff 30                	pushl  (%eax)
  80134f:	e8 a8 fb ff ff       	call   800efc <dev_lookup>
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 37                	js     801392 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801362:	74 32                	je     801396 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801364:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801367:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136e:	00 00 00 
	stat->st_isdir = 0;
  801371:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801378:	00 00 00 
	stat->st_dev = dev;
  80137b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	53                   	push   %ebx
  801385:	ff 75 f0             	pushl  -0x10(%ebp)
  801388:	ff 50 14             	call   *0x14(%eax)
  80138b:	89 c2                	mov    %eax,%edx
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	eb 09                	jmp    80139b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801392:	89 c2                	mov    %eax,%edx
  801394:	eb 05                	jmp    80139b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801396:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139b:	89 d0                	mov    %edx,%eax
  80139d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	6a 00                	push   $0x0
  8013ac:	ff 75 08             	pushl  0x8(%ebp)
  8013af:	e8 dc 01 00 00       	call   801590 <open>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 1b                	js     8013d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	ff 75 0c             	pushl  0xc(%ebp)
  8013c3:	50                   	push   %eax
  8013c4:	e8 5b ff ff ff       	call   801324 <fstat>
  8013c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8013cb:	89 1c 24             	mov    %ebx,(%esp)
  8013ce:	e8 fd fb ff ff       	call   800fd0 <close>
	return r;
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	89 f0                	mov    %esi,%eax
}
  8013d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	89 c6                	mov    %eax,%esi
  8013e6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ef:	75 12                	jne    801403 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	6a 01                	push   $0x1
  8013f6:	e8 fc f9 ff ff       	call   800df7 <ipc_find_env>
  8013fb:	a3 00 40 80 00       	mov    %eax,0x804000
  801400:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801403:	6a 07                	push   $0x7
  801405:	68 00 50 80 00       	push   $0x805000
  80140a:	56                   	push   %esi
  80140b:	ff 35 00 40 80 00    	pushl  0x804000
  801411:	e8 9e f9 ff ff       	call   800db4 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801416:	83 c4 0c             	add    $0xc,%esp
  801419:	6a 00                	push   $0x0
  80141b:	53                   	push   %ebx
  80141c:	6a 00                	push   $0x0
  80141e:	e8 34 f9 ff ff       	call   800d57 <ipc_recv>
}
  801423:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801426:	5b                   	pop    %ebx
  801427:	5e                   	pop    %esi
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	8b 40 0c             	mov    0xc(%eax),%eax
  801436:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801443:	ba 00 00 00 00       	mov    $0x0,%edx
  801448:	b8 02 00 00 00       	mov    $0x2,%eax
  80144d:	e8 8d ff ff ff       	call   8013df <fsipc>
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801465:	ba 00 00 00 00       	mov    $0x0,%edx
  80146a:	b8 06 00 00 00       	mov    $0x6,%eax
  80146f:	e8 6b ff ff ff       	call   8013df <fsipc>
}
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	8b 40 0c             	mov    0xc(%eax),%eax
  801486:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148b:	ba 00 00 00 00       	mov    $0x0,%edx
  801490:	b8 05 00 00 00       	mov    $0x5,%eax
  801495:	e8 45 ff ff ff       	call   8013df <fsipc>
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 2c                	js     8014ca <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	68 00 50 80 00       	push   $0x805000
  8014a6:	53                   	push   %ebx
  8014a7:	e8 b7 f2 ff ff       	call   800763 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8014bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014db:	8b 52 0c             	mov    0xc(%edx),%edx
  8014de:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014e4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014e9:	50                   	push   %eax
  8014ea:	ff 75 0c             	pushl  0xc(%ebp)
  8014ed:	68 08 50 80 00       	push   $0x805008
  8014f2:	e8 fe f3 ff ff       	call   8008f5 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801501:	e8 d9 fe ff ff       	call   8013df <fsipc>
	//panic("devfile_write not implemented");
}
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801510:	8b 45 08             	mov    0x8(%ebp),%eax
  801513:	8b 40 0c             	mov    0xc(%eax),%eax
  801516:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801521:	ba 00 00 00 00       	mov    $0x0,%edx
  801526:	b8 03 00 00 00       	mov    $0x3,%eax
  80152b:	e8 af fe ff ff       	call   8013df <fsipc>
  801530:	89 c3                	mov    %eax,%ebx
  801532:	85 c0                	test   %eax,%eax
  801534:	78 51                	js     801587 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801536:	39 c6                	cmp    %eax,%esi
  801538:	73 19                	jae    801553 <devfile_read+0x4b>
  80153a:	68 48 22 80 00       	push   $0x802248
  80153f:	68 4f 22 80 00       	push   $0x80224f
  801544:	68 80 00 00 00       	push   $0x80
  801549:	68 64 22 80 00       	push   $0x802264
  80154e:	e8 c0 05 00 00       	call   801b13 <_panic>
	assert(r <= PGSIZE);
  801553:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801558:	7e 19                	jle    801573 <devfile_read+0x6b>
  80155a:	68 6f 22 80 00       	push   $0x80226f
  80155f:	68 4f 22 80 00       	push   $0x80224f
  801564:	68 81 00 00 00       	push   $0x81
  801569:	68 64 22 80 00       	push   $0x802264
  80156e:	e8 a0 05 00 00       	call   801b13 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	50                   	push   %eax
  801577:	68 00 50 80 00       	push   $0x805000
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	e8 71 f3 ff ff       	call   8008f5 <memmove>
	return r;
  801584:	83 c4 10             	add    $0x10,%esp
}
  801587:	89 d8                	mov    %ebx,%eax
  801589:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158c:	5b                   	pop    %ebx
  80158d:	5e                   	pop    %esi
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 20             	sub    $0x20,%esp
  801597:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80159a:	53                   	push   %ebx
  80159b:	e8 8a f1 ff ff       	call   80072a <strlen>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a8:	7f 67                	jg     801611 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	e8 a1 f8 ff ff       	call   800e57 <fd_alloc>
  8015b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 57                	js     801616 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	68 00 50 80 00       	push   $0x805000
  8015c8:	e8 96 f1 ff ff       	call   800763 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d0:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015dd:	e8 fd fd ff ff       	call   8013df <fsipc>
  8015e2:	89 c3                	mov    %eax,%ebx
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	79 14                	jns    8015ff <open+0x6f>
		
		fd_close(fd, 0);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	6a 00                	push   $0x0
  8015f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f3:	e8 57 f9 ff ff       	call   800f4f <fd_close>
		return r;
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	89 da                	mov    %ebx,%edx
  8015fd:	eb 17                	jmp    801616 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	ff 75 f4             	pushl  -0xc(%ebp)
  801605:	e8 26 f8 ff ff       	call   800e30 <fd2num>
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	eb 05                	jmp    801616 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801611:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801616:	89 d0                	mov    %edx,%eax
  801618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801623:	ba 00 00 00 00       	mov    $0x0,%edx
  801628:	b8 08 00 00 00       	mov    $0x8,%eax
  80162d:	e8 ad fd ff ff       	call   8013df <fsipc>
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	56                   	push   %esi
  801638:	53                   	push   %ebx
  801639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	ff 75 08             	pushl  0x8(%ebp)
  801642:	e8 f9 f7 ff ff       	call   800e40 <fd2data>
  801647:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801649:	83 c4 08             	add    $0x8,%esp
  80164c:	68 7b 22 80 00       	push   $0x80227b
  801651:	53                   	push   %ebx
  801652:	e8 0c f1 ff ff       	call   800763 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801657:	8b 46 04             	mov    0x4(%esi),%eax
  80165a:	2b 06                	sub    (%esi),%eax
  80165c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801662:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801669:	00 00 00 
	stat->st_dev = &devpipe;
  80166c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801673:	30 80 00 
	return 0;
}
  801676:	b8 00 00 00 00       	mov    $0x0,%eax
  80167b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80168c:	53                   	push   %ebx
  80168d:	6a 00                	push   $0x0
  80168f:	e8 57 f5 ff ff       	call   800beb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801694:	89 1c 24             	mov    %ebx,(%esp)
  801697:	e8 a4 f7 ff ff       	call   800e40 <fd2data>
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	50                   	push   %eax
  8016a0:	6a 00                	push   $0x0
  8016a2:	e8 44 f5 ff ff       	call   800beb <sys_page_unmap>
}
  8016a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	57                   	push   %edi
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 1c             	sub    $0x1c,%esp
  8016b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016b8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8016bf:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016c2:	83 ec 0c             	sub    $0xc,%esp
  8016c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8016c8:	e8 8c 04 00 00       	call   801b59 <pageref>
  8016cd:	89 c3                	mov    %eax,%ebx
  8016cf:	89 3c 24             	mov    %edi,(%esp)
  8016d2:	e8 82 04 00 00       	call   801b59 <pageref>
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	39 c3                	cmp    %eax,%ebx
  8016dc:	0f 94 c1             	sete   %cl
  8016df:	0f b6 c9             	movzbl %cl,%ecx
  8016e2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016e5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016eb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ee:	39 ce                	cmp    %ecx,%esi
  8016f0:	74 1b                	je     80170d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016f2:	39 c3                	cmp    %eax,%ebx
  8016f4:	75 c4                	jne    8016ba <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016f6:	8b 42 58             	mov    0x58(%edx),%eax
  8016f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fc:	50                   	push   %eax
  8016fd:	56                   	push   %esi
  8016fe:	68 82 22 80 00       	push   $0x802282
  801703:	e8 8c ea ff ff       	call   800194 <cprintf>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb ad                	jmp    8016ba <_pipeisclosed+0xe>
	}
}
  80170d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5f                   	pop    %edi
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	57                   	push   %edi
  80171c:	56                   	push   %esi
  80171d:	53                   	push   %ebx
  80171e:	83 ec 28             	sub    $0x28,%esp
  801721:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801724:	56                   	push   %esi
  801725:	e8 16 f7 ff ff       	call   800e40 <fd2data>
  80172a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	bf 00 00 00 00       	mov    $0x0,%edi
  801734:	eb 4b                	jmp    801781 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801736:	89 da                	mov    %ebx,%edx
  801738:	89 f0                	mov    %esi,%eax
  80173a:	e8 6d ff ff ff       	call   8016ac <_pipeisclosed>
  80173f:	85 c0                	test   %eax,%eax
  801741:	75 48                	jne    80178b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801743:	e8 ff f3 ff ff       	call   800b47 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801748:	8b 43 04             	mov    0x4(%ebx),%eax
  80174b:	8b 0b                	mov    (%ebx),%ecx
  80174d:	8d 51 20             	lea    0x20(%ecx),%edx
  801750:	39 d0                	cmp    %edx,%eax
  801752:	73 e2                	jae    801736 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801754:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801757:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80175b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80175e:	89 c2                	mov    %eax,%edx
  801760:	c1 fa 1f             	sar    $0x1f,%edx
  801763:	89 d1                	mov    %edx,%ecx
  801765:	c1 e9 1b             	shr    $0x1b,%ecx
  801768:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80176b:	83 e2 1f             	and    $0x1f,%edx
  80176e:	29 ca                	sub    %ecx,%edx
  801770:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801774:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801778:	83 c0 01             	add    $0x1,%eax
  80177b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177e:	83 c7 01             	add    $0x1,%edi
  801781:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801784:	75 c2                	jne    801748 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801786:	8b 45 10             	mov    0x10(%ebp),%eax
  801789:	eb 05                	jmp    801790 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80178b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801790:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5f                   	pop    %edi
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	57                   	push   %edi
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	83 ec 18             	sub    $0x18,%esp
  8017a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017a4:	57                   	push   %edi
  8017a5:	e8 96 f6 ff ff       	call   800e40 <fd2data>
  8017aa:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b4:	eb 3d                	jmp    8017f3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017b6:	85 db                	test   %ebx,%ebx
  8017b8:	74 04                	je     8017be <devpipe_read+0x26>
				return i;
  8017ba:	89 d8                	mov    %ebx,%eax
  8017bc:	eb 44                	jmp    801802 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017be:	89 f2                	mov    %esi,%edx
  8017c0:	89 f8                	mov    %edi,%eax
  8017c2:	e8 e5 fe ff ff       	call   8016ac <_pipeisclosed>
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	75 32                	jne    8017fd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017cb:	e8 77 f3 ff ff       	call   800b47 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017d0:	8b 06                	mov    (%esi),%eax
  8017d2:	3b 46 04             	cmp    0x4(%esi),%eax
  8017d5:	74 df                	je     8017b6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017d7:	99                   	cltd   
  8017d8:	c1 ea 1b             	shr    $0x1b,%edx
  8017db:	01 d0                	add    %edx,%eax
  8017dd:	83 e0 1f             	and    $0x1f,%eax
  8017e0:	29 d0                	sub    %edx,%eax
  8017e2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ea:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017ed:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f0:	83 c3 01             	add    $0x1,%ebx
  8017f3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017f6:	75 d8                	jne    8017d0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fb:	eb 05                	jmp    801802 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017fd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801802:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5f                   	pop    %edi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
  80180f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	e8 3c f6 ff ff       	call   800e57 <fd_alloc>
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	89 c2                	mov    %eax,%edx
  801820:	85 c0                	test   %eax,%eax
  801822:	0f 88 2c 01 00 00    	js     801954 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801828:	83 ec 04             	sub    $0x4,%esp
  80182b:	68 07 04 00 00       	push   $0x407
  801830:	ff 75 f4             	pushl  -0xc(%ebp)
  801833:	6a 00                	push   $0x0
  801835:	e8 2c f3 ff ff       	call   800b66 <sys_page_alloc>
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	85 c0                	test   %eax,%eax
  801841:	0f 88 0d 01 00 00    	js     801954 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184d:	50                   	push   %eax
  80184e:	e8 04 f6 ff ff       	call   800e57 <fd_alloc>
  801853:	89 c3                	mov    %eax,%ebx
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	0f 88 e2 00 00 00    	js     801942 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801860:	83 ec 04             	sub    $0x4,%esp
  801863:	68 07 04 00 00       	push   $0x407
  801868:	ff 75 f0             	pushl  -0x10(%ebp)
  80186b:	6a 00                	push   $0x0
  80186d:	e8 f4 f2 ff ff       	call   800b66 <sys_page_alloc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	0f 88 c3 00 00 00    	js     801942 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80187f:	83 ec 0c             	sub    $0xc,%esp
  801882:	ff 75 f4             	pushl  -0xc(%ebp)
  801885:	e8 b6 f5 ff ff       	call   800e40 <fd2data>
  80188a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188c:	83 c4 0c             	add    $0xc,%esp
  80188f:	68 07 04 00 00       	push   $0x407
  801894:	50                   	push   %eax
  801895:	6a 00                	push   $0x0
  801897:	e8 ca f2 ff ff       	call   800b66 <sys_page_alloc>
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	0f 88 89 00 00 00    	js     801932 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8018af:	e8 8c f5 ff ff       	call   800e40 <fd2data>
  8018b4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018bb:	50                   	push   %eax
  8018bc:	6a 00                	push   $0x0
  8018be:	56                   	push   %esi
  8018bf:	6a 00                	push   $0x0
  8018c1:	e8 e3 f2 ff ff       	call   800ba9 <sys_page_map>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	83 c4 20             	add    $0x20,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 55                	js     801924 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018cf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018dd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018e4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ed:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018f9:	83 ec 0c             	sub    $0xc,%esp
  8018fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ff:	e8 2c f5 ff ff       	call   800e30 <fd2num>
  801904:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801907:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801909:	83 c4 04             	add    $0x4,%esp
  80190c:	ff 75 f0             	pushl  -0x10(%ebp)
  80190f:	e8 1c f5 ff ff       	call   800e30 <fd2num>
  801914:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801917:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	ba 00 00 00 00       	mov    $0x0,%edx
  801922:	eb 30                	jmp    801954 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	56                   	push   %esi
  801928:	6a 00                	push   $0x0
  80192a:	e8 bc f2 ff ff       	call   800beb <sys_page_unmap>
  80192f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	ff 75 f0             	pushl  -0x10(%ebp)
  801938:	6a 00                	push   $0x0
  80193a:	e8 ac f2 ff ff       	call   800beb <sys_page_unmap>
  80193f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	ff 75 f4             	pushl  -0xc(%ebp)
  801948:	6a 00                	push   $0x0
  80194a:	e8 9c f2 ff ff       	call   800beb <sys_page_unmap>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801954:	89 d0                	mov    %edx,%eax
  801956:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801959:	5b                   	pop    %ebx
  80195a:	5e                   	pop    %esi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801966:	50                   	push   %eax
  801967:	ff 75 08             	pushl  0x8(%ebp)
  80196a:	e8 37 f5 ff ff       	call   800ea6 <fd_lookup>
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	85 c0                	test   %eax,%eax
  801974:	78 18                	js     80198e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801976:	83 ec 0c             	sub    $0xc,%esp
  801979:	ff 75 f4             	pushl  -0xc(%ebp)
  80197c:	e8 bf f4 ff ff       	call   800e40 <fd2data>
	return _pipeisclosed(fd, p);
  801981:	89 c2                	mov    %eax,%edx
  801983:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801986:	e8 21 fd ff ff       	call   8016ac <_pipeisclosed>
  80198b:	83 c4 10             	add    $0x10,%esp
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801993:	b8 00 00 00 00       	mov    $0x0,%eax
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019a0:	68 9a 22 80 00       	push   $0x80229a
  8019a5:	ff 75 0c             	pushl  0xc(%ebp)
  8019a8:	e8 b6 ed ff ff       	call   800763 <strcpy>
	return 0;
}
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	57                   	push   %edi
  8019b8:	56                   	push   %esi
  8019b9:	53                   	push   %ebx
  8019ba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019cb:	eb 2d                	jmp    8019fa <devcons_write+0x46>
		m = n - tot;
  8019cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019d0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019d2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019d5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019da:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019dd:	83 ec 04             	sub    $0x4,%esp
  8019e0:	53                   	push   %ebx
  8019e1:	03 45 0c             	add    0xc(%ebp),%eax
  8019e4:	50                   	push   %eax
  8019e5:	57                   	push   %edi
  8019e6:	e8 0a ef ff ff       	call   8008f5 <memmove>
		sys_cputs(buf, m);
  8019eb:	83 c4 08             	add    $0x8,%esp
  8019ee:	53                   	push   %ebx
  8019ef:	57                   	push   %edi
  8019f0:	e8 b5 f0 ff ff       	call   800aaa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f5:	01 de                	add    %ebx,%esi
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	89 f0                	mov    %esi,%eax
  8019fc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ff:	72 cc                	jb     8019cd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a04:	5b                   	pop    %ebx
  801a05:	5e                   	pop    %esi
  801a06:	5f                   	pop    %edi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a18:	74 2a                	je     801a44 <devcons_read+0x3b>
  801a1a:	eb 05                	jmp    801a21 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a1c:	e8 26 f1 ff ff       	call   800b47 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a21:	e8 a2 f0 ff ff       	call   800ac8 <sys_cgetc>
  801a26:	85 c0                	test   %eax,%eax
  801a28:	74 f2                	je     801a1c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 16                	js     801a44 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a2e:	83 f8 04             	cmp    $0x4,%eax
  801a31:	74 0c                	je     801a3f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a33:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a36:	88 02                	mov    %al,(%edx)
	return 1;
  801a38:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3d:	eb 05                	jmp    801a44 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a3f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a52:	6a 01                	push   $0x1
  801a54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a57:	50                   	push   %eax
  801a58:	e8 4d f0 ff ff       	call   800aaa <sys_cputs>
}
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <getchar>:

int
getchar(void)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a68:	6a 01                	push   $0x1
  801a6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a6d:	50                   	push   %eax
  801a6e:	6a 00                	push   $0x0
  801a70:	e8 97 f6 ff ff       	call   80110c <read>
	if (r < 0)
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 0f                	js     801a8b <getchar+0x29>
		return r;
	if (r < 1)
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	7e 06                	jle    801a86 <getchar+0x24>
		return -E_EOF;
	return c;
  801a80:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a84:	eb 05                	jmp    801a8b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a86:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a96:	50                   	push   %eax
  801a97:	ff 75 08             	pushl  0x8(%ebp)
  801a9a:	e8 07 f4 ff ff       	call   800ea6 <fd_lookup>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 11                	js     801ab7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aaf:	39 10                	cmp    %edx,(%eax)
  801ab1:	0f 94 c0             	sete   %al
  801ab4:	0f b6 c0             	movzbl %al,%eax
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <opencons>:

int
opencons(void)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801abf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac2:	50                   	push   %eax
  801ac3:	e8 8f f3 ff ff       	call   800e57 <fd_alloc>
  801ac8:	83 c4 10             	add    $0x10,%esp
		return r;
  801acb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 3e                	js     801b0f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ad1:	83 ec 04             	sub    $0x4,%esp
  801ad4:	68 07 04 00 00       	push   $0x407
  801ad9:	ff 75 f4             	pushl  -0xc(%ebp)
  801adc:	6a 00                	push   $0x0
  801ade:	e8 83 f0 ff ff       	call   800b66 <sys_page_alloc>
  801ae3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	78 23                	js     801b0f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801aec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	50                   	push   %eax
  801b05:	e8 26 f3 ff ff       	call   800e30 <fd2num>
  801b0a:	89 c2                	mov    %eax,%edx
  801b0c:	83 c4 10             	add    $0x10,%esp
}
  801b0f:	89 d0                	mov    %edx,%eax
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b18:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b1b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b21:	e8 02 f0 ff ff       	call   800b28 <sys_getenvid>
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	ff 75 0c             	pushl  0xc(%ebp)
  801b2c:	ff 75 08             	pushl  0x8(%ebp)
  801b2f:	56                   	push   %esi
  801b30:	50                   	push   %eax
  801b31:	68 a8 22 80 00       	push   $0x8022a8
  801b36:	e8 59 e6 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b3b:	83 c4 18             	add    $0x18,%esp
  801b3e:	53                   	push   %ebx
  801b3f:	ff 75 10             	pushl  0x10(%ebp)
  801b42:	e8 fc e5 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801b47:	c7 04 24 93 22 80 00 	movl   $0x802293,(%esp)
  801b4e:	e8 41 e6 ff ff       	call   800194 <cprintf>
  801b53:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b56:	cc                   	int3   
  801b57:	eb fd                	jmp    801b56 <_panic+0x43>

00801b59 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5f:	89 d0                	mov    %edx,%eax
  801b61:	c1 e8 16             	shr    $0x16,%eax
  801b64:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b6b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b70:	f6 c1 01             	test   $0x1,%cl
  801b73:	74 1d                	je     801b92 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b75:	c1 ea 0c             	shr    $0xc,%edx
  801b78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7f:	f6 c2 01             	test   $0x1,%dl
  801b82:	74 0e                	je     801b92 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b84:	c1 ea 0c             	shr    $0xc,%edx
  801b87:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8e:	ef 
  801b8f:	0f b7 c0             	movzwl %ax,%eax
}
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    
  801b94:	66 90                	xchg   %ax,%ax
  801b96:	66 90                	xchg   %ax,%ax
  801b98:	66 90                	xchg   %ax,%ax
  801b9a:	66 90                	xchg   %ax,%ax
  801b9c:	66 90                	xchg   %ax,%ax
  801b9e:	66 90                	xchg   %ax,%ax

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801baf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bb7:	85 f6                	test   %esi,%esi
  801bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbd:	89 ca                	mov    %ecx,%edx
  801bbf:	89 f8                	mov    %edi,%eax
  801bc1:	75 3d                	jne    801c00 <__udivdi3+0x60>
  801bc3:	39 cf                	cmp    %ecx,%edi
  801bc5:	0f 87 c5 00 00 00    	ja     801c90 <__udivdi3+0xf0>
  801bcb:	85 ff                	test   %edi,%edi
  801bcd:	89 fd                	mov    %edi,%ebp
  801bcf:	75 0b                	jne    801bdc <__udivdi3+0x3c>
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	31 d2                	xor    %edx,%edx
  801bd8:	f7 f7                	div    %edi
  801bda:	89 c5                	mov    %eax,%ebp
  801bdc:	89 c8                	mov    %ecx,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f5                	div    %ebp
  801be2:	89 c1                	mov    %eax,%ecx
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	89 cf                	mov    %ecx,%edi
  801be8:	f7 f5                	div    %ebp
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	39 ce                	cmp    %ecx,%esi
  801c02:	77 74                	ja     801c78 <__udivdi3+0xd8>
  801c04:	0f bd fe             	bsr    %esi,%edi
  801c07:	83 f7 1f             	xor    $0x1f,%edi
  801c0a:	0f 84 98 00 00 00    	je     801ca8 <__udivdi3+0x108>
  801c10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	89 c5                	mov    %eax,%ebp
  801c19:	29 fb                	sub    %edi,%ebx
  801c1b:	d3 e6                	shl    %cl,%esi
  801c1d:	89 d9                	mov    %ebx,%ecx
  801c1f:	d3 ed                	shr    %cl,%ebp
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e0                	shl    %cl,%eax
  801c25:	09 ee                	or     %ebp,%esi
  801c27:	89 d9                	mov    %ebx,%ecx
  801c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2d:	89 d5                	mov    %edx,%ebp
  801c2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c33:	d3 ed                	shr    %cl,%ebp
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e2                	shl    %cl,%edx
  801c39:	89 d9                	mov    %ebx,%ecx
  801c3b:	d3 e8                	shr    %cl,%eax
  801c3d:	09 c2                	or     %eax,%edx
  801c3f:	89 d0                	mov    %edx,%eax
  801c41:	89 ea                	mov    %ebp,%edx
  801c43:	f7 f6                	div    %esi
  801c45:	89 d5                	mov    %edx,%ebp
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	f7 64 24 0c          	mull   0xc(%esp)
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	72 10                	jb     801c61 <__udivdi3+0xc1>
  801c51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e6                	shl    %cl,%esi
  801c59:	39 c6                	cmp    %eax,%esi
  801c5b:	73 07                	jae    801c64 <__udivdi3+0xc4>
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	75 03                	jne    801c64 <__udivdi3+0xc4>
  801c61:	83 eb 01             	sub    $0x1,%ebx
  801c64:	31 ff                	xor    %edi,%edi
  801c66:	89 d8                	mov    %ebx,%eax
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	31 ff                	xor    %edi,%edi
  801c7a:	31 db                	xor    %ebx,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	f7 f7                	div    %edi
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	89 d8                	mov    %ebx,%eax
  801c9a:	89 fa                	mov    %edi,%edx
  801c9c:	83 c4 1c             	add    $0x1c,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    
  801ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	39 ce                	cmp    %ecx,%esi
  801caa:	72 0c                	jb     801cb8 <__udivdi3+0x118>
  801cac:	31 db                	xor    %ebx,%ebx
  801cae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cb2:	0f 87 34 ff ff ff    	ja     801bec <__udivdi3+0x4c>
  801cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cbd:	e9 2a ff ff ff       	jmp    801bec <__udivdi3+0x4c>
  801cc2:	66 90                	xchg   %ax,%ax
  801cc4:	66 90                	xchg   %ax,%ax
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	66 90                	xchg   %ax,%ax
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 d2                	test   %edx,%edx
  801ce9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cf1:	89 f3                	mov    %esi,%ebx
  801cf3:	89 3c 24             	mov    %edi,(%esp)
  801cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfa:	75 1c                	jne    801d18 <__umoddi3+0x48>
  801cfc:	39 f7                	cmp    %esi,%edi
  801cfe:	76 50                	jbe    801d50 <__umoddi3+0x80>
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	f7 f7                	div    %edi
  801d06:	89 d0                	mov    %edx,%eax
  801d08:	31 d2                	xor    %edx,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	39 f2                	cmp    %esi,%edx
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	77 52                	ja     801d70 <__umoddi3+0xa0>
  801d1e:	0f bd ea             	bsr    %edx,%ebp
  801d21:	83 f5 1f             	xor    $0x1f,%ebp
  801d24:	75 5a                	jne    801d80 <__umoddi3+0xb0>
  801d26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d2a:	0f 82 e0 00 00 00    	jb     801e10 <__umoddi3+0x140>
  801d30:	39 0c 24             	cmp    %ecx,(%esp)
  801d33:	0f 86 d7 00 00 00    	jbe    801e10 <__umoddi3+0x140>
  801d39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d41:	83 c4 1c             	add    $0x1c,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	85 ff                	test   %edi,%edi
  801d52:	89 fd                	mov    %edi,%ebp
  801d54:	75 0b                	jne    801d61 <__umoddi3+0x91>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f7                	div    %edi
  801d5f:	89 c5                	mov    %eax,%ebp
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f5                	div    %ebp
  801d67:	89 c8                	mov    %ecx,%eax
  801d69:	f7 f5                	div    %ebp
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	eb 99                	jmp    801d08 <__umoddi3+0x38>
  801d6f:	90                   	nop
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	83 c4 1c             	add    $0x1c,%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	8b 34 24             	mov    (%esp),%esi
  801d83:	bf 20 00 00 00       	mov    $0x20,%edi
  801d88:	89 e9                	mov    %ebp,%ecx
  801d8a:	29 ef                	sub    %ebp,%edi
  801d8c:	d3 e0                	shl    %cl,%eax
  801d8e:	89 f9                	mov    %edi,%ecx
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	d3 ea                	shr    %cl,%edx
  801d94:	89 e9                	mov    %ebp,%ecx
  801d96:	09 c2                	or     %eax,%edx
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	89 14 24             	mov    %edx,(%esp)
  801d9d:	89 f2                	mov    %esi,%edx
  801d9f:	d3 e2                	shl    %cl,%edx
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dab:	d3 e8                	shr    %cl,%eax
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	d3 e3                	shl    %cl,%ebx
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 d0                	mov    %edx,%eax
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	09 d8                	or     %ebx,%eax
  801dbd:	89 d3                	mov    %edx,%ebx
  801dbf:	89 f2                	mov    %esi,%edx
  801dc1:	f7 34 24             	divl   (%esp)
  801dc4:	89 d6                	mov    %edx,%esi
  801dc6:	d3 e3                	shl    %cl,%ebx
  801dc8:	f7 64 24 04          	mull   0x4(%esp)
  801dcc:	39 d6                	cmp    %edx,%esi
  801dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd2:	89 d1                	mov    %edx,%ecx
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	72 08                	jb     801de0 <__umoddi3+0x110>
  801dd8:	75 11                	jne    801deb <__umoddi3+0x11b>
  801dda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dde:	73 0b                	jae    801deb <__umoddi3+0x11b>
  801de0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801de4:	1b 14 24             	sbb    (%esp),%edx
  801de7:	89 d1                	mov    %edx,%ecx
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801def:	29 da                	sub    %ebx,%edx
  801df1:	19 ce                	sbb    %ecx,%esi
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	d3 e0                	shl    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	d3 ea                	shr    %cl,%edx
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	d3 ee                	shr    %cl,%esi
  801e01:	09 d0                	or     %edx,%eax
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	83 c4 1c             	add    $0x1c,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	29 f9                	sub    %edi,%ecx
  801e12:	19 d6                	sbb    %edx,%esi
  801e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e1c:	e9 18 ff ff ff       	jmp    801d39 <__umoddi3+0x69>
