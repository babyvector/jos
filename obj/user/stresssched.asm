
obj/user/stresssched.debug:     file format elf32-i386


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
  800038:	e8 7d 0b 00 00       	call   800bba <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 58 0f 00 00       	call   800fa1 <fork>
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
  80005c:	e8 78 0b 00 00       	call   800bd9 <sys_yield>
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
  800085:	e8 4f 0b 00 00       	call   800bd9 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
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
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 c0 22 80 00       	push   $0x8022c0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 e8 22 80 00       	push   $0x8022e8
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 fb 22 80 00       	push   $0x8022fb
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
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
  8000f8:	e8 bd 0a 00 00       	call   800bba <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 23 12 00 00       	call   801361 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 31 0a 00 00       	call   800b79 <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 5a 0a 00 00       	call   800bba <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 24 23 80 00       	push   $0x802324
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 43 27 80 00 	movl   $0x802743,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 79 09 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 1e 09 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 92 1d 00 00       	call   802020 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 7f 1e 00 00       	call   802150 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 47 23 80 00 	movsbl 0x802347(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 d3 03 00 00    	je     80074c <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 64 03 00 00    	ja     800731 <vprintfmt+0x3d4>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 39                	ja     800436 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800413:	eb 27                	jmp    80043c <vprintfmt+0xdf>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	0f 49 c8             	cmovns %eax,%ecx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	eb 8c                	jmp    8003b6 <vprintfmt+0x59>
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800434:	eb 80                	jmp    8003b6 <vprintfmt+0x59>
  800436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800439:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 89 70 ff ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800446:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800453:	e9 5e ff ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800458:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045e:	e9 53 ff ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 30                	pushl  (%eax)
  800472:	ff d6                	call   *%esi
			break;
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047a:	e9 04 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	99                   	cltd   
  80048b:	31 d0                	xor    %edx,%eax
  80048d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 5f 23 80 00       	push   $0x80235f
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 94 fe ff ff       	call   800340 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 cc fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	52                   	push   %edx
  8004b8:	68 89 28 80 00       	push   $0x802889
  8004bd:	53                   	push   %ebx
  8004be:	56                   	push   %esi
  8004bf:	e8 7c fe ff ff       	call   800340 <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 b4 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	b8 58 23 80 00       	mov    $0x802358,%eax
  8004e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	0f 8e 94 00 00 00    	jle    800582 <vprintfmt+0x225>
  8004ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f2:	0f 84 98 00 00 00    	je     800590 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 c8             	pushl  -0x38(%ebp)
  8004fe:	57                   	push   %edi
  8004ff:	e8 d0 02 00 00       	call   8007d4 <strnlen>
  800504:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800519:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0f                	jmp    80052c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	ff 75 e0             	pushl  -0x20(%ebp)
  800524:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f ed                	jg     80051d <vprintfmt+0x1c0>
  800530:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800533:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800536:	85 c9                	test   %ecx,%ecx
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	0f 49 c1             	cmovns %ecx,%eax
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	89 cb                	mov    %ecx,%ebx
  80054d:	eb 4d                	jmp    80059c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800553:	74 1b                	je     800570 <vprintfmt+0x213>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 10                	jbe    800570 <vprintfmt+0x213>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 0d                	jmp    80057d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	52                   	push   %edx
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	eb 1a                	jmp    80059c <vprintfmt+0x23f>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	0f be d0             	movsbl %al,%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 23                	je     8005cd <vprintfmt+0x270>
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	78 a1                	js     80054f <vprintfmt+0x1f2>
  8005ae:	83 ee 01             	sub    $0x1,%esi
  8005b1:	79 9c                	jns    80054f <vprintfmt+0x1f2>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	eb 18                	jmp    8005d5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 20                	push   $0x20
  8005c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 ef 01             	sub    $0x1,%edi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 08                	jmp    8005d5 <vprintfmt+0x278>
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	7f e4                	jg     8005bd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 a2 fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e1:	83 fa 01             	cmp    $0x1,%edx
  8005e4:	7e 16                	jle    8005fc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f7:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005fa:	eb 32                	jmp    80062e <vprintfmt+0x2d1>
	else if (lflag)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 18                	je     800618 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800616:	eb 16                	jmp    80062e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800626:	89 c1                	mov    %eax,%ecx
  800628:	c1 f9 1f             	sar    $0x1f,%ecx
  80062b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800631:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800634:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800637:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800643:	0f 89 b0 00 00 00    	jns    8006f9 <vprintfmt+0x39c>
				putch('-', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 2d                	push   $0x2d
  80064f:	ff d6                	call   *%esi
				num = -(long long) num;
  800651:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800654:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800657:	f7 d8                	neg    %eax
  800659:	83 d2 00             	adc    $0x0,%edx
  80065c:	f7 da                	neg    %edx
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800664:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800667:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066c:	e9 88 00 00 00       	jmp    8006f9 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 70 fc ff ff       	call   8002e9 <getuint>
  800679:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80067f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800684:	eb 73                	jmp    8006f9 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 5b fc ff ff       	call   8002e9 <getuint>
  80068e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800691:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 58                	push   $0x58
  80069a:	ff d6                	call   *%esi
			putch('X', putdat);
  80069c:	83 c4 08             	add    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 58                	push   $0x58
  8006a2:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a4:	83 c4 08             	add    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 58                	push   $0x58
  8006aa:	ff d6                	call   *%esi
			goto number;
  8006ac:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8006af:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006b4:	eb 43                	jmp    8006f9 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 30                	push   $0x30
  8006bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8006be:	83 c4 08             	add    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 78                	push   $0x78
  8006c4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006dc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e4:	eb 13                	jmp    8006f9 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e9:	e8 fb fb ff ff       	call   8002e9 <getuint>
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006f4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f9:	83 ec 0c             	sub    $0xc,%esp
  8006fc:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800700:	52                   	push   %edx
  800701:	ff 75 e0             	pushl  -0x20(%ebp)
  800704:	50                   	push   %eax
  800705:	ff 75 dc             	pushl  -0x24(%ebp)
  800708:	ff 75 d8             	pushl  -0x28(%ebp)
  80070b:	89 da                	mov    %ebx,%edx
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	e8 26 fb ff ff       	call   80023a <printnum>
			break;
  800714:	83 c4 20             	add    $0x20,%esp
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071a:	e9 64 fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	51                   	push   %ecx
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072c:	e9 52 fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 25                	push   $0x25
  800737:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 03                	jmp    800741 <vprintfmt+0x3e4>
  80073e:	83 ef 01             	sub    $0x1,%edi
  800741:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800745:	75 f7                	jne    80073e <vprintfmt+0x3e1>
  800747:	e9 37 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80074c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5f                   	pop    %edi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 18             	sub    $0x18,%esp
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800760:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800763:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800767:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800771:	85 c0                	test   %eax,%eax
  800773:	74 26                	je     80079b <vsnprintf+0x47>
  800775:	85 d2                	test   %edx,%edx
  800777:	7e 22                	jle    80079b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800779:	ff 75 14             	pushl  0x14(%ebp)
  80077c:	ff 75 10             	pushl  0x10(%ebp)
  80077f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800782:	50                   	push   %eax
  800783:	68 23 03 80 00       	push   $0x800323
  800788:	e8 d0 fb ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800790:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 05                	jmp    8007a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 9a ff ff ff       	call   800754 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	eb 03                	jmp    8007cc <strlen+0x10>
		n++;
  8007c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d0:	75 f7                	jne    8007c9 <strlen+0xd>
		n++;
	return n;
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e2:	eb 03                	jmp    8007e7 <strnlen+0x13>
		n++;
  8007e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	39 c2                	cmp    %eax,%edx
  8007e9:	74 08                	je     8007f3 <strnlen+0x1f>
  8007eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ef:	75 f3                	jne    8007e4 <strnlen+0x10>
  8007f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ef                	jne    800801 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081c:	53                   	push   %ebx
  80081d:	e8 9a ff ff ff       	call   8007bc <strlen>
  800822:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	01 d8                	add    %ebx,%eax
  80082a:	50                   	push   %eax
  80082b:	e8 c5 ff ff ff       	call   8007f5 <strcpy>
	return dst;
}
  800830:	89 d8                	mov    %ebx,%eax
  800832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 75 08             	mov    0x8(%ebp),%esi
  80083f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800842:	89 f3                	mov    %esi,%ebx
  800844:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800847:	89 f2                	mov    %esi,%edx
  800849:	eb 0f                	jmp    80085a <strncpy+0x23>
		*dst++ = *src;
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	0f b6 01             	movzbl (%ecx),%eax
  800851:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800854:	80 39 01             	cmpb   $0x1,(%ecx)
  800857:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085a:	39 da                	cmp    %ebx,%edx
  80085c:	75 ed                	jne    80084b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085e:	89 f0                	mov    %esi,%eax
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	8b 55 10             	mov    0x10(%ebp),%edx
  800872:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800874:	85 d2                	test   %edx,%edx
  800876:	74 21                	je     800899 <strlcpy+0x35>
  800878:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087c:	89 f2                	mov    %esi,%edx
  80087e:	eb 09                	jmp    800889 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	83 c1 01             	add    $0x1,%ecx
  800886:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800889:	39 c2                	cmp    %eax,%edx
  80088b:	74 09                	je     800896 <strlcpy+0x32>
  80088d:	0f b6 19             	movzbl (%ecx),%ebx
  800890:	84 db                	test   %bl,%bl
  800892:	75 ec                	jne    800880 <strlcpy+0x1c>
  800894:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800896:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800899:	29 f0                	sub    %esi,%eax
}
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a8:	eb 06                	jmp    8008b0 <strcmp+0x11>
		p++, q++;
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b0:	0f b6 01             	movzbl (%ecx),%eax
  8008b3:	84 c0                	test   %al,%al
  8008b5:	74 04                	je     8008bb <strcmp+0x1c>
  8008b7:	3a 02                	cmp    (%edx),%al
  8008b9:	74 ef                	je     8008aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 c0             	movzbl %al,%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d4:	eb 06                	jmp    8008dc <strncmp+0x17>
		n--, p++, q++;
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dc:	39 d8                	cmp    %ebx,%eax
  8008de:	74 15                	je     8008f5 <strncmp+0x30>
  8008e0:	0f b6 08             	movzbl (%eax),%ecx
  8008e3:	84 c9                	test   %cl,%cl
  8008e5:	74 04                	je     8008eb <strncmp+0x26>
  8008e7:	3a 0a                	cmp    (%edx),%cl
  8008e9:	74 eb                	je     8008d6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 12             	movzbl (%edx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
  8008f3:	eb 05                	jmp    8008fa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	eb 07                	jmp    800910 <strchr+0x13>
		if (*s == c)
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	74 0f                	je     80091c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	eb 03                	jmp    80092d <strfind+0xf>
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 04                	je     800938 <strfind+0x1a>
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f2                	jne    80092a <strfind+0xc>
			break;
	return (char *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800946:	85 c9                	test   %ecx,%ecx
  800948:	74 36                	je     800980 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800950:	75 28                	jne    80097a <memset+0x40>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 23                	jne    80097a <memset+0x40>
		c &= 0xFF;
  800957:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095b:	89 d3                	mov    %edx,%ebx
  80095d:	c1 e3 08             	shl    $0x8,%ebx
  800960:	89 d6                	mov    %edx,%esi
  800962:	c1 e6 18             	shl    $0x18,%esi
  800965:	89 d0                	mov    %edx,%eax
  800967:	c1 e0 10             	shl    $0x10,%eax
  80096a:	09 f0                	or     %esi,%eax
  80096c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	09 d0                	or     %edx,%eax
  800972:	c1 e9 02             	shr    $0x2,%ecx
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 06                	jmp    800980 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800995:	39 c6                	cmp    %eax,%esi
  800997:	73 35                	jae    8009ce <memmove+0x47>
  800999:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099c:	39 d0                	cmp    %edx,%eax
  80099e:	73 2e                	jae    8009ce <memmove+0x47>
		s += n;
		d += n;
  8009a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	89 d6                	mov    %edx,%esi
  8009a5:	09 fe                	or     %edi,%esi
  8009a7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ad:	75 13                	jne    8009c2 <memmove+0x3b>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 0e                	jne    8009c2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b4:	83 ef 04             	sub    $0x4,%edi
  8009b7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
  8009bd:	fd                   	std    
  8009be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c0:	eb 09                	jmp    8009cb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c2:	83 ef 01             	sub    $0x1,%edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 1d                	jmp    8009eb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 f2                	mov    %esi,%edx
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	f6 c2 03             	test   $0x3,%dl
  8009d5:	75 0f                	jne    8009e6 <memmove+0x5f>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 0a                	jne    8009e6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
  8009df:	89 c7                	mov    %eax,%edi
  8009e1:	fc                   	cld    
  8009e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e4:	eb 05                	jmp    8009eb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f2:	ff 75 10             	pushl  0x10(%ebp)
  8009f5:	ff 75 0c             	pushl  0xc(%ebp)
  8009f8:	ff 75 08             	pushl  0x8(%ebp)
  8009fb:	e8 87 ff ff ff       	call   800987 <memmove>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 c6                	mov    %eax,%esi
  800a0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a12:	eb 1a                	jmp    800a2e <memcmp+0x2c>
		if (*s1 != *s2)
  800a14:	0f b6 08             	movzbl (%eax),%ecx
  800a17:	0f b6 1a             	movzbl (%edx),%ebx
  800a1a:	38 d9                	cmp    %bl,%cl
  800a1c:	74 0a                	je     800a28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1e:	0f b6 c1             	movzbl %cl,%eax
  800a21:	0f b6 db             	movzbl %bl,%ebx
  800a24:	29 d8                	sub    %ebx,%eax
  800a26:	eb 0f                	jmp    800a37 <memcmp+0x35>
		s1++, s2++;
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	39 f0                	cmp    %esi,%eax
  800a30:	75 e2                	jne    800a14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a42:	89 c1                	mov    %eax,%ecx
  800a44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4b:	eb 0a                	jmp    800a57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	39 da                	cmp    %ebx,%edx
  800a52:	74 07                	je     800a5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a54:	83 c0 01             	add    $0x1,%eax
  800a57:	39 c8                	cmp    %ecx,%eax
  800a59:	72 f2                	jb     800a4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6a:	eb 03                	jmp    800a6f <strtol+0x11>
		s++;
  800a6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	0f b6 01             	movzbl (%ecx),%eax
  800a72:	3c 20                	cmp    $0x20,%al
  800a74:	74 f6                	je     800a6c <strtol+0xe>
  800a76:	3c 09                	cmp    $0x9,%al
  800a78:	74 f2                	je     800a6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7a:	3c 2b                	cmp    $0x2b,%al
  800a7c:	75 0a                	jne    800a88 <strtol+0x2a>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
  800a86:	eb 11                	jmp    800a99 <strtol+0x3b>
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 08                	jne    800a99 <strtol+0x3b>
		s++, neg = 1;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9f:	75 15                	jne    800ab6 <strtol+0x58>
  800aa1:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa4:	75 10                	jne    800ab6 <strtol+0x58>
  800aa6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aaa:	75 7c                	jne    800b28 <strtol+0xca>
		s += 2, base = 16;
  800aac:	83 c1 02             	add    $0x2,%ecx
  800aaf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab4:	eb 16                	jmp    800acc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	75 12                	jne    800acc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac2:	75 08                	jne    800acc <strtol+0x6e>
		s++, base = 8;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad4:	0f b6 11             	movzbl (%ecx),%edx
  800ad7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ada:	89 f3                	mov    %esi,%ebx
  800adc:	80 fb 09             	cmp    $0x9,%bl
  800adf:	77 08                	ja     800ae9 <strtol+0x8b>
			dig = *s - '0';
  800ae1:	0f be d2             	movsbl %dl,%edx
  800ae4:	83 ea 30             	sub    $0x30,%edx
  800ae7:	eb 22                	jmp    800b0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 19             	cmp    $0x19,%bl
  800af1:	77 08                	ja     800afb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 57             	sub    $0x57,%edx
  800af9:	eb 10                	jmp    800b0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800afb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 16                	ja     800b1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0e:	7d 0b                	jge    800b1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b10:	83 c1 01             	add    $0x1,%ecx
  800b13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b19:	eb b9                	jmp    800ad4 <strtol+0x76>

	if (endptr)
  800b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1f:	74 0d                	je     800b2e <strtol+0xd0>
		*endptr = (char *) s;
  800b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b24:	89 0e                	mov    %ecx,(%esi)
  800b26:	eb 06                	jmp    800b2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	74 98                	je     800ac4 <strtol+0x66>
  800b2c:	eb 9e                	jmp    800acc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	f7 da                	neg    %edx
  800b32:	85 ff                	test   %edi,%edi
  800b34:	0f 45 c2             	cmovne %edx,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	89 c6                	mov    %eax,%esi
  800b53:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b87:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	89 cf                	mov    %ecx,%edi
  800b93:	89 ce                	mov    %ecx,%esi
  800b95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 17                	jle    800bb2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 3f 26 80 00       	push   $0x80263f
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 5c 26 80 00       	push   $0x80265c
  800bad:	e8 9b f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_yield>:

void
sys_yield(void)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be9:	89 d1                	mov    %edx,%ecx
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 d7                	mov    %edx,%edi
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c01:	be 00 00 00 00       	mov    $0x0,%esi
  800c06:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c14:	89 f7                	mov    %esi,%edi
  800c16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 04                	push   $0x4
  800c22:	68 3f 26 80 00       	push   $0x80263f
  800c27:	6a 23                	push   $0x23
  800c29:	68 5c 26 80 00       	push   $0x80265c
  800c2e:	e8 1a f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c44:	b8 05 00 00 00       	mov    $0x5,%eax
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 75 18             	mov    0x18(%ebp),%esi
  800c58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 05                	push   $0x5
  800c64:	68 3f 26 80 00       	push   $0x80263f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 5c 26 80 00       	push   $0x80265c
  800c70:	e8 d8 f4 ff ff       	call   80014d <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c8b:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c9e:	7e 17                	jle    800cb7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 3f 26 80 00       	push   $0x80263f
  800cab:	6a 23                	push   $0x23
  800cad:	68 5c 26 80 00       	push   $0x80265c
  800cb2:	e8 96 f4 ff ff       	call   80014d <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ccd:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800ce0:	7e 17                	jle    800cf9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 3f 26 80 00       	push   $0x80263f
  800ced:	6a 23                	push   $0x23
  800cef:	68 5c 26 80 00       	push   $0x80265c
  800cf4:	e8 54 f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 df                	mov    %ebx,%edi
  800d1c:	89 de                	mov    %ebx,%esi
  800d1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 17                	jle    800d3b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 09                	push   $0x9
  800d2a:	68 3f 26 80 00       	push   $0x80263f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 5c 26 80 00       	push   $0x80265c
  800d36:	e8 12 f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0a                	push   $0xa
  800d6c:	68 3f 26 80 00       	push   $0x80263f
  800d71:	6a 23                	push   $0x23
  800d73:	68 5c 26 80 00       	push   $0x80265c
  800d78:	e8 d0 f3 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d8b:	be 00 00 00 00       	mov    $0x0,%esi
  800d90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800db1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 cb                	mov    %ecx,%ebx
  800dc0:	89 cf                	mov    %ecx,%edi
  800dc2:	89 ce                	mov    %ecx,%esi
  800dc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 17                	jle    800de1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0d                	push   $0xd
  800dd0:	68 3f 26 80 00       	push   $0x80263f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 5c 26 80 00       	push   $0x80265c
  800ddc:	e8 6c f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df1:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800df3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800df7:	74 11                	je     800e0a <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800df9:	89 d8                	mov    %ebx,%eax
  800dfb:	c1 e8 0c             	shr    $0xc,%eax
  800dfe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800e05:	f6 c4 08             	test   $0x8,%ah
  800e08:	75 14                	jne    800e1e <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 6a 26 80 00       	push   $0x80266a
  800e12:	6a 21                	push   $0x21
  800e14:	68 80 26 80 00       	push   $0x802680
  800e19:	e8 2f f3 ff ff       	call   80014d <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800e1e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e24:	e8 91 fd ff ff       	call   800bba <sys_getenvid>
  800e29:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	6a 07                	push   $0x7
  800e30:	68 00 f0 7f 00       	push   $0x7ff000
  800e35:	50                   	push   %eax
  800e36:	e8 bd fd ff ff       	call   800bf8 <sys_page_alloc>
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	79 14                	jns    800e56 <pgfault+0x6d>
		panic("sys_page_alloc");
  800e42:	83 ec 04             	sub    $0x4,%esp
  800e45:	68 8b 26 80 00       	push   $0x80268b
  800e4a:	6a 30                	push   $0x30
  800e4c:	68 80 26 80 00       	push   $0x802680
  800e51:	e8 f7 f2 ff ff       	call   80014d <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800e56:	83 ec 04             	sub    $0x4,%esp
  800e59:	68 00 10 00 00       	push   $0x1000
  800e5e:	53                   	push   %ebx
  800e5f:	68 00 f0 7f 00       	push   $0x7ff000
  800e64:	e8 86 fb ff ff       	call   8009ef <memcpy>
	retv = sys_page_unmap(envid, addr);
  800e69:	83 c4 08             	add    $0x8,%esp
  800e6c:	53                   	push   %ebx
  800e6d:	56                   	push   %esi
  800e6e:	e8 0a fe ff ff       	call   800c7d <sys_page_unmap>
	if(retv < 0){
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	79 12                	jns    800e8c <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800e7a:	50                   	push   %eax
  800e7b:	68 78 27 80 00       	push   $0x802778
  800e80:	6a 35                	push   $0x35
  800e82:	68 80 26 80 00       	push   $0x802680
  800e87:	e8 c1 f2 ff ff       	call   80014d <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	6a 07                	push   $0x7
  800e91:	53                   	push   %ebx
  800e92:	56                   	push   %esi
  800e93:	68 00 f0 7f 00       	push   $0x7ff000
  800e98:	56                   	push   %esi
  800e99:	e8 9d fd ff ff       	call   800c3b <sys_page_map>
	if(retv < 0){
  800e9e:	83 c4 20             	add    $0x20,%esp
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	79 14                	jns    800eb9 <pgfault+0xd0>
		panic("sys_page_map");
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	68 9a 26 80 00       	push   $0x80269a
  800ead:	6a 39                	push   $0x39
  800eaf:	68 80 26 80 00       	push   $0x802680
  800eb4:	e8 94 f2 ff ff       	call   80014d <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	68 00 f0 7f 00       	push   $0x7ff000
  800ec1:	56                   	push   %esi
  800ec2:	e8 b6 fd ff ff       	call   800c7d <sys_page_unmap>
	if(retv < 0){
  800ec7:	83 c4 10             	add    $0x10,%esp
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	79 14                	jns    800ee2 <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800ece:	83 ec 04             	sub    $0x4,%esp
  800ed1:	68 a7 26 80 00       	push   $0x8026a7
  800ed6:	6a 3d                	push   $0x3d
  800ed8:	68 80 26 80 00       	push   $0x802680
  800edd:	e8 6b f2 ff ff       	call   80014d <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800ee2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
  800eee:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800ef1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ef4:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800ef7:	83 ec 08             	sub    $0x8,%esp
  800efa:	53                   	push   %ebx
  800efb:	68 c4 26 80 00       	push   $0x8026c4
  800f00:	e8 21 f3 ff ff       	call   800226 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f05:	83 c4 0c             	add    $0xc,%esp
  800f08:	6a 07                	push   $0x7
  800f0a:	53                   	push   %ebx
  800f0b:	56                   	push   %esi
  800f0c:	e8 e7 fc ff ff       	call   800bf8 <sys_page_alloc>
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	79 15                	jns    800f2d <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800f18:	50                   	push   %eax
  800f19:	68 d7 26 80 00       	push   $0x8026d7
  800f1e:	68 90 00 00 00       	push   $0x90
  800f23:	68 80 26 80 00       	push   $0x802680
  800f28:	e8 20 f2 ff ff       	call   80014d <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800f2d:	83 ec 0c             	sub    $0xc,%esp
  800f30:	68 ea 26 80 00       	push   $0x8026ea
  800f35:	e8 ec f2 ff ff       	call   800226 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f3a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f41:	68 00 00 40 00       	push   $0x400000
  800f46:	6a 00                	push   $0x0
  800f48:	53                   	push   %ebx
  800f49:	56                   	push   %esi
  800f4a:	e8 ec fc ff ff       	call   800c3b <sys_page_map>
  800f4f:	83 c4 20             	add    $0x20,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	79 15                	jns    800f6b <dupagege+0x82>
                panic("sys_page_map: %e", r);
  800f56:	50                   	push   %eax
  800f57:	68 f2 26 80 00       	push   $0x8026f2
  800f5c:	68 94 00 00 00       	push   $0x94
  800f61:	68 80 26 80 00       	push   $0x802680
  800f66:	e8 e2 f1 ff ff       	call   80014d <_panic>
        cprintf("af_p_m.");
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	68 03 27 80 00       	push   $0x802703
  800f73:	e8 ae f2 ff ff       	call   800226 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  800f78:	83 c4 0c             	add    $0xc,%esp
  800f7b:	68 00 10 00 00       	push   $0x1000
  800f80:	53                   	push   %ebx
  800f81:	68 00 00 40 00       	push   $0x400000
  800f86:	e8 fc f9 ff ff       	call   800987 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  800f8b:	c7 04 24 0b 27 80 00 	movl   $0x80270b,(%esp)
  800f92:	e8 8f f2 ff ff       	call   800226 <cprintf>
}
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	57                   	push   %edi
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800faa:	68 e9 0d 80 00       	push   $0x800de9
  800faf:	e8 c5 0e 00 00       	call   801e79 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb4:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb9:	cd 30                	int    $0x30
  800fbb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fbe:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	79 17                	jns    800fdf <fork+0x3e>
		panic("sys_exofork failed.");
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	68 19 27 80 00       	push   $0x802719
  800fd0:	68 b7 00 00 00       	push   $0xb7
  800fd5:	68 80 26 80 00       	push   $0x802680
  800fda:	e8 6e f1 ff ff       	call   80014d <_panic>
  800fdf:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  800fe4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fe8:	75 21                	jne    80100b <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fea:	e8 cb fb ff ff       	call   800bba <sys_getenvid>
  800fef:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ff7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ffc:	a3 08 40 80 00       	mov    %eax,0x804008
//		cprintf("we are the child.\n");
		return 0;
  801001:	b8 00 00 00 00       	mov    $0x0,%eax
  801006:	e9 69 01 00 00       	jmp    801174 <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	c1 e8 16             	shr    $0x16,%eax
  801010:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  801017:	a8 01                	test   $0x1,%al
  801019:	0f 84 d6 00 00 00    	je     8010f5 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  80101f:	89 de                	mov    %ebx,%esi
  801021:	c1 ee 0c             	shr    $0xc,%esi
  801024:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  80102b:	a8 01                	test   $0x1,%al
  80102d:	0f 84 c2 00 00 00    	je     8010f5 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  801033:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  80103a:	89 f7                	mov    %esi,%edi
  80103c:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  80103f:	e8 76 fb ff ff       	call   800bba <sys_getenvid>
  801044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  801047:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80104e:	f6 c4 04             	test   $0x4,%ah
  801051:	74 1c                	je     80106f <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	68 07 0e 00 00       	push   $0xe07
  80105b:	57                   	push   %edi
  80105c:	ff 75 e0             	pushl  -0x20(%ebp)
  80105f:	57                   	push   %edi
  801060:	6a 00                	push   $0x0
  801062:	e8 d4 fb ff ff       	call   800c3b <sys_page_map>
  801067:	83 c4 20             	add    $0x20,%esp
  80106a:	e9 86 00 00 00       	jmp    8010f5 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  80106f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801076:	a8 02                	test   $0x2,%al
  801078:	75 0c                	jne    801086 <fork+0xe5>
  80107a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801081:	f6 c4 08             	test   $0x8,%ah
  801084:	74 5b                	je     8010e1 <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	68 05 08 00 00       	push   $0x805
  80108e:	57                   	push   %edi
  80108f:	ff 75 e0             	pushl  -0x20(%ebp)
  801092:	57                   	push   %edi
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	e8 a0 fb ff ff       	call   800c3b <sys_page_map>
  80109b:	83 c4 20             	add    $0x20,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 12                	jns    8010b4 <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  8010a2:	50                   	push   %eax
  8010a3:	68 9c 27 80 00       	push   $0x80279c
  8010a8:	6a 5f                	push   $0x5f
  8010aa:	68 80 26 80 00       	push   $0x802680
  8010af:	e8 99 f0 ff ff       	call   80014d <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	68 05 08 00 00       	push   $0x805
  8010bc:	57                   	push   %edi
  8010bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	57                   	push   %edi
  8010c2:	50                   	push   %eax
  8010c3:	e8 73 fb ff ff       	call   800c3b <sys_page_map>
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 26                	jns    8010f5 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  8010cf:	50                   	push   %eax
  8010d0:	68 c0 27 80 00       	push   $0x8027c0
  8010d5:	6a 64                	push   $0x64
  8010d7:	68 80 26 80 00       	push   $0x802680
  8010dc:	e8 6c f0 ff ff       	call   80014d <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	6a 05                	push   $0x5
  8010e6:	57                   	push   %edi
  8010e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8010ea:	57                   	push   %edi
  8010eb:	6a 00                	push   $0x0
  8010ed:	e8 49 fb ff ff       	call   800c3b <sys_page_map>
  8010f2:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8010f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010fb:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801101:	0f 85 04 ff ff ff    	jne    80100b <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	6a 07                	push   $0x7
  80110c:	68 00 f0 bf ee       	push   $0xeebff000
  801111:	ff 75 dc             	pushl  -0x24(%ebp)
  801114:	e8 df fa ff ff       	call   800bf8 <sys_page_alloc>
	if(retv < 0){
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	79 17                	jns    801137 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	68 2d 27 80 00       	push   $0x80272d
  801128:	68 cc 00 00 00       	push   $0xcc
  80112d:	68 80 26 80 00       	push   $0x802680
  801132:	e8 16 f0 ff ff       	call   80014d <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  801137:	83 ec 08             	sub    $0x8,%esp
  80113a:	68 de 1e 80 00       	push   $0x801ede
  80113f:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801142:	57                   	push   %edi
  801143:	e8 fb fb ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  801148:	83 c4 08             	add    $0x8,%esp
  80114b:	6a 02                	push   $0x2
  80114d:	57                   	push   %edi
  80114e:	e8 6c fb ff ff       	call   800cbf <sys_env_set_status>
	if(retv < 0){
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	79 17                	jns    801171 <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  80115a:	83 ec 04             	sub    $0x4,%esp
  80115d:	68 45 27 80 00       	push   $0x802745
  801162:	68 dd 00 00 00       	push   $0xdd
  801167:	68 80 26 80 00       	push   $0x802680
  80116c:	e8 dc ef ff ff       	call   80014d <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  801171:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  801174:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801177:	5b                   	pop    %ebx
  801178:	5e                   	pop    %esi
  801179:	5f                   	pop    %edi
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <sfork>:

// Challenge!
int
sfork(void)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801182:	68 61 27 80 00       	push   $0x802761
  801187:	68 e8 00 00 00       	push   $0xe8
  80118c:	68 80 26 80 00       	push   $0x802680
  801191:	e8 b7 ef ff ff       	call   80014d <_panic>

00801196 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801199:	8b 45 08             	mov    0x8(%ebp),%eax
  80119c:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a1:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ac:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	c1 ea 16             	shr    $0x16,%edx
  8011cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d4:	f6 c2 01             	test   $0x1,%dl
  8011d7:	74 11                	je     8011ea <fd_alloc+0x2d>
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	c1 ea 0c             	shr    $0xc,%edx
  8011de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e5:	f6 c2 01             	test   $0x1,%dl
  8011e8:	75 09                	jne    8011f3 <fd_alloc+0x36>
			*fd_store = fd;
  8011ea:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f1:	eb 17                	jmp    80120a <fd_alloc+0x4d>
  8011f3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011fd:	75 c9                	jne    8011c8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011ff:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801205:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801212:	83 f8 1f             	cmp    $0x1f,%eax
  801215:	77 36                	ja     80124d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801217:	c1 e0 0c             	shl    $0xc,%eax
  80121a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121f:	89 c2                	mov    %eax,%edx
  801221:	c1 ea 16             	shr    $0x16,%edx
  801224:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122b:	f6 c2 01             	test   $0x1,%dl
  80122e:	74 24                	je     801254 <fd_lookup+0x48>
  801230:	89 c2                	mov    %eax,%edx
  801232:	c1 ea 0c             	shr    $0xc,%edx
  801235:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123c:	f6 c2 01             	test   $0x1,%dl
  80123f:	74 1a                	je     80125b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801241:	8b 55 0c             	mov    0xc(%ebp),%edx
  801244:	89 02                	mov    %eax,(%edx)
	return 0;
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
  80124b:	eb 13                	jmp    801260 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801252:	eb 0c                	jmp    801260 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801259:	eb 05                	jmp    801260 <fd_lookup+0x54>
  80125b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126b:	ba 60 28 80 00       	mov    $0x802860,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801270:	eb 13                	jmp    801285 <dev_lookup+0x23>
  801272:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801275:	39 08                	cmp    %ecx,(%eax)
  801277:	75 0c                	jne    801285 <dev_lookup+0x23>
			*dev = devtab[i];
  801279:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80127e:	b8 00 00 00 00       	mov    $0x0,%eax
  801283:	eb 2e                	jmp    8012b3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801285:	8b 02                	mov    (%edx),%eax
  801287:	85 c0                	test   %eax,%eax
  801289:	75 e7                	jne    801272 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80128b:	a1 08 40 80 00       	mov    0x804008,%eax
  801290:	8b 40 48             	mov    0x48(%eax),%eax
  801293:	83 ec 04             	sub    $0x4,%esp
  801296:	51                   	push   %ecx
  801297:	50                   	push   %eax
  801298:	68 e4 27 80 00       	push   $0x8027e4
  80129d:	e8 84 ef ff ff       	call   800226 <cprintf>
	*dev = 0;
  8012a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 10             	sub    $0x10,%esp
  8012bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012cd:	c1 e8 0c             	shr    $0xc,%eax
  8012d0:	50                   	push   %eax
  8012d1:	e8 36 ff ff ff       	call   80120c <fd_lookup>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 05                	js     8012e2 <fd_close+0x2d>
	    || fd != fd2)
  8012dd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012e0:	74 0c                	je     8012ee <fd_close+0x39>
		return (must_exist ? r : 0);
  8012e2:	84 db                	test   %bl,%bl
  8012e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e9:	0f 44 c2             	cmove  %edx,%eax
  8012ec:	eb 41                	jmp    80132f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	ff 36                	pushl  (%esi)
  8012f7:	e8 66 ff ff ff       	call   801262 <dev_lookup>
  8012fc:	89 c3                	mov    %eax,%ebx
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 1a                	js     80131f <fd_close+0x6a>
		if (dev->dev_close)
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80130b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801310:	85 c0                	test   %eax,%eax
  801312:	74 0b                	je     80131f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801314:	83 ec 0c             	sub    $0xc,%esp
  801317:	56                   	push   %esi
  801318:	ff d0                	call   *%eax
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	56                   	push   %esi
  801323:	6a 00                	push   $0x0
  801325:	e8 53 f9 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	89 d8                	mov    %ebx,%eax
}
  80132f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	ff 75 08             	pushl  0x8(%ebp)
  801343:	e8 c4 fe ff ff       	call   80120c <fd_lookup>
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 10                	js     80135f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	6a 01                	push   $0x1
  801354:	ff 75 f4             	pushl  -0xc(%ebp)
  801357:	e8 59 ff ff ff       	call   8012b5 <fd_close>
  80135c:	83 c4 10             	add    $0x10,%esp
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <close_all>:

void
close_all(void)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	53                   	push   %ebx
  801365:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801368:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	53                   	push   %ebx
  801371:	e8 c0 ff ff ff       	call   801336 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801376:	83 c3 01             	add    $0x1,%ebx
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	83 fb 20             	cmp    $0x20,%ebx
  80137f:	75 ec                	jne    80136d <close_all+0xc>
		close(i);
}
  801381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	57                   	push   %edi
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	83 ec 2c             	sub    $0x2c,%esp
  80138f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801392:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	ff 75 08             	pushl  0x8(%ebp)
  801399:	e8 6e fe ff ff       	call   80120c <fd_lookup>
  80139e:	83 c4 08             	add    $0x8,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	0f 88 c1 00 00 00    	js     80146a <dup+0xe4>
		return r;
	close(newfdnum);
  8013a9:	83 ec 0c             	sub    $0xc,%esp
  8013ac:	56                   	push   %esi
  8013ad:	e8 84 ff ff ff       	call   801336 <close>

	newfd = INDEX2FD(newfdnum);
  8013b2:	89 f3                	mov    %esi,%ebx
  8013b4:	c1 e3 0c             	shl    $0xc,%ebx
  8013b7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013bd:	83 c4 04             	add    $0x4,%esp
  8013c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c3:	e8 de fd ff ff       	call   8011a6 <fd2data>
  8013c8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ca:	89 1c 24             	mov    %ebx,(%esp)
  8013cd:	e8 d4 fd ff ff       	call   8011a6 <fd2data>
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d8:	89 f8                	mov    %edi,%eax
  8013da:	c1 e8 16             	shr    $0x16,%eax
  8013dd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e4:	a8 01                	test   $0x1,%al
  8013e6:	74 37                	je     80141f <dup+0x99>
  8013e8:	89 f8                	mov    %edi,%eax
  8013ea:	c1 e8 0c             	shr    $0xc,%eax
  8013ed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f4:	f6 c2 01             	test   $0x1,%dl
  8013f7:	74 26                	je     80141f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801400:	83 ec 0c             	sub    $0xc,%esp
  801403:	25 07 0e 00 00       	and    $0xe07,%eax
  801408:	50                   	push   %eax
  801409:	ff 75 d4             	pushl  -0x2c(%ebp)
  80140c:	6a 00                	push   $0x0
  80140e:	57                   	push   %edi
  80140f:	6a 00                	push   $0x0
  801411:	e8 25 f8 ff ff       	call   800c3b <sys_page_map>
  801416:	89 c7                	mov    %eax,%edi
  801418:	83 c4 20             	add    $0x20,%esp
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 2e                	js     80144d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801422:	89 d0                	mov    %edx,%eax
  801424:	c1 e8 0c             	shr    $0xc,%eax
  801427:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	25 07 0e 00 00       	and    $0xe07,%eax
  801436:	50                   	push   %eax
  801437:	53                   	push   %ebx
  801438:	6a 00                	push   $0x0
  80143a:	52                   	push   %edx
  80143b:	6a 00                	push   $0x0
  80143d:	e8 f9 f7 ff ff       	call   800c3b <sys_page_map>
  801442:	89 c7                	mov    %eax,%edi
  801444:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801447:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801449:	85 ff                	test   %edi,%edi
  80144b:	79 1d                	jns    80146a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	53                   	push   %ebx
  801451:	6a 00                	push   $0x0
  801453:	e8 25 f8 ff ff       	call   800c7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145e:	6a 00                	push   $0x0
  801460:	e8 18 f8 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	89 f8                	mov    %edi,%eax
}
  80146a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5f                   	pop    %edi
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    

00801472 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	53                   	push   %ebx
  801476:	83 ec 14             	sub    $0x14,%esp
  801479:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	53                   	push   %ebx
  801481:	e8 86 fd ff ff       	call   80120c <fd_lookup>
  801486:	83 c4 08             	add    $0x8,%esp
  801489:	89 c2                	mov    %eax,%edx
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 6d                	js     8014fc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801499:	ff 30                	pushl  (%eax)
  80149b:	e8 c2 fd ff ff       	call   801262 <dev_lookup>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 4c                	js     8014f3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014aa:	8b 42 08             	mov    0x8(%edx),%eax
  8014ad:	83 e0 03             	and    $0x3,%eax
  8014b0:	83 f8 01             	cmp    $0x1,%eax
  8014b3:	75 21                	jne    8014d6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ba:	8b 40 48             	mov    0x48(%eax),%eax
  8014bd:	83 ec 04             	sub    $0x4,%esp
  8014c0:	53                   	push   %ebx
  8014c1:	50                   	push   %eax
  8014c2:	68 25 28 80 00       	push   $0x802825
  8014c7:	e8 5a ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d4:	eb 26                	jmp    8014fc <read+0x8a>
	}
	if (!dev->dev_read)
  8014d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d9:	8b 40 08             	mov    0x8(%eax),%eax
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	74 17                	je     8014f7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e0:	83 ec 04             	sub    $0x4,%esp
  8014e3:	ff 75 10             	pushl  0x10(%ebp)
  8014e6:	ff 75 0c             	pushl  0xc(%ebp)
  8014e9:	52                   	push   %edx
  8014ea:	ff d0                	call   *%eax
  8014ec:	89 c2                	mov    %eax,%edx
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	eb 09                	jmp    8014fc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	89 c2                	mov    %eax,%edx
  8014f5:	eb 05                	jmp    8014fc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014fc:	89 d0                	mov    %edx,%eax
  8014fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	57                   	push   %edi
  801507:	56                   	push   %esi
  801508:	53                   	push   %ebx
  801509:	83 ec 0c             	sub    $0xc,%esp
  80150c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801512:	bb 00 00 00 00       	mov    $0x0,%ebx
  801517:	eb 21                	jmp    80153a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801519:	83 ec 04             	sub    $0x4,%esp
  80151c:	89 f0                	mov    %esi,%eax
  80151e:	29 d8                	sub    %ebx,%eax
  801520:	50                   	push   %eax
  801521:	89 d8                	mov    %ebx,%eax
  801523:	03 45 0c             	add    0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	57                   	push   %edi
  801528:	e8 45 ff ff ff       	call   801472 <read>
		if (m < 0)
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 10                	js     801544 <readn+0x41>
			return m;
		if (m == 0)
  801534:	85 c0                	test   %eax,%eax
  801536:	74 0a                	je     801542 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801538:	01 c3                	add    %eax,%ebx
  80153a:	39 f3                	cmp    %esi,%ebx
  80153c:	72 db                	jb     801519 <readn+0x16>
  80153e:	89 d8                	mov    %ebx,%eax
  801540:	eb 02                	jmp    801544 <readn+0x41>
  801542:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801544:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801547:	5b                   	pop    %ebx
  801548:	5e                   	pop    %esi
  801549:	5f                   	pop    %edi
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	53                   	push   %ebx
  801550:	83 ec 14             	sub    $0x14,%esp
  801553:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801556:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801559:	50                   	push   %eax
  80155a:	53                   	push   %ebx
  80155b:	e8 ac fc ff ff       	call   80120c <fd_lookup>
  801560:	83 c4 08             	add    $0x8,%esp
  801563:	89 c2                	mov    %eax,%edx
  801565:	85 c0                	test   %eax,%eax
  801567:	78 68                	js     8015d1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156f:	50                   	push   %eax
  801570:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801573:	ff 30                	pushl  (%eax)
  801575:	e8 e8 fc ff ff       	call   801262 <dev_lookup>
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 47                	js     8015c8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801581:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801584:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801588:	75 21                	jne    8015ab <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80158a:	a1 08 40 80 00       	mov    0x804008,%eax
  80158f:	8b 40 48             	mov    0x48(%eax),%eax
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	53                   	push   %ebx
  801596:	50                   	push   %eax
  801597:	68 41 28 80 00       	push   $0x802841
  80159c:	e8 85 ec ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a9:	eb 26                	jmp    8015d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b1:	85 d2                	test   %edx,%edx
  8015b3:	74 17                	je     8015cc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b5:	83 ec 04             	sub    $0x4,%esp
  8015b8:	ff 75 10             	pushl  0x10(%ebp)
  8015bb:	ff 75 0c             	pushl  0xc(%ebp)
  8015be:	50                   	push   %eax
  8015bf:	ff d2                	call   *%edx
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	eb 09                	jmp    8015d1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c8:	89 c2                	mov    %eax,%edx
  8015ca:	eb 05                	jmp    8015d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015d1:	89 d0                	mov    %edx,%eax
  8015d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015de:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	ff 75 08             	pushl  0x8(%ebp)
  8015e5:	e8 22 fc ff ff       	call   80120c <fd_lookup>
  8015ea:	83 c4 08             	add    $0x8,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 0e                	js     8015ff <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	53                   	push   %ebx
  801605:	83 ec 14             	sub    $0x14,%esp
  801608:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	53                   	push   %ebx
  801610:	e8 f7 fb ff ff       	call   80120c <fd_lookup>
  801615:	83 c4 08             	add    $0x8,%esp
  801618:	89 c2                	mov    %eax,%edx
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 65                	js     801683 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801628:	ff 30                	pushl  (%eax)
  80162a:	e8 33 fc ff ff       	call   801262 <dev_lookup>
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 44                	js     80167a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801636:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801639:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163d:	75 21                	jne    801660 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80163f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801644:	8b 40 48             	mov    0x48(%eax),%eax
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	53                   	push   %ebx
  80164b:	50                   	push   %eax
  80164c:	68 04 28 80 00       	push   $0x802804
  801651:	e8 d0 eb ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165e:	eb 23                	jmp    801683 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801660:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801663:	8b 52 18             	mov    0x18(%edx),%edx
  801666:	85 d2                	test   %edx,%edx
  801668:	74 14                	je     80167e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	ff 75 0c             	pushl  0xc(%ebp)
  801670:	50                   	push   %eax
  801671:	ff d2                	call   *%edx
  801673:	89 c2                	mov    %eax,%edx
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	eb 09                	jmp    801683 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	eb 05                	jmp    801683 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80167e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801683:	89 d0                	mov    %edx,%eax
  801685:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	53                   	push   %ebx
  80168e:	83 ec 14             	sub    $0x14,%esp
  801691:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801694:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	ff 75 08             	pushl  0x8(%ebp)
  80169b:	e8 6c fb ff ff       	call   80120c <fd_lookup>
  8016a0:	83 c4 08             	add    $0x8,%esp
  8016a3:	89 c2                	mov    %eax,%edx
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 58                	js     801701 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b3:	ff 30                	pushl  (%eax)
  8016b5:	e8 a8 fb ff ff       	call   801262 <dev_lookup>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 37                	js     8016f8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c8:	74 32                	je     8016fc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ca:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016cd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d4:	00 00 00 
	stat->st_isdir = 0;
  8016d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016de:	00 00 00 
	stat->st_dev = dev;
  8016e1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	53                   	push   %ebx
  8016eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ee:	ff 50 14             	call   *0x14(%eax)
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	eb 09                	jmp    801701 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f8:	89 c2                	mov    %eax,%edx
  8016fa:	eb 05                	jmp    801701 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801701:	89 d0                	mov    %edx,%eax
  801703:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	6a 00                	push   $0x0
  801712:	ff 75 08             	pushl  0x8(%ebp)
  801715:	e8 dc 01 00 00       	call   8018f6 <open>
  80171a:	89 c3                	mov    %eax,%ebx
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 1b                	js     80173e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	ff 75 0c             	pushl  0xc(%ebp)
  801729:	50                   	push   %eax
  80172a:	e8 5b ff ff ff       	call   80168a <fstat>
  80172f:	89 c6                	mov    %eax,%esi
	close(fd);
  801731:	89 1c 24             	mov    %ebx,(%esp)
  801734:	e8 fd fb ff ff       	call   801336 <close>
	return r;
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	89 f0                	mov    %esi,%eax
}
  80173e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	89 c6                	mov    %eax,%esi
  80174c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801755:	75 12                	jne    801769 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	6a 01                	push   $0x1
  80175c:	e8 41 08 00 00       	call   801fa2 <ipc_find_env>
  801761:	a3 00 40 80 00       	mov    %eax,0x804000
  801766:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801769:	6a 07                	push   $0x7
  80176b:	68 00 50 80 00       	push   $0x805000
  801770:	56                   	push   %esi
  801771:	ff 35 00 40 80 00    	pushl  0x804000
  801777:	e8 e3 07 00 00       	call   801f5f <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  80177c:	83 c4 0c             	add    $0xc,%esp
  80177f:	6a 00                	push   $0x0
  801781:	53                   	push   %ebx
  801782:	6a 00                	push   $0x0
  801784:	e8 79 07 00 00       	call   801f02 <ipc_recv>
}
  801789:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
  801799:	8b 40 0c             	mov    0xc(%eax),%eax
  80179c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b3:	e8 8d ff ff ff       	call   801745 <fsipc>
}
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d5:	e8 6b ff ff ff       	call   801745 <fsipc>
}
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 04             	sub    $0x4,%esp
  8017e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ec:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fb:	e8 45 ff ff ff       	call   801745 <fsipc>
  801800:	85 c0                	test   %eax,%eax
  801802:	78 2c                	js     801830 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801804:	83 ec 08             	sub    $0x8,%esp
  801807:	68 00 50 80 00       	push   $0x805000
  80180c:	53                   	push   %ebx
  80180d:	e8 e3 ef ff ff       	call   8007f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801812:	a1 80 50 80 00       	mov    0x805080,%eax
  801817:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181d:	a1 84 50 80 00       	mov    0x805084,%eax
  801822:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	83 ec 0c             	sub    $0xc,%esp
  80183b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80183e:	8b 55 08             	mov    0x8(%ebp),%edx
  801841:	8b 52 0c             	mov    0xc(%edx),%edx
  801844:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80184a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80184f:	50                   	push   %eax
  801850:	ff 75 0c             	pushl  0xc(%ebp)
  801853:	68 08 50 80 00       	push   $0x805008
  801858:	e8 2a f1 ff ff       	call   800987 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80185d:	ba 00 00 00 00       	mov    $0x0,%edx
  801862:	b8 04 00 00 00       	mov    $0x4,%eax
  801867:	e8 d9 fe ff ff       	call   801745 <fsipc>
	//panic("devfile_write not implemented");
}
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	56                   	push   %esi
  801872:	53                   	push   %ebx
  801873:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 40 0c             	mov    0xc(%eax),%eax
  80187c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801881:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801887:	ba 00 00 00 00       	mov    $0x0,%edx
  80188c:	b8 03 00 00 00       	mov    $0x3,%eax
  801891:	e8 af fe ff ff       	call   801745 <fsipc>
  801896:	89 c3                	mov    %eax,%ebx
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 51                	js     8018ed <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80189c:	39 c6                	cmp    %eax,%esi
  80189e:	73 19                	jae    8018b9 <devfile_read+0x4b>
  8018a0:	68 70 28 80 00       	push   $0x802870
  8018a5:	68 77 28 80 00       	push   $0x802877
  8018aa:	68 80 00 00 00       	push   $0x80
  8018af:	68 8c 28 80 00       	push   $0x80288c
  8018b4:	e8 94 e8 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  8018b9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018be:	7e 19                	jle    8018d9 <devfile_read+0x6b>
  8018c0:	68 97 28 80 00       	push   $0x802897
  8018c5:	68 77 28 80 00       	push   $0x802877
  8018ca:	68 81 00 00 00       	push   $0x81
  8018cf:	68 8c 28 80 00       	push   $0x80288c
  8018d4:	e8 74 e8 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d9:	83 ec 04             	sub    $0x4,%esp
  8018dc:	50                   	push   %eax
  8018dd:	68 00 50 80 00       	push   $0x805000
  8018e2:	ff 75 0c             	pushl  0xc(%ebp)
  8018e5:	e8 9d f0 ff ff       	call   800987 <memmove>
	return r;
  8018ea:	83 c4 10             	add    $0x10,%esp
}
  8018ed:	89 d8                	mov    %ebx,%eax
  8018ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f2:	5b                   	pop    %ebx
  8018f3:	5e                   	pop    %esi
  8018f4:	5d                   	pop    %ebp
  8018f5:	c3                   	ret    

