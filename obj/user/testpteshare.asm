
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 37 08 00 00       	call   800880 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 0a 0c 00 00       	call   800c83 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 4c 29 80 00       	push   $0x80294c
  800086:	6a 13                	push   $0x13
  800088:	68 5f 29 80 00       	push   $0x80295f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 95 0f 00 00       	call   80102c <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 73 29 80 00       	push   $0x802973
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 5f 29 80 00       	push   $0x80295f
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 ba 07 00 00       	call   800880 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 5e 22 00 00       	call   802335 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 40 08 00 00       	call   80092a <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 46 29 80 00       	mov    $0x802946,%edx
  8000f4:	b8 40 29 80 00       	mov    $0x802940,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 7c 29 80 00       	push   $0x80297c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 97 29 80 00       	push   $0x802997
  80010e:	68 9c 29 80 00       	push   $0x80299c
  800113:	68 9b 29 80 00       	push   $0x80299b
  800118:	e8 49 1e 00 00       	call   801f66 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 a9 29 80 00       	push   $0x8029a9
  80012a:	6a 21                	push   $0x21
  80012c:	68 5f 29 80 00       	push   $0x80295f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 f6 21 00 00       	call   802335 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 d8 07 00 00       	call   80092a <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 46 29 80 00       	mov    $0x802946,%edx
  80015c:	b8 40 29 80 00       	mov    $0x802940,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 b3 29 80 00       	push   $0x8029b3
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 bd 0a 00 00       	call   800c45 <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 50 80 00       	mov    %eax,0x805004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 23 12 00 00       	call   8013ec <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 31 0a 00 00       	call   800c04 <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001e6:	e8 5a 0a 00 00       	call   800c45 <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 f8 29 80 00       	push   $0x8029f8
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 10 2e 80 00 	movl   $0x802e10,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 79 09 00 00       	call   800bc7 <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 54 01 00 00       	call   8003e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 1e 09 00 00       	call   800bc7 <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 97 23 00 00       	call   8026b0 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 84 24 00 00       	call   8027e0 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 22                	jmp    8003ac <getuint+0x38>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 10                	je     80039e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 0e                	jmp    8003ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bd:	73 0a                	jae    8003c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	88 02                	mov    %al,(%edx)
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d4:	50                   	push   %eax
  8003d5:	ff 75 10             	pushl  0x10(%ebp)
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 05 00 00 00       	call   8003e8 <vprintfmt>
	va_end(ap);
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 2c             	sub    $0x2c,%esp
  8003f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fa:	eb 12                	jmp    80040e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	0f 84 d3 03 00 00    	je     8007d7 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	50                   	push   %eax
  800409:	ff d6                	call   *%esi
  80040b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040e:	83 c7 01             	add    $0x1,%edi
  800411:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	75 e2                	jne    8003fc <vprintfmt+0x14>
  80041a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800425:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80042c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
  800438:	eb 07                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8d 47 01             	lea    0x1(%edi),%eax
  800444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800447:	0f b6 07             	movzbl (%edi),%eax
  80044a:	0f b6 c8             	movzbl %al,%ecx
  80044d:	83 e8 23             	sub    $0x23,%eax
  800450:	3c 55                	cmp    $0x55,%al
  800452:	0f 87 64 03 00 00    	ja     8007bc <vprintfmt+0x3d4>
  800458:	0f b6 c0             	movzbl %al,%eax
  80045b:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800465:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800469:	eb d6                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800476:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800479:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800480:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 39                	ja     8004c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800488:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048b:	eb e9                	jmp    800476 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 48 04             	lea    0x4(%eax),%ecx
  800493:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049e:	eb 27                	jmp    8004c7 <vprintfmt+0xdf>
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004aa:	0f 49 c8             	cmovns %eax,%ecx
  8004ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b3:	eb 8c                	jmp    800441 <vprintfmt+0x59>
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bf:	eb 80                	jmp    800441 <vprintfmt+0x59>
  8004c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c4:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8004c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cb:	0f 89 70 ff ff ff    	jns    800441 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004de:	e9 5e ff ff ff       	jmp    800441 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e9:	e9 53 ff ff ff       	jmp    800441 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800505:	e9 04 ff ff ff       	jmp    80040e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	99                   	cltd   
  800516:	31 d0                	xor    %edx,%eax
  800518:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051a:	83 f8 0f             	cmp    $0xf,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x142>
  80051f:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 33 2a 80 00       	push   $0x802a33
  800530:	53                   	push   %ebx
  800531:	56                   	push   %esi
  800532:	e8 94 fe ff ff       	call   8003cb <printfmt>
  800537:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053d:	e9 cc fe ff ff       	jmp    80040e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800542:	52                   	push   %edx
  800543:	68 55 2f 80 00       	push   $0x802f55
  800548:	53                   	push   %ebx
  800549:	56                   	push   %esi
  80054a:	e8 7c fe ff ff       	call   8003cb <printfmt>
  80054f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800555:	e9 b4 fe ff ff       	jmp    80040e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 2c 2a 80 00       	mov    $0x802a2c,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e 94 00 00 00    	jle    80060d <vprintfmt+0x225>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	0f 84 98 00 00 00    	je     80061b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 c8             	pushl  -0x38(%ebp)
  800589:	57                   	push   %edi
  80058a:	e8 d0 02 00 00       	call   80085f <strnlen>
  80058f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800592:	29 c1                	sub    %eax,%ecx
  800594:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	eb 0f                	jmp    8005b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8005af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f ed                	jg     8005a8 <vprintfmt+0x1c0>
  8005bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005be:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c8:	0f 49 c1             	cmovns %ecx,%eax
  8005cb:	29 c1                	sub    %eax,%ecx
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	89 cb                	mov    %ecx,%ebx
  8005d8:	eb 4d                	jmp    800627 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005de:	74 1b                	je     8005fb <vprintfmt+0x213>
  8005e0:	0f be c0             	movsbl %al,%eax
  8005e3:	83 e8 20             	sub    $0x20,%eax
  8005e6:	83 f8 5e             	cmp    $0x5e,%eax
  8005e9:	76 10                	jbe    8005fb <vprintfmt+0x213>
					putch('?', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	ff 75 0c             	pushl  0xc(%ebp)
  8005f1:	6a 3f                	push   $0x3f
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	eb 0d                	jmp    800608 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	52                   	push   %edx
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	83 eb 01             	sub    $0x1,%ebx
  80060b:	eb 1a                	jmp    800627 <vprintfmt+0x23f>
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800619:	eb 0c                	jmp    800627 <vprintfmt+0x23f>
  80061b:	89 75 08             	mov    %esi,0x8(%ebp)
  80061e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800621:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800624:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800627:	83 c7 01             	add    $0x1,%edi
  80062a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062e:	0f be d0             	movsbl %al,%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	74 23                	je     800658 <vprintfmt+0x270>
  800635:	85 f6                	test   %esi,%esi
  800637:	78 a1                	js     8005da <vprintfmt+0x1f2>
  800639:	83 ee 01             	sub    $0x1,%esi
  80063c:	79 9c                	jns    8005da <vprintfmt+0x1f2>
  80063e:	89 df                	mov    %ebx,%edi
  800640:	8b 75 08             	mov    0x8(%ebp),%esi
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800646:	eb 18                	jmp    800660 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 20                	push   $0x20
  80064e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 08                	jmp    800660 <vprintfmt+0x278>
  800658:	89 df                	mov    %ebx,%edi
  80065a:	8b 75 08             	mov    0x8(%ebp),%esi
  80065d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800660:	85 ff                	test   %edi,%edi
  800662:	7f e4                	jg     800648 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	e9 a2 fd ff ff       	jmp    80040e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066c:	83 fa 01             	cmp    $0x1,%edx
  80066f:	7e 16                	jle    800687 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 08             	lea    0x8(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 50 04             	mov    0x4(%eax),%edx
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800682:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800685:	eb 32                	jmp    8006b9 <vprintfmt+0x2d1>
	else if (lflag)
  800687:	85 d2                	test   %edx,%edx
  800689:	74 18                	je     8006a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800699:	89 c1                	mov    %eax,%ecx
  80069b:	c1 f9 1f             	sar    $0x1f,%ecx
  80069e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006a1:	eb 16                	jmp    8006b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 04             	lea    0x4(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006b1:	89 c1                	mov    %eax,%ecx
  8006b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006bc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ca:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006ce:	0f 89 b0 00 00 00    	jns    800784 <vprintfmt+0x39c>
				putch('-', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 2d                	push   $0x2d
  8006da:	ff d6                	call   *%esi
				num = -(long long) num;
  8006dc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006df:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006e2:	f7 d8                	neg    %eax
  8006e4:	83 d2 00             	adc    $0x0,%edx
  8006e7:	f7 da                	neg    %edx
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ef:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f7:	e9 88 00 00 00       	jmp    800784 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ff:	e8 70 fc ff ff       	call   800374 <getuint>
  800704:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800707:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80070a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80070f:	eb 73                	jmp    800784 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800711:	8d 45 14             	lea    0x14(%ebp),%eax
  800714:	e8 5b fc ff ff       	call   800374 <getuint>
  800719:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	6a 58                	push   $0x58
  800725:	ff d6                	call   *%esi
			putch('X', putdat);
  800727:	83 c4 08             	add    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	6a 58                	push   $0x58
  80072d:	ff d6                	call   *%esi
			putch('X', putdat);
  80072f:	83 c4 08             	add    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 58                	push   $0x58
  800735:	ff d6                	call   *%esi
			goto number;
  800737:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80073a:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80073f:	eb 43                	jmp    800784 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 30                	push   $0x30
  800747:	ff d6                	call   *%esi
			putch('x', putdat);
  800749:	83 c4 08             	add    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 78                	push   $0x78
  80074f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 50 04             	lea    0x4(%eax),%edx
  800757:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075a:	8b 00                	mov    (%eax),%eax
  80075c:	ba 00 00 00 00       	mov    $0x0,%edx
  800761:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800764:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800767:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80076f:	eb 13                	jmp    800784 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 fb fb ff ff       	call   800374 <getuint>
  800779:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80077f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800784:	83 ec 0c             	sub    $0xc,%esp
  800787:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80078b:	52                   	push   %edx
  80078c:	ff 75 e0             	pushl  -0x20(%ebp)
  80078f:	50                   	push   %eax
  800790:	ff 75 dc             	pushl  -0x24(%ebp)
  800793:	ff 75 d8             	pushl  -0x28(%ebp)
  800796:	89 da                	mov    %ebx,%edx
  800798:	89 f0                	mov    %esi,%eax
  80079a:	e8 26 fb ff ff       	call   8002c5 <printnum>
			break;
  80079f:	83 c4 20             	add    $0x20,%esp
  8007a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a5:	e9 64 fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	53                   	push   %ebx
  8007ae:	51                   	push   %ecx
  8007af:	ff d6                	call   *%esi
			break;
  8007b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007b7:	e9 52 fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	53                   	push   %ebx
  8007c0:	6a 25                	push   $0x25
  8007c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	eb 03                	jmp    8007cc <vprintfmt+0x3e4>
  8007c9:	83 ef 01             	sub    $0x1,%edi
  8007cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d0:	75 f7                	jne    8007c9 <vprintfmt+0x3e1>
  8007d2:	e9 37 fc ff ff       	jmp    80040e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5f                   	pop    %edi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 18             	sub    $0x18,%esp
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	74 26                	je     800826 <vsnprintf+0x47>
  800800:	85 d2                	test   %edx,%edx
  800802:	7e 22                	jle    800826 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800804:	ff 75 14             	pushl  0x14(%ebp)
  800807:	ff 75 10             	pushl  0x10(%ebp)
  80080a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080d:	50                   	push   %eax
  80080e:	68 ae 03 80 00       	push   $0x8003ae
  800813:	e8 d0 fb ff ff       	call   8003e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800818:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	eb 05                	jmp    80082b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800826:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800836:	50                   	push   %eax
  800837:	ff 75 10             	pushl  0x10(%ebp)
  80083a:	ff 75 0c             	pushl  0xc(%ebp)
  80083d:	ff 75 08             	pushl  0x8(%ebp)
  800840:	e8 9a ff ff ff       	call   8007df <vsnprintf>
	va_end(ap);

	return rc;
}
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
  800852:	eb 03                	jmp    800857 <strlen+0x10>
		n++;
  800854:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800857:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80085b:	75 f7                	jne    800854 <strlen+0xd>
		n++;
	return n;
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800865:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	ba 00 00 00 00       	mov    $0x0,%edx
  80086d:	eb 03                	jmp    800872 <strnlen+0x13>
		n++;
  80086f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800872:	39 c2                	cmp    %eax,%edx
  800874:	74 08                	je     80087e <strnlen+0x1f>
  800876:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80087a:	75 f3                	jne    80086f <strnlen+0x10>
  80087c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	53                   	push   %ebx
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80088a:	89 c2                	mov    %eax,%edx
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	83 c1 01             	add    $0x1,%ecx
  800892:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800896:	88 5a ff             	mov    %bl,-0x1(%edx)
  800899:	84 db                	test   %bl,%bl
  80089b:	75 ef                	jne    80088c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a7:	53                   	push   %ebx
  8008a8:	e8 9a ff ff ff       	call   800847 <strlen>
  8008ad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	01 d8                	add    %ebx,%eax
  8008b5:	50                   	push   %eax
  8008b6:	e8 c5 ff ff ff       	call   800880 <strcpy>
	return dst;
}
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	89 f3                	mov    %esi,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	eb 0f                	jmp    8008e5 <strncpy+0x23>
		*dst++ = *src;
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008df:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e5:	39 da                	cmp    %ebx,%edx
  8008e7:	75 ed                	jne    8008d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e9:	89 f0                	mov    %esi,%eax
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8008fd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ff:	85 d2                	test   %edx,%edx
  800901:	74 21                	je     800924 <strlcpy+0x35>
  800903:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800907:	89 f2                	mov    %esi,%edx
  800909:	eb 09                	jmp    800914 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	83 c1 01             	add    $0x1,%ecx
  800911:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800914:	39 c2                	cmp    %eax,%edx
  800916:	74 09                	je     800921 <strlcpy+0x32>
  800918:	0f b6 19             	movzbl (%ecx),%ebx
  80091b:	84 db                	test   %bl,%bl
  80091d:	75 ec                	jne    80090b <strlcpy+0x1c>
  80091f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800921:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800924:	29 f0                	sub    %esi,%eax
}
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800933:	eb 06                	jmp    80093b <strcmp+0x11>
		p++, q++;
  800935:	83 c1 01             	add    $0x1,%ecx
  800938:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093b:	0f b6 01             	movzbl (%ecx),%eax
  80093e:	84 c0                	test   %al,%al
  800940:	74 04                	je     800946 <strcmp+0x1c>
  800942:	3a 02                	cmp    (%edx),%al
  800944:	74 ef                	je     800935 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800946:	0f b6 c0             	movzbl %al,%eax
  800949:	0f b6 12             	movzbl (%edx),%edx
  80094c:	29 d0                	sub    %edx,%eax
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095a:	89 c3                	mov    %eax,%ebx
  80095c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80095f:	eb 06                	jmp    800967 <strncmp+0x17>
		n--, p++, q++;
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800967:	39 d8                	cmp    %ebx,%eax
  800969:	74 15                	je     800980 <strncmp+0x30>
  80096b:	0f b6 08             	movzbl (%eax),%ecx
  80096e:	84 c9                	test   %cl,%cl
  800970:	74 04                	je     800976 <strncmp+0x26>
  800972:	3a 0a                	cmp    (%edx),%cl
  800974:	74 eb                	je     800961 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 00             	movzbl (%eax),%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
  80097e:	eb 05                	jmp    800985 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800985:	5b                   	pop    %ebx
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800992:	eb 07                	jmp    80099b <strchr+0x13>
		if (*s == c)
  800994:	38 ca                	cmp    %cl,%dl
  800996:	74 0f                	je     8009a7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	0f b6 10             	movzbl (%eax),%edx
  80099e:	84 d2                	test   %dl,%dl
  8009a0:	75 f2                	jne    800994 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b3:	eb 03                	jmp    8009b8 <strfind+0xf>
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009bb:	38 ca                	cmp    %cl,%dl
  8009bd:	74 04                	je     8009c3 <strfind+0x1a>
  8009bf:	84 d2                	test   %dl,%dl
  8009c1:	75 f2                	jne    8009b5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	57                   	push   %edi
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d1:	85 c9                	test   %ecx,%ecx
  8009d3:	74 36                	je     800a0b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009db:	75 28                	jne    800a05 <memset+0x40>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 23                	jne    800a05 <memset+0x40>
		c &= 0xFF;
  8009e2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e6:	89 d3                	mov    %edx,%ebx
  8009e8:	c1 e3 08             	shl    $0x8,%ebx
  8009eb:	89 d6                	mov    %edx,%esi
  8009ed:	c1 e6 18             	shl    $0x18,%esi
  8009f0:	89 d0                	mov    %edx,%eax
  8009f2:	c1 e0 10             	shl    $0x10,%eax
  8009f5:	09 f0                	or     %esi,%eax
  8009f7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009f9:	89 d8                	mov    %ebx,%eax
  8009fb:	09 d0                	or     %edx,%eax
  8009fd:	c1 e9 02             	shr    $0x2,%ecx
  800a00:	fc                   	cld    
  800a01:	f3 ab                	rep stos %eax,%es:(%edi)
  800a03:	eb 06                	jmp    800a0b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a08:	fc                   	cld    
  800a09:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0b:	89 f8                	mov    %edi,%eax
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5f                   	pop    %edi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a20:	39 c6                	cmp    %eax,%esi
  800a22:	73 35                	jae    800a59 <memmove+0x47>
  800a24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	73 2e                	jae    800a59 <memmove+0x47>
		s += n;
		d += n;
  800a2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	89 d6                	mov    %edx,%esi
  800a30:	09 fe                	or     %edi,%esi
  800a32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a38:	75 13                	jne    800a4d <memmove+0x3b>
  800a3a:	f6 c1 03             	test   $0x3,%cl
  800a3d:	75 0e                	jne    800a4d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a3f:	83 ef 04             	sub    $0x4,%edi
  800a42:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a45:	c1 e9 02             	shr    $0x2,%ecx
  800a48:	fd                   	std    
  800a49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4b:	eb 09                	jmp    800a56 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4d:	83 ef 01             	sub    $0x1,%edi
  800a50:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a53:	fd                   	std    
  800a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a56:	fc                   	cld    
  800a57:	eb 1d                	jmp    800a76 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a59:	89 f2                	mov    %esi,%edx
  800a5b:	09 c2                	or     %eax,%edx
  800a5d:	f6 c2 03             	test   $0x3,%dl
  800a60:	75 0f                	jne    800a71 <memmove+0x5f>
  800a62:	f6 c1 03             	test   $0x3,%cl
  800a65:	75 0a                	jne    800a71 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	89 c7                	mov    %eax,%edi
  800a6c:	fc                   	cld    
  800a6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6f:	eb 05                	jmp    800a76 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a71:	89 c7                	mov    %eax,%edi
  800a73:	fc                   	cld    
  800a74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a7d:	ff 75 10             	pushl  0x10(%ebp)
  800a80:	ff 75 0c             	pushl  0xc(%ebp)
  800a83:	ff 75 08             	pushl  0x8(%ebp)
  800a86:	e8 87 ff ff ff       	call   800a12 <memmove>
}
  800a8b:	c9                   	leave  
  800a8c:	c3                   	ret    

