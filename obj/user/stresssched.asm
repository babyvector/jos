
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 75 0b 00 00       	call   800bb2 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 26 0e 00 00       	call   800e6f <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 70 0b 00 00       	call   800bd1 <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 47 0b 00 00       	call   800bd1 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 20 80 00       	mov    0x802004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 e0 13 80 00       	push   $0x8013e0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 08 14 80 00       	push   $0x801408
  8000c4:	e8 7c 00 00 00       	call   800145 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 20 80 00       	mov    0x802008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 1b 14 80 00       	push   $0x80141b
  8000de:	e8 3b 01 00 00       	call   80021e <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 b5 0a 00 00       	call   800bb2 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800139:	6a 00                	push   $0x0
  80013b:	e8 31 0a 00 00       	call   800b71 <sys_env_destroy>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800153:	e8 5a 0a 00 00       	call   800bb2 <sys_getenvid>
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 75 0c             	pushl  0xc(%ebp)
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	56                   	push   %esi
  800162:	50                   	push   %eax
  800163:	68 44 14 80 00       	push   $0x801444
  800168:	e8 b1 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016d:	83 c4 18             	add    $0x18,%esp
  800170:	53                   	push   %ebx
  800171:	ff 75 10             	pushl  0x10(%ebp)
  800174:	e8 54 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800179:	c7 04 24 24 17 80 00 	movl   $0x801724,(%esp)
  800180:	e8 99 00 00 00       	call   80021e <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800188:	cc                   	int3   
  800189:	eb fd                	jmp    800188 <_panic+0x43>

0080018b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	83 ec 04             	sub    $0x4,%esp
  800192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800195:	8b 13                	mov    (%ebx),%edx
  800197:	8d 42 01             	lea    0x1(%edx),%eax
  80019a:	89 03                	mov    %eax,(%ebx)
  80019c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a8:	75 1a                	jne    8001c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	68 ff 00 00 00       	push   $0xff
  8001b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b5:	50                   	push   %eax
  8001b6:	e8 79 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  8001bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dd:	00 00 00 
	b.cnt = 0;
  8001e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ea:	ff 75 0c             	pushl  0xc(%ebp)
  8001ed:	ff 75 08             	pushl  0x8(%ebp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	68 8b 01 80 00       	push   $0x80018b
  8001fc:	e8 54 01 00 00       	call   800355 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800201:	83 c4 08             	add    $0x8,%esp
  800204:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 1e 09 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800224:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800227:	50                   	push   %eax
  800228:	ff 75 08             	pushl  0x8(%ebp)
  80022b:	e8 9d ff ff ff       	call   8001cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 1c             	sub    $0x1c,%esp
  80023b:	89 c7                	mov    %eax,%edi
  80023d:	89 d6                	mov    %edx,%esi
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800248:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800253:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800256:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800259:	39 d3                	cmp    %edx,%ebx
  80025b:	72 05                	jb     800262 <printnum+0x30>
  80025d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800260:	77 45                	ja     8002a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	8b 45 14             	mov    0x14(%ebp),%eax
  80026b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026e:	53                   	push   %ebx
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	ff 75 e4             	pushl  -0x1c(%ebp)
  800278:	ff 75 e0             	pushl  -0x20(%ebp)
  80027b:	ff 75 dc             	pushl  -0x24(%ebp)
  80027e:	ff 75 d8             	pushl  -0x28(%ebp)
  800281:	e8 ba 0e 00 00       	call   801140 <__udivdi3>
  800286:	83 c4 18             	add    $0x18,%esp
  800289:	52                   	push   %edx
  80028a:	50                   	push   %eax
  80028b:	89 f2                	mov    %esi,%edx
  80028d:	89 f8                	mov    %edi,%eax
  80028f:	e8 9e ff ff ff       	call   800232 <printnum>
  800294:	83 c4 20             	add    $0x20,%esp
  800297:	eb 18                	jmp    8002b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	ff 75 18             	pushl  0x18(%ebp)
  8002a0:	ff d7                	call   *%edi
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	eb 03                	jmp    8002aa <printnum+0x78>
  8002a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f e8                	jg     800299 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 a7 0f 00 00       	call   801270 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 67 14 80 00 	movsbl 0x801467(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff d7                	call   *%edi
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e4:	83 fa 01             	cmp    $0x1,%edx
  8002e7:	7e 0e                	jle    8002f7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	8b 52 04             	mov    0x4(%edx),%edx
  8002f5:	eb 22                	jmp    800319 <getuint+0x38>
	else if (lflag)
  8002f7:	85 d2                	test   %edx,%edx
  8002f9:	74 10                	je     80030b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 02                	mov    (%edx),%eax
  800304:	ba 00 00 00 00       	mov    $0x0,%edx
  800309:	eb 0e                	jmp    800319 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800310:	89 08                	mov    %ecx,(%eax)
  800312:	8b 02                	mov    (%edx),%eax
  800314:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800321:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800325:	8b 10                	mov    (%eax),%edx
  800327:	3b 50 04             	cmp    0x4(%eax),%edx
  80032a:	73 0a                	jae    800336 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	88 02                	mov    %al,(%edx)
}
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800341:	50                   	push   %eax
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	ff 75 0c             	pushl  0xc(%ebp)
  800348:	ff 75 08             	pushl  0x8(%ebp)
  80034b:	e8 05 00 00 00       	call   800355 <vprintfmt>
	va_end(ap);
}
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	c9                   	leave  
  800354:	c3                   	ret    