008018f6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	53                   	push   %ebx
  8018fa:	83 ec 20             	sub    $0x20,%esp
  8018fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801900:	53                   	push   %ebx
  801901:	e8 b6 ee ff ff       	call   8007bc <strlen>
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190e:	7f 67                	jg     801977 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801910:	83 ec 0c             	sub    $0xc,%esp
  801913:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801916:	50                   	push   %eax
  801917:	e8 a1 f8 ff ff       	call   8011bd <fd_alloc>
  80191c:	83 c4 10             	add    $0x10,%esp
		return r;
  80191f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801921:	85 c0                	test   %eax,%eax
  801923:	78 57                	js     80197c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801925:	83 ec 08             	sub    $0x8,%esp
  801928:	53                   	push   %ebx
  801929:	68 00 50 80 00       	push   $0x805000
  80192e:	e8 c2 ee ff ff       	call   8007f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801933:	8b 45 0c             	mov    0xc(%ebp),%eax
  801936:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193e:	b8 01 00 00 00       	mov    $0x1,%eax
  801943:	e8 fd fd ff ff       	call   801745 <fsipc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	79 14                	jns    801965 <open+0x6f>
		
		fd_close(fd, 0);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	6a 00                	push   $0x0
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	e8 57 f9 ff ff       	call   8012b5 <fd_close>
		return r;
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	89 da                	mov    %ebx,%edx
  801963:	eb 17                	jmp    80197c <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	ff 75 f4             	pushl  -0xc(%ebp)
  80196b:	e8 26 f8 ff ff       	call   801196 <fd2num>
  801970:	89 c2                	mov    %eax,%edx
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	eb 05                	jmp    80197c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801977:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  80197c:	89 d0                	mov    %edx,%eax
  80197e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801989:	ba 00 00 00 00       	mov    $0x0,%edx
  80198e:	b8 08 00 00 00       	mov    $0x8,%eax
  801993:	e8 ad fd ff ff       	call   801745 <fsipc>
}
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	56                   	push   %esi
  80199e:	53                   	push   %ebx
  80199f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019a2:	83 ec 0c             	sub    $0xc,%esp
  8019a5:	ff 75 08             	pushl  0x8(%ebp)
  8019a8:	e8 f9 f7 ff ff       	call   8011a6 <fd2data>
  8019ad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019af:	83 c4 08             	add    $0x8,%esp
  8019b2:	68 a3 28 80 00       	push   $0x8028a3
  8019b7:	53                   	push   %ebx
  8019b8:	e8 38 ee ff ff       	call   8007f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019bd:	8b 46 04             	mov    0x4(%esi),%eax
  8019c0:	2b 06                	sub    (%esi),%eax
  8019c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019cf:	00 00 00 
	stat->st_dev = &devpipe;
  8019d2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019d9:	30 80 00 
	return 0;
}
  8019dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5e                   	pop    %esi
  8019e6:	5d                   	pop    %ebp
  8019e7:	c3                   	ret    

