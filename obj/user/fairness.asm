
obj/user/fairness:     file format elf32-i386


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
  80003b:	e8 e0 0a 00 00       	call   800b20 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 af 0c 00 00       	call   800d0d <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 60 10 80 00       	push   $0x801060
  80006a:	e8 1d 01 00 00       	call   80018c <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 71 10 80 00       	push   $0x801071
  800083:	e8 04 01 00 00       	call   80018c <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 88 0c 00 00       	call   800d24 <ipc_send>
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
  8000ac:	e8 6f 0a 00 00       	call   800b20 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 eb 09 00 00       	call   800adf <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	75 1a                	jne    800132 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	68 ff 00 00 00       	push   $0xff
  800120:	8d 43 08             	lea    0x8(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	e8 79 09 00 00       	call   800aa2 <sys_cputs>
		b->idx = 0;
  800129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	68 f9 00 80 00       	push   $0x8000f9
  80016a:	e8 54 01 00 00       	call   8002c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 1e 09 00 00       	call   800aa2 <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 9d ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 1c             	sub    $0x1c,%esp
  8001a9:	89 c7                	mov    %eax,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c7:	39 d3                	cmp    %edx,%ebx
  8001c9:	72 05                	jb     8001d0 <printnum+0x30>
  8001cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ce:	77 45                	ja     800215 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	ff 75 18             	pushl  0x18(%ebp)
  8001d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dc:	53                   	push   %ebx
  8001dd:	ff 75 10             	pushl  0x10(%ebp)
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 cc 0b 00 00       	call   800dc0 <__udivdi3>
  8001f4:	83 c4 18             	add    $0x18,%esp
  8001f7:	52                   	push   %edx
  8001f8:	50                   	push   %eax
  8001f9:	89 f2                	mov    %esi,%edx
  8001fb:	89 f8                	mov    %edi,%eax
  8001fd:	e8 9e ff ff ff       	call   8001a0 <printnum>
  800202:	83 c4 20             	add    $0x20,%esp
  800205:	eb 18                	jmp    80021f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	ff 75 18             	pushl  0x18(%ebp)
  80020e:	ff d7                	call   *%edi
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	eb 03                	jmp    800218 <printnum+0x78>
  800215:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f e8                	jg     800207 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	ff 75 dc             	pushl  -0x24(%ebp)
  80022f:	ff 75 d8             	pushl  -0x28(%ebp)
  800232:	e8 b9 0c 00 00       	call   800ef0 <__umoddi3>
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	0f be 80 92 10 80 00 	movsbl 0x801092(%eax),%eax
  800241:	50                   	push   %eax
  800242:	ff d7                	call   *%edi
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7e 0e                	jle    800265 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800257:	8b 10                	mov    (%eax),%edx
  800259:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 02                	mov    (%edx),%eax
  800260:	8b 52 04             	mov    0x4(%edx),%edx
  800263:	eb 22                	jmp    800287 <getuint+0x38>
	else if (lflag)
  800265:	85 d2                	test   %edx,%edx
  800267:	74 10                	je     800279 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	eb 0e                	jmp    800287 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800293:	8b 10                	mov    (%eax),%edx
  800295:	3b 50 04             	cmp    0x4(%eax),%edx
  800298:	73 0a                	jae    8002a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	88 02                	mov    %al,(%edx)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	50                   	push   %eax
  8002b0:	ff 75 10             	pushl  0x10(%ebp)
  8002b3:	ff 75 0c             	pushl  0xc(%ebp)
  8002b6:	ff 75 08             	pushl  0x8(%ebp)
  8002b9:	e8 05 00 00 00       	call   8002c3 <vprintfmt>
	va_end(ap);
}
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	57                   	push   %edi
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 2c             	sub    $0x2c,%esp
  8002cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d5:	eb 12                	jmp    8002e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	0f 84 d3 03 00 00    	je     8006b2 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	53                   	push   %ebx
  8002e3:	50                   	push   %eax
  8002e4:	ff d6                	call   *%esi
  8002e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	83 c7 01             	add    $0x1,%edi
  8002ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f0:	83 f8 25             	cmp    $0x25,%eax
  8002f3:	75 e2                	jne    8002d7 <vprintfmt+0x14>
  8002f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800300:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800307:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
  800313:	eb 07                	jmp    80031c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800318:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8d 47 01             	lea    0x1(%edi),%eax
  80031f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800322:	0f b6 07             	movzbl (%edi),%eax
  800325:	0f b6 c8             	movzbl %al,%ecx
  800328:	83 e8 23             	sub    $0x23,%eax
  80032b:	3c 55                	cmp    $0x55,%al
  80032d:	0f 87 64 03 00 00    	ja     800697 <vprintfmt+0x3d4>
  800333:	0f b6 c0             	movzbl %al,%eax
  800336:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800340:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800344:	eb d6                	jmp    80031c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800349:	b8 00 00 00 00       	mov    $0x0,%eax
  80034e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800351:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800354:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800358:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035e:	83 fa 09             	cmp    $0x9,%edx
  800361:	77 39                	ja     80039c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800363:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800366:	eb e9                	jmp    800351 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 48 04             	lea    0x4(%eax),%ecx
  80036e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800371:	8b 00                	mov    (%eax),%eax
  800373:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800379:	eb 27                	jmp    8003a2 <vprintfmt+0xdf>
  80037b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037e:	85 c0                	test   %eax,%eax
  800380:	b9 00 00 00 00       	mov    $0x0,%ecx
  800385:	0f 49 c8             	cmovns %eax,%ecx
  800388:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038e:	eb 8c                	jmp    80031c <vprintfmt+0x59>
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800393:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039a:	eb 80                	jmp    80031c <vprintfmt+0x59>
  80039c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80039f:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a6:	0f 89 70 ff ff ff    	jns    80031c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ac:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003b9:	e9 5e ff ff ff       	jmp    80031c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c4:	e9 53 ff ff ff       	jmp    80031c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 50 04             	lea    0x4(%eax),%edx
  8003cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d2:	83 ec 08             	sub    $0x8,%esp
  8003d5:	53                   	push   %ebx
  8003d6:	ff 30                	pushl  (%eax)
  8003d8:	ff d6                	call   *%esi
			break;
  8003da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e0:	e9 04 ff ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	99                   	cltd   
  8003f1:	31 d0                	xor    %edx,%eax
  8003f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f5:	83 f8 08             	cmp    $0x8,%eax
  8003f8:	7f 0b                	jg     800405 <vprintfmt+0x142>
  8003fa:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800401:	85 d2                	test   %edx,%edx
  800403:	75 18                	jne    80041d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800405:	50                   	push   %eax
  800406:	68 aa 10 80 00       	push   $0x8010aa
  80040b:	53                   	push   %ebx
  80040c:	56                   	push   %esi
  80040d:	e8 94 fe ff ff       	call   8002a6 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800418:	e9 cc fe ff ff       	jmp    8002e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041d:	52                   	push   %edx
  80041e:	68 b3 10 80 00       	push   $0x8010b3
  800423:	53                   	push   %ebx
  800424:	56                   	push   %esi
  800425:	e8 7c fe ff ff       	call   8002a6 <printfmt>
  80042a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800430:	e9 b4 fe ff ff       	jmp    8002e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800440:	85 ff                	test   %edi,%edi
  800442:	b8 a3 10 80 00       	mov    $0x8010a3,%eax
  800447:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044e:	0f 8e 94 00 00 00    	jle    8004e8 <vprintfmt+0x225>
  800454:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800458:	0f 84 98 00 00 00    	je     8004f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 c8             	pushl  -0x38(%ebp)
  800464:	57                   	push   %edi
  800465:	e8 d0 02 00 00       	call   80073a <strnlen>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800475:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	eb 0f                	jmp    800492 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 ff                	test   %edi,%edi
  800494:	7f ed                	jg     800483 <vprintfmt+0x1c0>
  800496:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800499:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80049c:	85 c9                	test   %ecx,%ecx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c1             	cmovns %ecx,%eax
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b1:	89 cb                	mov    %ecx,%ebx
  8004b3:	eb 4d                	jmp    800502 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	74 1b                	je     8004d6 <vprintfmt+0x213>
  8004bb:	0f be c0             	movsbl %al,%eax
  8004be:	83 e8 20             	sub    $0x20,%eax
  8004c1:	83 f8 5e             	cmp    $0x5e,%eax
  8004c4:	76 10                	jbe    8004d6 <vprintfmt+0x213>
					putch('?', putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 0c             	pushl  0xc(%ebp)
  8004cc:	6a 3f                	push   $0x3f
  8004ce:	ff 55 08             	call   *0x8(%ebp)
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	eb 0d                	jmp    8004e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	52                   	push   %edx
  8004dd:	ff 55 08             	call   *0x8(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e3:	83 eb 01             	sub    $0x1,%ebx
  8004e6:	eb 1a                	jmp    800502 <vprintfmt+0x23f>
  8004e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004eb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f4:	eb 0c                	jmp    800502 <vprintfmt+0x23f>
  8004f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	0f be d0             	movsbl %al,%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 23                	je     800533 <vprintfmt+0x270>
  800510:	85 f6                	test   %esi,%esi
  800512:	78 a1                	js     8004b5 <vprintfmt+0x1f2>
  800514:	83 ee 01             	sub    $0x1,%esi
  800517:	79 9c                	jns    8004b5 <vprintfmt+0x1f2>
  800519:	89 df                	mov    %ebx,%edi
  80051b:	8b 75 08             	mov    0x8(%ebp),%esi
  80051e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800521:	eb 18                	jmp    80053b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	6a 20                	push   $0x20
  800529:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 08                	jmp    80053b <vprintfmt+0x278>
  800533:	89 df                	mov    %ebx,%edi
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	85 ff                	test   %edi,%edi
  80053d:	7f e4                	jg     800523 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800542:	e9 a2 fd ff ff       	jmp    8002e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 fa 01             	cmp    $0x1,%edx
  80054a:	7e 16                	jle    800562 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 08             	lea    0x8(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 50 04             	mov    0x4(%eax),%edx
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80055d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800560:	eb 32                	jmp    800594 <vprintfmt+0x2d1>
	else if (lflag)
  800562:	85 d2                	test   %edx,%edx
  800564:	74 18                	je     80057e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800574:	89 c1                	mov    %eax,%ecx
  800576:	c1 f9 1f             	sar    $0x1f,%ecx
  800579:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80057c:	eb 16                	jmp    800594 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800594:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800597:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80059a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005a9:	0f 89 b0 00 00 00    	jns    80065f <vprintfmt+0x39c>
				putch('-', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 2d                	push   $0x2d
  8005b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005ba:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005bd:	f7 d8                	neg    %eax
  8005bf:	83 d2 00             	adc    $0x0,%edx
  8005c2:	f7 da                	neg    %edx
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ca:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 88 00 00 00       	jmp    80065f <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005da:	e8 70 fc ff ff       	call   80024f <getuint>
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005e5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ea:	eb 73                	jmp    80065f <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 5b fc ff ff       	call   80024f <getuint>
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	6a 58                	push   $0x58
  800600:	ff d6                	call   *%esi
			putch('X', putdat);
  800602:	83 c4 08             	add    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 58                	push   $0x58
  800608:	ff d6                	call   *%esi
			putch('X', putdat);
  80060a:	83 c4 08             	add    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 58                	push   $0x58
  800610:	ff d6                	call   *%esi
			goto number;
  800612:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800615:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80061a:	eb 43                	jmp    80065f <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 30                	push   $0x30
  800622:	ff d6                	call   *%esi
			putch('x', putdat);
  800624:	83 c4 08             	add    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 78                	push   $0x78
  80062a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800635:	8b 00                	mov    (%eax),%eax
  800637:	ba 00 00 00 00       	mov    $0x0,%edx
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800642:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800645:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064a:	eb 13                	jmp    80065f <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 fb fb ff ff       	call   80024f <getuint>
  800654:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800657:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80065a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065f:	83 ec 0c             	sub    $0xc,%esp
  800662:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800666:	52                   	push   %edx
  800667:	ff 75 e0             	pushl  -0x20(%ebp)
  80066a:	50                   	push   %eax
  80066b:	ff 75 dc             	pushl  -0x24(%ebp)
  80066e:	ff 75 d8             	pushl  -0x28(%ebp)
  800671:	89 da                	mov    %ebx,%edx
  800673:	89 f0                	mov    %esi,%eax
  800675:	e8 26 fb ff ff       	call   8001a0 <printnum>
			break;
  80067a:	83 c4 20             	add    $0x20,%esp
  80067d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800680:	e9 64 fc ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	51                   	push   %ecx
  80068a:	ff d6                	call   *%esi
			break;
  80068c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800692:	e9 52 fc ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 25                	push   $0x25
  80069d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 03                	jmp    8006a7 <vprintfmt+0x3e4>
  8006a4:	83 ef 01             	sub    $0x1,%edi
  8006a7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ab:	75 f7                	jne    8006a4 <vprintfmt+0x3e1>
  8006ad:	e9 37 fc ff ff       	jmp    8002e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b5:	5b                   	pop    %ebx
  8006b6:	5e                   	pop    %esi
  8006b7:	5f                   	pop    %edi
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 18             	sub    $0x18,%esp
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 26                	je     800701 <vsnprintf+0x47>
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	7e 22                	jle    800701 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006df:	ff 75 14             	pushl  0x14(%ebp)
  8006e2:	ff 75 10             	pushl  0x10(%ebp)
  8006e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e8:	50                   	push   %eax
  8006e9:	68 89 02 80 00       	push   $0x800289
  8006ee:	e8 d0 fb ff ff       	call   8002c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 05                	jmp    800706 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800701:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800711:	50                   	push   %eax
  800712:	ff 75 10             	pushl  0x10(%ebp)
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	ff 75 08             	pushl  0x8(%ebp)
  80071b:	e8 9a ff ff ff       	call   8006ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800728:	b8 00 00 00 00       	mov    $0x0,%eax
  80072d:	eb 03                	jmp    800732 <strlen+0x10>
		n++;
  80072f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800736:	75 f7                	jne    80072f <strlen+0xd>
		n++;
	return n;
}
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800743:	ba 00 00 00 00       	mov    $0x0,%edx
  800748:	eb 03                	jmp    80074d <strnlen+0x13>
		n++;
  80074a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074d:	39 c2                	cmp    %eax,%edx
  80074f:	74 08                	je     800759 <strnlen+0x1f>
  800751:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800755:	75 f3                	jne    80074a <strnlen+0x10>
  800757:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800765:	89 c2                	mov    %eax,%edx
  800767:	83 c2 01             	add    $0x1,%edx
  80076a:	83 c1 01             	add    $0x1,%ecx
  80076d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800771:	88 5a ff             	mov    %bl,-0x1(%edx)
  800774:	84 db                	test   %bl,%bl
  800776:	75 ef                	jne    800767 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800778:	5b                   	pop    %ebx
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800782:	53                   	push   %ebx
  800783:	e8 9a ff ff ff       	call   800722 <strlen>
  800788:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	01 d8                	add    %ebx,%eax
  800790:	50                   	push   %eax
  800791:	e8 c5 ff ff ff       	call   80075b <strcpy>
	return dst;
}
  800796:	89 d8                	mov    %ebx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a8:	89 f3                	mov    %esi,%ebx
  8007aa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ad:	89 f2                	mov    %esi,%edx
  8007af:	eb 0f                	jmp    8007c0 <strncpy+0x23>
		*dst++ = *src;
  8007b1:	83 c2 01             	add    $0x1,%edx
  8007b4:	0f b6 01             	movzbl (%ecx),%eax
  8007b7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ba:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c0:	39 da                	cmp    %ebx,%edx
  8007c2:	75 ed                	jne    8007b1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c4:	89 f0                	mov    %esi,%eax
  8007c6:	5b                   	pop    %ebx
  8007c7:	5e                   	pop    %esi
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	74 21                	je     8007ff <strlcpy+0x35>
  8007de:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e2:	89 f2                	mov    %esi,%edx
  8007e4:	eb 09                	jmp    8007ef <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e6:	83 c2 01             	add    $0x1,%edx
  8007e9:	83 c1 01             	add    $0x1,%ecx
  8007ec:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ef:	39 c2                	cmp    %eax,%edx
  8007f1:	74 09                	je     8007fc <strlcpy+0x32>
  8007f3:	0f b6 19             	movzbl (%ecx),%ebx
  8007f6:	84 db                	test   %bl,%bl
  8007f8:	75 ec                	jne    8007e6 <strlcpy+0x1c>
  8007fa:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ff:	29 f0                	sub    %esi,%eax
}
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080e:	eb 06                	jmp    800816 <strcmp+0x11>
		p++, q++;
  800810:	83 c1 01             	add    $0x1,%ecx
  800813:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800816:	0f b6 01             	movzbl (%ecx),%eax
  800819:	84 c0                	test   %al,%al
  80081b:	74 04                	je     800821 <strcmp+0x1c>
  80081d:	3a 02                	cmp    (%edx),%al
  80081f:	74 ef                	je     800810 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800821:	0f b6 c0             	movzbl %al,%eax
  800824:	0f b6 12             	movzbl (%edx),%edx
  800827:	29 d0                	sub    %edx,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
  800835:	89 c3                	mov    %eax,%ebx
  800837:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083a:	eb 06                	jmp    800842 <strncmp+0x17>
		n--, p++, q++;
  80083c:	83 c0 01             	add    $0x1,%eax
  80083f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800842:	39 d8                	cmp    %ebx,%eax
  800844:	74 15                	je     80085b <strncmp+0x30>
  800846:	0f b6 08             	movzbl (%eax),%ecx
  800849:	84 c9                	test   %cl,%cl
  80084b:	74 04                	je     800851 <strncmp+0x26>
  80084d:	3a 0a                	cmp    (%edx),%cl
  80084f:	74 eb                	je     80083c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800851:	0f b6 00             	movzbl (%eax),%eax
  800854:	0f b6 12             	movzbl (%edx),%edx
  800857:	29 d0                	sub    %edx,%eax
  800859:	eb 05                	jmp    800860 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086d:	eb 07                	jmp    800876 <strchr+0x13>
		if (*s == c)
  80086f:	38 ca                	cmp    %cl,%dl
  800871:	74 0f                	je     800882 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	0f b6 10             	movzbl (%eax),%edx
  800879:	84 d2                	test   %dl,%dl
  80087b:	75 f2                	jne    80086f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088e:	eb 03                	jmp    800893 <strfind+0xf>
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800896:	38 ca                	cmp    %cl,%dl
  800898:	74 04                	je     80089e <strfind+0x1a>
  80089a:	84 d2                	test   %dl,%dl
  80089c:	75 f2                	jne    800890 <strfind+0xc>
			break;
	return (char *) s;
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	57                   	push   %edi
  8008a4:	56                   	push   %esi
  8008a5:	53                   	push   %ebx
  8008a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ac:	85 c9                	test   %ecx,%ecx
  8008ae:	74 36                	je     8008e6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b6:	75 28                	jne    8008e0 <memset+0x40>
  8008b8:	f6 c1 03             	test   $0x3,%cl
  8008bb:	75 23                	jne    8008e0 <memset+0x40>
		c &= 0xFF;
  8008bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c1:	89 d3                	mov    %edx,%ebx
  8008c3:	c1 e3 08             	shl    $0x8,%ebx
  8008c6:	89 d6                	mov    %edx,%esi
  8008c8:	c1 e6 18             	shl    $0x18,%esi
  8008cb:	89 d0                	mov    %edx,%eax
  8008cd:	c1 e0 10             	shl    $0x10,%eax
  8008d0:	09 f0                	or     %esi,%eax
  8008d2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	09 d0                	or     %edx,%eax
  8008d8:	c1 e9 02             	shr    $0x2,%ecx
  8008db:	fc                   	cld    
  8008dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008de:	eb 06                	jmp    8008e6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e3:	fc                   	cld    
  8008e4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e6:	89 f8                	mov    %edi,%eax
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5f                   	pop    %edi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fb:	39 c6                	cmp    %eax,%esi
  8008fd:	73 35                	jae    800934 <memmove+0x47>
  8008ff:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800902:	39 d0                	cmp    %edx,%eax
  800904:	73 2e                	jae    800934 <memmove+0x47>
		s += n;
		d += n;
  800906:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800909:	89 d6                	mov    %edx,%esi
  80090b:	09 fe                	or     %edi,%esi
  80090d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800913:	75 13                	jne    800928 <memmove+0x3b>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 0e                	jne    800928 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80091a:	83 ef 04             	sub    $0x4,%edi
  80091d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800920:	c1 e9 02             	shr    $0x2,%ecx
  800923:	fd                   	std    
  800924:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800926:	eb 09                	jmp    800931 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800928:	83 ef 01             	sub    $0x1,%edi
  80092b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092e:	fd                   	std    
  80092f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800931:	fc                   	cld    
  800932:	eb 1d                	jmp    800951 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800934:	89 f2                	mov    %esi,%edx
  800936:	09 c2                	or     %eax,%edx
  800938:	f6 c2 03             	test   $0x3,%dl
  80093b:	75 0f                	jne    80094c <memmove+0x5f>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 0a                	jne    80094c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800942:	c1 e9 02             	shr    $0x2,%ecx
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb 05                	jmp    800951 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094c:	89 c7                	mov    %eax,%edi
  80094e:	fc                   	cld    
  80094f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800958:	ff 75 10             	pushl  0x10(%ebp)
  80095b:	ff 75 0c             	pushl  0xc(%ebp)
  80095e:	ff 75 08             	pushl  0x8(%ebp)
  800961:	e8 87 ff ff ff       	call   8008ed <memmove>
}
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c6                	mov    %eax,%esi
  800975:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800978:	eb 1a                	jmp    800994 <memcmp+0x2c>
		if (*s1 != *s2)
  80097a:	0f b6 08             	movzbl (%eax),%ecx
  80097d:	0f b6 1a             	movzbl (%edx),%ebx
  800980:	38 d9                	cmp    %bl,%cl
  800982:	74 0a                	je     80098e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800984:	0f b6 c1             	movzbl %cl,%eax
  800987:	0f b6 db             	movzbl %bl,%ebx
  80098a:	29 d8                	sub    %ebx,%eax
  80098c:	eb 0f                	jmp    80099d <memcmp+0x35>
		s1++, s2++;
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800994:	39 f0                	cmp    %esi,%eax
  800996:	75 e2                	jne    80097a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a8:	89 c1                	mov    %eax,%ecx
  8009aa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ad:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b1:	eb 0a                	jmp    8009bd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b3:	0f b6 10             	movzbl (%eax),%edx
  8009b6:	39 da                	cmp    %ebx,%edx
  8009b8:	74 07                	je     8009c1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	39 c8                	cmp    %ecx,%eax
  8009bf:	72 f2                	jb     8009b3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d0:	eb 03                	jmp    8009d5 <strtol+0x11>
		s++;
  8009d2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d5:	0f b6 01             	movzbl (%ecx),%eax
  8009d8:	3c 20                	cmp    $0x20,%al
  8009da:	74 f6                	je     8009d2 <strtol+0xe>
  8009dc:	3c 09                	cmp    $0x9,%al
  8009de:	74 f2                	je     8009d2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e0:	3c 2b                	cmp    $0x2b,%al
  8009e2:	75 0a                	jne    8009ee <strtol+0x2a>
		s++;
  8009e4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ec:	eb 11                	jmp    8009ff <strtol+0x3b>
  8009ee:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f3:	3c 2d                	cmp    $0x2d,%al
  8009f5:	75 08                	jne    8009ff <strtol+0x3b>
		s++, neg = 1;
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a05:	75 15                	jne    800a1c <strtol+0x58>
  800a07:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0a:	75 10                	jne    800a1c <strtol+0x58>
  800a0c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a10:	75 7c                	jne    800a8e <strtol+0xca>
		s += 2, base = 16;
  800a12:	83 c1 02             	add    $0x2,%ecx
  800a15:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1a:	eb 16                	jmp    800a32 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1c:	85 db                	test   %ebx,%ebx
  800a1e:	75 12                	jne    800a32 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a20:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a25:	80 39 30             	cmpb   $0x30,(%ecx)
  800a28:	75 08                	jne    800a32 <strtol+0x6e>
		s++, base = 8;
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3a:	0f b6 11             	movzbl (%ecx),%edx
  800a3d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a40:	89 f3                	mov    %esi,%ebx
  800a42:	80 fb 09             	cmp    $0x9,%bl
  800a45:	77 08                	ja     800a4f <strtol+0x8b>
			dig = *s - '0';
  800a47:	0f be d2             	movsbl %dl,%edx
  800a4a:	83 ea 30             	sub    $0x30,%edx
  800a4d:	eb 22                	jmp    800a71 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a52:	89 f3                	mov    %esi,%ebx
  800a54:	80 fb 19             	cmp    $0x19,%bl
  800a57:	77 08                	ja     800a61 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a59:	0f be d2             	movsbl %dl,%edx
  800a5c:	83 ea 57             	sub    $0x57,%edx
  800a5f:	eb 10                	jmp    800a71 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a61:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a64:	89 f3                	mov    %esi,%ebx
  800a66:	80 fb 19             	cmp    $0x19,%bl
  800a69:	77 16                	ja     800a81 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6b:	0f be d2             	movsbl %dl,%edx
  800a6e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a71:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a74:	7d 0b                	jge    800a81 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7f:	eb b9                	jmp    800a3a <strtol+0x76>

	if (endptr)
  800a81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a85:	74 0d                	je     800a94 <strtol+0xd0>
		*endptr = (char *) s;
  800a87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8a:	89 0e                	mov    %ecx,(%esi)
  800a8c:	eb 06                	jmp    800a94 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8e:	85 db                	test   %ebx,%ebx
  800a90:	74 98                	je     800a2a <strtol+0x66>
  800a92:	eb 9e                	jmp    800a32 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a94:	89 c2                	mov    %eax,%edx
  800a96:	f7 da                	neg    %edx
  800a98:	85 ff                	test   %edi,%edi
  800a9a:	0f 45 c2             	cmovne %edx,%eax
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 c3                	mov    %eax,%ebx
  800ab5:	89 c7                	mov    %eax,%edi
  800ab7:	89 c6                	mov    %eax,%esi
  800ab9:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  800acb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad0:	89 d1                	mov    %edx,%ecx
  800ad2:	89 d3                	mov    %edx,%ebx
  800ad4:	89 d7                	mov    %edx,%edi
  800ad6:	89 d6                	mov    %edx,%esi
  800ad8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aed:	b8 03 00 00 00       	mov    $0x3,%eax
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	89 cb                	mov    %ecx,%ebx
  800af7:	89 cf                	mov    %ecx,%edi
  800af9:	89 ce                	mov    %ecx,%esi
  800afb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800afd:	85 c0                	test   %eax,%eax
  800aff:	7e 17                	jle    800b18 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b01:	83 ec 0c             	sub    $0xc,%esp
  800b04:	50                   	push   %eax
  800b05:	6a 03                	push   $0x3
  800b07:	68 e4 12 80 00       	push   $0x8012e4
  800b0c:	6a 23                	push   $0x23
  800b0e:	68 01 13 80 00       	push   $0x801301
  800b13:	e8 5c 02 00 00       	call   800d74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_yield>:

void
sys_yield(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4f:	89 d1                	mov    %edx,%ecx
  800b51:	89 d3                	mov    %edx,%ebx
  800b53:	89 d7                	mov    %edx,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b67:	be 00 00 00 00       	mov    $0x0,%esi
  800b6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7a:	89 f7                	mov    %esi,%edi
  800b7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 04                	push   $0x4
  800b88:	68 e4 12 80 00       	push   $0x8012e4
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 01 13 80 00       	push   $0x801301
  800b94:	e8 db 01 00 00       	call   800d74 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800baa:	b8 05 00 00 00       	mov    $0x5,%eax
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 05                	push   $0x5
  800bca:	68 e4 12 80 00       	push   $0x8012e4
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 01 13 80 00       	push   $0x801301
  800bd6:	e8 99 01 00 00       	call   800d74 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf1:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	89 df                	mov    %ebx,%edi
  800bfe:	89 de                	mov    %ebx,%esi
  800c00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 06                	push   $0x6
  800c0c:	68 e4 12 80 00       	push   $0x8012e4
  800c11:	6a 23                	push   $0x23
  800c13:	68 01 13 80 00       	push   $0x801301
  800c18:	e8 57 01 00 00       	call   800d74 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	b8 08 00 00 00       	mov    $0x8,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 08                	push   $0x8
  800c4e:	68 e4 12 80 00       	push   $0x8012e4
  800c53:	6a 23                	push   $0x23
  800c55:	68 01 13 80 00       	push   $0x801301
  800c5a:	e8 15 01 00 00       	call   800d74 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 17                	jle    800ca1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	50                   	push   %eax
  800c8e:	6a 09                	push   $0x9
  800c90:	68 e4 12 80 00       	push   $0x8012e4
  800c95:	6a 23                	push   $0x23
  800c97:	68 01 13 80 00       	push   $0x801301
  800c9c:	e8 d3 00 00 00       	call   800d74 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0c                	push   $0xc
  800cf4:	68 e4 12 80 00       	push   $0x8012e4
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 01 13 80 00       	push   $0x801301
  800d00:	e8 6f 00 00 00       	call   800d74 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d13:	68 0f 13 80 00       	push   $0x80130f
  800d18:	6a 1a                	push   $0x1a
  800d1a:	68 28 13 80 00       	push   $0x801328
  800d1f:	e8 50 00 00 00       	call   800d74 <_panic>

00800d24 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d2a:	68 32 13 80 00       	push   $0x801332
  800d2f:	6a 2a                	push   $0x2a
  800d31:	68 28 13 80 00       	push   $0x801328
  800d36:	e8 39 00 00 00       	call   800d74 <_panic>

00800d3b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d46:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800d49:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d4f:	8b 52 50             	mov    0x50(%edx),%edx
  800d52:	39 ca                	cmp    %ecx,%edx
  800d54:	75 0d                	jne    800d63 <ipc_find_env+0x28>
			return envs[i].env_id;
  800d56:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800d59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d5e:	8b 40 48             	mov    0x48(%eax),%eax
  800d61:	eb 0f                	jmp    800d72 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800d63:	83 c0 01             	add    $0x1,%eax
  800d66:	3d 00 04 00 00       	cmp    $0x400,%eax
  800d6b:	75 d9                	jne    800d46 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800d6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d79:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d7c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d82:	e8 99 fd ff ff       	call   800b20 <sys_getenvid>
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	ff 75 0c             	pushl  0xc(%ebp)
  800d8d:	ff 75 08             	pushl  0x8(%ebp)
  800d90:	56                   	push   %esi
  800d91:	50                   	push   %eax
  800d92:	68 4c 13 80 00       	push   $0x80134c
  800d97:	e8 f0 f3 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d9c:	83 c4 18             	add    $0x18,%esp
  800d9f:	53                   	push   %ebx
  800da0:	ff 75 10             	pushl  0x10(%ebp)
  800da3:	e8 93 f3 ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  800da8:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800daf:	e8 d8 f3 ff ff       	call   80018c <cprintf>
  800db4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800db7:	cc                   	int3   
  800db8:	eb fd                	jmp    800db7 <_panic+0x43>
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 f6                	test   %esi,%esi
  800dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ddd:	89 ca                	mov    %ecx,%edx
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	75 3d                	jne    800e20 <__udivdi3+0x60>
  800de3:	39 cf                	cmp    %ecx,%edi
  800de5:	0f 87 c5 00 00 00    	ja     800eb0 <__udivdi3+0xf0>
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 fd                	mov    %edi,%ebp
  800def:	75 0b                	jne    800dfc <__udivdi3+0x3c>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f7                	div    %edi
  800dfa:	89 c5                	mov    %eax,%ebp
  800dfc:	89 c8                	mov    %ecx,%eax
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f5                	div    %ebp
  800e02:	89 c1                	mov    %eax,%ecx
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	f7 f5                	div    %ebp
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	39 ce                	cmp    %ecx,%esi
  800e22:	77 74                	ja     800e98 <__udivdi3+0xd8>
  800e24:	0f bd fe             	bsr    %esi,%edi
  800e27:	83 f7 1f             	xor    $0x1f,%edi
  800e2a:	0f 84 98 00 00 00    	je     800ec8 <__udivdi3+0x108>
  800e30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	89 c5                	mov    %eax,%ebp
  800e39:	29 fb                	sub    %edi,%ebx
  800e3b:	d3 e6                	shl    %cl,%esi
  800e3d:	89 d9                	mov    %ebx,%ecx
  800e3f:	d3 ed                	shr    %cl,%ebp
  800e41:	89 f9                	mov    %edi,%ecx
  800e43:	d3 e0                	shl    %cl,%eax
  800e45:	09 ee                	or     %ebp,%esi
  800e47:	89 d9                	mov    %ebx,%ecx
  800e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4d:	89 d5                	mov    %edx,%ebp
  800e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e53:	d3 ed                	shr    %cl,%ebp
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e2                	shl    %cl,%edx
  800e59:	89 d9                	mov    %ebx,%ecx
  800e5b:	d3 e8                	shr    %cl,%eax
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	89 ea                	mov    %ebp,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 d5                	mov    %edx,%ebp
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	f7 64 24 0c          	mull   0xc(%esp)
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	72 10                	jb     800e81 <__udivdi3+0xc1>
  800e71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e6                	shl    %cl,%esi
  800e79:	39 c6                	cmp    %eax,%esi
  800e7b:	73 07                	jae    800e84 <__udivdi3+0xc4>
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	75 03                	jne    800e84 <__udivdi3+0xc4>
  800e81:	83 eb 01             	sub    $0x1,%ebx
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	31 ff                	xor    %edi,%edi
  800e9a:	31 db                	xor    %ebx,%ebx
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	f7 f7                	div    %edi
  800eb4:	31 ff                	xor    %edi,%edi
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 fa                	mov    %edi,%edx
  800ebc:	83 c4 1c             	add    $0x1c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	39 ce                	cmp    %ecx,%esi
  800eca:	72 0c                	jb     800ed8 <__udivdi3+0x118>
  800ecc:	31 db                	xor    %ebx,%ebx
  800ece:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ed2:	0f 87 34 ff ff ff    	ja     800e0c <__udivdi3+0x4c>
  800ed8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800edd:	e9 2a ff ff ff       	jmp    800e0c <__udivdi3+0x4c>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 d2                	test   %edx,%edx
  800f09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f3                	mov    %esi,%ebx
  800f13:	89 3c 24             	mov    %edi,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	75 1c                	jne    800f38 <__umoddi3+0x48>
  800f1c:	39 f7                	cmp    %esi,%edi
  800f1e:	76 50                	jbe    800f70 <__umoddi3+0x80>
  800f20:	89 c8                	mov    %ecx,%eax
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	f7 f7                	div    %edi
  800f26:	89 d0                	mov    %edx,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	83 c4 1c             	add    $0x1c,%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	77 52                	ja     800f90 <__umoddi3+0xa0>
  800f3e:	0f bd ea             	bsr    %edx,%ebp
  800f41:	83 f5 1f             	xor    $0x1f,%ebp
  800f44:	75 5a                	jne    800fa0 <__umoddi3+0xb0>
  800f46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	39 0c 24             	cmp    %ecx,(%esp)
  800f53:	0f 86 d7 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f61:	83 c4 1c             	add    $0x1c,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	85 ff                	test   %edi,%edi
  800f72:	89 fd                	mov    %edi,%ebp
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 c8                	mov    %ecx,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	eb 99                	jmp    800f28 <__umoddi3+0x38>
  800f8f:	90                   	nop
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	83 c4 1c             	add    $0x1c,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	8b 34 24             	mov    (%esp),%esi
  800fa3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	29 ef                	sub    %ebp,%edi
  800fac:	d3 e0                	shl    %cl,%eax
  800fae:	89 f9                	mov    %edi,%ecx
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	d3 ea                	shr    %cl,%edx
  800fb4:	89 e9                	mov    %ebp,%ecx
  800fb6:	09 c2                	or     %eax,%edx
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	89 14 24             	mov    %edx,(%esp)
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	d3 e2                	shl    %cl,%edx
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	d3 e3                	shl    %cl,%ebx
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	09 d8                	or     %ebx,%eax
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 f2                	mov    %esi,%edx
  800fe1:	f7 34 24             	divl   (%esp)
  800fe4:	89 d6                	mov    %edx,%esi
  800fe6:	d3 e3                	shl    %cl,%ebx
  800fe8:	f7 64 24 04          	mull   0x4(%esp)
  800fec:	39 d6                	cmp    %edx,%esi
  800fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff2:	89 d1                	mov    %edx,%ecx
  800ff4:	89 c3                	mov    %eax,%ebx
  800ff6:	72 08                	jb     801000 <__umoddi3+0x110>
  800ff8:	75 11                	jne    80100b <__umoddi3+0x11b>
  800ffa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800ffe:	73 0b                	jae    80100b <__umoddi3+0x11b>
  801000:	2b 44 24 04          	sub    0x4(%esp),%eax
  801004:	1b 14 24             	sbb    (%esp),%edx
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80100f:	29 da                	sub    %ebx,%edx
  801011:	19 ce                	sbb    %ecx,%esi
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 f0                	mov    %esi,%eax
  801017:	d3 e0                	shl    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	d3 ee                	shr    %cl,%esi
  801021:	09 d0                	or     %edx,%eax
  801023:	89 f2                	mov    %esi,%edx
  801025:	83 c4 1c             	add    $0x1c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 f9                	sub    %edi,%ecx
  801032:	19 d6                	sbb    %edx,%esi
  801034:	89 74 24 04          	mov    %esi,0x4(%esp)
  801038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103c:	e9 18 ff ff ff       	jmp    800f59 <__umoddi3+0x69>
