
obj/user/forktree:     file format elf32-i386


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
  80003d:	e8 36 0b 00 00       	call   800b78 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 a0 13 80 00       	push   $0x8013a0
  80004c:	e8 93 01 00 00       	call   8001e4 <cprintf>

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
  80007e:	e8 f7 06 00 00       	call   80077a <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 52                	jg     8000dd <forkchild+0x6e>
		return;
	cprintf("\t at forkchild.\n");
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	68 b1 13 80 00       	push   $0x8013b1
  800093:	e8 4c 01 00 00       	call   8001e4 <cprintf>
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800098:	89 f0                	mov    %esi,%eax
  80009a:	0f be f0             	movsbl %al,%esi
  80009d:	89 34 24             	mov    %esi,(%esp)
  8000a0:	53                   	push   %ebx
  8000a1:	68 c2 13 80 00       	push   $0x8013c2
  8000a6:	6a 04                	push   $0x4
  8000a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ab:	50                   	push   %eax
  8000ac:	e8 af 06 00 00       	call   800760 <snprintf>
	if (fork() == 0) {
  8000b1:	83 c4 20             	add    $0x20,%esp
  8000b4:	e8 97 0d 00 00       	call   800e50 <fork>
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	75 20                	jne    8000dd <forkchild+0x6e>
		cprintf("\t fork() == 0");
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	68 c7 13 80 00       	push   $0x8013c7
  8000c5:	e8 1a 01 00 00       	call   8001e4 <cprintf>
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
  8000ea:	68 b0 13 80 00       	push   $0x8013b0
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
  800104:	e8 6f 0a 00 00       	call   800b78 <sys_getenvid>
  800109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011b:	85 db                	test   %ebx,%ebx
  80011d:	7e 07                	jle    800126 <libmain+0x2d>
		binaryname = argv[0];
  80011f:	8b 06                	mov    (%esi),%eax
  800121:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800142:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800145:	6a 00                	push   $0x0
  800147:	e8 eb 09 00 00       	call   800b37 <sys_env_destroy>
}
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	53                   	push   %ebx
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015b:	8b 13                	mov    (%ebx),%edx
  80015d:	8d 42 01             	lea    0x1(%edx),%eax
  800160:	89 03                	mov    %eax,(%ebx)
  800162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800165:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800169:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016e:	75 1a                	jne    80018a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800170:	83 ec 08             	sub    $0x8,%esp
  800173:	68 ff 00 00 00       	push   $0xff
  800178:	8d 43 08             	lea    0x8(%ebx),%eax
  80017b:	50                   	push   %eax
  80017c:	e8 79 09 00 00       	call   800afa <sys_cputs>
		b->idx = 0;
  800181:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800187:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80019c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a3:	00 00 00 
	b.cnt = 0;
  8001a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b0:	ff 75 0c             	pushl  0xc(%ebp)
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001bc:	50                   	push   %eax
  8001bd:	68 51 01 80 00       	push   $0x800151
  8001c2:	e8 54 01 00 00       	call   80031b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c7:	83 c4 08             	add    $0x8,%esp
  8001ca:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d6:	50                   	push   %eax
  8001d7:	e8 1e 09 00 00       	call   800afa <sys_cputs>

	return b.cnt;
}
  8001dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ed:	50                   	push   %eax
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	e8 9d ff ff ff       	call   800193 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	57                   	push   %edi
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	83 ec 1c             	sub    $0x1c,%esp
  800201:	89 c7                	mov    %eax,%edi
  800203:	89 d6                	mov    %edx,%esi
  800205:	8b 45 08             	mov    0x8(%ebp),%eax
  800208:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800211:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800214:	bb 00 00 00 00       	mov    $0x0,%ebx
  800219:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80021c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80021f:	39 d3                	cmp    %edx,%ebx
  800221:	72 05                	jb     800228 <printnum+0x30>
  800223:	39 45 10             	cmp    %eax,0x10(%ebp)
  800226:	77 45                	ja     80026d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800228:	83 ec 0c             	sub    $0xc,%esp
  80022b:	ff 75 18             	pushl  0x18(%ebp)
  80022e:	8b 45 14             	mov    0x14(%ebp),%eax
  800231:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800234:	53                   	push   %ebx
  800235:	ff 75 10             	pushl  0x10(%ebp)
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023e:	ff 75 e0             	pushl  -0x20(%ebp)
  800241:	ff 75 dc             	pushl  -0x24(%ebp)
  800244:	ff 75 d8             	pushl  -0x28(%ebp)
  800247:	e8 c4 0e 00 00       	call   801110 <__udivdi3>
  80024c:	83 c4 18             	add    $0x18,%esp
  80024f:	52                   	push   %edx
  800250:	50                   	push   %eax
  800251:	89 f2                	mov    %esi,%edx
  800253:	89 f8                	mov    %edi,%eax
  800255:	e8 9e ff ff ff       	call   8001f8 <printnum>
  80025a:	83 c4 20             	add    $0x20,%esp
  80025d:	eb 18                	jmp    800277 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	56                   	push   %esi
  800263:	ff 75 18             	pushl  0x18(%ebp)
  800266:	ff d7                	call   *%edi
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	eb 03                	jmp    800270 <printnum+0x78>
  80026d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800270:	83 eb 01             	sub    $0x1,%ebx
  800273:	85 db                	test   %ebx,%ebx
  800275:	7f e8                	jg     80025f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	56                   	push   %esi
  80027b:	83 ec 04             	sub    $0x4,%esp
  80027e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800281:	ff 75 e0             	pushl  -0x20(%ebp)
  800284:	ff 75 dc             	pushl  -0x24(%ebp)
  800287:	ff 75 d8             	pushl  -0x28(%ebp)
  80028a:	e8 b1 0f 00 00       	call   801240 <__umoddi3>
  80028f:	83 c4 14             	add    $0x14,%esp
  800292:	0f be 80 df 13 80 00 	movsbl 0x8013df(%eax),%eax
  800299:	50                   	push   %eax
  80029a:	ff d7                	call   *%edi
}
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002aa:	83 fa 01             	cmp    $0x1,%edx
  8002ad:	7e 0e                	jle    8002bd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	8b 52 04             	mov    0x4(%edx),%edx
  8002bb:	eb 22                	jmp    8002df <getuint+0x38>
	else if (lflag)
  8002bd:	85 d2                	test   %edx,%edx
  8002bf:	74 10                	je     8002d1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cf:	eb 0e                	jmp    8002df <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f0:	73 0a                	jae    8002fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	88 02                	mov    %al,(%edx)
}
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800304:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800307:	50                   	push   %eax
  800308:	ff 75 10             	pushl  0x10(%ebp)
  80030b:	ff 75 0c             	pushl  0xc(%ebp)
  80030e:	ff 75 08             	pushl  0x8(%ebp)
  800311:	e8 05 00 00 00       	call   80031b <vprintfmt>
	va_end(ap);
}
  800316:	83 c4 10             	add    $0x10,%esp
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 2c             	sub    $0x2c,%esp
  800324:	8b 75 08             	mov    0x8(%ebp),%esi
  800327:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032d:	eb 12                	jmp    800341 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032f:	85 c0                	test   %eax,%eax
  800331:	0f 84 d3 03 00 00    	je     80070a <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800337:	83 ec 08             	sub    $0x8,%esp
  80033a:	53                   	push   %ebx
  80033b:	50                   	push   %eax
  80033c:	ff d6                	call   *%esi
  80033e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800341:	83 c7 01             	add    $0x1,%edi
  800344:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800348:	83 f8 25             	cmp    $0x25,%eax
  80034b:	75 e2                	jne    80032f <vprintfmt+0x14>
  80034d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800351:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800358:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80035f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800366:	ba 00 00 00 00       	mov    $0x0,%edx
  80036b:	eb 07                	jmp    800374 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800370:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8d 47 01             	lea    0x1(%edi),%eax
  800377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037a:	0f b6 07             	movzbl (%edi),%eax
  80037d:	0f b6 c8             	movzbl %al,%ecx
  800380:	83 e8 23             	sub    $0x23,%eax
  800383:	3c 55                	cmp    $0x55,%al
  800385:	0f 87 64 03 00 00    	ja     8006ef <vprintfmt+0x3d4>
  80038b:	0f b6 c0             	movzbl %al,%eax
  80038e:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800398:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80039c:	eb d6                	jmp    800374 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ac:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003b6:	83 fa 09             	cmp    $0x9,%edx
  8003b9:	77 39                	ja     8003f4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003be:	eb e9                	jmp    8003a9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c9:	8b 00                	mov    (%eax),%eax
  8003cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d1:	eb 27                	jmp    8003fa <vprintfmt+0xdf>
  8003d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003dd:	0f 49 c8             	cmovns %eax,%ecx
  8003e0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	eb 8c                	jmp    800374 <vprintfmt+0x59>
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003eb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f2:	eb 80                	jmp    800374 <vprintfmt+0x59>
  8003f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003f7:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fe:	0f 89 70 ff ff ff    	jns    800374 <vprintfmt+0x59>
				width = precision, precision = -1;
  800404:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800407:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800411:	e9 5e ff ff ff       	jmp    800374 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800416:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041c:	e9 53 ff ff ff       	jmp    800374 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 50 04             	lea    0x4(%eax),%edx
  800427:	89 55 14             	mov    %edx,0x14(%ebp)
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	53                   	push   %ebx
  80042e:	ff 30                	pushl  (%eax)
  800430:	ff d6                	call   *%esi
			break;
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800438:	e9 04 ff ff ff       	jmp    800341 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 00                	mov    (%eax),%eax
  800448:	99                   	cltd   
  800449:	31 d0                	xor    %edx,%eax
  80044b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044d:	83 f8 08             	cmp    $0x8,%eax
  800450:	7f 0b                	jg     80045d <vprintfmt+0x142>
  800452:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	75 18                	jne    800475 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80045d:	50                   	push   %eax
  80045e:	68 f7 13 80 00       	push   $0x8013f7
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 94 fe ff ff       	call   8002fe <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800470:	e9 cc fe ff ff       	jmp    800341 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800475:	52                   	push   %edx
  800476:	68 00 14 80 00       	push   $0x801400
  80047b:	53                   	push   %ebx
  80047c:	56                   	push   %esi
  80047d:	e8 7c fe ff ff       	call   8002fe <printfmt>
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800488:	e9 b4 fe ff ff       	jmp    800341 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 50 04             	lea    0x4(%eax),%edx
  800493:	89 55 14             	mov    %edx,0x14(%ebp)
  800496:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800498:	85 ff                	test   %edi,%edi
  80049a:	b8 f0 13 80 00       	mov    $0x8013f0,%eax
  80049f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	0f 8e 94 00 00 00    	jle    800540 <vprintfmt+0x225>
  8004ac:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b0:	0f 84 98 00 00 00    	je     80054e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	ff 75 c8             	pushl  -0x38(%ebp)
  8004bc:	57                   	push   %edi
  8004bd:	e8 d0 02 00 00       	call   800792 <strnlen>
  8004c2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c5:	29 c1                	sub    %eax,%ecx
  8004c7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004ca:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004cd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	eb 0f                	jmp    8004ea <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	83 ef 01             	sub    $0x1,%edi
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	7f ed                	jg     8004db <vprintfmt+0x1c0>
  8004ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004f4:	85 c9                	test   %ecx,%ecx
  8004f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fb:	0f 49 c1             	cmovns %ecx,%eax
  8004fe:	29 c1                	sub    %eax,%ecx
  800500:	89 75 08             	mov    %esi,0x8(%ebp)
  800503:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800506:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800509:	89 cb                	mov    %ecx,%ebx
  80050b:	eb 4d                	jmp    80055a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800511:	74 1b                	je     80052e <vprintfmt+0x213>
  800513:	0f be c0             	movsbl %al,%eax
  800516:	83 e8 20             	sub    $0x20,%eax
  800519:	83 f8 5e             	cmp    $0x5e,%eax
  80051c:	76 10                	jbe    80052e <vprintfmt+0x213>
					putch('?', putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	ff 75 0c             	pushl  0xc(%ebp)
  800524:	6a 3f                	push   $0x3f
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	eb 0d                	jmp    80053b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	ff 75 0c             	pushl  0xc(%ebp)
  800534:	52                   	push   %edx
  800535:	ff 55 08             	call   *0x8(%ebp)
  800538:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053b:	83 eb 01             	sub    $0x1,%ebx
  80053e:	eb 1a                	jmp    80055a <vprintfmt+0x23f>
  800540:	89 75 08             	mov    %esi,0x8(%ebp)
  800543:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800546:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800549:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054c:	eb 0c                	jmp    80055a <vprintfmt+0x23f>
  80054e:	89 75 08             	mov    %esi,0x8(%ebp)
  800551:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800554:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800557:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	0f be d0             	movsbl %al,%edx
  800564:	85 d2                	test   %edx,%edx
  800566:	74 23                	je     80058b <vprintfmt+0x270>
  800568:	85 f6                	test   %esi,%esi
  80056a:	78 a1                	js     80050d <vprintfmt+0x1f2>
  80056c:	83 ee 01             	sub    $0x1,%esi
  80056f:	79 9c                	jns    80050d <vprintfmt+0x1f2>
  800571:	89 df                	mov    %ebx,%edi
  800573:	8b 75 08             	mov    0x8(%ebp),%esi
  800576:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800579:	eb 18                	jmp    800593 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	6a 20                	push   $0x20
  800581:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800583:	83 ef 01             	sub    $0x1,%edi
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	eb 08                	jmp    800593 <vprintfmt+0x278>
  80058b:	89 df                	mov    %ebx,%edi
  80058d:	8b 75 08             	mov    0x8(%ebp),%esi
  800590:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800593:	85 ff                	test   %edi,%edi
  800595:	7f e4                	jg     80057b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059a:	e9 a2 fd ff ff       	jmp    800341 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059f:	83 fa 01             	cmp    $0x1,%edx
  8005a2:	7e 16                	jle    8005ba <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 08             	lea    0x8(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 50 04             	mov    0x4(%eax),%edx
  8005b0:	8b 00                	mov    (%eax),%eax
  8005b2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005b5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005b8:	eb 32                	jmp    8005ec <vprintfmt+0x2d1>
	else if (lflag)
  8005ba:	85 d2                	test   %edx,%edx
  8005bc:	74 18                	je     8005d6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005cc:	89 c1                	mov    %eax,%ecx
  8005ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d4:	eb 16                	jmp    8005ec <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e4:	89 c1                	mov    %eax,%ecx
  8005e6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005ef:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f8:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800601:	0f 89 b0 00 00 00    	jns    8006b7 <vprintfmt+0x39c>
				putch('-', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 2d                	push   $0x2d
  80060d:	ff d6                	call   *%esi
				num = -(long long) num;
  80060f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800612:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800615:	f7 d8                	neg    %eax
  800617:	83 d2 00             	adc    $0x0,%edx
  80061a:	f7 da                	neg    %edx
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800622:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	e9 88 00 00 00       	jmp    8006b7 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 70 fc ff ff       	call   8002a7 <getuint>
  800637:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80063d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800642:	eb 73                	jmp    8006b7 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800644:	8d 45 14             	lea    0x14(%ebp),%eax
  800647:	e8 5b fc ff ff       	call   8002a7 <getuint>
  80064c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 58                	push   $0x58
  800658:	ff d6                	call   *%esi
			putch('X', putdat);
  80065a:	83 c4 08             	add    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 58                	push   $0x58
  800660:	ff d6                	call   *%esi
			putch('X', putdat);
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	6a 58                	push   $0x58
  800668:	ff d6                	call   *%esi
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80066d:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800672:	eb 43                	jmp    8006b7 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 30                	push   $0x30
  80067a:	ff d6                	call   *%esi
			putch('x', putdat);
  80067c:	83 c4 08             	add    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 78                	push   $0x78
  800682:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	ba 00 00 00 00       	mov    $0x0,%edx
  800694:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800697:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a2:	eb 13                	jmp    8006b7 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a7:	e8 fb fb ff ff       	call   8002a7 <getuint>
  8006ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006af:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006b2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b7:	83 ec 0c             	sub    $0xc,%esp
  8006ba:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006be:	52                   	push   %edx
  8006bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c2:	50                   	push   %eax
  8006c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c9:	89 da                	mov    %ebx,%edx
  8006cb:	89 f0                	mov    %esi,%eax
  8006cd:	e8 26 fb ff ff       	call   8001f8 <printnum>
			break;
  8006d2:	83 c4 20             	add    $0x20,%esp
  8006d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d8:	e9 64 fc ff ff       	jmp    800341 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	51                   	push   %ecx
  8006e2:	ff d6                	call   *%esi
			break;
  8006e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ea:	e9 52 fc ff ff       	jmp    800341 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 25                	push   $0x25
  8006f5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	eb 03                	jmp    8006ff <vprintfmt+0x3e4>
  8006fc:	83 ef 01             	sub    $0x1,%edi
  8006ff:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800703:	75 f7                	jne    8006fc <vprintfmt+0x3e1>
  800705:	e9 37 fc ff ff       	jmp    800341 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070d:	5b                   	pop    %ebx
  80070e:	5e                   	pop    %esi
  80070f:	5f                   	pop    %edi
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	83 ec 18             	sub    $0x18,%esp
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800721:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800725:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800728:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 26                	je     800759 <vsnprintf+0x47>
  800733:	85 d2                	test   %edx,%edx
  800735:	7e 22                	jle    800759 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800737:	ff 75 14             	pushl  0x14(%ebp)
  80073a:	ff 75 10             	pushl  0x10(%ebp)
  80073d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800740:	50                   	push   %eax
  800741:	68 e1 02 80 00       	push   $0x8002e1
  800746:	e8 d0 fb ff ff       	call   80031b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800751:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 05                	jmp    80075e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800769:	50                   	push   %eax
  80076a:	ff 75 10             	pushl  0x10(%ebp)
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	ff 75 08             	pushl  0x8(%ebp)
  800773:	e8 9a ff ff ff       	call   800712 <vsnprintf>
	va_end(ap);

	return rc;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800780:	b8 00 00 00 00       	mov    $0x0,%eax
  800785:	eb 03                	jmp    80078a <strlen+0x10>
		n++;
  800787:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078e:	75 f7                	jne    800787 <strlen+0xd>
		n++;
	return n;
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800798:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a0:	eb 03                	jmp    8007a5 <strnlen+0x13>
		n++;
  8007a2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a5:	39 c2                	cmp    %eax,%edx
  8007a7:	74 08                	je     8007b1 <strnlen+0x1f>
  8007a9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ad:	75 f3                	jne    8007a2 <strnlen+0x10>
  8007af:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bd:	89 c2                	mov    %eax,%edx
  8007bf:	83 c2 01             	add    $0x1,%edx
  8007c2:	83 c1 01             	add    $0x1,%ecx
  8007c5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cc:	84 db                	test   %bl,%bl
  8007ce:	75 ef                	jne    8007bf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d0:	5b                   	pop    %ebx
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007da:	53                   	push   %ebx
  8007db:	e8 9a ff ff ff       	call   80077a <strlen>
  8007e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e3:	ff 75 0c             	pushl  0xc(%ebp)
  8007e6:	01 d8                	add    %ebx,%eax
  8007e8:	50                   	push   %eax
  8007e9:	e8 c5 ff ff ff       	call   8007b3 <strcpy>
	return dst;
}
  8007ee:	89 d8                	mov    %ebx,%eax
  8007f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    

008007f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800800:	89 f3                	mov    %esi,%ebx
  800802:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800805:	89 f2                	mov    %esi,%edx
  800807:	eb 0f                	jmp    800818 <strncpy+0x23>
		*dst++ = *src;
  800809:	83 c2 01             	add    $0x1,%edx
  80080c:	0f b6 01             	movzbl (%ecx),%eax
  80080f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800812:	80 39 01             	cmpb   $0x1,(%ecx)
  800815:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800818:	39 da                	cmp    %ebx,%edx
  80081a:	75 ed                	jne    800809 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081c:	89 f0                	mov    %esi,%eax
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 75 08             	mov    0x8(%ebp),%esi
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	8b 55 10             	mov    0x10(%ebp),%edx
  800830:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800832:	85 d2                	test   %edx,%edx
  800834:	74 21                	je     800857 <strlcpy+0x35>
  800836:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083a:	89 f2                	mov    %esi,%edx
  80083c:	eb 09                	jmp    800847 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083e:	83 c2 01             	add    $0x1,%edx
  800841:	83 c1 01             	add    $0x1,%ecx
  800844:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800847:	39 c2                	cmp    %eax,%edx
  800849:	74 09                	je     800854 <strlcpy+0x32>
  80084b:	0f b6 19             	movzbl (%ecx),%ebx
  80084e:	84 db                	test   %bl,%bl
  800850:	75 ec                	jne    80083e <strlcpy+0x1c>
  800852:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800854:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800857:	29 f0                	sub    %esi,%eax
}
  800859:	5b                   	pop    %ebx
  80085a:	5e                   	pop    %esi
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800866:	eb 06                	jmp    80086e <strcmp+0x11>
		p++, q++;
  800868:	83 c1 01             	add    $0x1,%ecx
  80086b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086e:	0f b6 01             	movzbl (%ecx),%eax
  800871:	84 c0                	test   %al,%al
  800873:	74 04                	je     800879 <strcmp+0x1c>
  800875:	3a 02                	cmp    (%edx),%al
  800877:	74 ef                	je     800868 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800879:	0f b6 c0             	movzbl %al,%eax
  80087c:	0f b6 12             	movzbl (%edx),%edx
  80087f:	29 d0                	sub    %edx,%eax
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088d:	89 c3                	mov    %eax,%ebx
  80088f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800892:	eb 06                	jmp    80089a <strncmp+0x17>
		n--, p++, q++;
  800894:	83 c0 01             	add    $0x1,%eax
  800897:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089a:	39 d8                	cmp    %ebx,%eax
  80089c:	74 15                	je     8008b3 <strncmp+0x30>
  80089e:	0f b6 08             	movzbl (%eax),%ecx
  8008a1:	84 c9                	test   %cl,%cl
  8008a3:	74 04                	je     8008a9 <strncmp+0x26>
  8008a5:	3a 0a                	cmp    (%edx),%cl
  8008a7:	74 eb                	je     800894 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a9:	0f b6 00             	movzbl (%eax),%eax
  8008ac:	0f b6 12             	movzbl (%edx),%edx
  8008af:	29 d0                	sub    %edx,%eax
  8008b1:	eb 05                	jmp    8008b8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	eb 07                	jmp    8008ce <strchr+0x13>
		if (*s == c)
  8008c7:	38 ca                	cmp    %cl,%dl
  8008c9:	74 0f                	je     8008da <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 10             	movzbl (%eax),%edx
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	75 f2                	jne    8008c7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e6:	eb 03                	jmp    8008eb <strfind+0xf>
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ee:	38 ca                	cmp    %cl,%dl
  8008f0:	74 04                	je     8008f6 <strfind+0x1a>
  8008f2:	84 d2                	test   %dl,%dl
  8008f4:	75 f2                	jne    8008e8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	57                   	push   %edi
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800901:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 36                	je     80093e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800908:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090e:	75 28                	jne    800938 <memset+0x40>
  800910:	f6 c1 03             	test   $0x3,%cl
  800913:	75 23                	jne    800938 <memset+0x40>
		c &= 0xFF;
  800915:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800919:	89 d3                	mov    %edx,%ebx
  80091b:	c1 e3 08             	shl    $0x8,%ebx
  80091e:	89 d6                	mov    %edx,%esi
  800920:	c1 e6 18             	shl    $0x18,%esi
  800923:	89 d0                	mov    %edx,%eax
  800925:	c1 e0 10             	shl    $0x10,%eax
  800928:	09 f0                	or     %esi,%eax
  80092a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	09 d0                	or     %edx,%eax
  800930:	c1 e9 02             	shr    $0x2,%ecx
  800933:	fc                   	cld    
  800934:	f3 ab                	rep stos %eax,%es:(%edi)
  800936:	eb 06                	jmp    80093e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093b:	fc                   	cld    
  80093c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093e:	89 f8                	mov    %edi,%eax
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5f                   	pop    %edi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	57                   	push   %edi
  800949:	56                   	push   %esi
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800950:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800953:	39 c6                	cmp    %eax,%esi
  800955:	73 35                	jae    80098c <memmove+0x47>
  800957:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095a:	39 d0                	cmp    %edx,%eax
  80095c:	73 2e                	jae    80098c <memmove+0x47>
		s += n;
		d += n;
  80095e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	89 d6                	mov    %edx,%esi
  800963:	09 fe                	or     %edi,%esi
  800965:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096b:	75 13                	jne    800980 <memmove+0x3b>
  80096d:	f6 c1 03             	test   $0x3,%cl
  800970:	75 0e                	jne    800980 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800972:	83 ef 04             	sub    $0x4,%edi
  800975:	8d 72 fc             	lea    -0x4(%edx),%esi
  800978:	c1 e9 02             	shr    $0x2,%ecx
  80097b:	fd                   	std    
  80097c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097e:	eb 09                	jmp    800989 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800980:	83 ef 01             	sub    $0x1,%edi
  800983:	8d 72 ff             	lea    -0x1(%edx),%esi
  800986:	fd                   	std    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800989:	fc                   	cld    
  80098a:	eb 1d                	jmp    8009a9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	89 f2                	mov    %esi,%edx
  80098e:	09 c2                	or     %eax,%edx
  800990:	f6 c2 03             	test   $0x3,%dl
  800993:	75 0f                	jne    8009a4 <memmove+0x5f>
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	75 0a                	jne    8009a4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099a:	c1 e9 02             	shr    $0x2,%ecx
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 05                	jmp    8009a9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b0:	ff 75 10             	pushl  0x10(%ebp)
  8009b3:	ff 75 0c             	pushl  0xc(%ebp)
  8009b6:	ff 75 08             	pushl  0x8(%ebp)
  8009b9:	e8 87 ff ff ff       	call   800945 <memmove>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cb:	89 c6                	mov    %eax,%esi
  8009cd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d0:	eb 1a                	jmp    8009ec <memcmp+0x2c>
		if (*s1 != *s2)
  8009d2:	0f b6 08             	movzbl (%eax),%ecx
  8009d5:	0f b6 1a             	movzbl (%edx),%ebx
  8009d8:	38 d9                	cmp    %bl,%cl
  8009da:	74 0a                	je     8009e6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009dc:	0f b6 c1             	movzbl %cl,%eax
  8009df:	0f b6 db             	movzbl %bl,%ebx
  8009e2:	29 d8                	sub    %ebx,%eax
  8009e4:	eb 0f                	jmp    8009f5 <memcmp+0x35>
		s1++, s2++;
  8009e6:	83 c0 01             	add    $0x1,%eax
  8009e9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ec:	39 f0                	cmp    %esi,%eax
  8009ee:	75 e2                	jne    8009d2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	53                   	push   %ebx
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a00:	89 c1                	mov    %eax,%ecx
  800a02:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a05:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a09:	eb 0a                	jmp    800a15 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0b:	0f b6 10             	movzbl (%eax),%edx
  800a0e:	39 da                	cmp    %ebx,%edx
  800a10:	74 07                	je     800a19 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	39 c8                	cmp    %ecx,%eax
  800a17:	72 f2                	jb     800a0b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a28:	eb 03                	jmp    800a2d <strtol+0x11>
		s++;
  800a2a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2d:	0f b6 01             	movzbl (%ecx),%eax
  800a30:	3c 20                	cmp    $0x20,%al
  800a32:	74 f6                	je     800a2a <strtol+0xe>
  800a34:	3c 09                	cmp    $0x9,%al
  800a36:	74 f2                	je     800a2a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a38:	3c 2b                	cmp    $0x2b,%al
  800a3a:	75 0a                	jne    800a46 <strtol+0x2a>
		s++;
  800a3c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a44:	eb 11                	jmp    800a57 <strtol+0x3b>
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4b:	3c 2d                	cmp    $0x2d,%al
  800a4d:	75 08                	jne    800a57 <strtol+0x3b>
		s++, neg = 1;
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5d:	75 15                	jne    800a74 <strtol+0x58>
  800a5f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a62:	75 10                	jne    800a74 <strtol+0x58>
  800a64:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a68:	75 7c                	jne    800ae6 <strtol+0xca>
		s += 2, base = 16;
  800a6a:	83 c1 02             	add    $0x2,%ecx
  800a6d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a72:	eb 16                	jmp    800a8a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	75 12                	jne    800a8a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a78:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a80:	75 08                	jne    800a8a <strtol+0x6e>
		s++, base = 8;
  800a82:	83 c1 01             	add    $0x1,%ecx
  800a85:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a92:	0f b6 11             	movzbl (%ecx),%edx
  800a95:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 09             	cmp    $0x9,%bl
  800a9d:	77 08                	ja     800aa7 <strtol+0x8b>
			dig = *s - '0';
  800a9f:	0f be d2             	movsbl %dl,%edx
  800aa2:	83 ea 30             	sub    $0x30,%edx
  800aa5:	eb 22                	jmp    800ac9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 19             	cmp    $0x19,%bl
  800aaf:	77 08                	ja     800ab9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab1:	0f be d2             	movsbl %dl,%edx
  800ab4:	83 ea 57             	sub    $0x57,%edx
  800ab7:	eb 10                	jmp    800ac9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abc:	89 f3                	mov    %esi,%ebx
  800abe:	80 fb 19             	cmp    $0x19,%bl
  800ac1:	77 16                	ja     800ad9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac3:	0f be d2             	movsbl %dl,%edx
  800ac6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acc:	7d 0b                	jge    800ad9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad7:	eb b9                	jmp    800a92 <strtol+0x76>

	if (endptr)
  800ad9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800add:	74 0d                	je     800aec <strtol+0xd0>
		*endptr = (char *) s;
  800adf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae2:	89 0e                	mov    %ecx,(%esi)
  800ae4:	eb 06                	jmp    800aec <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae6:	85 db                	test   %ebx,%ebx
  800ae8:	74 98                	je     800a82 <strtol+0x66>
  800aea:	eb 9e                	jmp    800a8a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aec:	89 c2                	mov    %eax,%edx
  800aee:	f7 da                	neg    %edx
  800af0:	85 ff                	test   %edi,%edi
  800af2:	0f 45 c2             	cmovne %edx,%eax
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0b:	89 c3                	mov    %eax,%ebx
  800b0d:	89 c7                	mov    %eax,%edi
  800b0f:	89 c6                	mov    %eax,%esi
  800b11:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	b8 01 00 00 00       	mov    $0x1,%eax
  800b28:	89 d1                	mov    %edx,%ecx
  800b2a:	89 d3                	mov    %edx,%ebx
  800b2c:	89 d7                	mov    %edx,%edi
  800b2e:	89 d6                	mov    %edx,%esi
  800b30:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b45:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 cb                	mov    %ecx,%ebx
  800b4f:	89 cf                	mov    %ecx,%edi
  800b51:	89 ce                	mov    %ecx,%esi
  800b53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	7e 17                	jle    800b70 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 03                	push   $0x3
  800b5f:	68 24 16 80 00       	push   $0x801624
  800b64:	6a 23                	push   $0x23
  800b66:	68 41 16 80 00       	push   $0x801641
  800b6b:	e8 6a 04 00 00       	call   800fda <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 02 00 00 00       	mov    $0x2,%eax
  800b88:	89 d1                	mov    %edx,%ecx
  800b8a:	89 d3                	mov    %edx,%ebx
  800b8c:	89 d7                	mov    %edx,%edi
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_yield>:

void
sys_yield(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bbf:	be 00 00 00 00       	mov    $0x0,%esi
  800bc4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd2:	89 f7                	mov    %esi,%edi
  800bd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	7e 17                	jle    800bf1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 04                	push   $0x4
  800be0:	68 24 16 80 00       	push   $0x801624
  800be5:	6a 23                	push   $0x23
  800be7:	68 41 16 80 00       	push   $0x801641
  800bec:	e8 e9 03 00 00       	call   800fda <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c02:	b8 05 00 00 00       	mov    $0x5,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c13:	8b 75 18             	mov    0x18(%ebp),%esi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 05                	push   $0x5
  800c22:	68 24 16 80 00       	push   $0x801624
  800c27:	6a 23                	push   $0x23
  800c29:	68 41 16 80 00       	push   $0x801641
  800c2e:	e8 a7 03 00 00       	call   800fda <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c49:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c5c:	7e 17                	jle    800c75 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 06                	push   $0x6
  800c64:	68 24 16 80 00       	push   $0x801624
  800c69:	6a 23                	push   $0x23
  800c6b:	68 41 16 80 00       	push   $0x801641
  800c70:	e8 65 03 00 00       	call   800fda <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c8b:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c9e:	7e 17                	jle    800cb7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 08                	push   $0x8
  800ca6:	68 24 16 80 00       	push   $0x801624
  800cab:	6a 23                	push   $0x23
  800cad:	68 41 16 80 00       	push   $0x801641
  800cb2:	e8 23 03 00 00       	call   800fda <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 df                	mov    %ebx,%edi
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 17                	jle    800cf9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 09                	push   $0x9
  800ce8:	68 24 16 80 00       	push   $0x801624
  800ced:	6a 23                	push   $0x23
  800cef:	68 41 16 80 00       	push   $0x801641
  800cf4:	e8 e1 02 00 00       	call   800fda <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d07:	be 00 00 00 00       	mov    $0x0,%esi
  800d0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d32:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 cb                	mov    %ecx,%ebx
  800d3c:	89 cf                	mov    %ecx,%edi
  800d3e:	89 ce                	mov    %ecx,%esi
  800d40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7e 17                	jle    800d5d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	50                   	push   %eax
  800d4a:	6a 0c                	push   $0xc
  800d4c:	68 24 16 80 00       	push   $0x801624
  800d51:	6a 23                	push   $0x23
  800d53:	68 41 16 80 00       	push   $0x801641
  800d58:	e8 7d 02 00 00       	call   800fda <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	53                   	push   %ebx
  800d69:	83 ec 04             	sub    $0x4,%esp
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d6f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800d71:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d75:	74 2d                	je     800da4 <pgfault+0x3f>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800d77:	89 d8                	mov    %ebx,%eax
  800d79:	c1 e8 16             	shr    $0x16,%eax
  800d7c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
  800d83:	a8 01                	test   $0x1,%al
  800d85:	74 1d                	je     800da4 <pgfault+0x3f>
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
  800d87:	89 d8                	mov    %ebx,%eax
  800d89:	c1 e8 0c             	shr    $0xc,%eax
  800d8c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800d93:	f6 c2 01             	test   $0x1,%dl
  800d96:	74 0c                	je     800da4 <pgfault+0x3f>
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800d98:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800d9f:	f6 c4 08             	test   $0x8,%ah
  800da2:	75 14                	jne    800db8 <pgfault+0x53>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	68 4f 16 80 00       	push   $0x80164f
  800dac:	6a 22                	push   $0x22
  800dae:	68 65 16 80 00       	push   $0x801665
  800db3:	e8 22 02 00 00       	call   800fda <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	cprintf("in pgfault.\n");
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	68 70 16 80 00       	push   $0x801670
  800dc0:	e8 1f f4 ff ff       	call   8001e4 <cprintf>
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800dc5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800dcb:	83 c4 0c             	add    $0xc,%esp
  800dce:	6a 07                	push   $0x7
  800dd0:	68 00 f0 7f 00       	push   $0x7ff000
  800dd5:	6a 00                	push   $0x0
  800dd7:	e8 da fd ff ff       	call   800bb6 <sys_page_alloc>
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	79 14                	jns    800df7 <pgfault+0x92>
		panic("sys_page_alloc");
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	68 7d 16 80 00       	push   $0x80167d
  800deb:	6a 30                	push   $0x30
  800ded:	68 65 16 80 00       	push   $0x801665
  800df2:	e8 e3 01 00 00       	call   800fda <_panic>
	}
	memcpy(PFTEMP, addr, PGSIZE);
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	68 00 10 00 00       	push   $0x1000
  800dff:	53                   	push   %ebx
  800e00:	68 00 f0 7f 00       	push   $0x7ff000
  800e05:	e8 a3 fb ff ff       	call   8009ad <memcpy>
	
	retv = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P);
  800e0a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e11:	53                   	push   %ebx
  800e12:	6a 00                	push   $0x0
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 d9 fd ff ff       	call   800bf9 <sys_page_map>
	if(retv < 0){
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 14                	jns    800e3b <pgfault+0xd6>
		panic("sys_page_map");
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 8c 16 80 00       	push   $0x80168c
  800e2f:	6a 36                	push   $0x36
  800e31:	68 65 16 80 00       	push   $0x801665
  800e36:	e8 9f 01 00 00       	call   800fda <_panic>
	}
	cprintf("out of pgfault.\n");
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	68 99 16 80 00       	push   $0x801699
  800e43:	e8 9c f3 ff ff       	call   8001e4 <cprintf>
	return;
  800e48:	83 c4 10             	add    $0x10,%esp
	panic("pgfault not implemented");
}
  800e4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4e:	c9                   	leave  
  800e4f:	c3                   	ret    