008019e8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 0c             	sub    $0xc,%esp
  8019ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019f2:	53                   	push   %ebx
  8019f3:	6a 00                	push   $0x0
  8019f5:	e8 83 f2 ff ff       	call   800c7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019fa:	89 1c 24             	mov    %ebx,(%esp)
  8019fd:	e8 a4 f7 ff ff       	call   8011a6 <fd2data>
  801a02:	83 c4 08             	add    $0x8,%esp
  801a05:	50                   	push   %eax
  801a06:	6a 00                	push   $0x0
  801a08:	e8 70 f2 ff ff       	call   800c7d <sys_page_unmap>
}
  801a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	57                   	push   %edi
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	83 ec 1c             	sub    $0x1c,%esp
  801a1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a1e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a20:	a1 08 40 80 00       	mov    0x804008,%eax
  801a25:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a28:	83 ec 0c             	sub    $0xc,%esp
  801a2b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a2e:	e8 a8 05 00 00       	call   801fdb <pageref>
  801a33:	89 c3                	mov    %eax,%ebx
  801a35:	89 3c 24             	mov    %edi,(%esp)
  801a38:	e8 9e 05 00 00       	call   801fdb <pageref>
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	39 c3                	cmp    %eax,%ebx
  801a42:	0f 94 c1             	sete   %cl
  801a45:	0f b6 c9             	movzbl %cl,%ecx
  801a48:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a4b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a54:	39 ce                	cmp    %ecx,%esi
  801a56:	74 1b                	je     801a73 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a58:	39 c3                	cmp    %eax,%ebx
  801a5a:	75 c4                	jne    801a20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a5c:	8b 42 58             	mov    0x58(%edx),%eax
  801a5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a62:	50                   	push   %eax
  801a63:	56                   	push   %esi
  801a64:	68 aa 28 80 00       	push   $0x8028aa
  801a69:	e8 b8 e7 ff ff       	call   800226 <cprintf>
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	eb ad                	jmp    801a20 <_pipeisclosed+0xe>
	}
}
  801a73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a79:	5b                   	pop    %ebx
  801a7a:	5e                   	pop    %esi
  801a7b:	5f                   	pop    %edi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 28             	sub    $0x28,%esp
  801a87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a8a:	56                   	push   %esi
  801a8b:	e8 16 f7 ff ff       	call   8011a6 <fd2data>
  801a90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	bf 00 00 00 00       	mov    $0x0,%edi
  801a9a:	eb 4b                	jmp    801ae7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a9c:	89 da                	mov    %ebx,%edx
  801a9e:	89 f0                	mov    %esi,%eax
  801aa0:	e8 6d ff ff ff       	call   801a12 <_pipeisclosed>
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	75 48                	jne    801af1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa9:	e8 2b f1 ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aae:	8b 43 04             	mov    0x4(%ebx),%eax
  801ab1:	8b 0b                	mov    (%ebx),%ecx
  801ab3:	8d 51 20             	lea    0x20(%ecx),%edx
  801ab6:	39 d0                	cmp    %edx,%eax
  801ab8:	73 e2                	jae    801a9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ac1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ac4:	89 c2                	mov    %eax,%edx
  801ac6:	c1 fa 1f             	sar    $0x1f,%edx
  801ac9:	89 d1                	mov    %edx,%ecx
  801acb:	c1 e9 1b             	shr    $0x1b,%ecx
  801ace:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ad1:	83 e2 1f             	and    $0x1f,%edx
  801ad4:	29 ca                	sub    %ecx,%edx
  801ad6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ada:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ade:	83 c0 01             	add    $0x1,%eax
  801ae1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae4:	83 c7 01             	add    $0x1,%edi
  801ae7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aea:	75 c2                	jne    801aae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aec:	8b 45 10             	mov    0x10(%ebp),%eax
  801aef:	eb 05                	jmp    801af6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af9:	5b                   	pop    %ebx
  801afa:	5e                   	pop    %esi
  801afb:	5f                   	pop    %edi
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 18             	sub    $0x18,%esp
  801b07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b0a:	57                   	push   %edi
  801b0b:	e8 96 f6 ff ff       	call   8011a6 <fd2data>
  801b10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b1a:	eb 3d                	jmp    801b59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b1c:	85 db                	test   %ebx,%ebx
  801b1e:	74 04                	je     801b24 <devpipe_read+0x26>
				return i;
  801b20:	89 d8                	mov    %ebx,%eax
  801b22:	eb 44                	jmp    801b68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b24:	89 f2                	mov    %esi,%edx
  801b26:	89 f8                	mov    %edi,%eax
  801b28:	e8 e5 fe ff ff       	call   801a12 <_pipeisclosed>
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	75 32                	jne    801b63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b31:	e8 a3 f0 ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b36:	8b 06                	mov    (%esi),%eax
  801b38:	3b 46 04             	cmp    0x4(%esi),%eax
  801b3b:	74 df                	je     801b1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b3d:	99                   	cltd   
  801b3e:	c1 ea 1b             	shr    $0x1b,%edx
  801b41:	01 d0                	add    %edx,%eax
  801b43:	83 e0 1f             	and    $0x1f,%eax
  801b46:	29 d0                	sub    %edx,%eax
  801b48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b56:	83 c3 01             	add    $0x1,%ebx
  801b59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b5c:	75 d8                	jne    801b36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b61:	eb 05                	jmp    801b68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
  801b75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7b:	50                   	push   %eax
  801b7c:	e8 3c f6 ff ff       	call   8011bd <fd_alloc>
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	89 c2                	mov    %eax,%edx
  801b86:	85 c0                	test   %eax,%eax
  801b88:	0f 88 2c 01 00 00    	js     801cba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8e:	83 ec 04             	sub    $0x4,%esp
  801b91:	68 07 04 00 00       	push   $0x407
  801b96:	ff 75 f4             	pushl  -0xc(%ebp)
  801b99:	6a 00                	push   $0x0
  801b9b:	e8 58 f0 ff ff       	call   800bf8 <sys_page_alloc>
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	89 c2                	mov    %eax,%edx
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	0f 88 0d 01 00 00    	js     801cba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bad:	83 ec 0c             	sub    $0xc,%esp
  801bb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb3:	50                   	push   %eax
  801bb4:	e8 04 f6 ff ff       	call   8011bd <fd_alloc>
  801bb9:	89 c3                	mov    %eax,%ebx
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 88 e2 00 00 00    	js     801ca8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc6:	83 ec 04             	sub    $0x4,%esp
  801bc9:	68 07 04 00 00       	push   $0x407
  801bce:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd1:	6a 00                	push   $0x0
  801bd3:	e8 20 f0 ff ff       	call   800bf8 <sys_page_alloc>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 88 c3 00 00 00    	js     801ca8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	e8 b6 f5 ff ff       	call   8011a6 <fd2data>
  801bf0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf2:	83 c4 0c             	add    $0xc,%esp
  801bf5:	68 07 04 00 00       	push   $0x407
  801bfa:	50                   	push   %eax
  801bfb:	6a 00                	push   $0x0
  801bfd:	e8 f6 ef ff ff       	call   800bf8 <sys_page_alloc>
  801c02:	89 c3                	mov    %eax,%ebx
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 89 00 00 00    	js     801c98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	ff 75 f0             	pushl  -0x10(%ebp)
  801c15:	e8 8c f5 ff ff       	call   8011a6 <fd2data>
  801c1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c21:	50                   	push   %eax
  801c22:	6a 00                	push   $0x0
  801c24:	56                   	push   %esi
  801c25:	6a 00                	push   $0x0
  801c27:	e8 0f f0 ff ff       	call   800c3b <sys_page_map>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	83 c4 20             	add    $0x20,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	78 55                	js     801c8a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c5f:	83 ec 0c             	sub    $0xc,%esp
  801c62:	ff 75 f4             	pushl  -0xc(%ebp)
  801c65:	e8 2c f5 ff ff       	call   801196 <fd2num>
  801c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c6f:	83 c4 04             	add    $0x4,%esp
  801c72:	ff 75 f0             	pushl  -0x10(%ebp)
  801c75:	e8 1c f5 ff ff       	call   801196 <fd2num>
  801c7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	ba 00 00 00 00       	mov    $0x0,%edx
  801c88:	eb 30                	jmp    801cba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c8a:	83 ec 08             	sub    $0x8,%esp
  801c8d:	56                   	push   %esi
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 e8 ef ff ff       	call   800c7d <sys_page_unmap>
  801c95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 d8 ef ff ff       	call   800c7d <sys_page_unmap>
  801ca5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca8:	83 ec 08             	sub    $0x8,%esp
  801cab:	ff 75 f4             	pushl  -0xc(%ebp)
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 c8 ef ff ff       	call   800c7d <sys_page_unmap>
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	ff 75 08             	pushl  0x8(%ebp)
  801cd0:	e8 37 f5 ff ff       	call   80120c <fd_lookup>
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 18                	js     801cf4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cdc:	83 ec 0c             	sub    $0xc,%esp
  801cdf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce2:	e8 bf f4 ff ff       	call   8011a6 <fd2data>
	return _pipeisclosed(fd, p);
  801ce7:	89 c2                	mov    %eax,%edx
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	e8 21 fd ff ff       	call   801a12 <_pipeisclosed>
  801cf1:	83 c4 10             	add    $0x10,%esp
}
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    

