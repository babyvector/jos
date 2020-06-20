
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 3e 0b 00 00       	call   800b80 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 c0 22 80 00       	push   $0x8022c0
  80004c:	e8 9b 01 00 00       	call   8001ec <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 ff 06 00 00       	call   800782 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 52                	jg     8000dd <forkchild+0x6e>
		return;
	cprintf("\t at forkchild.\n");
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	68 d1 22 80 00       	push   $0x8022d1
  800093:	e8 54 01 00 00       	call   8001ec <cprintf>
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800098:	89 f0                	mov    %esi,%eax
  80009a:	0f be f0             	movsbl %al,%esi
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	53                   	push   %ebx
  8000a1:	68 e2 22 80 00       	push   $0x8022e2
  8000a6:	6a 04                	push   $0x4
  8000a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ab:	50                   	push   %eax
  8000ac:	e8 b7 06 00 00       	call   800768 <snprintf>
	if (fork() == 0) {
  8000b1:	83 c4 20             	add    $0x20,%esp
  8000b4:	e8 ae 0e 00 00       	call   800f67 <fork>
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	75 20                	jne    8000dd <forkchild+0x6e>
		cprintf("\t fork() == 0");
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	68 e7 22 80 00       	push   $0x8022e7
  8000c5:	e8 22 01 00 00       	call   8001ec <cprintf>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5e ff ff ff       	call   800033 <forktree>
		exit();
  8000d5:	e8 65 00 00 00       	call   80013f <exit>
  8000da:	83 c4 10             	add    $0x10,%esp
	}
}
  8000dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000ea:	68 d0 22 80 00       	push   $0x8022d0
  8000ef:	e8 3f ff ff ff       	call   800033 <forktree>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800101:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800104:	e8 77 0a 00 00       	call   800b80 <sys_getenvid>
  800109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011b:	85 db                	test   %ebx,%ebx
  80011d:	7e 07                	jle    800126 <libmain+0x2d>
		binaryname = argv[0];
  80011f:	8b 06                	mov    (%esi),%eax
  800121:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	e8 b4 ff ff ff       	call   8000e4 <umain>

	// exit gracefully
	exit();
  800130:	e8 0a 00 00 00       	call   80013f <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800145:	e8 dd 11 00 00       	call   801327 <close_all>
	sys_env_destroy(0);
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	6a 00                	push   $0x0
  80014f:	e8 eb 09 00 00       	call   800b3f <sys_env_destroy>
}
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	53                   	push   %ebx
  80015d:	83 ec 04             	sub    $0x4,%esp
  800160:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800163:	8b 13                	mov    (%ebx),%edx
  800165:	8d 42 01             	lea    0x1(%edx),%eax
  800168:	89 03                	mov    %eax,(%ebx)
  80016a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800171:	3d ff 00 00 00       	cmp    $0xff,%eax
  800176:	75 1a                	jne    800192 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800178:	83 ec 08             	sub    $0x8,%esp
  80017b:	68 ff 00 00 00       	push   $0xff
  800180:	8d 43 08             	lea    0x8(%ebx),%eax
  800183:	50                   	push   %eax
  800184:	e8 79 09 00 00       	call   800b02 <sys_cputs>
		b->idx = 0;
  800189:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800192:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c4:	50                   	push   %eax
  8001c5:	68 59 01 80 00       	push   $0x800159
  8001ca:	e8 54 01 00 00       	call   800323 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cf:	83 c4 08             	add    $0x8,%esp
  8001d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	e8 1e 09 00 00       	call   800b02 <sys_cputs>

	return b.cnt;
}
  8001e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f5:	50                   	push   %eax
  8001f6:	ff 75 08             	pushl  0x8(%ebp)
  8001f9:	e8 9d ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 1c             	sub    $0x1c,%esp
  800209:	89 c7                	mov    %eax,%edi
  80020b:	89 d6                	mov    %edx,%esi
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	8b 55 0c             	mov    0xc(%ebp),%edx
  800213:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800216:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800219:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800221:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800224:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800227:	39 d3                	cmp    %edx,%ebx
  800229:	72 05                	jb     800230 <printnum+0x30>
  80022b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022e:	77 45                	ja     800275 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	8b 45 14             	mov    0x14(%ebp),%eax
  800239:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023c:	53                   	push   %ebx
  80023d:	ff 75 10             	pushl  0x10(%ebp)
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	ff 75 e4             	pushl  -0x1c(%ebp)
  800246:	ff 75 e0             	pushl  -0x20(%ebp)
  800249:	ff 75 dc             	pushl  -0x24(%ebp)
  80024c:	ff 75 d8             	pushl  -0x28(%ebp)
  80024f:	e8 dc 1d 00 00       	call   802030 <__udivdi3>
  800254:	83 c4 18             	add    $0x18,%esp
  800257:	52                   	push   %edx
  800258:	50                   	push   %eax
  800259:	89 f2                	mov    %esi,%edx
  80025b:	89 f8                	mov    %edi,%eax
  80025d:	e8 9e ff ff ff       	call   800200 <printnum>
  800262:	83 c4 20             	add    $0x20,%esp
  800265:	eb 18                	jmp    80027f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	ff 75 18             	pushl  0x18(%ebp)
  80026e:	ff d7                	call   *%edi
  800270:	83 c4 10             	add    $0x10,%esp
  800273:	eb 03                	jmp    800278 <printnum+0x78>
  800275:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800278:	83 eb 01             	sub    $0x1,%ebx
  80027b:	85 db                	test   %ebx,%ebx
  80027d:	7f e8                	jg     800267 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027f:	83 ec 08             	sub    $0x8,%esp
  800282:	56                   	push   %esi
  800283:	83 ec 04             	sub    $0x4,%esp
  800286:	ff 75 e4             	pushl  -0x1c(%ebp)
  800289:	ff 75 e0             	pushl  -0x20(%ebp)
  80028c:	ff 75 dc             	pushl  -0x24(%ebp)
  80028f:	ff 75 d8             	pushl  -0x28(%ebp)
  800292:	e8 c9 1e 00 00       	call   802160 <__umoddi3>
  800297:	83 c4 14             	add    $0x14,%esp
  80029a:	0f be 80 ff 22 80 00 	movsbl 0x8022ff(%eax),%eax
  8002a1:	50                   	push   %eax
  8002a2:	ff d7                	call   *%edi
}
  8002a4:	83 c4 10             	add    $0x10,%esp
  8002a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b2:	83 fa 01             	cmp    $0x1,%edx
  8002b5:	7e 0e                	jle    8002c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	8b 52 04             	mov    0x4(%edx),%edx
  8002c3:	eb 22                	jmp    8002e7 <getuint+0x38>
	else if (lflag)
  8002c5:	85 d2                	test   %edx,%edx
  8002c7:	74 10                	je     8002d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 02                	mov    (%edx),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d7:	eb 0e                	jmp    8002e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 05 00 00 00       	call   800323 <vprintfmt>
	va_end(ap);
}
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 2c             	sub    $0x2c,%esp
  80032c:	8b 75 08             	mov    0x8(%ebp),%esi
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 7d 10             	mov    0x10(%ebp),%edi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 d3 03 00 00    	je     800712 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	53                   	push   %ebx
  800343:	50                   	push   %eax
  800344:	ff d6                	call   *%esi
  800346:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	83 c7 01             	add    $0x1,%edi
  80034c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800350:	83 f8 25             	cmp    $0x25,%eax
  800353:	75 e2                	jne    800337 <vprintfmt+0x14>
  800355:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800359:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800360:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	eb 07                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8d 47 01             	lea    0x1(%edi),%eax
  80037f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800382:	0f b6 07             	movzbl (%edi),%eax
  800385:	0f b6 c8             	movzbl %al,%ecx
  800388:	83 e8 23             	sub    $0x23,%eax
  80038b:	3c 55                	cmp    $0x55,%al
  80038d:	0f 87 64 03 00 00    	ja     8006f7 <vprintfmt+0x3d4>
  800393:	0f b6 c0             	movzbl %al,%eax
  800396:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a4:	eb d6                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003be:	83 fa 09             	cmp    $0x9,%edx
  8003c1:	77 39                	ja     8003fc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d1:	8b 00                	mov    (%eax),%eax
  8003d3:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d9:	eb 27                	jmp    800402 <vprintfmt+0xdf>
  8003db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003de:	85 c0                	test   %eax,%eax
  8003e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e5:	0f 49 c8             	cmovns %eax,%ecx
  8003e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	eb 8c                	jmp    80037c <vprintfmt+0x59>
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fa:	eb 80                	jmp    80037c <vprintfmt+0x59>
  8003fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ff:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800402:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800406:	0f 89 70 ff ff ff    	jns    80037c <vprintfmt+0x59>
				width = precision, precision = -1;
  80040c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800412:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800419:	e9 5e ff ff ff       	jmp    80037c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800424:	e9 53 ff ff ff       	jmp    80037c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 50 04             	lea    0x4(%eax),%edx
  80042f:	89 55 14             	mov    %edx,0x14(%ebp)
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	53                   	push   %ebx
  800436:	ff 30                	pushl  (%eax)
  800438:	ff d6                	call   *%esi
			break;
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800440:	e9 04 ff ff ff       	jmp    800349 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	99                   	cltd   
  800451:	31 d0                	xor    %edx,%eax
  800453:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800455:	83 f8 0f             	cmp    $0xf,%eax
  800458:	7f 0b                	jg     800465 <vprintfmt+0x142>
  80045a:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800461:	85 d2                	test   %edx,%edx
  800463:	75 18                	jne    80047d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800465:	50                   	push   %eax
  800466:	68 17 23 80 00       	push   $0x802317
  80046b:	53                   	push   %ebx
  80046c:	56                   	push   %esi
  80046d:	e8 94 fe ff ff       	call   800306 <printfmt>
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800478:	e9 cc fe ff ff       	jmp    800349 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047d:	52                   	push   %edx
  80047e:	68 49 28 80 00       	push   $0x802849
  800483:	53                   	push   %ebx
  800484:	56                   	push   %esi
  800485:	e8 7c fe ff ff       	call   800306 <printfmt>
  80048a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800490:	e9 b4 fe ff ff       	jmp    800349 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a0:	85 ff                	test   %edi,%edi
  8004a2:	b8 10 23 80 00       	mov    $0x802310,%eax
  8004a7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ae:	0f 8e 94 00 00 00    	jle    800548 <vprintfmt+0x225>
  8004b4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b8:	0f 84 98 00 00 00    	je     800556 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	ff 75 c8             	pushl  -0x38(%ebp)
  8004c4:	57                   	push   %edi
  8004c5:	e8 d0 02 00 00       	call   80079a <strnlen>
  8004ca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cd:	29 c1                	sub    %eax,%ecx
  8004cf:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004df:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	eb 0f                	jmp    8004f2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ea:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	83 ef 01             	sub    $0x1,%edi
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	7f ed                	jg     8004e3 <vprintfmt+0x1c0>
  8004f6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004fc:	85 c9                	test   %ecx,%ecx
  8004fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800503:	0f 49 c1             	cmovns %ecx,%eax
  800506:	29 c1                	sub    %eax,%ecx
  800508:	89 75 08             	mov    %esi,0x8(%ebp)
  80050b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80050e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800511:	89 cb                	mov    %ecx,%ebx
  800513:	eb 4d                	jmp    800562 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800515:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800519:	74 1b                	je     800536 <vprintfmt+0x213>
  80051b:	0f be c0             	movsbl %al,%eax
  80051e:	83 e8 20             	sub    $0x20,%eax
  800521:	83 f8 5e             	cmp    $0x5e,%eax
  800524:	76 10                	jbe    800536 <vprintfmt+0x213>
					putch('?', putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	ff 75 0c             	pushl  0xc(%ebp)
  80052c:	6a 3f                	push   $0x3f
  80052e:	ff 55 08             	call   *0x8(%ebp)
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	eb 0d                	jmp    800543 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 0c             	pushl  0xc(%ebp)
  80053c:	52                   	push   %edx
  80053d:	ff 55 08             	call   *0x8(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800543:	83 eb 01             	sub    $0x1,%ebx
  800546:	eb 1a                	jmp    800562 <vprintfmt+0x23f>
  800548:	89 75 08             	mov    %esi,0x8(%ebp)
  80054b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80054e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800551:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800554:	eb 0c                	jmp    800562 <vprintfmt+0x23f>
  800556:	89 75 08             	mov    %esi,0x8(%ebp)
  800559:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80055c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800562:	83 c7 01             	add    $0x1,%edi
  800565:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800569:	0f be d0             	movsbl %al,%edx
  80056c:	85 d2                	test   %edx,%edx
  80056e:	74 23                	je     800593 <vprintfmt+0x270>
  800570:	85 f6                	test   %esi,%esi
  800572:	78 a1                	js     800515 <vprintfmt+0x1f2>
  800574:	83 ee 01             	sub    $0x1,%esi
  800577:	79 9c                	jns    800515 <vprintfmt+0x1f2>
  800579:	89 df                	mov    %ebx,%edi
  80057b:	8b 75 08             	mov    0x8(%ebp),%esi
  80057e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800581:	eb 18                	jmp    80059b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	6a 20                	push   $0x20
  800589:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058b:	83 ef 01             	sub    $0x1,%edi
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	eb 08                	jmp    80059b <vprintfmt+0x278>
  800593:	89 df                	mov    %ebx,%edi
  800595:	8b 75 08             	mov    0x8(%ebp),%esi
  800598:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059b:	85 ff                	test   %edi,%edi
  80059d:	7f e4                	jg     800583 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a2:	e9 a2 fd ff ff       	jmp    800349 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a7:	83 fa 01             	cmp    $0x1,%edx
  8005aa:	7e 16                	jle    8005c2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 08             	lea    0x8(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	8b 50 04             	mov    0x4(%eax),%edx
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005bd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005c0:	eb 32                	jmp    8005f4 <vprintfmt+0x2d1>
	else if (lflag)
  8005c2:	85 d2                	test   %edx,%edx
  8005c4:	74 18                	je     8005de <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d4:	89 c1                	mov    %eax,%ecx
  8005d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005dc:	eb 16                	jmp    8005f4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ec:	89 c1                	mov    %eax,%ecx
  8005ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005f7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800600:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800605:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800609:	0f 89 b0 00 00 00    	jns    8006bf <vprintfmt+0x39c>
				putch('-', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 2d                	push   $0x2d
  800615:	ff d6                	call   *%esi
				num = -(long long) num;
  800617:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80061a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80061d:	f7 d8                	neg    %eax
  80061f:	83 d2 00             	adc    $0x0,%edx
  800622:	f7 da                	neg    %edx
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800632:	e9 88 00 00 00       	jmp    8006bf <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 70 fc ff ff       	call   8002af <getuint>
  80063f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800642:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800645:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80064a:	eb 73                	jmp    8006bf <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 5b fc ff ff       	call   8002af <getuint>
  800654:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800657:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 58                	push   $0x58
  800660:	ff d6                	call   *%esi
			putch('X', putdat);
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	6a 58                	push   $0x58
  800668:	ff d6                	call   *%esi
			putch('X', putdat);
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 58                	push   $0x58
  800670:	ff d6                	call   *%esi
			goto number;
  800672:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800675:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80067a:	eb 43                	jmp    8006bf <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
  80069c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006aa:	eb 13                	jmp    8006bf <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8006af:	e8 fb fb ff ff       	call   8002af <getuint>
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006c6:	52                   	push   %edx
  8006c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ca:	50                   	push   %eax
  8006cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d1:	89 da                	mov    %ebx,%edx
  8006d3:	89 f0                	mov    %esi,%eax
  8006d5:	e8 26 fb ff ff       	call   800200 <printnum>
			break;
  8006da:	83 c4 20             	add    $0x20,%esp
  8006dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e0:	e9 64 fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	51                   	push   %ecx
  8006ea:	ff d6                	call   *%esi
			break;
  8006ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f2:	e9 52 fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	6a 25                	push   $0x25
  8006fd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	eb 03                	jmp    800707 <vprintfmt+0x3e4>
  800704:	83 ef 01             	sub    $0x1,%edi
  800707:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070b:	75 f7                	jne    800704 <vprintfmt+0x3e1>
  80070d:	e9 37 fc ff ff       	jmp    800349 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800715:	5b                   	pop    %ebx
  800716:	5e                   	pop    %esi
  800717:	5f                   	pop    %edi
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 18             	sub    $0x18,%esp
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800726:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800729:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800730:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800737:	85 c0                	test   %eax,%eax
  800739:	74 26                	je     800761 <vsnprintf+0x47>
  80073b:	85 d2                	test   %edx,%edx
  80073d:	7e 22                	jle    800761 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073f:	ff 75 14             	pushl  0x14(%ebp)
  800742:	ff 75 10             	pushl  0x10(%ebp)
  800745:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	68 e9 02 80 00       	push   $0x8002e9
  80074e:	e8 d0 fb ff ff       	call   800323 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800753:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800756:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	eb 05                	jmp    800766 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800771:	50                   	push   %eax
  800772:	ff 75 10             	pushl  0x10(%ebp)
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	ff 75 08             	pushl  0x8(%ebp)
  80077b:	e8 9a ff ff ff       	call   80071a <vsnprintf>
	va_end(ap);

	return rc;
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
  80078d:	eb 03                	jmp    800792 <strlen+0x10>
		n++;
  80078f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800792:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800796:	75 f7                	jne    80078f <strlen+0xd>
		n++;
	return n;
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a8:	eb 03                	jmp    8007ad <strnlen+0x13>
		n++;
  8007aa:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ad:	39 c2                	cmp    %eax,%edx
  8007af:	74 08                	je     8007b9 <strnlen+0x1f>
  8007b1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b5:	75 f3                	jne    8007aa <strnlen+0x10>
  8007b7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	83 c2 01             	add    $0x1,%edx
  8007ca:	83 c1 01             	add    $0x1,%ecx
  8007cd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ef                	jne    8007c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e2:	53                   	push   %ebx
  8007e3:	e8 9a ff ff ff       	call   800782 <strlen>
  8007e8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007eb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ee:	01 d8                	add    %ebx,%eax
  8007f0:	50                   	push   %eax
  8007f1:	e8 c5 ff ff ff       	call   8007bb <strcpy>
	return dst;
}
  8007f6:	89 d8                	mov    %ebx,%eax
  8007f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	8b 75 08             	mov    0x8(%ebp),%esi
  800805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800808:	89 f3                	mov    %esi,%ebx
  80080a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080d:	89 f2                	mov    %esi,%edx
  80080f:	eb 0f                	jmp    800820 <strncpy+0x23>
		*dst++ = *src;
  800811:	83 c2 01             	add    $0x1,%edx
  800814:	0f b6 01             	movzbl (%ecx),%eax
  800817:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081a:	80 39 01             	cmpb   $0x1,(%ecx)
  80081d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800820:	39 da                	cmp    %ebx,%edx
  800822:	75 ed                	jne    800811 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800824:	89 f0                	mov    %esi,%eax
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 75 08             	mov    0x8(%ebp),%esi
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	8b 55 10             	mov    0x10(%ebp),%edx
  800838:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 21                	je     80085f <strlcpy+0x35>
  80083e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 09                	jmp    80084f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084f:	39 c2                	cmp    %eax,%edx
  800851:	74 09                	je     80085c <strlcpy+0x32>
  800853:	0f b6 19             	movzbl (%ecx),%ebx
  800856:	84 db                	test   %bl,%bl
  800858:	75 ec                	jne    800846 <strlcpy+0x1c>
  80085a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085f:	29 f0                	sub    %esi,%eax
}
  800861:	5b                   	pop    %ebx
  800862:	5e                   	pop    %esi
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086e:	eb 06                	jmp    800876 <strcmp+0x11>
		p++, q++;
  800870:	83 c1 01             	add    $0x1,%ecx
  800873:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800876:	0f b6 01             	movzbl (%ecx),%eax
  800879:	84 c0                	test   %al,%al
  80087b:	74 04                	je     800881 <strcmp+0x1c>
  80087d:	3a 02                	cmp    (%edx),%al
  80087f:	74 ef                	je     800870 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800881:	0f b6 c0             	movzbl %al,%eax
  800884:	0f b6 12             	movzbl (%edx),%edx
  800887:	29 d0                	sub    %edx,%eax
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
  800895:	89 c3                	mov    %eax,%ebx
  800897:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089a:	eb 06                	jmp    8008a2 <strncmp+0x17>
		n--, p++, q++;
  80089c:	83 c0 01             	add    $0x1,%eax
  80089f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a2:	39 d8                	cmp    %ebx,%eax
  8008a4:	74 15                	je     8008bb <strncmp+0x30>
  8008a6:	0f b6 08             	movzbl (%eax),%ecx
  8008a9:	84 c9                	test   %cl,%cl
  8008ab:	74 04                	je     8008b1 <strncmp+0x26>
  8008ad:	3a 0a                	cmp    (%edx),%cl
  8008af:	74 eb                	je     80089c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 00             	movzbl (%eax),%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
  8008b9:	eb 05                	jmp    8008c0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cd:	eb 07                	jmp    8008d6 <strchr+0x13>
		if (*s == c)
  8008cf:	38 ca                	cmp    %cl,%dl
  8008d1:	74 0f                	je     8008e2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	0f b6 10             	movzbl (%eax),%edx
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f2                	jne    8008cf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ee:	eb 03                	jmp    8008f3 <strfind+0xf>
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 04                	je     8008fe <strfind+0x1a>
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	75 f2                	jne    8008f0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 7d 08             	mov    0x8(%ebp),%edi
  800909:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 36                	je     800946 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800910:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800916:	75 28                	jne    800940 <memset+0x40>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 23                	jne    800940 <memset+0x40>
		c &= 0xFF;
  80091d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800921:	89 d3                	mov    %edx,%ebx
  800923:	c1 e3 08             	shl    $0x8,%ebx
  800926:	89 d6                	mov    %edx,%esi
  800928:	c1 e6 18             	shl    $0x18,%esi
  80092b:	89 d0                	mov    %edx,%eax
  80092d:	c1 e0 10             	shl    $0x10,%eax
  800930:	09 f0                	or     %esi,%eax
  800932:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800934:	89 d8                	mov    %ebx,%eax
  800936:	09 d0                	or     %edx,%eax
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	fc                   	cld    
  80093c:	f3 ab                	rep stos %eax,%es:(%edi)
  80093e:	eb 06                	jmp    800946 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800940:	8b 45 0c             	mov    0xc(%ebp),%eax
  800943:	fc                   	cld    
  800944:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800946:	89 f8                	mov    %edi,%eax
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 75 0c             	mov    0xc(%ebp),%esi
  800958:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095b:	39 c6                	cmp    %eax,%esi
  80095d:	73 35                	jae    800994 <memmove+0x47>
  80095f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800962:	39 d0                	cmp    %edx,%eax
  800964:	73 2e                	jae    800994 <memmove+0x47>
		s += n;
		d += n;
  800966:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	89 d6                	mov    %edx,%esi
  80096b:	09 fe                	or     %edi,%esi
  80096d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800973:	75 13                	jne    800988 <memmove+0x3b>
  800975:	f6 c1 03             	test   $0x3,%cl
  800978:	75 0e                	jne    800988 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097a:	83 ef 04             	sub    $0x4,%edi
  80097d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800980:	c1 e9 02             	shr    $0x2,%ecx
  800983:	fd                   	std    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 09                	jmp    800991 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800988:	83 ef 01             	sub    $0x1,%edi
  80098b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098e:	fd                   	std    
  80098f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800991:	fc                   	cld    
  800992:	eb 1d                	jmp    8009b1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800994:	89 f2                	mov    %esi,%edx
  800996:	09 c2                	or     %eax,%edx
  800998:	f6 c2 03             	test   $0x3,%dl
  80099b:	75 0f                	jne    8009ac <memmove+0x5f>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 0a                	jne    8009ac <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
  8009a5:	89 c7                	mov    %eax,%edi
  8009a7:	fc                   	cld    
  8009a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009aa:	eb 05                	jmp    8009b1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ac:	89 c7                	mov    %eax,%edi
  8009ae:	fc                   	cld    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b8:	ff 75 10             	pushl  0x10(%ebp)
  8009bb:	ff 75 0c             	pushl  0xc(%ebp)
  8009be:	ff 75 08             	pushl  0x8(%ebp)
  8009c1:	e8 87 ff ff ff       	call   80094d <memmove>
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d3:	89 c6                	mov    %eax,%esi
  8009d5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d8:	eb 1a                	jmp    8009f4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009da:	0f b6 08             	movzbl (%eax),%ecx
  8009dd:	0f b6 1a             	movzbl (%edx),%ebx
  8009e0:	38 d9                	cmp    %bl,%cl
  8009e2:	74 0a                	je     8009ee <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e4:	0f b6 c1             	movzbl %cl,%eax
  8009e7:	0f b6 db             	movzbl %bl,%ebx
  8009ea:	29 d8                	sub    %ebx,%eax
  8009ec:	eb 0f                	jmp    8009fd <memcmp+0x35>
		s1++, s2++;
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f4:	39 f0                	cmp    %esi,%eax
  8009f6:	75 e2                	jne    8009da <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a08:	89 c1                	mov    %eax,%ecx
  800a0a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a11:	eb 0a                	jmp    800a1d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a13:	0f b6 10             	movzbl (%eax),%edx
  800a16:	39 da                	cmp    %ebx,%edx
  800a18:	74 07                	je     800a21 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	39 c8                	cmp    %ecx,%eax
  800a1f:	72 f2                	jb     800a13 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a21:	5b                   	pop    %ebx
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	eb 03                	jmp    800a35 <strtol+0x11>
		s++;
  800a32:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	0f b6 01             	movzbl (%ecx),%eax
  800a38:	3c 20                	cmp    $0x20,%al
  800a3a:	74 f6                	je     800a32 <strtol+0xe>
  800a3c:	3c 09                	cmp    $0x9,%al
  800a3e:	74 f2                	je     800a32 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a40:	3c 2b                	cmp    $0x2b,%al
  800a42:	75 0a                	jne    800a4e <strtol+0x2a>
		s++;
  800a44:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4c:	eb 11                	jmp    800a5f <strtol+0x3b>
  800a4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a53:	3c 2d                	cmp    $0x2d,%al
  800a55:	75 08                	jne    800a5f <strtol+0x3b>
		s++, neg = 1;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a65:	75 15                	jne    800a7c <strtol+0x58>
  800a67:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6a:	75 10                	jne    800a7c <strtol+0x58>
  800a6c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a70:	75 7c                	jne    800aee <strtol+0xca>
		s += 2, base = 16;
  800a72:	83 c1 02             	add    $0x2,%ecx
  800a75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7a:	eb 16                	jmp    800a92 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	75 12                	jne    800a92 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a80:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a85:	80 39 30             	cmpb   $0x30,(%ecx)
  800a88:	75 08                	jne    800a92 <strtol+0x6e>
		s++, base = 8;
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9a:	0f b6 11             	movzbl (%ecx),%edx
  800a9d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 09             	cmp    $0x9,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0x8b>
			dig = *s - '0';
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 30             	sub    $0x30,%edx
  800aad:	eb 22                	jmp    800ad1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 57             	sub    $0x57,%edx
  800abf:	eb 10                	jmp    800ad1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 16                	ja     800ae1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800acb:	0f be d2             	movsbl %dl,%edx
  800ace:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad4:	7d 0b                	jge    800ae1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800add:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adf:	eb b9                	jmp    800a9a <strtol+0x76>

	if (endptr)
  800ae1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae5:	74 0d                	je     800af4 <strtol+0xd0>
		*endptr = (char *) s;
  800ae7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aea:	89 0e                	mov    %ecx,(%esi)
  800aec:	eb 06                	jmp    800af4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aee:	85 db                	test   %ebx,%ebx
  800af0:	74 98                	je     800a8a <strtol+0x66>
  800af2:	eb 9e                	jmp    800a92 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af4:	89 c2                	mov    %eax,%edx
  800af6:	f7 da                	neg    %edx
  800af8:	85 ff                	test   %edi,%edi
  800afa:	0f 45 c2             	cmovne %edx,%eax
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	89 c3                	mov    %eax,%ebx
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	89 c6                	mov    %eax,%esi
  800b19:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b2b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	89 cb                	mov    %ecx,%ebx
  800b57:	89 cf                	mov    %ecx,%edi
  800b59:	89 ce                	mov    %ecx,%esi
  800b5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 03                	push   $0x3
  800b67:	68 ff 25 80 00       	push   $0x8025ff
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 1c 26 80 00       	push   $0x80261c
  800b73:	e8 c7 12 00 00       	call   801e3f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_yield>:

void
sys_yield(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bc7:	be 00 00 00 00       	mov    $0x0,%esi
  800bcc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	89 f7                	mov    %esi,%edi
  800bdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 04                	push   $0x4
  800be8:	68 ff 25 80 00       	push   $0x8025ff
  800bed:	6a 23                	push   $0x23
  800bef:	68 1c 26 80 00       	push   $0x80261c
  800bf4:	e8 46 12 00 00       	call   801e3f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 05                	push   $0x5
  800c2a:	68 ff 25 80 00       	push   $0x8025ff
  800c2f:	6a 23                	push   $0x23
  800c31:	68 1c 26 80 00       	push   $0x80261c
  800c36:	e8 04 12 00 00       	call   801e3f <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	b8 06 00 00 00       	mov    $0x6,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 06                	push   $0x6
  800c6c:	68 ff 25 80 00       	push   $0x8025ff
  800c71:	6a 23                	push   $0x23
  800c73:	68 1c 26 80 00       	push   $0x80261c
  800c78:	e8 c2 11 00 00       	call   801e3f <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	b8 08 00 00 00       	mov    $0x8,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 08                	push   $0x8
  800cae:	68 ff 25 80 00       	push   $0x8025ff
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 1c 26 80 00       	push   $0x80261c
  800cba:	e8 80 11 00 00       	call   801e3f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 17                	jle    800d01 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	50                   	push   %eax
  800cee:	6a 09                	push   $0x9
  800cf0:	68 ff 25 80 00       	push   $0x8025ff
  800cf5:	6a 23                	push   $0x23
  800cf7:	68 1c 26 80 00       	push   $0x80261c
  800cfc:	e8 3e 11 00 00       	call   801e3f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 df                	mov    %ebx,%edi
  800d24:	89 de                	mov    %ebx,%esi
  800d26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7e 17                	jle    800d43 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	50                   	push   %eax
  800d30:	6a 0a                	push   $0xa
  800d32:	68 ff 25 80 00       	push   $0x8025ff
  800d37:	6a 23                	push   $0x23
  800d39:	68 1c 26 80 00       	push   $0x80261c
  800d3e:	e8 fc 10 00 00       	call   801e3f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d51:	be 00 00 00 00       	mov    $0x0,%esi
  800d56:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d67:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 0d                	push   $0xd
  800d96:	68 ff 25 80 00       	push   $0x8025ff
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 1c 26 80 00       	push   $0x80261c
  800da2:	e8 98 10 00 00       	call   801e3f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db7:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800db9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dbd:	74 11                	je     800dd0 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800dbf:	89 d8                	mov    %ebx,%eax
  800dc1:	c1 e8 0c             	shr    $0xc,%eax
  800dc4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800dcb:	f6 c4 08             	test   $0x8,%ah
  800dce:	75 14                	jne    800de4 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	68 2a 26 80 00       	push   $0x80262a
  800dd8:	6a 21                	push   $0x21
  800dda:	68 40 26 80 00       	push   $0x802640
  800ddf:	e8 5b 10 00 00       	call   801e3f <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800de4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800dea:	e8 91 fd ff ff       	call   800b80 <sys_getenvid>
  800def:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800df1:	83 ec 04             	sub    $0x4,%esp
  800df4:	6a 07                	push   $0x7
  800df6:	68 00 f0 7f 00       	push   $0x7ff000
  800dfb:	50                   	push   %eax
  800dfc:	e8 bd fd ff ff       	call   800bbe <sys_page_alloc>
  800e01:	83 c4 10             	add    $0x10,%esp
  800e04:	85 c0                	test   %eax,%eax
  800e06:	79 14                	jns    800e1c <pgfault+0x6d>
		panic("sys_page_alloc");
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	68 4b 26 80 00       	push   $0x80264b
  800e10:	6a 30                	push   $0x30
  800e12:	68 40 26 80 00       	push   $0x802640
  800e17:	e8 23 10 00 00       	call   801e3f <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800e1c:	83 ec 04             	sub    $0x4,%esp
  800e1f:	68 00 10 00 00       	push   $0x1000
  800e24:	53                   	push   %ebx
  800e25:	68 00 f0 7f 00       	push   $0x7ff000
  800e2a:	e8 86 fb ff ff       	call   8009b5 <memcpy>
	retv = sys_page_unmap(envid, addr);
  800e2f:	83 c4 08             	add    $0x8,%esp
  800e32:	53                   	push   %ebx
  800e33:	56                   	push   %esi
  800e34:	e8 0a fe ff ff       	call   800c43 <sys_page_unmap>
	if(retv < 0){
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	79 12                	jns    800e52 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800e40:	50                   	push   %eax
  800e41:	68 38 27 80 00       	push   $0x802738
  800e46:	6a 35                	push   $0x35
  800e48:	68 40 26 80 00       	push   $0x802640
  800e4d:	e8 ed 0f 00 00       	call   801e3f <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800e52:	83 ec 0c             	sub    $0xc,%esp
  800e55:	6a 07                	push   $0x7
  800e57:	53                   	push   %ebx
  800e58:	56                   	push   %esi
  800e59:	68 00 f0 7f 00       	push   $0x7ff000
  800e5e:	56                   	push   %esi
  800e5f:	e8 9d fd ff ff       	call   800c01 <sys_page_map>
	if(retv < 0){
  800e64:	83 c4 20             	add    $0x20,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 14                	jns    800e7f <pgfault+0xd0>
		panic("sys_page_map");
  800e6b:	83 ec 04             	sub    $0x4,%esp
  800e6e:	68 5a 26 80 00       	push   $0x80265a
  800e73:	6a 39                	push   $0x39
  800e75:	68 40 26 80 00       	push   $0x802640
  800e7a:	e8 c0 0f 00 00       	call   801e3f <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	68 00 f0 7f 00       	push   $0x7ff000
  800e87:	56                   	push   %esi
  800e88:	e8 b6 fd ff ff       	call   800c43 <sys_page_unmap>
	if(retv < 0){
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	79 14                	jns    800ea8 <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	68 67 26 80 00       	push   $0x802667
  800e9c:	6a 3d                	push   $0x3d
  800e9e:	68 40 26 80 00       	push   $0x802640
  800ea3:	e8 97 0f 00 00       	call   801e3f <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800ea8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800eb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eba:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800ebd:	83 ec 08             	sub    $0x8,%esp
  800ec0:	53                   	push   %ebx
  800ec1:	68 84 26 80 00       	push   $0x802684
  800ec6:	e8 21 f3 ff ff       	call   8001ec <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800ecb:	83 c4 0c             	add    $0xc,%esp
  800ece:	6a 07                	push   $0x7
  800ed0:	53                   	push   %ebx
  800ed1:	56                   	push   %esi
  800ed2:	e8 e7 fc ff ff       	call   800bbe <sys_page_alloc>
  800ed7:	83 c4 10             	add    $0x10,%esp
  800eda:	85 c0                	test   %eax,%eax
  800edc:	79 15                	jns    800ef3 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800ede:	50                   	push   %eax
  800edf:	68 97 26 80 00       	push   $0x802697
  800ee4:	68 90 00 00 00       	push   $0x90
  800ee9:	68 40 26 80 00       	push   $0x802640
  800eee:	e8 4c 0f 00 00       	call   801e3f <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	68 aa 26 80 00       	push   $0x8026aa
  800efb:	e8 ec f2 ff ff       	call   8001ec <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f00:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f07:	68 00 00 40 00       	push   $0x400000
  800f0c:	6a 00                	push   $0x0
  800f0e:	53                   	push   %ebx
  800f0f:	56                   	push   %esi
  800f10:	e8 ec fc ff ff       	call   800c01 <sys_page_map>
  800f15:	83 c4 20             	add    $0x20,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	79 15                	jns    800f31 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  800f1c:	50                   	push   %eax
  800f1d:	68 b2 26 80 00       	push   $0x8026b2
  800f22:	68 94 00 00 00       	push   $0x94
  800f27:	68 40 26 80 00       	push   $0x802640
  800f2c:	e8 0e 0f 00 00       	call   801e3f <_panic>
        cprintf("af_p_m.");
  800f31:	83 ec 0c             	sub    $0xc,%esp
  800f34:	68 c3 26 80 00       	push   $0x8026c3
  800f39:	e8 ae f2 ff ff       	call   8001ec <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  800f3e:	83 c4 0c             	add    $0xc,%esp
  800f41:	68 00 10 00 00       	push   $0x1000
  800f46:	53                   	push   %ebx
  800f47:	68 00 00 40 00       	push   $0x400000
  800f4c:	e8 fc f9 ff ff       	call   80094d <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  800f51:	c7 04 24 cb 26 80 00 	movl   $0x8026cb,(%esp)
  800f58:	e8 8f f2 ff ff       	call   8001ec <cprintf>
}
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800f70:	68 af 0d 80 00       	push   $0x800daf
  800f75:	e8 0b 0f 00 00       	call   801e85 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f7a:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7f:	cd 30                	int    $0x30
  800f81:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f84:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  800f87:	83 c4 10             	add    $0x10,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	79 17                	jns    800fa5 <fork+0x3e>
		panic("sys_exofork failed.");
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	68 d9 26 80 00       	push   $0x8026d9
  800f96:	68 b7 00 00 00       	push   $0xb7
  800f9b:	68 40 26 80 00       	push   $0x802640
  800fa0:	e8 9a 0e 00 00       	call   801e3f <_panic>
  800fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  800faa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fae:	75 21                	jne    800fd1 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb0:	e8 cb fb ff ff       	call   800b80 <sys_getenvid>
  800fb5:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fbd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc2:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  800fc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcc:	e9 69 01 00 00       	jmp    80113a <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800fd1:	89 d8                	mov    %ebx,%eax
  800fd3:	c1 e8 16             	shr    $0x16,%eax
  800fd6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800fdd:	a8 01                	test   $0x1,%al
  800fdf:	0f 84 d6 00 00 00    	je     8010bb <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	c1 ee 0c             	shr    $0xc,%esi
  800fea:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800ff1:	a8 01                	test   $0x1,%al
  800ff3:	0f 84 c2 00 00 00    	je     8010bb <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  800ff9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  801000:	89 f7                	mov    %esi,%edi
  801002:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  801005:	e8 76 fb ff ff       	call   800b80 <sys_getenvid>
  80100a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  80100d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801014:	f6 c4 04             	test   $0x4,%ah
  801017:	74 1c                	je     801035 <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	68 07 0e 00 00       	push   $0xe07
  801021:	57                   	push   %edi
  801022:	ff 75 e0             	pushl  -0x20(%ebp)
  801025:	57                   	push   %edi
  801026:	6a 00                	push   $0x0
  801028:	e8 d4 fb ff ff       	call   800c01 <sys_page_map>
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	e9 86 00 00 00       	jmp    8010bb <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  801035:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103c:	a8 02                	test   $0x2,%al
  80103e:	75 0c                	jne    80104c <fork+0xe5>
  801040:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801047:	f6 c4 08             	test   $0x8,%ah
  80104a:	74 5b                	je     8010a7 <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	68 05 08 00 00       	push   $0x805
  801054:	57                   	push   %edi
  801055:	ff 75 e0             	pushl  -0x20(%ebp)
  801058:	57                   	push   %edi
  801059:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105c:	e8 a0 fb ff ff       	call   800c01 <sys_page_map>
  801061:	83 c4 20             	add    $0x20,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	79 12                	jns    80107a <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  801068:	50                   	push   %eax
  801069:	68 5c 27 80 00       	push   $0x80275c
  80106e:	6a 5f                	push   $0x5f
  801070:	68 40 26 80 00       	push   $0x802640
  801075:	e8 c5 0d 00 00       	call   801e3f <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	68 05 08 00 00       	push   $0x805
  801082:	57                   	push   %edi
  801083:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801086:	50                   	push   %eax
  801087:	57                   	push   %edi
  801088:	50                   	push   %eax
  801089:	e8 73 fb ff ff       	call   800c01 <sys_page_map>
  80108e:	83 c4 20             	add    $0x20,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 26                	jns    8010bb <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  801095:	50                   	push   %eax
  801096:	68 80 27 80 00       	push   $0x802780
  80109b:	6a 64                	push   $0x64
  80109d:	68 40 26 80 00       	push   $0x802640
  8010a2:	e8 98 0d 00 00       	call   801e3f <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	6a 05                	push   $0x5
  8010ac:	57                   	push   %edi
  8010ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8010b0:	57                   	push   %edi
  8010b1:	6a 00                	push   $0x0
  8010b3:	e8 49 fb ff ff       	call   800c01 <sys_page_map>
  8010b8:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8010bb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c1:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010c7:	0f 85 04 ff ff ff    	jne    800fd1 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  8010cd:	83 ec 04             	sub    $0x4,%esp
  8010d0:	6a 07                	push   $0x7
  8010d2:	68 00 f0 bf ee       	push   $0xeebff000
  8010d7:	ff 75 dc             	pushl  -0x24(%ebp)
  8010da:	e8 df fa ff ff       	call   800bbe <sys_page_alloc>
	if(retv < 0){
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	79 17                	jns    8010fd <fork+0x196>
		panic("sys_page_alloc failed.\n");
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	68 ed 26 80 00       	push   $0x8026ed
  8010ee:	68 cc 00 00 00       	push   $0xcc
  8010f3:	68 40 26 80 00       	push   $0x802640
  8010f8:	e8 42 0d 00 00       	call   801e3f <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  8010fd:	83 ec 08             	sub    $0x8,%esp
  801100:	68 ea 1e 80 00       	push   $0x801eea
  801105:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801108:	57                   	push   %edi
  801109:	e8 fb fb ff ff       	call   800d09 <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  80110e:	83 c4 08             	add    $0x8,%esp
  801111:	6a 02                	push   $0x2
  801113:	57                   	push   %edi
  801114:	e8 6c fb ff ff       	call   800c85 <sys_env_set_status>
	if(retv < 0){
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	79 17                	jns    801137 <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	68 05 27 80 00       	push   $0x802705
  801128:	68 dd 00 00 00       	push   $0xdd
  80112d:	68 40 26 80 00       	push   $0x802640
  801132:	e8 08 0d 00 00       	call   801e3f <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  801137:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <sfork>:

// Challenge!
int
sfork(void)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801148:	68 21 27 80 00       	push   $0x802721
  80114d:	68 e8 00 00 00       	push   $0xe8
  801152:	68 40 26 80 00       	push   $0x802640
  801157:	e8 e3 0c 00 00       	call   801e3f <_panic>

0080115c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	05 00 00 00 30       	add    $0x30000000,%eax
  801167:	c1 e8 0c             	shr    $0xc,%eax
}
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	05 00 00 00 30       	add    $0x30000000,%eax
  801177:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80117c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801189:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80118e:	89 c2                	mov    %eax,%edx
  801190:	c1 ea 16             	shr    $0x16,%edx
  801193:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119a:	f6 c2 01             	test   $0x1,%dl
  80119d:	74 11                	je     8011b0 <fd_alloc+0x2d>
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	c1 ea 0c             	shr    $0xc,%edx
  8011a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ab:	f6 c2 01             	test   $0x1,%dl
  8011ae:	75 09                	jne    8011b9 <fd_alloc+0x36>
			*fd_store = fd;
  8011b0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b7:	eb 17                	jmp    8011d0 <fd_alloc+0x4d>
  8011b9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011be:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c3:	75 c9                	jne    80118e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011cb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d8:	83 f8 1f             	cmp    $0x1f,%eax
  8011db:	77 36                	ja     801213 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011dd:	c1 e0 0c             	shl    $0xc,%eax
  8011e0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	c1 ea 16             	shr    $0x16,%edx
  8011ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f1:	f6 c2 01             	test   $0x1,%dl
  8011f4:	74 24                	je     80121a <fd_lookup+0x48>
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	c1 ea 0c             	shr    $0xc,%edx
  8011fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801202:	f6 c2 01             	test   $0x1,%dl
  801205:	74 1a                	je     801221 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801207:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120a:	89 02                	mov    %eax,(%edx)
	return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
  801211:	eb 13                	jmp    801226 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801213:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801218:	eb 0c                	jmp    801226 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121f:	eb 05                	jmp    801226 <fd_lookup+0x54>
  801221:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801231:	ba 20 28 80 00       	mov    $0x802820,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801236:	eb 13                	jmp    80124b <dev_lookup+0x23>
  801238:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80123b:	39 08                	cmp    %ecx,(%eax)
  80123d:	75 0c                	jne    80124b <dev_lookup+0x23>
			*dev = devtab[i];
  80123f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801242:	89 01                	mov    %eax,(%ecx)
			return 0;
  801244:	b8 00 00 00 00       	mov    $0x0,%eax
  801249:	eb 2e                	jmp    801279 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80124b:	8b 02                	mov    (%edx),%eax
  80124d:	85 c0                	test   %eax,%eax
  80124f:	75 e7                	jne    801238 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801251:	a1 04 40 80 00       	mov    0x804004,%eax
  801256:	8b 40 48             	mov    0x48(%eax),%eax
  801259:	83 ec 04             	sub    $0x4,%esp
  80125c:	51                   	push   %ecx
  80125d:	50                   	push   %eax
  80125e:	68 a4 27 80 00       	push   $0x8027a4
  801263:	e8 84 ef ff ff       	call   8001ec <cprintf>
	*dev = 0;
  801268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	56                   	push   %esi
  80127f:	53                   	push   %ebx
  801280:	83 ec 10             	sub    $0x10,%esp
  801283:	8b 75 08             	mov    0x8(%ebp),%esi
  801286:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801289:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128c:	50                   	push   %eax
  80128d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801293:	c1 e8 0c             	shr    $0xc,%eax
  801296:	50                   	push   %eax
  801297:	e8 36 ff ff ff       	call   8011d2 <fd_lookup>
  80129c:	83 c4 08             	add    $0x8,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 05                	js     8012a8 <fd_close+0x2d>
	    || fd != fd2)
  8012a3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012a6:	74 0c                	je     8012b4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012a8:	84 db                	test   %bl,%bl
  8012aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012af:	0f 44 c2             	cmove  %edx,%eax
  8012b2:	eb 41                	jmp    8012f5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ba:	50                   	push   %eax
  8012bb:	ff 36                	pushl  (%esi)
  8012bd:	e8 66 ff ff ff       	call   801228 <dev_lookup>
  8012c2:	89 c3                	mov    %eax,%ebx
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	78 1a                	js     8012e5 <fd_close+0x6a>
		if (dev->dev_close)
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012d1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	74 0b                	je     8012e5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012da:	83 ec 0c             	sub    $0xc,%esp
  8012dd:	56                   	push   %esi
  8012de:	ff d0                	call   *%eax
  8012e0:	89 c3                	mov    %eax,%ebx
  8012e2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	56                   	push   %esi
  8012e9:	6a 00                	push   $0x0
  8012eb:	e8 53 f9 ff ff       	call   800c43 <sys_page_unmap>
	return r;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	89 d8                	mov    %ebx,%eax
}
  8012f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801302:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	ff 75 08             	pushl  0x8(%ebp)
  801309:	e8 c4 fe ff ff       	call   8011d2 <fd_lookup>
  80130e:	83 c4 08             	add    $0x8,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 10                	js     801325 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	6a 01                	push   $0x1
  80131a:	ff 75 f4             	pushl  -0xc(%ebp)
  80131d:	e8 59 ff ff ff       	call   80127b <fd_close>
  801322:	83 c4 10             	add    $0x10,%esp
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <close_all>:

void
close_all(void)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	53                   	push   %ebx
  80132b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80132e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	53                   	push   %ebx
  801337:	e8 c0 ff ff ff       	call   8012fc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80133c:	83 c3 01             	add    $0x1,%ebx
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	83 fb 20             	cmp    $0x20,%ebx
  801345:	75 ec                	jne    801333 <close_all+0xc>
		close(i);
}
  801347:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134a:	c9                   	leave  
  80134b:	c3                   	ret    

0080134c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	57                   	push   %edi
  801350:	56                   	push   %esi
  801351:	53                   	push   %ebx
  801352:	83 ec 2c             	sub    $0x2c,%esp
  801355:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801358:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 75 08             	pushl  0x8(%ebp)
  80135f:	e8 6e fe ff ff       	call   8011d2 <fd_lookup>
  801364:	83 c4 08             	add    $0x8,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	0f 88 c1 00 00 00    	js     801430 <dup+0xe4>
		return r;
	close(newfdnum);
  80136f:	83 ec 0c             	sub    $0xc,%esp
  801372:	56                   	push   %esi
  801373:	e8 84 ff ff ff       	call   8012fc <close>

	newfd = INDEX2FD(newfdnum);
  801378:	89 f3                	mov    %esi,%ebx
  80137a:	c1 e3 0c             	shl    $0xc,%ebx
  80137d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801383:	83 c4 04             	add    $0x4,%esp
  801386:	ff 75 e4             	pushl  -0x1c(%ebp)
  801389:	e8 de fd ff ff       	call   80116c <fd2data>
  80138e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801390:	89 1c 24             	mov    %ebx,(%esp)
  801393:	e8 d4 fd ff ff       	call   80116c <fd2data>
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80139e:	89 f8                	mov    %edi,%eax
  8013a0:	c1 e8 16             	shr    $0x16,%eax
  8013a3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013aa:	a8 01                	test   $0x1,%al
  8013ac:	74 37                	je     8013e5 <dup+0x99>
  8013ae:	89 f8                	mov    %edi,%eax
  8013b0:	c1 e8 0c             	shr    $0xc,%eax
  8013b3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ba:	f6 c2 01             	test   $0x1,%dl
  8013bd:	74 26                	je     8013e5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ce:	50                   	push   %eax
  8013cf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d2:	6a 00                	push   $0x0
  8013d4:	57                   	push   %edi
  8013d5:	6a 00                	push   $0x0
  8013d7:	e8 25 f8 ff ff       	call   800c01 <sys_page_map>
  8013dc:	89 c7                	mov    %eax,%edi
  8013de:	83 c4 20             	add    $0x20,%esp
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 2e                	js     801413 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013e8:	89 d0                	mov    %edx,%eax
  8013ea:	c1 e8 0c             	shr    $0xc,%eax
  8013ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013fc:	50                   	push   %eax
  8013fd:	53                   	push   %ebx
  8013fe:	6a 00                	push   $0x0
  801400:	52                   	push   %edx
  801401:	6a 00                	push   $0x0
  801403:	e8 f9 f7 ff ff       	call   800c01 <sys_page_map>
  801408:	89 c7                	mov    %eax,%edi
  80140a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80140d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80140f:	85 ff                	test   %edi,%edi
  801411:	79 1d                	jns    801430 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	53                   	push   %ebx
  801417:	6a 00                	push   $0x0
  801419:	e8 25 f8 ff ff       	call   800c43 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80141e:	83 c4 08             	add    $0x8,%esp
  801421:	ff 75 d4             	pushl  -0x2c(%ebp)
  801424:	6a 00                	push   $0x0
  801426:	e8 18 f8 ff ff       	call   800c43 <sys_page_unmap>
	return r;
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	89 f8                	mov    %edi,%eax
}
  801430:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5f                   	pop    %edi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 14             	sub    $0x14,%esp
  80143f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801442:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	53                   	push   %ebx
  801447:	e8 86 fd ff ff       	call   8011d2 <fd_lookup>
  80144c:	83 c4 08             	add    $0x8,%esp
  80144f:	89 c2                	mov    %eax,%edx
  801451:	85 c0                	test   %eax,%eax
  801453:	78 6d                	js     8014c2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145f:	ff 30                	pushl  (%eax)
  801461:	e8 c2 fd ff ff       	call   801228 <dev_lookup>
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 4c                	js     8014b9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80146d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801470:	8b 42 08             	mov    0x8(%edx),%eax
  801473:	83 e0 03             	and    $0x3,%eax
  801476:	83 f8 01             	cmp    $0x1,%eax
  801479:	75 21                	jne    80149c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80147b:	a1 04 40 80 00       	mov    0x804004,%eax
  801480:	8b 40 48             	mov    0x48(%eax),%eax
  801483:	83 ec 04             	sub    $0x4,%esp
  801486:	53                   	push   %ebx
  801487:	50                   	push   %eax
  801488:	68 e5 27 80 00       	push   $0x8027e5
  80148d:	e8 5a ed ff ff       	call   8001ec <cprintf>
		return -E_INVAL;
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80149a:	eb 26                	jmp    8014c2 <read+0x8a>
	}
	if (!dev->dev_read)
  80149c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149f:	8b 40 08             	mov    0x8(%eax),%eax
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	74 17                	je     8014bd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a6:	83 ec 04             	sub    $0x4,%esp
  8014a9:	ff 75 10             	pushl  0x10(%ebp)
  8014ac:	ff 75 0c             	pushl  0xc(%ebp)
  8014af:	52                   	push   %edx
  8014b0:	ff d0                	call   *%eax
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	eb 09                	jmp    8014c2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b9:	89 c2                	mov    %eax,%edx
  8014bb:	eb 05                	jmp    8014c2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014c2:	89 d0                	mov    %edx,%eax
  8014c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    

008014c9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	57                   	push   %edi
  8014cd:	56                   	push   %esi
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014dd:	eb 21                	jmp    801500 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014df:	83 ec 04             	sub    $0x4,%esp
  8014e2:	89 f0                	mov    %esi,%eax
  8014e4:	29 d8                	sub    %ebx,%eax
  8014e6:	50                   	push   %eax
  8014e7:	89 d8                	mov    %ebx,%eax
  8014e9:	03 45 0c             	add    0xc(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	57                   	push   %edi
  8014ee:	e8 45 ff ff ff       	call   801438 <read>
		if (m < 0)
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 10                	js     80150a <readn+0x41>
			return m;
		if (m == 0)
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	74 0a                	je     801508 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014fe:	01 c3                	add    %eax,%ebx
  801500:	39 f3                	cmp    %esi,%ebx
  801502:	72 db                	jb     8014df <readn+0x16>
  801504:	89 d8                	mov    %ebx,%eax
  801506:	eb 02                	jmp    80150a <readn+0x41>
  801508:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80150a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150d:	5b                   	pop    %ebx
  80150e:	5e                   	pop    %esi
  80150f:	5f                   	pop    %edi
  801510:	5d                   	pop    %ebp
  801511:	c3                   	ret    

00801512 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	53                   	push   %ebx
  801516:	83 ec 14             	sub    $0x14,%esp
  801519:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	53                   	push   %ebx
  801521:	e8 ac fc ff ff       	call   8011d2 <fd_lookup>
  801526:	83 c4 08             	add    $0x8,%esp
  801529:	89 c2                	mov    %eax,%edx
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 68                	js     801597 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801539:	ff 30                	pushl  (%eax)
  80153b:	e8 e8 fc ff ff       	call   801228 <dev_lookup>
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	85 c0                	test   %eax,%eax
  801545:	78 47                	js     80158e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154e:	75 21                	jne    801571 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801550:	a1 04 40 80 00       	mov    0x804004,%eax
  801555:	8b 40 48             	mov    0x48(%eax),%eax
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	53                   	push   %ebx
  80155c:	50                   	push   %eax
  80155d:	68 01 28 80 00       	push   $0x802801
  801562:	e8 85 ec ff ff       	call   8001ec <cprintf>
		return -E_INVAL;
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156f:	eb 26                	jmp    801597 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801571:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801574:	8b 52 0c             	mov    0xc(%edx),%edx
  801577:	85 d2                	test   %edx,%edx
  801579:	74 17                	je     801592 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	ff 75 10             	pushl  0x10(%ebp)
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	50                   	push   %eax
  801585:	ff d2                	call   *%edx
  801587:	89 c2                	mov    %eax,%edx
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	eb 09                	jmp    801597 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158e:	89 c2                	mov    %eax,%edx
  801590:	eb 05                	jmp    801597 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801592:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801597:	89 d0                	mov    %edx,%eax
  801599:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159c:	c9                   	leave  
  80159d:	c3                   	ret    

0080159e <seek>:

int
seek(int fdnum, off_t offset)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	ff 75 08             	pushl  0x8(%ebp)
  8015ab:	e8 22 fc ff ff       	call   8011d2 <fd_lookup>
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 0e                	js     8015c5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	53                   	push   %ebx
  8015cb:	83 ec 14             	sub    $0x14,%esp
  8015ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d4:	50                   	push   %eax
  8015d5:	53                   	push   %ebx
  8015d6:	e8 f7 fb ff ff       	call   8011d2 <fd_lookup>
  8015db:	83 c4 08             	add    $0x8,%esp
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 65                	js     801649 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ee:	ff 30                	pushl  (%eax)
  8015f0:	e8 33 fc ff ff       	call   801228 <dev_lookup>
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 44                	js     801640 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801603:	75 21                	jne    801626 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801605:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80160a:	8b 40 48             	mov    0x48(%eax),%eax
  80160d:	83 ec 04             	sub    $0x4,%esp
  801610:	53                   	push   %ebx
  801611:	50                   	push   %eax
  801612:	68 c4 27 80 00       	push   $0x8027c4
  801617:	e8 d0 eb ff ff       	call   8001ec <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801624:	eb 23                	jmp    801649 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801626:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801629:	8b 52 18             	mov    0x18(%edx),%edx
  80162c:	85 d2                	test   %edx,%edx
  80162e:	74 14                	je     801644 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	ff 75 0c             	pushl  0xc(%ebp)
  801636:	50                   	push   %eax
  801637:	ff d2                	call   *%edx
  801639:	89 c2                	mov    %eax,%edx
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	eb 09                	jmp    801649 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801640:	89 c2                	mov    %eax,%edx
  801642:	eb 05                	jmp    801649 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801644:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801649:	89 d0                	mov    %edx,%eax
  80164b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	53                   	push   %ebx
  801654:	83 ec 14             	sub    $0x14,%esp
  801657:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	ff 75 08             	pushl  0x8(%ebp)
  801661:	e8 6c fb ff ff       	call   8011d2 <fd_lookup>
  801666:	83 c4 08             	add    $0x8,%esp
  801669:	89 c2                	mov    %eax,%edx
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 58                	js     8016c7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801679:	ff 30                	pushl  (%eax)
  80167b:	e8 a8 fb ff ff       	call   801228 <dev_lookup>
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 37                	js     8016be <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80168e:	74 32                	je     8016c2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801690:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801693:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169a:	00 00 00 
	stat->st_isdir = 0;
  80169d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a4:	00 00 00 
	stat->st_dev = dev;
  8016a7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	53                   	push   %ebx
  8016b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b4:	ff 50 14             	call   *0x14(%eax)
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	eb 09                	jmp    8016c7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	eb 05                	jmp    8016c7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016c7:	89 d0                	mov    %edx,%eax
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	56                   	push   %esi
  8016d2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	6a 00                	push   $0x0
  8016d8:	ff 75 08             	pushl  0x8(%ebp)
  8016db:	e8 dc 01 00 00       	call   8018bc <open>
  8016e0:	89 c3                	mov    %eax,%ebx
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 1b                	js     801704 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	50                   	push   %eax
  8016f0:	e8 5b ff ff ff       	call   801650 <fstat>
  8016f5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f7:	89 1c 24             	mov    %ebx,(%esp)
  8016fa:	e8 fd fb ff ff       	call   8012fc <close>
	return r;
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	89 f0                	mov    %esi,%eax
}
  801704:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801707:	5b                   	pop    %ebx
  801708:	5e                   	pop    %esi
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	56                   	push   %esi
  80170f:	53                   	push   %ebx
  801710:	89 c6                	mov    %eax,%esi
  801712:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801714:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80171b:	75 12                	jne    80172f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80171d:	83 ec 0c             	sub    $0xc,%esp
  801720:	6a 01                	push   $0x1
  801722:	e8 87 08 00 00       	call   801fae <ipc_find_env>
  801727:	a3 00 40 80 00       	mov    %eax,0x804000
  80172c:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80172f:	6a 07                	push   $0x7
  801731:	68 00 50 80 00       	push   $0x805000
  801736:	56                   	push   %esi
  801737:	ff 35 00 40 80 00    	pushl  0x804000
  80173d:	e8 29 08 00 00       	call   801f6b <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801742:	83 c4 0c             	add    $0xc,%esp
  801745:	6a 00                	push   $0x0
  801747:	53                   	push   %ebx
  801748:	6a 00                	push   $0x0
  80174a:	e8 bf 07 00 00       	call   801f0e <ipc_recv>
}
  80174f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801752:	5b                   	pop    %ebx
  801753:	5e                   	pop    %esi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
  80175f:	8b 40 0c             	mov    0xc(%eax),%eax
  801762:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801767:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	b8 02 00 00 00       	mov    $0x2,%eax
  801779:	e8 8d ff ff ff       	call   80170b <fsipc>
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8b 40 0c             	mov    0xc(%eax),%eax
  80178c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
  801796:	b8 06 00 00 00       	mov    $0x6,%eax
  80179b:	e8 6b ff ff ff       	call   80170b <fsipc>
}
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 04             	sub    $0x4,%esp
  8017a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c1:	e8 45 ff ff ff       	call   80170b <fsipc>
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 2c                	js     8017f6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ca:	83 ec 08             	sub    $0x8,%esp
  8017cd:	68 00 50 80 00       	push   $0x805000
  8017d2:	53                   	push   %ebx
  8017d3:	e8 e3 ef ff ff       	call   8007bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d8:	a1 80 50 80 00       	mov    0x805080,%eax
  8017dd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e3:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801804:	8b 55 08             	mov    0x8(%ebp),%edx
  801807:	8b 52 0c             	mov    0xc(%edx),%edx
  80180a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801810:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801815:	50                   	push   %eax
  801816:	ff 75 0c             	pushl  0xc(%ebp)
  801819:	68 08 50 80 00       	push   $0x805008
  80181e:	e8 2a f1 ff ff       	call   80094d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 04 00 00 00       	mov    $0x4,%eax
  80182d:	e8 d9 fe ff ff       	call   80170b <fsipc>
	//panic("devfile_write not implemented");
}
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	56                   	push   %esi
  801838:	53                   	push   %ebx
  801839:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	8b 40 0c             	mov    0xc(%eax),%eax
  801842:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801847:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 03 00 00 00       	mov    $0x3,%eax
  801857:	e8 af fe ff ff       	call   80170b <fsipc>
  80185c:	89 c3                	mov    %eax,%ebx
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 51                	js     8018b3 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801862:	39 c6                	cmp    %eax,%esi
  801864:	73 19                	jae    80187f <devfile_read+0x4b>
  801866:	68 30 28 80 00       	push   $0x802830
  80186b:	68 37 28 80 00       	push   $0x802837
  801870:	68 80 00 00 00       	push   $0x80
  801875:	68 4c 28 80 00       	push   $0x80284c
  80187a:	e8 c0 05 00 00       	call   801e3f <_panic>
	assert(r <= PGSIZE);
  80187f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801884:	7e 19                	jle    80189f <devfile_read+0x6b>
  801886:	68 57 28 80 00       	push   $0x802857
  80188b:	68 37 28 80 00       	push   $0x802837
  801890:	68 81 00 00 00       	push   $0x81
  801895:	68 4c 28 80 00       	push   $0x80284c
  80189a:	e8 a0 05 00 00       	call   801e3f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	50                   	push   %eax
  8018a3:	68 00 50 80 00       	push   $0x805000
  8018a8:	ff 75 0c             	pushl  0xc(%ebp)
  8018ab:	e8 9d f0 ff ff       	call   80094d <memmove>
	return r;
  8018b0:	83 c4 10             	add    $0x10,%esp
}
  8018b3:	89 d8                	mov    %ebx,%eax
  8018b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5e                   	pop    %esi
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 20             	sub    $0x20,%esp
  8018c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018c6:	53                   	push   %ebx
  8018c7:	e8 b6 ee ff ff       	call   800782 <strlen>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d4:	7f 67                	jg     80193d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d6:	83 ec 0c             	sub    $0xc,%esp
  8018d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018dc:	50                   	push   %eax
  8018dd:	e8 a1 f8 ff ff       	call   801183 <fd_alloc>
  8018e2:	83 c4 10             	add    $0x10,%esp
		return r;
  8018e5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 57                	js     801942 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	53                   	push   %ebx
  8018ef:	68 00 50 80 00       	push   $0x805000
  8018f4:	e8 c2 ee ff ff       	call   8007bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fc:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801901:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801904:	b8 01 00 00 00       	mov    $0x1,%eax
  801909:	e8 fd fd ff ff       	call   80170b <fsipc>
  80190e:	89 c3                	mov    %eax,%ebx
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	79 14                	jns    80192b <open+0x6f>
		
		fd_close(fd, 0);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	6a 00                	push   $0x0
  80191c:	ff 75 f4             	pushl  -0xc(%ebp)
  80191f:	e8 57 f9 ff ff       	call   80127b <fd_close>
		return r;
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	89 da                	mov    %ebx,%edx
  801929:	eb 17                	jmp    801942 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	ff 75 f4             	pushl  -0xc(%ebp)
  801931:	e8 26 f8 ff ff       	call   80115c <fd2num>
  801936:	89 c2                	mov    %eax,%edx
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	eb 05                	jmp    801942 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80193d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801942:	89 d0                	mov    %edx,%eax
  801944:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801947:	c9                   	leave  
  801948:	c3                   	ret    

