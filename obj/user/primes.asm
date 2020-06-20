
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 55 11 00 00       	call   8011a1 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 c0 22 80 00       	push   $0x8022c0
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 42 0f 00 00       	call   800fac <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 cc 22 80 00       	push   $0x8022cc
  800079:	6a 1a                	push   $0x1a
  80007b:	68 d5 22 80 00       	push   $0x8022d5
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 08 11 00 00       	call   8011a1 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 4e 11 00 00       	call   8011fe <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 ed 0e 00 00       	call   800fac <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 cc 22 80 00       	push   $0x8022cc
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 d5 22 80 00       	push   $0x8022d5
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 0e 11 00 00       	call   8011fe <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 bd 0a 00 00       	call   800bc5 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 fc 12 00 00       	call   801445 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 31 0a 00 00       	call   800b84 <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 5a 0a 00 00       	call   800bc5 <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 f0 22 80 00       	push   $0x8022f0
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 23 27 80 00 	movl   $0x802723,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 79 09 00 00       	call   800b47 <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 1e 09 00 00       	call   800b47 <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 97 1d 00 00       	call   802030 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 84 1e 00 00       	call   802160 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 13 23 80 00 	movsbl 0x802313(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 d3 03 00 00    	je     800757 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 64 03 00 00    	ja     80073c <vprintfmt+0x3d4>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800400:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 39                	ja     800441 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800408:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040b:	eb e9                	jmp    8003f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 48 04             	lea    0x4(%eax),%ecx
  800413:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 27                	jmp    800447 <vprintfmt+0xdf>
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	0f 49 c8             	cmovns %eax,%ecx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	eb 8c                	jmp    8003c1 <vprintfmt+0x59>
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800438:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043f:	eb 80                	jmp    8003c1 <vprintfmt+0x59>
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 89 70 ff ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800451:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800469:	e9 53 ff ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 30                	pushl  (%eax)
  80047d:	ff d6                	call   *%esi
			break;
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800485:	e9 04 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	99                   	cltd   
  800496:	31 d0                	xor    %edx,%eax
  800498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 0b                	jg     8004aa <vprintfmt+0x142>
  80049f:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 2b 23 80 00       	push   $0x80232b
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 94 fe ff ff       	call   80034b <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bd:	e9 cc fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	68 79 28 80 00       	push   $0x802879
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7c fe ff ff       	call   80034b <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	e9 b4 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	b8 24 23 80 00       	mov    $0x802324,%eax
  8004ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	0f 8e 94 00 00 00    	jle    80058d <vprintfmt+0x225>
  8004f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fd:	0f 84 98 00 00 00    	je     80059b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 c8             	pushl  -0x38(%ebp)
  800509:	57                   	push   %edi
  80050a:	e8 d0 02 00 00       	call   8007df <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	eb 0f                	jmp    800537 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 75 e0             	pushl  -0x20(%ebp)
  80052f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ed                	jg     800528 <vprintfmt+0x1c0>
  80053b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800541:	85 c9                	test   %ecx,%ecx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c1             	cmovns %ecx,%eax
  80054b:	29 c1                	sub    %eax,%ecx
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	89 cb                	mov    %ecx,%ebx
  800558:	eb 4d                	jmp    8005a7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x213>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 10                	jbe    80057b <vprintfmt+0x213>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 3f                	push   $0x3f
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	52                   	push   %edx
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	eb 1a                	jmp    8005a7 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	eb 0c                	jmp    8005a7 <vprintfmt+0x23f>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 23                	je     8005d8 <vprintfmt+0x270>
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	78 a1                	js     80055a <vprintfmt+0x1f2>
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	79 9c                	jns    80055a <vprintfmt+0x1f2>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	eb 18                	jmp    8005e0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 20                	push   $0x20
  8005ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 08                	jmp    8005e0 <vprintfmt+0x278>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f e4                	jg     8005c8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a2 fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 fa 01             	cmp    $0x1,%edx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800602:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x2d1>
	else if (lflag)
  800607:	85 d2                	test   %edx,%edx
  800609:	74 18                	je     800623 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80063c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80063f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800642:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800645:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80064e:	0f 89 b0 00 00 00    	jns    800704 <vprintfmt+0x39c>
				putch('-', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 2d                	push   $0x2d
  80065a:	ff d6                	call   *%esi
				num = -(long long) num;
  80065c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80065f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800662:	f7 d8                	neg    %eax
  800664:	83 d2 00             	adc    $0x0,%edx
  800667:	f7 da                	neg    %edx
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800672:	b8 0a 00 00 00       	mov    $0xa,%eax
  800677:	e9 88 00 00 00       	jmp    800704 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067c:	8d 45 14             	lea    0x14(%ebp),%eax
  80067f:	e8 70 fc ff ff       	call   8002f4 <getuint>
  800684:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800687:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068f:	eb 73                	jmp    800704 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800691:	8d 45 14             	lea    0x14(%ebp),%eax
  800694:	e8 5b fc ff ff       	call   8002f4 <getuint>
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 58                	push   $0x58
  8006a5:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a7:	83 c4 08             	add    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 58                	push   $0x58
  8006ad:	ff d6                	call   *%esi
			putch('X', putdat);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 58                	push   $0x58
  8006b5:	ff d6                	call   *%esi
			goto number;
  8006b7:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8006ba:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006bf:	eb 43                	jmp    800704 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 30                	push   $0x30
  8006c7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c9:	83 c4 08             	add    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 78                	push   $0x78
  8006cf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 04             	lea    0x4(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ea:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ef:	eb 13                	jmp    800704 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f4:	e8 fb fb ff ff       	call   8002f4 <getuint>
  8006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800704:	83 ec 0c             	sub    $0xc,%esp
  800707:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80070b:	52                   	push   %edx
  80070c:	ff 75 e0             	pushl  -0x20(%ebp)
  80070f:	50                   	push   %eax
  800710:	ff 75 dc             	pushl  -0x24(%ebp)
  800713:	ff 75 d8             	pushl  -0x28(%ebp)
  800716:	89 da                	mov    %ebx,%edx
  800718:	89 f0                	mov    %esi,%eax
  80071a:	e8 26 fb ff ff       	call   800245 <printnum>
			break;
  80071f:	83 c4 20             	add    $0x20,%esp
  800722:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800725:	e9 64 fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	51                   	push   %ecx
  80072f:	ff d6                	call   *%esi
			break;
  800731:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800737:	e9 52 fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 25                	push   $0x25
  800742:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb 03                	jmp    80074c <vprintfmt+0x3e4>
  800749:	83 ef 01             	sub    $0x1,%edi
  80074c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800750:	75 f7                	jne    800749 <vprintfmt+0x3e1>
  800752:	e9 37 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800757:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075a:	5b                   	pop    %ebx
  80075b:	5e                   	pop    %esi
  80075c:	5f                   	pop    %edi
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	83 ec 18             	sub    $0x18,%esp
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
  800768:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800772:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800775:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077c:	85 c0                	test   %eax,%eax
  80077e:	74 26                	je     8007a6 <vsnprintf+0x47>
  800780:	85 d2                	test   %edx,%edx
  800782:	7e 22                	jle    8007a6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800784:	ff 75 14             	pushl  0x14(%ebp)
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078d:	50                   	push   %eax
  80078e:	68 2e 03 80 00       	push   $0x80032e
  800793:	e8 d0 fb ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	eb 05                	jmp    8007ab <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b6:	50                   	push   %eax
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	ff 75 08             	pushl  0x8(%ebp)
  8007c0:	e8 9a ff ff ff       	call   80075f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d2:	eb 03                	jmp    8007d7 <strlen+0x10>
		n++;
  8007d4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007db:	75 f7                	jne    8007d4 <strlen+0xd>
		n++;
	return n;
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ed:	eb 03                	jmp    8007f2 <strnlen+0x13>
		n++;
  8007ef:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f2:	39 c2                	cmp    %eax,%edx
  8007f4:	74 08                	je     8007fe <strnlen+0x1f>
  8007f6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007fa:	75 f3                	jne    8007ef <strnlen+0x10>
  8007fc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080a:	89 c2                	mov    %eax,%edx
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800816:	88 5a ff             	mov    %bl,-0x1(%edx)
  800819:	84 db                	test   %bl,%bl
  80081b:	75 ef                	jne    80080c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800827:	53                   	push   %ebx
  800828:	e8 9a ff ff ff       	call   8007c7 <strlen>
  80082d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	01 d8                	add    %ebx,%eax
  800835:	50                   	push   %eax
  800836:	e8 c5 ff ff ff       	call   800800 <strcpy>
	return dst;
}
  80083b:	89 d8                	mov    %ebx,%eax
  80083d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 75 08             	mov    0x8(%ebp),%esi
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084d:	89 f3                	mov    %esi,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800852:	89 f2                	mov    %esi,%edx
  800854:	eb 0f                	jmp    800865 <strncpy+0x23>
		*dst++ = *src;
  800856:	83 c2 01             	add    $0x1,%edx
  800859:	0f b6 01             	movzbl (%ecx),%eax
  80085c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085f:	80 39 01             	cmpb   $0x1,(%ecx)
  800862:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	39 da                	cmp    %ebx,%edx
  800867:	75 ed                	jne    800856 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800869:	89 f0                	mov    %esi,%eax
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	8b 75 08             	mov    0x8(%ebp),%esi
  800877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087a:	8b 55 10             	mov    0x10(%ebp),%edx
  80087d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087f:	85 d2                	test   %edx,%edx
  800881:	74 21                	je     8008a4 <strlcpy+0x35>
  800883:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800887:	89 f2                	mov    %esi,%edx
  800889:	eb 09                	jmp    800894 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088b:	83 c2 01             	add    $0x1,%edx
  80088e:	83 c1 01             	add    $0x1,%ecx
  800891:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800894:	39 c2                	cmp    %eax,%edx
  800896:	74 09                	je     8008a1 <strlcpy+0x32>
  800898:	0f b6 19             	movzbl (%ecx),%ebx
  80089b:	84 db                	test   %bl,%bl
  80089d:	75 ec                	jne    80088b <strlcpy+0x1c>
  80089f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a4:	29 f0                	sub    %esi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b3:	eb 06                	jmp    8008bb <strcmp+0x11>
		p++, q++;
  8008b5:	83 c1 01             	add    $0x1,%ecx
  8008b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bb:	0f b6 01             	movzbl (%ecx),%eax
  8008be:	84 c0                	test   %al,%al
  8008c0:	74 04                	je     8008c6 <strcmp+0x1c>
  8008c2:	3a 02                	cmp    (%edx),%al
  8008c4:	74 ef                	je     8008b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 c0             	movzbl %al,%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	89 c3                	mov    %eax,%ebx
  8008dc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008df:	eb 06                	jmp    8008e7 <strncmp+0x17>
		n--, p++, q++;
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e7:	39 d8                	cmp    %ebx,%eax
  8008e9:	74 15                	je     800900 <strncmp+0x30>
  8008eb:	0f b6 08             	movzbl (%eax),%ecx
  8008ee:	84 c9                	test   %cl,%cl
  8008f0:	74 04                	je     8008f6 <strncmp+0x26>
  8008f2:	3a 0a                	cmp    (%edx),%cl
  8008f4:	74 eb                	je     8008e1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f6:	0f b6 00             	movzbl (%eax),%eax
  8008f9:	0f b6 12             	movzbl (%edx),%edx
  8008fc:	29 d0                	sub    %edx,%eax
  8008fe:	eb 05                	jmp    800905 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800905:	5b                   	pop    %ebx
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800912:	eb 07                	jmp    80091b <strchr+0x13>
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 0f                	je     800927 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	0f b6 10             	movzbl (%eax),%edx
  80091e:	84 d2                	test   %dl,%dl
  800920:	75 f2                	jne    800914 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800933:	eb 03                	jmp    800938 <strfind+0xf>
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093b:	38 ca                	cmp    %cl,%dl
  80093d:	74 04                	je     800943 <strfind+0x1a>
  80093f:	84 d2                	test   %dl,%dl
  800941:	75 f2                	jne    800935 <strfind+0xc>
			break;
	return (char *) s;
}
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	57                   	push   %edi
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 36                	je     80098b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 28                	jne    800985 <memset+0x40>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 23                	jne    800985 <memset+0x40>
		c &= 0xFF;
  800962:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800966:	89 d3                	mov    %edx,%ebx
  800968:	c1 e3 08             	shl    $0x8,%ebx
  80096b:	89 d6                	mov    %edx,%esi
  80096d:	c1 e6 18             	shl    $0x18,%esi
  800970:	89 d0                	mov    %edx,%eax
  800972:	c1 e0 10             	shl    $0x10,%eax
  800975:	09 f0                	or     %esi,%eax
  800977:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800979:	89 d8                	mov    %ebx,%eax
  80097b:	09 d0                	or     %edx,%eax
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	fc                   	cld    
  800981:	f3 ab                	rep stos %eax,%es:(%edi)
  800983:	eb 06                	jmp    80098b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	fc                   	cld    
  800989:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098b:	89 f8                	mov    %edi,%eax
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a0:	39 c6                	cmp    %eax,%esi
  8009a2:	73 35                	jae    8009d9 <memmove+0x47>
  8009a4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a7:	39 d0                	cmp    %edx,%eax
  8009a9:	73 2e                	jae    8009d9 <memmove+0x47>
		s += n;
		d += n;
  8009ab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	89 d6                	mov    %edx,%esi
  8009b0:	09 fe                	or     %edi,%esi
  8009b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b8:	75 13                	jne    8009cd <memmove+0x3b>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0e                	jne    8009cd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009bf:	83 ef 04             	sub    $0x4,%edi
  8009c2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c5:	c1 e9 02             	shr    $0x2,%ecx
  8009c8:	fd                   	std    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb 09                	jmp    8009d6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cd:	83 ef 01             	sub    $0x1,%edi
  8009d0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d3:	fd                   	std    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d6:	fc                   	cld    
  8009d7:	eb 1d                	jmp    8009f6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	89 f2                	mov    %esi,%edx
  8009db:	09 c2                	or     %eax,%edx
  8009dd:	f6 c2 03             	test   $0x3,%dl
  8009e0:	75 0f                	jne    8009f1 <memmove+0x5f>
  8009e2:	f6 c1 03             	test   $0x3,%cl
  8009e5:	75 0a                	jne    8009f1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
  8009ea:	89 c7                	mov    %eax,%edi
  8009ec:	fc                   	cld    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 05                	jmp    8009f6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f6:	5e                   	pop    %esi
  8009f7:	5f                   	pop    %edi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fd:	ff 75 10             	pushl  0x10(%ebp)
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	ff 75 08             	pushl  0x8(%ebp)
  800a06:	e8 87 ff ff ff       	call   800992 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a18:	89 c6                	mov    %eax,%esi
  800a1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	eb 1a                	jmp    800a39 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1f:	0f b6 08             	movzbl (%eax),%ecx
  800a22:	0f b6 1a             	movzbl (%edx),%ebx
  800a25:	38 d9                	cmp    %bl,%cl
  800a27:	74 0a                	je     800a33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c1             	movzbl %cl,%eax
  800a2c:	0f b6 db             	movzbl %bl,%ebx
  800a2f:	29 d8                	sub    %ebx,%eax
  800a31:	eb 0f                	jmp    800a42 <memcmp+0x35>
		s1++, s2++;
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a39:	39 f0                	cmp    %esi,%eax
  800a3b:	75 e2                	jne    800a1f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	53                   	push   %ebx
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4d:	89 c1                	mov    %eax,%ecx
  800a4f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a52:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a56:	eb 0a                	jmp    800a62 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	39 da                	cmp    %ebx,%edx
  800a5d:	74 07                	je     800a66 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	39 c8                	cmp    %ecx,%eax
  800a64:	72 f2                	jb     800a58 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a66:	5b                   	pop    %ebx
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a75:	eb 03                	jmp    800a7a <strtol+0x11>
		s++;
  800a77:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	0f b6 01             	movzbl (%ecx),%eax
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 f6                	je     800a77 <strtol+0xe>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	74 f2                	je     800a77 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a85:	3c 2b                	cmp    $0x2b,%al
  800a87:	75 0a                	jne    800a93 <strtol+0x2a>
		s++;
  800a89:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a91:	eb 11                	jmp    800aa4 <strtol+0x3b>
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a98:	3c 2d                	cmp    $0x2d,%al
  800a9a:	75 08                	jne    800aa4 <strtol+0x3b>
		s++, neg = 1;
  800a9c:	83 c1 01             	add    $0x1,%ecx
  800a9f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aaa:	75 15                	jne    800ac1 <strtol+0x58>
  800aac:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaf:	75 10                	jne    800ac1 <strtol+0x58>
  800ab1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab5:	75 7c                	jne    800b33 <strtol+0xca>
		s += 2, base = 16;
  800ab7:	83 c1 02             	add    $0x2,%ecx
  800aba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abf:	eb 16                	jmp    800ad7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac1:	85 db                	test   %ebx,%ebx
  800ac3:	75 12                	jne    800ad7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	80 39 30             	cmpb   $0x30,(%ecx)
  800acd:	75 08                	jne    800ad7 <strtol+0x6e>
		s++, base = 8;
  800acf:	83 c1 01             	add    $0x1,%ecx
  800ad2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adf:	0f b6 11             	movzbl (%ecx),%edx
  800ae2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae5:	89 f3                	mov    %esi,%ebx
  800ae7:	80 fb 09             	cmp    $0x9,%bl
  800aea:	77 08                	ja     800af4 <strtol+0x8b>
			dig = *s - '0';
  800aec:	0f be d2             	movsbl %dl,%edx
  800aef:	83 ea 30             	sub    $0x30,%edx
  800af2:	eb 22                	jmp    800b16 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800afe:	0f be d2             	movsbl %dl,%edx
  800b01:	83 ea 57             	sub    $0x57,%edx
  800b04:	eb 10                	jmp    800b16 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 16                	ja     800b26 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b16:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b19:	7d 0b                	jge    800b26 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b1b:	83 c1 01             	add    $0x1,%ecx
  800b1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b22:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b24:	eb b9                	jmp    800adf <strtol+0x76>

	if (endptr)
  800b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2a:	74 0d                	je     800b39 <strtol+0xd0>
		*endptr = (char *) s;
  800b2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2f:	89 0e                	mov    %ecx,(%esi)
  800b31:	eb 06                	jmp    800b39 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b33:	85 db                	test   %ebx,%ebx
  800b35:	74 98                	je     800acf <strtol+0x66>
  800b37:	eb 9e                	jmp    800ad7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b39:	89 c2                	mov    %eax,%edx
  800b3b:	f7 da                	neg    %edx
  800b3d:	85 ff                	test   %edi,%edi
  800b3f:	0f 45 c2             	cmovne %edx,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	89 c7                	mov    %eax,%edi
  800b5c:	89 c6                	mov    %eax,%esi
  800b5e:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 01 00 00 00       	mov    $0x1,%eax
  800b75:	89 d1                	mov    %edx,%ecx
  800b77:	89 d3                	mov    %edx,%ebx
  800b79:	89 d7                	mov    %edx,%edi
  800b7b:	89 d6                	mov    %edx,%esi
  800b7d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b92:	b8 03 00 00 00       	mov    $0x3,%eax
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	89 cb                	mov    %ecx,%ebx
  800b9c:	89 cf                	mov    %ecx,%edi
  800b9e:	89 ce                	mov    %ecx,%esi
  800ba0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ba2:	85 c0                	test   %eax,%eax
  800ba4:	7e 17                	jle    800bbd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 03                	push   $0x3
  800bac:	68 1f 26 80 00       	push   $0x80261f
  800bb1:	6a 23                	push   $0x23
  800bb3:	68 3c 26 80 00       	push   $0x80263c
  800bb8:	e8 9b f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd5:	89 d1                	mov    %edx,%ecx
  800bd7:	89 d3                	mov    %edx,%ebx
  800bd9:	89 d7                	mov    %edx,%edi
  800bdb:	89 d6                	mov    %edx,%esi
  800bdd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_yield>:

void
sys_yield(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c0c:	be 00 00 00 00       	mov    $0x0,%esi
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	89 f7                	mov    %esi,%edi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 04                	push   $0x4
  800c2d:	68 1f 26 80 00       	push   $0x80261f
  800c32:	6a 23                	push   $0x23
  800c34:	68 3c 26 80 00       	push   $0x80263c
  800c39:	e8 1a f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c60:	8b 75 18             	mov    0x18(%ebp),%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 05                	push   $0x5
  800c6f:	68 1f 26 80 00       	push   $0x80261f
  800c74:	6a 23                	push   $0x23
  800c76:	68 3c 26 80 00       	push   $0x80263c
  800c7b:	e8 d8 f4 ff ff       	call   800158 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 06                	push   $0x6
  800cb1:	68 1f 26 80 00       	push   $0x80261f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 3c 26 80 00       	push   $0x80263c
  800cbd:	e8 96 f4 ff ff       	call   800158 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 08                	push   $0x8
  800cf3:	68 1f 26 80 00       	push   $0x80261f
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 3c 26 80 00       	push   $0x80263c
  800cff:	e8 54 f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 17                	jle    800d46 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 09                	push   $0x9
  800d35:	68 1f 26 80 00       	push   $0x80261f
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 3c 26 80 00       	push   $0x80263c
  800d41:	e8 12 f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 17                	jle    800d88 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	50                   	push   %eax
  800d75:	6a 0a                	push   $0xa
  800d77:	68 1f 26 80 00       	push   $0x80261f
  800d7c:	6a 23                	push   $0x23
  800d7e:	68 3c 26 80 00       	push   $0x80263c
  800d83:	e8 d0 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d96:	be 00 00 00 00       	mov    $0x0,%esi
  800d9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dac:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	89 cb                	mov    %ecx,%ebx
  800dcb:	89 cf                	mov    %ecx,%edi
  800dcd:	89 ce                	mov    %ecx,%esi
  800dcf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	7e 17                	jle    800dec <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	50                   	push   %eax
  800dd9:	6a 0d                	push   $0xd
  800ddb:	68 1f 26 80 00       	push   $0x80261f
  800de0:	6a 23                	push   $0x23
  800de2:	68 3c 26 80 00       	push   $0x80263c
  800de7:	e8 6c f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dfc:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800dfe:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e02:	74 11                	je     800e15 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	c1 e8 0c             	shr    $0xc,%eax
  800e09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800e10:	f6 c4 08             	test   $0x8,%ah
  800e13:	75 14                	jne    800e29 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	68 4a 26 80 00       	push   $0x80264a
  800e1d:	6a 21                	push   $0x21
  800e1f:	68 60 26 80 00       	push   $0x802660
  800e24:	e8 2f f3 ff ff       	call   800158 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800e29:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e2f:	e8 91 fd ff ff       	call   800bc5 <sys_getenvid>
  800e34:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	6a 07                	push   $0x7
  800e3b:	68 00 f0 7f 00       	push   $0x7ff000
  800e40:	50                   	push   %eax
  800e41:	e8 bd fd ff ff       	call   800c03 <sys_page_alloc>
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	79 14                	jns    800e61 <pgfault+0x6d>
		panic("sys_page_alloc");
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	68 6b 26 80 00       	push   $0x80266b
  800e55:	6a 30                	push   $0x30
  800e57:	68 60 26 80 00       	push   $0x802660
  800e5c:	e8 f7 f2 ff ff       	call   800158 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	68 00 10 00 00       	push   $0x1000
  800e69:	53                   	push   %ebx
  800e6a:	68 00 f0 7f 00       	push   $0x7ff000
  800e6f:	e8 86 fb ff ff       	call   8009fa <memcpy>
	retv = sys_page_unmap(envid, addr);
  800e74:	83 c4 08             	add    $0x8,%esp
  800e77:	53                   	push   %ebx
  800e78:	56                   	push   %esi
  800e79:	e8 0a fe ff ff       	call   800c88 <sys_page_unmap>
	if(retv < 0){
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	79 12                	jns    800e97 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800e85:	50                   	push   %eax
  800e86:	68 58 27 80 00       	push   $0x802758
  800e8b:	6a 35                	push   $0x35
  800e8d:	68 60 26 80 00       	push   $0x802660
  800e92:	e8 c1 f2 ff ff       	call   800158 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	6a 07                	push   $0x7
  800e9c:	53                   	push   %ebx
  800e9d:	56                   	push   %esi
  800e9e:	68 00 f0 7f 00       	push   $0x7ff000
  800ea3:	56                   	push   %esi
  800ea4:	e8 9d fd ff ff       	call   800c46 <sys_page_map>
	if(retv < 0){
  800ea9:	83 c4 20             	add    $0x20,%esp
  800eac:	85 c0                	test   %eax,%eax
  800eae:	79 14                	jns    800ec4 <pgfault+0xd0>
		panic("sys_page_map");
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	68 7a 26 80 00       	push   $0x80267a
  800eb8:	6a 39                	push   $0x39
  800eba:	68 60 26 80 00       	push   $0x802660
  800ebf:	e8 94 f2 ff ff       	call   800158 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	68 00 f0 7f 00       	push   $0x7ff000
  800ecc:	56                   	push   %esi
  800ecd:	e8 b6 fd ff ff       	call   800c88 <sys_page_unmap>
	if(retv < 0){
  800ed2:	83 c4 10             	add    $0x10,%esp
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	79 14                	jns    800eed <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	68 87 26 80 00       	push   $0x802687
  800ee1:	6a 3d                	push   $0x3d
  800ee3:	68 60 26 80 00       	push   $0x802660
  800ee8:	e8 6b f2 ff ff       	call   800158 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800eed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800efc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eff:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	53                   	push   %ebx
  800f06:	68 a4 26 80 00       	push   $0x8026a4
  800f0b:	e8 21 f3 ff ff       	call   800231 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f10:	83 c4 0c             	add    $0xc,%esp
  800f13:	6a 07                	push   $0x7
  800f15:	53                   	push   %ebx
  800f16:	56                   	push   %esi
  800f17:	e8 e7 fc ff ff       	call   800c03 <sys_page_alloc>
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	79 15                	jns    800f38 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800f23:	50                   	push   %eax
  800f24:	68 b7 26 80 00       	push   $0x8026b7
  800f29:	68 90 00 00 00       	push   $0x90
  800f2e:	68 60 26 80 00       	push   $0x802660
  800f33:	e8 20 f2 ff ff       	call   800158 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	68 ca 26 80 00       	push   $0x8026ca
  800f40:	e8 ec f2 ff ff       	call   800231 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f45:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f4c:	68 00 00 40 00       	push   $0x400000
  800f51:	6a 00                	push   $0x0
  800f53:	53                   	push   %ebx
  800f54:	56                   	push   %esi
  800f55:	e8 ec fc ff ff       	call   800c46 <sys_page_map>
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	79 15                	jns    800f76 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  800f61:	50                   	push   %eax
  800f62:	68 d2 26 80 00       	push   $0x8026d2
  800f67:	68 94 00 00 00       	push   $0x94
  800f6c:	68 60 26 80 00       	push   $0x802660
  800f71:	e8 e2 f1 ff ff       	call   800158 <_panic>
        cprintf("af_p_m.");
  800f76:	83 ec 0c             	sub    $0xc,%esp
  800f79:	68 e3 26 80 00       	push   $0x8026e3
  800f7e:	e8 ae f2 ff ff       	call   800231 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  800f83:	83 c4 0c             	add    $0xc,%esp
  800f86:	68 00 10 00 00       	push   $0x1000
  800f8b:	53                   	push   %ebx
  800f8c:	68 00 00 40 00       	push   $0x400000
  800f91:	e8 fc f9 ff ff       	call   800992 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  800f96:	c7 04 24 eb 26 80 00 	movl   $0x8026eb,(%esp)
  800f9d:	e8 8f f2 ff ff       	call   800231 <cprintf>
}
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	57                   	push   %edi
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
  800fb2:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800fb5:	68 f4 0d 80 00       	push   $0x800df4
  800fba:	e8 9e 0f 00 00       	call   801f5d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fbf:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc4:	cd 30                	int    $0x30
  800fc6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	79 17                	jns    800fea <fork+0x3e>
		panic("sys_exofork failed.");
  800fd3:	83 ec 04             	sub    $0x4,%esp
  800fd6:	68 f9 26 80 00       	push   $0x8026f9
  800fdb:	68 b7 00 00 00       	push   $0xb7
  800fe0:	68 60 26 80 00       	push   $0x802660
  800fe5:	e8 6e f1 ff ff       	call   800158 <_panic>
  800fea:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  800fef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ff3:	75 21                	jne    801016 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff5:	e8 cb fb ff ff       	call   800bc5 <sys_getenvid>
  800ffa:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fff:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801002:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801007:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
  801011:	e9 69 01 00 00       	jmp    80117f <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801016:	89 d8                	mov    %ebx,%eax
  801018:	c1 e8 16             	shr    $0x16,%eax
  80101b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  801022:	a8 01                	test   $0x1,%al
  801024:	0f 84 d6 00 00 00    	je     801100 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  80102a:	89 de                	mov    %ebx,%esi
  80102c:	c1 ee 0c             	shr    $0xc,%esi
  80102f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801036:	a8 01                	test   $0x1,%al
  801038:	0f 84 c2 00 00 00    	je     801100 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  80103e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  801045:	89 f7                	mov    %esi,%edi
  801047:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  80104a:	e8 76 fb ff ff       	call   800bc5 <sys_getenvid>
  80104f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  801052:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801059:	f6 c4 04             	test   $0x4,%ah
  80105c:	74 1c                	je     80107a <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	68 07 0e 00 00       	push   $0xe07
  801066:	57                   	push   %edi
  801067:	ff 75 e0             	pushl  -0x20(%ebp)
  80106a:	57                   	push   %edi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 d4 fb ff ff       	call   800c46 <sys_page_map>
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	e9 86 00 00 00       	jmp    801100 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  80107a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801081:	a8 02                	test   $0x2,%al
  801083:	75 0c                	jne    801091 <fork+0xe5>
  801085:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80108c:	f6 c4 08             	test   $0x8,%ah
  80108f:	74 5b                	je     8010ec <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	68 05 08 00 00       	push   $0x805
  801099:	57                   	push   %edi
  80109a:	ff 75 e0             	pushl  -0x20(%ebp)
  80109d:	57                   	push   %edi
  80109e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a1:	e8 a0 fb ff ff       	call   800c46 <sys_page_map>
  8010a6:	83 c4 20             	add    $0x20,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	79 12                	jns    8010bf <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  8010ad:	50                   	push   %eax
  8010ae:	68 7c 27 80 00       	push   $0x80277c
  8010b3:	6a 5f                	push   $0x5f
  8010b5:	68 60 26 80 00       	push   $0x802660
  8010ba:	e8 99 f0 ff ff       	call   800158 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	68 05 08 00 00       	push   $0x805
  8010c7:	57                   	push   %edi
  8010c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010cb:	50                   	push   %eax
  8010cc:	57                   	push   %edi
  8010cd:	50                   	push   %eax
  8010ce:	e8 73 fb ff ff       	call   800c46 <sys_page_map>
  8010d3:	83 c4 20             	add    $0x20,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	79 26                	jns    801100 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  8010da:	50                   	push   %eax
  8010db:	68 a0 27 80 00       	push   $0x8027a0
  8010e0:	6a 64                	push   $0x64
  8010e2:	68 60 26 80 00       	push   $0x802660
  8010e7:	e8 6c f0 ff ff       	call   800158 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	6a 05                	push   $0x5
  8010f1:	57                   	push   %edi
  8010f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f5:	57                   	push   %edi
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 49 fb ff ff       	call   800c46 <sys_page_map>
  8010fd:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801100:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801106:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80110c:	0f 85 04 ff ff ff    	jne    801016 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	6a 07                	push   $0x7
  801117:	68 00 f0 bf ee       	push   $0xeebff000
  80111c:	ff 75 dc             	pushl  -0x24(%ebp)
  80111f:	e8 df fa ff ff       	call   800c03 <sys_page_alloc>
	if(retv < 0){
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	79 17                	jns    801142 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	68 0d 27 80 00       	push   $0x80270d
  801133:	68 cc 00 00 00       	push   $0xcc
  801138:	68 60 26 80 00       	push   $0x802660
  80113d:	e8 16 f0 ff ff       	call   800158 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	68 c2 1f 80 00       	push   $0x801fc2
  80114a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80114d:	57                   	push   %edi
  80114e:	e8 fb fb ff ff       	call   800d4e <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  801153:	83 c4 08             	add    $0x8,%esp
  801156:	6a 02                	push   $0x2
  801158:	57                   	push   %edi
  801159:	e8 6c fb ff ff       	call   800cca <sys_env_set_status>
	if(retv < 0){
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	79 17                	jns    80117c <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	68 25 27 80 00       	push   $0x802725
  80116d:	68 dd 00 00 00       	push   $0xdd
  801172:	68 60 26 80 00       	push   $0x802660
  801177:	e8 dc ef ff ff       	call   800158 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  80117c:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  80117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sfork>:

// Challenge!
int
sfork(void)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80118d:	68 41 27 80 00       	push   $0x802741
  801192:	68 e8 00 00 00       	push   $0xe8
  801197:	68 60 26 80 00       	push   $0x802660
  80119c:	e8 b7 ef ff ff       	call   800158 <_panic>

008011a1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011a9:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  8011ac:	83 ec 0c             	sub    $0xc,%esp
  8011af:	ff 75 0c             	pushl  0xc(%ebp)
  8011b2:	e8 fc fb ff ff       	call   800db3 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	85 f6                	test   %esi,%esi
  8011bc:	74 1c                	je     8011da <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  8011be:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c3:	8b 40 78             	mov    0x78(%eax),%eax
  8011c6:	89 06                	mov    %eax,(%esi)
  8011c8:	eb 10                	jmp    8011da <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  8011ca:	83 ec 0c             	sub    $0xc,%esp
  8011cd:	68 c2 27 80 00       	push   $0x8027c2
  8011d2:	e8 5a f0 ff ff       	call   800231 <cprintf>
  8011d7:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  8011da:	a1 04 40 80 00       	mov    0x804004,%eax
  8011df:	8b 50 74             	mov    0x74(%eax),%edx
  8011e2:	85 d2                	test   %edx,%edx
  8011e4:	74 e4                	je     8011ca <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  8011e6:	85 db                	test   %ebx,%ebx
  8011e8:	74 05                	je     8011ef <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  8011ea:	8b 40 74             	mov    0x74(%eax),%eax
  8011ed:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f4:	8b 40 70             	mov    0x70(%eax),%eax

}
  8011f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011fa:	5b                   	pop    %ebx
  8011fb:	5e                   	pop    %esi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80120d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801210:	85 db                	test   %ebx,%ebx
  801212:	75 13                	jne    801227 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801214:	6a 00                	push   $0x0
  801216:	68 00 00 c0 ee       	push   $0xeec00000
  80121b:	56                   	push   %esi
  80121c:	57                   	push   %edi
  80121d:	e8 6e fb ff ff       	call   800d90 <sys_ipc_try_send>
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	eb 0e                	jmp    801235 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801227:	ff 75 14             	pushl  0x14(%ebp)
  80122a:	53                   	push   %ebx
  80122b:	56                   	push   %esi
  80122c:	57                   	push   %edi
  80122d:	e8 5e fb ff ff       	call   800d90 <sys_ipc_try_send>
  801232:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801235:	85 c0                	test   %eax,%eax
  801237:	75 d7                	jne    801210 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801247:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80124c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80124f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801255:	8b 52 50             	mov    0x50(%edx),%edx
  801258:	39 ca                	cmp    %ecx,%edx
  80125a:	75 0d                	jne    801269 <ipc_find_env+0x28>
			return envs[i].env_id;
  80125c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80125f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801264:	8b 40 48             	mov    0x48(%eax),%eax
  801267:	eb 0f                	jmp    801278 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801269:	83 c0 01             	add    $0x1,%eax
  80126c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801271:	75 d9                	jne    80124c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127d:	8b 45 08             	mov    0x8(%ebp),%eax
  801280:	05 00 00 00 30       	add    $0x30000000,%eax
  801285:	c1 e8 0c             	shr    $0xc,%eax
}
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80128d:	8b 45 08             	mov    0x8(%ebp),%eax
  801290:	05 00 00 00 30       	add    $0x30000000,%eax
  801295:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	c1 ea 16             	shr    $0x16,%edx
  8012b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b8:	f6 c2 01             	test   $0x1,%dl
  8012bb:	74 11                	je     8012ce <fd_alloc+0x2d>
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	c1 ea 0c             	shr    $0xc,%edx
  8012c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c9:	f6 c2 01             	test   $0x1,%dl
  8012cc:	75 09                	jne    8012d7 <fd_alloc+0x36>
			*fd_store = fd;
  8012ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d5:	eb 17                	jmp    8012ee <fd_alloc+0x4d>
  8012d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012e1:	75 c9                	jne    8012ac <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f6:	83 f8 1f             	cmp    $0x1f,%eax
  8012f9:	77 36                	ja     801331 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012fb:	c1 e0 0c             	shl    $0xc,%eax
  8012fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801303:	89 c2                	mov    %eax,%edx
  801305:	c1 ea 16             	shr    $0x16,%edx
  801308:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	74 24                	je     801338 <fd_lookup+0x48>
  801314:	89 c2                	mov    %eax,%edx
  801316:	c1 ea 0c             	shr    $0xc,%edx
  801319:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801320:	f6 c2 01             	test   $0x1,%dl
  801323:	74 1a                	je     80133f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801325:	8b 55 0c             	mov    0xc(%ebp),%edx
  801328:	89 02                	mov    %eax,(%edx)
	return 0;
  80132a:	b8 00 00 00 00       	mov    $0x0,%eax
  80132f:	eb 13                	jmp    801344 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801331:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801336:	eb 0c                	jmp    801344 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801338:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133d:	eb 05                	jmp    801344 <fd_lookup+0x54>
  80133f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134f:	ba 50 28 80 00       	mov    $0x802850,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801354:	eb 13                	jmp    801369 <dev_lookup+0x23>
  801356:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801359:	39 08                	cmp    %ecx,(%eax)
  80135b:	75 0c                	jne    801369 <dev_lookup+0x23>
			*dev = devtab[i];
  80135d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801360:	89 01                	mov    %eax,(%ecx)
			return 0;
  801362:	b8 00 00 00 00       	mov    $0x0,%eax
  801367:	eb 2e                	jmp    801397 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801369:	8b 02                	mov    (%edx),%eax
  80136b:	85 c0                	test   %eax,%eax
  80136d:	75 e7                	jne    801356 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80136f:	a1 04 40 80 00       	mov    0x804004,%eax
  801374:	8b 40 48             	mov    0x48(%eax),%eax
  801377:	83 ec 04             	sub    $0x4,%esp
  80137a:	51                   	push   %ecx
  80137b:	50                   	push   %eax
  80137c:	68 d4 27 80 00       	push   $0x8027d4
  801381:	e8 ab ee ff ff       	call   800231 <cprintf>
	*dev = 0;
  801386:	8b 45 0c             	mov    0xc(%ebp),%eax
  801389:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
  80139e:	83 ec 10             	sub    $0x10,%esp
  8013a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8013a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013b1:	c1 e8 0c             	shr    $0xc,%eax
  8013b4:	50                   	push   %eax
  8013b5:	e8 36 ff ff ff       	call   8012f0 <fd_lookup>
  8013ba:	83 c4 08             	add    $0x8,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 05                	js     8013c6 <fd_close+0x2d>
	    || fd != fd2)
  8013c1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013c4:	74 0c                	je     8013d2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013c6:	84 db                	test   %bl,%bl
  8013c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cd:	0f 44 c2             	cmove  %edx,%eax
  8013d0:	eb 41                	jmp    801413 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d8:	50                   	push   %eax
  8013d9:	ff 36                	pushl  (%esi)
  8013db:	e8 66 ff ff ff       	call   801346 <dev_lookup>
  8013e0:	89 c3                	mov    %eax,%ebx
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 1a                	js     801403 <fd_close+0x6a>
		if (dev->dev_close)
  8013e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ec:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	74 0b                	je     801403 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	56                   	push   %esi
  8013fc:	ff d0                	call   *%eax
  8013fe:	89 c3                	mov    %eax,%ebx
  801400:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	56                   	push   %esi
  801407:	6a 00                	push   $0x0
  801409:	e8 7a f8 ff ff       	call   800c88 <sys_page_unmap>
	return r;
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	89 d8                	mov    %ebx,%eax
}
  801413:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801416:	5b                   	pop    %ebx
  801417:	5e                   	pop    %esi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    

0080141a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	ff 75 08             	pushl  0x8(%ebp)
  801427:	e8 c4 fe ff ff       	call   8012f0 <fd_lookup>
  80142c:	83 c4 08             	add    $0x8,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 10                	js     801443 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	6a 01                	push   $0x1
  801438:	ff 75 f4             	pushl  -0xc(%ebp)
  80143b:	e8 59 ff ff ff       	call   801399 <fd_close>
  801440:	83 c4 10             	add    $0x10,%esp
}
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <close_all>:

void
close_all(void)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	53                   	push   %ebx
  801449:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80144c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	53                   	push   %ebx
  801455:	e8 c0 ff ff ff       	call   80141a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80145a:	83 c3 01             	add    $0x1,%ebx
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	83 fb 20             	cmp    $0x20,%ebx
  801463:	75 ec                	jne    801451 <close_all+0xc>
		close(i);
}
  801465:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	57                   	push   %edi
  80146e:	56                   	push   %esi
  80146f:	53                   	push   %ebx
  801470:	83 ec 2c             	sub    $0x2c,%esp
  801473:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801476:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	ff 75 08             	pushl  0x8(%ebp)
  80147d:	e8 6e fe ff ff       	call   8012f0 <fd_lookup>
  801482:	83 c4 08             	add    $0x8,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	0f 88 c1 00 00 00    	js     80154e <dup+0xe4>
		return r;
	close(newfdnum);
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	56                   	push   %esi
  801491:	e8 84 ff ff ff       	call   80141a <close>

	newfd = INDEX2FD(newfdnum);
  801496:	89 f3                	mov    %esi,%ebx
  801498:	c1 e3 0c             	shl    $0xc,%ebx
  80149b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014a1:	83 c4 04             	add    $0x4,%esp
  8014a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a7:	e8 de fd ff ff       	call   80128a <fd2data>
  8014ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014ae:	89 1c 24             	mov    %ebx,(%esp)
  8014b1:	e8 d4 fd ff ff       	call   80128a <fd2data>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014bc:	89 f8                	mov    %edi,%eax
  8014be:	c1 e8 16             	shr    $0x16,%eax
  8014c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c8:	a8 01                	test   $0x1,%al
  8014ca:	74 37                	je     801503 <dup+0x99>
  8014cc:	89 f8                	mov    %edi,%eax
  8014ce:	c1 e8 0c             	shr    $0xc,%eax
  8014d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d8:	f6 c2 01             	test   $0x1,%dl
  8014db:	74 26                	je     801503 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ec:	50                   	push   %eax
  8014ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f0:	6a 00                	push   $0x0
  8014f2:	57                   	push   %edi
  8014f3:	6a 00                	push   $0x0
  8014f5:	e8 4c f7 ff ff       	call   800c46 <sys_page_map>
  8014fa:	89 c7                	mov    %eax,%edi
  8014fc:	83 c4 20             	add    $0x20,%esp
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 2e                	js     801531 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801503:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801506:	89 d0                	mov    %edx,%eax
  801508:	c1 e8 0c             	shr    $0xc,%eax
  80150b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	25 07 0e 00 00       	and    $0xe07,%eax
  80151a:	50                   	push   %eax
  80151b:	53                   	push   %ebx
  80151c:	6a 00                	push   $0x0
  80151e:	52                   	push   %edx
  80151f:	6a 00                	push   $0x0
  801521:	e8 20 f7 ff ff       	call   800c46 <sys_page_map>
  801526:	89 c7                	mov    %eax,%edi
  801528:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80152b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80152d:	85 ff                	test   %edi,%edi
  80152f:	79 1d                	jns    80154e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	53                   	push   %ebx
  801535:	6a 00                	push   $0x0
  801537:	e8 4c f7 ff ff       	call   800c88 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801542:	6a 00                	push   $0x0
  801544:	e8 3f f7 ff ff       	call   800c88 <sys_page_unmap>
	return r;
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	89 f8                	mov    %edi,%eax
}
  80154e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801551:	5b                   	pop    %ebx
  801552:	5e                   	pop    %esi
  801553:	5f                   	pop    %edi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	53                   	push   %ebx
  80155a:	83 ec 14             	sub    $0x14,%esp
  80155d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801560:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	53                   	push   %ebx
  801565:	e8 86 fd ff ff       	call   8012f0 <fd_lookup>
  80156a:	83 c4 08             	add    $0x8,%esp
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 6d                	js     8015e0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157d:	ff 30                	pushl  (%eax)
  80157f:	e8 c2 fd ff ff       	call   801346 <dev_lookup>
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	85 c0                	test   %eax,%eax
  801589:	78 4c                	js     8015d7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80158b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80158e:	8b 42 08             	mov    0x8(%edx),%eax
  801591:	83 e0 03             	and    $0x3,%eax
  801594:	83 f8 01             	cmp    $0x1,%eax
  801597:	75 21                	jne    8015ba <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801599:	a1 04 40 80 00       	mov    0x804004,%eax
  80159e:	8b 40 48             	mov    0x48(%eax),%eax
  8015a1:	83 ec 04             	sub    $0x4,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	50                   	push   %eax
  8015a6:	68 15 28 80 00       	push   $0x802815
  8015ab:	e8 81 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b8:	eb 26                	jmp    8015e0 <read+0x8a>
	}
	if (!dev->dev_read)
  8015ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bd:	8b 40 08             	mov    0x8(%eax),%eax
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	74 17                	je     8015db <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	ff 75 10             	pushl  0x10(%ebp)
  8015ca:	ff 75 0c             	pushl  0xc(%ebp)
  8015cd:	52                   	push   %edx
  8015ce:	ff d0                	call   *%eax
  8015d0:	89 c2                	mov    %eax,%edx
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	eb 09                	jmp    8015e0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	eb 05                	jmp    8015e0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015e0:	89 d0                	mov    %edx,%eax
  8015e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	57                   	push   %edi
  8015eb:	56                   	push   %esi
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fb:	eb 21                	jmp    80161e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	89 f0                	mov    %esi,%eax
  801602:	29 d8                	sub    %ebx,%eax
  801604:	50                   	push   %eax
  801605:	89 d8                	mov    %ebx,%eax
  801607:	03 45 0c             	add    0xc(%ebp),%eax
  80160a:	50                   	push   %eax
  80160b:	57                   	push   %edi
  80160c:	e8 45 ff ff ff       	call   801556 <read>
		if (m < 0)
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 10                	js     801628 <readn+0x41>
			return m;
		if (m == 0)
  801618:	85 c0                	test   %eax,%eax
  80161a:	74 0a                	je     801626 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161c:	01 c3                	add    %eax,%ebx
  80161e:	39 f3                	cmp    %esi,%ebx
  801620:	72 db                	jb     8015fd <readn+0x16>
  801622:	89 d8                	mov    %ebx,%eax
  801624:	eb 02                	jmp    801628 <readn+0x41>
  801626:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5f                   	pop    %edi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 14             	sub    $0x14,%esp
  801637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	53                   	push   %ebx
  80163f:	e8 ac fc ff ff       	call   8012f0 <fd_lookup>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	89 c2                	mov    %eax,%edx
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 68                	js     8016b5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801657:	ff 30                	pushl  (%eax)
  801659:	e8 e8 fc ff ff       	call   801346 <dev_lookup>
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	85 c0                	test   %eax,%eax
  801663:	78 47                	js     8016ac <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166c:	75 21                	jne    80168f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80166e:	a1 04 40 80 00       	mov    0x804004,%eax
  801673:	8b 40 48             	mov    0x48(%eax),%eax
  801676:	83 ec 04             	sub    $0x4,%esp
  801679:	53                   	push   %ebx
  80167a:	50                   	push   %eax
  80167b:	68 31 28 80 00       	push   $0x802831
  801680:	e8 ac eb ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80168d:	eb 26                	jmp    8016b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801692:	8b 52 0c             	mov    0xc(%edx),%edx
  801695:	85 d2                	test   %edx,%edx
  801697:	74 17                	je     8016b0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801699:	83 ec 04             	sub    $0x4,%esp
  80169c:	ff 75 10             	pushl  0x10(%ebp)
  80169f:	ff 75 0c             	pushl  0xc(%ebp)
  8016a2:	50                   	push   %eax
  8016a3:	ff d2                	call   *%edx
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	eb 09                	jmp    8016b5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ac:	89 c2                	mov    %eax,%edx
  8016ae:	eb 05                	jmp    8016b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016b5:	89 d0                	mov    %edx,%eax
  8016b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016c5:	50                   	push   %eax
  8016c6:	ff 75 08             	pushl  0x8(%ebp)
  8016c9:	e8 22 fc ff ff       	call   8012f0 <fd_lookup>
  8016ce:	83 c4 08             	add    $0x8,%esp
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 0e                	js     8016e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 14             	sub    $0x14,%esp
  8016ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f2:	50                   	push   %eax
  8016f3:	53                   	push   %ebx
  8016f4:	e8 f7 fb ff ff       	call   8012f0 <fd_lookup>
  8016f9:	83 c4 08             	add    $0x8,%esp
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 65                	js     801767 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801702:	83 ec 08             	sub    $0x8,%esp
  801705:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801708:	50                   	push   %eax
  801709:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170c:	ff 30                	pushl  (%eax)
  80170e:	e8 33 fc ff ff       	call   801346 <dev_lookup>
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	78 44                	js     80175e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801721:	75 21                	jne    801744 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801723:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801728:	8b 40 48             	mov    0x48(%eax),%eax
  80172b:	83 ec 04             	sub    $0x4,%esp
  80172e:	53                   	push   %ebx
  80172f:	50                   	push   %eax
  801730:	68 f4 27 80 00       	push   $0x8027f4
  801735:	e8 f7 ea ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801742:	eb 23                	jmp    801767 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801744:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801747:	8b 52 18             	mov    0x18(%edx),%edx
  80174a:	85 d2                	test   %edx,%edx
  80174c:	74 14                	je     801762 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80174e:	83 ec 08             	sub    $0x8,%esp
  801751:	ff 75 0c             	pushl  0xc(%ebp)
  801754:	50                   	push   %eax
  801755:	ff d2                	call   *%edx
  801757:	89 c2                	mov    %eax,%edx
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	eb 09                	jmp    801767 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175e:	89 c2                	mov    %eax,%edx
  801760:	eb 05                	jmp    801767 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801762:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801767:	89 d0                	mov    %edx,%eax
  801769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	53                   	push   %ebx
  801772:	83 ec 14             	sub    $0x14,%esp
  801775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801778:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	ff 75 08             	pushl  0x8(%ebp)
  80177f:	e8 6c fb ff ff       	call   8012f0 <fd_lookup>
  801784:	83 c4 08             	add    $0x8,%esp
  801787:	89 c2                	mov    %eax,%edx
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 58                	js     8017e5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178d:	83 ec 08             	sub    $0x8,%esp
  801790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801793:	50                   	push   %eax
  801794:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801797:	ff 30                	pushl  (%eax)
  801799:	e8 a8 fb ff ff       	call   801346 <dev_lookup>
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 37                	js     8017dc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ac:	74 32                	je     8017e0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b8:	00 00 00 
	stat->st_isdir = 0;
  8017bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017c2:	00 00 00 
	stat->st_dev = dev;
  8017c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	53                   	push   %ebx
  8017cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d2:	ff 50 14             	call   *0x14(%eax)
  8017d5:	89 c2                	mov    %eax,%edx
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	eb 09                	jmp    8017e5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017dc:	89 c2                	mov    %eax,%edx
  8017de:	eb 05                	jmp    8017e5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017e5:	89 d0                	mov    %edx,%eax
  8017e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	6a 00                	push   $0x0
  8017f6:	ff 75 08             	pushl  0x8(%ebp)
  8017f9:	e8 dc 01 00 00       	call   8019da <open>
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	78 1b                	js     801822 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	ff 75 0c             	pushl  0xc(%ebp)
  80180d:	50                   	push   %eax
  80180e:	e8 5b ff ff ff       	call   80176e <fstat>
  801813:	89 c6                	mov    %eax,%esi
	close(fd);
  801815:	89 1c 24             	mov    %ebx,(%esp)
  801818:	e8 fd fb ff ff       	call   80141a <close>
	return r;
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	89 f0                	mov    %esi,%eax
}
  801822:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801825:	5b                   	pop    %ebx
  801826:	5e                   	pop    %esi
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    