00800a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a98:	89 c6                	mov    %eax,%esi
  800a9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9d:	eb 1a                	jmp    800ab9 <memcmp+0x2c>
		if (*s1 != *s2)
  800a9f:	0f b6 08             	movzbl (%eax),%ecx
  800aa2:	0f b6 1a             	movzbl (%edx),%ebx
  800aa5:	38 d9                	cmp    %bl,%cl
  800aa7:	74 0a                	je     800ab3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aa9:	0f b6 c1             	movzbl %cl,%eax
  800aac:	0f b6 db             	movzbl %bl,%ebx
  800aaf:	29 d8                	sub    %ebx,%eax
  800ab1:	eb 0f                	jmp    800ac2 <memcmp+0x35>
		s1++, s2++;
  800ab3:	83 c0 01             	add    $0x1,%eax
  800ab6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab9:	39 f0                	cmp    %esi,%eax
  800abb:	75 e2                	jne    800a9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	53                   	push   %ebx
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800acd:	89 c1                	mov    %eax,%ecx
  800acf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad6:	eb 0a                	jmp    800ae2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad8:	0f b6 10             	movzbl (%eax),%edx
  800adb:	39 da                	cmp    %ebx,%edx
  800add:	74 07                	je     800ae6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800adf:	83 c0 01             	add    $0x1,%eax
  800ae2:	39 c8                	cmp    %ecx,%eax
  800ae4:	72 f2                	jb     800ad8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af5:	eb 03                	jmp    800afa <strtol+0x11>
		s++;
  800af7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afa:	0f b6 01             	movzbl (%ecx),%eax
  800afd:	3c 20                	cmp    $0x20,%al
  800aff:	74 f6                	je     800af7 <strtol+0xe>
  800b01:	3c 09                	cmp    $0x9,%al
  800b03:	74 f2                	je     800af7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b05:	3c 2b                	cmp    $0x2b,%al
  800b07:	75 0a                	jne    800b13 <strtol+0x2a>
		s++;
  800b09:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b11:	eb 11                	jmp    800b24 <strtol+0x3b>
  800b13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b18:	3c 2d                	cmp    $0x2d,%al
  800b1a:	75 08                	jne    800b24 <strtol+0x3b>
		s++, neg = 1;
  800b1c:	83 c1 01             	add    $0x1,%ecx
  800b1f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b2a:	75 15                	jne    800b41 <strtol+0x58>
  800b2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2f:	75 10                	jne    800b41 <strtol+0x58>
  800b31:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b35:	75 7c                	jne    800bb3 <strtol+0xca>
		s += 2, base = 16;
  800b37:	83 c1 02             	add    $0x2,%ecx
  800b3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3f:	eb 16                	jmp    800b57 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	75 12                	jne    800b57 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b45:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4d:	75 08                	jne    800b57 <strtol+0x6e>
		s++, base = 8;
  800b4f:	83 c1 01             	add    $0x1,%ecx
  800b52:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5f:	0f b6 11             	movzbl (%ecx),%edx
  800b62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b65:	89 f3                	mov    %esi,%ebx
  800b67:	80 fb 09             	cmp    $0x9,%bl
  800b6a:	77 08                	ja     800b74 <strtol+0x8b>
			dig = *s - '0';
  800b6c:	0f be d2             	movsbl %dl,%edx
  800b6f:	83 ea 30             	sub    $0x30,%edx
  800b72:	eb 22                	jmp    800b96 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b77:	89 f3                	mov    %esi,%ebx
  800b79:	80 fb 19             	cmp    $0x19,%bl
  800b7c:	77 08                	ja     800b86 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b7e:	0f be d2             	movsbl %dl,%edx
  800b81:	83 ea 57             	sub    $0x57,%edx
  800b84:	eb 10                	jmp    800b96 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b89:	89 f3                	mov    %esi,%ebx
  800b8b:	80 fb 19             	cmp    $0x19,%bl
  800b8e:	77 16                	ja     800ba6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b90:	0f be d2             	movsbl %dl,%edx
  800b93:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b99:	7d 0b                	jge    800ba6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b9b:	83 c1 01             	add    $0x1,%ecx
  800b9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ba4:	eb b9                	jmp    800b5f <strtol+0x76>

	if (endptr)
  800ba6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800baa:	74 0d                	je     800bb9 <strtol+0xd0>
		*endptr = (char *) s;
  800bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800baf:	89 0e                	mov    %ecx,(%esi)
  800bb1:	eb 06                	jmp    800bb9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb3:	85 db                	test   %ebx,%ebx
  800bb5:	74 98                	je     800b4f <strtol+0x66>
  800bb7:	eb 9e                	jmp    800b57 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bb9:	89 c2                	mov    %eax,%edx
  800bbb:	f7 da                	neg    %edx
  800bbd:	85 ff                	test   %edi,%edi
  800bbf:	0f 45 c2             	cmovne %edx,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	89 c3                	mov    %eax,%ebx
  800bda:	89 c7                	mov    %eax,%edi
  800bdc:	89 c6                	mov    %eax,%esi
  800bde:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800beb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf0:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf5:	89 d1                	mov    %edx,%ecx
  800bf7:	89 d3                	mov    %edx,%ebx
  800bf9:	89 d7                	mov    %edx,%edi
  800bfb:	89 d6                	mov    %edx,%esi
  800bfd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c12:	b8 03 00 00 00       	mov    $0x3,%eax
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 cb                	mov    %ecx,%ebx
  800c1c:	89 cf                	mov    %ecx,%edi
  800c1e:	89 ce                	mov    %ecx,%esi
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 03                	push   $0x3
  800c2c:	68 1f 2d 80 00       	push   $0x802d1f
  800c31:	6a 23                	push   $0x23
  800c33:	68 3c 2d 80 00       	push   $0x802d3c
  800c38:	e8 9b f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 02 00 00 00       	mov    $0x2,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_yield>:

void
sys_yield(void)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	89 d1                	mov    %edx,%ecx
  800c76:	89 d3                	mov    %edx,%ebx
  800c78:	89 d7                	mov    %edx,%edi
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 04 00 00 00       	mov    $0x4,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	89 f7                	mov    %esi,%edi
  800ca1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 04                	push   $0x4
  800cad:	68 1f 2d 80 00       	push   $0x802d1f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 3c 2d 80 00       	push   $0x802d3c
  800cb9:	e8 1a f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccf:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 05                	push   $0x5
  800cef:	68 1f 2d 80 00       	push   $0x802d1f
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 3c 2d 80 00       	push   $0x802d3c
  800cfb:	e8 d8 f4 ff ff       	call   8001d8 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 17                	jle    800d42 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 06                	push   $0x6
  800d31:	68 1f 2d 80 00       	push   $0x802d1f
  800d36:	6a 23                	push   $0x23
  800d38:	68 3c 2d 80 00       	push   $0x802d3c
  800d3d:	e8 96 f4 ff ff       	call   8001d8 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 08                	push   $0x8
  800d73:	68 1f 2d 80 00       	push   $0x802d1f
  800d78:	6a 23                	push   $0x23
  800d7a:	68 3c 2d 80 00       	push   $0x802d3c
  800d7f:	e8 54 f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 17                	jle    800dc6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	50                   	push   %eax
  800db3:	6a 09                	push   $0x9
  800db5:	68 1f 2d 80 00       	push   $0x802d1f
  800dba:	6a 23                	push   $0x23
  800dbc:	68 3c 2d 80 00       	push   $0x802d3c
  800dc1:	e8 12 f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 df                	mov    %ebx,%edi
  800de9:	89 de                	mov    %ebx,%esi
  800deb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 17                	jle    800e08 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	50                   	push   %eax
  800df5:	6a 0a                	push   $0xa
  800df7:	68 1f 2d 80 00       	push   $0x802d1f
  800dfc:	6a 23                	push   $0x23
  800dfe:	68 3c 2d 80 00       	push   $0x802d3c
  800e03:	e8 d0 f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e16:	be 00 00 00 00       	mov    $0x0,%esi
  800e1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 cb                	mov    %ecx,%ebx
  800e4b:	89 cf                	mov    %ecx,%edi
  800e4d:	89 ce                	mov    %ecx,%esi
  800e4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 17                	jle    800e6c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	50                   	push   %eax
  800e59:	6a 0d                	push   $0xd
  800e5b:	68 1f 2d 80 00       	push   $0x802d1f
  800e60:	6a 23                	push   $0x23
  800e62:	68 3c 2d 80 00       	push   $0x802d3c
  800e67:	e8 6c f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e7c:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800e7e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e82:	74 11                	je     800e95 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800e84:	89 d8                	mov    %ebx,%eax
  800e86:	c1 e8 0c             	shr    $0xc,%eax
  800e89:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800e90:	f6 c4 08             	test   $0x8,%ah
  800e93:	75 14                	jne    800ea9 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	68 4a 2d 80 00       	push   $0x802d4a
  800e9d:	6a 21                	push   $0x21
  800e9f:	68 60 2d 80 00       	push   $0x802d60
  800ea4:	e8 2f f3 ff ff       	call   8001d8 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800ea9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800eaf:	e8 91 fd ff ff       	call   800c45 <sys_getenvid>
  800eb4:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800eb6:	83 ec 04             	sub    $0x4,%esp
  800eb9:	6a 07                	push   $0x7
  800ebb:	68 00 f0 7f 00       	push   $0x7ff000
  800ec0:	50                   	push   %eax
  800ec1:	e8 bd fd ff ff       	call   800c83 <sys_page_alloc>
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	79 14                	jns    800ee1 <pgfault+0x6d>
		panic("sys_page_alloc");
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	68 6b 2d 80 00       	push   $0x802d6b
  800ed5:	6a 30                	push   $0x30
  800ed7:	68 60 2d 80 00       	push   $0x802d60
  800edc:	e8 f7 f2 ff ff       	call   8001d8 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	68 00 10 00 00       	push   $0x1000
  800ee9:	53                   	push   %ebx
  800eea:	68 00 f0 7f 00       	push   $0x7ff000
  800eef:	e8 86 fb ff ff       	call   800a7a <memcpy>
	retv = sys_page_unmap(envid, addr);
  800ef4:	83 c4 08             	add    $0x8,%esp
  800ef7:	53                   	push   %ebx
  800ef8:	56                   	push   %esi
  800ef9:	e8 0a fe ff ff       	call   800d08 <sys_page_unmap>
	if(retv < 0){
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	79 12                	jns    800f17 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800f05:	50                   	push   %eax
  800f06:	68 44 2e 80 00       	push   $0x802e44
  800f0b:	6a 35                	push   $0x35
  800f0d:	68 60 2d 80 00       	push   $0x802d60
  800f12:	e8 c1 f2 ff ff       	call   8001d8 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	6a 07                	push   $0x7
  800f1c:	53                   	push   %ebx
  800f1d:	56                   	push   %esi
  800f1e:	68 00 f0 7f 00       	push   $0x7ff000
  800f23:	56                   	push   %esi
  800f24:	e8 9d fd ff ff       	call   800cc6 <sys_page_map>
	if(retv < 0){
  800f29:	83 c4 20             	add    $0x20,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	79 14                	jns    800f44 <pgfault+0xd0>
		panic("sys_page_map");
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	68 7a 2d 80 00       	push   $0x802d7a
  800f38:	6a 39                	push   $0x39
  800f3a:	68 60 2d 80 00       	push   $0x802d60
  800f3f:	e8 94 f2 ff ff       	call   8001d8 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	68 00 f0 7f 00       	push   $0x7ff000
  800f4c:	56                   	push   %esi
  800f4d:	e8 b6 fd ff ff       	call   800d08 <sys_page_unmap>
	if(retv < 0){
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	79 14                	jns    800f6d <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	68 87 2d 80 00       	push   $0x802d87
  800f61:	6a 3d                	push   $0x3d
  800f63:	68 60 2d 80 00       	push   $0x802d60
  800f68:	e8 6b f2 ff ff       	call   8001d8 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800f6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f7f:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800f82:	83 ec 08             	sub    $0x8,%esp
  800f85:	53                   	push   %ebx
  800f86:	68 a4 2d 80 00       	push   $0x802da4
  800f8b:	e8 21 f3 ff ff       	call   8002b1 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f90:	83 c4 0c             	add    $0xc,%esp
  800f93:	6a 07                	push   $0x7
  800f95:	53                   	push   %ebx
  800f96:	56                   	push   %esi
  800f97:	e8 e7 fc ff ff       	call   800c83 <sys_page_alloc>
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	79 15                	jns    800fb8 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800fa3:	50                   	push   %eax
  800fa4:	68 4c 29 80 00       	push   $0x80294c
  800fa9:	68 90 00 00 00       	push   $0x90
  800fae:	68 60 2d 80 00       	push   $0x802d60
  800fb3:	e8 20 f2 ff ff       	call   8001d8 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	68 b7 2d 80 00       	push   $0x802db7
  800fc0:	e8 ec f2 ff ff       	call   8002b1 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fc5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fcc:	68 00 00 40 00       	push   $0x400000
  800fd1:	6a 00                	push   $0x0
  800fd3:	53                   	push   %ebx
  800fd4:	56                   	push   %esi
  800fd5:	e8 ec fc ff ff       	call   800cc6 <sys_page_map>
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	79 15                	jns    800ff6 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  800fe1:	50                   	push   %eax
  800fe2:	68 bf 2d 80 00       	push   $0x802dbf
  800fe7:	68 94 00 00 00       	push   $0x94
  800fec:	68 60 2d 80 00       	push   $0x802d60
  800ff1:	e8 e2 f1 ff ff       	call   8001d8 <_panic>
        cprintf("af_p_m.");
  800ff6:	83 ec 0c             	sub    $0xc,%esp
  800ff9:	68 d0 2d 80 00       	push   $0x802dd0
  800ffe:	e8 ae f2 ff ff       	call   8002b1 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  801003:	83 c4 0c             	add    $0xc,%esp
  801006:	68 00 10 00 00       	push   $0x1000
  80100b:	53                   	push   %ebx
  80100c:	68 00 00 40 00       	push   $0x400000
  801011:	e8 fc f9 ff ff       	call   800a12 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  801016:	c7 04 24 d8 2d 80 00 	movl   $0x802dd8,(%esp)
  80101d:	e8 8f f2 ff ff       	call   8002b1 <cprintf>
}
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
  801032:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  801035:	68 74 0e 80 00       	push   $0x800e74
  80103a:	e8 c8 14 00 00       	call   802507 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80103f:	b8 07 00 00 00       	mov    $0x7,%eax
  801044:	cd 30                	int    $0x30
  801046:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801049:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 17                	jns    80106a <fork+0x3e>
		panic("sys_exofork failed.");
  801053:	83 ec 04             	sub    $0x4,%esp
  801056:	68 e6 2d 80 00       	push   $0x802de6
  80105b:	68 b7 00 00 00       	push   $0xb7
  801060:	68 60 2d 80 00       	push   $0x802d60
  801065:	e8 6e f1 ff ff       	call   8001d8 <_panic>
  80106a:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  80106f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801073:	75 21                	jne    801096 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801075:	e8 cb fb ff ff       	call   800c45 <sys_getenvid>
  80107a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80107f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801082:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801087:	a3 04 50 80 00       	mov    %eax,0x805004
//		cprintf("we are the child.\n");
		return 0;
  80108c:	b8 00 00 00 00       	mov    $0x0,%eax
  801091:	e9 69 01 00 00       	jmp    8011ff <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801096:	89 d8                	mov    %ebx,%eax
  801098:	c1 e8 16             	shr    $0x16,%eax
  80109b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  8010a2:	a8 01                	test   $0x1,%al
  8010a4:	0f 84 d6 00 00 00    	je     801180 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  8010aa:	89 de                	mov    %ebx,%esi
  8010ac:	c1 ee 0c             	shr    $0xc,%esi
  8010af:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8010b6:	a8 01                	test   $0x1,%al
  8010b8:	0f 84 c2 00 00 00    	je     801180 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  8010be:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  8010c5:	89 f7                	mov    %esi,%edi
  8010c7:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  8010ca:	e8 76 fb ff ff       	call   800c45 <sys_getenvid>
  8010cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  8010d2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d9:	f6 c4 04             	test   $0x4,%ah
  8010dc:	74 1c                	je     8010fa <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	68 07 0e 00 00       	push   $0xe07
  8010e6:	57                   	push   %edi
  8010e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8010ea:	57                   	push   %edi
  8010eb:	6a 00                	push   $0x0
  8010ed:	e8 d4 fb ff ff       	call   800cc6 <sys_page_map>
  8010f2:	83 c4 20             	add    $0x20,%esp
  8010f5:	e9 86 00 00 00       	jmp    801180 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  8010fa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801101:	a8 02                	test   $0x2,%al
  801103:	75 0c                	jne    801111 <fork+0xe5>
  801105:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80110c:	f6 c4 08             	test   $0x8,%ah
  80110f:	74 5b                	je     80116c <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	68 05 08 00 00       	push   $0x805
  801119:	57                   	push   %edi
  80111a:	ff 75 e0             	pushl  -0x20(%ebp)
  80111d:	57                   	push   %edi
  80111e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801121:	e8 a0 fb ff ff       	call   800cc6 <sys_page_map>
  801126:	83 c4 20             	add    $0x20,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	79 12                	jns    80113f <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  80112d:	50                   	push   %eax
  80112e:	68 68 2e 80 00       	push   $0x802e68
  801133:	6a 5f                	push   $0x5f
  801135:	68 60 2d 80 00       	push   $0x802d60
  80113a:	e8 99 f0 ff ff       	call   8001d8 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  80113f:	83 ec 0c             	sub    $0xc,%esp
  801142:	68 05 08 00 00       	push   $0x805
  801147:	57                   	push   %edi
  801148:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	57                   	push   %edi
  80114d:	50                   	push   %eax
  80114e:	e8 73 fb ff ff       	call   800cc6 <sys_page_map>
  801153:	83 c4 20             	add    $0x20,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	79 26                	jns    801180 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  80115a:	50                   	push   %eax
  80115b:	68 8c 2e 80 00       	push   $0x802e8c
  801160:	6a 64                	push   $0x64
  801162:	68 60 2d 80 00       	push   $0x802d60
  801167:	e8 6c f0 ff ff       	call   8001d8 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	6a 05                	push   $0x5
  801171:	57                   	push   %edi
  801172:	ff 75 e0             	pushl  -0x20(%ebp)
  801175:	57                   	push   %edi
  801176:	6a 00                	push   $0x0
  801178:	e8 49 fb ff ff       	call   800cc6 <sys_page_map>
  80117d:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801180:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801186:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80118c:	0f 85 04 ff ff ff    	jne    801096 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	6a 07                	push   $0x7
  801197:	68 00 f0 bf ee       	push   $0xeebff000
  80119c:	ff 75 dc             	pushl  -0x24(%ebp)
  80119f:	e8 df fa ff ff       	call   800c83 <sys_page_alloc>
	if(retv < 0){
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	79 17                	jns    8011c2 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  8011ab:	83 ec 04             	sub    $0x4,%esp
  8011ae:	68 fa 2d 80 00       	push   $0x802dfa
  8011b3:	68 cc 00 00 00       	push   $0xcc
  8011b8:	68 60 2d 80 00       	push   $0x802d60
  8011bd:	e8 16 f0 ff ff       	call   8001d8 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	68 6c 25 80 00       	push   $0x80256c
  8011ca:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8011cd:	57                   	push   %edi
  8011ce:	e8 fb fb ff ff       	call   800dce <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  8011d3:	83 c4 08             	add    $0x8,%esp
  8011d6:	6a 02                	push   $0x2
  8011d8:	57                   	push   %edi
  8011d9:	e8 6c fb ff ff       	call   800d4a <sys_env_set_status>
	if(retv < 0){
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	79 17                	jns    8011fc <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	68 12 2e 80 00       	push   $0x802e12
  8011ed:	68 dd 00 00 00       	push   $0xdd
  8011f2:	68 60 2d 80 00       	push   $0x802d60
  8011f7:	e8 dc ef ff ff       	call   8001d8 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  8011fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  8011ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <sfork>:

// Challenge!
int
sfork(void)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80120d:	68 2e 2e 80 00       	push   $0x802e2e
  801212:	68 e8 00 00 00       	push   $0xe8
  801217:	68 60 2d 80 00       	push   $0x802d60
  80121c:	e8 b7 ef ff ff       	call   8001d8 <_panic>

00801221 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801224:	8b 45 08             	mov    0x8(%ebp),%eax
  801227:	05 00 00 00 30       	add    $0x30000000,%eax
  80122c:	c1 e8 0c             	shr    $0xc,%eax
}
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
  801237:	05 00 00 00 30       	add    $0x30000000,%eax
  80123c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801241:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801253:	89 c2                	mov    %eax,%edx
  801255:	c1 ea 16             	shr    $0x16,%edx
  801258:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125f:	f6 c2 01             	test   $0x1,%dl
  801262:	74 11                	je     801275 <fd_alloc+0x2d>
  801264:	89 c2                	mov    %eax,%edx
  801266:	c1 ea 0c             	shr    $0xc,%edx
  801269:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801270:	f6 c2 01             	test   $0x1,%dl
  801273:	75 09                	jne    80127e <fd_alloc+0x36>
			*fd_store = fd;
  801275:	89 01                	mov    %eax,(%ecx)
			return 0;
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
  80127c:	eb 17                	jmp    801295 <fd_alloc+0x4d>
  80127e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801283:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801288:	75 c9                	jne    801253 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80128a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801290:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80129d:	83 f8 1f             	cmp    $0x1f,%eax
  8012a0:	77 36                	ja     8012d8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a2:	c1 e0 0c             	shl    $0xc,%eax
  8012a5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012aa:	89 c2                	mov    %eax,%edx
  8012ac:	c1 ea 16             	shr    $0x16,%edx
  8012af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b6:	f6 c2 01             	test   $0x1,%dl
  8012b9:	74 24                	je     8012df <fd_lookup+0x48>
  8012bb:	89 c2                	mov    %eax,%edx
  8012bd:	c1 ea 0c             	shr    $0xc,%edx
  8012c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c7:	f6 c2 01             	test   $0x1,%dl
  8012ca:	74 1a                	je     8012e6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cf:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d6:	eb 13                	jmp    8012eb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012dd:	eb 0c                	jmp    8012eb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e4:	eb 05                	jmp    8012eb <fd_lookup+0x54>
  8012e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f6:	ba 2c 2f 80 00       	mov    $0x802f2c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012fb:	eb 13                	jmp    801310 <dev_lookup+0x23>
  8012fd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801300:	39 08                	cmp    %ecx,(%eax)
  801302:	75 0c                	jne    801310 <dev_lookup+0x23>
			*dev = devtab[i];
  801304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801307:	89 01                	mov    %eax,(%ecx)
			return 0;
  801309:	b8 00 00 00 00       	mov    $0x0,%eax
  80130e:	eb 2e                	jmp    80133e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801310:	8b 02                	mov    (%edx),%eax
  801312:	85 c0                	test   %eax,%eax
  801314:	75 e7                	jne    8012fd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801316:	a1 04 50 80 00       	mov    0x805004,%eax
  80131b:	8b 40 48             	mov    0x48(%eax),%eax
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	51                   	push   %ecx
  801322:	50                   	push   %eax
  801323:	68 b0 2e 80 00       	push   $0x802eb0
  801328:	e8 84 ef ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  80132d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801330:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	83 ec 10             	sub    $0x10,%esp
  801348:	8b 75 08             	mov    0x8(%ebp),%esi
  80134b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801358:	c1 e8 0c             	shr    $0xc,%eax
  80135b:	50                   	push   %eax
  80135c:	e8 36 ff ff ff       	call   801297 <fd_lookup>
  801361:	83 c4 08             	add    $0x8,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 05                	js     80136d <fd_close+0x2d>
	    || fd != fd2)
  801368:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136b:	74 0c                	je     801379 <fd_close+0x39>
		return (must_exist ? r : 0);
  80136d:	84 db                	test   %bl,%bl
  80136f:	ba 00 00 00 00       	mov    $0x0,%edx
  801374:	0f 44 c2             	cmove  %edx,%eax
  801377:	eb 41                	jmp    8013ba <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 36                	pushl  (%esi)
  801382:	e8 66 ff ff ff       	call   8012ed <dev_lookup>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 1a                	js     8013aa <fd_close+0x6a>
		if (dev->dev_close)
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801396:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80139b:	85 c0                	test   %eax,%eax
  80139d:	74 0b                	je     8013aa <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	56                   	push   %esi
  8013a3:	ff d0                	call   *%eax
  8013a5:	89 c3                	mov    %eax,%ebx
  8013a7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	56                   	push   %esi
  8013ae:	6a 00                	push   $0x0
  8013b0:	e8 53 f9 ff ff       	call   800d08 <sys_page_unmap>
	return r;
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	89 d8                	mov    %ebx,%eax
}
  8013ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    

008013c1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ca:	50                   	push   %eax
  8013cb:	ff 75 08             	pushl  0x8(%ebp)
  8013ce:	e8 c4 fe ff ff       	call   801297 <fd_lookup>
  8013d3:	83 c4 08             	add    $0x8,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 10                	js     8013ea <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	6a 01                	push   $0x1
  8013df:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e2:	e8 59 ff ff ff       	call   801340 <fd_close>
  8013e7:	83 c4 10             	add    $0x10,%esp
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <close_all>:

void
close_all(void)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	e8 c0 ff ff ff       	call   8013c1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801401:	83 c3 01             	add    $0x1,%ebx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	83 fb 20             	cmp    $0x20,%ebx
  80140a:	75 ec                	jne    8013f8 <close_all+0xc>
		close(i);
}
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	57                   	push   %edi
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 2c             	sub    $0x2c,%esp
  80141a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	ff 75 08             	pushl  0x8(%ebp)
  801424:	e8 6e fe ff ff       	call   801297 <fd_lookup>
  801429:	83 c4 08             	add    $0x8,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	0f 88 c1 00 00 00    	js     8014f5 <dup+0xe4>
		return r;
	close(newfdnum);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	56                   	push   %esi
  801438:	e8 84 ff ff ff       	call   8013c1 <close>

	newfd = INDEX2FD(newfdnum);
  80143d:	89 f3                	mov    %esi,%ebx
  80143f:	c1 e3 0c             	shl    $0xc,%ebx
  801442:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801448:	83 c4 04             	add    $0x4,%esp
  80144b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144e:	e8 de fd ff ff       	call   801231 <fd2data>
  801453:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801455:	89 1c 24             	mov    %ebx,(%esp)
  801458:	e8 d4 fd ff ff       	call   801231 <fd2data>
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801463:	89 f8                	mov    %edi,%eax
  801465:	c1 e8 16             	shr    $0x16,%eax
  801468:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146f:	a8 01                	test   $0x1,%al
  801471:	74 37                	je     8014aa <dup+0x99>
  801473:	89 f8                	mov    %edi,%eax
  801475:	c1 e8 0c             	shr    $0xc,%eax
  801478:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147f:	f6 c2 01             	test   $0x1,%dl
  801482:	74 26                	je     8014aa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801484:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	25 07 0e 00 00       	and    $0xe07,%eax
  801493:	50                   	push   %eax
  801494:	ff 75 d4             	pushl  -0x2c(%ebp)
  801497:	6a 00                	push   $0x0
  801499:	57                   	push   %edi
  80149a:	6a 00                	push   $0x0
  80149c:	e8 25 f8 ff ff       	call   800cc6 <sys_page_map>
  8014a1:	89 c7                	mov    %eax,%edi
  8014a3:	83 c4 20             	add    $0x20,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 2e                	js     8014d8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ad:	89 d0                	mov    %edx,%eax
  8014af:	c1 e8 0c             	shr    $0xc,%eax
  8014b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c1:	50                   	push   %eax
  8014c2:	53                   	push   %ebx
  8014c3:	6a 00                	push   $0x0
  8014c5:	52                   	push   %edx
  8014c6:	6a 00                	push   $0x0
  8014c8:	e8 f9 f7 ff ff       	call   800cc6 <sys_page_map>
  8014cd:	89 c7                	mov    %eax,%edi
  8014cf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014d2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d4:	85 ff                	test   %edi,%edi
  8014d6:	79 1d                	jns    8014f5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	53                   	push   %ebx
  8014dc:	6a 00                	push   $0x0
  8014de:	e8 25 f8 ff ff       	call   800d08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e9:	6a 00                	push   $0x0
  8014eb:	e8 18 f8 ff ff       	call   800d08 <sys_page_unmap>
	return r;
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	89 f8                	mov    %edi,%eax
}
  8014f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 14             	sub    $0x14,%esp
  801504:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801507:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	53                   	push   %ebx
  80150c:	e8 86 fd ff ff       	call   801297 <fd_lookup>
  801511:	83 c4 08             	add    $0x8,%esp
  801514:	89 c2                	mov    %eax,%edx
  801516:	85 c0                	test   %eax,%eax
  801518:	78 6d                	js     801587 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801524:	ff 30                	pushl  (%eax)
  801526:	e8 c2 fd ff ff       	call   8012ed <dev_lookup>
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 4c                	js     80157e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801532:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801535:	8b 42 08             	mov    0x8(%edx),%eax
  801538:	83 e0 03             	and    $0x3,%eax
  80153b:	83 f8 01             	cmp    $0x1,%eax
  80153e:	75 21                	jne    801561 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801540:	a1 04 50 80 00       	mov    0x805004,%eax
  801545:	8b 40 48             	mov    0x48(%eax),%eax
  801548:	83 ec 04             	sub    $0x4,%esp
  80154b:	53                   	push   %ebx
  80154c:	50                   	push   %eax
  80154d:	68 f1 2e 80 00       	push   $0x802ef1
  801552:	e8 5a ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80155f:	eb 26                	jmp    801587 <read+0x8a>
	}
	if (!dev->dev_read)
  801561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801564:	8b 40 08             	mov    0x8(%eax),%eax
  801567:	85 c0                	test   %eax,%eax
  801569:	74 17                	je     801582 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	ff 75 10             	pushl  0x10(%ebp)
  801571:	ff 75 0c             	pushl  0xc(%ebp)
  801574:	52                   	push   %edx
  801575:	ff d0                	call   *%eax
  801577:	89 c2                	mov    %eax,%edx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	eb 09                	jmp    801587 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157e:	89 c2                	mov    %eax,%edx
  801580:	eb 05                	jmp    801587 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801582:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801587:	89 d0                	mov    %edx,%eax
  801589:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a2:	eb 21                	jmp    8015c5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a4:	83 ec 04             	sub    $0x4,%esp
  8015a7:	89 f0                	mov    %esi,%eax
  8015a9:	29 d8                	sub    %ebx,%eax
  8015ab:	50                   	push   %eax
  8015ac:	89 d8                	mov    %ebx,%eax
  8015ae:	03 45 0c             	add    0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	57                   	push   %edi
  8015b3:	e8 45 ff ff ff       	call   8014fd <read>
		if (m < 0)
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 10                	js     8015cf <readn+0x41>
			return m;
		if (m == 0)
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	74 0a                	je     8015cd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c3:	01 c3                	add    %eax,%ebx
  8015c5:	39 f3                	cmp    %esi,%ebx
  8015c7:	72 db                	jb     8015a4 <readn+0x16>
  8015c9:	89 d8                	mov    %ebx,%eax
  8015cb:	eb 02                	jmp    8015cf <readn+0x41>
  8015cd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d2:	5b                   	pop    %ebx
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	53                   	push   %ebx
  8015db:	83 ec 14             	sub    $0x14,%esp
  8015de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	53                   	push   %ebx
  8015e6:	e8 ac fc ff ff       	call   801297 <fd_lookup>
  8015eb:	83 c4 08             	add    $0x8,%esp
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 68                	js     80165c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fe:	ff 30                	pushl  (%eax)
  801600:	e8 e8 fc ff ff       	call   8012ed <dev_lookup>
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 47                	js     801653 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801613:	75 21                	jne    801636 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801615:	a1 04 50 80 00       	mov    0x805004,%eax
  80161a:	8b 40 48             	mov    0x48(%eax),%eax
  80161d:	83 ec 04             	sub    $0x4,%esp
  801620:	53                   	push   %ebx
  801621:	50                   	push   %eax
  801622:	68 0d 2f 80 00       	push   $0x802f0d
  801627:	e8 85 ec ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801634:	eb 26                	jmp    80165c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801636:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801639:	8b 52 0c             	mov    0xc(%edx),%edx
  80163c:	85 d2                	test   %edx,%edx
  80163e:	74 17                	je     801657 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	ff 75 10             	pushl  0x10(%ebp)
  801646:	ff 75 0c             	pushl  0xc(%ebp)
  801649:	50                   	push   %eax
  80164a:	ff d2                	call   *%edx
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	eb 09                	jmp    80165c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801653:	89 c2                	mov    %eax,%edx
  801655:	eb 05                	jmp    80165c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801657:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80165c:	89 d0                	mov    %edx,%eax
  80165e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <seek>:

