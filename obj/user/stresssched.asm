
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
  800044:	e8 56 0d 00 00       	call   800d9f <fork>
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
  8000b8:	68 60 10 80 00       	push   $0x801060
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 88 10 80 00       	push   $0x801088
  8000c4:	e8 7c 00 00 00       	call   800145 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 20 80 00       	mov    0x802008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 9b 10 80 00       	push   $0x80109b
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
  800163:	68 c4 10 80 00       	push   $0x8010c4
  800168:	e8 b1 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016d:	83 c4 18             	add    $0x18,%esp
  800170:	53                   	push   %ebx
  800171:	ff 75 10             	pushl  0x10(%ebp)
  800174:	e8 54 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800179:	c7 04 24 b7 10 80 00 	movl   $0x8010b7,(%esp)
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
  800281:	e8 4a 0b 00 00       	call   800dd0 <__udivdi3>
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
  8002c4:	e8 37 0c 00 00       	call   800f00 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 e8 10 80 00 	movsbl 0x8010e8(%eax),%eax
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
  8003c8:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
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
  80048c:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	75 18                	jne    8004af <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800497:	50                   	push   %eax
  800498:	68 00 11 80 00       	push   $0x801100
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
  8004b0:	68 09 11 80 00       	push   $0x801109
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
  8004d4:	b8 f9 10 80 00       	mov    $0x8010f9,%eax
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
  800b99:	68 24 13 80 00       	push   $0x801324
  800b9e:	6a 23                	push   $0x23
  800ba0:	68 41 13 80 00       	push   $0x801341
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
  800c1a:	68 24 13 80 00       	push   $0x801324
  800c1f:	6a 23                	push   $0x23
  800c21:	68 41 13 80 00       	push   $0x801341
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
  800c5c:	68 24 13 80 00       	push   $0x801324
  800c61:	6a 23                	push   $0x23
  800c63:	68 41 13 80 00       	push   $0x801341
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
  800c9e:	68 24 13 80 00       	push   $0x801324
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 41 13 80 00       	push   $0x801341
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
  800ce0:	68 24 13 80 00       	push   $0x801324
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 41 13 80 00       	push   $0x801341
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
  800d22:	68 24 13 80 00       	push   $0x801324
  800d27:	6a 23                	push   $0x23
  800d29:	68 41 13 80 00       	push   $0x801341
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
  800d86:	68 24 13 80 00       	push   $0x801324
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 41 13 80 00       	push   $0x801341
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

00800d9f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800da5:	68 5b 13 80 00       	push   $0x80135b
  800daa:	6a 51                	push   $0x51
  800dac:	68 4f 13 80 00       	push   $0x80134f
  800db1:	e8 8f f3 ff ff       	call   800145 <_panic>

00800db6 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dbc:	68 5a 13 80 00       	push   $0x80135a
  800dc1:	6a 58                	push   $0x58
  800dc3:	68 4f 13 80 00       	push   $0x80134f
  800dc8:	e8 78 f3 ff ff       	call   800145 <_panic>
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