00801829 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	56                   	push   %esi
  80182d:	53                   	push   %ebx
  80182e:	89 c6                	mov    %eax,%esi
  801830:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801832:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801839:	75 12                	jne    80184d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	6a 01                	push   $0x1
  801840:	e8 fc f9 ff ff       	call   801241 <ipc_find_env>
  801845:	a3 00 40 80 00       	mov    %eax,0x804000
  80184a:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80184d:	6a 07                	push   $0x7
  80184f:	68 00 50 80 00       	push   $0x805000
  801854:	56                   	push   %esi
  801855:	ff 35 00 40 80 00    	pushl  0x804000
  80185b:	e8 9e f9 ff ff       	call   8011fe <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801860:	83 c4 0c             	add    $0xc,%esp
  801863:	6a 00                	push   $0x0
  801865:	53                   	push   %ebx
  801866:	6a 00                	push   $0x0
  801868:	e8 34 f9 ff ff       	call   8011a1 <ipc_recv>
}
  80186d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801870:	5b                   	pop    %ebx
  801871:	5e                   	pop    %esi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    

00801874 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801885:	8b 45 0c             	mov    0xc(%ebp),%eax
  801888:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80188d:	ba 00 00 00 00       	mov    $0x0,%edx
  801892:	b8 02 00 00 00       	mov    $0x2,%eax
  801897:	e8 8d ff ff ff       	call   801829 <fsipc>
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8018b9:	e8 6b ff ff ff       	call   801829 <fsipc>
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 04             	sub    $0x4,%esp
  8018c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018da:	b8 05 00 00 00       	mov    $0x5,%eax
  8018df:	e8 45 ff ff ff       	call   801829 <fsipc>
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 2c                	js     801914 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e8:	83 ec 08             	sub    $0x8,%esp
  8018eb:	68 00 50 80 00       	push   $0x805000
  8018f0:	53                   	push   %ebx
  8018f1:	e8 0a ef ff ff       	call   800800 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8018fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801901:	a1 84 50 80 00       	mov    0x805084,%eax
  801906:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801917:	c9                   	leave  
  801918:	c3                   	ret    

