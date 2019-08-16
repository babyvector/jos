
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
  80003a:	68 80 13 80 00       	push   $0x801380
  80003f:	e8 68 01 00 00       	call   8001ac <cprintf>
	cprintf("\t \t before the fork().\n");
  800044:	c7 04 24 f8 13 80 00 	movl   $0x8013f8,(%esp)
  80004b:	e8 5c 01 00 00       	call   8001ac <cprintf>
	if ((env = fork()) == 0) {
  800050:	e8 c3 0d 00 00       	call   800e18 <fork>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	85 c0                	test   %eax,%eax
  80005a:	75 12                	jne    80006e <umain+0x3b>

		cprintf("I am the child.  Spinning...\n");
  80005c:	83 ec 0c             	sub    $0xc,%esp
  80005f:	68 10 14 80 00       	push   $0x801410
  800064:	e8 43 01 00 00       	call   8001ac <cprintf>
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	eb fe                	jmp    80006c <umain+0x39>
  80006e:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 a8 13 80 00       	push   $0x8013a8
  800078:	e8 2f 01 00 00       	call   8001ac <cprintf>
	sys_yield();
  80007d:	e8 dd 0a 00 00       	call   800b5f <sys_yield>
	sys_yield();
  800082:	e8 d8 0a 00 00       	call   800b5f <sys_yield>
	sys_yield();
  800087:	e8 d3 0a 00 00       	call   800b5f <sys_yield>
	sys_yield();
  80008c:	e8 ce 0a 00 00       	call   800b5f <sys_yield>
	sys_yield();
  800091:	e8 c9 0a 00 00       	call   800b5f <sys_yield>
	sys_yield();
  800096:	e8 c4 0a 00 00       	call   800b5f <sys_yield>
	sys_yield();
  80009b:	e8 bf 0a 00 00       	call   800b5f <sys_yield>
	sys_yield();
  8000a0:	e8 ba 0a 00 00       	call   800b5f <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 d0 13 80 00 	movl   $0x8013d0,(%esp)
  8000ac:	e8 fb 00 00 00       	call   8001ac <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 46 0a 00 00       	call   800aff <sys_env_destroy>
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
  8000cc:	e8 6f 0a 00 00       	call   800b40 <sys_getenvid>
  8000d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 db                	test   %ebx,%ebx
  8000e5:	7e 07                	jle    8000ee <libmain+0x2d>
		binaryname = argv[0];
  8000e7:	8b 06                	mov    (%esi),%eax
  8000e9:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80010a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010d:	6a 00                	push   $0x0
  80010f:	e8 eb 09 00 00       	call   800aff <sys_env_destroy>
}
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	53                   	push   %ebx
  80011d:	83 ec 04             	sub    $0x4,%esp
  800120:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800123:	8b 13                	mov    (%ebx),%edx
  800125:	8d 42 01             	lea    0x1(%edx),%eax
  800128:	89 03                	mov    %eax,(%ebx)
  80012a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800131:	3d ff 00 00 00       	cmp    $0xff,%eax
  800136:	75 1a                	jne    800152 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	68 ff 00 00 00       	push   $0xff
  800140:	8d 43 08             	lea    0x8(%ebx),%eax
  800143:	50                   	push   %eax
  800144:	e8 79 09 00 00       	call   800ac2 <sys_cputs>
		b->idx = 0;
  800149:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800152:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800164:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016b:	00 00 00 
	b.cnt = 0;
  80016e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800175:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800178:	ff 75 0c             	pushl  0xc(%ebp)
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	68 19 01 80 00       	push   $0x800119
  80018a:	e8 54 01 00 00       	call   8002e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018f:	83 c4 08             	add    $0x8,%esp
  800192:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800198:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 1e 09 00 00       	call   800ac2 <sys_cputs>

	return b.cnt;
}
  8001a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b5:	50                   	push   %eax
  8001b6:	ff 75 08             	pushl  0x8(%ebp)
  8001b9:	e8 9d ff ff ff       	call   80015b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 1c             	sub    $0x1c,%esp
  8001c9:	89 c7                	mov    %eax,%edi
  8001cb:	89 d6                	mov    %edx,%esi
  8001cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e7:	39 d3                	cmp    %edx,%ebx
  8001e9:	72 05                	jb     8001f0 <printnum+0x30>
  8001eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ee:	77 45                	ja     800235 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	ff 75 18             	pushl  0x18(%ebp)
  8001f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fc:	53                   	push   %ebx
  8001fd:	ff 75 10             	pushl  0x10(%ebp)
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 e4             	pushl  -0x1c(%ebp)
  800206:	ff 75 e0             	pushl  -0x20(%ebp)
  800209:	ff 75 dc             	pushl  -0x24(%ebp)
  80020c:	ff 75 d8             	pushl  -0x28(%ebp)
  80020f:	e8 cc 0e 00 00       	call   8010e0 <__udivdi3>
  800214:	83 c4 18             	add    $0x18,%esp
  800217:	52                   	push   %edx
  800218:	50                   	push   %eax
  800219:	89 f2                	mov    %esi,%edx
  80021b:	89 f8                	mov    %edi,%eax
  80021d:	e8 9e ff ff ff       	call   8001c0 <printnum>
  800222:	83 c4 20             	add    $0x20,%esp
  800225:	eb 18                	jmp    80023f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	ff 75 18             	pushl  0x18(%ebp)
  80022e:	ff d7                	call   *%edi
  800230:	83 c4 10             	add    $0x10,%esp
  800233:	eb 03                	jmp    800238 <printnum+0x78>
  800235:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	85 db                	test   %ebx,%ebx
  80023d:	7f e8                	jg     800227 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023f:	83 ec 08             	sub    $0x8,%esp
  800242:	56                   	push   %esi
  800243:	83 ec 04             	sub    $0x4,%esp
  800246:	ff 75 e4             	pushl  -0x1c(%ebp)
  800249:	ff 75 e0             	pushl  -0x20(%ebp)
  80024c:	ff 75 dc             	pushl  -0x24(%ebp)
  80024f:	ff 75 d8             	pushl  -0x28(%ebp)
  800252:	e8 b9 0f 00 00       	call   801210 <__umoddi3>
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	0f be 80 38 14 80 00 	movsbl 0x801438(%eax),%eax
  800261:	50                   	push   %eax
  800262:	ff d7                	call   *%edi
}
  800264:	83 c4 10             	add    $0x10,%esp
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800272:	83 fa 01             	cmp    $0x1,%edx
  800275:	7e 0e                	jle    800285 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	8b 52 04             	mov    0x4(%edx),%edx
  800283:	eb 22                	jmp    8002a7 <getuint+0x38>
	else if (lflag)
  800285:	85 d2                	test   %edx,%edx
  800287:	74 10                	je     800299 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	ba 00 00 00 00       	mov    $0x0,%edx
  800297:	eb 0e                	jmp    8002a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b8:	73 0a                	jae    8002c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	88 02                	mov    %al,(%edx)
}
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cf:	50                   	push   %eax
  8002d0:	ff 75 10             	pushl  0x10(%ebp)
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 05 00 00 00       	call   8002e3 <vprintfmt>
	va_end(ap);
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	c9                   	leave  
  8002e2:	c3                   	ret    