int
seek(int fdnum, off_t offset)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801669:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	ff 75 08             	pushl  0x8(%ebp)
  801670:	e8 22 fc ff ff       	call   801297 <fd_lookup>
  801675:	83 c4 08             	add    $0x8,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 0e                	js     80168a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80167c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80167f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801682:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	53                   	push   %ebx
  801690:	83 ec 14             	sub    $0x14,%esp
  801693:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801696:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	53                   	push   %ebx
  80169b:	e8 f7 fb ff ff       	call   801297 <fd_lookup>
  8016a0:	83 c4 08             	add    $0x8,%esp
  8016a3:	89 c2                	mov    %eax,%edx
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 65                	js     80170e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b3:	ff 30                	pushl  (%eax)
  8016b5:	e8 33 fc ff ff       	call   8012ed <dev_lookup>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 44                	js     801705 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c8:	75 21                	jne    8016eb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ca:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016cf:	8b 40 48             	mov    0x48(%eax),%eax
  8016d2:	83 ec 04             	sub    $0x4,%esp
  8016d5:	53                   	push   %ebx
  8016d6:	50                   	push   %eax
  8016d7:	68 d0 2e 80 00       	push   $0x802ed0
  8016dc:	e8 d0 eb ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e9:	eb 23                	jmp    80170e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ee:	8b 52 18             	mov    0x18(%edx),%edx
  8016f1:	85 d2                	test   %edx,%edx
  8016f3:	74 14                	je     801709 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	ff d2                	call   *%edx
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	eb 09                	jmp    80170e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	89 c2                	mov    %eax,%edx
  801707:	eb 05                	jmp    80170e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801709:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80170e:	89 d0                	mov    %edx,%eax
  801710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	83 ec 14             	sub    $0x14,%esp
  80171c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	ff 75 08             	pushl  0x8(%ebp)
  801726:	e8 6c fb ff ff       	call   801297 <fd_lookup>
  80172b:	83 c4 08             	add    $0x8,%esp
  80172e:	89 c2                	mov    %eax,%edx
  801730:	85 c0                	test   %eax,%eax
  801732:	78 58                	js     80178c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801734:	83 ec 08             	sub    $0x8,%esp
  801737:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173e:	ff 30                	pushl  (%eax)
  801740:	e8 a8 fb ff ff       	call   8012ed <dev_lookup>
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 37                	js     801783 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801753:	74 32                	je     801787 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801755:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801758:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80175f:	00 00 00 
	stat->st_isdir = 0;
  801762:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801769:	00 00 00 
	stat->st_dev = dev;
  80176c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801772:	83 ec 08             	sub    $0x8,%esp
  801775:	53                   	push   %ebx
  801776:	ff 75 f0             	pushl  -0x10(%ebp)
  801779:	ff 50 14             	call   *0x14(%eax)
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	eb 09                	jmp    80178c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801783:	89 c2                	mov    %eax,%edx
  801785:	eb 05                	jmp    80178c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801787:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80178c:	89 d0                	mov    %edx,%eax
  80178e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	56                   	push   %esi
  801797:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	6a 00                	push   $0x0
  80179d:	ff 75 08             	pushl  0x8(%ebp)
  8017a0:	e8 dc 01 00 00       	call   801981 <open>
  8017a5:	89 c3                	mov    %eax,%ebx
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 1b                	js     8017c9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	50                   	push   %eax
  8017b5:	e8 5b ff ff ff       	call   801715 <fstat>
  8017ba:	89 c6                	mov    %eax,%esi
	close(fd);
  8017bc:	89 1c 24             	mov    %ebx,(%esp)
  8017bf:	e8 fd fb ff ff       	call   8013c1 <close>
	return r;
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	89 f0                	mov    %esi,%eax
}
  8017c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cc:	5b                   	pop    %ebx
  8017cd:	5e                   	pop    %esi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	89 c6                	mov    %eax,%esi
  8017d7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8017e0:	75 12                	jne    8017f4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	6a 01                	push   $0x1
  8017e7:	e8 44 0e 00 00       	call   802630 <ipc_find_env>
  8017ec:	a3 00 50 80 00       	mov    %eax,0x805000
  8017f1:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f4:	6a 07                	push   $0x7
  8017f6:	68 00 60 80 00       	push   $0x806000
  8017fb:	56                   	push   %esi
  8017fc:	ff 35 00 50 80 00    	pushl  0x805000
  801802:	e8 e6 0d 00 00       	call   8025ed <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801807:	83 c4 0c             	add    $0xc,%esp
  80180a:	6a 00                	push   $0x0
  80180c:	53                   	push   %ebx
  80180d:	6a 00                	push   $0x0
  80180f:	e8 7c 0d 00 00       	call   802590 <ipc_recv>
}
  801814:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	8b 40 0c             	mov    0xc(%eax),%eax
  801827:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80182c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182f:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801834:	ba 00 00 00 00       	mov    $0x0,%edx
  801839:	b8 02 00 00 00       	mov    $0x2,%eax
  80183e:	e8 8d ff ff ff       	call   8017d0 <fsipc>
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	8b 40 0c             	mov    0xc(%eax),%eax
  801851:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801856:	ba 00 00 00 00       	mov    $0x0,%edx
  80185b:	b8 06 00 00 00       	mov    $0x6,%eax
  801860:	e8 6b ff ff ff       	call   8017d0 <fsipc>
}
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	8b 40 0c             	mov    0xc(%eax),%eax
  801877:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 05 00 00 00       	mov    $0x5,%eax
  801886:	e8 45 ff ff ff       	call   8017d0 <fsipc>
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 2c                	js     8018bb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	68 00 60 80 00       	push   $0x806000
  801897:	53                   	push   %ebx
  801898:	e8 e3 ef ff ff       	call   800880 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189d:	a1 80 60 80 00       	mov    0x806080,%eax
  8018a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a8:	a1 84 60 80 00       	mov    0x806084,%eax
  8018ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 0c             	sub    $0xc,%esp
  8018c6:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8018cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8018cf:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  8018d5:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018da:	50                   	push   %eax
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	68 08 60 80 00       	push   $0x806008
  8018e3:	e8 2a f1 ff ff       	call   800a12 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ed:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f2:	e8 d9 fe ff ff       	call   8017d0 <fsipc>
	//panic("devfile_write not implemented");
}
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	56                   	push   %esi
  8018fd:	53                   	push   %ebx
  8018fe:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 40 0c             	mov    0xc(%eax),%eax
  801907:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80190c:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801912:	ba 00 00 00 00       	mov    $0x0,%edx
  801917:	b8 03 00 00 00       	mov    $0x3,%eax
  80191c:	e8 af fe ff ff       	call   8017d0 <fsipc>
  801921:	89 c3                	mov    %eax,%ebx
  801923:	85 c0                	test   %eax,%eax
  801925:	78 51                	js     801978 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801927:	39 c6                	cmp    %eax,%esi
  801929:	73 19                	jae    801944 <devfile_read+0x4b>
  80192b:	68 3c 2f 80 00       	push   $0x802f3c
  801930:	68 43 2f 80 00       	push   $0x802f43
  801935:	68 80 00 00 00       	push   $0x80
  80193a:	68 58 2f 80 00       	push   $0x802f58
  80193f:	e8 94 e8 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801944:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801949:	7e 19                	jle    801964 <devfile_read+0x6b>
  80194b:	68 63 2f 80 00       	push   $0x802f63
  801950:	68 43 2f 80 00       	push   $0x802f43
  801955:	68 81 00 00 00       	push   $0x81
  80195a:	68 58 2f 80 00       	push   $0x802f58
  80195f:	e8 74 e8 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	50                   	push   %eax
  801968:	68 00 60 80 00       	push   $0x806000
  80196d:	ff 75 0c             	pushl  0xc(%ebp)
  801970:	e8 9d f0 ff ff       	call   800a12 <memmove>
	return r;
  801975:	83 c4 10             	add    $0x10,%esp
}
  801978:	89 d8                	mov    %ebx,%eax
  80197a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	53                   	push   %ebx
  801985:	83 ec 20             	sub    $0x20,%esp
  801988:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80198b:	53                   	push   %ebx
  80198c:	e8 b6 ee ff ff       	call   800847 <strlen>
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801999:	7f 67                	jg     801a02 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80199b:	83 ec 0c             	sub    $0xc,%esp
  80199e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a1:	50                   	push   %eax
  8019a2:	e8 a1 f8 ff ff       	call   801248 <fd_alloc>
  8019a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019aa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 57                	js     801a07 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019b0:	83 ec 08             	sub    $0x8,%esp
  8019b3:	53                   	push   %ebx
  8019b4:	68 00 60 80 00       	push   $0x806000
  8019b9:	e8 c2 ee ff ff       	call   800880 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c1:	a3 00 64 80 00       	mov    %eax,0x806400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ce:	e8 fd fd ff ff       	call   8017d0 <fsipc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	79 14                	jns    8019f0 <open+0x6f>
		
		fd_close(fd, 0);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	6a 00                	push   $0x0
  8019e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e4:	e8 57 f9 ff ff       	call   801340 <fd_close>
		return r;
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	89 da                	mov    %ebx,%edx
  8019ee:	eb 17                	jmp    801a07 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f6:	e8 26 f8 ff ff       	call   801221 <fd2num>
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	eb 05                	jmp    801a07 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a02:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801a07:	89 d0                	mov    %edx,%eax
  801a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a14:	ba 00 00 00 00       	mov    $0x0,%edx
  801a19:	b8 08 00 00 00       	mov    $0x8,%eax
  801a1e:	e8 ad fd ff ff       	call   8017d0 <fsipc>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	57                   	push   %edi
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a31:	6a 00                	push   $0x0
  801a33:	ff 75 08             	pushl  0x8(%ebp)
  801a36:	e8 46 ff ff ff       	call   801981 <open>
  801a3b:	89 c7                	mov    %eax,%edi
  801a3d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	0f 88 ae 04 00 00    	js     801efc <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	68 00 02 00 00       	push   $0x200
  801a56:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a5c:	50                   	push   %eax
  801a5d:	57                   	push   %edi
  801a5e:	e8 2b fb ff ff       	call   80158e <readn>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a6b:	75 0c                	jne    801a79 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801a6d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a74:	45 4c 46 
  801a77:	74 33                	je     801aac <spawn+0x87>
		close(fd);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a82:	e8 3a f9 ff ff       	call   8013c1 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a87:	83 c4 0c             	add    $0xc,%esp
  801a8a:	68 7f 45 4c 46       	push   $0x464c457f
  801a8f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a95:	68 6f 2f 80 00       	push   $0x802f6f
  801a9a:	e8 12 e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801aa7:	e9 b0 04 00 00       	jmp    801f5c <spawn+0x537>
  801aac:	b8 07 00 00 00       	mov    $0x7,%eax
  801ab1:	cd 30                	int    $0x30
  801ab3:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801ab9:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	0f 88 3d 04 00 00    	js     801f04 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ac7:	89 c6                	mov    %eax,%esi
  801ac9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801acf:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801ad2:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801ad8:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ade:	b9 11 00 00 00       	mov    $0x11,%ecx
  801ae3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801ae5:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801aeb:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801af1:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801af6:	be 00 00 00 00       	mov    $0x0,%esi
  801afb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801afe:	eb 13                	jmp    801b13 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	50                   	push   %eax
  801b04:	e8 3e ed ff ff       	call   800847 <strlen>
  801b09:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b0d:	83 c3 01             	add    $0x1,%ebx
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801b1a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	75 df                	jne    801b00 <spawn+0xdb>
  801b21:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801b27:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b2d:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b32:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b34:	89 fa                	mov    %edi,%edx
  801b36:	83 e2 fc             	and    $0xfffffffc,%edx
  801b39:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801b40:	29 c2                	sub    %eax,%edx
  801b42:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b48:	8d 42 f8             	lea    -0x8(%edx),%eax
  801b4b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b50:	0f 86 be 03 00 00    	jbe    801f14 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b56:	83 ec 04             	sub    $0x4,%esp
  801b59:	6a 07                	push   $0x7
  801b5b:	68 00 00 40 00       	push   $0x400000
  801b60:	6a 00                	push   $0x0
  801b62:	e8 1c f1 ff ff       	call   800c83 <sys_page_alloc>
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	0f 88 a9 03 00 00    	js     801f1b <spawn+0x4f6>
  801b72:	be 00 00 00 00       	mov    $0x0,%esi
  801b77:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b80:	eb 30                	jmp    801bb2 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b82:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b88:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b8e:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801b91:	83 ec 08             	sub    $0x8,%esp
  801b94:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b97:	57                   	push   %edi
  801b98:	e8 e3 ec ff ff       	call   800880 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b9d:	83 c4 04             	add    $0x4,%esp
  801ba0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ba3:	e8 9f ec ff ff       	call   800847 <strlen>
  801ba8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801bac:	83 c6 01             	add    $0x1,%esi
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801bb8:	7f c8                	jg     801b82 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801bba:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801bc0:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801bc6:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801bcd:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801bd3:	74 19                	je     801bee <spawn+0x1c9>
  801bd5:	68 e4 2f 80 00       	push   $0x802fe4
  801bda:	68 43 2f 80 00       	push   $0x802f43
  801bdf:	68 f2 00 00 00       	push   $0xf2
  801be4:	68 89 2f 80 00       	push   $0x802f89
  801be9:	e8 ea e5 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801bee:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801bf4:	89 f8                	mov    %edi,%eax
  801bf6:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801bfb:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801bfe:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801c04:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c07:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801c0d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c13:	83 ec 0c             	sub    $0xc,%esp
  801c16:	6a 07                	push   $0x7
  801c18:	68 00 d0 bf ee       	push   $0xeebfd000
  801c1d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c23:	68 00 00 40 00       	push   $0x400000
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 97 f0 ff ff       	call   800cc6 <sys_page_map>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	83 c4 20             	add    $0x20,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	0f 88 0e 03 00 00    	js     801f4a <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	68 00 00 40 00       	push   $0x400000
  801c44:	6a 00                	push   $0x0
  801c46:	e8 bd f0 ff ff       	call   800d08 <sys_page_unmap>
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	0f 88 f2 02 00 00    	js     801f4a <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c58:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801c5e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801c65:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c6b:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801c72:	00 00 00 
  801c75:	e9 88 01 00 00       	jmp    801e02 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801c7a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c80:	83 38 01             	cmpl   $0x1,(%eax)
  801c83:	0f 85 6b 01 00 00    	jne    801df4 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c89:	89 c7                	mov    %eax,%edi
  801c8b:	8b 40 18             	mov    0x18(%eax),%eax
  801c8e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c94:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c97:	83 f8 01             	cmp    $0x1,%eax
  801c9a:	19 c0                	sbb    %eax,%eax
  801c9c:	83 e0 fe             	and    $0xfffffffe,%eax
  801c9f:	83 c0 07             	add    $0x7,%eax
  801ca2:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801ca8:	89 f8                	mov    %edi,%eax
  801caa:	8b 7f 04             	mov    0x4(%edi),%edi
  801cad:	89 f9                	mov    %edi,%ecx
  801caf:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801cb5:	8b 78 10             	mov    0x10(%eax),%edi
  801cb8:	8b 50 14             	mov    0x14(%eax),%edx
  801cbb:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801cc1:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801cc4:	89 f0                	mov    %esi,%eax
  801cc6:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ccb:	74 14                	je     801ce1 <spawn+0x2bc>
		va -= i;
  801ccd:	29 c6                	sub    %eax,%esi
		memsz += i;
  801ccf:	01 c2                	add    %eax,%edx
  801cd1:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801cd7:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801cd9:	29 c1                	sub    %eax,%ecx
  801cdb:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce6:	e9 f7 00 00 00       	jmp    801de2 <spawn+0x3bd>
		if (i >= filesz) {
  801ceb:	39 df                	cmp    %ebx,%edi
  801ced:	77 27                	ja     801d16 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801cef:	83 ec 04             	sub    $0x4,%esp
  801cf2:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cf8:	56                   	push   %esi
  801cf9:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cff:	e8 7f ef ff ff       	call   800c83 <sys_page_alloc>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	0f 89 c7 00 00 00    	jns    801dd6 <spawn+0x3b1>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	e9 13 02 00 00       	jmp    801f29 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	6a 07                	push   $0x7
  801d1b:	68 00 00 40 00       	push   $0x400000
  801d20:	6a 00                	push   $0x0
  801d22:	e8 5c ef ff ff       	call   800c83 <sys_page_alloc>
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	0f 88 ed 01 00 00    	js     801f1f <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d32:	83 ec 08             	sub    $0x8,%esp
  801d35:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d3b:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801d41:	50                   	push   %eax
  801d42:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d48:	e8 16 f9 ff ff       	call   801663 <seek>
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	85 c0                	test   %eax,%eax
  801d52:	0f 88 cb 01 00 00    	js     801f23 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d58:	83 ec 04             	sub    $0x4,%esp
  801d5b:	89 f8                	mov    %edi,%eax
  801d5d:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801d63:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d68:	ba 00 10 00 00       	mov    $0x1000,%edx
  801d6d:	0f 47 c2             	cmova  %edx,%eax
  801d70:	50                   	push   %eax
  801d71:	68 00 00 40 00       	push   $0x400000
  801d76:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d7c:	e8 0d f8 ff ff       	call   80158e <readn>
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	85 c0                	test   %eax,%eax
  801d86:	0f 88 9b 01 00 00    	js     801f27 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d8c:	83 ec 0c             	sub    $0xc,%esp
  801d8f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d95:	56                   	push   %esi
  801d96:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d9c:	68 00 00 40 00       	push   $0x400000
  801da1:	6a 00                	push   $0x0
  801da3:	e8 1e ef ff ff       	call   800cc6 <sys_page_map>
  801da8:	83 c4 20             	add    $0x20,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	79 15                	jns    801dc4 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801daf:	50                   	push   %eax
  801db0:	68 95 2f 80 00       	push   $0x802f95
  801db5:	68 25 01 00 00       	push   $0x125
  801dba:	68 89 2f 80 00       	push   $0x802f89
  801dbf:	e8 14 e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	68 00 00 40 00       	push   $0x400000
  801dcc:	6a 00                	push   $0x0
  801dce:	e8 35 ef ff ff       	call   800d08 <sys_page_unmap>
  801dd3:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801dd6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ddc:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801de2:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801de8:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801dee:	0f 87 f7 fe ff ff    	ja     801ceb <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801df4:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801dfb:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801e02:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e09:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801e0f:	0f 8c 65 fe ff ff    	jl     801c7a <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e1e:	e8 9e f5 ff ff       	call   8013c1 <close>
  801e23:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801e26:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e2b:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801e31:	89 d8                	mov    %ebx,%eax
  801e33:	c1 e8 16             	shr    $0x16,%eax
  801e36:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e3d:	a8 01                	test   $0x1,%al
  801e3f:	74 46                	je     801e87 <spawn+0x462>
  801e41:	89 d8                	mov    %ebx,%eax
  801e43:	c1 e8 0c             	shr    $0xc,%eax
  801e46:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e4d:	f6 c2 01             	test   $0x1,%dl
  801e50:	74 35                	je     801e87 <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801e52:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801e59:	f6 c2 04             	test   $0x4,%dl
  801e5c:	74 29                	je     801e87 <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801e5e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e65:	f6 c6 04             	test   $0x4,%dh
  801e68:	74 1d                	je     801e87 <spawn+0x462>
            sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801e6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	25 07 0e 00 00       	and    $0xe07,%eax
  801e79:	50                   	push   %eax
  801e7a:	53                   	push   %ebx
  801e7b:	56                   	push   %esi
  801e7c:	53                   	push   %ebx
  801e7d:	6a 00                	push   $0x0
  801e7f:	e8 42 ee ff ff       	call   800cc6 <sys_page_map>
  801e84:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801e87:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e8d:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801e93:	75 9c                	jne    801e31 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e95:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e9c:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e9f:	83 ec 08             	sub    $0x8,%esp
  801ea2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ea8:	50                   	push   %eax
  801ea9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801eaf:	e8 d8 ee ff ff       	call   800d8c <sys_env_set_trapframe>
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	79 15                	jns    801ed0 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801ebb:	50                   	push   %eax
  801ebc:	68 b2 2f 80 00       	push   $0x802fb2
  801ec1:	68 86 00 00 00       	push   $0x86
  801ec6:	68 89 2f 80 00       	push   $0x802f89
  801ecb:	e8 08 e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ed0:	83 ec 08             	sub    $0x8,%esp
  801ed3:	6a 02                	push   $0x2
  801ed5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801edb:	e8 6a ee ff ff       	call   800d4a <sys_env_set_status>
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	79 25                	jns    801f0c <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801ee7:	50                   	push   %eax
  801ee8:	68 cc 2f 80 00       	push   $0x802fcc
  801eed:	68 89 00 00 00       	push   $0x89
  801ef2:	68 89 2f 80 00       	push   $0x802f89
  801ef7:	e8 dc e2 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801efc:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801f02:	eb 58                	jmp    801f5c <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801f04:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801f0a:	eb 50                	jmp    801f5c <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801f0c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801f12:	eb 48                	jmp    801f5c <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801f14:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801f19:	eb 41                	jmp    801f5c <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801f1b:	89 c3                	mov    %eax,%ebx
  801f1d:	eb 3d                	jmp    801f5c <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f1f:	89 c3                	mov    %eax,%ebx
  801f21:	eb 06                	jmp    801f29 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f23:	89 c3                	mov    %eax,%ebx
  801f25:	eb 02                	jmp    801f29 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f27:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f32:	e8 cd ec ff ff       	call   800c04 <sys_env_destroy>
	close(fd);
  801f37:	83 c4 04             	add    $0x4,%esp
  801f3a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801f40:	e8 7c f4 ff ff       	call   8013c1 <close>
	return r;
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	eb 12                	jmp    801f5c <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801f4a:	83 ec 08             	sub    $0x8,%esp
  801f4d:	68 00 00 40 00       	push   $0x400000
  801f52:	6a 00                	push   $0x0
  801f54:	e8 af ed ff ff       	call   800d08 <sys_page_unmap>
  801f59:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5f                   	pop    %edi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    

00801f66 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	56                   	push   %esi
  801f6a:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f6b:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f73:	eb 03                	jmp    801f78 <spawnl+0x12>
		argc++;
  801f75:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f78:	83 c2 04             	add    $0x4,%edx
  801f7b:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f7f:	75 f4                	jne    801f75 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f81:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f88:	83 e2 f0             	and    $0xfffffff0,%edx
  801f8b:	29 d4                	sub    %edx,%esp
  801f8d:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f91:	c1 ea 02             	shr    $0x2,%edx
  801f94:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f9b:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa0:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801fa7:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801fae:	00 
  801faf:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801fb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb6:	eb 0a                	jmp    801fc2 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801fb8:	83 c0 01             	add    $0x1,%eax
  801fbb:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801fbf:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801fc2:	39 d0                	cmp    %edx,%eax
  801fc4:	75 f2                	jne    801fb8 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801fc6:	83 ec 08             	sub    $0x8,%esp
  801fc9:	56                   	push   %esi
  801fca:	ff 75 08             	pushl  0x8(%ebp)
  801fcd:	e8 53 fa ff ff       	call   801a25 <spawn>
}
  801fd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	56                   	push   %esi
  801fdd:	53                   	push   %ebx
  801fde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fe1:	83 ec 0c             	sub    $0xc,%esp
  801fe4:	ff 75 08             	pushl  0x8(%ebp)
  801fe7:	e8 45 f2 ff ff       	call   801231 <fd2data>
  801fec:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fee:	83 c4 08             	add    $0x8,%esp
  801ff1:	68 0a 30 80 00       	push   $0x80300a
  801ff6:	53                   	push   %ebx
  801ff7:	e8 84 e8 ff ff       	call   800880 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ffc:	8b 46 04             	mov    0x4(%esi),%eax
  801fff:	2b 06                	sub    (%esi),%eax
  802001:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802007:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80200e:	00 00 00 
	stat->st_dev = &devpipe;
  802011:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  802018:	40 80 00 
	return 0;
}
  80201b:	b8 00 00 00 00       	mov    $0x0,%eax
  802020:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    