00801919 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801922:	8b 55 08             	mov    0x8(%ebp),%edx
  801925:	8b 52 0c             	mov    0xc(%edx),%edx
  801928:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80192e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801933:	50                   	push   %eax
  801934:	ff 75 0c             	pushl  0xc(%ebp)
  801937:	68 08 50 80 00       	push   $0x805008
  80193c:	e8 51 f0 ff ff       	call   800992 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
  801946:	b8 04 00 00 00       	mov    $0x4,%eax
  80194b:	e8 d9 fe ff ff       	call   801829 <fsipc>
	//panic("devfile_write not implemented");
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	8b 40 0c             	mov    0xc(%eax),%eax
  801960:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801965:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
  801970:	b8 03 00 00 00       	mov    $0x3,%eax
  801975:	e8 af fe ff ff       	call   801829 <fsipc>
  80197a:	89 c3                	mov    %eax,%ebx
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 51                	js     8019d1 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801980:	39 c6                	cmp    %eax,%esi
  801982:	73 19                	jae    80199d <devfile_read+0x4b>
  801984:	68 60 28 80 00       	push   $0x802860
  801989:	68 67 28 80 00       	push   $0x802867
  80198e:	68 80 00 00 00       	push   $0x80
  801993:	68 7c 28 80 00       	push   $0x80287c
  801998:	e8 bb e7 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80199d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a2:	7e 19                	jle    8019bd <devfile_read+0x6b>
  8019a4:	68 87 28 80 00       	push   $0x802887
  8019a9:	68 67 28 80 00       	push   $0x802867
  8019ae:	68 81 00 00 00       	push   $0x81
  8019b3:	68 7c 28 80 00       	push   $0x80287c
  8019b8:	e8 9b e7 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019bd:	83 ec 04             	sub    $0x4,%esp
  8019c0:	50                   	push   %eax
  8019c1:	68 00 50 80 00       	push   $0x805000
  8019c6:	ff 75 0c             	pushl  0xc(%ebp)
  8019c9:	e8 c4 ef ff ff       	call   800992 <memmove>
	return r;
  8019ce:	83 c4 10             	add    $0x10,%esp
}
  8019d1:	89 d8                	mov    %ebx,%eax
  8019d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    