008002e3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 2c             	sub    $0x2c,%esp
  8002ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f5:	eb 12                	jmp    800309 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	0f 84 d3 03 00 00    	je     8006d2 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	53                   	push   %ebx
  800303:	50                   	push   %eax
  800304:	ff d6                	call   *%esi
  800306:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	83 c7 01             	add    $0x1,%edi
  80030c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800310:	83 f8 25             	cmp    $0x25,%eax
  800313:	75 e2                	jne    8002f7 <vprintfmt+0x14>
  800315:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800319:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800320:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800327:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	eb 07                	jmp    80033c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800338:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8d 47 01             	lea    0x1(%edi),%eax
  80033f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800342:	0f b6 07             	movzbl (%edi),%eax
  800345:	0f b6 c8             	movzbl %al,%ecx
  800348:	83 e8 23             	sub    $0x23,%eax
  80034b:	3c 55                	cmp    $0x55,%al
  80034d:	0f 87 64 03 00 00    	ja     8006b7 <vprintfmt+0x3d4>
  800353:	0f b6 c0             	movzbl %al,%eax
  800356:	ff 24 85 00 15 80 00 	jmp    *0x801500(,%eax,4)
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800360:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800364:	eb d6                	jmp    80033c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800371:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800374:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800378:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80037b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037e:	83 fa 09             	cmp    $0x9,%edx
  800381:	77 39                	ja     8003bc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800383:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800386:	eb e9                	jmp    800371 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 48 04             	lea    0x4(%eax),%ecx
  80038e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800391:	8b 00                	mov    (%eax),%eax
  800393:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800399:	eb 27                	jmp    8003c2 <vprintfmt+0xdf>
  80039b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a5:	0f 49 c8             	cmovns %eax,%ecx
  8003a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	eb 8c                	jmp    80033c <vprintfmt+0x59>
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ba:	eb 80                	jmp    80033c <vprintfmt+0x59>
  8003bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bf:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c6:	0f 89 70 ff ff ff    	jns    80033c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003cc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003d9:	e9 5e ff ff ff       	jmp    80033c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003de:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e4:	e9 53 ff ff ff       	jmp    80033c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 50 04             	lea    0x4(%eax),%edx
  8003ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f2:	83 ec 08             	sub    $0x8,%esp
  8003f5:	53                   	push   %ebx
  8003f6:	ff 30                	pushl  (%eax)
  8003f8:	ff d6                	call   *%esi
			break;
  8003fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800400:	e9 04 ff ff ff       	jmp    800309 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	99                   	cltd   
  800411:	31 d0                	xor    %edx,%eax
  800413:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800415:	83 f8 08             	cmp    $0x8,%eax
  800418:	7f 0b                	jg     800425 <vprintfmt+0x142>
  80041a:	8b 14 85 60 16 80 00 	mov    0x801660(,%eax,4),%edx
  800421:	85 d2                	test   %edx,%edx
  800423:	75 18                	jne    80043d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800425:	50                   	push   %eax
  800426:	68 50 14 80 00       	push   $0x801450
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 94 fe ff ff       	call   8002c6 <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800438:	e9 cc fe ff ff       	jmp    800309 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80043d:	52                   	push   %edx
  80043e:	68 59 14 80 00       	push   $0x801459
  800443:	53                   	push   %ebx
  800444:	56                   	push   %esi
  800445:	e8 7c fe ff ff       	call   8002c6 <printfmt>
  80044a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800450:	e9 b4 fe ff ff       	jmp    800309 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800460:	85 ff                	test   %edi,%edi
  800462:	b8 49 14 80 00       	mov    $0x801449,%eax
  800467:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046e:	0f 8e 94 00 00 00    	jle    800508 <vprintfmt+0x225>
  800474:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800478:	0f 84 98 00 00 00    	je     800516 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 c8             	pushl  -0x38(%ebp)
  800484:	57                   	push   %edi
  800485:	e8 d0 02 00 00       	call   80075a <strnlen>
  80048a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800492:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800495:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800499:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	eb 0f                	jmp    8004b2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004aa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	83 ef 01             	sub    $0x1,%edi
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 ff                	test   %edi,%edi
  8004b4:	7f ed                	jg     8004a3 <vprintfmt+0x1c0>
  8004b6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004bc:	85 c9                	test   %ecx,%ecx
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	0f 49 c1             	cmovns %ecx,%eax
  8004c6:	29 c1                	sub    %eax,%ecx
  8004c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d1:	89 cb                	mov    %ecx,%ebx
  8004d3:	eb 4d                	jmp    800522 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d9:	74 1b                	je     8004f6 <vprintfmt+0x213>
  8004db:	0f be c0             	movsbl %al,%eax
  8004de:	83 e8 20             	sub    $0x20,%eax
  8004e1:	83 f8 5e             	cmp    $0x5e,%eax
  8004e4:	76 10                	jbe    8004f6 <vprintfmt+0x213>
					putch('?', putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 0c             	pushl  0xc(%ebp)
  8004ec:	6a 3f                	push   $0x3f
  8004ee:	ff 55 08             	call   *0x8(%ebp)
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	eb 0d                	jmp    800503 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	ff 75 0c             	pushl  0xc(%ebp)
  8004fc:	52                   	push   %edx
  8004fd:	ff 55 08             	call   *0x8(%ebp)
  800500:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800503:	83 eb 01             	sub    $0x1,%ebx
  800506:	eb 1a                	jmp    800522 <vprintfmt+0x23f>
  800508:	89 75 08             	mov    %esi,0x8(%ebp)
  80050b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80050e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800511:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800514:	eb 0c                	jmp    800522 <vprintfmt+0x23f>
  800516:	89 75 08             	mov    %esi,0x8(%ebp)
  800519:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80051c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800522:	83 c7 01             	add    $0x1,%edi
  800525:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800529:	0f be d0             	movsbl %al,%edx
  80052c:	85 d2                	test   %edx,%edx
  80052e:	74 23                	je     800553 <vprintfmt+0x270>
  800530:	85 f6                	test   %esi,%esi
  800532:	78 a1                	js     8004d5 <vprintfmt+0x1f2>
  800534:	83 ee 01             	sub    $0x1,%esi
  800537:	79 9c                	jns    8004d5 <vprintfmt+0x1f2>
  800539:	89 df                	mov    %ebx,%edi
  80053b:	8b 75 08             	mov    0x8(%ebp),%esi
  80053e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800541:	eb 18                	jmp    80055b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	53                   	push   %ebx
  800547:	6a 20                	push   $0x20
  800549:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054b:	83 ef 01             	sub    $0x1,%edi
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	eb 08                	jmp    80055b <vprintfmt+0x278>
  800553:	89 df                	mov    %ebx,%edi
  800555:	8b 75 08             	mov    0x8(%ebp),%esi
  800558:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055b:	85 ff                	test   %edi,%edi
  80055d:	7f e4                	jg     800543 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 a2 fd ff ff       	jmp    800309 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800567:	83 fa 01             	cmp    $0x1,%edx
  80056a:	7e 16                	jle    800582 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 08             	lea    0x8(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	8b 50 04             	mov    0x4(%eax),%edx
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800580:	eb 32                	jmp    8005b4 <vprintfmt+0x2d1>
	else if (lflag)
  800582:	85 d2                	test   %edx,%edx
  800584:	74 18                	je     80059e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80059c:	eb 16                	jmp    8005b4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 50 04             	lea    0x4(%eax),%edx
  8005a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ac:	89 c1                	mov    %eax,%ecx
  8005ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005b7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005c9:	0f 89 b0 00 00 00    	jns    80067f <vprintfmt+0x39c>
				putch('-', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 2d                	push   $0x2d
  8005d5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005da:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005dd:	f7 d8                	neg    %eax
  8005df:	83 d2 00             	adc    $0x0,%edx
  8005e2:	f7 da                	neg    %edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ea:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f2:	e9 88 00 00 00       	jmp    80067f <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 70 fc ff ff       	call   80026f <getuint>
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80060a:	eb 73                	jmp    80067f <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80060c:	8d 45 14             	lea    0x14(%ebp),%eax
  80060f:	e8 5b fc ff ff       	call   80026f <getuint>
  800614:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800617:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 58                	push   $0x58
  800620:	ff d6                	call   *%esi
			putch('X', putdat);
  800622:	83 c4 08             	add    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 58                	push   $0x58
  800628:	ff d6                	call   *%esi
			putch('X', putdat);
  80062a:	83 c4 08             	add    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 58                	push   $0x58
  800630:	ff d6                	call   *%esi
			goto number;
  800632:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800635:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80063a:	eb 43                	jmp    80067f <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 30                	push   $0x30
  800642:	ff d6                	call   *%esi
			putch('x', putdat);
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 78                	push   $0x78
  80064a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800655:	8b 00                	mov    (%eax),%eax
  800657:	ba 00 00 00 00       	mov    $0x0,%edx
  80065c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800662:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800665:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80066a:	eb 13                	jmp    80067f <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 fb fb ff ff       	call   80026f <getuint>
  800674:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800677:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067f:	83 ec 0c             	sub    $0xc,%esp
  800682:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800686:	52                   	push   %edx
  800687:	ff 75 e0             	pushl  -0x20(%ebp)
  80068a:	50                   	push   %eax
  80068b:	ff 75 dc             	pushl  -0x24(%ebp)
  80068e:	ff 75 d8             	pushl  -0x28(%ebp)
  800691:	89 da                	mov    %ebx,%edx
  800693:	89 f0                	mov    %esi,%eax
  800695:	e8 26 fb ff ff       	call   8001c0 <printnum>
			break;
  80069a:	83 c4 20             	add    $0x20,%esp
  80069d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a0:	e9 64 fc ff ff       	jmp    800309 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	51                   	push   %ecx
  8006aa:	ff d6                	call   *%esi
			break;
  8006ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b2:	e9 52 fc ff ff       	jmp    800309 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 25                	push   $0x25
  8006bd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 03                	jmp    8006c7 <vprintfmt+0x3e4>
  8006c4:	83 ef 01             	sub    $0x1,%edi
  8006c7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006cb:	75 f7                	jne    8006c4 <vprintfmt+0x3e1>
  8006cd:	e9 37 fc ff ff       	jmp    800309 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d5:	5b                   	pop    %ebx
  8006d6:	5e                   	pop    %esi
  8006d7:	5f                   	pop    %edi
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 18             	sub    $0x18,%esp
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	74 26                	je     800721 <vsnprintf+0x47>
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	7e 22                	jle    800721 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ff:	ff 75 14             	pushl  0x14(%ebp)
  800702:	ff 75 10             	pushl  0x10(%ebp)
  800705:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	68 a9 02 80 00       	push   $0x8002a9
  80070e:	e8 d0 fb ff ff       	call   8002e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800713:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800716:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb 05                	jmp    800726 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800721:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800731:	50                   	push   %eax
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	ff 75 08             	pushl  0x8(%ebp)
  80073b:	e8 9a ff ff ff       	call   8006da <vsnprintf>
	va_end(ap);

	return rc;
}
  800740:	c9                   	leave  
  800741:	c3                   	ret    

00800742 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	eb 03                	jmp    800752 <strlen+0x10>
		n++;
  80074f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800756:	75 f7                	jne    80074f <strlen+0xd>
		n++;
	return n;
}
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800760:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800763:	ba 00 00 00 00       	mov    $0x0,%edx
  800768:	eb 03                	jmp    80076d <strnlen+0x13>
		n++;
  80076a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	39 c2                	cmp    %eax,%edx
  80076f:	74 08                	je     800779 <strnlen+0x1f>
  800771:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800775:	75 f3                	jne    80076a <strnlen+0x10>
  800777:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800785:	89 c2                	mov    %eax,%edx
  800787:	83 c2 01             	add    $0x1,%edx
  80078a:	83 c1 01             	add    $0x1,%ecx
  80078d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800791:	88 5a ff             	mov    %bl,-0x1(%edx)
  800794:	84 db                	test   %bl,%bl
  800796:	75 ef                	jne    800787 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800798:	5b                   	pop    %ebx
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a2:	53                   	push   %ebx
  8007a3:	e8 9a ff ff ff       	call   800742 <strlen>
  8007a8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	01 d8                	add    %ebx,%eax
  8007b0:	50                   	push   %eax
  8007b1:	e8 c5 ff ff ff       	call   80077b <strcpy>
	return dst;
}
  8007b6:	89 d8                	mov    %ebx,%eax
  8007b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	56                   	push   %esi
  8007c1:	53                   	push   %ebx
  8007c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c8:	89 f3                	mov    %esi,%ebx
  8007ca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	89 f2                	mov    %esi,%edx
  8007cf:	eb 0f                	jmp    8007e0 <strncpy+0x23>
		*dst++ = *src;
  8007d1:	83 c2 01             	add    $0x1,%edx
  8007d4:	0f b6 01             	movzbl (%ecx),%eax
  8007d7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007da:	80 39 01             	cmpb   $0x1,(%ecx)
  8007dd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e0:	39 da                	cmp    %ebx,%edx
  8007e2:	75 ed                	jne    8007d1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e4:	89 f0                	mov    %esi,%eax
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	56                   	push   %esi
  8007ee:	53                   	push   %ebx
  8007ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	74 21                	je     80081f <strlcpy+0x35>
  8007fe:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800802:	89 f2                	mov    %esi,%edx
  800804:	eb 09                	jmp    80080f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	83 c1 01             	add    $0x1,%ecx
  80080c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080f:	39 c2                	cmp    %eax,%edx
  800811:	74 09                	je     80081c <strlcpy+0x32>
  800813:	0f b6 19             	movzbl (%ecx),%ebx
  800816:	84 db                	test   %bl,%bl
  800818:	75 ec                	jne    800806 <strlcpy+0x1c>
  80081a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081f:	29 f0                	sub    %esi,%eax
}
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082e:	eb 06                	jmp    800836 <strcmp+0x11>
		p++, q++;
  800830:	83 c1 01             	add    $0x1,%ecx
  800833:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800836:	0f b6 01             	movzbl (%ecx),%eax
  800839:	84 c0                	test   %al,%al
  80083b:	74 04                	je     800841 <strcmp+0x1c>
  80083d:	3a 02                	cmp    (%edx),%al
  80083f:	74 ef                	je     800830 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	89 c3                	mov    %eax,%ebx
  800857:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085a:	eb 06                	jmp    800862 <strncmp+0x17>
		n--, p++, q++;
  80085c:	83 c0 01             	add    $0x1,%eax
  80085f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800862:	39 d8                	cmp    %ebx,%eax
  800864:	74 15                	je     80087b <strncmp+0x30>
  800866:	0f b6 08             	movzbl (%eax),%ecx
  800869:	84 c9                	test   %cl,%cl
  80086b:	74 04                	je     800871 <strncmp+0x26>
  80086d:	3a 0a                	cmp    (%edx),%cl
  80086f:	74 eb                	je     80085c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 00             	movzbl (%eax),%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
  800879:	eb 05                	jmp    800880 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800880:	5b                   	pop    %ebx
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088d:	eb 07                	jmp    800896 <strchr+0x13>
		if (*s == c)
  80088f:	38 ca                	cmp    %cl,%dl
  800891:	74 0f                	je     8008a2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800893:	83 c0 01             	add    $0x1,%eax
  800896:	0f b6 10             	movzbl (%eax),%edx
  800899:	84 d2                	test   %dl,%dl
  80089b:	75 f2                	jne    80088f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ae:	eb 03                	jmp    8008b3 <strfind+0xf>
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	74 04                	je     8008be <strfind+0x1a>
  8008ba:	84 d2                	test   %dl,%dl
  8008bc:	75 f2                	jne    8008b0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	57                   	push   %edi
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	74 36                	je     800906 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d6:	75 28                	jne    800900 <memset+0x40>
  8008d8:	f6 c1 03             	test   $0x3,%cl
  8008db:	75 23                	jne    800900 <memset+0x40>
		c &= 0xFF;
  8008dd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e1:	89 d3                	mov    %edx,%ebx
  8008e3:	c1 e3 08             	shl    $0x8,%ebx
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	c1 e6 18             	shl    $0x18,%esi
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	c1 e0 10             	shl    $0x10,%eax
  8008f0:	09 f0                	or     %esi,%eax
  8008f2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f4:	89 d8                	mov    %ebx,%eax
  8008f6:	09 d0                	or     %edx,%eax
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
  8008fb:	fc                   	cld    
  8008fc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fe:	eb 06                	jmp    800906 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800900:	8b 45 0c             	mov    0xc(%ebp),%eax
  800903:	fc                   	cld    
  800904:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800906:	89 f8                	mov    %edi,%eax
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 75 0c             	mov    0xc(%ebp),%esi
  800918:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091b:	39 c6                	cmp    %eax,%esi
  80091d:	73 35                	jae    800954 <memmove+0x47>
  80091f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800922:	39 d0                	cmp    %edx,%eax
  800924:	73 2e                	jae    800954 <memmove+0x47>
		s += n;
		d += n;
  800926:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800929:	89 d6                	mov    %edx,%esi
  80092b:	09 fe                	or     %edi,%esi
  80092d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800933:	75 13                	jne    800948 <memmove+0x3b>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 0e                	jne    800948 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093a:	83 ef 04             	sub    $0x4,%edi
  80093d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800940:	c1 e9 02             	shr    $0x2,%ecx
  800943:	fd                   	std    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 09                	jmp    800951 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800948:	83 ef 01             	sub    $0x1,%edi
  80094b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094e:	fd                   	std    
  80094f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800951:	fc                   	cld    
  800952:	eb 1d                	jmp    800971 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800954:	89 f2                	mov    %esi,%edx
  800956:	09 c2                	or     %eax,%edx
  800958:	f6 c2 03             	test   $0x3,%dl
  80095b:	75 0f                	jne    80096c <memmove+0x5f>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 0a                	jne    80096c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800962:	c1 e9 02             	shr    $0x2,%ecx
  800965:	89 c7                	mov    %eax,%edi
  800967:	fc                   	cld    
  800968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096a:	eb 05                	jmp    800971 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096c:	89 c7                	mov    %eax,%edi
  80096e:	fc                   	cld    
  80096f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800978:	ff 75 10             	pushl  0x10(%ebp)
  80097b:	ff 75 0c             	pushl  0xc(%ebp)
  80097e:	ff 75 08             	pushl  0x8(%ebp)
  800981:	e8 87 ff ff ff       	call   80090d <memmove>
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
  800993:	89 c6                	mov    %eax,%esi
  800995:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800998:	eb 1a                	jmp    8009b4 <memcmp+0x2c>
		if (*s1 != *s2)
  80099a:	0f b6 08             	movzbl (%eax),%ecx
  80099d:	0f b6 1a             	movzbl (%edx),%ebx
  8009a0:	38 d9                	cmp    %bl,%cl
  8009a2:	74 0a                	je     8009ae <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a4:	0f b6 c1             	movzbl %cl,%eax
  8009a7:	0f b6 db             	movzbl %bl,%ebx
  8009aa:	29 d8                	sub    %ebx,%eax
  8009ac:	eb 0f                	jmp    8009bd <memcmp+0x35>
		s1++, s2++;
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b4:	39 f0                	cmp    %esi,%eax
  8009b6:	75 e2                	jne    80099a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	53                   	push   %ebx
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c8:	89 c1                	mov    %eax,%ecx
  8009ca:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d1:	eb 0a                	jmp    8009dd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d3:	0f b6 10             	movzbl (%eax),%edx
  8009d6:	39 da                	cmp    %ebx,%edx
  8009d8:	74 07                	je     8009e1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	39 c8                	cmp    %ecx,%eax
  8009df:	72 f2                	jb     8009d3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	eb 03                	jmp    8009f5 <strtol+0x11>
		s++;
  8009f2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f5:	0f b6 01             	movzbl (%ecx),%eax
  8009f8:	3c 20                	cmp    $0x20,%al
  8009fa:	74 f6                	je     8009f2 <strtol+0xe>
  8009fc:	3c 09                	cmp    $0x9,%al
  8009fe:	74 f2                	je     8009f2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a00:	3c 2b                	cmp    $0x2b,%al
  800a02:	75 0a                	jne    800a0e <strtol+0x2a>
		s++;
  800a04:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a07:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0c:	eb 11                	jmp    800a1f <strtol+0x3b>
  800a0e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a13:	3c 2d                	cmp    $0x2d,%al
  800a15:	75 08                	jne    800a1f <strtol+0x3b>
		s++, neg = 1;
  800a17:	83 c1 01             	add    $0x1,%ecx
  800a1a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a25:	75 15                	jne    800a3c <strtol+0x58>
  800a27:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2a:	75 10                	jne    800a3c <strtol+0x58>
  800a2c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a30:	75 7c                	jne    800aae <strtol+0xca>
		s += 2, base = 16;
  800a32:	83 c1 02             	add    $0x2,%ecx
  800a35:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3a:	eb 16                	jmp    800a52 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	75 12                	jne    800a52 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a40:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	75 08                	jne    800a52 <strtol+0x6e>
		s++, base = 8;
  800a4a:	83 c1 01             	add    $0x1,%ecx
  800a4d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5a:	0f b6 11             	movzbl (%ecx),%edx
  800a5d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a60:	89 f3                	mov    %esi,%ebx
  800a62:	80 fb 09             	cmp    $0x9,%bl
  800a65:	77 08                	ja     800a6f <strtol+0x8b>
			dig = *s - '0';
  800a67:	0f be d2             	movsbl %dl,%edx
  800a6a:	83 ea 30             	sub    $0x30,%edx
  800a6d:	eb 22                	jmp    800a91 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a72:	89 f3                	mov    %esi,%ebx
  800a74:	80 fb 19             	cmp    $0x19,%bl
  800a77:	77 08                	ja     800a81 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a79:	0f be d2             	movsbl %dl,%edx
  800a7c:	83 ea 57             	sub    $0x57,%edx
  800a7f:	eb 10                	jmp    800a91 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a81:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a84:	89 f3                	mov    %esi,%ebx
  800a86:	80 fb 19             	cmp    $0x19,%bl
  800a89:	77 16                	ja     800aa1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8b:	0f be d2             	movsbl %dl,%edx
  800a8e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a91:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a94:	7d 0b                	jge    800aa1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a96:	83 c1 01             	add    $0x1,%ecx
  800a99:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9f:	eb b9                	jmp    800a5a <strtol+0x76>

	if (endptr)
  800aa1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa5:	74 0d                	je     800ab4 <strtol+0xd0>
		*endptr = (char *) s;
  800aa7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaa:	89 0e                	mov    %ecx,(%esi)
  800aac:	eb 06                	jmp    800ab4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aae:	85 db                	test   %ebx,%ebx
  800ab0:	74 98                	je     800a4a <strtol+0x66>
  800ab2:	eb 9e                	jmp    800a52 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab4:	89 c2                	mov    %eax,%edx
  800ab6:	f7 da                	neg    %edx
  800ab8:	85 ff                	test   %edi,%edi
  800aba:	0f 45 c2             	cmovne %edx,%eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	89 c7                	mov    %eax,%edi
  800ad7:	89 c6                	mov    %eax,%esi
  800ad9:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	b8 01 00 00 00       	mov    $0x1,%eax
  800af0:	89 d1                	mov    %edx,%ecx
  800af2:	89 d3                	mov    %edx,%ebx
  800af4:	89 d7                	mov    %edx,%edi
  800af6:	89 d6                	mov    %edx,%esi
  800af8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	89 cb                	mov    %ecx,%ebx
  800b17:	89 cf                	mov    %ecx,%edi
  800b19:	89 ce                	mov    %ecx,%esi
  800b1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	7e 17                	jle    800b38 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	50                   	push   %eax
  800b25:	6a 03                	push   $0x3
  800b27:	68 84 16 80 00       	push   $0x801684
  800b2c:	6a 23                	push   $0x23
  800b2e:	68 a1 16 80 00       	push   $0x8016a1
  800b33:	e8 6a 04 00 00       	call   800fa2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b4b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b50:	89 d1                	mov    %edx,%ecx
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	89 d7                	mov    %edx,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_yield>:

void
sys_yield(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b87:	be 00 00 00 00       	mov    $0x0,%esi
  800b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9a:	89 f7                	mov    %esi,%edi
  800b9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 04                	push   $0x4
  800ba8:	68 84 16 80 00       	push   $0x801684
  800bad:	6a 23                	push   $0x23
  800baf:	68 a1 16 80 00       	push   $0x8016a1
  800bb4:	e8 e9 03 00 00       	call   800fa2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 05                	push   $0x5
  800bea:	68 84 16 80 00       	push   $0x801684
  800bef:	6a 23                	push   $0x23
  800bf1:	68 a1 16 80 00       	push   $0x8016a1
  800bf6:	e8 a7 03 00 00       	call   800fa2 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 06 00 00 00       	mov    $0x6,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 06                	push   $0x6
  800c2c:	68 84 16 80 00       	push   $0x801684
  800c31:	6a 23                	push   $0x23
  800c33:	68 a1 16 80 00       	push   $0x8016a1
  800c38:	e8 65 03 00 00       	call   800fa2 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 08 00 00 00       	mov    $0x8,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 08                	push   $0x8
  800c6e:	68 84 16 80 00       	push   $0x801684
  800c73:	6a 23                	push   $0x23
  800c75:	68 a1 16 80 00       	push   $0x8016a1
  800c7a:	e8 23 03 00 00       	call   800fa2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 09                	push   $0x9
  800cb0:	68 84 16 80 00       	push   $0x801684
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 a1 16 80 00       	push   $0x8016a1
  800cbc:	e8 e1 02 00 00       	call   800fa2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 0c                	push   $0xc
  800d14:	68 84 16 80 00       	push   $0x801684
  800d19:	6a 23                	push   $0x23
  800d1b:	68 a1 16 80 00       	push   $0x8016a1
  800d20:	e8 7d 02 00 00       	call   800fa2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	53                   	push   %ebx
  800d31:	83 ec 04             	sub    $0x4,%esp
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d37:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800d39:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d3d:	74 2d                	je     800d6c <pgfault+0x3f>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800d3f:	89 d8                	mov    %ebx,%eax
  800d41:	c1 e8 16             	shr    $0x16,%eax
  800d44:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
  800d4b:	a8 01                	test   $0x1,%al
  800d4d:	74 1d                	je     800d6c <pgfault+0x3f>
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
  800d4f:	89 d8                	mov    %ebx,%eax
  800d51:	c1 e8 0c             	shr    $0xc,%eax
  800d54:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800d5b:	f6 c2 01             	test   $0x1,%dl
  800d5e:	74 0c                	je     800d6c <pgfault+0x3f>
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800d60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800d67:	f6 c4 08             	test   $0x8,%ah
  800d6a:	75 14                	jne    800d80 <pgfault+0x53>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	68 af 16 80 00       	push   $0x8016af
  800d74:	6a 22                	push   $0x22
  800d76:	68 c5 16 80 00       	push   $0x8016c5
  800d7b:	e8 22 02 00 00       	call   800fa2 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	cprintf("in pgfault.\n");
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	68 d0 16 80 00       	push   $0x8016d0
  800d88:	e8 1f f4 ff ff       	call   8001ac <cprintf>
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800d8d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800d93:	83 c4 0c             	add    $0xc,%esp
  800d96:	6a 07                	push   $0x7
  800d98:	68 00 f0 7f 00       	push   $0x7ff000
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 da fd ff ff       	call   800b7e <sys_page_alloc>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	79 14                	jns    800dbf <pgfault+0x92>
		panic("sys_page_alloc");
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	68 dd 16 80 00       	push   $0x8016dd
  800db3:	6a 30                	push   $0x30
  800db5:	68 c5 16 80 00       	push   $0x8016c5
  800dba:	e8 e3 01 00 00       	call   800fa2 <_panic>
	}
	memcpy(PFTEMP, addr, PGSIZE);
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	68 00 10 00 00       	push   $0x1000
  800dc7:	53                   	push   %ebx
  800dc8:	68 00 f0 7f 00       	push   $0x7ff000
  800dcd:	e8 a3 fb ff ff       	call   800975 <memcpy>
	
	retv = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P);
  800dd2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dd9:	53                   	push   %ebx
  800dda:	6a 00                	push   $0x0
  800ddc:	68 00 f0 7f 00       	push   $0x7ff000
  800de1:	6a 00                	push   $0x0
  800de3:	e8 d9 fd ff ff       	call   800bc1 <sys_page_map>
	if(retv < 0){
  800de8:	83 c4 20             	add    $0x20,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	79 14                	jns    800e03 <pgfault+0xd6>
		panic("sys_page_map");
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	68 ec 16 80 00       	push   $0x8016ec
  800df7:	6a 36                	push   $0x36
  800df9:	68 c5 16 80 00       	push   $0x8016c5
  800dfe:	e8 9f 01 00 00       	call   800fa2 <_panic>
	}
	cprintf("out of pgfault.\n");
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	68 f9 16 80 00       	push   $0x8016f9
  800e0b:	e8 9c f3 ff ff       	call   8001ac <cprintf>
	return;
  800e10:	83 c4 10             	add    $0x10,%esp
	panic("pgfault not implemented");
}
  800e13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e16:	c9                   	leave  
  800e17:	c3                   	ret    