00801d00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d06:	68 c2 28 80 00       	push   $0x8028c2
  801d0b:	ff 75 0c             	pushl  0xc(%ebp)
  801d0e:	e8 e2 ea ff ff       	call   8007f5 <strcpy>
	return 0;
}
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	57                   	push   %edi
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d26:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d31:	eb 2d                	jmp    801d60 <devcons_write+0x46>
		m = n - tot;
  801d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d36:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d38:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d40:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d43:	83 ec 04             	sub    $0x4,%esp
  801d46:	53                   	push   %ebx
  801d47:	03 45 0c             	add    0xc(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	57                   	push   %edi
  801d4c:	e8 36 ec ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  801d51:	83 c4 08             	add    $0x8,%esp
  801d54:	53                   	push   %ebx
  801d55:	57                   	push   %edi
  801d56:	e8 e1 ed ff ff       	call   800b3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5b:	01 de                	add    %ebx,%esi
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	89 f0                	mov    %esi,%eax
  801d62:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d65:	72 cc                	jb     801d33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6a:	5b                   	pop    %ebx
  801d6b:	5e                   	pop    %esi
  801d6c:	5f                   	pop    %edi
  801d6d:	5d                   	pop    %ebp
  801d6e:	c3                   	ret    

00801d6f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	83 ec 08             	sub    $0x8,%esp
  801d75:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7e:	74 2a                	je     801daa <devcons_read+0x3b>
  801d80:	eb 05                	jmp    801d87 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d82:	e8 52 ee ff ff       	call   800bd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d87:	e8 ce ed ff ff       	call   800b5a <sys_cgetc>
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	74 f2                	je     801d82 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 16                	js     801daa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d94:	83 f8 04             	cmp    $0x4,%eax
  801d97:	74 0c                	je     801da5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d99:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9c:	88 02                	mov    %al,(%edx)
	return 1;
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	eb 05                	jmp    801daa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db8:	6a 01                	push   $0x1
  801dba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dbd:	50                   	push   %eax
  801dbe:	e8 79 ed ff ff       	call   800b3c <sys_cputs>
}
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	c9                   	leave  
  801dc7:	c3                   	ret    