00800355 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
  80035b:	83 ec 2c             	sub    $0x2c,%esp
  80035e:	8b 75 08             	mov    0x8(%ebp),%esi
  800361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800364:	8b 7d 10             	mov    0x10(%ebp),%edi
  800367:	eb 12                	jmp    80037b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800369:	85 c0                	test   %eax,%eax
  80036b:	0f 84 d3 03 00 00    	je     800744 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	53                   	push   %ebx
  800375:	50                   	push   %eax
  800376:	ff d6                	call   *%esi
  800378:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037b:	83 c7 01             	add    $0x1,%edi
  80037e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800382:	83 f8 25             	cmp    $0x25,%eax
  800385:	75 e2                	jne    800369 <vprintfmt+0x14>
  800387:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80038b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800392:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800399:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a5:	eb 07                	jmp    8003ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8d 47 01             	lea    0x1(%edi),%eax
  8003b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b4:	0f b6 07             	movzbl (%edi),%eax
  8003b7:	0f b6 c8             	movzbl %al,%ecx
  8003ba:	83 e8 23             	sub    $0x23,%eax
  8003bd:	3c 55                	cmp    $0x55,%al
  8003bf:	0f 87 64 03 00 00    	ja     800729 <vprintfmt+0x3d4>
  8003c5:	0f b6 c0             	movzbl %al,%eax
  8003c8:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d6:	eb d6                	jmp    8003ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ea:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ed:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f0:	83 fa 09             	cmp    $0x9,%edx
  8003f3:	77 39                	ja     80042e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f8:	eb e9                	jmp    8003e3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 48 04             	lea    0x4(%eax),%ecx
  800400:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800403:	8b 00                	mov    (%eax),%eax
  800405:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040b:	eb 27                	jmp    800434 <vprintfmt+0xdf>
  80040d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800410:	85 c0                	test   %eax,%eax
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	0f 49 c8             	cmovns %eax,%ecx
  80041a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800420:	eb 8c                	jmp    8003ae <vprintfmt+0x59>
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800425:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042c:	eb 80                	jmp    8003ae <vprintfmt+0x59>
  80042e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800431:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800434:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800438:	0f 89 70 ff ff ff    	jns    8003ae <vprintfmt+0x59>
				width = precision, precision = -1;
  80043e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800441:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800444:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80044b:	e9 5e ff ff ff       	jmp    8003ae <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800450:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800456:	e9 53 ff ff ff       	jmp    8003ae <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 50 04             	lea    0x4(%eax),%edx
  800461:	89 55 14             	mov    %edx,0x14(%ebp)
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	53                   	push   %ebx
  800468:	ff 30                	pushl  (%eax)
  80046a:	ff d6                	call   *%esi
			break;
  80046c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800472:	e9 04 ff ff ff       	jmp    80037b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	8b 00                	mov    (%eax),%eax
  800482:	99                   	cltd   
  800483:	31 d0                	xor    %edx,%eax
  800485:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800487:	83 f8 08             	cmp    $0x8,%eax
  80048a:	7f 0b                	jg     800497 <vprintfmt+0x142>
  80048c:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	75 18                	jne    8004af <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800497:	50                   	push   %eax
  800498:	68 7f 14 80 00       	push   $0x80147f
  80049d:	53                   	push   %ebx
  80049e:	56                   	push   %esi
  80049f:	e8 94 fe ff ff       	call   800338 <printfmt>
  8004a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004aa:	e9 cc fe ff ff       	jmp    80037b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004af:	52                   	push   %edx
  8004b0:	68 88 14 80 00       	push   $0x801488
  8004b5:	53                   	push   %ebx
  8004b6:	56                   	push   %esi
  8004b7:	e8 7c fe ff ff       	call   800338 <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c2:	e9 b4 fe ff ff       	jmp    80037b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 50 04             	lea    0x4(%eax),%edx
  8004cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	b8 78 14 80 00       	mov    $0x801478,%eax
  8004d9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e0:	0f 8e 94 00 00 00    	jle    80057a <vprintfmt+0x225>
  8004e6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ea:	0f 84 98 00 00 00    	je     800588 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 c8             	pushl  -0x38(%ebp)
  8004f6:	57                   	push   %edi
  8004f7:	e8 d0 02 00 00       	call   8007cc <strnlen>
  8004fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ff:	29 c1                	sub    %eax,%ecx
  800501:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800504:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800507:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800511:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	eb 0f                	jmp    800524 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	ff 75 e0             	pushl  -0x20(%ebp)
  80051c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	83 ef 01             	sub    $0x1,%edi
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	85 ff                	test   %edi,%edi
  800526:	7f ed                	jg     800515 <vprintfmt+0x1c0>
  800528:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80052e:	85 c9                	test   %ecx,%ecx
  800530:	b8 00 00 00 00       	mov    $0x0,%eax
  800535:	0f 49 c1             	cmovns %ecx,%eax
  800538:	29 c1                	sub    %eax,%ecx
  80053a:	89 75 08             	mov    %esi,0x8(%ebp)
  80053d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800540:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800543:	89 cb                	mov    %ecx,%ebx
  800545:	eb 4d                	jmp    800594 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800547:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054b:	74 1b                	je     800568 <vprintfmt+0x213>
  80054d:	0f be c0             	movsbl %al,%eax
  800550:	83 e8 20             	sub    $0x20,%eax
  800553:	83 f8 5e             	cmp    $0x5e,%eax
  800556:	76 10                	jbe    800568 <vprintfmt+0x213>
					putch('?', putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	ff 75 0c             	pushl  0xc(%ebp)
  80055e:	6a 3f                	push   $0x3f
  800560:	ff 55 08             	call   *0x8(%ebp)
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	eb 0d                	jmp    800575 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	52                   	push   %edx
  80056f:	ff 55 08             	call   *0x8(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800575:	83 eb 01             	sub    $0x1,%ebx
  800578:	eb 1a                	jmp    800594 <vprintfmt+0x23f>
  80057a:	89 75 08             	mov    %esi,0x8(%ebp)
  80057d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800580:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800583:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800586:	eb 0c                	jmp    800594 <vprintfmt+0x23f>
  800588:	89 75 08             	mov    %esi,0x8(%ebp)
  80058b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80058e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800591:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800594:	83 c7 01             	add    $0x1,%edi
  800597:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059b:	0f be d0             	movsbl %al,%edx
  80059e:	85 d2                	test   %edx,%edx
  8005a0:	74 23                	je     8005c5 <vprintfmt+0x270>
  8005a2:	85 f6                	test   %esi,%esi
  8005a4:	78 a1                	js     800547 <vprintfmt+0x1f2>
  8005a6:	83 ee 01             	sub    $0x1,%esi
  8005a9:	79 9c                	jns    800547 <vprintfmt+0x1f2>
  8005ab:	89 df                	mov    %ebx,%edi
  8005ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b3:	eb 18                	jmp    8005cd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	6a 20                	push   $0x20
  8005bb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bd:	83 ef 01             	sub    $0x1,%edi
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	eb 08                	jmp    8005cd <vprintfmt+0x278>
  8005c5:	89 df                	mov    %ebx,%edi
  8005c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cd:	85 ff                	test   %edi,%edi
  8005cf:	7f e4                	jg     8005b5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d4:	e9 a2 fd ff ff       	jmp    80037b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d9:	83 fa 01             	cmp    $0x1,%edx
  8005dc:	7e 16                	jle    8005f4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 08             	lea    0x8(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ef:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005f2:	eb 32                	jmp    800626 <vprintfmt+0x2d1>
	else if (lflag)
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	74 18                	je     800610 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800606:	89 c1                	mov    %eax,%ecx
  800608:	c1 f9 1f             	sar    $0x1f,%ecx
  80060b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80060e:	eb 16                	jmp    800626 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80061e:	89 c1                	mov    %eax,%ecx
  800620:	c1 f9 1f             	sar    $0x1f,%ecx
  800623:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800626:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800629:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800637:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80063b:	0f 89 b0 00 00 00    	jns    8006f1 <vprintfmt+0x39c>
				putch('-', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 2d                	push   $0x2d
  800647:	ff d6                	call   *%esi
				num = -(long long) num;
  800649:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80064c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80064f:	f7 d8                	neg    %eax
  800651:	83 d2 00             	adc    $0x0,%edx
  800654:	f7 da                	neg    %edx
  800656:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800659:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800664:	e9 88 00 00 00       	jmp    8006f1 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 70 fc ff ff       	call   8002e1 <getuint>
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067c:	eb 73                	jmp    8006f1 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 5b fc ff ff       	call   8002e1 <getuint>
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	6a 58                	push   $0x58
  800692:	ff d6                	call   *%esi
			putch('X', putdat);
  800694:	83 c4 08             	add    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 58                	push   $0x58
  80069a:	ff d6                	call   *%esi
			putch('X', putdat);
  80069c:	83 c4 08             	add    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 58                	push   $0x58
  8006a2:	ff d6                	call   *%esi
			goto number;
  8006a4:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8006a7:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006ac:	eb 43                	jmp    8006f1 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 30                	push   $0x30
  8006b4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b6:	83 c4 08             	add    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 78                	push   $0x78
  8006bc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 50 04             	lea    0x4(%eax),%edx
  8006c4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006dc:	eb 13                	jmp    8006f1 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006de:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e1:	e8 fb fb ff ff       	call   8002e1 <getuint>
  8006e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006ec:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f1:	83 ec 0c             	sub    $0xc,%esp
  8006f4:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006f8:	52                   	push   %edx
  8006f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fc:	50                   	push   %eax
  8006fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800700:	ff 75 d8             	pushl  -0x28(%ebp)
  800703:	89 da                	mov    %ebx,%edx
  800705:	89 f0                	mov    %esi,%eax
  800707:	e8 26 fb ff ff       	call   800232 <printnum>
			break;
  80070c:	83 c4 20             	add    $0x20,%esp
  80070f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800712:	e9 64 fc ff ff       	jmp    80037b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	51                   	push   %ecx
  80071c:	ff d6                	call   *%esi
			break;
  80071e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800721:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800724:	e9 52 fc ff ff       	jmp    80037b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	53                   	push   %ebx
  80072d:	6a 25                	push   $0x25
  80072f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	eb 03                	jmp    800739 <vprintfmt+0x3e4>
  800736:	83 ef 01             	sub    $0x1,%edi
  800739:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80073d:	75 f7                	jne    800736 <vprintfmt+0x3e1>
  80073f:	e9 37 fc ff ff       	jmp    80037b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800747:	5b                   	pop    %ebx
  800748:	5e                   	pop    %esi
  800749:	5f                   	pop    %edi
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	83 ec 18             	sub    $0x18,%esp
  800752:	8b 45 08             	mov    0x8(%ebp),%eax
  800755:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800758:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800762:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800769:	85 c0                	test   %eax,%eax
  80076b:	74 26                	je     800793 <vsnprintf+0x47>
  80076d:	85 d2                	test   %edx,%edx
  80076f:	7e 22                	jle    800793 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800771:	ff 75 14             	pushl  0x14(%ebp)
  800774:	ff 75 10             	pushl  0x10(%ebp)
  800777:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077a:	50                   	push   %eax
  80077b:	68 1b 03 80 00       	push   $0x80031b
  800780:	e8 d0 fb ff ff       	call   800355 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800785:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800788:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078e:	83 c4 10             	add    $0x10,%esp
  800791:	eb 05                	jmp    800798 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800793:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a3:	50                   	push   %eax
  8007a4:	ff 75 10             	pushl  0x10(%ebp)
  8007a7:	ff 75 0c             	pushl  0xc(%ebp)
  8007aa:	ff 75 08             	pushl  0x8(%ebp)
  8007ad:	e8 9a ff ff ff       	call   80074c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bf:	eb 03                	jmp    8007c4 <strlen+0x10>
		n++;
  8007c1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c8:	75 f7                	jne    8007c1 <strlen+0xd>
		n++;
	return n;
}
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007da:	eb 03                	jmp    8007df <strnlen+0x13>
		n++;
  8007dc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007df:	39 c2                	cmp    %eax,%edx
  8007e1:	74 08                	je     8007eb <strnlen+0x1f>
  8007e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e7:	75 f3                	jne    8007dc <strnlen+0x10>
  8007e9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	53                   	push   %ebx
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f7:	89 c2                	mov    %eax,%edx
  8007f9:	83 c2 01             	add    $0x1,%edx
  8007fc:	83 c1 01             	add    $0x1,%ecx
  8007ff:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800803:	88 5a ff             	mov    %bl,-0x1(%edx)
  800806:	84 db                	test   %bl,%bl
  800808:	75 ef                	jne    8007f9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080a:	5b                   	pop    %ebx
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	53                   	push   %ebx
  800811:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800814:	53                   	push   %ebx
  800815:	e8 9a ff ff ff       	call   8007b4 <strlen>
  80081a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	01 d8                	add    %ebx,%eax
  800822:	50                   	push   %eax
  800823:	e8 c5 ff ff ff       	call   8007ed <strcpy>
	return dst;
}
  800828:	89 d8                	mov    %ebx,%eax
  80082a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083a:	89 f3                	mov    %esi,%ebx
  80083c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083f:	89 f2                	mov    %esi,%edx
  800841:	eb 0f                	jmp    800852 <strncpy+0x23>
		*dst++ = *src;
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	0f b6 01             	movzbl (%ecx),%eax
  800849:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084c:	80 39 01             	cmpb   $0x1,(%ecx)
  80084f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800852:	39 da                	cmp    %ebx,%edx
  800854:	75 ed                	jne    800843 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800856:	89 f0                	mov    %esi,%eax
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 75 08             	mov    0x8(%ebp),%esi
  800864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800867:	8b 55 10             	mov    0x10(%ebp),%edx
  80086a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086c:	85 d2                	test   %edx,%edx
  80086e:	74 21                	je     800891 <strlcpy+0x35>
  800870:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800874:	89 f2                	mov    %esi,%edx
  800876:	eb 09                	jmp    800881 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800878:	83 c2 01             	add    $0x1,%edx
  80087b:	83 c1 01             	add    $0x1,%ecx
  80087e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800881:	39 c2                	cmp    %eax,%edx
  800883:	74 09                	je     80088e <strlcpy+0x32>
  800885:	0f b6 19             	movzbl (%ecx),%ebx
  800888:	84 db                	test   %bl,%bl
  80088a:	75 ec                	jne    800878 <strlcpy+0x1c>
  80088c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800891:	29 f0                	sub    %esi,%eax
}
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a0:	eb 06                	jmp    8008a8 <strcmp+0x11>
		p++, q++;
  8008a2:	83 c1 01             	add    $0x1,%ecx
  8008a5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a8:	0f b6 01             	movzbl (%ecx),%eax
  8008ab:	84 c0                	test   %al,%al
  8008ad:	74 04                	je     8008b3 <strcmp+0x1c>
  8008af:	3a 02                	cmp    (%edx),%al
  8008b1:	74 ef                	je     8008a2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 c0             	movzbl %al,%eax
  8008b6:	0f b6 12             	movzbl (%edx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c7:	89 c3                	mov    %eax,%ebx
  8008c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cc:	eb 06                	jmp    8008d4 <strncmp+0x17>
		n--, p++, q++;
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d4:	39 d8                	cmp    %ebx,%eax
  8008d6:	74 15                	je     8008ed <strncmp+0x30>
  8008d8:	0f b6 08             	movzbl (%eax),%ecx
  8008db:	84 c9                	test   %cl,%cl
  8008dd:	74 04                	je     8008e3 <strncmp+0x26>
  8008df:	3a 0a                	cmp    (%edx),%cl
  8008e1:	74 eb                	je     8008ce <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 00             	movzbl (%eax),%eax
  8008e6:	0f b6 12             	movzbl (%edx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
  8008eb:	eb 05                	jmp    8008f2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ff:	eb 07                	jmp    800908 <strchr+0x13>
		if (*s == c)
  800901:	38 ca                	cmp    %cl,%dl
  800903:	74 0f                	je     800914 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	0f b6 10             	movzbl (%eax),%edx
  80090b:	84 d2                	test   %dl,%dl
  80090d:	75 f2                	jne    800901 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800920:	eb 03                	jmp    800925 <strfind+0xf>
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	74 04                	je     800930 <strfind+0x1a>
  80092c:	84 d2                	test   %dl,%dl
  80092e:	75 f2                	jne    800922 <strfind+0xc>
			break;
	return (char *) s;
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	57                   	push   %edi
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093e:	85 c9                	test   %ecx,%ecx
  800940:	74 36                	je     800978 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800942:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800948:	75 28                	jne    800972 <memset+0x40>
  80094a:	f6 c1 03             	test   $0x3,%cl
  80094d:	75 23                	jne    800972 <memset+0x40>
		c &= 0xFF;
  80094f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800953:	89 d3                	mov    %edx,%ebx
  800955:	c1 e3 08             	shl    $0x8,%ebx
  800958:	89 d6                	mov    %edx,%esi
  80095a:	c1 e6 18             	shl    $0x18,%esi
  80095d:	89 d0                	mov    %edx,%eax
  80095f:	c1 e0 10             	shl    $0x10,%eax
  800962:	09 f0                	or     %esi,%eax
  800964:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800966:	89 d8                	mov    %ebx,%eax
  800968:	09 d0                	or     %edx,%eax
  80096a:	c1 e9 02             	shr    $0x2,%ecx
  80096d:	fc                   	cld    
  80096e:	f3 ab                	rep stos %eax,%es:(%edi)
  800970:	eb 06                	jmp    800978 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	fc                   	cld    
  800976:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800978:	89 f8                	mov    %edi,%eax
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098d:	39 c6                	cmp    %eax,%esi
  80098f:	73 35                	jae    8009c6 <memmove+0x47>
  800991:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800994:	39 d0                	cmp    %edx,%eax
  800996:	73 2e                	jae    8009c6 <memmove+0x47>
		s += n;
		d += n;
  800998:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099b:	89 d6                	mov    %edx,%esi
  80099d:	09 fe                	or     %edi,%esi
  80099f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a5:	75 13                	jne    8009ba <memmove+0x3b>
  8009a7:	f6 c1 03             	test   $0x3,%cl
  8009aa:	75 0e                	jne    8009ba <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ac:	83 ef 04             	sub    $0x4,%edi
  8009af:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
  8009b5:	fd                   	std    
  8009b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b8:	eb 09                	jmp    8009c3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ba:	83 ef 01             	sub    $0x1,%edi
  8009bd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c0:	fd                   	std    
  8009c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c3:	fc                   	cld    
  8009c4:	eb 1d                	jmp    8009e3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c6:	89 f2                	mov    %esi,%edx
  8009c8:	09 c2                	or     %eax,%edx
  8009ca:	f6 c2 03             	test   $0x3,%dl
  8009cd:	75 0f                	jne    8009de <memmove+0x5f>
  8009cf:	f6 c1 03             	test   $0x3,%cl
  8009d2:	75 0a                	jne    8009de <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
  8009d7:	89 c7                	mov    %eax,%edi
  8009d9:	fc                   	cld    
  8009da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dc:	eb 05                	jmp    8009e3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ea:	ff 75 10             	pushl  0x10(%ebp)
  8009ed:	ff 75 0c             	pushl  0xc(%ebp)
  8009f0:	ff 75 08             	pushl  0x8(%ebp)
  8009f3:	e8 87 ff ff ff       	call   80097f <memmove>
}
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a05:	89 c6                	mov    %eax,%esi
  800a07:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0a:	eb 1a                	jmp    800a26 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0c:	0f b6 08             	movzbl (%eax),%ecx
  800a0f:	0f b6 1a             	movzbl (%edx),%ebx
  800a12:	38 d9                	cmp    %bl,%cl
  800a14:	74 0a                	je     800a20 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a16:	0f b6 c1             	movzbl %cl,%eax
  800a19:	0f b6 db             	movzbl %bl,%ebx
  800a1c:	29 d8                	sub    %ebx,%eax
  800a1e:	eb 0f                	jmp    800a2f <memcmp+0x35>
		s1++, s2++;
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a26:	39 f0                	cmp    %esi,%eax
  800a28:	75 e2                	jne    800a0c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3a:	89 c1                	mov    %eax,%ecx
  800a3c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a43:	eb 0a                	jmp    800a4f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	39 da                	cmp    %ebx,%edx
  800a4a:	74 07                	je     800a53 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	39 c8                	cmp    %ecx,%eax
  800a51:	72 f2                	jb     800a45 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a62:	eb 03                	jmp    800a67 <strtol+0x11>
		s++;
  800a64:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	0f b6 01             	movzbl (%ecx),%eax
  800a6a:	3c 20                	cmp    $0x20,%al
  800a6c:	74 f6                	je     800a64 <strtol+0xe>
  800a6e:	3c 09                	cmp    $0x9,%al
  800a70:	74 f2                	je     800a64 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a72:	3c 2b                	cmp    $0x2b,%al
  800a74:	75 0a                	jne    800a80 <strtol+0x2a>
		s++;
  800a76:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7e:	eb 11                	jmp    800a91 <strtol+0x3b>
  800a80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a85:	3c 2d                	cmp    $0x2d,%al
  800a87:	75 08                	jne    800a91 <strtol+0x3b>
		s++, neg = 1;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a91:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a97:	75 15                	jne    800aae <strtol+0x58>
  800a99:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9c:	75 10                	jne    800aae <strtol+0x58>
  800a9e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa2:	75 7c                	jne    800b20 <strtol+0xca>
		s += 2, base = 16;
  800aa4:	83 c1 02             	add    $0x2,%ecx
  800aa7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aac:	eb 16                	jmp    800ac4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aae:	85 db                	test   %ebx,%ebx
  800ab0:	75 12                	jne    800ac4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aba:	75 08                	jne    800ac4 <strtol+0x6e>
		s++, base = 8;
  800abc:	83 c1 01             	add    $0x1,%ecx
  800abf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800acc:	0f b6 11             	movzbl (%ecx),%edx
  800acf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad2:	89 f3                	mov    %esi,%ebx
  800ad4:	80 fb 09             	cmp    $0x9,%bl
  800ad7:	77 08                	ja     800ae1 <strtol+0x8b>
			dig = *s - '0';
  800ad9:	0f be d2             	movsbl %dl,%edx
  800adc:	83 ea 30             	sub    $0x30,%edx
  800adf:	eb 22                	jmp    800b03 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae4:	89 f3                	mov    %esi,%ebx
  800ae6:	80 fb 19             	cmp    $0x19,%bl
  800ae9:	77 08                	ja     800af3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aeb:	0f be d2             	movsbl %dl,%edx
  800aee:	83 ea 57             	sub    $0x57,%edx
  800af1:	eb 10                	jmp    800b03 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	80 fb 19             	cmp    $0x19,%bl
  800afb:	77 16                	ja     800b13 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800afd:	0f be d2             	movsbl %dl,%edx
  800b00:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b03:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b06:	7d 0b                	jge    800b13 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b08:	83 c1 01             	add    $0x1,%ecx
  800b0b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b11:	eb b9                	jmp    800acc <strtol+0x76>

	if (endptr)
  800b13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b17:	74 0d                	je     800b26 <strtol+0xd0>
		*endptr = (char *) s;
  800b19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1c:	89 0e                	mov    %ecx,(%esi)
  800b1e:	eb 06                	jmp    800b26 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b20:	85 db                	test   %ebx,%ebx
  800b22:	74 98                	je     800abc <strtol+0x66>
  800b24:	eb 9e                	jmp    800ac4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b26:	89 c2                	mov    %eax,%edx
  800b28:	f7 da                	neg    %edx
  800b2a:	85 ff                	test   %edi,%edi
  800b2c:	0f 45 c2             	cmovne %edx,%eax
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 17                	jle    800baa <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	83 ec 0c             	sub    $0xc,%esp
  800b96:	50                   	push   %eax
  800b97:	6a 03                	push   $0x3
  800b99:	68 a4 16 80 00       	push   $0x8016a4
  800b9e:	6a 23                	push   $0x23
  800ba0:	68 c1 16 80 00       	push   $0x8016c1
  800ba5:	e8 9b f5 ff ff       	call   800145 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_yield>:

void
sys_yield(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bf9:	be 00 00 00 00       	mov    $0x0,%esi
  800bfe:	b8 04 00 00 00       	mov    $0x4,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	89 f7                	mov    %esi,%edi
  800c0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 04                	push   $0x4
  800c1a:	68 a4 16 80 00       	push   $0x8016a4
  800c1f:	6a 23                	push   $0x23
  800c21:	68 c1 16 80 00       	push   $0x8016c1
  800c26:	e8 1a f5 ff ff       	call   800145 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c3c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 05                	push   $0x5
  800c5c:	68 a4 16 80 00       	push   $0x8016a4
  800c61:	6a 23                	push   $0x23
  800c63:	68 c1 16 80 00       	push   $0x8016c1
  800c68:	e8 d8 f4 ff ff       	call   800145 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 06 00 00 00       	mov    $0x6,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 06                	push   $0x6
  800c9e:	68 a4 16 80 00       	push   $0x8016a4
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 c1 16 80 00       	push   $0x8016c1
  800caa:	e8 96 f4 ff ff       	call   800145 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 08                	push   $0x8
  800ce0:	68 a4 16 80 00       	push   $0x8016a4
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 c1 16 80 00       	push   $0x8016c1
  800cec:	e8 54 f4 ff ff       	call   800145 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 09 00 00 00       	mov    $0x9,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 09                	push   $0x9
  800d22:	68 a4 16 80 00       	push   $0x8016a4
  800d27:	6a 23                	push   $0x23
  800d29:	68 c1 16 80 00       	push   $0x8016c1
  800d2e:	e8 12 f4 ff ff       	call   800145 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0c                	push   $0xc
  800d86:	68 a4 16 80 00       	push   $0x8016a4
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 c1 16 80 00       	push   $0x8016c1
  800d92:	e8 ae f3 ff ff       	call   800145 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	53                   	push   %ebx
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800da9:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800dab:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800daf:	74 2e                	je     800ddf <pgfault+0x40>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	c1 ea 16             	shr    $0x16,%edx
  800db6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
  800dbd:	f6 c2 01             	test   $0x1,%dl
  800dc0:	74 1d                	je     800ddf <pgfault+0x40>
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
  800dc2:	89 c2                	mov    %eax,%edx
  800dc4:	c1 ea 0c             	shr    $0xc,%edx
  800dc7:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800dce:	f6 c1 01             	test   $0x1,%cl
  800dd1:	74 0c                	je     800ddf <pgfault+0x40>
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800dd3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800dda:	f6 c6 08             	test   $0x8,%dh
  800ddd:	75 14                	jne    800df3 <pgfault+0x54>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	68 cf 16 80 00       	push   $0x8016cf
  800de7:	6a 22                	push   $0x22
  800de9:	68 e5 16 80 00       	push   $0x8016e5
  800dee:	e8 52 f3 ff ff       	call   800145 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df8:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	6a 07                	push   $0x7
  800dff:	68 00 f0 7f 00       	push   $0x7ff000
  800e04:	6a 00                	push   $0x0
  800e06:	e8 e5 fd ff ff       	call   800bf0 <sys_page_alloc>
  800e0b:	83 c4 10             	add    $0x10,%esp
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	79 14                	jns    800e26 <pgfault+0x87>
		panic("sys_page_alloc");
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	68 f0 16 80 00       	push   $0x8016f0
  800e1a:	6a 2f                	push   $0x2f
  800e1c:	68 e5 16 80 00       	push   $0x8016e5
  800e21:	e8 1f f3 ff ff       	call   800145 <_panic>
	}
	memcpy(PFTEMP, addr, PGSIZE);
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	68 00 10 00 00       	push   $0x1000
  800e2e:	53                   	push   %ebx
  800e2f:	68 00 f0 7f 00       	push   $0x7ff000
  800e34:	e8 ae fb ff ff       	call   8009e7 <memcpy>
	
	retv = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P);
  800e39:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e40:	53                   	push   %ebx
  800e41:	6a 00                	push   $0x0
  800e43:	68 00 f0 7f 00       	push   $0x7ff000
  800e48:	6a 00                	push   $0x0
  800e4a:	e8 e4 fd ff ff       	call   800c33 <sys_page_map>
	if(retv < 0){
  800e4f:	83 c4 20             	add    $0x20,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	79 14                	jns    800e6a <pgfault+0xcb>
		panic("sys_page_map");
  800e56:	83 ec 04             	sub    $0x4,%esp
  800e59:	68 ff 16 80 00       	push   $0x8016ff
  800e5e:	6a 35                	push   $0x35
  800e60:	68 e5 16 80 00       	push   $0x8016e5
  800e65:	e8 db f2 ff ff       	call   800145 <_panic>
	}
	return;
	panic("pgfault not implemented");
}
  800e6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 28             	sub    $0x28,%esp
	cprintf("\t\t we are in the fork().\n");
  800e78:	68 0c 17 80 00       	push   $0x80170c
  800e7d:	e8 9c f3 ff ff       	call   80021e <cprintf>
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800e82:	c7 04 24 9f 0d 80 00 	movl   $0x800d9f,(%esp)
  800e89:	e8 bc 01 00 00       	call   80104a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e8e:	b8 07 00 00 00       	mov    $0x7,%eax
  800e93:	cd 30                	int    $0x30
  800e95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//create a child
	child_envid = sys_exofork();
	if(child_envid < 0 ){
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	79 14                	jns    800eb3 <fork+0x44>
		panic("sys_exofork failed.");
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	68 26 17 80 00       	push   $0x801726
  800ea7:	6a 7d                	push   $0x7d
  800ea9:	68 e5 16 80 00       	push   $0x8016e5
  800eae:	e8 92 f2 ff ff       	call   800145 <_panic>
  800eb3:	89 c7                	mov    %eax,%edi
  800eb5:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800eba:	89 d8                	mov    %ebx,%eax
  800ebc:	c1 e8 16             	shr    $0x16,%eax
  800ebf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800ec6:	a8 01                	test   $0x1,%al
  800ec8:	0f 84 db 00 00 00    	je     800fa9 <fork+0x13a>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800ece:	89 d8                	mov    %ebx,%eax
  800ed0:	c1 e8 0c             	shr    $0xc,%eax
  800ed3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800eda:	f6 c2 01             	test   $0x1,%dl
  800edd:	0f 84 c6 00 00 00    	je     800fa9 <fork+0x13a>
			(uvpt[PGNUM(addr)] & PTE_P)&& 
			(uvpt[PGNUM(addr)] & PTE_U)
  800ee3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800eea:	f6 c2 04             	test   $0x4,%dl
  800eed:	0f 84 b6 00 00 00    	je     800fa9 <fork+0x13a>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;

	// LAB 4: Your code here.
	void *addr = (void*)(pn*PGSIZE);
  800ef3:	89 c6                	mov    %eax,%esi
  800ef5:	c1 e6 0c             	shl    $0xc,%esi
	if( (uvpt[pn] & PTE_W)||(uvpt[pn]) & PTE_COW ){
  800ef8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eff:	f6 c2 02             	test   $0x2,%dl
  800f02:	75 0c                	jne    800f10 <fork+0xa1>
  800f04:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0b:	f6 c4 08             	test   $0x8,%ah
  800f0e:	74 77                	je     800f87 <fork+0x118>
		
		r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_P|PTE_U);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	68 05 08 00 00       	push   $0x805
  800f18:	56                   	push   %esi
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	6a 00                	push   $0x0
  800f1d:	e8 11 fd ff ff       	call   800c33 <sys_page_map>
		if(r<0){
  800f22:	83 c4 20             	add    $0x20,%esp
  800f25:	85 c0                	test   %eax,%eax
  800f27:	79 22                	jns    800f4b <fork+0xdc>
			cprintf("sys_page_map failed :%d\n",r);
  800f29:	83 ec 08             	sub    $0x8,%esp
  800f2c:	50                   	push   %eax
  800f2d:	68 3a 17 80 00       	push   $0x80173a
  800f32:	e8 e7 f2 ff ff       	call   80021e <cprintf>
			panic("map env id 0 to child_envid failed.");
  800f37:	83 c4 0c             	add    $0xc,%esp
  800f3a:	68 b4 17 80 00       	push   $0x8017b4
  800f3f:	6a 52                	push   $0x52
  800f41:	68 e5 16 80 00       	push   $0x8016e5
  800f46:	e8 fa f1 ff ff       	call   800145 <_panic>
		
		}
		r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_P|PTE_U);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	68 05 08 00 00       	push   $0x805
  800f53:	56                   	push   %esi
  800f54:	6a 00                	push   $0x0
  800f56:	56                   	push   %esi
  800f57:	6a 00                	push   $0x0
  800f59:	e8 d5 fc ff ff       	call   800c33 <sys_page_map>
		if(r<0){
  800f5e:	83 c4 20             	add    $0x20,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 34                	jns    800f99 <fork+0x12a>
			cprintf("sys_page_map failed :%d\n",r);
  800f65:	83 ec 08             	sub    $0x8,%esp
  800f68:	50                   	push   %eax
  800f69:	68 3a 17 80 00       	push   $0x80173a
  800f6e:	e8 ab f2 ff ff       	call   80021e <cprintf>
			panic("map env id 0 to 0");
  800f73:	83 c4 0c             	add    $0xc,%esp
  800f76:	68 53 17 80 00       	push   $0x801753
  800f7b:	6a 58                	push   $0x58
  800f7d:	68 e5 16 80 00       	push   $0x8016e5
  800f82:	e8 be f1 ff ff       	call   800145 <_panic>
		}//?we should mark PTE_COW both to two id.
	}else{
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800f87:	83 ec 0c             	sub    $0xc,%esp
  800f8a:	6a 05                	push   $0x5
  800f8c:	56                   	push   %esi
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 9d fc ff ff       	call   800c33 <sys_page_map>
  800f96:	83 c4 20             	add    $0x20,%esp
	}
	cprintf("1.");
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	68 65 17 80 00       	push   $0x801765
  800fa1:	e8 78 f2 ff ff       	call   80021e <cprintf>
  800fa6:	83 c4 10             	add    $0x10,%esp
	if(child_envid < 0 ){
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800fa9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800faf:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fb5:	0f 85 ff fe ff ff    	jne    800eba <fork+0x4b>
	 	    }	
	}
	//panic("failed at duppage.");
	//set up a user exception stack for pgfault() to run.
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	6a 07                	push   $0x7
  800fc0:	68 00 f0 bf ee       	push   $0xeebff000
  800fc5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc8:	e8 23 fc ff ff       	call   800bf0 <sys_page_alloc>
	if(retv < 0){
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 17                	jns    800feb <fork+0x17c>
		panic("sys_page_alloc failed.\n");
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	68 68 17 80 00       	push   $0x801768
  800fdc:	68 8f 00 00 00       	push   $0x8f
  800fe1:	68 e5 16 80 00       	push   $0x8016e5
  800fe6:	e8 5a f1 ff ff       	call   800145 <_panic>
	}
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	68 11 11 80 00       	push   $0x801111
  800ff3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ff6:	57                   	push   %edi
  800ff7:	e8 fd fc ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  800ffc:	83 c4 08             	add    $0x8,%esp
  800fff:	6a 02                	push   $0x2
  801001:	57                   	push   %edi
  801002:	e8 b0 fc ff ff       	call   800cb7 <sys_env_set_status>
	if(retv < 0){
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	79 17                	jns    801025 <fork+0x1b6>
		panic("sys_env_set_status failed.\n");
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	68 80 17 80 00       	push   $0x801780
  801016:	68 95 00 00 00       	push   $0x95
  80101b:	68 e5 16 80 00       	push   $0x8016e5
  801020:	e8 20 f1 ff ff       	call   800145 <_panic>
	}
	return child_envid;
	panic("fork not implemented");
}
  801025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801028:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <sfork>:

// Challenge!
int
sfork(void)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801036:	68 9c 17 80 00       	push   $0x80179c
  80103b:	68 9f 00 00 00       	push   $0x9f
  801040:	68 e5 16 80 00       	push   $0x8016e5
  801045:	e8 fb f0 ff ff       	call   800145 <_panic>

0080104a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  801050:	68 d8 17 80 00       	push   $0x8017d8
  801055:	e8 c4 f1 ff ff       	call   80021e <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801064:	0f 85 8d 00 00 00    	jne    8010f7 <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	68 f8 17 80 00       	push   $0x8017f8
  801072:	e8 a7 f1 ff ff       	call   80021e <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801077:	a1 08 20 80 00       	mov    0x802008,%eax
  80107c:	8b 40 48             	mov    0x48(%eax),%eax
  80107f:	83 c4 0c             	add    $0xc,%esp
  801082:	6a 07                	push   $0x7
  801084:	68 00 f0 bf ee       	push   $0xeebff000
  801089:	50                   	push   %eax
  80108a:	e8 61 fb ff ff       	call   800bf0 <sys_page_alloc>
		if(retv != 0){
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	74 14                	je     8010aa <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  801096:	83 ec 04             	sub    $0x4,%esp
  801099:	68 1c 18 80 00       	push   $0x80181c
  80109e:	6a 27                	push   $0x27
  8010a0:	68 70 18 80 00       	push   $0x801870
  8010a5:	e8 9b f0 ff ff       	call   800145 <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	68 11 11 80 00       	push   $0x801111
  8010b2:	68 7e 18 80 00       	push   $0x80187e
  8010b7:	e8 62 f1 ff ff       	call   80021e <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  8010bc:	a1 08 20 80 00       	mov    0x802008,%eax
  8010c1:	8b 40 48             	mov    0x48(%eax),%eax
  8010c4:	83 c4 08             	add    $0x8,%esp
  8010c7:	50                   	push   %eax
  8010c8:	68 99 18 80 00       	push   $0x801899
  8010cd:	e8 4c f1 ff ff       	call   80021e <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8010d2:	a1 08 20 80 00       	mov    0x802008,%eax
  8010d7:	8b 40 48             	mov    0x48(%eax),%eax
  8010da:	83 c4 08             	add    $0x8,%esp
  8010dd:	68 11 11 80 00       	push   $0x801111
  8010e2:	50                   	push   %eax
  8010e3:	e8 11 fc ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  8010e8:	c7 04 24 b0 18 80 00 	movl   $0x8018b0,(%esp)
  8010ef:	e8 2a f1 ff ff       	call   80021e <cprintf>
  8010f4:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	68 48 18 80 00       	push   $0x801848
  8010ff:	e8 1a f1 ff ff       	call   80021e <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	a3 0c 20 80 00       	mov    %eax,0x80200c

}
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801111:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801112:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801117:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801119:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  80111c:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  80111e:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  801122:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801126:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  801127:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  801129:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  801130:	00 
	popl %eax
  801131:	58                   	pop    %eax
	popl %eax
  801132:	58                   	pop    %eax
	popal
  801133:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  801134:	83 c4 04             	add    $0x4,%esp
	popfl
  801137:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801138:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801139:	c3                   	ret    
  80113a:	66 90                	xchg   %ax,%ax
  80113c:	66 90                	xchg   %ax,%ax
  80113e:	66 90                	xchg   %ax,%ax