00800e50 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 18             	sub    $0x18,%esp
	cprintf("\t\t we are in the fork().\n");
  800e59:	68 aa 16 80 00       	push   $0x8016aa
  800e5e:	e8 81 f3 ff ff       	call   8001e4 <cprintf>
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800e63:	c7 04 24 65 0d 80 00 	movl   $0x800d65,(%esp)
  800e6a:	e8 b1 01 00 00       	call   801020 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e6f:	b8 07 00 00 00       	mov    $0x7,%eax
  800e74:	cd 30                	int    $0x30
  800e76:	89 c6                	mov    %eax,%esi
	//create a child
	child_envid = sys_exofork();
	if(child_envid < 0 ){
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e80:	85 c0                	test   %eax,%eax
  800e82:	79 17                	jns    800e9b <fork+0x4b>
		panic("sys_exofork failed.");
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	68 c4 16 80 00       	push   $0x8016c4
  800e8c:	68 82 00 00 00       	push   $0x82
  800e91:	68 65 16 80 00       	push   $0x801665
  800e96:	e8 3f 01 00 00       	call   800fda <_panic>
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800e9b:	89 d8                	mov    %ebx,%eax
  800e9d:	c1 e8 16             	shr    $0x16,%eax
  800ea0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800ea7:	a8 01                	test   $0x1,%al
  800ea9:	0f 84 e8 00 00 00    	je     800f97 <fork+0x147>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800eaf:	89 d8                	mov    %ebx,%eax
  800eb1:	c1 e8 0c             	shr    $0xc,%eax
  800eb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800ebb:	f6 c2 01             	test   $0x1,%dl
  800ebe:	0f 84 d3 00 00 00    	je     800f97 <fork+0x147>
			(uvpt[PGNUM(addr)] & PTE_P)&& 
			(uvpt[PGNUM(addr)] & PTE_U)
  800ec4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800ecb:	f6 c2 04             	test   $0x4,%dl
  800ece:	0f 84 c3 00 00 00    	je     800f97 <fork+0x147>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;

	// LAB 4: Your code here.
	void *addr = (void*)(pn*PGSIZE);
  800ed4:	89 c7                	mov    %eax,%edi
  800ed6:	c1 e7 0c             	shl    $0xc,%edi
	if( (uvpt[pn] & PTE_W)||(uvpt[pn]) & PTE_COW ){
  800ed9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee0:	f6 c2 02             	test   $0x2,%dl
  800ee3:	75 10                	jne    800ef5 <fork+0xa5>
  800ee5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eec:	f6 c4 08             	test   $0x8,%ah
  800eef:	0f 84 90 00 00 00    	je     800f85 <fork+0x135>
		cprintf("!!start page map.\n");	
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	68 d8 16 80 00       	push   $0x8016d8
  800efd:	e8 e2 f2 ff ff       	call   8001e4 <cprintf>
		r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_P|PTE_U);
  800f02:	c7 04 24 05 08 00 00 	movl   $0x805,(%esp)
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	57                   	push   %edi
  800f0c:	6a 00                	push   $0x0
  800f0e:	e8 e6 fc ff ff       	call   800bf9 <sys_page_map>
		if(r<0){
  800f13:	83 c4 20             	add    $0x20,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	79 22                	jns    800f3c <fork+0xec>
			cprintf("sys_page_map failed :%d\n",r);
  800f1a:	83 ec 08             	sub    $0x8,%esp
  800f1d:	50                   	push   %eax
  800f1e:	68 eb 16 80 00       	push   $0x8016eb
  800f23:	e8 bc f2 ff ff       	call   8001e4 <cprintf>
			panic("map env id 0 to child_envid failed.");
  800f28:	83 c4 0c             	add    $0xc,%esp
  800f2b:	68 54 17 80 00       	push   $0x801754
  800f30:	6a 54                	push   $0x54
  800f32:	68 65 16 80 00       	push   $0x801665
  800f37:	e8 9e 00 00 00       	call   800fda <_panic>
		
		}
		cprintf("mapping addr is:%x\n",addr);
  800f3c:	83 ec 08             	sub    $0x8,%esp
  800f3f:	57                   	push   %edi
  800f40:	68 04 17 80 00       	push   $0x801704
  800f45:	e8 9a f2 ff ff       	call   8001e4 <cprintf>
		r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_P|PTE_U);
  800f4a:	c7 04 24 05 08 00 00 	movl   $0x805,(%esp)
  800f51:	57                   	push   %edi
  800f52:	6a 00                	push   $0x0
  800f54:	57                   	push   %edi
  800f55:	6a 00                	push   $0x0
  800f57:	e8 9d fc ff ff       	call   800bf9 <sys_page_map>