00801949 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	b8 08 00 00 00       	mov    $0x8,%eax
  801959:	e8 ad fd ff ff       	call   80170b <fsipc>
}
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	ff 75 08             	pushl  0x8(%ebp)
  80196e:	e8 f9 f7 ff ff       	call   80116c <fd2data>
  801973:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801975:	83 c4 08             	add    $0x8,%esp
  801978:	68 63 28 80 00       	push   $0x802863
  80197d:	53                   	push   %ebx
  80197e:	e8 38 ee ff ff       	call   8007bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801983:	8b 46 04             	mov    0x4(%esi),%eax
  801986:	2b 06                	sub    (%esi),%eax
  801988:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80198e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801995:	00 00 00 
	stat->st_dev = &devpipe;
  801998:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80199f:	30 80 00 
	return 0;
}
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019aa:	5b                   	pop    %ebx
  8019ab:	5e                   	pop    %esi
  8019ac:	5d                   	pop    %ebp
  8019ad:	c3                   	ret    

008019ae <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	53                   	push   %ebx
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019b8:	53                   	push   %ebx
  8019b9:	6a 00                	push   $0x0
  8019bb:	e8 83 f2 ff ff       	call   800c43 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019c0:	89 1c 24             	mov    %ebx,(%esp)
  8019c3:	e8 a4 f7 ff ff       	call   80116c <fd2data>
  8019c8:	83 c4 08             	add    $0x8,%esp
  8019cb:	50                   	push   %eax
  8019cc:	6a 00                	push   $0x0
  8019ce:	e8 70 f2 ff ff       	call   800c43 <sys_page_unmap>
}
  8019d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	57                   	push   %edi
  8019dc:	56                   	push   %esi
  8019dd:	53                   	push   %ebx
  8019de:	83 ec 1c             	sub    $0x1c,%esp
  8019e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019e4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8019eb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8019f4:	e8 ee 05 00 00       	call   801fe7 <pageref>
  8019f9:	89 c3                	mov    %eax,%ebx
  8019fb:	89 3c 24             	mov    %edi,(%esp)
  8019fe:	e8 e4 05 00 00       	call   801fe7 <pageref>
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	39 c3                	cmp    %eax,%ebx
  801a08:	0f 94 c1             	sete   %cl
  801a0b:	0f b6 c9             	movzbl %cl,%ecx
  801a0e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a11:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a17:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a1a:	39 ce                	cmp    %ecx,%esi
  801a1c:	74 1b                	je     801a39 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a1e:	39 c3                	cmp    %eax,%ebx
  801a20:	75 c4                	jne    8019e6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a22:	8b 42 58             	mov    0x58(%edx),%eax
  801a25:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a28:	50                   	push   %eax
  801a29:	56                   	push   %esi
  801a2a:	68 6a 28 80 00       	push   $0x80286a
  801a2f:	e8 b8 e7 ff ff       	call   8001ec <cprintf>
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	eb ad                	jmp    8019e6 <_pipeisclosed+0xe>
	}
}
  801a39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3f:	5b                   	pop    %ebx
  801a40:	5e                   	pop    %esi
  801a41:	5f                   	pop    %edi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	83 ec 28             	sub    $0x28,%esp
  801a4d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a50:	56                   	push   %esi
  801a51:	e8 16 f7 ff ff       	call   80116c <fd2data>
  801a56:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	bf 00 00 00 00       	mov    $0x0,%edi
  801a60:	eb 4b                	jmp    801aad <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a62:	89 da                	mov    %ebx,%edx
  801a64:	89 f0                	mov    %esi,%eax
  801a66:	e8 6d ff ff ff       	call   8019d8 <_pipeisclosed>
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	75 48                	jne    801ab7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a6f:	e8 2b f1 ff ff       	call   800b9f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a74:	8b 43 04             	mov    0x4(%ebx),%eax
  801a77:	8b 0b                	mov    (%ebx),%ecx
  801a79:	8d 51 20             	lea    0x20(%ecx),%edx
  801a7c:	39 d0                	cmp    %edx,%eax
  801a7e:	73 e2                	jae    801a62 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a83:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a87:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a8a:	89 c2                	mov    %eax,%edx
  801a8c:	c1 fa 1f             	sar    $0x1f,%edx
  801a8f:	89 d1                	mov    %edx,%ecx
  801a91:	c1 e9 1b             	shr    $0x1b,%ecx
  801a94:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a97:	83 e2 1f             	and    $0x1f,%edx
  801a9a:	29 ca                	sub    %ecx,%edx
  801a9c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aa0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aa4:	83 c0 01             	add    $0x1,%eax
  801aa7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aaa:	83 c7 01             	add    $0x1,%edi
  801aad:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ab0:	75 c2                	jne    801a74 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab5:	eb 05                	jmp    801abc <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801abc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abf:	5b                   	pop    %ebx
  801ac0:	5e                   	pop    %esi
  801ac1:	5f                   	pop    %edi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	57                   	push   %edi
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 18             	sub    $0x18,%esp
  801acd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ad0:	57                   	push   %edi
  801ad1:	e8 96 f6 ff ff       	call   80116c <fd2data>
  801ad6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae0:	eb 3d                	jmp    801b1f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ae2:	85 db                	test   %ebx,%ebx
  801ae4:	74 04                	je     801aea <devpipe_read+0x26>
				return i;
  801ae6:	89 d8                	mov    %ebx,%eax
  801ae8:	eb 44                	jmp    801b2e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aea:	89 f2                	mov    %esi,%edx
  801aec:	89 f8                	mov    %edi,%eax
  801aee:	e8 e5 fe ff ff       	call   8019d8 <_pipeisclosed>
  801af3:	85 c0                	test   %eax,%eax
  801af5:	75 32                	jne    801b29 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801af7:	e8 a3 f0 ff ff       	call   800b9f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801afc:	8b 06                	mov    (%esi),%eax
  801afe:	3b 46 04             	cmp    0x4(%esi),%eax
  801b01:	74 df                	je     801ae2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b03:	99                   	cltd   
  801b04:	c1 ea 1b             	shr    $0x1b,%edx
  801b07:	01 d0                	add    %edx,%eax
  801b09:	83 e0 1f             	and    $0x1f,%eax
  801b0c:	29 d0                	sub    %edx,%eax
  801b0e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b16:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b19:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1c:	83 c3 01             	add    $0x1,%ebx
  801b1f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b22:	75 d8                	jne    801afc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b24:	8b 45 10             	mov    0x10(%ebp),%eax
  801b27:	eb 05                	jmp    801b2e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b41:	50                   	push   %eax
  801b42:	e8 3c f6 ff ff       	call   801183 <fd_alloc>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	89 c2                	mov    %eax,%edx
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	0f 88 2c 01 00 00    	js     801c80 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b54:	83 ec 04             	sub    $0x4,%esp
  801b57:	68 07 04 00 00       	push   $0x407
  801b5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 58 f0 ff ff       	call   800bbe <sys_page_alloc>
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	89 c2                	mov    %eax,%edx
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	0f 88 0d 01 00 00    	js     801c80 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	e8 04 f6 ff ff       	call   801183 <fd_alloc>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 e2 00 00 00    	js     801c6e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	68 07 04 00 00       	push   $0x407
  801b94:	ff 75 f0             	pushl  -0x10(%ebp)
  801b97:	6a 00                	push   $0x0
  801b99:	e8 20 f0 ff ff       	call   800bbe <sys_page_alloc>
  801b9e:	89 c3                	mov    %eax,%ebx
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 c3 00 00 00    	js     801c6e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb1:	e8 b6 f5 ff ff       	call   80116c <fd2data>
  801bb6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb8:	83 c4 0c             	add    $0xc,%esp
  801bbb:	68 07 04 00 00       	push   $0x407
  801bc0:	50                   	push   %eax
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 f6 ef ff ff       	call   800bbe <sys_page_alloc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	0f 88 89 00 00 00    	js     801c5e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdb:	e8 8c f5 ff ff       	call   80116c <fd2data>
  801be0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801be7:	50                   	push   %eax
  801be8:	6a 00                	push   $0x0
  801bea:	56                   	push   %esi
  801beb:	6a 00                	push   $0x0
  801bed:	e8 0f f0 ff ff       	call   800c01 <sys_page_map>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	83 c4 20             	add    $0x20,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 55                	js     801c50 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bfb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c04:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c09:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c10:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c19:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c1e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c25:	83 ec 0c             	sub    $0xc,%esp
  801c28:	ff 75 f4             	pushl  -0xc(%ebp)
  801c2b:	e8 2c f5 ff ff       	call   80115c <fd2num>
  801c30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c33:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c35:	83 c4 04             	add    $0x4,%esp
  801c38:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3b:	e8 1c f5 ff ff       	call   80115c <fd2num>
  801c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c43:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	ba 00 00 00 00       	mov    $0x0,%edx
  801c4e:	eb 30                	jmp    801c80 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c50:	83 ec 08             	sub    $0x8,%esp
  801c53:	56                   	push   %esi
  801c54:	6a 00                	push   $0x0
  801c56:	e8 e8 ef ff ff       	call   800c43 <sys_page_unmap>
  801c5b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c5e:	83 ec 08             	sub    $0x8,%esp
  801c61:	ff 75 f0             	pushl  -0x10(%ebp)
  801c64:	6a 00                	push   $0x0
  801c66:	e8 d8 ef ff ff       	call   800c43 <sys_page_unmap>
  801c6b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c6e:	83 ec 08             	sub    $0x8,%esp
  801c71:	ff 75 f4             	pushl  -0xc(%ebp)
  801c74:	6a 00                	push   $0x0
  801c76:	e8 c8 ef ff ff       	call   800c43 <sys_page_unmap>
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c80:	89 d0                	mov    %edx,%eax
  801c82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c92:	50                   	push   %eax
  801c93:	ff 75 08             	pushl  0x8(%ebp)
  801c96:	e8 37 f5 ff ff       	call   8011d2 <fd_lookup>
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 18                	js     801cba <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca8:	e8 bf f4 ff ff       	call   80116c <fd2data>
	return _pipeisclosed(fd, p);
  801cad:	89 c2                	mov    %eax,%edx
  801caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb2:	e8 21 fd ff ff       	call   8019d8 <_pipeisclosed>
  801cb7:	83 c4 10             	add    $0x10,%esp
}
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    