00801140 <__udivdi3>:
  801140:	55                   	push   %ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 1c             	sub    $0x1c,%esp
  801147:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80114b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80114f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801153:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801157:	85 f6                	test   %esi,%esi
  801159:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80115d:	89 ca                	mov    %ecx,%edx
  80115f:	89 f8                	mov    %edi,%eax
  801161:	75 3d                	jne    8011a0 <__udivdi3+0x60>
  801163:	39 cf                	cmp    %ecx,%edi
  801165:	0f 87 c5 00 00 00    	ja     801230 <__udivdi3+0xf0>
  80116b:	85 ff                	test   %edi,%edi
  80116d:	89 fd                	mov    %edi,%ebp
  80116f:	75 0b                	jne    80117c <__udivdi3+0x3c>
  801171:	b8 01 00 00 00       	mov    $0x1,%eax
  801176:	31 d2                	xor    %edx,%edx
  801178:	f7 f7                	div    %edi
  80117a:	89 c5                	mov    %eax,%ebp
  80117c:	89 c8                	mov    %ecx,%eax
  80117e:	31 d2                	xor    %edx,%edx
  801180:	f7 f5                	div    %ebp
  801182:	89 c1                	mov    %eax,%ecx
  801184:	89 d8                	mov    %ebx,%eax
  801186:	89 cf                	mov    %ecx,%edi
  801188:	f7 f5                	div    %ebp
  80118a:	89 c3                	mov    %eax,%ebx
  80118c:	89 d8                	mov    %ebx,%eax
  80118e:	89 fa                	mov    %edi,%edx
  801190:	83 c4 1c             	add    $0x1c,%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    
  801198:	90                   	nop
  801199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	39 ce                	cmp    %ecx,%esi
  8011a2:	77 74                	ja     801218 <__udivdi3+0xd8>
  8011a4:	0f bd fe             	bsr    %esi,%edi
  8011a7:	83 f7 1f             	xor    $0x1f,%edi
  8011aa:	0f 84 98 00 00 00    	je     801248 <__udivdi3+0x108>
  8011b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011b5:	89 f9                	mov    %edi,%ecx
  8011b7:	89 c5                	mov    %eax,%ebp
  8011b9:	29 fb                	sub    %edi,%ebx
  8011bb:	d3 e6                	shl    %cl,%esi
  8011bd:	89 d9                	mov    %ebx,%ecx
  8011bf:	d3 ed                	shr    %cl,%ebp
  8011c1:	89 f9                	mov    %edi,%ecx
  8011c3:	d3 e0                	shl    %cl,%eax
  8011c5:	09 ee                	or     %ebp,%esi
  8011c7:	89 d9                	mov    %ebx,%ecx
  8011c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011cd:	89 d5                	mov    %edx,%ebp
  8011cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011d3:	d3 ed                	shr    %cl,%ebp
  8011d5:	89 f9                	mov    %edi,%ecx
  8011d7:	d3 e2                	shl    %cl,%edx
  8011d9:	89 d9                	mov    %ebx,%ecx
  8011db:	d3 e8                	shr    %cl,%eax
  8011dd:	09 c2                	or     %eax,%edx
  8011df:	89 d0                	mov    %edx,%eax
  8011e1:	89 ea                	mov    %ebp,%edx
  8011e3:	f7 f6                	div    %esi
  8011e5:	89 d5                	mov    %edx,%ebp
  8011e7:	89 c3                	mov    %eax,%ebx
  8011e9:	f7 64 24 0c          	mull   0xc(%esp)
  8011ed:	39 d5                	cmp    %edx,%ebp
  8011ef:	72 10                	jb     801201 <__udivdi3+0xc1>
  8011f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011f5:	89 f9                	mov    %edi,%ecx
  8011f7:	d3 e6                	shl    %cl,%esi
  8011f9:	39 c6                	cmp    %eax,%esi
  8011fb:	73 07                	jae    801204 <__udivdi3+0xc4>
  8011fd:	39 d5                	cmp    %edx,%ebp
  8011ff:	75 03                	jne    801204 <__udivdi3+0xc4>
  801201:	83 eb 01             	sub    $0x1,%ebx
  801204:	31 ff                	xor    %edi,%edi
  801206:	89 d8                	mov    %ebx,%eax
  801208:	89 fa                	mov    %edi,%edx
  80120a:	83 c4 1c             	add    $0x1c,%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5e                   	pop    %esi
  80120f:	5f                   	pop    %edi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    
  801212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801218:	31 ff                	xor    %edi,%edi
  80121a:	31 db                	xor    %ebx,%ebx
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	89 fa                	mov    %edi,%edx
  801220:	83 c4 1c             	add    $0x1c,%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
  801228:	90                   	nop
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 d8                	mov    %ebx,%eax
  801232:	f7 f7                	div    %edi
  801234:	31 ff                	xor    %edi,%edi
  801236:	89 c3                	mov    %eax,%ebx
  801238:	89 d8                	mov    %ebx,%eax
  80123a:	89 fa                	mov    %edi,%edx
  80123c:	83 c4 1c             	add    $0x1c,%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5f                   	pop    %edi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	39 ce                	cmp    %ecx,%esi
  80124a:	72 0c                	jb     801258 <__udivdi3+0x118>
  80124c:	31 db                	xor    %ebx,%ebx
  80124e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801252:	0f 87 34 ff ff ff    	ja     80118c <__udivdi3+0x4c>
  801258:	bb 01 00 00 00       	mov    $0x1,%ebx
  80125d:	e9 2a ff ff ff       	jmp    80118c <__udivdi3+0x4c>
  801262:	66 90                	xchg   %ax,%ax
  801264:	66 90                	xchg   %ax,%ax
  801266:	66 90                	xchg   %ax,%ax
  801268:	66 90                	xchg   %ax,%ax
  80126a:	66 90                	xchg   %ax,%ax
  80126c:	66 90                	xchg   %ax,%ax
  80126e:	66 90                	xchg   %ax,%ax