008019da <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	53                   	push   %ebx
  8019de:	83 ec 20             	sub    $0x20,%esp
  8019e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e4:	53                   	push   %ebx
  8019e5:	e8 dd ed ff ff       	call   8007c7 <strlen>
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f2:	7f 67                	jg     801a5b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fa:	50                   	push   %eax
  8019fb:	e8 a1 f8 ff ff       	call   8012a1 <fd_alloc>
  801a00:	83 c4 10             	add    $0x10,%esp
		return r;
  801a03:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 57                	js     801a60 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	53                   	push   %ebx
  801a0d:	68 00 50 80 00       	push   $0x805000
  801a12:	e8 e9 ed ff ff       	call   800800 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1a:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a22:	b8 01 00 00 00       	mov    $0x1,%eax
  801a27:	e8 fd fd ff ff       	call   801829 <fsipc>
  801a2c:	89 c3                	mov    %eax,%ebx
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	85 c0                	test   %eax,%eax
  801a33:	79 14                	jns    801a49 <open+0x6f>
		
		fd_close(fd, 0);
  801a35:	83 ec 08             	sub    $0x8,%esp
  801a38:	6a 00                	push   $0x0
  801a3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3d:	e8 57 f9 ff ff       	call   801399 <fd_close>
		return r;
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	89 da                	mov    %ebx,%edx
  801a47:	eb 17                	jmp    801a60 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4f:	e8 26 f8 ff ff       	call   80127a <fd2num>
  801a54:	89 c2                	mov    %eax,%edx
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	eb 05                	jmp    801a60 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a5b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801a60:	89 d0                	mov    %edx,%eax
  801a62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a72:	b8 08 00 00 00       	mov    $0x8,%eax
  801a77:	e8 ad fd ff ff       	call   801829 <fsipc>
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	56                   	push   %esi
  801a82:	53                   	push   %ebx
  801a83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	ff 75 08             	pushl  0x8(%ebp)
  801a8c:	e8 f9 f7 ff ff       	call   80128a <fd2data>
  801a91:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a93:	83 c4 08             	add    $0x8,%esp
  801a96:	68 93 28 80 00       	push   $0x802893
  801a9b:	53                   	push   %ebx
  801a9c:	e8 5f ed ff ff       	call   800800 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa1:	8b 46 04             	mov    0x4(%esi),%eax
  801aa4:	2b 06                	sub    (%esi),%eax
  801aa6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab3:	00 00 00 
	stat->st_dev = &devpipe;
  801ab6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801abd:	30 80 00 
	return 0;
}
  801ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac8:	5b                   	pop    %ebx
  801ac9:	5e                   	pop    %esi
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	53                   	push   %ebx
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ad6:	53                   	push   %ebx
  801ad7:	6a 00                	push   $0x0
  801ad9:	e8 aa f1 ff ff       	call   800c88 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ade:	89 1c 24             	mov    %ebx,(%esp)
  801ae1:	e8 a4 f7 ff ff       	call   80128a <fd2data>
  801ae6:	83 c4 08             	add    $0x8,%esp
  801ae9:	50                   	push   %eax
  801aea:	6a 00                	push   $0x0
  801aec:	e8 97 f1 ff ff       	call   800c88 <sys_page_unmap>
}
  801af1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	57                   	push   %edi
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	83 ec 1c             	sub    $0x1c,%esp
  801aff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b02:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b04:	a1 04 40 80 00       	mov    0x804004,%eax
  801b09:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b0c:	83 ec 0c             	sub    $0xc,%esp
  801b0f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b12:	e8 cf 04 00 00       	call   801fe6 <pageref>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	89 3c 24             	mov    %edi,(%esp)
  801b1c:	e8 c5 04 00 00       	call   801fe6 <pageref>
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	39 c3                	cmp    %eax,%ebx
  801b26:	0f 94 c1             	sete   %cl
  801b29:	0f b6 c9             	movzbl %cl,%ecx
  801b2c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b2f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b35:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b38:	39 ce                	cmp    %ecx,%esi
  801b3a:	74 1b                	je     801b57 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b3c:	39 c3                	cmp    %eax,%ebx
  801b3e:	75 c4                	jne    801b04 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b40:	8b 42 58             	mov    0x58(%edx),%eax
  801b43:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b46:	50                   	push   %eax
  801b47:	56                   	push   %esi
  801b48:	68 9a 28 80 00       	push   $0x80289a
  801b4d:	e8 df e6 ff ff       	call   800231 <cprintf>
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	eb ad                	jmp    801b04 <_pipeisclosed+0xe>
	}
}
  801b57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 28             	sub    $0x28,%esp
  801b6b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b6e:	56                   	push   %esi
  801b6f:	e8 16 f7 ff ff       	call   80128a <fd2data>
  801b74:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	bf 00 00 00 00       	mov    $0x0,%edi
  801b7e:	eb 4b                	jmp    801bcb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b80:	89 da                	mov    %ebx,%edx
  801b82:	89 f0                	mov    %esi,%eax
  801b84:	e8 6d ff ff ff       	call   801af6 <_pipeisclosed>
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	75 48                	jne    801bd5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b8d:	e8 52 f0 ff ff       	call   800be4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b92:	8b 43 04             	mov    0x4(%ebx),%eax
  801b95:	8b 0b                	mov    (%ebx),%ecx
  801b97:	8d 51 20             	lea    0x20(%ecx),%edx
  801b9a:	39 d0                	cmp    %edx,%eax
  801b9c:	73 e2                	jae    801b80 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ba5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ba8:	89 c2                	mov    %eax,%edx
  801baa:	c1 fa 1f             	sar    $0x1f,%edx
  801bad:	89 d1                	mov    %edx,%ecx
  801baf:	c1 e9 1b             	shr    $0x1b,%ecx
  801bb2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bb5:	83 e2 1f             	and    $0x1f,%edx
  801bb8:	29 ca                	sub    %ecx,%edx
  801bba:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bbe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bc2:	83 c0 01             	add    $0x1,%eax
  801bc5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc8:	83 c7 01             	add    $0x1,%edi
  801bcb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bce:	75 c2                	jne    801b92 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bd0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd3:	eb 05                	jmp    801bda <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bd5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    