00801dc8 <getchar>:

int
getchar(void)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dce:	6a 01                	push   $0x1
  801dd0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd3:	50                   	push   %eax
  801dd4:	6a 00                	push   $0x0
  801dd6:	e8 97 f6 ff ff       	call   801472 <read>
	if (r < 0)
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 0f                	js     801df1 <getchar+0x29>
		return r;
	if (r < 1)
  801de2:	85 c0                	test   %eax,%eax
  801de4:	7e 06                	jle    801dec <getchar+0x24>
		return -E_EOF;
	return c;
  801de6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dea:	eb 05                	jmp    801df1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	ff 75 08             	pushl  0x8(%ebp)
  801e00:	e8 07 f4 ff ff       	call   80120c <fd_lookup>
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	78 11                	js     801e1d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e15:	39 10                	cmp    %edx,(%eax)
  801e17:	0f 94 c0             	sete   %al
  801e1a:	0f b6 c0             	movzbl %al,%eax
}
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <opencons>:

int
opencons(void)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e28:	50                   	push   %eax
  801e29:	e8 8f f3 ff ff       	call   8011bd <fd_alloc>
  801e2e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e31:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 3e                	js     801e75 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e37:	83 ec 04             	sub    $0x4,%esp
  801e3a:	68 07 04 00 00       	push   $0x407
  801e3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e42:	6a 00                	push   $0x0
  801e44:	e8 af ed ff ff       	call   800bf8 <sys_page_alloc>
  801e49:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 23                	js     801e75 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e52:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e60:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e67:	83 ec 0c             	sub    $0xc,%esp
  801e6a:	50                   	push   %eax
  801e6b:	e8 26 f3 ff ff       	call   801196 <fd2num>
  801e70:	89 c2                	mov    %eax,%edx
  801e72:	83 c4 10             	add    $0x10,%esp
}
  801e75:	89 d0                	mov    %edx,%eax
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801e7f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e86:	75 4c                	jne    801ed4 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801e88:	a1 08 40 80 00       	mov    0x804008,%eax
  801e8d:	8b 40 48             	mov    0x48(%eax),%eax
  801e90:	83 ec 04             	sub    $0x4,%esp
  801e93:	6a 07                	push   $0x7
  801e95:	68 00 f0 bf ee       	push   $0xeebff000
  801e9a:	50                   	push   %eax
  801e9b:	e8 58 ed ff ff       	call   800bf8 <sys_page_alloc>
		if(retv != 0){
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	74 14                	je     801ebb <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801ea7:	83 ec 04             	sub    $0x4,%esp
  801eaa:	68 d0 28 80 00       	push   $0x8028d0
  801eaf:	6a 27                	push   $0x27
  801eb1:	68 fc 28 80 00       	push   $0x8028fc
  801eb6:	e8 92 e2 ff ff       	call   80014d <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ebb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec0:	8b 40 48             	mov    0x48(%eax),%eax
  801ec3:	83 ec 08             	sub    $0x8,%esp
  801ec6:	68 de 1e 80 00       	push   $0x801ede
  801ecb:	50                   	push   %eax
  801ecc:	e8 72 ee ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
  801ed1:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed7:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ede:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801edf:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ee4:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  801ee6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  801ee9:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  801eed:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  801ef2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  801ef6:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  801ef8:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  801efb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  801efc:	83 c4 04             	add    $0x4,%esp
	popfl
  801eff:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f00:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f01:	c3                   	ret    

00801f02 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	56                   	push   %esi
  801f06:	53                   	push   %ebx
  801f07:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f0a:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801f0d:	83 ec 0c             	sub    $0xc,%esp
  801f10:	ff 75 0c             	pushl  0xc(%ebp)
  801f13:	e8 90 ee ff ff       	call   800da8 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	85 f6                	test   %esi,%esi
  801f1d:	74 1c                	je     801f3b <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801f1f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f24:	8b 40 78             	mov    0x78(%eax),%eax
  801f27:	89 06                	mov    %eax,(%esi)
  801f29:	eb 10                	jmp    801f3b <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801f2b:	83 ec 0c             	sub    $0xc,%esp
  801f2e:	68 0a 29 80 00       	push   $0x80290a
  801f33:	e8 ee e2 ff ff       	call   800226 <cprintf>
  801f38:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801f3b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f40:	8b 50 74             	mov    0x74(%eax),%edx
  801f43:	85 d2                	test   %edx,%edx
  801f45:	74 e4                	je     801f2b <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801f47:	85 db                	test   %ebx,%ebx
  801f49:	74 05                	je     801f50 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801f4b:	8b 40 74             	mov    0x74(%eax),%eax
  801f4e:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f50:	a1 08 40 80 00       	mov    0x804008,%eax
  801f55:	8b 40 70             	mov    0x70(%eax),%eax

}
  801f58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	57                   	push   %edi
  801f63:	56                   	push   %esi
  801f64:	53                   	push   %ebx
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801f71:	85 db                	test   %ebx,%ebx
  801f73:	75 13                	jne    801f88 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801f75:	6a 00                	push   $0x0
  801f77:	68 00 00 c0 ee       	push   $0xeec00000
  801f7c:	56                   	push   %esi
  801f7d:	57                   	push   %edi
  801f7e:	e8 02 ee ff ff       	call   800d85 <sys_ipc_try_send>
  801f83:	83 c4 10             	add    $0x10,%esp
  801f86:	eb 0e                	jmp    801f96 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801f88:	ff 75 14             	pushl  0x14(%ebp)
  801f8b:	53                   	push   %ebx
  801f8c:	56                   	push   %esi
  801f8d:	57                   	push   %edi
  801f8e:	e8 f2 ed ff ff       	call   800d85 <sys_ipc_try_send>
  801f93:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801f96:	85 c0                	test   %eax,%eax
  801f98:	75 d7                	jne    801f71 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801f9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    

