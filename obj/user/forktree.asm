
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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
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
  80003d:	e8 1e 0b 00 00       	call   800b60 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 10 80 00       	push   $0x801060
  80004c:	e8 7b 01 00 00       	call   8001cc <cprintf>

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
  80007e:	e8 df 06 00 00       	call   800762 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 71 10 80 00       	push   $0x801071
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 a3 06 00 00       	call   800748 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 a0 0c 00 00       	call   800d4d <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 70 10 80 00       	push   $0x801070
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 6f 0a 00 00       	call   800b60 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012d:	6a 00                	push   $0x0
  80012f:	e8 eb 09 00 00       	call   800b1f <sys_env_destroy>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	53                   	push   %ebx
  80013d:	83 ec 04             	sub    $0x4,%esp
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800143:	8b 13                	mov    (%ebx),%edx
  800145:	8d 42 01             	lea    0x1(%edx),%eax
  800148:	89 03                	mov    %eax,(%ebx)
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800151:	3d ff 00 00 00       	cmp    $0xff,%eax
  800156:	75 1a                	jne    800172 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 79 09 00 00       	call   800ae2 <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800184:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 39 01 80 00       	push   $0x800139
  8001aa:	e8 54 01 00 00       	call   800303 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 1e 09 00 00       	call   800ae2 <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	89 c7                	mov    %eax,%edi
  8001eb:	89 d6                	mov    %edx,%esi
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800201:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800204:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800207:	39 d3                	cmp    %edx,%ebx
  800209:	72 05                	jb     800210 <printnum+0x30>
  80020b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80020e:	77 45                	ja     800255 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	8b 45 14             	mov    0x14(%ebp),%eax
  800219:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021c:	53                   	push   %ebx
  80021d:	ff 75 10             	pushl  0x10(%ebp)
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 9c 0b 00 00       	call   800dd0 <__udivdi3>
  800234:	83 c4 18             	add    $0x18,%esp
  800237:	52                   	push   %edx
  800238:	50                   	push   %eax
  800239:	89 f2                	mov    %esi,%edx
  80023b:	89 f8                	mov    %edi,%eax
  80023d:	e8 9e ff ff ff       	call   8001e0 <printnum>
  800242:	83 c4 20             	add    $0x20,%esp
  800245:	eb 18                	jmp    80025f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	ff 75 18             	pushl  0x18(%ebp)
  80024e:	ff d7                	call   *%edi
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	eb 03                	jmp    800258 <printnum+0x78>
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	7f e8                	jg     800247 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	56                   	push   %esi
  800263:	83 ec 04             	sub    $0x4,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 89 0c 00 00       	call   800f00 <__umoddi3>
  800277:	83 c4 14             	add    $0x14,%esp
  80027a:	0f be 80 80 10 80 00 	movsbl 0x801080(%eax),%eax
  800281:	50                   	push   %eax
  800282:	ff d7                	call   *%edi
}
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800292:	83 fa 01             	cmp    $0x1,%edx
  800295:	7e 0e                	jle    8002a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	8b 52 04             	mov    0x4(%edx),%edx
  8002a3:	eb 22                	jmp    8002c7 <getuint+0x38>
	else if (lflag)
  8002a5:	85 d2                	test   %edx,%edx
  8002a7:	74 10                	je     8002b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	eb 0e                	jmp    8002c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ef:	50                   	push   %eax
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	e8 05 00 00 00       	call   800303 <vprintfmt>
	va_end(ap);
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	c9                   	leave  
  800302:	c3                   	ret    