00801be2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	57                   	push   %edi
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	83 ec 18             	sub    $0x18,%esp
  801beb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bee:	57                   	push   %edi
  801bef:	e8 96 f6 ff ff       	call   80128a <fd2data>
  801bf4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bfe:	eb 3d                	jmp    801c3d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c00:	85 db                	test   %ebx,%ebx
  801c02:	74 04                	je     801c08 <devpipe_read+0x26>
				return i;
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	eb 44                	jmp    801c4c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c08:	89 f2                	mov    %esi,%edx
  801c0a:	89 f8                	mov    %edi,%eax
  801c0c:	e8 e5 fe ff ff       	call   801af6 <_pipeisclosed>
  801c11:	85 c0                	test   %eax,%eax
  801c13:	75 32                	jne    801c47 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c15:	e8 ca ef ff ff       	call   800be4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c1a:	8b 06                	mov    (%esi),%eax
  801c1c:	3b 46 04             	cmp    0x4(%esi),%eax
  801c1f:	74 df                	je     801c00 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c21:	99                   	cltd   
  801c22:	c1 ea 1b             	shr    $0x1b,%edx
  801c25:	01 d0                	add    %edx,%eax
  801c27:	83 e0 1f             	and    $0x1f,%eax
  801c2a:	29 d0                	sub    %edx,%eax
  801c2c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c34:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c37:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3a:	83 c3 01             	add    $0x1,%ebx
  801c3d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c40:	75 d8                	jne    801c1a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c42:	8b 45 10             	mov    0x10(%ebp),%eax
  801c45:	eb 05                	jmp    801c4c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c47:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5f                   	pop    %edi
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    