00800e18 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 18             	sub    $0x18,%esp
	cprintf("\t\t we are in the fork().\n");
  800e21:	68 0a 17 80 00       	push   $0x80170a
  800e26:	e8 81 f3 ff ff       	call   8001ac <cprintf>
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800e2b:	c7 04 24 2d 0d 80 00 	movl   $0x800d2d,(%esp)
  800e32:	e8 b1 01 00 00       	call   800fe8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e37:	b8 07 00 00 00       	mov    $0x7,%eax
  800e3c:	cd 30                	int    $0x30
  800e3e:	89 c6                	mov    %eax,%esi
	//create a child
	child_envid = sys_exofork();
	if(child_envid < 0 ){
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	79 17                	jns    800e63 <fork+0x4b>
		panic("sys_exofork failed.");
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	68 24 17 80 00       	push   $0x801724
  800e54:	68 82 00 00 00       	push   $0x82
  800e59:	68 c5 16 80 00       	push   $0x8016c5
  800e5e:	e8 3f 01 00 00       	call   800fa2 <_panic>
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800e63:	89 d8                	mov    %ebx,%eax
  800e65:	c1 e8 16             	shr    $0x16,%eax
  800e68:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800e6f:	a8 01                	test   $0x1,%al
  800e71:	0f 84 e8 00 00 00    	je     800f5f <fork+0x147>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800e77:	89 d8                	mov    %ebx,%eax
  800e79:	c1 e8 0c             	shr    $0xc,%eax
  800e7c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800e83:	f6 c2 01             	test   $0x1,%dl
  800e86:	0f 84 d3 00 00 00    	je     800f5f <fork+0x147>
			(uvpt[PGNUM(addr)] & PTE_P)&& 
			(uvpt[PGNUM(addr)] & PTE_U)
  800e8c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800e93:	f6 c2 04             	test   $0x4,%dl
  800e96:	0f 84 c3 00 00 00    	je     800f5f <fork+0x147>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;

	// LAB 4: Your code here.
	void *addr = (void*)(pn*PGSIZE);
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	c1 e7 0c             	shl    $0xc,%edi
	if( (uvpt[pn] & PTE_W)||(uvpt[pn]) & PTE_COW ){
  800ea1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea8:	f6 c2 02             	test   $0x2,%dl
  800eab:	75 10                	jne    800ebd <fork+0xa5>
  800ead:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb4:	f6 c4 08             	test   $0x8,%ah
  800eb7:	0f 84 90 00 00 00    	je     800f4d <fork+0x135>
		cprintf("!!start page map.\n");	
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	68 38 17 80 00       	push   $0x801738
  800ec5:	e8 e2 f2 ff ff       	call   8001ac <cprintf>
		r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_P|PTE_U);
  800eca:	c7 04 24 05 08 00 00 	movl   $0x805,(%esp)
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	57                   	push   %edi
  800ed4:	6a 00                	push   $0x0
  800ed6:	e8 e6 fc ff ff       	call   800bc1 <sys_page_map>
		if(r<0){
  800edb:	83 c4 20             	add    $0x20,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	79 22                	jns    800f04 <fork+0xec>
			cprintf("sys_page_map failed :%d\n",r);
  800ee2:	83 ec 08             	sub    $0x8,%esp
  800ee5:	50                   	push   %eax
  800ee6:	68 4b 17 80 00       	push   $0x80174b
  800eeb:	e8 bc f2 ff ff       	call   8001ac <cprintf>
			panic("map env id 0 to child_envid failed.");
  800ef0:	83 c4 0c             	add    $0xc,%esp
  800ef3:	68 b4 17 80 00       	push   $0x8017b4
  800ef8:	6a 54                	push   $0x54
  800efa:	68 c5 16 80 00       	push   $0x8016c5
  800eff:	e8 9e 00 00 00       	call   800fa2 <_panic>
		
		}
		cprintf("mapping addr is:%x\n",addr);
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	57                   	push   %edi
  800f08:	68 64 17 80 00       	push   $0x801764
  800f0d:	e8 9a f2 ff ff       	call   8001ac <cprintf>
		r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_P|PTE_U);
  800f12:	c7 04 24 05 08 00 00 	movl   $0x805,(%esp)
  800f19:	57                   	push   %edi
  800f1a:	6a 00                	push   $0x0
  800f1c:	57                   	push   %edi
  800f1d:	6a 00                	push   $0x0
  800f1f:	e8 9d fc ff ff       	call   800bc1 <sys_page_map>