00802027 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	53                   	push   %ebx
  80202b:	83 ec 0c             	sub    $0xc,%esp
  80202e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802031:	53                   	push   %ebx
  802032:	6a 00                	push   $0x0
  802034:	e8 cf ec ff ff       	call   800d08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802039:	89 1c 24             	mov    %ebx,(%esp)
  80203c:	e8 f0 f1 ff ff       	call   801231 <fd2data>
  802041:	83 c4 08             	add    $0x8,%esp
  802044:	50                   	push   %eax
  802045:	6a 00                	push   $0x0
  802047:	e8 bc ec ff ff       	call   800d08 <sys_page_unmap>
}
  80204c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80204f:	c9                   	leave  
  802050:	c3                   	ret    

00802051 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	57                   	push   %edi
  802055:	56                   	push   %esi
  802056:	53                   	push   %ebx
  802057:	83 ec 1c             	sub    $0x1c,%esp
  80205a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80205d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80205f:	a1 04 50 80 00       	mov    0x805004,%eax
  802064:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802067:	83 ec 0c             	sub    $0xc,%esp
  80206a:	ff 75 e0             	pushl  -0x20(%ebp)
  80206d:	e8 f7 05 00 00       	call   802669 <pageref>
  802072:	89 c3                	mov    %eax,%ebx
  802074:	89 3c 24             	mov    %edi,(%esp)
  802077:	e8 ed 05 00 00       	call   802669 <pageref>
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	39 c3                	cmp    %eax,%ebx
  802081:	0f 94 c1             	sete   %cl
  802084:	0f b6 c9             	movzbl %cl,%ecx
  802087:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80208a:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802090:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802093:	39 ce                	cmp    %ecx,%esi
  802095:	74 1b                	je     8020b2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802097:	39 c3                	cmp    %eax,%ebx
  802099:	75 c4                	jne    80205f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80209b:	8b 42 58             	mov    0x58(%edx),%eax
  80209e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020a1:	50                   	push   %eax
  8020a2:	56                   	push   %esi
  8020a3:	68 11 30 80 00       	push   $0x803011
  8020a8:	e8 04 e2 ff ff       	call   8002b1 <cprintf>
  8020ad:	83 c4 10             	add    $0x10,%esp
  8020b0:	eb ad                	jmp    80205f <_pipeisclosed+0xe>
	}
}
  8020b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5e                   	pop    %esi
  8020ba:	5f                   	pop    %edi
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    