00801c54 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	56                   	push   %esi
  801c58:	53                   	push   %ebx
  801c59:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5f:	50                   	push   %eax
  801c60:	e8 3c f6 ff ff       	call   8012a1 <fd_alloc>
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	89 c2                	mov    %eax,%edx
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	0f 88 2c 01 00 00    	js     801d9e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c72:	83 ec 04             	sub    $0x4,%esp
  801c75:	68 07 04 00 00       	push   $0x407
  801c7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7d:	6a 00                	push   $0x0
  801c7f:	e8 7f ef ff ff       	call   800c03 <sys_page_alloc>
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	89 c2                	mov    %eax,%edx
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	0f 88 0d 01 00 00    	js     801d9e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c91:	83 ec 0c             	sub    $0xc,%esp
  801c94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c97:	50                   	push   %eax
  801c98:	e8 04 f6 ff ff       	call   8012a1 <fd_alloc>
  801c9d:	89 c3                	mov    %eax,%ebx
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	0f 88 e2 00 00 00    	js     801d8c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801caa:	83 ec 04             	sub    $0x4,%esp
  801cad:	68 07 04 00 00       	push   $0x407
  801cb2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb5:	6a 00                	push   $0x0
  801cb7:	e8 47 ef ff ff       	call   800c03 <sys_page_alloc>
  801cbc:	89 c3                	mov    %eax,%ebx
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	0f 88 c3 00 00 00    	js     801d8c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cc9:	83 ec 0c             	sub    $0xc,%esp
  801ccc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccf:	e8 b6 f5 ff ff       	call   80128a <fd2data>
  801cd4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd6:	83 c4 0c             	add    $0xc,%esp
  801cd9:	68 07 04 00 00       	push   $0x407
  801cde:	50                   	push   %eax
  801cdf:	6a 00                	push   $0x0
  801ce1:	e8 1d ef ff ff       	call   800c03 <sys_page_alloc>
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	0f 88 89 00 00 00    	js     801d7c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf3:	83 ec 0c             	sub    $0xc,%esp
  801cf6:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf9:	e8 8c f5 ff ff       	call   80128a <fd2data>
  801cfe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d05:	50                   	push   %eax
  801d06:	6a 00                	push   $0x0
  801d08:	56                   	push   %esi
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 36 ef ff ff       	call   800c46 <sys_page_map>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	83 c4 20             	add    $0x20,%esp
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 55                	js     801d6e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d19:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d22:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d27:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d2e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d37:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	ff 75 f4             	pushl  -0xc(%ebp)
  801d49:	e8 2c f5 ff ff       	call   80127a <fd2num>
  801d4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d51:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d53:	83 c4 04             	add    $0x4,%esp
  801d56:	ff 75 f0             	pushl  -0x10(%ebp)
  801d59:	e8 1c f5 ff ff       	call   80127a <fd2num>
  801d5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d61:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	ba 00 00 00 00       	mov    $0x0,%edx
  801d6c:	eb 30                	jmp    801d9e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d6e:	83 ec 08             	sub    $0x8,%esp
  801d71:	56                   	push   %esi
  801d72:	6a 00                	push   $0x0
  801d74:	e8 0f ef ff ff       	call   800c88 <sys_page_unmap>
  801d79:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d7c:	83 ec 08             	sub    $0x8,%esp
  801d7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d82:	6a 00                	push   $0x0
  801d84:	e8 ff ee ff ff       	call   800c88 <sys_page_unmap>
  801d89:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d8c:	83 ec 08             	sub    $0x8,%esp
  801d8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d92:	6a 00                	push   $0x0
  801d94:	e8 ef ee ff ff       	call   800c88 <sys_page_unmap>
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d9e:	89 d0                	mov    %edx,%eax
  801da0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db0:	50                   	push   %eax
  801db1:	ff 75 08             	pushl  0x8(%ebp)
  801db4:	e8 37 f5 ff ff       	call   8012f0 <fd_lookup>
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 18                	js     801dd8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dc0:	83 ec 0c             	sub    $0xc,%esp
  801dc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc6:	e8 bf f4 ff ff       	call   80128a <fd2data>
	return _pipeisclosed(fd, p);
  801dcb:	89 c2                	mov    %eax,%edx
  801dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd0:	e8 21 fd ff ff       	call   801af6 <_pipeisclosed>
  801dd5:	83 c4 10             	add    $0x10,%esp
}
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ddd:	b8 00 00 00 00       	mov    $0x0,%eax
  801de2:	5d                   	pop    %ebp
  801de3:	c3                   	ret    