//		cprintf("!!end sys_page_map 0.\n");
		if(r<0){
  800f24:	83 c4 20             	add    $0x20,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	79 34                	jns    800f5f <fork+0x147>
			cprintf("sys_page_map failed :%d\n",r);
  800f2b:	83 ec 08             	sub    $0x8,%esp
  800f2e:	50                   	push   %eax
  800f2f:	68 4b 17 80 00       	push   $0x80174b
  800f34:	e8 73 f2 ff ff       	call   8001ac <cprintf>
			panic("map env id 0 to 0");
  800f39:	83 c4 0c             	add    $0xc,%esp
  800f3c:	68 78 17 80 00       	push   $0x801778
  800f41:	6a 5c                	push   $0x5c
  800f43:	68 c5 16 80 00       	push   $0x8016c5
  800f48:	e8 55 00 00 00       	call   800fa2 <_panic>
		}//?we should mark PTE_COW both to two id.
//		cprintf("!!end page map.\n");	
	}else{
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	6a 05                	push   $0x5
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	57                   	push   %edi
  800f55:	6a 00                	push   $0x0
  800f57:	e8 65 fc ff ff       	call   800bc1 <sys_page_map>
  800f5c:	83 c4 20             	add    $0x20,%esp
	if(child_envid < 0 ){
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800f5f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f65:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f6b:	0f 85 f2 fe ff ff    	jne    800e63 <fork+0x4b>
			(uvpt[PGNUM(addr)] & PTE_U)
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	panic("failed at duppage.");
  800f71:	83 ec 04             	sub    $0x4,%esp
  800f74:	68 8a 17 80 00       	push   $0x80178a
  800f79:	68 8f 00 00 00       	push   $0x8f
  800f7e:	68 c5 16 80 00       	push   $0x8016c5
  800f83:	e8 1a 00 00 00       	call   800fa2 <_panic>

00800f88 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f8e:	68 9d 17 80 00       	push   $0x80179d
  800f93:	68 a4 00 00 00       	push   $0xa4
  800f98:	68 c5 16 80 00       	push   $0x8016c5
  800f9d:	e8 00 00 00 00       	call   800fa2 <_panic>

00800fa2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fa7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800faa:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fb0:	e8 8b fb ff ff       	call   800b40 <sys_getenvid>
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	ff 75 0c             	pushl  0xc(%ebp)
  800fbb:	ff 75 08             	pushl  0x8(%ebp)
  800fbe:	56                   	push   %esi
  800fbf:	50                   	push   %eax
  800fc0:	68 d8 17 80 00       	push   $0x8017d8
  800fc5:	e8 e2 f1 ff ff       	call   8001ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fca:	83 c4 18             	add    $0x18,%esp
  800fcd:	53                   	push   %ebx
  800fce:	ff 75 10             	pushl  0x10(%ebp)
  800fd1:	e8 85 f1 ff ff       	call   80015b <vcprintf>
	cprintf("\n");
  800fd6:	c7 04 24 0e 14 80 00 	movl   $0x80140e,(%esp)
  800fdd:	e8 ca f1 ff ff       	call   8001ac <cprintf>
  800fe2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fe5:	cc                   	int3   
  800fe6:	eb fd                	jmp    800fe5 <_panic+0x43>

00800fe8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  800fee:	68 fc 17 80 00       	push   $0x8017fc
  800ff3:	e8 b4 f1 ff ff       	call   8001ac <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801002:	0f 85 8d 00 00 00    	jne    801095 <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	68 1c 18 80 00       	push   $0x80181c
  801010:	e8 97 f1 ff ff       	call   8001ac <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801015:	a1 04 20 80 00       	mov    0x802004,%eax
  80101a:	8b 40 48             	mov    0x48(%eax),%eax
  80101d:	83 c4 0c             	add    $0xc,%esp
  801020:	6a 07                	push   $0x7
  801022:	68 00 f0 bf ee       	push   $0xeebff000
  801027:	50                   	push   %eax
  801028:	e8 51 fb ff ff       	call   800b7e <sys_page_alloc>
		if(retv != 0){
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	74 14                	je     801048 <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  801034:	83 ec 04             	sub    $0x4,%esp
  801037:	68 40 18 80 00       	push   $0x801840
  80103c:	6a 27                	push   $0x27
  80103e:	68 94 18 80 00       	push   $0x801894
  801043:	e8 5a ff ff ff       	call   800fa2 <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  801048:	83 ec 08             	sub    $0x8,%esp
  80104b:	68 af 10 80 00       	push   $0x8010af
  801050:	68 a2 18 80 00       	push   $0x8018a2
  801055:	e8 52 f1 ff ff       	call   8001ac <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  80105a:	a1 04 20 80 00       	mov    0x802004,%eax
  80105f:	8b 40 48             	mov    0x48(%eax),%eax
  801062:	83 c4 08             	add    $0x8,%esp
  801065:	50                   	push   %eax
  801066:	68 bd 18 80 00       	push   $0x8018bd
  80106b:	e8 3c f1 ff ff       	call   8001ac <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801070:	a1 04 20 80 00       	mov    0x802004,%eax
  801075:	8b 40 48             	mov    0x48(%eax),%eax
  801078:	83 c4 08             	add    $0x8,%esp
  80107b:	68 af 10 80 00       	push   $0x8010af
  801080:	50                   	push   %eax
  801081:	e8 01 fc ff ff       	call   800c87 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  801086:	c7 04 24 d4 18 80 00 	movl   $0x8018d4,(%esp)
  80108d:	e8 1a f1 ff ff       	call   8001ac <cprintf>
  801092:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	68 6c 18 80 00       	push   $0x80186c
  80109d:	e8 0a f1 ff ff       	call   8001ac <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	a3 08 20 80 00       	mov    %eax,0x802008

}
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010af:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010b0:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8010b5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010b7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  8010ba:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  8010bc:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  8010c0:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8010c4:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  8010c5:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  8010c7:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  8010ce:	00 
	popl %eax
  8010cf:	58                   	pop    %eax
	popl %eax
  8010d0:	58                   	pop    %eax
	popal
  8010d1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  8010d2:	83 c4 04             	add    $0x4,%esp
	popfl
  8010d5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010d6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010d7:	c3                   	ret    
  8010d8:	66 90                	xchg   %ax,%ax
  8010da:	66 90                	xchg   %ax,%ax
  8010dc:	66 90                	xchg   %ax,%ax
  8010de:	66 90                	xchg   %ax,%ax

008010e0 <__udivdi3>:
  8010e0:	55                   	push   %ebp
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 1c             	sub    $0x1c,%esp
  8010e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8010eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8010ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8010f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010f7:	85 f6                	test   %esi,%esi
  8010f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010fd:	89 ca                	mov    %ecx,%edx
  8010ff:	89 f8                	mov    %edi,%eax
  801101:	75 3d                	jne    801140 <__udivdi3+0x60>
  801103:	39 cf                	cmp    %ecx,%edi
  801105:	0f 87 c5 00 00 00    	ja     8011d0 <__udivdi3+0xf0>
  80110b:	85 ff                	test   %edi,%edi
  80110d:	89 fd                	mov    %edi,%ebp
  80110f:	75 0b                	jne    80111c <__udivdi3+0x3c>
  801111:	b8 01 00 00 00       	mov    $0x1,%eax
  801116:	31 d2                	xor    %edx,%edx
  801118:	f7 f7                	div    %edi
  80111a:	89 c5                	mov    %eax,%ebp
  80111c:	89 c8                	mov    %ecx,%eax
  80111e:	31 d2                	xor    %edx,%edx
  801120:	f7 f5                	div    %ebp
  801122:	89 c1                	mov    %eax,%ecx
  801124:	89 d8                	mov    %ebx,%eax
  801126:	89 cf                	mov    %ecx,%edi
  801128:	f7 f5                	div    %ebp
  80112a:	89 c3                	mov    %eax,%ebx
  80112c:	89 d8                	mov    %ebx,%eax
  80112e:	89 fa                	mov    %edi,%edx
  801130:	83 c4 1c             	add    $0x1c,%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    
  801138:	90                   	nop
  801139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801140:	39 ce                	cmp    %ecx,%esi
  801142:	77 74                	ja     8011b8 <__udivdi3+0xd8>
  801144:	0f bd fe             	bsr    %esi,%edi
  801147:	83 f7 1f             	xor    $0x1f,%edi
  80114a:	0f 84 98 00 00 00    	je     8011e8 <__udivdi3+0x108>
  801150:	bb 20 00 00 00       	mov    $0x20,%ebx
  801155:	89 f9                	mov    %edi,%ecx
  801157:	89 c5                	mov    %eax,%ebp
  801159:	29 fb                	sub    %edi,%ebx
  80115b:	d3 e6                	shl    %cl,%esi
  80115d:	89 d9                	mov    %ebx,%ecx
  80115f:	d3 ed                	shr    %cl,%ebp
  801161:	89 f9                	mov    %edi,%ecx
  801163:	d3 e0                	shl    %cl,%eax
  801165:	09 ee                	or     %ebp,%esi
  801167:	89 d9                	mov    %ebx,%ecx
  801169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116d:	89 d5                	mov    %edx,%ebp
  80116f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801173:	d3 ed                	shr    %cl,%ebp
  801175:	89 f9                	mov    %edi,%ecx
  801177:	d3 e2                	shl    %cl,%edx
  801179:	89 d9                	mov    %ebx,%ecx
  80117b:	d3 e8                	shr    %cl,%eax
  80117d:	09 c2                	or     %eax,%edx
  80117f:	89 d0                	mov    %edx,%eax
  801181:	89 ea                	mov    %ebp,%edx
  801183:	f7 f6                	div    %esi
  801185:	89 d5                	mov    %edx,%ebp
  801187:	89 c3                	mov    %eax,%ebx
  801189:	f7 64 24 0c          	mull   0xc(%esp)
  80118d:	39 d5                	cmp    %edx,%ebp
  80118f:	72 10                	jb     8011a1 <__udivdi3+0xc1>
  801191:	8b 74 24 08          	mov    0x8(%esp),%esi
  801195:	89 f9                	mov    %edi,%ecx
  801197:	d3 e6                	shl    %cl,%esi
  801199:	39 c6                	cmp    %eax,%esi
  80119b:	73 07                	jae    8011a4 <__udivdi3+0xc4>
  80119d:	39 d5                	cmp    %edx,%ebp
  80119f:	75 03                	jne    8011a4 <__udivdi3+0xc4>
  8011a1:	83 eb 01             	sub    $0x1,%ebx
  8011a4:	31 ff                	xor    %edi,%edi
  8011a6:	89 d8                	mov    %ebx,%eax
  8011a8:	89 fa                	mov    %edi,%edx
  8011aa:	83 c4 1c             	add    $0x1c,%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    
  8011b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b8:	31 ff                	xor    %edi,%edi
  8011ba:	31 db                	xor    %ebx,%ebx
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	89 fa                	mov    %edi,%edx
  8011c0:	83 c4 1c             	add    $0x1c,%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    
  8011c8:	90                   	nop
  8011c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	89 d8                	mov    %ebx,%eax
  8011d2:	f7 f7                	div    %edi
  8011d4:	31 ff                	xor    %edi,%edi
  8011d6:	89 c3                	mov    %eax,%ebx
  8011d8:	89 d8                	mov    %ebx,%eax
  8011da:	89 fa                	mov    %edi,%edx
  8011dc:	83 c4 1c             	add    $0x1c,%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    
  8011e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	39 ce                	cmp    %ecx,%esi
  8011ea:	72 0c                	jb     8011f8 <__udivdi3+0x118>
  8011ec:	31 db                	xor    %ebx,%ebx
  8011ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8011f2:	0f 87 34 ff ff ff    	ja     80112c <__udivdi3+0x4c>
  8011f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8011fd:	e9 2a ff ff ff       	jmp    80112c <__udivdi3+0x4c>
  801202:	66 90                	xchg   %ax,%ax
  801204:	66 90                	xchg   %ax,%ax
  801206:	66 90                	xchg   %ax,%ax
  801208:	66 90                	xchg   %ax,%ax
  80120a:	66 90                	xchg   %ax,%ax
  80120c:	66 90                	xchg   %ax,%ax
  80120e:	66 90                	xchg   %ax,%ax

00801210 <__umoddi3>:
  801210:	55                   	push   %ebp
  801211:	57                   	push   %edi
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	83 ec 1c             	sub    $0x1c,%esp
  801217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80121b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80121f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801227:	85 d2                	test   %edx,%edx
  801229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80122d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801231:	89 f3                	mov    %esi,%ebx
  801233:	89 3c 24             	mov    %edi,(%esp)
  801236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80123a:	75 1c                	jne    801258 <__umoddi3+0x48>
  80123c:	39 f7                	cmp    %esi,%edi
  80123e:	76 50                	jbe    801290 <__umoddi3+0x80>
  801240:	89 c8                	mov    %ecx,%eax
  801242:	89 f2                	mov    %esi,%edx
  801244:	f7 f7                	div    %edi
  801246:	89 d0                	mov    %edx,%eax
  801248:	31 d2                	xor    %edx,%edx
  80124a:	83 c4 1c             	add    $0x1c,%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    
  801252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801258:	39 f2                	cmp    %esi,%edx
  80125a:	89 d0                	mov    %edx,%eax
  80125c:	77 52                	ja     8012b0 <__umoddi3+0xa0>
  80125e:	0f bd ea             	bsr    %edx,%ebp
  801261:	83 f5 1f             	xor    $0x1f,%ebp
  801264:	75 5a                	jne    8012c0 <__umoddi3+0xb0>
  801266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80126a:	0f 82 e0 00 00 00    	jb     801350 <__umoddi3+0x140>
  801270:	39 0c 24             	cmp    %ecx,(%esp)
  801273:	0f 86 d7 00 00 00    	jbe    801350 <__umoddi3+0x140>
  801279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80127d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801281:	83 c4 1c             	add    $0x1c,%esp
  801284:	5b                   	pop    %ebx
  801285:	5e                   	pop    %esi
  801286:	5f                   	pop    %edi
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    
  801289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801290:	85 ff                	test   %edi,%edi
  801292:	89 fd                	mov    %edi,%ebp
  801294:	75 0b                	jne    8012a1 <__umoddi3+0x91>
  801296:	b8 01 00 00 00       	mov    $0x1,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	f7 f7                	div    %edi
  80129f:	89 c5                	mov    %eax,%ebp
  8012a1:	89 f0                	mov    %esi,%eax
  8012a3:	31 d2                	xor    %edx,%edx
  8012a5:	f7 f5                	div    %ebp
  8012a7:	89 c8                	mov    %ecx,%eax
  8012a9:	f7 f5                	div    %ebp
  8012ab:	89 d0                	mov    %edx,%eax
  8012ad:	eb 99                	jmp    801248 <__umoddi3+0x38>
  8012af:	90                   	nop
  8012b0:	89 c8                	mov    %ecx,%eax
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	83 c4 1c             	add    $0x1c,%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5f                   	pop    %edi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    
  8012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	8b 34 24             	mov    (%esp),%esi
  8012c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8012c8:	89 e9                	mov    %ebp,%ecx
  8012ca:	29 ef                	sub    %ebp,%edi
  8012cc:	d3 e0                	shl    %cl,%eax
  8012ce:	89 f9                	mov    %edi,%ecx
  8012d0:	89 f2                	mov    %esi,%edx
  8012d2:	d3 ea                	shr    %cl,%edx
  8012d4:	89 e9                	mov    %ebp,%ecx
  8012d6:	09 c2                	or     %eax,%edx
  8012d8:	89 d8                	mov    %ebx,%eax
  8012da:	89 14 24             	mov    %edx,(%esp)
  8012dd:	89 f2                	mov    %esi,%edx
  8012df:	d3 e2                	shl    %cl,%edx
  8012e1:	89 f9                	mov    %edi,%ecx
  8012e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012eb:	d3 e8                	shr    %cl,%eax
  8012ed:	89 e9                	mov    %ebp,%ecx
  8012ef:	89 c6                	mov    %eax,%esi
  8012f1:	d3 e3                	shl    %cl,%ebx
  8012f3:	89 f9                	mov    %edi,%ecx
  8012f5:	89 d0                	mov    %edx,%eax
  8012f7:	d3 e8                	shr    %cl,%eax
  8012f9:	89 e9                	mov    %ebp,%ecx
  8012fb:	09 d8                	or     %ebx,%eax
  8012fd:	89 d3                	mov    %edx,%ebx
  8012ff:	89 f2                	mov    %esi,%edx
  801301:	f7 34 24             	divl   (%esp)
  801304:	89 d6                	mov    %edx,%esi
  801306:	d3 e3                	shl    %cl,%ebx
  801308:	f7 64 24 04          	mull   0x4(%esp)
  80130c:	39 d6                	cmp    %edx,%esi
  80130e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801312:	89 d1                	mov    %edx,%ecx
  801314:	89 c3                	mov    %eax,%ebx
  801316:	72 08                	jb     801320 <__umoddi3+0x110>
  801318:	75 11                	jne    80132b <__umoddi3+0x11b>
  80131a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80131e:	73 0b                	jae    80132b <__umoddi3+0x11b>
  801320:	2b 44 24 04          	sub    0x4(%esp),%eax
  801324:	1b 14 24             	sbb    (%esp),%edx
  801327:	89 d1                	mov    %edx,%ecx
  801329:	89 c3                	mov    %eax,%ebx
  80132b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80132f:	29 da                	sub    %ebx,%edx
  801331:	19 ce                	sbb    %ecx,%esi
  801333:	89 f9                	mov    %edi,%ecx
  801335:	89 f0                	mov    %esi,%eax
  801337:	d3 e0                	shl    %cl,%eax
  801339:	89 e9                	mov    %ebp,%ecx
  80133b:	d3 ea                	shr    %cl,%edx
  80133d:	89 e9                	mov    %ebp,%ecx
  80133f:	d3 ee                	shr    %cl,%esi
  801341:	09 d0                	or     %edx,%eax
  801343:	89 f2                	mov    %esi,%edx
  801345:	83 c4 1c             	add    $0x1c,%esp
  801348:	5b                   	pop    %ebx
  801349:	5e                   	pop    %esi
  80134a:	5f                   	pop    %edi
  80134b:	5d                   	pop    %ebp
  80134c:	c3                   	ret    
  80134d:	8d 76 00             	lea    0x0(%esi),%esi
  801350:	29 f9                	sub    %edi,%ecx
  801352:	19 d6                	sbb    %edx,%esi
  801354:	89 74 24 04          	mov    %esi,0x4(%esp)
  801358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135c:	e9 18 ff ff ff       	jmp    801279 <__umoddi3+0x69>