//		cprintf("!!end sys_page_map 0.\n");
		if(r<0){
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 34                	jns    800f97 <fork+0x147>
			cprintf("sys_page_map failed :%d\n",r);
  800f63:	83 ec 08             	sub    $0x8,%esp
  800f66:	50                   	push   %eax
  800f67:	68 eb 16 80 00       	push   $0x8016eb
  800f6c:	e8 73 f2 ff ff       	call   8001e4 <cprintf>
			panic("map env id 0 to 0");
  800f71:	83 c4 0c             	add    $0xc,%esp
  800f74:	68 18 17 80 00       	push   $0x801718
  800f79:	6a 5c                	push   $0x5c
  800f7b:	68 65 16 80 00       	push   $0x801665
  800f80:	e8 55 00 00 00       	call   800fda <_panic>
		}//?we should mark PTE_COW both to two id.
//		cprintf("!!end page map.\n");	
	}else{
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800f85:	83 ec 0c             	sub    $0xc,%esp
  800f88:	6a 05                	push   $0x5
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	57                   	push   %edi
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 65 fc ff ff       	call   800bf9 <sys_page_map>
  800f94:	83 c4 20             	add    $0x20,%esp
	if(child_envid < 0 ){
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800f97:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fa3:	0f 85 f2 fe ff ff    	jne    800e9b <fork+0x4b>
			(uvpt[PGNUM(addr)] & PTE_U)
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	panic("failed at duppage.");
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	68 2a 17 80 00       	push   $0x80172a
  800fb1:	68 8f 00 00 00       	push   $0x8f
  800fb6:	68 65 16 80 00       	push   $0x801665
  800fbb:	e8 1a 00 00 00       	call   800fda <_panic>

00800fc0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fc6:	68 3d 17 80 00       	push   $0x80173d
  800fcb:	68 a4 00 00 00       	push   $0xa4
  800fd0:	68 65 16 80 00       	push   $0x801665
  800fd5:	e8 00 00 00 00       	call   800fda <_panic>

00800fda <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fdf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fe2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fe8:	e8 8b fb ff ff       	call   800b78 <sys_getenvid>
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	ff 75 0c             	pushl  0xc(%ebp)
  800ff3:	ff 75 08             	pushl  0x8(%ebp)
  800ff6:	56                   	push   %esi
  800ff7:	50                   	push   %eax
  800ff8:	68 78 17 80 00       	push   $0x801778
  800ffd:	e8 e2 f1 ff ff       	call   8001e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801002:	83 c4 18             	add    $0x18,%esp
  801005:	53                   	push   %ebx
  801006:	ff 75 10             	pushl  0x10(%ebp)
  801009:	e8 85 f1 ff ff       	call   800193 <vcprintf>
	cprintf("\n");
  80100e:	c7 04 24 af 13 80 00 	movl   $0x8013af,(%esp)
  801015:	e8 ca f1 ff ff       	call   8001e4 <cprintf>
  80101a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80101d:	cc                   	int3   
  80101e:	eb fd                	jmp    80101d <_panic+0x43>

00801020 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  801026:	68 9c 17 80 00       	push   $0x80179c
  80102b:	e8 b4 f1 ff ff       	call   8001e4 <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80103a:	0f 85 8d 00 00 00    	jne    8010cd <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	68 bc 17 80 00       	push   $0x8017bc
  801048:	e8 97 f1 ff ff       	call   8001e4 <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  80104d:	a1 04 20 80 00       	mov    0x802004,%eax
  801052:	8b 40 48             	mov    0x48(%eax),%eax
  801055:	83 c4 0c             	add    $0xc,%esp
  801058:	6a 07                	push   $0x7
  80105a:	68 00 f0 bf ee       	push   $0xeebff000
  80105f:	50                   	push   %eax
  801060:	e8 51 fb ff ff       	call   800bb6 <sys_page_alloc>
		if(retv != 0){
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	74 14                	je     801080 <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  80106c:	83 ec 04             	sub    $0x4,%esp
  80106f:	68 e0 17 80 00       	push   $0x8017e0
  801074:	6a 27                	push   $0x27
  801076:	68 34 18 80 00       	push   $0x801834
  80107b:	e8 5a ff ff ff       	call   800fda <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	68 e7 10 80 00       	push   $0x8010e7
  801088:	68 42 18 80 00       	push   $0x801842
  80108d:	e8 52 f1 ff ff       	call   8001e4 <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  801092:	a1 04 20 80 00       	mov    0x802004,%eax
  801097:	8b 40 48             	mov    0x48(%eax),%eax
  80109a:	83 c4 08             	add    $0x8,%esp
  80109d:	50                   	push   %eax
  80109e:	68 5d 18 80 00       	push   $0x80185d
  8010a3:	e8 3c f1 ff ff       	call   8001e4 <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8010a8:	a1 04 20 80 00       	mov    0x802004,%eax
  8010ad:	8b 40 48             	mov    0x48(%eax),%eax
  8010b0:	83 c4 08             	add    $0x8,%esp
  8010b3:	68 e7 10 80 00       	push   $0x8010e7
  8010b8:	50                   	push   %eax
  8010b9:	e8 01 fc ff ff       	call   800cbf <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  8010be:	c7 04 24 74 18 80 00 	movl   $0x801874,(%esp)
  8010c5:	e8 1a f1 ff ff       	call   8001e4 <cprintf>
  8010ca:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	68 0c 18 80 00       	push   $0x80180c
  8010d5:	e8 0a f1 ff ff       	call   8001e4 <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010da:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dd:	a3 08 20 80 00       	mov    %eax,0x802008

}
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010e7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010e8:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8010ed:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010ef:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  8010f2:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  8010f4:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  8010f8:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8010fc:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  8010fd:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  8010ff:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  801106:	00 
	popl %eax
  801107:	58                   	pop    %eax
	popl %eax
  801108:	58                   	pop    %eax
	popal
  801109:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  80110a:	83 c4 04             	add    $0x4,%esp
	popfl
  80110d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80110e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80110f:	c3                   	ret    

00801110 <__udivdi3>:
  801110:	55                   	push   %ebp
  801111:	57                   	push   %edi
  801112:	56                   	push   %esi
  801113:	53                   	push   %ebx
  801114:	83 ec 1c             	sub    $0x1c,%esp
  801117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80111b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80111f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801127:	85 f6                	test   %esi,%esi
  801129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80112d:	89 ca                	mov    %ecx,%edx
  80112f:	89 f8                	mov    %edi,%eax
  801131:	75 3d                	jne    801170 <__udivdi3+0x60>
  801133:	39 cf                	cmp    %ecx,%edi
  801135:	0f 87 c5 00 00 00    	ja     801200 <__udivdi3+0xf0>
  80113b:	85 ff                	test   %edi,%edi
  80113d:	89 fd                	mov    %edi,%ebp
  80113f:	75 0b                	jne    80114c <__udivdi3+0x3c>
  801141:	b8 01 00 00 00       	mov    $0x1,%eax
  801146:	31 d2                	xor    %edx,%edx
  801148:	f7 f7                	div    %edi
  80114a:	89 c5                	mov    %eax,%ebp
  80114c:	89 c8                	mov    %ecx,%eax
  80114e:	31 d2                	xor    %edx,%edx
  801150:	f7 f5                	div    %ebp
  801152:	89 c1                	mov    %eax,%ecx
  801154:	89 d8                	mov    %ebx,%eax
  801156:	89 cf                	mov    %ecx,%edi
  801158:	f7 f5                	div    %ebp
  80115a:	89 c3                	mov    %eax,%ebx
  80115c:	89 d8                	mov    %ebx,%eax
  80115e:	89 fa                	mov    %edi,%edx
  801160:	83 c4 1c             	add    $0x1c,%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    
  801168:	90                   	nop
  801169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801170:	39 ce                	cmp    %ecx,%esi
  801172:	77 74                	ja     8011e8 <__udivdi3+0xd8>
  801174:	0f bd fe             	bsr    %esi,%edi
  801177:	83 f7 1f             	xor    $0x1f,%edi
  80117a:	0f 84 98 00 00 00    	je     801218 <__udivdi3+0x108>
  801180:	bb 20 00 00 00       	mov    $0x20,%ebx
  801185:	89 f9                	mov    %edi,%ecx
  801187:	89 c5                	mov    %eax,%ebp
  801189:	29 fb                	sub    %edi,%ebx
  80118b:	d3 e6                	shl    %cl,%esi
  80118d:	89 d9                	mov    %ebx,%ecx
  80118f:	d3 ed                	shr    %cl,%ebp
  801191:	89 f9                	mov    %edi,%ecx
  801193:	d3 e0                	shl    %cl,%eax
  801195:	09 ee                	or     %ebp,%esi
  801197:	89 d9                	mov    %ebx,%ecx
  801199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80119d:	89 d5                	mov    %edx,%ebp
  80119f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011a3:	d3 ed                	shr    %cl,%ebp
  8011a5:	89 f9                	mov    %edi,%ecx
  8011a7:	d3 e2                	shl    %cl,%edx
  8011a9:	89 d9                	mov    %ebx,%ecx
  8011ab:	d3 e8                	shr    %cl,%eax
  8011ad:	09 c2                	or     %eax,%edx
  8011af:	89 d0                	mov    %edx,%eax
  8011b1:	89 ea                	mov    %ebp,%edx
  8011b3:	f7 f6                	div    %esi
  8011b5:	89 d5                	mov    %edx,%ebp
  8011b7:	89 c3                	mov    %eax,%ebx
  8011b9:	f7 64 24 0c          	mull   0xc(%esp)
  8011bd:	39 d5                	cmp    %edx,%ebp
  8011bf:	72 10                	jb     8011d1 <__udivdi3+0xc1>
  8011c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011c5:	89 f9                	mov    %edi,%ecx
  8011c7:	d3 e6                	shl    %cl,%esi
  8011c9:	39 c6                	cmp    %eax,%esi
  8011cb:	73 07                	jae    8011d4 <__udivdi3+0xc4>
  8011cd:	39 d5                	cmp    %edx,%ebp
  8011cf:	75 03                	jne    8011d4 <__udivdi3+0xc4>
  8011d1:	83 eb 01             	sub    $0x1,%ebx
  8011d4:	31 ff                	xor    %edi,%edi
  8011d6:	89 d8                	mov    %ebx,%eax
  8011d8:	89 fa                	mov    %edi,%edx
  8011da:	83 c4 1c             	add    $0x1c,%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    
  8011e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011e8:	31 ff                	xor    %edi,%edi
  8011ea:	31 db                	xor    %ebx,%ebx
  8011ec:	89 d8                	mov    %ebx,%eax
  8011ee:	89 fa                	mov    %edi,%edx
  8011f0:	83 c4 1c             	add    $0x1c,%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    
  8011f8:	90                   	nop
  8011f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801200:	89 d8                	mov    %ebx,%eax
  801202:	f7 f7                	div    %edi
  801204:	31 ff                	xor    %edi,%edi
  801206:	89 c3                	mov    %eax,%ebx
  801208:	89 d8                	mov    %ebx,%eax
  80120a:	89 fa                	mov    %edi,%edx
  80120c:	83 c4 1c             	add    $0x1c,%esp
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	39 ce                	cmp    %ecx,%esi
  80121a:	72 0c                	jb     801228 <__udivdi3+0x118>
  80121c:	31 db                	xor    %ebx,%ebx
  80121e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801222:	0f 87 34 ff ff ff    	ja     80115c <__udivdi3+0x4c>
  801228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80122d:	e9 2a ff ff ff       	jmp    80115c <__udivdi3+0x4c>
  801232:	66 90                	xchg   %ax,%ax
  801234:	66 90                	xchg   %ax,%ax
  801236:	66 90                	xchg   %ax,%ax
  801238:	66 90                	xchg   %ax,%ax
  80123a:	66 90                	xchg   %ax,%ax
  80123c:	66 90                	xchg   %ax,%ax
  80123e:	66 90                	xchg   %ax,%ax

00801240 <__umoddi3>:
  801240:	55                   	push   %ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	83 ec 1c             	sub    $0x1c,%esp
  801247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80124b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80124f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801257:	85 d2                	test   %edx,%edx
  801259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80125d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801261:	89 f3                	mov    %esi,%ebx
  801263:	89 3c 24             	mov    %edi,(%esp)
  801266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80126a:	75 1c                	jne    801288 <__umoddi3+0x48>
  80126c:	39 f7                	cmp    %esi,%edi
  80126e:	76 50                	jbe    8012c0 <__umoddi3+0x80>
  801270:	89 c8                	mov    %ecx,%eax
  801272:	89 f2                	mov    %esi,%edx
  801274:	f7 f7                	div    %edi
  801276:	89 d0                	mov    %edx,%eax
  801278:	31 d2                	xor    %edx,%edx
  80127a:	83 c4 1c             	add    $0x1c,%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    
  801282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801288:	39 f2                	cmp    %esi,%edx
  80128a:	89 d0                	mov    %edx,%eax
  80128c:	77 52                	ja     8012e0 <__umoddi3+0xa0>
  80128e:	0f bd ea             	bsr    %edx,%ebp
  801291:	83 f5 1f             	xor    $0x1f,%ebp
  801294:	75 5a                	jne    8012f0 <__umoddi3+0xb0>
  801296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80129a:	0f 82 e0 00 00 00    	jb     801380 <__umoddi3+0x140>
  8012a0:	39 0c 24             	cmp    %ecx,(%esp)
  8012a3:	0f 86 d7 00 00 00    	jbe    801380 <__umoddi3+0x140>
  8012a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012b1:	83 c4 1c             	add    $0x1c,%esp
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	85 ff                	test   %edi,%edi
  8012c2:	89 fd                	mov    %edi,%ebp
  8012c4:	75 0b                	jne    8012d1 <__umoddi3+0x91>
  8012c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	f7 f7                	div    %edi
  8012cf:	89 c5                	mov    %eax,%ebp
  8012d1:	89 f0                	mov    %esi,%eax
  8012d3:	31 d2                	xor    %edx,%edx
  8012d5:	f7 f5                	div    %ebp
  8012d7:	89 c8                	mov    %ecx,%eax
  8012d9:	f7 f5                	div    %ebp
  8012db:	89 d0                	mov    %edx,%eax
  8012dd:	eb 99                	jmp    801278 <__umoddi3+0x38>
  8012df:	90                   	nop
  8012e0:	89 c8                	mov    %ecx,%eax
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	83 c4 1c             	add    $0x1c,%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5e                   	pop    %esi
  8012e9:	5f                   	pop    %edi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    
  8012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	8b 34 24             	mov    (%esp),%esi
  8012f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8012f8:	89 e9                	mov    %ebp,%ecx
  8012fa:	29 ef                	sub    %ebp,%edi
  8012fc:	d3 e0                	shl    %cl,%eax
  8012fe:	89 f9                	mov    %edi,%ecx
  801300:	89 f2                	mov    %esi,%edx
  801302:	d3 ea                	shr    %cl,%edx
  801304:	89 e9                	mov    %ebp,%ecx
  801306:	09 c2                	or     %eax,%edx
  801308:	89 d8                	mov    %ebx,%eax
  80130a:	89 14 24             	mov    %edx,(%esp)
  80130d:	89 f2                	mov    %esi,%edx
  80130f:	d3 e2                	shl    %cl,%edx
  801311:	89 f9                	mov    %edi,%ecx
  801313:	89 54 24 04          	mov    %edx,0x4(%esp)
  801317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80131b:	d3 e8                	shr    %cl,%eax
  80131d:	89 e9                	mov    %ebp,%ecx
  80131f:	89 c6                	mov    %eax,%esi
  801321:	d3 e3                	shl    %cl,%ebx
  801323:	89 f9                	mov    %edi,%ecx
  801325:	89 d0                	mov    %edx,%eax
  801327:	d3 e8                	shr    %cl,%eax
  801329:	89 e9                	mov    %ebp,%ecx
  80132b:	09 d8                	or     %ebx,%eax
  80132d:	89 d3                	mov    %edx,%ebx
  80132f:	89 f2                	mov    %esi,%edx
  801331:	f7 34 24             	divl   (%esp)
  801334:	89 d6                	mov    %edx,%esi
  801336:	d3 e3                	shl    %cl,%ebx
  801338:	f7 64 24 04          	mull   0x4(%esp)
  80133c:	39 d6                	cmp    %edx,%esi
  80133e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801342:	89 d1                	mov    %edx,%ecx
  801344:	89 c3                	mov    %eax,%ebx
  801346:	72 08                	jb     801350 <__umoddi3+0x110>
  801348:	75 11                	jne    80135b <__umoddi3+0x11b>
  80134a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80134e:	73 0b                	jae    80135b <__umoddi3+0x11b>
  801350:	2b 44 24 04          	sub    0x4(%esp),%eax
  801354:	1b 14 24             	sbb    (%esp),%edx
  801357:	89 d1                	mov    %edx,%ecx
  801359:	89 c3                	mov    %eax,%ebx
  80135b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80135f:	29 da                	sub    %ebx,%edx
  801361:	19 ce                	sbb    %ecx,%esi
  801363:	89 f9                	mov    %edi,%ecx
  801365:	89 f0                	mov    %esi,%eax
  801367:	d3 e0                	shl    %cl,%eax
  801369:	89 e9                	mov    %ebp,%ecx
  80136b:	d3 ea                	shr    %cl,%edx
  80136d:	89 e9                	mov    %ebp,%ecx
  80136f:	d3 ee                	shr    %cl,%esi
  801371:	09 d0                	or     %edx,%eax
  801373:	89 f2                	mov    %esi,%edx
  801375:	83 c4 1c             	add    $0x1c,%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    
  80137d:	8d 76 00             	lea    0x0(%esi),%esi
  801380:	29 f9                	sub    %edi,%ecx
  801382:	19 d6                	sbb    %edx,%esi
  801384:	89 74 24 04          	mov    %esi,0x4(%esp)
  801388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138c:	e9 18 ff ff ff       	jmp    8012a9 <__umoddi3+0x69>