00801de4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dea:	68 b2 28 80 00       	push   $0x8028b2
  801def:	ff 75 0c             	pushl  0xc(%ebp)
  801df2:	e8 09 ea ff ff       	call   800800 <strcpy>
	return 0;
}
  801df7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfc:	c9                   	leave  
  801dfd:	c3                   	ret    

00801dfe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	57                   	push   %edi
  801e02:	56                   	push   %esi
  801e03:	53                   	push   %ebx
  801e04:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e0f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e15:	eb 2d                	jmp    801e44 <devcons_write+0x46>
		m = n - tot;
  801e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e1a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e1c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e1f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e24:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e27:	83 ec 04             	sub    $0x4,%esp
  801e2a:	53                   	push   %ebx
  801e2b:	03 45 0c             	add    0xc(%ebp),%eax
  801e2e:	50                   	push   %eax
  801e2f:	57                   	push   %edi
  801e30:	e8 5d eb ff ff       	call   800992 <memmove>
		sys_cputs(buf, m);
  801e35:	83 c4 08             	add    $0x8,%esp
  801e38:	53                   	push   %ebx
  801e39:	57                   	push   %edi
  801e3a:	e8 08 ed ff ff       	call   800b47 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e3f:	01 de                	add    %ebx,%esi
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	89 f0                	mov    %esi,%eax
  801e46:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e49:	72 cc                	jb     801e17 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4e:	5b                   	pop    %ebx
  801e4f:	5e                   	pop    %esi
  801e50:	5f                   	pop    %edi
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 08             	sub    $0x8,%esp
  801e59:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e62:	74 2a                	je     801e8e <devcons_read+0x3b>
  801e64:	eb 05                	jmp    801e6b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e66:	e8 79 ed ff ff       	call   800be4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e6b:	e8 f5 ec ff ff       	call   800b65 <sys_cgetc>
  801e70:	85 c0                	test   %eax,%eax
  801e72:	74 f2                	je     801e66 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e74:	85 c0                	test   %eax,%eax
  801e76:	78 16                	js     801e8e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e78:	83 f8 04             	cmp    $0x4,%eax
  801e7b:	74 0c                	je     801e89 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e80:	88 02                	mov    %al,(%edx)
	return 1;
  801e82:	b8 01 00 00 00       	mov    $0x1,%eax
  801e87:	eb 05                	jmp    801e8e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e89:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e8e:	c9                   	leave  
  801e8f:	c3                   	ret    