00801cbc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ccc:	68 82 28 80 00       	push   $0x802882
  801cd1:	ff 75 0c             	pushl  0xc(%ebp)
  801cd4:	e8 e2 ea ff ff       	call   8007bb <strcpy>
	return 0;
}
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cec:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf7:	eb 2d                	jmp    801d26 <devcons_write+0x46>
		m = n - tot;
  801cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cfc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cfe:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d01:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d06:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d09:	83 ec 04             	sub    $0x4,%esp
  801d0c:	53                   	push   %ebx
  801d0d:	03 45 0c             	add    0xc(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	57                   	push   %edi
  801d12:	e8 36 ec ff ff       	call   80094d <memmove>
		sys_cputs(buf, m);
  801d17:	83 c4 08             	add    $0x8,%esp
  801d1a:	53                   	push   %ebx
  801d1b:	57                   	push   %edi
  801d1c:	e8 e1 ed ff ff       	call   800b02 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d21:	01 de                	add    %ebx,%esi
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	89 f0                	mov    %esi,%eax
  801d28:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d2b:	72 cc                	jb     801cf9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    

00801d35 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
  801d3b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d40:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d44:	74 2a                	je     801d70 <devcons_read+0x3b>
  801d46:	eb 05                	jmp    801d4d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d48:	e8 52 ee ff ff       	call   800b9f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d4d:	e8 ce ed ff ff       	call   800b20 <sys_cgetc>
  801d52:	85 c0                	test   %eax,%eax
  801d54:	74 f2                	je     801d48 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 16                	js     801d70 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d5a:	83 f8 04             	cmp    $0x4,%eax
  801d5d:	74 0c                	je     801d6b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d62:	88 02                	mov    %al,(%edx)
	return 1;
  801d64:	b8 01 00 00 00       	mov    $0x1,%eax
  801d69:	eb 05                	jmp    801d70 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d7e:	6a 01                	push   $0x1
  801d80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d83:	50                   	push   %eax
  801d84:	e8 79 ed ff ff       	call   800b02 <sys_cputs>
}
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <getchar>:

int
getchar(void)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d94:	6a 01                	push   $0x1
  801d96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d99:	50                   	push   %eax
  801d9a:	6a 00                	push   $0x0
  801d9c:	e8 97 f6 ff ff       	call   801438 <read>
	if (r < 0)
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	85 c0                	test   %eax,%eax
  801da6:	78 0f                	js     801db7 <getchar+0x29>
		return r;
	if (r < 1)
  801da8:	85 c0                	test   %eax,%eax
  801daa:	7e 06                	jle    801db2 <getchar+0x24>
		return -E_EOF;
	return c;
  801dac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801db0:	eb 05                	jmp    801db7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801db2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc2:	50                   	push   %eax
  801dc3:	ff 75 08             	pushl  0x8(%ebp)
  801dc6:	e8 07 f4 ff ff       	call   8011d2 <fd_lookup>
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 11                	js     801de3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ddb:	39 10                	cmp    %edx,(%eax)
  801ddd:	0f 94 c0             	sete   %al
  801de0:	0f b6 c0             	movzbl %al,%eax
}
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <opencons>:

int
opencons(void)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801deb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dee:	50                   	push   %eax
  801def:	e8 8f f3 ff ff       	call   801183 <fd_alloc>
  801df4:	83 c4 10             	add    $0x10,%esp
		return r;
  801df7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 3e                	js     801e3b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dfd:	83 ec 04             	sub    $0x4,%esp
  801e00:	68 07 04 00 00       	push   $0x407
  801e05:	ff 75 f4             	pushl  -0xc(%ebp)
  801e08:	6a 00                	push   $0x0
  801e0a:	e8 af ed ff ff       	call   800bbe <sys_page_alloc>
  801e0f:	83 c4 10             	add    $0x10,%esp
		return r;
  801e12:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e14:	85 c0                	test   %eax,%eax
  801e16:	78 23                	js     801e3b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e18:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e21:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e26:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e2d:	83 ec 0c             	sub    $0xc,%esp
  801e30:	50                   	push   %eax
  801e31:	e8 26 f3 ff ff       	call   80115c <fd2num>
  801e36:	89 c2                	mov    %eax,%edx
  801e38:	83 c4 10             	add    $0x10,%esp
}
  801e3b:	89 d0                	mov    %edx,%eax
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e44:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e47:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e4d:	e8 2e ed ff ff       	call   800b80 <sys_getenvid>
  801e52:	83 ec 0c             	sub    $0xc,%esp
  801e55:	ff 75 0c             	pushl  0xc(%ebp)
  801e58:	ff 75 08             	pushl  0x8(%ebp)
  801e5b:	56                   	push   %esi
  801e5c:	50                   	push   %eax
  801e5d:	68 90 28 80 00       	push   $0x802890
  801e62:	e8 85 e3 ff ff       	call   8001ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e67:	83 c4 18             	add    $0x18,%esp
  801e6a:	53                   	push   %ebx
  801e6b:	ff 75 10             	pushl  0x10(%ebp)
  801e6e:	e8 28 e3 ff ff       	call   80019b <vcprintf>
	cprintf("\n");
  801e73:	c7 04 24 cf 22 80 00 	movl   $0x8022cf,(%esp)
  801e7a:	e8 6d e3 ff ff       	call   8001ec <cprintf>
  801e7f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e82:	cc                   	int3   
  801e83:	eb fd                	jmp    801e82 <_panic+0x43>