008020bd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	57                   	push   %edi
  8020c1:	56                   	push   %esi
  8020c2:	53                   	push   %ebx
  8020c3:	83 ec 28             	sub    $0x28,%esp
  8020c6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020c9:	56                   	push   %esi
  8020ca:	e8 62 f1 ff ff       	call   801231 <fd2data>
  8020cf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8020d9:	eb 4b                	jmp    802126 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020db:	89 da                	mov    %ebx,%edx
  8020dd:	89 f0                	mov    %esi,%eax
  8020df:	e8 6d ff ff ff       	call   802051 <_pipeisclosed>
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	75 48                	jne    802130 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020e8:	e8 77 eb ff ff       	call   800c64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020ed:	8b 43 04             	mov    0x4(%ebx),%eax
  8020f0:	8b 0b                	mov    (%ebx),%ecx
  8020f2:	8d 51 20             	lea    0x20(%ecx),%edx
  8020f5:	39 d0                	cmp    %edx,%eax
  8020f7:	73 e2                	jae    8020db <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020fc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802100:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802103:	89 c2                	mov    %eax,%edx
  802105:	c1 fa 1f             	sar    $0x1f,%edx
  802108:	89 d1                	mov    %edx,%ecx
  80210a:	c1 e9 1b             	shr    $0x1b,%ecx
  80210d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802110:	83 e2 1f             	and    $0x1f,%edx
  802113:	29 ca                	sub    %ecx,%edx
  802115:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802119:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80211d:	83 c0 01             	add    $0x1,%eax
  802120:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802123:	83 c7 01             	add    $0x1,%edi
  802126:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802129:	75 c2                	jne    8020ed <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80212b:	8b 45 10             	mov    0x10(%ebp),%eax
  80212e:	eb 05                	jmp    802135 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802130:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5f                   	pop    %edi
  80213b:	5d                   	pop    %ebp
  80213c:	c3                   	ret    

0080213d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	57                   	push   %edi
  802141:	56                   	push   %esi
  802142:	53                   	push   %ebx
  802143:	83 ec 18             	sub    $0x18,%esp
  802146:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802149:	57                   	push   %edi
  80214a:	e8 e2 f0 ff ff       	call   801231 <fd2data>
  80214f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	bb 00 00 00 00       	mov    $0x0,%ebx
  802159:	eb 3d                	jmp    802198 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80215b:	85 db                	test   %ebx,%ebx
  80215d:	74 04                	je     802163 <devpipe_read+0x26>
				return i;
  80215f:	89 d8                	mov    %ebx,%eax
  802161:	eb 44                	jmp    8021a7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802163:	89 f2                	mov    %esi,%edx
  802165:	89 f8                	mov    %edi,%eax
  802167:	e8 e5 fe ff ff       	call   802051 <_pipeisclosed>
  80216c:	85 c0                	test   %eax,%eax
  80216e:	75 32                	jne    8021a2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802170:	e8 ef ea ff ff       	call   800c64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802175:	8b 06                	mov    (%esi),%eax
  802177:	3b 46 04             	cmp    0x4(%esi),%eax
  80217a:	74 df                	je     80215b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80217c:	99                   	cltd   
  80217d:	c1 ea 1b             	shr    $0x1b,%edx
  802180:	01 d0                	add    %edx,%eax
  802182:	83 e0 1f             	and    $0x1f,%eax
  802185:	29 d0                	sub    %edx,%eax
  802187:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80218c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80218f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802192:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802195:	83 c3 01             	add    $0x1,%ebx
  802198:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80219b:	75 d8                	jne    802175 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80219d:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a0:	eb 05                	jmp    8021a7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021a2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021aa:	5b                   	pop    %ebx
  8021ab:	5e                   	pop    %esi
  8021ac:	5f                   	pop    %edi
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ba:	50                   	push   %eax
  8021bb:	e8 88 f0 ff ff       	call   801248 <fd_alloc>
  8021c0:	83 c4 10             	add    $0x10,%esp
  8021c3:	89 c2                	mov    %eax,%edx
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	0f 88 2c 01 00 00    	js     8022f9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021cd:	83 ec 04             	sub    $0x4,%esp
  8021d0:	68 07 04 00 00       	push   $0x407
  8021d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d8:	6a 00                	push   $0x0
  8021da:	e8 a4 ea ff ff       	call   800c83 <sys_page_alloc>
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	89 c2                	mov    %eax,%edx
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	0f 88 0d 01 00 00    	js     8022f9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021ec:	83 ec 0c             	sub    $0xc,%esp
  8021ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021f2:	50                   	push   %eax
  8021f3:	e8 50 f0 ff ff       	call   801248 <fd_alloc>
  8021f8:	89 c3                	mov    %eax,%ebx
  8021fa:	83 c4 10             	add    $0x10,%esp
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	0f 88 e2 00 00 00    	js     8022e7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802205:	83 ec 04             	sub    $0x4,%esp
  802208:	68 07 04 00 00       	push   $0x407
  80220d:	ff 75 f0             	pushl  -0x10(%ebp)
  802210:	6a 00                	push   $0x0
  802212:	e8 6c ea ff ff       	call   800c83 <sys_page_alloc>
  802217:	89 c3                	mov    %eax,%ebx
  802219:	83 c4 10             	add    $0x10,%esp
  80221c:	85 c0                	test   %eax,%eax
  80221e:	0f 88 c3 00 00 00    	js     8022e7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802224:	83 ec 0c             	sub    $0xc,%esp
  802227:	ff 75 f4             	pushl  -0xc(%ebp)
  80222a:	e8 02 f0 ff ff       	call   801231 <fd2data>
  80222f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802231:	83 c4 0c             	add    $0xc,%esp
  802234:	68 07 04 00 00       	push   $0x407
  802239:	50                   	push   %eax
  80223a:	6a 00                	push   $0x0
  80223c:	e8 42 ea ff ff       	call   800c83 <sys_page_alloc>
  802241:	89 c3                	mov    %eax,%ebx
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	85 c0                	test   %eax,%eax
  802248:	0f 88 89 00 00 00    	js     8022d7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80224e:	83 ec 0c             	sub    $0xc,%esp
  802251:	ff 75 f0             	pushl  -0x10(%ebp)
  802254:	e8 d8 ef ff ff       	call   801231 <fd2data>
  802259:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802260:	50                   	push   %eax
  802261:	6a 00                	push   $0x0
  802263:	56                   	push   %esi
  802264:	6a 00                	push   $0x0
  802266:	e8 5b ea ff ff       	call   800cc6 <sys_page_map>
  80226b:	89 c3                	mov    %eax,%ebx
  80226d:	83 c4 20             	add    $0x20,%esp
  802270:	85 c0                	test   %eax,%eax
  802272:	78 55                	js     8022c9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802274:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80227a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80227f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802282:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802289:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80228f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802292:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802294:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802297:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80229e:	83 ec 0c             	sub    $0xc,%esp
  8022a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a4:	e8 78 ef ff ff       	call   801221 <fd2num>
  8022a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022ac:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022ae:	83 c4 04             	add    $0x4,%esp
  8022b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8022b4:	e8 68 ef ff ff       	call   801221 <fd2num>
  8022b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022bc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022bf:	83 c4 10             	add    $0x10,%esp
  8022c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c7:	eb 30                	jmp    8022f9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022c9:	83 ec 08             	sub    $0x8,%esp
  8022cc:	56                   	push   %esi
  8022cd:	6a 00                	push   $0x0
  8022cf:	e8 34 ea ff ff       	call   800d08 <sys_page_unmap>
  8022d4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8022d7:	83 ec 08             	sub    $0x8,%esp
  8022da:	ff 75 f0             	pushl  -0x10(%ebp)
  8022dd:	6a 00                	push   $0x0
  8022df:	e8 24 ea ff ff       	call   800d08 <sys_page_unmap>
  8022e4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8022e7:	83 ec 08             	sub    $0x8,%esp
  8022ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ed:	6a 00                	push   $0x0
  8022ef:	e8 14 ea ff ff       	call   800d08 <sys_page_unmap>
  8022f4:	83 c4 10             	add    $0x10,%esp
  8022f7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022f9:	89 d0                	mov    %edx,%eax
  8022fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022fe:	5b                   	pop    %ebx
  8022ff:	5e                   	pop    %esi
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    