00801270 <__umoddi3>:
  801270:	55                   	push   %ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 1c             	sub    $0x1c,%esp
  801277:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80127b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80127f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801287:	85 d2                	test   %edx,%edx
  801289:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80128d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801291:	89 f3                	mov    %esi,%ebx
  801293:	89 3c 24             	mov    %edi,(%esp)
  801296:	89 74 24 04          	mov    %esi,0x4(%esp)
  80129a:	75 1c                	jne    8012b8 <__umoddi3+0x48>
  80129c:	39 f7                	cmp    %esi,%edi
  80129e:	76 50                	jbe    8012f0 <__umoddi3+0x80>
  8012a0:	89 c8                	mov    %ecx,%eax
  8012a2:	89 f2                	mov    %esi,%edx
  8012a4:	f7 f7                	div    %edi
  8012a6:	89 d0                	mov    %edx,%eax
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	83 c4 1c             	add    $0x1c,%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5f                   	pop    %edi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    
  8012b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012b8:	39 f2                	cmp    %esi,%edx
  8012ba:	89 d0                	mov    %edx,%eax
  8012bc:	77 52                	ja     801310 <__umoddi3+0xa0>
  8012be:	0f bd ea             	bsr    %edx,%ebp
  8012c1:	83 f5 1f             	xor    $0x1f,%ebp
  8012c4:	75 5a                	jne    801320 <__umoddi3+0xb0>
  8012c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012ca:	0f 82 e0 00 00 00    	jb     8013b0 <__umoddi3+0x140>
  8012d0:	39 0c 24             	cmp    %ecx,(%esp)
  8012d3:	0f 86 d7 00 00 00    	jbe    8013b0 <__umoddi3+0x140>
  8012d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012e1:	83 c4 1c             	add    $0x1c,%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    
  8012e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	85 ff                	test   %edi,%edi
  8012f2:	89 fd                	mov    %edi,%ebp
  8012f4:	75 0b                	jne    801301 <__umoddi3+0x91>
  8012f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	f7 f7                	div    %edi
  8012ff:	89 c5                	mov    %eax,%ebp
  801301:	89 f0                	mov    %esi,%eax
  801303:	31 d2                	xor    %edx,%edx
  801305:	f7 f5                	div    %ebp
  801307:	89 c8                	mov    %ecx,%eax
  801309:	f7 f5                	div    %ebp
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	eb 99                	jmp    8012a8 <__umoddi3+0x38>
  80130f:	90                   	nop
  801310:	89 c8                	mov    %ecx,%eax
  801312:	89 f2                	mov    %esi,%edx
  801314:	83 c4 1c             	add    $0x1c,%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5f                   	pop    %edi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	8b 34 24             	mov    (%esp),%esi
  801323:	bf 20 00 00 00       	mov    $0x20,%edi
  801328:	89 e9                	mov    %ebp,%ecx
  80132a:	29 ef                	sub    %ebp,%edi
  80132c:	d3 e0                	shl    %cl,%eax
  80132e:	89 f9                	mov    %edi,%ecx
  801330:	89 f2                	mov    %esi,%edx
  801332:	d3 ea                	shr    %cl,%edx
  801334:	89 e9                	mov    %ebp,%ecx
  801336:	09 c2                	or     %eax,%edx
  801338:	89 d8                	mov    %ebx,%eax
  80133a:	89 14 24             	mov    %edx,(%esp)
  80133d:	89 f2                	mov    %esi,%edx
  80133f:	d3 e2                	shl    %cl,%edx
  801341:	89 f9                	mov    %edi,%ecx
  801343:	89 54 24 04          	mov    %edx,0x4(%esp)
  801347:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80134b:	d3 e8                	shr    %cl,%eax
  80134d:	89 e9                	mov    %ebp,%ecx
  80134f:	89 c6                	mov    %eax,%esi
  801351:	d3 e3                	shl    %cl,%ebx
  801353:	89 f9                	mov    %edi,%ecx
  801355:	89 d0                	mov    %edx,%eax
  801357:	d3 e8                	shr    %cl,%eax
  801359:	89 e9                	mov    %ebp,%ecx
  80135b:	09 d8                	or     %ebx,%eax
  80135d:	89 d3                	mov    %edx,%ebx
  80135f:	89 f2                	mov    %esi,%edx
  801361:	f7 34 24             	divl   (%esp)
  801364:	89 d6                	mov    %edx,%esi
  801366:	d3 e3                	shl    %cl,%ebx
  801368:	f7 64 24 04          	mull   0x4(%esp)
  80136c:	39 d6                	cmp    %edx,%esi
  80136e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801372:	89 d1                	mov    %edx,%ecx
  801374:	89 c3                	mov    %eax,%ebx
  801376:	72 08                	jb     801380 <__umoddi3+0x110>
  801378:	75 11                	jne    80138b <__umoddi3+0x11b>
  80137a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80137e:	73 0b                	jae    80138b <__umoddi3+0x11b>
  801380:	2b 44 24 04          	sub    0x4(%esp),%eax
  801384:	1b 14 24             	sbb    (%esp),%edx
  801387:	89 d1                	mov    %edx,%ecx
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80138f:	29 da                	sub    %ebx,%edx
  801391:	19 ce                	sbb    %ecx,%esi
  801393:	89 f9                	mov    %edi,%ecx
  801395:	89 f0                	mov    %esi,%eax
  801397:	d3 e0                	shl    %cl,%eax
  801399:	89 e9                	mov    %ebp,%ecx
  80139b:	d3 ea                	shr    %cl,%edx
  80139d:	89 e9                	mov    %ebp,%ecx
  80139f:	d3 ee                	shr    %cl,%esi
  8013a1:	09 d0                	or     %edx,%eax
  8013a3:	89 f2                	mov    %esi,%edx
  8013a5:	83 c4 1c             	add    $0x1c,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    
  8013ad:	8d 76 00             	lea    0x0(%esi),%esi
  8013b0:	29 f9                	sub    %edi,%ecx
  8013b2:	19 d6                	sbb    %edx,%esi
  8013b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013bc:	e9 18 ff ff ff       	jmp    8012d9 <__umoddi3+0x69>