00801e85 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801e8b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e92:	75 4c                	jne    801ee0 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801e94:	a1 04 40 80 00       	mov    0x804004,%eax
  801e99:	8b 40 48             	mov    0x48(%eax),%eax
  801e9c:	83 ec 04             	sub    $0x4,%esp
  801e9f:	6a 07                	push   $0x7
  801ea1:	68 00 f0 bf ee       	push   $0xeebff000
  801ea6:	50                   	push   %eax
  801ea7:	e8 12 ed ff ff       	call   800bbe <sys_page_alloc>
		if(retv != 0){
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	74 14                	je     801ec7 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801eb3:	83 ec 04             	sub    $0x4,%esp
  801eb6:	68 b4 28 80 00       	push   $0x8028b4
  801ebb:	6a 27                	push   $0x27
  801ebd:	68 e0 28 80 00       	push   $0x8028e0
  801ec2:	e8 78 ff ff ff       	call   801e3f <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ec7:	a1 04 40 80 00       	mov    0x804004,%eax
  801ecc:	8b 40 48             	mov    0x48(%eax),%eax
  801ecf:	83 ec 08             	sub    $0x8,%esp
  801ed2:	68 ea 1e 80 00       	push   $0x801eea
  801ed7:	50                   	push   %eax
  801ed8:	e8 2c ee ff ff       	call   800d09 <sys_env_set_pgfault_upcall>
  801edd:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    

00801eea <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eea:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eeb:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ef0:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  801ef2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  801ef5:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  801ef9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  801efe:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  801f02:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  801f04:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  801f07:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  801f08:	83 c4 04             	add    $0x4,%esp
	popfl
  801f0b:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f0c:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f0d:	c3                   	ret    

00801f0e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f16:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	ff 75 0c             	pushl  0xc(%ebp)
  801f1f:	e8 4a ee ff ff       	call   800d6e <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 f6                	test   %esi,%esi
  801f29:	74 1c                	je     801f47 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801f2b:	a1 04 40 80 00       	mov    0x804004,%eax
  801f30:	8b 40 78             	mov    0x78(%eax),%eax
  801f33:	89 06                	mov    %eax,(%esi)
  801f35:	eb 10                	jmp    801f47 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801f37:	83 ec 0c             	sub    $0xc,%esp
  801f3a:	68 ee 28 80 00       	push   $0x8028ee
  801f3f:	e8 a8 e2 ff ff       	call   8001ec <cprintf>
  801f44:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801f47:	a1 04 40 80 00       	mov    0x804004,%eax
  801f4c:	8b 50 74             	mov    0x74(%eax),%edx
  801f4f:	85 d2                	test   %edx,%edx
  801f51:	74 e4                	je     801f37 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801f53:	85 db                	test   %ebx,%ebx
  801f55:	74 05                	je     801f5c <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801f57:	8b 40 74             	mov    0x74(%eax),%eax
  801f5a:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801f61:	8b 40 70             	mov    0x70(%eax),%eax

}
  801f64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    