00801e90 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e96:	8b 45 08             	mov    0x8(%ebp),%eax
  801e99:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e9c:	6a 01                	push   $0x1
  801e9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea1:	50                   	push   %eax
  801ea2:	e8 a0 ec ff ff       	call   800b47 <sys_cputs>
}
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <getchar>:

int
getchar(void)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eb2:	6a 01                	push   $0x1
  801eb4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb7:	50                   	push   %eax
  801eb8:	6a 00                	push   $0x0
  801eba:	e8 97 f6 ff ff       	call   801556 <read>
	if (r < 0)
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	78 0f                	js     801ed5 <getchar+0x29>
		return r;
	if (r < 1)
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	7e 06                	jle    801ed0 <getchar+0x24>
		return -E_EOF;
	return c;
  801eca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ece:	eb 05                	jmp    801ed5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ed0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ed5:	c9                   	leave  
  801ed6:	c3                   	ret    

00801ed7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801edd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee0:	50                   	push   %eax
  801ee1:	ff 75 08             	pushl  0x8(%ebp)
  801ee4:	e8 07 f4 ff ff       	call   8012f0 <fd_lookup>
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 11                	js     801f01 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef9:	39 10                	cmp    %edx,(%eax)
  801efb:	0f 94 c0             	sete   %al
  801efe:	0f b6 c0             	movzbl %al,%eax
}
  801f01:	c9                   	leave  
  801f02:	c3                   	ret    

00801f03 <opencons>:

int
opencons(void)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0c:	50                   	push   %eax
  801f0d:	e8 8f f3 ff ff       	call   8012a1 <fd_alloc>
  801f12:	83 c4 10             	add    $0x10,%esp
		return r;
  801f15:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 3e                	js     801f59 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f1b:	83 ec 04             	sub    $0x4,%esp
  801f1e:	68 07 04 00 00       	push   $0x407
  801f23:	ff 75 f4             	pushl  -0xc(%ebp)
  801f26:	6a 00                	push   $0x0
  801f28:	e8 d6 ec ff ff       	call   800c03 <sys_page_alloc>
  801f2d:	83 c4 10             	add    $0x10,%esp
		return r;
  801f30:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f32:	85 c0                	test   %eax,%eax
  801f34:	78 23                	js     801f59 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f36:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f44:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f4b:	83 ec 0c             	sub    $0xc,%esp
  801f4e:	50                   	push   %eax
  801f4f:	e8 26 f3 ff ff       	call   80127a <fd2num>
  801f54:	89 c2                	mov    %eax,%edx
  801f56:	83 c4 10             	add    $0x10,%esp
}
  801f59:	89 d0                	mov    %edx,%eax
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801f63:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f6a:	75 4c                	jne    801fb8 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801f6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801f71:	8b 40 48             	mov    0x48(%eax),%eax
  801f74:	83 ec 04             	sub    $0x4,%esp
  801f77:	6a 07                	push   $0x7
  801f79:	68 00 f0 bf ee       	push   $0xeebff000
  801f7e:	50                   	push   %eax
  801f7f:	e8 7f ec ff ff       	call   800c03 <sys_page_alloc>
		if(retv != 0){
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	74 14                	je     801f9f <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801f8b:	83 ec 04             	sub    $0x4,%esp
  801f8e:	68 c0 28 80 00       	push   $0x8028c0
  801f93:	6a 27                	push   $0x27
  801f95:	68 ec 28 80 00       	push   $0x8028ec
  801f9a:	e8 b9 e1 ff ff       	call   800158 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa4:	8b 40 48             	mov    0x48(%eax),%eax
  801fa7:	83 ec 08             	sub    $0x8,%esp
  801faa:	68 c2 1f 80 00       	push   $0x801fc2
  801faf:	50                   	push   %eax
  801fb0:	e8 99 ed ff ff       	call   800d4e <sys_env_set_pgfault_upcall>
  801fb5:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbb:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801fc0:	c9                   	leave  
  801fc1:	c3                   	ret    

00801fc2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fc2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fc3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fc8:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  801fca:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  801fcd:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  801fd1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  801fd6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  801fda:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  801fdc:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  801fdf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  801fe0:	83 c4 04             	add    $0x4,%esp
	popfl
  801fe3:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fe4:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fe5:	c3                   	ret    

00801fe6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fec:	89 d0                	mov    %edx,%eax
  801fee:	c1 e8 16             	shr    $0x16,%eax
  801ff1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffd:	f6 c1 01             	test   $0x1,%cl
  802000:	74 1d                	je     80201f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802002:	c1 ea 0c             	shr    $0xc,%edx
  802005:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80200c:	f6 c2 01             	test   $0x1,%dl
  80200f:	74 0e                	je     80201f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802011:	c1 ea 0c             	shr    $0xc,%edx
  802014:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80201b:	ef 
  80201c:	0f b7 c0             	movzwl %ax,%eax
}
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    
  802021:	66 90                	xchg   %ax,%ax
  802023:	66 90                	xchg   %ax,%ax
  802025:	66 90                	xchg   %ax,%ax
  802027:	66 90                	xchg   %ax,%ax
  802029:	66 90                	xchg   %ax,%ax
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

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