00800303 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 2c             	sub    $0x2c,%esp
  80030c:	8b 75 08             	mov    0x8(%ebp),%esi
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800312:	8b 7d 10             	mov    0x10(%ebp),%edi
  800315:	eb 12                	jmp    800329 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800317:	85 c0                	test   %eax,%eax
  800319:	0f 84 d3 03 00 00    	je     8006f2 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	53                   	push   %ebx
  800323:	50                   	push   %eax
  800324:	ff d6                	call   *%esi
  800326:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	83 c7 01             	add    $0x1,%edi
  80032c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800330:	83 f8 25             	cmp    $0x25,%eax
  800333:	75 e2                	jne    800317 <vprintfmt+0x14>
  800335:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800339:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800340:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800347:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034e:	ba 00 00 00 00       	mov    $0x0,%edx
  800353:	eb 07                	jmp    80035c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800358:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8d 47 01             	lea    0x1(%edi),%eax
  80035f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800362:	0f b6 07             	movzbl (%edi),%eax
  800365:	0f b6 c8             	movzbl %al,%ecx
  800368:	83 e8 23             	sub    $0x23,%eax
  80036b:	3c 55                	cmp    $0x55,%al
  80036d:	0f 87 64 03 00 00    	ja     8006d7 <vprintfmt+0x3d4>
  800373:	0f b6 c0             	movzbl %al,%eax
  800376:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800380:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800384:	eb d6                	jmp    80035c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800389:	b8 00 00 00 00       	mov    $0x0,%eax
  80038e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800391:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800394:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800398:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80039b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80039e:	83 fa 09             	cmp    $0x9,%edx
  8003a1:	77 39                	ja     8003dc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a6:	eb e9                	jmp    800391 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b1:	8b 00                	mov    (%eax),%eax
  8003b3:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b9:	eb 27                	jmp    8003e2 <vprintfmt+0xdf>
  8003bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c5:	0f 49 c8             	cmovns %eax,%ecx
  8003c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	eb 8c                	jmp    80035c <vprintfmt+0x59>
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003da:	eb 80                	jmp    80035c <vprintfmt+0x59>
  8003dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003df:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e6:	0f 89 70 ff ff ff    	jns    80035c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ec:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003f9:	e9 5e ff ff ff       	jmp    80035c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fe:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800404:	e9 53 ff ff ff       	jmp    80035c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	pushl  (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800420:	e9 04 ff ff ff       	jmp    800329 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 08             	cmp    $0x8,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x142>
  80043a:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 18                	jne    80045d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 98 10 80 00       	push   $0x801098
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 94 fe ff ff       	call   8002e6 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800458:	e9 cc fe ff ff       	jmp    800329 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80045d:	52                   	push   %edx
  80045e:	68 a1 10 80 00       	push   $0x8010a1
  800463:	53                   	push   %ebx
  800464:	56                   	push   %esi
  800465:	e8 7c fe ff ff       	call   8002e6 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800470:	e9 b4 fe ff ff       	jmp    800329 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800480:	85 ff                	test   %edi,%edi
  800482:	b8 91 10 80 00       	mov    $0x801091,%eax
  800487:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048e:	0f 8e 94 00 00 00    	jle    800528 <vprintfmt+0x225>
  800494:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800498:	0f 84 98 00 00 00    	je     800536 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 c8             	pushl  -0x38(%ebp)
  8004a4:	57                   	push   %edi
  8004a5:	e8 d0 02 00 00       	call   80077a <strnlen>
  8004aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ad:	29 c1                	sub    %eax,%ecx
  8004af:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004bf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	eb 0f                	jmp    8004d2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	83 ef 01             	sub    $0x1,%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7f ed                	jg     8004c3 <vprintfmt+0x1c0>
  8004d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004dc:	85 c9                	test   %ecx,%ecx
  8004de:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e3:	0f 49 c1             	cmovns %ecx,%eax
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004eb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f1:	89 cb                	mov    %ecx,%ebx
  8004f3:	eb 4d                	jmp    800542 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f9:	74 1b                	je     800516 <vprintfmt+0x213>
  8004fb:	0f be c0             	movsbl %al,%eax
  8004fe:	83 e8 20             	sub    $0x20,%eax
  800501:	83 f8 5e             	cmp    $0x5e,%eax
  800504:	76 10                	jbe    800516 <vprintfmt+0x213>
					putch('?', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	6a 3f                	push   $0x3f
  80050e:	ff 55 08             	call   *0x8(%ebp)
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	eb 0d                	jmp    800523 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	52                   	push   %edx
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800523:	83 eb 01             	sub    $0x1,%ebx
  800526:	eb 1a                	jmp    800542 <vprintfmt+0x23f>
  800528:	89 75 08             	mov    %esi,0x8(%ebp)
  80052b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80052e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800531:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800534:	eb 0c                	jmp    800542 <vprintfmt+0x23f>
  800536:	89 75 08             	mov    %esi,0x8(%ebp)
  800539:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80053c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800542:	83 c7 01             	add    $0x1,%edi
  800545:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800549:	0f be d0             	movsbl %al,%edx
  80054c:	85 d2                	test   %edx,%edx
  80054e:	74 23                	je     800573 <vprintfmt+0x270>
  800550:	85 f6                	test   %esi,%esi
  800552:	78 a1                	js     8004f5 <vprintfmt+0x1f2>
  800554:	83 ee 01             	sub    $0x1,%esi
  800557:	79 9c                	jns    8004f5 <vprintfmt+0x1f2>
  800559:	89 df                	mov    %ebx,%edi
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800561:	eb 18                	jmp    80057b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	6a 20                	push   $0x20
  800569:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056b:	83 ef 01             	sub    $0x1,%edi
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 08                	jmp    80057b <vprintfmt+0x278>
  800573:	89 df                	mov    %ebx,%edi
  800575:	8b 75 08             	mov    0x8(%ebp),%esi
  800578:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057b:	85 ff                	test   %edi,%edi
  80057d:	7f e4                	jg     800563 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	e9 a2 fd ff ff       	jmp    800329 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800587:	83 fa 01             	cmp    $0x1,%edx
  80058a:	7e 16                	jle    8005a2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 08             	lea    0x8(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 50 04             	mov    0x4(%eax),%edx
  800598:	8b 00                	mov    (%eax),%eax
  80059a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80059d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005a0:	eb 32                	jmp    8005d4 <vprintfmt+0x2d1>
	else if (lflag)
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	74 18                	je     8005be <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005bc:	eb 16                	jmp    8005d4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005cc:	89 c1                	mov    %eax,%ecx
  8005ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005d7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005e9:	0f 89 b0 00 00 00    	jns    80069f <vprintfmt+0x39c>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005fa:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005fd:	f7 d8                	neg    %eax
  8005ff:	83 d2 00             	adc    $0x0,%edx
  800602:	f7 da                	neg    %edx
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800612:	e9 88 00 00 00       	jmp    80069f <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 70 fc ff ff       	call   80028f <getuint>
  80061f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800622:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062a:	eb 73                	jmp    80069f <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80062c:	8d 45 14             	lea    0x14(%ebp),%eax
  80062f:	e8 5b fc ff ff       	call   80028f <getuint>
  800634:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800637:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 58                	push   $0x58
  800640:	ff d6                	call   *%esi
			putch('X', putdat);
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	6a 58                	push   $0x58
  800648:	ff d6                	call   *%esi
			putch('X', putdat);
  80064a:	83 c4 08             	add    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 58                	push   $0x58
  800650:	ff d6                	call   *%esi
			goto number;
  800652:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800655:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80065a:	eb 43                	jmp    80069f <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 30                	push   $0x30
  800662:	ff d6                	call   *%esi
			putch('x', putdat);
  800664:	83 c4 08             	add    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 78                	push   $0x78
  80066a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800675:	8b 00                	mov    (%eax),%eax
  800677:	ba 00 00 00 00       	mov    $0x0,%edx
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800685:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068a:	eb 13                	jmp    80069f <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068c:	8d 45 14             	lea    0x14(%ebp),%eax
  80068f:	e8 fb fb ff ff       	call   80028f <getuint>
  800694:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800697:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069f:	83 ec 0c             	sub    $0xc,%esp
  8006a2:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006a6:	52                   	push   %edx
  8006a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006aa:	50                   	push   %eax
  8006ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b1:	89 da                	mov    %ebx,%edx
  8006b3:	89 f0                	mov    %esi,%eax
  8006b5:	e8 26 fb ff ff       	call   8001e0 <printnum>
			break;
  8006ba:	83 c4 20             	add    $0x20,%esp
  8006bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c0:	e9 64 fc ff ff       	jmp    800329 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	51                   	push   %ecx
  8006ca:	ff d6                	call   *%esi
			break;
  8006cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d2:	e9 52 fc ff ff       	jmp    800329 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 25                	push   $0x25
  8006dd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb 03                	jmp    8006e7 <vprintfmt+0x3e4>
  8006e4:	83 ef 01             	sub    $0x1,%edi
  8006e7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006eb:	75 f7                	jne    8006e4 <vprintfmt+0x3e1>
  8006ed:	e9 37 fc ff ff       	jmp    800329 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 18             	sub    $0x18,%esp
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800706:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800709:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800710:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800717:	85 c0                	test   %eax,%eax
  800719:	74 26                	je     800741 <vsnprintf+0x47>
  80071b:	85 d2                	test   %edx,%edx
  80071d:	7e 22                	jle    800741 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071f:	ff 75 14             	pushl  0x14(%ebp)
  800722:	ff 75 10             	pushl  0x10(%ebp)
  800725:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	68 c9 02 80 00       	push   $0x8002c9
  80072e:	e8 d0 fb ff ff       	call   800303 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800733:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800736:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb 05                	jmp    800746 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800741:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800746:	c9                   	leave  
  800747:	c3                   	ret    

00800748 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800751:	50                   	push   %eax
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	ff 75 08             	pushl  0x8(%ebp)
  80075b:	e8 9a ff ff ff       	call   8006fa <vsnprintf>
	va_end(ap);

	return rc;
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800768:	b8 00 00 00 00       	mov    $0x0,%eax
  80076d:	eb 03                	jmp    800772 <strlen+0x10>
		n++;
  80076f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800776:	75 f7                	jne    80076f <strlen+0xd>
		n++;
	return n;
}
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800780:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	ba 00 00 00 00       	mov    $0x0,%edx
  800788:	eb 03                	jmp    80078d <strnlen+0x13>
		n++;
  80078a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078d:	39 c2                	cmp    %eax,%edx
  80078f:	74 08                	je     800799 <strnlen+0x1f>
  800791:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800795:	75 f3                	jne    80078a <strnlen+0x10>
  800797:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a5:	89 c2                	mov    %eax,%edx
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	83 c1 01             	add    $0x1,%ecx
  8007ad:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b4:	84 db                	test   %bl,%bl
  8007b6:	75 ef                	jne    8007a7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c2:	53                   	push   %ebx
  8007c3:	e8 9a ff ff ff       	call   800762 <strlen>
  8007c8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	01 d8                	add    %ebx,%eax
  8007d0:	50                   	push   %eax
  8007d1:	e8 c5 ff ff ff       	call   80079b <strcpy>
	return dst;
}
  8007d6:	89 d8                	mov    %ebx,%eax
  8007d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	56                   	push   %esi
  8007e1:	53                   	push   %ebx
  8007e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e8:	89 f3                	mov    %esi,%ebx
  8007ea:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ed:	89 f2                	mov    %esi,%edx
  8007ef:	eb 0f                	jmp    800800 <strncpy+0x23>
		*dst++ = *src;
  8007f1:	83 c2 01             	add    $0x1,%edx
  8007f4:	0f b6 01             	movzbl (%ecx),%eax
  8007f7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fa:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	39 da                	cmp    %ebx,%edx
  800802:	75 ed                	jne    8007f1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800804:	89 f0                	mov    %esi,%eax
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	56                   	push   %esi
  80080e:	53                   	push   %ebx
  80080f:	8b 75 08             	mov    0x8(%ebp),%esi
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800815:	8b 55 10             	mov    0x10(%ebp),%edx
  800818:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081a:	85 d2                	test   %edx,%edx
  80081c:	74 21                	je     80083f <strlcpy+0x35>
  80081e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800822:	89 f2                	mov    %esi,%edx
  800824:	eb 09                	jmp    80082f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	83 c1 01             	add    $0x1,%ecx
  80082c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082f:	39 c2                	cmp    %eax,%edx
  800831:	74 09                	je     80083c <strlcpy+0x32>
  800833:	0f b6 19             	movzbl (%ecx),%ebx
  800836:	84 db                	test   %bl,%bl
  800838:	75 ec                	jne    800826 <strlcpy+0x1c>
  80083a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083f:	29 f0                	sub    %esi,%eax
}
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084e:	eb 06                	jmp    800856 <strcmp+0x11>
		p++, q++;
  800850:	83 c1 01             	add    $0x1,%ecx
  800853:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800856:	0f b6 01             	movzbl (%ecx),%eax
  800859:	84 c0                	test   %al,%al
  80085b:	74 04                	je     800861 <strcmp+0x1c>
  80085d:	3a 02                	cmp    (%edx),%al
  80085f:	74 ef                	je     800850 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800861:	0f b6 c0             	movzbl %al,%eax
  800864:	0f b6 12             	movzbl (%edx),%edx
  800867:	29 d0                	sub    %edx,%eax
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
  800875:	89 c3                	mov    %eax,%ebx
  800877:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087a:	eb 06                	jmp    800882 <strncmp+0x17>
		n--, p++, q++;
  80087c:	83 c0 01             	add    $0x1,%eax
  80087f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800882:	39 d8                	cmp    %ebx,%eax
  800884:	74 15                	je     80089b <strncmp+0x30>
  800886:	0f b6 08             	movzbl (%eax),%ecx
  800889:	84 c9                	test   %cl,%cl
  80088b:	74 04                	je     800891 <strncmp+0x26>
  80088d:	3a 0a                	cmp    (%edx),%cl
  80088f:	74 eb                	je     80087c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800891:	0f b6 00             	movzbl (%eax),%eax
  800894:	0f b6 12             	movzbl (%edx),%edx
  800897:	29 d0                	sub    %edx,%eax
  800899:	eb 05                	jmp    8008a0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ad:	eb 07                	jmp    8008b6 <strchr+0x13>
		if (*s == c)
  8008af:	38 ca                	cmp    %cl,%dl
  8008b1:	74 0f                	je     8008c2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b3:	83 c0 01             	add    $0x1,%eax
  8008b6:	0f b6 10             	movzbl (%eax),%edx
  8008b9:	84 d2                	test   %dl,%dl
  8008bb:	75 f2                	jne    8008af <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ce:	eb 03                	jmp    8008d3 <strfind+0xf>
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	74 04                	je     8008de <strfind+0x1a>
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	75 f2                	jne    8008d0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	57                   	push   %edi
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ec:	85 c9                	test   %ecx,%ecx
  8008ee:	74 36                	je     800926 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f6:	75 28                	jne    800920 <memset+0x40>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 23                	jne    800920 <memset+0x40>
		c &= 0xFF;
  8008fd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800901:	89 d3                	mov    %edx,%ebx
  800903:	c1 e3 08             	shl    $0x8,%ebx
  800906:	89 d6                	mov    %edx,%esi
  800908:	c1 e6 18             	shl    $0x18,%esi
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	c1 e0 10             	shl    $0x10,%eax
  800910:	09 f0                	or     %esi,%eax
  800912:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800914:	89 d8                	mov    %ebx,%eax
  800916:	09 d0                	or     %edx,%eax
  800918:	c1 e9 02             	shr    $0x2,%ecx
  80091b:	fc                   	cld    
  80091c:	f3 ab                	rep stos %eax,%es:(%edi)
  80091e:	eb 06                	jmp    800926 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800920:	8b 45 0c             	mov    0xc(%ebp),%eax
  800923:	fc                   	cld    
  800924:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800926:	89 f8                	mov    %edi,%eax
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 75 0c             	mov    0xc(%ebp),%esi
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093b:	39 c6                	cmp    %eax,%esi
  80093d:	73 35                	jae    800974 <memmove+0x47>
  80093f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800942:	39 d0                	cmp    %edx,%eax
  800944:	73 2e                	jae    800974 <memmove+0x47>
		s += n;
		d += n;
  800946:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800949:	89 d6                	mov    %edx,%esi
  80094b:	09 fe                	or     %edi,%esi
  80094d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800953:	75 13                	jne    800968 <memmove+0x3b>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0e                	jne    800968 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80095a:	83 ef 04             	sub    $0x4,%edi
  80095d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800960:	c1 e9 02             	shr    $0x2,%ecx
  800963:	fd                   	std    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 09                	jmp    800971 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800968:	83 ef 01             	sub    $0x1,%edi
  80096b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096e:	fd                   	std    
  80096f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800971:	fc                   	cld    
  800972:	eb 1d                	jmp    800991 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	89 f2                	mov    %esi,%edx
  800976:	09 c2                	or     %eax,%edx
  800978:	f6 c2 03             	test   $0x3,%dl
  80097b:	75 0f                	jne    80098c <memmove+0x5f>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 0a                	jne    80098c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800982:	c1 e9 02             	shr    $0x2,%ecx
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098a:	eb 05                	jmp    800991 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098c:	89 c7                	mov    %eax,%edi
  80098e:	fc                   	cld    
  80098f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800991:	5e                   	pop    %esi
  800992:	5f                   	pop    %edi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800998:	ff 75 10             	pushl  0x10(%ebp)
  80099b:	ff 75 0c             	pushl  0xc(%ebp)
  80099e:	ff 75 08             	pushl  0x8(%ebp)
  8009a1:	e8 87 ff ff ff       	call   80092d <memmove>
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b3:	89 c6                	mov    %eax,%esi
  8009b5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b8:	eb 1a                	jmp    8009d4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ba:	0f b6 08             	movzbl (%eax),%ecx
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	38 d9                	cmp    %bl,%cl
  8009c2:	74 0a                	je     8009ce <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c4:	0f b6 c1             	movzbl %cl,%eax
  8009c7:	0f b6 db             	movzbl %bl,%ebx
  8009ca:	29 d8                	sub    %ebx,%eax
  8009cc:	eb 0f                	jmp    8009dd <memcmp+0x35>
		s1++, s2++;
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d4:	39 f0                	cmp    %esi,%eax
  8009d6:	75 e2                	jne    8009ba <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	53                   	push   %ebx
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e8:	89 c1                	mov    %eax,%ecx
  8009ea:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f1:	eb 0a                	jmp    8009fd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f3:	0f b6 10             	movzbl (%eax),%edx
  8009f6:	39 da                	cmp    %ebx,%edx
  8009f8:	74 07                	je     800a01 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	39 c8                	cmp    %ecx,%eax
  8009ff:	72 f2                	jb     8009f3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a01:	5b                   	pop    %ebx
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a10:	eb 03                	jmp    800a15 <strtol+0x11>
		s++;
  800a12:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a15:	0f b6 01             	movzbl (%ecx),%eax
  800a18:	3c 20                	cmp    $0x20,%al
  800a1a:	74 f6                	je     800a12 <strtol+0xe>
  800a1c:	3c 09                	cmp    $0x9,%al
  800a1e:	74 f2                	je     800a12 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a20:	3c 2b                	cmp    $0x2b,%al
  800a22:	75 0a                	jne    800a2e <strtol+0x2a>
		s++;
  800a24:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2c:	eb 11                	jmp    800a3f <strtol+0x3b>
  800a2e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a33:	3c 2d                	cmp    $0x2d,%al
  800a35:	75 08                	jne    800a3f <strtol+0x3b>
		s++, neg = 1;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a45:	75 15                	jne    800a5c <strtol+0x58>
  800a47:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4a:	75 10                	jne    800a5c <strtol+0x58>
  800a4c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a50:	75 7c                	jne    800ace <strtol+0xca>
		s += 2, base = 16;
  800a52:	83 c1 02             	add    $0x2,%ecx
  800a55:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5a:	eb 16                	jmp    800a72 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5c:	85 db                	test   %ebx,%ebx
  800a5e:	75 12                	jne    800a72 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a60:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	75 08                	jne    800a72 <strtol+0x6e>
		s++, base = 8;
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7a:	0f b6 11             	movzbl (%ecx),%edx
  800a7d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 09             	cmp    $0x9,%bl
  800a85:	77 08                	ja     800a8f <strtol+0x8b>
			dig = *s - '0';
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 30             	sub    $0x30,%edx
  800a8d:	eb 22                	jmp    800ab1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 19             	cmp    $0x19,%bl
  800a97:	77 08                	ja     800aa1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a99:	0f be d2             	movsbl %dl,%edx
  800a9c:	83 ea 57             	sub    $0x57,%edx
  800a9f:	eb 10                	jmp    800ab1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa4:	89 f3                	mov    %esi,%ebx
  800aa6:	80 fb 19             	cmp    $0x19,%bl
  800aa9:	77 16                	ja     800ac1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aab:	0f be d2             	movsbl %dl,%edx
  800aae:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab4:	7d 0b                	jge    800ac1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abf:	eb b9                	jmp    800a7a <strtol+0x76>

	if (endptr)
  800ac1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac5:	74 0d                	je     800ad4 <strtol+0xd0>
		*endptr = (char *) s;
  800ac7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aca:	89 0e                	mov    %ecx,(%esi)
  800acc:	eb 06                	jmp    800ad4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ace:	85 db                	test   %ebx,%ebx
  800ad0:	74 98                	je     800a6a <strtol+0x66>
  800ad2:	eb 9e                	jmp    800a72 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad4:	89 c2                	mov    %eax,%edx
  800ad6:	f7 da                	neg    %edx
  800ad8:	85 ff                	test   %edi,%edi
  800ada:	0f 45 c2             	cmovne %edx,%eax
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	89 c7                	mov    %eax,%edi
  800af7:	89 c6                	mov    %eax,%esi
  800af9:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b10:	89 d1                	mov    %edx,%ecx
  800b12:	89 d3                	mov    %edx,%ebx
  800b14:	89 d7                	mov    %edx,%edi
  800b16:	89 d6                	mov    %edx,%esi
  800b18:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	89 cb                	mov    %ecx,%ebx
  800b37:	89 cf                	mov    %ecx,%edi
  800b39:	89 ce                	mov    %ecx,%esi
  800b3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7e 17                	jle    800b58 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 03                	push   $0x3
  800b47:	68 c4 12 80 00       	push   $0x8012c4
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 e1 12 80 00       	push   $0x8012e1
  800b53:	e8 23 02 00 00       	call   800d7b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b70:	89 d1                	mov    %edx,%ecx
  800b72:	89 d3                	mov    %edx,%ebx
  800b74:	89 d7                	mov    %edx,%edi
  800b76:	89 d6                	mov    %edx,%esi
  800b78:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_yield>:

void
sys_yield(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba7:	be 00 00 00 00       	mov    $0x0,%esi
  800bac:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bba:	89 f7                	mov    %esi,%edi
  800bbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 04                	push   $0x4
  800bc8:	68 c4 12 80 00       	push   $0x8012c4
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 e1 12 80 00       	push   $0x8012e1
  800bd4:	e8 a2 01 00 00       	call   800d7b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bea:	b8 05 00 00 00       	mov    $0x5,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 05                	push   $0x5
  800c0a:	68 c4 12 80 00       	push   $0x8012c4
  800c0f:	6a 23                	push   $0x23
  800c11:	68 e1 12 80 00       	push   $0x8012e1
  800c16:	e8 60 01 00 00       	call   800d7b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	b8 06 00 00 00       	mov    $0x6,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 06                	push   $0x6
  800c4c:	68 c4 12 80 00       	push   $0x8012c4
  800c51:	6a 23                	push   $0x23
  800c53:	68 e1 12 80 00       	push   $0x8012e1
  800c58:	e8 1e 01 00 00       	call   800d7b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 08 00 00 00       	mov    $0x8,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 08                	push   $0x8
  800c8e:	68 c4 12 80 00       	push   $0x8012c4
  800c93:	6a 23                	push   $0x23
  800c95:	68 e1 12 80 00       	push   $0x8012e1
  800c9a:	e8 dc 00 00 00       	call   800d7b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 09                	push   $0x9
  800cd0:	68 c4 12 80 00       	push   $0x8012c4
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 e1 12 80 00       	push   $0x8012e1
  800cdc:	e8 9a 00 00 00       	call   800d7b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cef:	be 00 00 00 00       	mov    $0x0,%esi
  800cf4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d05:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 cb                	mov    %ecx,%ebx
  800d24:	89 cf                	mov    %ecx,%edi
  800d26:	89 ce                	mov    %ecx,%esi
  800d28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 0c                	push   $0xc
  800d34:	68 c4 12 80 00       	push   $0x8012c4
  800d39:	6a 23                	push   $0x23
  800d3b:	68 e1 12 80 00       	push   $0x8012e1
  800d40:	e8 36 00 00 00       	call   800d7b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d53:	68 fb 12 80 00       	push   $0x8012fb
  800d58:	6a 51                	push   $0x51
  800d5a:	68 ef 12 80 00       	push   $0x8012ef
  800d5f:	e8 17 00 00 00       	call   800d7b <_panic>

00800d64 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d6a:	68 fa 12 80 00       	push   $0x8012fa
  800d6f:	6a 58                	push   $0x58
  800d71:	68 ef 12 80 00       	push   $0x8012ef
  800d76:	e8 00 00 00 00       	call   800d7b <_panic>

00800d7b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d80:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d83:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d89:	e8 d2 fd ff ff       	call   800b60 <sys_getenvid>
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	ff 75 0c             	pushl  0xc(%ebp)
  800d94:	ff 75 08             	pushl  0x8(%ebp)
  800d97:	56                   	push   %esi
  800d98:	50                   	push   %eax
  800d99:	68 10 13 80 00       	push   $0x801310
  800d9e:	e8 29 f4 ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da3:	83 c4 18             	add    $0x18,%esp
  800da6:	53                   	push   %ebx
  800da7:	ff 75 10             	pushl  0x10(%ebp)
  800daa:	e8 cc f3 ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  800daf:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800db6:	e8 11 f4 ff ff       	call   8001cc <cprintf>
  800dbb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dbe:	cc                   	int3   
  800dbf:	eb fd                	jmp    800dbe <_panic+0x43>
  800dc1:	66 90                	xchg   %ax,%ax
  800dc3:	66 90                	xchg   %ax,%ax
  800dc5:	66 90                	xchg   %ax,%ax
  800dc7:	66 90                	xchg   %ax,%ax
  800dc9:	66 90                	xchg   %ax,%ax
  800dcb:	66 90                	xchg   %ax,%ax
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 1c             	sub    $0x1c,%esp
  800dd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ddb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ddf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800de7:	85 f6                	test   %esi,%esi
  800de9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ded:	89 ca                	mov    %ecx,%edx
  800def:	89 f8                	mov    %edi,%eax
  800df1:	75 3d                	jne    800e30 <__udivdi3+0x60>
  800df3:	39 cf                	cmp    %ecx,%edi
  800df5:	0f 87 c5 00 00 00    	ja     800ec0 <__udivdi3+0xf0>
  800dfb:	85 ff                	test   %edi,%edi
  800dfd:	89 fd                	mov    %edi,%ebp
  800dff:	75 0b                	jne    800e0c <__udivdi3+0x3c>
  800e01:	b8 01 00 00 00       	mov    $0x1,%eax
  800e06:	31 d2                	xor    %edx,%edx
  800e08:	f7 f7                	div    %edi
  800e0a:	89 c5                	mov    %eax,%ebp
  800e0c:	89 c8                	mov    %ecx,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  800e10:	f7 f5                	div    %ebp
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	89 d8                	mov    %ebx,%eax
  800e16:	89 cf                	mov    %ecx,%edi
  800e18:	f7 f5                	div    %ebp
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 1c             	add    $0x1c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 ce                	cmp    %ecx,%esi
  800e32:	77 74                	ja     800ea8 <__udivdi3+0xd8>
  800e34:	0f bd fe             	bsr    %esi,%edi
  800e37:	83 f7 1f             	xor    $0x1f,%edi
  800e3a:	0f 84 98 00 00 00    	je     800ed8 <__udivdi3+0x108>
  800e40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	89 c5                	mov    %eax,%ebp
  800e49:	29 fb                	sub    %edi,%ebx
  800e4b:	d3 e6                	shl    %cl,%esi
  800e4d:	89 d9                	mov    %ebx,%ecx
  800e4f:	d3 ed                	shr    %cl,%ebp
  800e51:	89 f9                	mov    %edi,%ecx
  800e53:	d3 e0                	shl    %cl,%eax
  800e55:	09 ee                	or     %ebp,%esi
  800e57:	89 d9                	mov    %ebx,%ecx
  800e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5d:	89 d5                	mov    %edx,%ebp
  800e5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e63:	d3 ed                	shr    %cl,%ebp
  800e65:	89 f9                	mov    %edi,%ecx
  800e67:	d3 e2                	shl    %cl,%edx
  800e69:	89 d9                	mov    %ebx,%ecx
  800e6b:	d3 e8                	shr    %cl,%eax
  800e6d:	09 c2                	or     %eax,%edx
  800e6f:	89 d0                	mov    %edx,%eax
  800e71:	89 ea                	mov    %ebp,%edx
  800e73:	f7 f6                	div    %esi
  800e75:	89 d5                	mov    %edx,%ebp
  800e77:	89 c3                	mov    %eax,%ebx
  800e79:	f7 64 24 0c          	mull   0xc(%esp)
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	72 10                	jb     800e91 <__udivdi3+0xc1>
  800e81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	d3 e6                	shl    %cl,%esi
  800e89:	39 c6                	cmp    %eax,%esi
  800e8b:	73 07                	jae    800e94 <__udivdi3+0xc4>
  800e8d:	39 d5                	cmp    %edx,%ebp
  800e8f:	75 03                	jne    800e94 <__udivdi3+0xc4>
  800e91:	83 eb 01             	sub    $0x1,%ebx
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	89 d8                	mov    %ebx,%eax
  800e98:	89 fa                	mov    %edi,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	31 ff                	xor    %edi,%edi
  800eaa:	31 db                	xor    %ebx,%ebx
  800eac:	89 d8                	mov    %ebx,%eax
  800eae:	89 fa                	mov    %edi,%edx
  800eb0:	83 c4 1c             	add    $0x1c,%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
  800eb8:	90                   	nop
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 d8                	mov    %ebx,%eax
  800ec2:	f7 f7                	div    %edi
  800ec4:	31 ff                	xor    %edi,%edi
  800ec6:	89 c3                	mov    %eax,%ebx
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	89 fa                	mov    %edi,%edx
  800ecc:	83 c4 1c             	add    $0x1c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    
  800ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	39 ce                	cmp    %ecx,%esi
  800eda:	72 0c                	jb     800ee8 <__udivdi3+0x118>
  800edc:	31 db                	xor    %ebx,%ebx
  800ede:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ee2:	0f 87 34 ff ff ff    	ja     800e1c <__udivdi3+0x4c>
  800ee8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800eed:	e9 2a ff ff ff       	jmp    800e1c <__udivdi3+0x4c>
  800ef2:	66 90                	xchg   %ax,%ax
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f17:	85 d2                	test   %edx,%edx
  800f19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 f3                	mov    %esi,%ebx
  800f23:	89 3c 24             	mov    %edi,(%esp)
  800f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2a:	75 1c                	jne    800f48 <__umoddi3+0x48>
  800f2c:	39 f7                	cmp    %esi,%edi
  800f2e:	76 50                	jbe    800f80 <__umoddi3+0x80>
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	f7 f7                	div    %edi
  800f36:	89 d0                	mov    %edx,%eax
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	77 52                	ja     800fa0 <__umoddi3+0xa0>
  800f4e:	0f bd ea             	bsr    %edx,%ebp
  800f51:	83 f5 1f             	xor    $0x1f,%ebp
  800f54:	75 5a                	jne    800fb0 <__umoddi3+0xb0>
  800f56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	39 0c 24             	cmp    %ecx,(%esp)
  800f63:	0f 86 d7 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f71:	83 c4 1c             	add    $0x1c,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	85 ff                	test   %edi,%edi
  800f82:	89 fd                	mov    %edi,%ebp
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 f0                	mov    %esi,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 c8                	mov    %ecx,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	eb 99                	jmp    800f38 <__umoddi3+0x38>
  800f9f:	90                   	nop
  800fa0:	89 c8                	mov    %ecx,%eax
  800fa2:	89 f2                	mov    %esi,%edx
  800fa4:	83 c4 1c             	add    $0x1c,%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	8b 34 24             	mov    (%esp),%esi
  800fb3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	29 ef                	sub    %ebp,%edi
  800fbc:	d3 e0                	shl    %cl,%eax
  800fbe:	89 f9                	mov    %edi,%ecx
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	d3 ea                	shr    %cl,%edx
  800fc4:	89 e9                	mov    %ebp,%ecx
  800fc6:	09 c2                	or     %eax,%edx
  800fc8:	89 d8                	mov    %ebx,%eax
  800fca:	89 14 24             	mov    %edx,(%esp)
  800fcd:	89 f2                	mov    %esi,%edx
  800fcf:	d3 e2                	shl    %cl,%edx
  800fd1:	89 f9                	mov    %edi,%ecx
  800fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fdb:	d3 e8                	shr    %cl,%eax
  800fdd:	89 e9                	mov    %ebp,%ecx
  800fdf:	89 c6                	mov    %eax,%esi
  800fe1:	d3 e3                	shl    %cl,%ebx
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	89 d0                	mov    %edx,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	09 d8                	or     %ebx,%eax
  800fed:	89 d3                	mov    %edx,%ebx
  800fef:	89 f2                	mov    %esi,%edx
  800ff1:	f7 34 24             	divl   (%esp)
  800ff4:	89 d6                	mov    %edx,%esi
  800ff6:	d3 e3                	shl    %cl,%ebx
  800ff8:	f7 64 24 04          	mull   0x4(%esp)
  800ffc:	39 d6                	cmp    %edx,%esi
  800ffe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801002:	89 d1                	mov    %edx,%ecx
  801004:	89 c3                	mov    %eax,%ebx
  801006:	72 08                	jb     801010 <__umoddi3+0x110>
  801008:	75 11                	jne    80101b <__umoddi3+0x11b>
  80100a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80100e:	73 0b                	jae    80101b <__umoddi3+0x11b>
  801010:	2b 44 24 04          	sub    0x4(%esp),%eax
  801014:	1b 14 24             	sbb    (%esp),%edx
  801017:	89 d1                	mov    %edx,%ecx
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80101f:	29 da                	sub    %ebx,%edx
  801021:	19 ce                	sbb    %ecx,%esi
  801023:	89 f9                	mov    %edi,%ecx
  801025:	89 f0                	mov    %esi,%eax
  801027:	d3 e0                	shl    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	d3 ea                	shr    %cl,%edx
  80102d:	89 e9                	mov    %ebp,%ecx
  80102f:	d3 ee                	shr    %cl,%esi
  801031:	09 d0                	or     %edx,%eax
  801033:	89 f2                	mov    %esi,%edx
  801035:	83 c4 1c             	add    $0x1c,%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 f9                	sub    %edi,%ecx
  801042:	19 d6                	sbb    %edx,%esi
  801044:	89 74 24 04          	mov    %esi,0x4(%esp)
  801048:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80104c:	e9 18 ff ff ff       	jmp    800f69 <__umoddi3+0x69>