00801f6b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	57                   	push   %edi
  801f6f:	56                   	push   %esi
  801f70:	53                   	push   %ebx
  801f71:	83 ec 0c             	sub    $0xc,%esp
  801f74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f77:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801f7d:	85 db                	test   %ebx,%ebx
  801f7f:	75 13                	jne    801f94 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801f81:	6a 00                	push   $0x0
  801f83:	68 00 00 c0 ee       	push   $0xeec00000
  801f88:	56                   	push   %esi
  801f89:	57                   	push   %edi
  801f8a:	e8 bc ed ff ff       	call   800d4b <sys_ipc_try_send>
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	eb 0e                	jmp    801fa2 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801f94:	ff 75 14             	pushl  0x14(%ebp)
  801f97:	53                   	push   %ebx
  801f98:	56                   	push   %esi
  801f99:	57                   	push   %edi
  801f9a:	e8 ac ed ff ff       	call   800d4b <sys_ipc_try_send>
  801f9f:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	75 d7                	jne    801f7d <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa9:	5b                   	pop    %ebx
  801faa:	5e                   	pop    %esi
  801fab:	5f                   	pop    %edi
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    

00801fae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fbc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc2:	8b 52 50             	mov    0x50(%edx),%edx
  801fc5:	39 ca                	cmp    %ecx,%edx
  801fc7:	75 0d                	jne    801fd6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fc9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fcc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd1:	8b 40 48             	mov    0x48(%eax),%eax
  801fd4:	eb 0f                	jmp    801fe5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd6:	83 c0 01             	add    $0x1,%eax
  801fd9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fde:	75 d9                	jne    801fb9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    

00801fe7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fed:	89 d0                	mov    %edx,%eax
  801fef:	c1 e8 16             	shr    $0x16,%eax
  801ff2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffe:	f6 c1 01             	test   $0x1,%cl
  802001:	74 1d                	je     802020 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802003:	c1 ea 0c             	shr    $0xc,%edx
  802006:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80200d:	f6 c2 01             	test   $0x1,%dl
  802010:	74 0e                	je     802020 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802012:	c1 ea 0c             	shr    $0xc,%edx
  802015:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80201c:	ef 
  80201d:	0f b7 c0             	movzwl %ax,%eax
}
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	66 90                	xchg   %ax,%ax
  802024:	66 90                	xchg   %ax,%ax
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

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