00802302 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80230b:	50                   	push   %eax
  80230c:	ff 75 08             	pushl  0x8(%ebp)
  80230f:	e8 83 ef ff ff       	call   801297 <fd_lookup>
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	85 c0                	test   %eax,%eax
  802319:	78 18                	js     802333 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80231b:	83 ec 0c             	sub    $0xc,%esp
  80231e:	ff 75 f4             	pushl  -0xc(%ebp)
  802321:	e8 0b ef ff ff       	call   801231 <fd2data>
	return _pipeisclosed(fd, p);
  802326:	89 c2                	mov    %eax,%edx
  802328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232b:	e8 21 fd ff ff       	call   802051 <_pipeisclosed>
  802330:	83 c4 10             	add    $0x10,%esp
}
  802333:	c9                   	leave  
  802334:	c3                   	ret    

00802335 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802335:	55                   	push   %ebp
  802336:	89 e5                	mov    %esp,%ebp
  802338:	56                   	push   %esi
  802339:	53                   	push   %ebx
  80233a:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80233d:	85 f6                	test   %esi,%esi
  80233f:	75 16                	jne    802357 <wait+0x22>
  802341:	68 29 30 80 00       	push   $0x803029
  802346:	68 43 2f 80 00       	push   $0x802f43
  80234b:	6a 09                	push   $0x9
  80234d:	68 34 30 80 00       	push   $0x803034
  802352:	e8 81 de ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802357:	89 f3                	mov    %esi,%ebx
  802359:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80235f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802362:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802368:	eb 05                	jmp    80236f <wait+0x3a>
		sys_yield();
  80236a:	e8 f5 e8 ff ff       	call   800c64 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80236f:	8b 43 48             	mov    0x48(%ebx),%eax
  802372:	39 c6                	cmp    %eax,%esi
  802374:	75 07                	jne    80237d <wait+0x48>
  802376:	8b 43 54             	mov    0x54(%ebx),%eax
  802379:	85 c0                	test   %eax,%eax
  80237b:	75 ed                	jne    80236a <wait+0x35>
		sys_yield();
}
  80237d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802380:	5b                   	pop    %ebx
  802381:	5e                   	pop    %esi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    

00802384 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802384:	55                   	push   %ebp
  802385:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802387:	b8 00 00 00 00       	mov    $0x0,%eax
  80238c:	5d                   	pop    %ebp
  80238d:	c3                   	ret    

0080238e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
  802391:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802394:	68 3f 30 80 00       	push   $0x80303f
  802399:	ff 75 0c             	pushl  0xc(%ebp)
  80239c:	e8 df e4 ff ff       	call   800880 <strcpy>
	return 0;
}
  8023a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a6:	c9                   	leave  
  8023a7:	c3                   	ret    

008023a8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	57                   	push   %edi
  8023ac:	56                   	push   %esi
  8023ad:	53                   	push   %ebx
  8023ae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023b4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023b9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023bf:	eb 2d                	jmp    8023ee <devcons_write+0x46>
		m = n - tot;
  8023c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023c4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023c6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023c9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023ce:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023d1:	83 ec 04             	sub    $0x4,%esp
  8023d4:	53                   	push   %ebx
  8023d5:	03 45 0c             	add    0xc(%ebp),%eax
  8023d8:	50                   	push   %eax
  8023d9:	57                   	push   %edi
  8023da:	e8 33 e6 ff ff       	call   800a12 <memmove>
		sys_cputs(buf, m);
  8023df:	83 c4 08             	add    $0x8,%esp
  8023e2:	53                   	push   %ebx
  8023e3:	57                   	push   %edi
  8023e4:	e8 de e7 ff ff       	call   800bc7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023e9:	01 de                	add    %ebx,%esi
  8023eb:	83 c4 10             	add    $0x10,%esp
  8023ee:	89 f0                	mov    %esi,%eax
  8023f0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023f3:	72 cc                	jb     8023c1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f8:	5b                   	pop    %ebx
  8023f9:	5e                   	pop    %esi
  8023fa:	5f                   	pop    %edi
  8023fb:	5d                   	pop    %ebp
  8023fc:	c3                   	ret    

008023fd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023fd:	55                   	push   %ebp
  8023fe:	89 e5                	mov    %esp,%ebp
  802400:	83 ec 08             	sub    $0x8,%esp
  802403:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802408:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80240c:	74 2a                	je     802438 <devcons_read+0x3b>
  80240e:	eb 05                	jmp    802415 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802410:	e8 4f e8 ff ff       	call   800c64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802415:	e8 cb e7 ff ff       	call   800be5 <sys_cgetc>
  80241a:	85 c0                	test   %eax,%eax
  80241c:	74 f2                	je     802410 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80241e:	85 c0                	test   %eax,%eax
  802420:	78 16                	js     802438 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802422:	83 f8 04             	cmp    $0x4,%eax
  802425:	74 0c                	je     802433 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802427:	8b 55 0c             	mov    0xc(%ebp),%edx
  80242a:	88 02                	mov    %al,(%edx)
	return 1;
  80242c:	b8 01 00 00 00       	mov    $0x1,%eax
  802431:	eb 05                	jmp    802438 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802433:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802438:	c9                   	leave  
  802439:	c3                   	ret    

0080243a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
  80243d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802440:	8b 45 08             	mov    0x8(%ebp),%eax
  802443:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802446:	6a 01                	push   $0x1
  802448:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80244b:	50                   	push   %eax
  80244c:	e8 76 e7 ff ff       	call   800bc7 <sys_cputs>
}
  802451:	83 c4 10             	add    $0x10,%esp
  802454:	c9                   	leave  
  802455:	c3                   	ret    

00802456 <getchar>:

int
getchar(void)
{
  802456:	55                   	push   %ebp
  802457:	89 e5                	mov    %esp,%ebp
  802459:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80245c:	6a 01                	push   $0x1
  80245e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802461:	50                   	push   %eax
  802462:	6a 00                	push   $0x0
  802464:	e8 94 f0 ff ff       	call   8014fd <read>
	if (r < 0)
  802469:	83 c4 10             	add    $0x10,%esp
  80246c:	85 c0                	test   %eax,%eax
  80246e:	78 0f                	js     80247f <getchar+0x29>
		return r;
	if (r < 1)
  802470:	85 c0                	test   %eax,%eax
  802472:	7e 06                	jle    80247a <getchar+0x24>
		return -E_EOF;
	return c;
  802474:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802478:	eb 05                	jmp    80247f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80247a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80247f:	c9                   	leave  
  802480:	c3                   	ret    

00802481 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80248a:	50                   	push   %eax
  80248b:	ff 75 08             	pushl  0x8(%ebp)
  80248e:	e8 04 ee ff ff       	call   801297 <fd_lookup>
  802493:	83 c4 10             	add    $0x10,%esp
  802496:	85 c0                	test   %eax,%eax
  802498:	78 11                	js     8024ab <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80249d:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8024a3:	39 10                	cmp    %edx,(%eax)
  8024a5:	0f 94 c0             	sete   %al
  8024a8:	0f b6 c0             	movzbl %al,%eax
}
  8024ab:	c9                   	leave  
  8024ac:	c3                   	ret    

008024ad <opencons>:

int
opencons(void)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024b6:	50                   	push   %eax
  8024b7:	e8 8c ed ff ff       	call   801248 <fd_alloc>
  8024bc:	83 c4 10             	add    $0x10,%esp
		return r;
  8024bf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024c1:	85 c0                	test   %eax,%eax
  8024c3:	78 3e                	js     802503 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024c5:	83 ec 04             	sub    $0x4,%esp
  8024c8:	68 07 04 00 00       	push   $0x407
  8024cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8024d0:	6a 00                	push   $0x0
  8024d2:	e8 ac e7 ff ff       	call   800c83 <sys_page_alloc>
  8024d7:	83 c4 10             	add    $0x10,%esp
		return r;
  8024da:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	78 23                	js     802503 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024e0:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8024e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024f5:	83 ec 0c             	sub    $0xc,%esp
  8024f8:	50                   	push   %eax
  8024f9:	e8 23 ed ff ff       	call   801221 <fd2num>
  8024fe:	89 c2                	mov    %eax,%edx
  802500:	83 c4 10             	add    $0x10,%esp
}
  802503:	89 d0                	mov    %edx,%eax
  802505:	c9                   	leave  
  802506:	c3                   	ret    

00802507 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802507:	55                   	push   %ebp
  802508:	89 e5                	mov    %esp,%ebp
  80250a:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  80250d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802514:	75 4c                	jne    802562 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  802516:	a1 04 50 80 00       	mov    0x805004,%eax
  80251b:	8b 40 48             	mov    0x48(%eax),%eax
  80251e:	83 ec 04             	sub    $0x4,%esp
  802521:	6a 07                	push   $0x7
  802523:	68 00 f0 bf ee       	push   $0xeebff000
  802528:	50                   	push   %eax
  802529:	e8 55 e7 ff ff       	call   800c83 <sys_page_alloc>
		if(retv != 0){
  80252e:	83 c4 10             	add    $0x10,%esp
  802531:	85 c0                	test   %eax,%eax
  802533:	74 14                	je     802549 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  802535:	83 ec 04             	sub    $0x4,%esp
  802538:	68 4c 30 80 00       	push   $0x80304c
  80253d:	6a 27                	push   $0x27
  80253f:	68 78 30 80 00       	push   $0x803078
  802544:	e8 8f dc ff ff       	call   8001d8 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802549:	a1 04 50 80 00       	mov    0x805004,%eax
  80254e:	8b 40 48             	mov    0x48(%eax),%eax
  802551:	83 ec 08             	sub    $0x8,%esp
  802554:	68 6c 25 80 00       	push   $0x80256c
  802559:	50                   	push   %eax
  80255a:	e8 6f e8 ff ff       	call   800dce <sys_env_set_pgfault_upcall>
  80255f:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802562:	8b 45 08             	mov    0x8(%ebp),%eax
  802565:	a3 00 70 80 00       	mov    %eax,0x807000

}
  80256a:	c9                   	leave  
  80256b:	c3                   	ret    

0080256c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80256c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80256d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802572:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  802574:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  802577:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  80257b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  802580:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  802584:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  802586:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  802589:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  80258a:	83 c4 04             	add    $0x4,%esp
	popfl
  80258d:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80258e:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80258f:	c3                   	ret    

00802590 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802590:	55                   	push   %ebp
  802591:	89 e5                	mov    %esp,%ebp
  802593:	56                   	push   %esi
  802594:	53                   	push   %ebx
  802595:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802598:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  80259b:	83 ec 0c             	sub    $0xc,%esp
  80259e:	ff 75 0c             	pushl  0xc(%ebp)
  8025a1:	e8 8d e8 ff ff       	call   800e33 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  8025a6:	83 c4 10             	add    $0x10,%esp
  8025a9:	85 f6                	test   %esi,%esi
  8025ab:	74 1c                	je     8025c9 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  8025ad:	a1 04 50 80 00       	mov    0x805004,%eax
  8025b2:	8b 40 78             	mov    0x78(%eax),%eax
  8025b5:	89 06                	mov    %eax,(%esi)
  8025b7:	eb 10                	jmp    8025c9 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  8025b9:	83 ec 0c             	sub    $0xc,%esp
  8025bc:	68 86 30 80 00       	push   $0x803086
  8025c1:	e8 eb dc ff ff       	call   8002b1 <cprintf>
  8025c6:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  8025c9:	a1 04 50 80 00       	mov    0x805004,%eax
  8025ce:	8b 50 74             	mov    0x74(%eax),%edx
  8025d1:	85 d2                	test   %edx,%edx
  8025d3:	74 e4                	je     8025b9 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  8025d5:	85 db                	test   %ebx,%ebx
  8025d7:	74 05                	je     8025de <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  8025d9:	8b 40 74             	mov    0x74(%eax),%eax
  8025dc:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8025de:	a1 04 50 80 00       	mov    0x805004,%eax
  8025e3:	8b 40 70             	mov    0x70(%eax),%eax

}
  8025e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025e9:	5b                   	pop    %ebx
  8025ea:	5e                   	pop    %esi
  8025eb:	5d                   	pop    %ebp
  8025ec:	c3                   	ret    

008025ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025ed:	55                   	push   %ebp
  8025ee:	89 e5                	mov    %esp,%ebp
  8025f0:	57                   	push   %edi
  8025f1:	56                   	push   %esi
  8025f2:	53                   	push   %ebx
  8025f3:	83 ec 0c             	sub    $0xc,%esp
  8025f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  8025ff:	85 db                	test   %ebx,%ebx
  802601:	75 13                	jne    802616 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  802603:	6a 00                	push   $0x0
  802605:	68 00 00 c0 ee       	push   $0xeec00000
  80260a:	56                   	push   %esi
  80260b:	57                   	push   %edi
  80260c:	e8 ff e7 ff ff       	call   800e10 <sys_ipc_try_send>
  802611:	83 c4 10             	add    $0x10,%esp
  802614:	eb 0e                	jmp    802624 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  802616:	ff 75 14             	pushl  0x14(%ebp)
  802619:	53                   	push   %ebx
  80261a:	56                   	push   %esi
  80261b:	57                   	push   %edi
  80261c:	e8 ef e7 ff ff       	call   800e10 <sys_ipc_try_send>
  802621:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  802624:	85 c0                	test   %eax,%eax
  802626:	75 d7                	jne    8025ff <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  802628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80262b:	5b                   	pop    %ebx
  80262c:	5e                   	pop    %esi
  80262d:	5f                   	pop    %edi
  80262e:	5d                   	pop    %ebp
  80262f:	c3                   	ret    

00802630 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802630:	55                   	push   %ebp
  802631:	89 e5                	mov    %esp,%ebp
  802633:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802636:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80263b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80263e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802644:	8b 52 50             	mov    0x50(%edx),%edx
  802647:	39 ca                	cmp    %ecx,%edx
  802649:	75 0d                	jne    802658 <ipc_find_env+0x28>
			return envs[i].env_id;
  80264b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80264e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802653:	8b 40 48             	mov    0x48(%eax),%eax
  802656:	eb 0f                	jmp    802667 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802658:	83 c0 01             	add    $0x1,%eax
  80265b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802660:	75 d9                	jne    80263b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802662:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802667:	5d                   	pop    %ebp
  802668:	c3                   	ret    