00801fa2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fad:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fb0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fb6:	8b 52 50             	mov    0x50(%edx),%edx
  801fb9:	39 ca                	cmp    %ecx,%edx
  801fbb:	75 0d                	jne    801fca <ipc_find_env+0x28>
			return envs[i].env_id;
  801fbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc5:	8b 40 48             	mov    0x48(%eax),%eax
  801fc8:	eb 0f                	jmp    801fd9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fca:	83 c0 01             	add    $0x1,%eax
  801fcd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fd2:	75 d9                	jne    801fad <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd9:	5d                   	pop    %ebp
  801fda:	c3                   	ret    

00801fdb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe1:	89 d0                	mov    %edx,%eax
  801fe3:	c1 e8 16             	shr    $0x16,%eax
  801fe6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff2:	f6 c1 01             	test   $0x1,%cl
  801ff5:	74 1d                	je     802014 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ff7:	c1 ea 0c             	shr    $0xc,%edx
  801ffa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802001:	f6 c2 01             	test   $0x1,%dl
  802004:	74 0e                	je     802014 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802006:	c1 ea 0c             	shr    $0xc,%edx
  802009:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802010:	ef 
  802011:	0f b7 c0             	movzwl %ax,%eax
}
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    
  802016:	66 90                	xchg   %ax,%ax
  802018:	66 90                	xchg   %ax,%ax
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