00802669 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802669:	55                   	push   %ebp
  80266a:	89 e5                	mov    %esp,%ebp
  80266c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80266f:	89 d0                	mov    %edx,%eax
  802671:	c1 e8 16             	shr    $0x16,%eax
  802674:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80267b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802680:	f6 c1 01             	test   $0x1,%cl
  802683:	74 1d                	je     8026a2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802685:	c1 ea 0c             	shr    $0xc,%edx
  802688:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80268f:	f6 c2 01             	test   $0x1,%dl
  802692:	74 0e                	je     8026a2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802694:	c1 ea 0c             	shr    $0xc,%edx
  802697:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80269e:	ef 
  80269f:	0f b7 c0             	movzwl %ax,%eax
}
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    
  8026a4:	66 90                	xchg   %ax,%ax
  8026a6:	66 90                	xchg   %ax,%ax
  8026a8:	66 90                	xchg   %ax,%ax
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__udivdi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	53                   	push   %ebx
  8026b4:	83 ec 1c             	sub    $0x1c,%esp
  8026b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8026bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026c7:	85 f6                	test   %esi,%esi
  8026c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026cd:	89 ca                	mov    %ecx,%edx
  8026cf:	89 f8                	mov    %edi,%eax
  8026d1:	75 3d                	jne    802710 <__udivdi3+0x60>
  8026d3:	39 cf                	cmp    %ecx,%edi
  8026d5:	0f 87 c5 00 00 00    	ja     8027a0 <__udivdi3+0xf0>
  8026db:	85 ff                	test   %edi,%edi
  8026dd:	89 fd                	mov    %edi,%ebp
  8026df:	75 0b                	jne    8026ec <__udivdi3+0x3c>
  8026e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e6:	31 d2                	xor    %edx,%edx
  8026e8:	f7 f7                	div    %edi
  8026ea:	89 c5                	mov    %eax,%ebp
  8026ec:	89 c8                	mov    %ecx,%eax
  8026ee:	31 d2                	xor    %edx,%edx
  8026f0:	f7 f5                	div    %ebp
  8026f2:	89 c1                	mov    %eax,%ecx
  8026f4:	89 d8                	mov    %ebx,%eax
  8026f6:	89 cf                	mov    %ecx,%edi
  8026f8:	f7 f5                	div    %ebp
  8026fa:	89 c3                	mov    %eax,%ebx
  8026fc:	89 d8                	mov    %ebx,%eax
  8026fe:	89 fa                	mov    %edi,%edx
  802700:	83 c4 1c             	add    $0x1c,%esp
  802703:	5b                   	pop    %ebx
  802704:	5e                   	pop    %esi
  802705:	5f                   	pop    %edi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    
  802708:	90                   	nop
  802709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802710:	39 ce                	cmp    %ecx,%esi
  802712:	77 74                	ja     802788 <__udivdi3+0xd8>
  802714:	0f bd fe             	bsr    %esi,%edi
  802717:	83 f7 1f             	xor    $0x1f,%edi
  80271a:	0f 84 98 00 00 00    	je     8027b8 <__udivdi3+0x108>
  802720:	bb 20 00 00 00       	mov    $0x20,%ebx
  802725:	89 f9                	mov    %edi,%ecx
  802727:	89 c5                	mov    %eax,%ebp
  802729:	29 fb                	sub    %edi,%ebx
  80272b:	d3 e6                	shl    %cl,%esi
  80272d:	89 d9                	mov    %ebx,%ecx
  80272f:	d3 ed                	shr    %cl,%ebp
  802731:	89 f9                	mov    %edi,%ecx
  802733:	d3 e0                	shl    %cl,%eax
  802735:	09 ee                	or     %ebp,%esi
  802737:	89 d9                	mov    %ebx,%ecx
  802739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80273d:	89 d5                	mov    %edx,%ebp
  80273f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802743:	d3 ed                	shr    %cl,%ebp
  802745:	89 f9                	mov    %edi,%ecx
  802747:	d3 e2                	shl    %cl,%edx
  802749:	89 d9                	mov    %ebx,%ecx
  80274b:	d3 e8                	shr    %cl,%eax
  80274d:	09 c2                	or     %eax,%edx
  80274f:	89 d0                	mov    %edx,%eax
  802751:	89 ea                	mov    %ebp,%edx
  802753:	f7 f6                	div    %esi
  802755:	89 d5                	mov    %edx,%ebp
  802757:	89 c3                	mov    %eax,%ebx
  802759:	f7 64 24 0c          	mull   0xc(%esp)
  80275d:	39 d5                	cmp    %edx,%ebp
  80275f:	72 10                	jb     802771 <__udivdi3+0xc1>
  802761:	8b 74 24 08          	mov    0x8(%esp),%esi
  802765:	89 f9                	mov    %edi,%ecx
  802767:	d3 e6                	shl    %cl,%esi
  802769:	39 c6                	cmp    %eax,%esi
  80276b:	73 07                	jae    802774 <__udivdi3+0xc4>
  80276d:	39 d5                	cmp    %edx,%ebp
  80276f:	75 03                	jne    802774 <__udivdi3+0xc4>
  802771:	83 eb 01             	sub    $0x1,%ebx
  802774:	31 ff                	xor    %edi,%edi
  802776:	89 d8                	mov    %ebx,%eax
  802778:	89 fa                	mov    %edi,%edx
  80277a:	83 c4 1c             	add    $0x1c,%esp
  80277d:	5b                   	pop    %ebx
  80277e:	5e                   	pop    %esi
  80277f:	5f                   	pop    %edi
  802780:	5d                   	pop    %ebp
  802781:	c3                   	ret    
  802782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802788:	31 ff                	xor    %edi,%edi
  80278a:	31 db                	xor    %ebx,%ebx
  80278c:	89 d8                	mov    %ebx,%eax
  80278e:	89 fa                	mov    %edi,%edx
  802790:	83 c4 1c             	add    $0x1c,%esp
  802793:	5b                   	pop    %ebx
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    
  802798:	90                   	nop
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	89 d8                	mov    %ebx,%eax
  8027a2:	f7 f7                	div    %edi
  8027a4:	31 ff                	xor    %edi,%edi
  8027a6:	89 c3                	mov    %eax,%ebx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 fa                	mov    %edi,%edx
  8027ac:	83 c4 1c             	add    $0x1c,%esp
  8027af:	5b                   	pop    %ebx
  8027b0:	5e                   	pop    %esi
  8027b1:	5f                   	pop    %edi
  8027b2:	5d                   	pop    %ebp
  8027b3:	c3                   	ret    
  8027b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b8:	39 ce                	cmp    %ecx,%esi
  8027ba:	72 0c                	jb     8027c8 <__udivdi3+0x118>
  8027bc:	31 db                	xor    %ebx,%ebx
  8027be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027c2:	0f 87 34 ff ff ff    	ja     8026fc <__udivdi3+0x4c>
  8027c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027cd:	e9 2a ff ff ff       	jmp    8026fc <__udivdi3+0x4c>
  8027d2:	66 90                	xchg   %ax,%ax
  8027d4:	66 90                	xchg   %ax,%ax
  8027d6:	66 90                	xchg   %ax,%ax
  8027d8:	66 90                	xchg   %ax,%ax
  8027da:	66 90                	xchg   %ax,%ax
  8027dc:	66 90                	xchg   %ax,%ax
  8027de:	66 90                	xchg   %ax,%ax

008027e0 <__umoddi3>:
  8027e0:	55                   	push   %ebp
  8027e1:	57                   	push   %edi
  8027e2:	56                   	push   %esi
  8027e3:	53                   	push   %ebx
  8027e4:	83 ec 1c             	sub    $0x1c,%esp
  8027e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027f7:	85 d2                	test   %edx,%edx
  8027f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802801:	89 f3                	mov    %esi,%ebx
  802803:	89 3c 24             	mov    %edi,(%esp)
  802806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80280a:	75 1c                	jne    802828 <__umoddi3+0x48>
  80280c:	39 f7                	cmp    %esi,%edi
  80280e:	76 50                	jbe    802860 <__umoddi3+0x80>
  802810:	89 c8                	mov    %ecx,%eax
  802812:	89 f2                	mov    %esi,%edx
  802814:	f7 f7                	div    %edi
  802816:	89 d0                	mov    %edx,%eax
  802818:	31 d2                	xor    %edx,%edx
  80281a:	83 c4 1c             	add    $0x1c,%esp
  80281d:	5b                   	pop    %ebx
  80281e:	5e                   	pop    %esi
  80281f:	5f                   	pop    %edi
  802820:	5d                   	pop    %ebp
  802821:	c3                   	ret    
  802822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802828:	39 f2                	cmp    %esi,%edx
  80282a:	89 d0                	mov    %edx,%eax
  80282c:	77 52                	ja     802880 <__umoddi3+0xa0>
  80282e:	0f bd ea             	bsr    %edx,%ebp
  802831:	83 f5 1f             	xor    $0x1f,%ebp
  802834:	75 5a                	jne    802890 <__umoddi3+0xb0>
  802836:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80283a:	0f 82 e0 00 00 00    	jb     802920 <__umoddi3+0x140>
  802840:	39 0c 24             	cmp    %ecx,(%esp)
  802843:	0f 86 d7 00 00 00    	jbe    802920 <__umoddi3+0x140>
  802849:	8b 44 24 08          	mov    0x8(%esp),%eax
  80284d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802851:	83 c4 1c             	add    $0x1c,%esp
  802854:	5b                   	pop    %ebx
  802855:	5e                   	pop    %esi
  802856:	5f                   	pop    %edi
  802857:	5d                   	pop    %ebp
  802858:	c3                   	ret    
  802859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802860:	85 ff                	test   %edi,%edi
  802862:	89 fd                	mov    %edi,%ebp
  802864:	75 0b                	jne    802871 <__umoddi3+0x91>
  802866:	b8 01 00 00 00       	mov    $0x1,%eax
  80286b:	31 d2                	xor    %edx,%edx
  80286d:	f7 f7                	div    %edi
  80286f:	89 c5                	mov    %eax,%ebp
  802871:	89 f0                	mov    %esi,%eax
  802873:	31 d2                	xor    %edx,%edx
  802875:	f7 f5                	div    %ebp
  802877:	89 c8                	mov    %ecx,%eax
  802879:	f7 f5                	div    %ebp
  80287b:	89 d0                	mov    %edx,%eax
  80287d:	eb 99                	jmp    802818 <__umoddi3+0x38>
  80287f:	90                   	nop
  802880:	89 c8                	mov    %ecx,%eax
  802882:	89 f2                	mov    %esi,%edx
  802884:	83 c4 1c             	add    $0x1c,%esp
  802887:	5b                   	pop    %ebx
  802888:	5e                   	pop    %esi
  802889:	5f                   	pop    %edi
  80288a:	5d                   	pop    %ebp
  80288b:	c3                   	ret    
  80288c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802890:	8b 34 24             	mov    (%esp),%esi
  802893:	bf 20 00 00 00       	mov    $0x20,%edi
  802898:	89 e9                	mov    %ebp,%ecx
  80289a:	29 ef                	sub    %ebp,%edi
  80289c:	d3 e0                	shl    %cl,%eax
  80289e:	89 f9                	mov    %edi,%ecx
  8028a0:	89 f2                	mov    %esi,%edx
  8028a2:	d3 ea                	shr    %cl,%edx
  8028a4:	89 e9                	mov    %ebp,%ecx
  8028a6:	09 c2                	or     %eax,%edx
  8028a8:	89 d8                	mov    %ebx,%eax
  8028aa:	89 14 24             	mov    %edx,(%esp)
  8028ad:	89 f2                	mov    %esi,%edx
  8028af:	d3 e2                	shl    %cl,%edx
  8028b1:	89 f9                	mov    %edi,%ecx
  8028b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028bb:	d3 e8                	shr    %cl,%eax
  8028bd:	89 e9                	mov    %ebp,%ecx
  8028bf:	89 c6                	mov    %eax,%esi
  8028c1:	d3 e3                	shl    %cl,%ebx
  8028c3:	89 f9                	mov    %edi,%ecx
  8028c5:	89 d0                	mov    %edx,%eax
  8028c7:	d3 e8                	shr    %cl,%eax
  8028c9:	89 e9                	mov    %ebp,%ecx
  8028cb:	09 d8                	or     %ebx,%eax
  8028cd:	89 d3                	mov    %edx,%ebx
  8028cf:	89 f2                	mov    %esi,%edx
  8028d1:	f7 34 24             	divl   (%esp)
  8028d4:	89 d6                	mov    %edx,%esi
  8028d6:	d3 e3                	shl    %cl,%ebx
  8028d8:	f7 64 24 04          	mull   0x4(%esp)
  8028dc:	39 d6                	cmp    %edx,%esi
  8028de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028e2:	89 d1                	mov    %edx,%ecx
  8028e4:	89 c3                	mov    %eax,%ebx
  8028e6:	72 08                	jb     8028f0 <__umoddi3+0x110>
  8028e8:	75 11                	jne    8028fb <__umoddi3+0x11b>
  8028ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ee:	73 0b                	jae    8028fb <__umoddi3+0x11b>
  8028f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028f4:	1b 14 24             	sbb    (%esp),%edx
  8028f7:	89 d1                	mov    %edx,%ecx
  8028f9:	89 c3                	mov    %eax,%ebx
  8028fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028ff:	29 da                	sub    %ebx,%edx
  802901:	19 ce                	sbb    %ecx,%esi
  802903:	89 f9                	mov    %edi,%ecx
  802905:	89 f0                	mov    %esi,%eax
  802907:	d3 e0                	shl    %cl,%eax
  802909:	89 e9                	mov    %ebp,%ecx
  80290b:	d3 ea                	shr    %cl,%edx
  80290d:	89 e9                	mov    %ebp,%ecx
  80290f:	d3 ee                	shr    %cl,%esi
  802911:	09 d0                	or     %edx,%eax
  802913:	89 f2                	mov    %esi,%edx
  802915:	83 c4 1c             	add    $0x1c,%esp
  802918:	5b                   	pop    %ebx
  802919:	5e                   	pop    %esi
  80291a:	5f                   	pop    %edi
  80291b:	5d                   	pop    %ebp
  80291c:	c3                   	ret    
  80291d:	8d 76 00             	lea    0x0(%esi),%esi
  802920:	29 f9                	sub    %edi,%ecx
  802922:	19 d6                	sbb    %edx,%esi
  802924:	89 74 24 04          	mov    %esi,0x4(%esp)
  802928:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80292c:	e9 18 ff ff ff       	jmp    802849 <__umoddi3+0x69>
