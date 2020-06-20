
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
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
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 80 	movl   $0x802480,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 86 24 80 00       	push   $0x802486
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 95 24 80 00 	movl   $0x802495,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 a8 24 80 00       	push   $0x8024a8
  800068:	e8 23 15 00 00       	call   801590 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ae 24 80 00       	push   $0x8024ae
  80007c:	6a 0f                	push   $0xf
  80007e:	68 c4 24 80 00       	push   $0x8024c4
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 d1 24 80 00       	push   $0x8024d1
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 d9 0a 00 00       	call   800b83 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 50 10 00 00       	call   80110c <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 e4 24 80 00       	push   $0x8024e4
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 f8 0e 00 00       	call   800fd0 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 0c 25 80 00       	push   $0x80250c
  8000f0:	68 15 25 80 00       	push   $0x802515
  8000f5:	68 1f 25 80 00       	push   $0x80251f
  8000fa:	68 1e 25 80 00       	push   $0x80251e
  8000ff:	e8 71 1a 00 00       	call   801b75 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 24 25 80 00       	push   $0x802524
  800111:	6a 1a                	push   $0x1a
  800113:	68 c4 24 80 00       	push   $0x8024c4
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 3b 25 80 00       	push   $0x80253b
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 bd 0a 00 00       	call   800c01 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 76 0e 00 00       	call   800ffb <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 31 0a 00 00       	call   800bc0 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 5a 0a 00 00       	call   800c01 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 58 25 80 00       	push   $0x802558
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 79 09 00 00       	call   800b83 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 54 01 00 00       	call   8003a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 1e 09 00 00       	call   800b83 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 0b 1f 00 00       	call   8021e0 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 f8 1f 00 00       	call   802310 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 7b 25 80 00 	movsbl 0x80257b(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800333:	83 fa 01             	cmp    $0x1,%edx
  800336:	7e 0e                	jle    800346 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	8b 52 04             	mov    0x4(%edx),%edx
  800344:	eb 22                	jmp    800368 <getuint+0x38>
	else if (lflag)
  800346:	85 d2                	test   %edx,%edx
  800348:	74 10                	je     80035a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	ba 00 00 00 00       	mov    $0x0,%edx
  800358:	eb 0e                	jmp    800368 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800390:	50                   	push   %eax
  800391:	ff 75 10             	pushl  0x10(%ebp)
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	e8 05 00 00 00       	call   8003a4 <vprintfmt>
	va_end(ap);
}
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 2c             	sub    $0x2c,%esp
  8003ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b6:	eb 12                	jmp    8003ca <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 d3 03 00 00    	je     800793 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	ff d6                	call   *%esi
  8003c7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e2                	jne    8003b8 <vprintfmt+0x14>
  8003d6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003da:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	eb 07                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 47 01             	lea    0x1(%edi),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	0f b6 07             	movzbl (%edi),%eax
  800406:	0f b6 c8             	movzbl %al,%ecx
  800409:	83 e8 23             	sub    $0x23,%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 64 03 00 00    	ja     800778 <vprintfmt+0x3d4>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800421:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800425:	eb d6                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800432:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800435:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800439:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043f:	83 fa 09             	cmp    $0x9,%edx
  800442:	77 39                	ja     80047d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800444:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800447:	eb e9                	jmp    800432 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 48 04             	lea    0x4(%eax),%ecx
  80044f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045a:	eb 27                	jmp    800483 <vprintfmt+0xdf>
  80045c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	b9 00 00 00 00       	mov    $0x0,%ecx
  800466:	0f 49 c8             	cmovns %eax,%ecx
  800469:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046f:	eb 8c                	jmp    8003fd <vprintfmt+0x59>
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800474:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047b:	eb 80                	jmp    8003fd <vprintfmt+0x59>
  80047d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800480:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	0f 89 70 ff ff ff    	jns    8003fd <vprintfmt+0x59>
				width = precision, precision = -1;
  80048d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800490:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800493:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80049a:	e9 5e ff ff ff       	jmp    8003fd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a5:	e9 53 ff ff ff       	jmp    8003fd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 30                	pushl  (%eax)
  8004b9:	ff d6                	call   *%esi
			break;
  8004bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 04 ff ff ff       	jmp    8003ca <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	99                   	cltd   
  8004d2:	31 d0                	xor    %edx,%eax
  8004d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 0f             	cmp    $0xf,%eax
  8004d9:	7f 0b                	jg     8004e6 <vprintfmt+0x142>
  8004db:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 18                	jne    8004fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	68 93 25 80 00       	push   $0x802593
  8004ec:	53                   	push   %ebx
  8004ed:	56                   	push   %esi
  8004ee:	e8 94 fe ff ff       	call   800387 <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f9:	e9 cc fe ff ff       	jmp    8003ca <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fe:	52                   	push   %edx
  8004ff:	68 51 29 80 00       	push   $0x802951
  800504:	53                   	push   %ebx
  800505:	56                   	push   %esi
  800506:	e8 7c fe ff ff       	call   800387 <printfmt>
  80050b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	e9 b4 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800521:	85 ff                	test   %edi,%edi
  800523:	b8 8c 25 80 00       	mov    $0x80258c,%eax
  800528:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052f:	0f 8e 94 00 00 00    	jle    8005c9 <vprintfmt+0x225>
  800535:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800539:	0f 84 98 00 00 00    	je     8005d7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 c8             	pushl  -0x38(%ebp)
  800545:	57                   	push   %edi
  800546:	e8 d0 02 00 00       	call   80081b <strnlen>
  80054b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800556:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800560:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	eb 0f                	jmp    800573 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	ff 75 e0             	pushl  -0x20(%ebp)
  80056b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 ef 01             	sub    $0x1,%edi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 ff                	test   %edi,%edi
  800575:	7f ed                	jg     800564 <vprintfmt+0x1c0>
  800577:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	0f 49 c1             	cmovns %ecx,%eax
  800587:	29 c1                	sub    %eax,%ecx
  800589:	89 75 08             	mov    %esi,0x8(%ebp)
  80058c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80058f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800592:	89 cb                	mov    %ecx,%ebx
  800594:	eb 4d                	jmp    8005e3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059a:	74 1b                	je     8005b7 <vprintfmt+0x213>
  80059c:	0f be c0             	movsbl %al,%eax
  80059f:	83 e8 20             	sub    $0x20,%eax
  8005a2:	83 f8 5e             	cmp    $0x5e,%eax
  8005a5:	76 10                	jbe    8005b7 <vprintfmt+0x213>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	6a 3f                	push   $0x3f
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	eb 0d                	jmp    8005c4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	ff 75 0c             	pushl  0xc(%ebp)
  8005bd:	52                   	push   %edx
  8005be:	ff 55 08             	call   *0x8(%ebp)
  8005c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	eb 1a                	jmp    8005e3 <vprintfmt+0x23f>
  8005c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cc:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d5:	eb 0c                	jmp    8005e3 <vprintfmt+0x23f>
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e3:	83 c7 01             	add    $0x1,%edi
  8005e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ea:	0f be d0             	movsbl %al,%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	74 23                	je     800614 <vprintfmt+0x270>
  8005f1:	85 f6                	test   %esi,%esi
  8005f3:	78 a1                	js     800596 <vprintfmt+0x1f2>
  8005f5:	83 ee 01             	sub    $0x1,%esi
  8005f8:	79 9c                	jns    800596 <vprintfmt+0x1f2>
  8005fa:	89 df                	mov    %ebx,%edi
  8005fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800602:	eb 18                	jmp    80061c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	6a 20                	push   $0x20
  80060a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	eb 08                	jmp    80061c <vprintfmt+0x278>
  800614:	89 df                	mov    %ebx,%edi
  800616:	8b 75 08             	mov    0x8(%ebp),%esi
  800619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f e4                	jg     800604 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800623:	e9 a2 fd ff ff       	jmp    8003ca <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800628:	83 fa 01             	cmp    $0x1,%edx
  80062b:	7e 16                	jle    800643 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 08             	lea    0x8(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 50 04             	mov    0x4(%eax),%edx
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80063e:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800641:	eb 32                	jmp    800675 <vprintfmt+0x2d1>
	else if (lflag)
  800643:	85 d2                	test   %edx,%edx
  800645:	74 18                	je     80065f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800655:	89 c1                	mov    %eax,%ecx
  800657:	c1 f9 1f             	sar    $0x1f,%ecx
  80065a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80065d:	eb 16                	jmp    800675 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80066d:	89 c1                	mov    %eax,%ecx
  80066f:	c1 f9 1f             	sar    $0x1f,%ecx
  800672:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800678:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80067b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800681:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800686:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80068a:	0f 89 b0 00 00 00    	jns    800740 <vprintfmt+0x39c>
				putch('-', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 2d                	push   $0x2d
  800696:	ff d6                	call   *%esi
				num = -(long long) num;
  800698:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80069b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80069e:	f7 d8                	neg    %eax
  8006a0:	83 d2 00             	adc    $0x0,%edx
  8006a3:	f7 da                	neg    %edx
  8006a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ab:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b3:	e9 88 00 00 00       	jmp    800740 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bb:	e8 70 fc ff ff       	call   800330 <getuint>
  8006c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006cb:	eb 73                	jmp    800740 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8006cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d0:	e8 5b fc ff ff       	call   800330 <getuint>
  8006d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	6a 58                	push   $0x58
  8006e1:	ff d6                	call   *%esi
			putch('X', putdat);
  8006e3:	83 c4 08             	add    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	6a 58                	push   $0x58
  8006e9:	ff d6                	call   *%esi
			putch('X', putdat);
  8006eb:	83 c4 08             	add    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	6a 58                	push   $0x58
  8006f1:	ff d6                	call   *%esi
			goto number;
  8006f3:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8006f6:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006fb:	eb 43                	jmp    800740 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 30                	push   $0x30
  800703:	ff d6                	call   *%esi
			putch('x', putdat);
  800705:	83 c4 08             	add    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 78                	push   $0x78
  80070b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 50 04             	lea    0x4(%eax),%edx
  800713:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800716:	8b 00                	mov    (%eax),%eax
  800718:	ba 00 00 00 00       	mov    $0x0,%edx
  80071d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800720:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800723:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800726:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80072b:	eb 13                	jmp    800740 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
  800730:	e8 fb fb ff ff       	call   800330 <getuint>
  800735:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800738:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80073b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800740:	83 ec 0c             	sub    $0xc,%esp
  800743:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800747:	52                   	push   %edx
  800748:	ff 75 e0             	pushl  -0x20(%ebp)
  80074b:	50                   	push   %eax
  80074c:	ff 75 dc             	pushl  -0x24(%ebp)
  80074f:	ff 75 d8             	pushl  -0x28(%ebp)
  800752:	89 da                	mov    %ebx,%edx
  800754:	89 f0                	mov    %esi,%eax
  800756:	e8 26 fb ff ff       	call   800281 <printnum>
			break;
  80075b:	83 c4 20             	add    $0x20,%esp
  80075e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800761:	e9 64 fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	51                   	push   %ecx
  80076b:	ff d6                	call   *%esi
			break;
  80076d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800773:	e9 52 fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	53                   	push   %ebx
  80077c:	6a 25                	push   $0x25
  80077e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	eb 03                	jmp    800788 <vprintfmt+0x3e4>
  800785:	83 ef 01             	sub    $0x1,%edi
  800788:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80078c:	75 f7                	jne    800785 <vprintfmt+0x3e1>
  80078e:	e9 37 fc ff ff       	jmp    8003ca <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800793:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5f                   	pop    %edi
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	83 ec 18             	sub    $0x18,%esp
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b8:	85 c0                	test   %eax,%eax
  8007ba:	74 26                	je     8007e2 <vsnprintf+0x47>
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	7e 22                	jle    8007e2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c0:	ff 75 14             	pushl  0x14(%ebp)
  8007c3:	ff 75 10             	pushl  0x10(%ebp)
  8007c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c9:	50                   	push   %eax
  8007ca:	68 6a 03 80 00       	push   $0x80036a
  8007cf:	e8 d0 fb ff ff       	call   8003a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	eb 05                	jmp    8007e7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f2:	50                   	push   %eax
  8007f3:	ff 75 10             	pushl  0x10(%ebp)
  8007f6:	ff 75 0c             	pushl  0xc(%ebp)
  8007f9:	ff 75 08             	pushl  0x8(%ebp)
  8007fc:	e8 9a ff ff ff       	call   80079b <vsnprintf>
	va_end(ap);

	return rc;
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
  80080e:	eb 03                	jmp    800813 <strlen+0x10>
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800813:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800817:	75 f7                	jne    800810 <strlen+0xd>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800824:	ba 00 00 00 00       	mov    $0x0,%edx
  800829:	eb 03                	jmp    80082e <strnlen+0x13>
		n++;
  80082b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082e:	39 c2                	cmp    %eax,%edx
  800830:	74 08                	je     80083a <strnlen+0x1f>
  800832:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800836:	75 f3                	jne    80082b <strnlen+0x10>
  800838:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	53                   	push   %ebx
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800846:	89 c2                	mov    %eax,%edx
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800852:	88 5a ff             	mov    %bl,-0x1(%edx)
  800855:	84 db                	test   %bl,%bl
  800857:	75 ef                	jne    800848 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800859:	5b                   	pop    %ebx
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	53                   	push   %ebx
  800860:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800863:	53                   	push   %ebx
  800864:	e8 9a ff ff ff       	call   800803 <strlen>
  800869:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80086c:	ff 75 0c             	pushl  0xc(%ebp)
  80086f:	01 d8                	add    %ebx,%eax
  800871:	50                   	push   %eax
  800872:	e8 c5 ff ff ff       	call   80083c <strcpy>
	return dst;
}
  800877:	89 d8                	mov    %ebx,%eax
  800879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	89 f3                	mov    %esi,%ebx
  80088b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088e:	89 f2                	mov    %esi,%edx
  800890:	eb 0f                	jmp    8008a1 <strncpy+0x23>
		*dst++ = *src;
  800892:	83 c2 01             	add    $0x1,%edx
  800895:	0f b6 01             	movzbl (%ecx),%eax
  800898:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089b:	80 39 01             	cmpb   $0x1,(%ecx)
  80089e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a1:	39 da                	cmp    %ebx,%edx
  8008a3:	75 ed                	jne    800892 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a5:	89 f0                	mov    %esi,%eax
  8008a7:	5b                   	pop    %ebx
  8008a8:	5e                   	pop    %esi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bb:	85 d2                	test   %edx,%edx
  8008bd:	74 21                	je     8008e0 <strlcpy+0x35>
  8008bf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c3:	89 f2                	mov    %esi,%edx
  8008c5:	eb 09                	jmp    8008d0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c7:	83 c2 01             	add    $0x1,%edx
  8008ca:	83 c1 01             	add    $0x1,%ecx
  8008cd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d0:	39 c2                	cmp    %eax,%edx
  8008d2:	74 09                	je     8008dd <strlcpy+0x32>
  8008d4:	0f b6 19             	movzbl (%ecx),%ebx
  8008d7:	84 db                	test   %bl,%bl
  8008d9:	75 ec                	jne    8008c7 <strlcpy+0x1c>
  8008db:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008dd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e0:	29 f0                	sub    %esi,%eax
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ef:	eb 06                	jmp    8008f7 <strcmp+0x11>
		p++, q++;
  8008f1:	83 c1 01             	add    $0x1,%ecx
  8008f4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f7:	0f b6 01             	movzbl (%ecx),%eax
  8008fa:	84 c0                	test   %al,%al
  8008fc:	74 04                	je     800902 <strcmp+0x1c>
  8008fe:	3a 02                	cmp    (%edx),%al
  800900:	74 ef                	je     8008f1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800902:	0f b6 c0             	movzbl %al,%eax
  800905:	0f b6 12             	movzbl (%edx),%edx
  800908:	29 d0                	sub    %edx,%eax
}
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
  800916:	89 c3                	mov    %eax,%ebx
  800918:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091b:	eb 06                	jmp    800923 <strncmp+0x17>
		n--, p++, q++;
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800923:	39 d8                	cmp    %ebx,%eax
  800925:	74 15                	je     80093c <strncmp+0x30>
  800927:	0f b6 08             	movzbl (%eax),%ecx
  80092a:	84 c9                	test   %cl,%cl
  80092c:	74 04                	je     800932 <strncmp+0x26>
  80092e:	3a 0a                	cmp    (%edx),%cl
  800930:	74 eb                	je     80091d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800932:	0f b6 00             	movzbl (%eax),%eax
  800935:	0f b6 12             	movzbl (%edx),%edx
  800938:	29 d0                	sub    %edx,%eax
  80093a:	eb 05                	jmp    800941 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800941:	5b                   	pop    %ebx
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094e:	eb 07                	jmp    800957 <strchr+0x13>
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 0f                	je     800963 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800954:	83 c0 01             	add    $0x1,%eax
  800957:	0f b6 10             	movzbl (%eax),%edx
  80095a:	84 d2                	test   %dl,%dl
  80095c:	75 f2                	jne    800950 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096f:	eb 03                	jmp    800974 <strfind+0xf>
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800977:	38 ca                	cmp    %cl,%dl
  800979:	74 04                	je     80097f <strfind+0x1a>
  80097b:	84 d2                	test   %dl,%dl
  80097d:	75 f2                	jne    800971 <strfind+0xc>
			break;
	return (char *) s;
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098d:	85 c9                	test   %ecx,%ecx
  80098f:	74 36                	je     8009c7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800991:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800997:	75 28                	jne    8009c1 <memset+0x40>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 23                	jne    8009c1 <memset+0x40>
		c &= 0xFF;
  80099e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a2:	89 d3                	mov    %edx,%ebx
  8009a4:	c1 e3 08             	shl    $0x8,%ebx
  8009a7:	89 d6                	mov    %edx,%esi
  8009a9:	c1 e6 18             	shl    $0x18,%esi
  8009ac:	89 d0                	mov    %edx,%eax
  8009ae:	c1 e0 10             	shl    $0x10,%eax
  8009b1:	09 f0                	or     %esi,%eax
  8009b3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009b5:	89 d8                	mov    %ebx,%eax
  8009b7:	09 d0                	or     %edx,%eax
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
  8009bc:	fc                   	cld    
  8009bd:	f3 ab                	rep stos %eax,%es:(%edi)
  8009bf:	eb 06                	jmp    8009c7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c4:	fc                   	cld    
  8009c5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c7:	89 f8                	mov    %edi,%eax
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5f                   	pop    %edi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	57                   	push   %edi
  8009d2:	56                   	push   %esi
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009dc:	39 c6                	cmp    %eax,%esi
  8009de:	73 35                	jae    800a15 <memmove+0x47>
  8009e0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e3:	39 d0                	cmp    %edx,%eax
  8009e5:	73 2e                	jae    800a15 <memmove+0x47>
		s += n;
		d += n;
  8009e7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	89 d6                	mov    %edx,%esi
  8009ec:	09 fe                	or     %edi,%esi
  8009ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f4:	75 13                	jne    800a09 <memmove+0x3b>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 0e                	jne    800a09 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009fb:	83 ef 04             	sub    $0x4,%edi
  8009fe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a01:	c1 e9 02             	shr    $0x2,%ecx
  800a04:	fd                   	std    
  800a05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a07:	eb 09                	jmp    800a12 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a09:	83 ef 01             	sub    $0x1,%edi
  800a0c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a0f:	fd                   	std    
  800a10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a12:	fc                   	cld    
  800a13:	eb 1d                	jmp    800a32 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	89 f2                	mov    %esi,%edx
  800a17:	09 c2                	or     %eax,%edx
  800a19:	f6 c2 03             	test   $0x3,%dl
  800a1c:	75 0f                	jne    800a2d <memmove+0x5f>
  800a1e:	f6 c1 03             	test   $0x3,%cl
  800a21:	75 0a                	jne    800a2d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a23:	c1 e9 02             	shr    $0x2,%ecx
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	fc                   	cld    
  800a29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2b:	eb 05                	jmp    800a32 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a39:	ff 75 10             	pushl  0x10(%ebp)
  800a3c:	ff 75 0c             	pushl  0xc(%ebp)
  800a3f:	ff 75 08             	pushl  0x8(%ebp)
  800a42:	e8 87 ff ff ff       	call   8009ce <memmove>
}
  800a47:	c9                   	leave  
  800a48:	c3                   	ret    

00800a49 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a54:	89 c6                	mov    %eax,%esi
  800a56:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a59:	eb 1a                	jmp    800a75 <memcmp+0x2c>
		if (*s1 != *s2)
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	0f b6 1a             	movzbl (%edx),%ebx
  800a61:	38 d9                	cmp    %bl,%cl
  800a63:	74 0a                	je     800a6f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a65:	0f b6 c1             	movzbl %cl,%eax
  800a68:	0f b6 db             	movzbl %bl,%ebx
  800a6b:	29 d8                	sub    %ebx,%eax
  800a6d:	eb 0f                	jmp    800a7e <memcmp+0x35>
		s1++, s2++;
  800a6f:	83 c0 01             	add    $0x1,%eax
  800a72:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a75:	39 f0                	cmp    %esi,%eax
  800a77:	75 e2                	jne    800a5b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a89:	89 c1                	mov    %eax,%ecx
  800a8b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a92:	eb 0a                	jmp    800a9e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a94:	0f b6 10             	movzbl (%eax),%edx
  800a97:	39 da                	cmp    %ebx,%edx
  800a99:	74 07                	je     800aa2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9b:	83 c0 01             	add    $0x1,%eax
  800a9e:	39 c8                	cmp    %ecx,%eax
  800aa0:	72 f2                	jb     800a94 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	eb 03                	jmp    800ab6 <strtol+0x11>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	3c 20                	cmp    $0x20,%al
  800abb:	74 f6                	je     800ab3 <strtol+0xe>
  800abd:	3c 09                	cmp    $0x9,%al
  800abf:	74 f2                	je     800ab3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac1:	3c 2b                	cmp    $0x2b,%al
  800ac3:	75 0a                	jne    800acf <strtol+0x2a>
		s++;
  800ac5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac8:	bf 00 00 00 00       	mov    $0x0,%edi
  800acd:	eb 11                	jmp    800ae0 <strtol+0x3b>
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad4:	3c 2d                	cmp    $0x2d,%al
  800ad6:	75 08                	jne    800ae0 <strtol+0x3b>
		s++, neg = 1;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae6:	75 15                	jne    800afd <strtol+0x58>
  800ae8:	80 39 30             	cmpb   $0x30,(%ecx)
  800aeb:	75 10                	jne    800afd <strtol+0x58>
  800aed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af1:	75 7c                	jne    800b6f <strtol+0xca>
		s += 2, base = 16;
  800af3:	83 c1 02             	add    $0x2,%ecx
  800af6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800afb:	eb 16                	jmp    800b13 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800afd:	85 db                	test   %ebx,%ebx
  800aff:	75 12                	jne    800b13 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b01:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b06:	80 39 30             	cmpb   $0x30,(%ecx)
  800b09:	75 08                	jne    800b13 <strtol+0x6e>
		s++, base = 8;
  800b0b:	83 c1 01             	add    $0x1,%ecx
  800b0e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b13:	b8 00 00 00 00       	mov    $0x0,%eax
  800b18:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b1b:	0f b6 11             	movzbl (%ecx),%edx
  800b1e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b21:	89 f3                	mov    %esi,%ebx
  800b23:	80 fb 09             	cmp    $0x9,%bl
  800b26:	77 08                	ja     800b30 <strtol+0x8b>
			dig = *s - '0';
  800b28:	0f be d2             	movsbl %dl,%edx
  800b2b:	83 ea 30             	sub    $0x30,%edx
  800b2e:	eb 22                	jmp    800b52 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b30:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b33:	89 f3                	mov    %esi,%ebx
  800b35:	80 fb 19             	cmp    $0x19,%bl
  800b38:	77 08                	ja     800b42 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b3a:	0f be d2             	movsbl %dl,%edx
  800b3d:	83 ea 57             	sub    $0x57,%edx
  800b40:	eb 10                	jmp    800b52 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b42:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b45:	89 f3                	mov    %esi,%ebx
  800b47:	80 fb 19             	cmp    $0x19,%bl
  800b4a:	77 16                	ja     800b62 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b4c:	0f be d2             	movsbl %dl,%edx
  800b4f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b52:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b55:	7d 0b                	jge    800b62 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b57:	83 c1 01             	add    $0x1,%ecx
  800b5a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b60:	eb b9                	jmp    800b1b <strtol+0x76>

	if (endptr)
  800b62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b66:	74 0d                	je     800b75 <strtol+0xd0>
		*endptr = (char *) s;
  800b68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6b:	89 0e                	mov    %ecx,(%esi)
  800b6d:	eb 06                	jmp    800b75 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6f:	85 db                	test   %ebx,%ebx
  800b71:	74 98                	je     800b0b <strtol+0x66>
  800b73:	eb 9e                	jmp    800b13 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b75:	89 c2                	mov    %eax,%edx
  800b77:	f7 da                	neg    %edx
  800b79:	85 ff                	test   %edi,%edi
  800b7b:	0f 45 c2             	cmovne %edx,%eax
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	89 c3                	mov    %eax,%ebx
  800b96:	89 c7                	mov    %eax,%edi
  800b98:	89 c6                	mov    %eax,%esi
  800b9a:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb1:	89 d1                	mov    %edx,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bce:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	89 cb                	mov    %ecx,%ebx
  800bd8:	89 cf                	mov    %ecx,%edi
  800bda:	89 ce                	mov    %ecx,%esi
  800bdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 03                	push   $0x3
  800be8:	68 7f 28 80 00       	push   $0x80287f
  800bed:	6a 23                	push   $0x23
  800bef:	68 9c 28 80 00       	push   $0x80289c
  800bf4:	e8 9b f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c11:	89 d1                	mov    %edx,%ecx
  800c13:	89 d3                	mov    %edx,%ebx
  800c15:	89 d7                	mov    %edx,%edi
  800c17:	89 d6                	mov    %edx,%esi
  800c19:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_yield>:

void
sys_yield(void)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c26:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c30:	89 d1                	mov    %edx,%ecx
  800c32:	89 d3                	mov    %edx,%ebx
  800c34:	89 d7                	mov    %edx,%edi
  800c36:	89 d6                	mov    %edx,%esi
  800c38:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c48:	be 00 00 00 00       	mov    $0x0,%esi
  800c4d:	b8 04 00 00 00       	mov    $0x4,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5b:	89 f7                	mov    %esi,%edi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 04                	push   $0x4
  800c69:	68 7f 28 80 00       	push   $0x80287f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 9c 28 80 00       	push   $0x80289c
  800c75:	e8 1a f5 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 05                	push   $0x5
  800cab:	68 7f 28 80 00       	push   $0x80287f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 9c 28 80 00       	push   $0x80289c
  800cb7:	e8 d8 f4 ff ff       	call   800194 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 06                	push   $0x6
  800ced:	68 7f 28 80 00       	push   $0x80287f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 9c 28 80 00       	push   $0x80289c
  800cf9:	e8 96 f4 ff ff       	call   800194 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 08 00 00 00       	mov    $0x8,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 08                	push   $0x8
  800d2f:	68 7f 28 80 00       	push   $0x80287f
  800d34:	6a 23                	push   $0x23
  800d36:	68 9c 28 80 00       	push   $0x80289c
  800d3b:	e8 54 f4 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 09                	push   $0x9
  800d71:	68 7f 28 80 00       	push   $0x80287f
  800d76:	6a 23                	push   $0x23
  800d78:	68 9c 28 80 00       	push   $0x80289c
  800d7d:	e8 12 f4 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 0a                	push   $0xa
  800db3:	68 7f 28 80 00       	push   $0x80287f
  800db8:	6a 23                	push   $0x23
  800dba:	68 9c 28 80 00       	push   $0x80289c
  800dbf:	e8 d0 f3 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dd2:	be 00 00 00 00       	mov    $0x0,%esi
  800dd7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
  800df5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800df8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	89 cb                	mov    %ecx,%ebx
  800e07:	89 cf                	mov    %ecx,%edi
  800e09:	89 ce                	mov    %ecx,%esi
  800e0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	7e 17                	jle    800e28 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	50                   	push   %eax
  800e15:	6a 0d                	push   $0xd
  800e17:	68 7f 28 80 00       	push   $0x80287f
  800e1c:	6a 23                	push   $0x23
  800e1e:	68 9c 28 80 00       	push   $0x80289c
  800e23:	e8 6c f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e50:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	c1 ea 16             	shr    $0x16,%edx
  800e67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	74 11                	je     800e84 <fd_alloc+0x2d>
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	c1 ea 0c             	shr    $0xc,%edx
  800e78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7f:	f6 c2 01             	test   $0x1,%dl
  800e82:	75 09                	jne    800e8d <fd_alloc+0x36>
			*fd_store = fd;
  800e84:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 17                	jmp    800ea4 <fd_alloc+0x4d>
  800e8d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e92:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e97:	75 c9                	jne    800e62 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e99:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e9f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eac:	83 f8 1f             	cmp    $0x1f,%eax
  800eaf:	77 36                	ja     800ee7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb1:	c1 e0 0c             	shl    $0xc,%eax
  800eb4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb9:	89 c2                	mov    %eax,%edx
  800ebb:	c1 ea 16             	shr    $0x16,%edx
  800ebe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec5:	f6 c2 01             	test   $0x1,%dl
  800ec8:	74 24                	je     800eee <fd_lookup+0x48>
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	c1 ea 0c             	shr    $0xc,%edx
  800ecf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed6:	f6 c2 01             	test   $0x1,%dl
  800ed9:	74 1a                	je     800ef5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800edb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ede:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	eb 13                	jmp    800efa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eec:	eb 0c                	jmp    800efa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef3:	eb 05                	jmp    800efa <fd_lookup+0x54>
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f05:	ba 28 29 80 00       	mov    $0x802928,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0a:	eb 13                	jmp    800f1f <dev_lookup+0x23>
  800f0c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f0f:	39 08                	cmp    %ecx,(%eax)
  800f11:	75 0c                	jne    800f1f <dev_lookup+0x23>
			*dev = devtab[i];
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1d:	eb 2e                	jmp    800f4d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1f:	8b 02                	mov    (%edx),%eax
  800f21:	85 c0                	test   %eax,%eax
  800f23:	75 e7                	jne    800f0c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f25:	a1 04 40 80 00       	mov    0x804004,%eax
  800f2a:	8b 40 48             	mov    0x48(%eax),%eax
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	51                   	push   %ecx
  800f31:	50                   	push   %eax
  800f32:	68 ac 28 80 00       	push   $0x8028ac
  800f37:	e8 31 f3 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 10             	sub    $0x10,%esp
  800f57:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f67:	c1 e8 0c             	shr    $0xc,%eax
  800f6a:	50                   	push   %eax
  800f6b:	e8 36 ff ff ff       	call   800ea6 <fd_lookup>
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 05                	js     800f7c <fd_close+0x2d>
	    || fd != fd2)
  800f77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7a:	74 0c                	je     800f88 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7c:	84 db                	test   %bl,%bl
  800f7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f83:	0f 44 c2             	cmove  %edx,%eax
  800f86:	eb 41                	jmp    800fc9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 36                	pushl  (%esi)
  800f91:	e8 66 ff ff ff       	call   800efc <dev_lookup>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 1a                	js     800fb9 <fd_close+0x6a>
		if (dev->dev_close)
  800f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	74 0b                	je     800fb9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	56                   	push   %esi
  800fb2:	ff d0                	call   *%eax
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	56                   	push   %esi
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 00 fd ff ff       	call   800cc4 <sys_page_unmap>
	return r;
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	89 d8                	mov    %ebx,%eax
}
  800fc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd9:	50                   	push   %eax
  800fda:	ff 75 08             	pushl  0x8(%ebp)
  800fdd:	e8 c4 fe ff ff       	call   800ea6 <fd_lookup>
  800fe2:	83 c4 08             	add    $0x8,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 10                	js     800ff9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	6a 01                	push   $0x1
  800fee:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff1:	e8 59 ff ff ff       	call   800f4f <fd_close>
  800ff6:	83 c4 10             	add    $0x10,%esp
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <close_all>:

void
close_all(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	53                   	push   %ebx
  80100b:	e8 c0 ff ff ff       	call   800fd0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801010:	83 c3 01             	add    $0x1,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	83 fb 20             	cmp    $0x20,%ebx
  801019:	75 ec                	jne    801007 <close_all+0xc>
		close(i);
}
  80101b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
  801026:	83 ec 2c             	sub    $0x2c,%esp
  801029:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102f:	50                   	push   %eax
  801030:	ff 75 08             	pushl  0x8(%ebp)
  801033:	e8 6e fe ff ff       	call   800ea6 <fd_lookup>
  801038:	83 c4 08             	add    $0x8,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	0f 88 c1 00 00 00    	js     801104 <dup+0xe4>
		return r;
	close(newfdnum);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	56                   	push   %esi
  801047:	e8 84 ff ff ff       	call   800fd0 <close>

	newfd = INDEX2FD(newfdnum);
  80104c:	89 f3                	mov    %esi,%ebx
  80104e:	c1 e3 0c             	shl    $0xc,%ebx
  801051:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801057:	83 c4 04             	add    $0x4,%esp
  80105a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105d:	e8 de fd ff ff       	call   800e40 <fd2data>
  801062:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801064:	89 1c 24             	mov    %ebx,(%esp)
  801067:	e8 d4 fd ff ff       	call   800e40 <fd2data>
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801072:	89 f8                	mov    %edi,%eax
  801074:	c1 e8 16             	shr    $0x16,%eax
  801077:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107e:	a8 01                	test   $0x1,%al
  801080:	74 37                	je     8010b9 <dup+0x99>
  801082:	89 f8                	mov    %edi,%eax
  801084:	c1 e8 0c             	shr    $0xc,%eax
  801087:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	74 26                	je     8010b9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801093:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a2:	50                   	push   %eax
  8010a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a6:	6a 00                	push   $0x0
  8010a8:	57                   	push   %edi
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 d2 fb ff ff       	call   800c82 <sys_page_map>
  8010b0:	89 c7                	mov    %eax,%edi
  8010b2:	83 c4 20             	add    $0x20,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 2e                	js     8010e7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bc:	89 d0                	mov    %edx,%eax
  8010be:	c1 e8 0c             	shr    $0xc,%eax
  8010c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d0:	50                   	push   %eax
  8010d1:	53                   	push   %ebx
  8010d2:	6a 00                	push   $0x0
  8010d4:	52                   	push   %edx
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 a6 fb ff ff       	call   800c82 <sys_page_map>
  8010dc:	89 c7                	mov    %eax,%edi
  8010de:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e3:	85 ff                	test   %edi,%edi
  8010e5:	79 1d                	jns    801104 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	53                   	push   %ebx
  8010eb:	6a 00                	push   $0x0
  8010ed:	e8 d2 fb ff ff       	call   800cc4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f2:	83 c4 08             	add    $0x8,%esp
  8010f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 c5 fb ff ff       	call   800cc4 <sys_page_unmap>
	return r;
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	89 f8                	mov    %edi,%eax
}
  801104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	53                   	push   %ebx
  801110:	83 ec 14             	sub    $0x14,%esp
  801113:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801116:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	53                   	push   %ebx
  80111b:	e8 86 fd ff ff       	call   800ea6 <fd_lookup>
  801120:	83 c4 08             	add    $0x8,%esp
  801123:	89 c2                	mov    %eax,%edx
  801125:	85 c0                	test   %eax,%eax
  801127:	78 6d                	js     801196 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112f:	50                   	push   %eax
  801130:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801133:	ff 30                	pushl  (%eax)
  801135:	e8 c2 fd ff ff       	call   800efc <dev_lookup>
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	85 c0                	test   %eax,%eax
  80113f:	78 4c                	js     80118d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801141:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801144:	8b 42 08             	mov    0x8(%edx),%eax
  801147:	83 e0 03             	and    $0x3,%eax
  80114a:	83 f8 01             	cmp    $0x1,%eax
  80114d:	75 21                	jne    801170 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114f:	a1 04 40 80 00       	mov    0x804004,%eax
  801154:	8b 40 48             	mov    0x48(%eax),%eax
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	53                   	push   %ebx
  80115b:	50                   	push   %eax
  80115c:	68 ed 28 80 00       	push   $0x8028ed
  801161:	e8 07 f1 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116e:	eb 26                	jmp    801196 <read+0x8a>
	}
	if (!dev->dev_read)
  801170:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801173:	8b 40 08             	mov    0x8(%eax),%eax
  801176:	85 c0                	test   %eax,%eax
  801178:	74 17                	je     801191 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	ff 75 10             	pushl  0x10(%ebp)
  801180:	ff 75 0c             	pushl  0xc(%ebp)
  801183:	52                   	push   %edx
  801184:	ff d0                	call   *%eax
  801186:	89 c2                	mov    %eax,%edx
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	eb 09                	jmp    801196 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	eb 05                	jmp    801196 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801191:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801196:	89 d0                	mov    %edx,%eax
  801198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    

0080119d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	eb 21                	jmp    8011d4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	89 f0                	mov    %esi,%eax
  8011b8:	29 d8                	sub    %ebx,%eax
  8011ba:	50                   	push   %eax
  8011bb:	89 d8                	mov    %ebx,%eax
  8011bd:	03 45 0c             	add    0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	57                   	push   %edi
  8011c2:	e8 45 ff ff ff       	call   80110c <read>
		if (m < 0)
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 10                	js     8011de <readn+0x41>
			return m;
		if (m == 0)
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	74 0a                	je     8011dc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d2:	01 c3                	add    %eax,%ebx
  8011d4:	39 f3                	cmp    %esi,%ebx
  8011d6:	72 db                	jb     8011b3 <readn+0x16>
  8011d8:	89 d8                	mov    %ebx,%eax
  8011da:	eb 02                	jmp    8011de <readn+0x41>
  8011dc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 14             	sub    $0x14,%esp
  8011ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	53                   	push   %ebx
  8011f5:	e8 ac fc ff ff       	call   800ea6 <fd_lookup>
  8011fa:	83 c4 08             	add    $0x8,%esp
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 68                	js     80126b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801209:	50                   	push   %eax
  80120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120d:	ff 30                	pushl  (%eax)
  80120f:	e8 e8 fc ff ff       	call   800efc <dev_lookup>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	78 47                	js     801262 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801222:	75 21                	jne    801245 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801224:	a1 04 40 80 00       	mov    0x804004,%eax
  801229:	8b 40 48             	mov    0x48(%eax),%eax
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	53                   	push   %ebx
  801230:	50                   	push   %eax
  801231:	68 09 29 80 00       	push   $0x802909
  801236:	e8 32 f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801243:	eb 26                	jmp    80126b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801245:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801248:	8b 52 0c             	mov    0xc(%edx),%edx
  80124b:	85 d2                	test   %edx,%edx
  80124d:	74 17                	je     801266 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	ff 75 10             	pushl  0x10(%ebp)
  801255:	ff 75 0c             	pushl  0xc(%ebp)
  801258:	50                   	push   %eax
  801259:	ff d2                	call   *%edx
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	eb 09                	jmp    80126b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801262:	89 c2                	mov    %eax,%edx
  801264:	eb 05                	jmp    80126b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801266:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126b:	89 d0                	mov    %edx,%eax
  80126d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <seek>:

int
seek(int fdnum, off_t offset)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801278:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 22 fc ff ff       	call   800ea6 <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 0e                	js     801299 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801291:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	53                   	push   %ebx
  80129f:	83 ec 14             	sub    $0x14,%esp
  8012a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	53                   	push   %ebx
  8012aa:	e8 f7 fb ff ff       	call   800ea6 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 65                	js     80131d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	ff 30                	pushl  (%eax)
  8012c4:	e8 33 fc ff ff       	call   800efc <dev_lookup>
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 44                	js     801314 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d7:	75 21                	jne    8012fa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012de:	8b 40 48             	mov    0x48(%eax),%eax
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	53                   	push   %ebx
  8012e5:	50                   	push   %eax
  8012e6:	68 cc 28 80 00       	push   $0x8028cc
  8012eb:	e8 7d ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f8:	eb 23                	jmp    80131d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fd:	8b 52 18             	mov    0x18(%edx),%edx
  801300:	85 d2                	test   %edx,%edx
  801302:	74 14                	je     801318 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	ff 75 0c             	pushl  0xc(%ebp)
  80130a:	50                   	push   %eax
  80130b:	ff d2                	call   *%edx
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	eb 09                	jmp    80131d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801314:	89 c2                	mov    %eax,%edx
  801316:	eb 05                	jmp    80131d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801318:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131d:	89 d0                	mov    %edx,%eax
  80131f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	53                   	push   %ebx
  801328:	83 ec 14             	sub    $0x14,%esp
  80132b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 75 08             	pushl  0x8(%ebp)
  801335:	e8 6c fb ff ff       	call   800ea6 <fd_lookup>
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	89 c2                	mov    %eax,%edx
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 58                	js     80139b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	ff 30                	pushl  (%eax)
  80134f:	e8 a8 fb ff ff       	call   800efc <dev_lookup>
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 37                	js     801392 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801362:	74 32                	je     801396 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801364:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801367:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136e:	00 00 00 
	stat->st_isdir = 0;
  801371:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801378:	00 00 00 
	stat->st_dev = dev;
  80137b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	53                   	push   %ebx
  801385:	ff 75 f0             	pushl  -0x10(%ebp)
  801388:	ff 50 14             	call   *0x14(%eax)
  80138b:	89 c2                	mov    %eax,%edx
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	eb 09                	jmp    80139b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801392:	89 c2                	mov    %eax,%edx
  801394:	eb 05                	jmp    80139b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801396:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139b:	89 d0                	mov    %edx,%eax
  80139d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	6a 00                	push   $0x0
  8013ac:	ff 75 08             	pushl  0x8(%ebp)
  8013af:	e8 dc 01 00 00       	call   801590 <open>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 1b                	js     8013d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	ff 75 0c             	pushl  0xc(%ebp)
  8013c3:	50                   	push   %eax
  8013c4:	e8 5b ff ff ff       	call   801324 <fstat>
  8013c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8013cb:	89 1c 24             	mov    %ebx,(%esp)
  8013ce:	e8 fd fb ff ff       	call   800fd0 <close>
	return r;
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	89 f0                	mov    %esi,%eax
}
  8013d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	89 c6                	mov    %eax,%esi
  8013e6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ef:	75 12                	jne    801403 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	6a 01                	push   $0x1
  8013f6:	e8 6c 0d 00 00       	call   802167 <ipc_find_env>
  8013fb:	a3 00 40 80 00       	mov    %eax,0x804000
  801400:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801403:	6a 07                	push   $0x7
  801405:	68 00 50 80 00       	push   $0x805000
  80140a:	56                   	push   %esi
  80140b:	ff 35 00 40 80 00    	pushl  0x804000
  801411:	e8 0e 0d 00 00       	call   802124 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801416:	83 c4 0c             	add    $0xc,%esp
  801419:	6a 00                	push   $0x0
  80141b:	53                   	push   %ebx
  80141c:	6a 00                	push   $0x0
  80141e:	e8 a4 0c 00 00       	call   8020c7 <ipc_recv>
}
  801423:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801426:	5b                   	pop    %ebx
  801427:	5e                   	pop    %esi
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	8b 40 0c             	mov    0xc(%eax),%eax
  801436:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801443:	ba 00 00 00 00       	mov    $0x0,%edx
  801448:	b8 02 00 00 00       	mov    $0x2,%eax
  80144d:	e8 8d ff ff ff       	call   8013df <fsipc>
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801465:	ba 00 00 00 00       	mov    $0x0,%edx
  80146a:	b8 06 00 00 00       	mov    $0x6,%eax
  80146f:	e8 6b ff ff ff       	call   8013df <fsipc>
}
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	8b 40 0c             	mov    0xc(%eax),%eax
  801486:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148b:	ba 00 00 00 00       	mov    $0x0,%edx
  801490:	b8 05 00 00 00       	mov    $0x5,%eax
  801495:	e8 45 ff ff ff       	call   8013df <fsipc>
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 2c                	js     8014ca <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	68 00 50 80 00       	push   $0x805000
  8014a6:	53                   	push   %ebx
  8014a7:	e8 90 f3 ff ff       	call   80083c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8014bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014db:	8b 52 0c             	mov    0xc(%edx),%edx
  8014de:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014e4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014e9:	50                   	push   %eax
  8014ea:	ff 75 0c             	pushl  0xc(%ebp)
  8014ed:	68 08 50 80 00       	push   $0x805008
  8014f2:	e8 d7 f4 ff ff       	call   8009ce <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801501:	e8 d9 fe ff ff       	call   8013df <fsipc>
	//panic("devfile_write not implemented");
}
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801510:	8b 45 08             	mov    0x8(%ebp),%eax
  801513:	8b 40 0c             	mov    0xc(%eax),%eax
  801516:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801521:	ba 00 00 00 00       	mov    $0x0,%edx
  801526:	b8 03 00 00 00       	mov    $0x3,%eax
  80152b:	e8 af fe ff ff       	call   8013df <fsipc>
  801530:	89 c3                	mov    %eax,%ebx
  801532:	85 c0                	test   %eax,%eax
  801534:	78 51                	js     801587 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801536:	39 c6                	cmp    %eax,%esi
  801538:	73 19                	jae    801553 <devfile_read+0x4b>
  80153a:	68 38 29 80 00       	push   $0x802938
  80153f:	68 3f 29 80 00       	push   $0x80293f
  801544:	68 80 00 00 00       	push   $0x80
  801549:	68 54 29 80 00       	push   $0x802954
  80154e:	e8 41 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  801553:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801558:	7e 19                	jle    801573 <devfile_read+0x6b>
  80155a:	68 5f 29 80 00       	push   $0x80295f
  80155f:	68 3f 29 80 00       	push   $0x80293f
  801564:	68 81 00 00 00       	push   $0x81
  801569:	68 54 29 80 00       	push   $0x802954
  80156e:	e8 21 ec ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	50                   	push   %eax
  801577:	68 00 50 80 00       	push   $0x805000
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	e8 4a f4 ff ff       	call   8009ce <memmove>
	return r;
  801584:	83 c4 10             	add    $0x10,%esp
}
  801587:	89 d8                	mov    %ebx,%eax
  801589:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158c:	5b                   	pop    %ebx
  80158d:	5e                   	pop    %esi
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 20             	sub    $0x20,%esp
  801597:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80159a:	53                   	push   %ebx
  80159b:	e8 63 f2 ff ff       	call   800803 <strlen>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a8:	7f 67                	jg     801611 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	e8 a1 f8 ff ff       	call   800e57 <fd_alloc>
  8015b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 57                	js     801616 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	68 00 50 80 00       	push   $0x805000
  8015c8:	e8 6f f2 ff ff       	call   80083c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d0:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015dd:	e8 fd fd ff ff       	call   8013df <fsipc>
  8015e2:	89 c3                	mov    %eax,%ebx
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	79 14                	jns    8015ff <open+0x6f>
		
		fd_close(fd, 0);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	6a 00                	push   $0x0
  8015f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f3:	e8 57 f9 ff ff       	call   800f4f <fd_close>
		return r;
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	89 da                	mov    %ebx,%edx
  8015fd:	eb 17                	jmp    801616 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	ff 75 f4             	pushl  -0xc(%ebp)
  801605:	e8 26 f8 ff ff       	call   800e30 <fd2num>
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	eb 05                	jmp    801616 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801611:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801616:	89 d0                	mov    %edx,%eax
  801618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801623:	ba 00 00 00 00       	mov    $0x0,%edx
  801628:	b8 08 00 00 00       	mov    $0x8,%eax
  80162d:	e8 ad fd ff ff       	call   8013df <fsipc>
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	57                   	push   %edi
  801638:	56                   	push   %esi
  801639:	53                   	push   %ebx
  80163a:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801640:	6a 00                	push   $0x0
  801642:	ff 75 08             	pushl  0x8(%ebp)
  801645:	e8 46 ff ff ff       	call   801590 <open>
  80164a:	89 c7                	mov    %eax,%edi
  80164c:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	0f 88 ae 04 00 00    	js     801b0b <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	68 00 02 00 00       	push   $0x200
  801665:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	57                   	push   %edi
  80166d:	e8 2b fb ff ff       	call   80119d <readn>
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	3d 00 02 00 00       	cmp    $0x200,%eax
  80167a:	75 0c                	jne    801688 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80167c:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801683:	45 4c 46 
  801686:	74 33                	je     8016bb <spawn+0x87>
		close(fd);
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801691:	e8 3a f9 ff ff       	call   800fd0 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801696:	83 c4 0c             	add    $0xc,%esp
  801699:	68 7f 45 4c 46       	push   $0x464c457f
  80169e:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016a4:	68 6b 29 80 00       	push   $0x80296b
  8016a9:	e8 bf eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016b6:	e9 b0 04 00 00       	jmp    801b6b <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016bb:	b8 07 00 00 00       	mov    $0x7,%eax
  8016c0:	cd 30                	int    $0x30
  8016c2:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016c8:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	0f 88 3d 04 00 00    	js     801b13 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016d6:	89 c6                	mov    %eax,%esi
  8016d8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016de:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016e1:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016e7:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016ed:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016f4:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016fa:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801700:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801705:	be 00 00 00 00       	mov    $0x0,%esi
  80170a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80170d:	eb 13                	jmp    801722 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80170f:	83 ec 0c             	sub    $0xc,%esp
  801712:	50                   	push   %eax
  801713:	e8 eb f0 ff ff       	call   800803 <strlen>
  801718:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80171c:	83 c3 01             	add    $0x1,%ebx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801729:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80172c:	85 c0                	test   %eax,%eax
  80172e:	75 df                	jne    80170f <spawn+0xdb>
  801730:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801736:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80173c:	bf 00 10 40 00       	mov    $0x401000,%edi
  801741:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801743:	89 fa                	mov    %edi,%edx
  801745:	83 e2 fc             	and    $0xfffffffc,%edx
  801748:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80174f:	29 c2                	sub    %eax,%edx
  801751:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801757:	8d 42 f8             	lea    -0x8(%edx),%eax
  80175a:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80175f:	0f 86 be 03 00 00    	jbe    801b23 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801765:	83 ec 04             	sub    $0x4,%esp
  801768:	6a 07                	push   $0x7
  80176a:	68 00 00 40 00       	push   $0x400000
  80176f:	6a 00                	push   $0x0
  801771:	e8 c9 f4 ff ff       	call   800c3f <sys_page_alloc>
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	0f 88 a9 03 00 00    	js     801b2a <spawn+0x4f6>
  801781:	be 00 00 00 00       	mov    $0x0,%esi
  801786:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80178c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80178f:	eb 30                	jmp    8017c1 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801791:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801797:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80179d:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017a6:	57                   	push   %edi
  8017a7:	e8 90 f0 ff ff       	call   80083c <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017ac:	83 c4 04             	add    $0x4,%esp
  8017af:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017b2:	e8 4c f0 ff ff       	call   800803 <strlen>
  8017b7:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017bb:	83 c6 01             	add    $0x1,%esi
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017c7:	7f c8                	jg     801791 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017c9:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017cf:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017d5:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017dc:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017e2:	74 19                	je     8017fd <spawn+0x1c9>
  8017e4:	68 e0 29 80 00       	push   $0x8029e0
  8017e9:	68 3f 29 80 00       	push   $0x80293f
  8017ee:	68 f2 00 00 00       	push   $0xf2
  8017f3:	68 85 29 80 00       	push   $0x802985
  8017f8:	e8 97 e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017fd:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801803:	89 f8                	mov    %edi,%eax
  801805:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80180a:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80180d:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801813:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801816:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80181c:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	6a 07                	push   $0x7
  801827:	68 00 d0 bf ee       	push   $0xeebfd000
  80182c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801832:	68 00 00 40 00       	push   $0x400000
  801837:	6a 00                	push   $0x0
  801839:	e8 44 f4 ff ff       	call   800c82 <sys_page_map>
  80183e:	89 c3                	mov    %eax,%ebx
  801840:	83 c4 20             	add    $0x20,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	0f 88 0e 03 00 00    	js     801b59 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	68 00 00 40 00       	push   $0x400000
  801853:	6a 00                	push   $0x0
  801855:	e8 6a f4 ff ff       	call   800cc4 <sys_page_unmap>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 c0                	test   %eax,%eax
  801861:	0f 88 f2 02 00 00    	js     801b59 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801867:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80186d:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801874:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80187a:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801881:	00 00 00 
  801884:	e9 88 01 00 00       	jmp    801a11 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801889:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80188f:	83 38 01             	cmpl   $0x1,(%eax)
  801892:	0f 85 6b 01 00 00    	jne    801a03 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801898:	89 c7                	mov    %eax,%edi
  80189a:	8b 40 18             	mov    0x18(%eax),%eax
  80189d:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018a3:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018a6:	83 f8 01             	cmp    $0x1,%eax
  8018a9:	19 c0                	sbb    %eax,%eax
  8018ab:	83 e0 fe             	and    $0xfffffffe,%eax
  8018ae:	83 c0 07             	add    $0x7,%eax
  8018b1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018b7:	89 f8                	mov    %edi,%eax
  8018b9:	8b 7f 04             	mov    0x4(%edi),%edi
  8018bc:	89 f9                	mov    %edi,%ecx
  8018be:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8018c4:	8b 78 10             	mov    0x10(%eax),%edi
  8018c7:	8b 50 14             	mov    0x14(%eax),%edx
  8018ca:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8018d0:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018d3:	89 f0                	mov    %esi,%eax
  8018d5:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018da:	74 14                	je     8018f0 <spawn+0x2bc>
		va -= i;
  8018dc:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018de:	01 c2                	add    %eax,%edx
  8018e0:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8018e6:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018e8:	29 c1                	sub    %eax,%ecx
  8018ea:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018f5:	e9 f7 00 00 00       	jmp    8019f1 <spawn+0x3bd>
		if (i >= filesz) {
  8018fa:	39 df                	cmp    %ebx,%edi
  8018fc:	77 27                	ja     801925 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018fe:	83 ec 04             	sub    $0x4,%esp
  801901:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801907:	56                   	push   %esi
  801908:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80190e:	e8 2c f3 ff ff       	call   800c3f <sys_page_alloc>
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	0f 89 c7 00 00 00    	jns    8019e5 <spawn+0x3b1>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	e9 13 02 00 00       	jmp    801b38 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801925:	83 ec 04             	sub    $0x4,%esp
  801928:	6a 07                	push   $0x7
  80192a:	68 00 00 40 00       	push   $0x400000
  80192f:	6a 00                	push   $0x0
  801931:	e8 09 f3 ff ff       	call   800c3f <sys_page_alloc>
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	85 c0                	test   %eax,%eax
  80193b:	0f 88 ed 01 00 00    	js     801b2e <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80194a:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801950:	50                   	push   %eax
  801951:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801957:	e8 16 f9 ff ff       	call   801272 <seek>
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	0f 88 cb 01 00 00    	js     801b32 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801967:	83 ec 04             	sub    $0x4,%esp
  80196a:	89 f8                	mov    %edi,%eax
  80196c:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801972:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801977:	ba 00 10 00 00       	mov    $0x1000,%edx
  80197c:	0f 47 c2             	cmova  %edx,%eax
  80197f:	50                   	push   %eax
  801980:	68 00 00 40 00       	push   $0x400000
  801985:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80198b:	e8 0d f8 ff ff       	call   80119d <readn>
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	85 c0                	test   %eax,%eax
  801995:	0f 88 9b 01 00 00    	js     801b36 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80199b:	83 ec 0c             	sub    $0xc,%esp
  80199e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019a4:	56                   	push   %esi
  8019a5:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019ab:	68 00 00 40 00       	push   $0x400000
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 cb f2 ff ff       	call   800c82 <sys_page_map>
  8019b7:	83 c4 20             	add    $0x20,%esp
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	79 15                	jns    8019d3 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8019be:	50                   	push   %eax
  8019bf:	68 91 29 80 00       	push   $0x802991
  8019c4:	68 25 01 00 00       	push   $0x125
  8019c9:	68 85 29 80 00       	push   $0x802985
  8019ce:	e8 c1 e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  8019d3:	83 ec 08             	sub    $0x8,%esp
  8019d6:	68 00 00 40 00       	push   $0x400000
  8019db:	6a 00                	push   $0x0
  8019dd:	e8 e2 f2 ff ff       	call   800cc4 <sys_page_unmap>
  8019e2:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019e5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019eb:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019f1:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019f7:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8019fd:	0f 87 f7 fe ff ff    	ja     8018fa <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a03:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a0a:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a11:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a18:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a1e:	0f 8c 65 fe ff ff    	jl     801889 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a2d:	e8 9e f5 ff ff       	call   800fd0 <close>
  801a32:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801a35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a3a:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801a40:	89 d8                	mov    %ebx,%eax
  801a42:	c1 e8 16             	shr    $0x16,%eax
  801a45:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a4c:	a8 01                	test   $0x1,%al
  801a4e:	74 46                	je     801a96 <spawn+0x462>
  801a50:	89 d8                	mov    %ebx,%eax
  801a52:	c1 e8 0c             	shr    $0xc,%eax
  801a55:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a5c:	f6 c2 01             	test   $0x1,%dl
  801a5f:	74 35                	je     801a96 <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801a61:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801a68:	f6 c2 04             	test   $0x4,%dl
  801a6b:	74 29                	je     801a96 <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801a6d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a74:	f6 c6 04             	test   $0x4,%dh
  801a77:	74 1d                	je     801a96 <spawn+0x462>
            sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801a79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	25 07 0e 00 00       	and    $0xe07,%eax
  801a88:	50                   	push   %eax
  801a89:	53                   	push   %ebx
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 ef f1 ff ff       	call   800c82 <sys_page_map>
  801a93:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801a96:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a9c:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801aa2:	75 9c                	jne    801a40 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801aa4:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801aab:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801abe:	e8 85 f2 ff ff       	call   800d48 <sys_env_set_trapframe>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	79 15                	jns    801adf <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801aca:	50                   	push   %eax
  801acb:	68 ae 29 80 00       	push   $0x8029ae
  801ad0:	68 86 00 00 00       	push   $0x86
  801ad5:	68 85 29 80 00       	push   $0x802985
  801ada:	e8 b5 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	6a 02                	push   $0x2
  801ae4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aea:	e8 17 f2 ff ff       	call   800d06 <sys_env_set_status>
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	79 25                	jns    801b1b <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801af6:	50                   	push   %eax
  801af7:	68 c8 29 80 00       	push   $0x8029c8
  801afc:	68 89 00 00 00       	push   $0x89
  801b01:	68 85 29 80 00       	push   $0x802985
  801b06:	e8 89 e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b0b:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b11:	eb 58                	jmp    801b6b <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b13:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b19:	eb 50                	jmp    801b6b <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b1b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b21:	eb 48                	jmp    801b6b <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b23:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b28:	eb 41                	jmp    801b6b <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	eb 3d                	jmp    801b6b <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	eb 06                	jmp    801b38 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b32:	89 c3                	mov    %eax,%ebx
  801b34:	eb 02                	jmp    801b38 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b36:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b41:	e8 7a f0 ff ff       	call   800bc0 <sys_env_destroy>
	close(fd);
  801b46:	83 c4 04             	add    $0x4,%esp
  801b49:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b4f:	e8 7c f4 ff ff       	call   800fd0 <close>
	return r;
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	eb 12                	jmp    801b6b <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	68 00 00 40 00       	push   $0x400000
  801b61:	6a 00                	push   $0x0
  801b63:	e8 5c f1 ff ff       	call   800cc4 <sys_page_unmap>
  801b68:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b6b:	89 d8                	mov    %ebx,%eax
  801b6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5f                   	pop    %edi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b7a:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b7d:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b82:	eb 03                	jmp    801b87 <spawnl+0x12>
		argc++;
  801b84:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b87:	83 c2 04             	add    $0x4,%edx
  801b8a:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b8e:	75 f4                	jne    801b84 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b90:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b97:	83 e2 f0             	and    $0xfffffff0,%edx
  801b9a:	29 d4                	sub    %edx,%esp
  801b9c:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ba0:	c1 ea 02             	shr    $0x2,%edx
  801ba3:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801baa:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801baf:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801bb6:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801bbd:	00 
  801bbe:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc5:	eb 0a                	jmp    801bd1 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bc7:	83 c0 01             	add    $0x1,%eax
  801bca:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bce:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bd1:	39 d0                	cmp    %edx,%eax
  801bd3:	75 f2                	jne    801bc7 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	56                   	push   %esi
  801bd9:	ff 75 08             	pushl  0x8(%ebp)
  801bdc:	e8 53 fa ff ff       	call   801634 <spawn>
}
  801be1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	ff 75 08             	pushl  0x8(%ebp)
  801bf6:	e8 45 f2 ff ff       	call   800e40 <fd2data>
  801bfb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bfd:	83 c4 08             	add    $0x8,%esp
  801c00:	68 08 2a 80 00       	push   $0x802a08
  801c05:	53                   	push   %ebx
  801c06:	e8 31 ec ff ff       	call   80083c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c0b:	8b 46 04             	mov    0x4(%esi),%eax
  801c0e:	2b 06                	sub    (%esi),%eax
  801c10:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c16:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c1d:	00 00 00 
	stat->st_dev = &devpipe;
  801c20:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c27:	30 80 00 
	return 0;
}
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c40:	53                   	push   %ebx
  801c41:	6a 00                	push   $0x0
  801c43:	e8 7c f0 ff ff       	call   800cc4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c48:	89 1c 24             	mov    %ebx,(%esp)
  801c4b:	e8 f0 f1 ff ff       	call   800e40 <fd2data>
  801c50:	83 c4 08             	add    $0x8,%esp
  801c53:	50                   	push   %eax
  801c54:	6a 00                	push   $0x0
  801c56:	e8 69 f0 ff ff       	call   800cc4 <sys_page_unmap>
}
  801c5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	57                   	push   %edi
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	83 ec 1c             	sub    $0x1c,%esp
  801c69:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c6c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801c73:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c76:	83 ec 0c             	sub    $0xc,%esp
  801c79:	ff 75 e0             	pushl  -0x20(%ebp)
  801c7c:	e8 1f 05 00 00       	call   8021a0 <pageref>
  801c81:	89 c3                	mov    %eax,%ebx
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	e8 15 05 00 00       	call   8021a0 <pageref>
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	39 c3                	cmp    %eax,%ebx
  801c90:	0f 94 c1             	sete   %cl
  801c93:	0f b6 c9             	movzbl %cl,%ecx
  801c96:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c99:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c9f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ca2:	39 ce                	cmp    %ecx,%esi
  801ca4:	74 1b                	je     801cc1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ca6:	39 c3                	cmp    %eax,%ebx
  801ca8:	75 c4                	jne    801c6e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801caa:	8b 42 58             	mov    0x58(%edx),%eax
  801cad:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cb0:	50                   	push   %eax
  801cb1:	56                   	push   %esi
  801cb2:	68 0f 2a 80 00       	push   $0x802a0f
  801cb7:	e8 b1 e5 ff ff       	call   80026d <cprintf>
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	eb ad                	jmp    801c6e <_pipeisclosed+0xe>
	}
}
  801cc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	57                   	push   %edi
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	83 ec 28             	sub    $0x28,%esp
  801cd5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cd8:	56                   	push   %esi
  801cd9:	e8 62 f1 ff ff       	call   800e40 <fd2data>
  801cde:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce8:	eb 4b                	jmp    801d35 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cea:	89 da                	mov    %ebx,%edx
  801cec:	89 f0                	mov    %esi,%eax
  801cee:	e8 6d ff ff ff       	call   801c60 <_pipeisclosed>
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	75 48                	jne    801d3f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cf7:	e8 24 ef ff ff       	call   800c20 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cfc:	8b 43 04             	mov    0x4(%ebx),%eax
  801cff:	8b 0b                	mov    (%ebx),%ecx
  801d01:	8d 51 20             	lea    0x20(%ecx),%edx
  801d04:	39 d0                	cmp    %edx,%eax
  801d06:	73 e2                	jae    801cea <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d0b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d0f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	c1 fa 1f             	sar    $0x1f,%edx
  801d17:	89 d1                	mov    %edx,%ecx
  801d19:	c1 e9 1b             	shr    $0x1b,%ecx
  801d1c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d1f:	83 e2 1f             	and    $0x1f,%edx
  801d22:	29 ca                	sub    %ecx,%edx
  801d24:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d28:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d2c:	83 c0 01             	add    $0x1,%eax
  801d2f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d32:	83 c7 01             	add    $0x1,%edi
  801d35:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d38:	75 c2                	jne    801cfc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3d:	eb 05                	jmp    801d44 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5f                   	pop    %edi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    

00801d4c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	57                   	push   %edi
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	83 ec 18             	sub    $0x18,%esp
  801d55:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d58:	57                   	push   %edi
  801d59:	e8 e2 f0 ff ff       	call   800e40 <fd2data>
  801d5e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d68:	eb 3d                	jmp    801da7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d6a:	85 db                	test   %ebx,%ebx
  801d6c:	74 04                	je     801d72 <devpipe_read+0x26>
				return i;
  801d6e:	89 d8                	mov    %ebx,%eax
  801d70:	eb 44                	jmp    801db6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	89 f8                	mov    %edi,%eax
  801d76:	e8 e5 fe ff ff       	call   801c60 <_pipeisclosed>
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	75 32                	jne    801db1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d7f:	e8 9c ee ff ff       	call   800c20 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d84:	8b 06                	mov    (%esi),%eax
  801d86:	3b 46 04             	cmp    0x4(%esi),%eax
  801d89:	74 df                	je     801d6a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d8b:	99                   	cltd   
  801d8c:	c1 ea 1b             	shr    $0x1b,%edx
  801d8f:	01 d0                	add    %edx,%eax
  801d91:	83 e0 1f             	and    $0x1f,%eax
  801d94:	29 d0                	sub    %edx,%eax
  801d96:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d9e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801da1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da4:	83 c3 01             	add    $0x1,%ebx
  801da7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801daa:	75 d8                	jne    801d84 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dac:	8b 45 10             	mov    0x10(%ebp),%eax
  801daf:	eb 05                	jmp    801db6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801db1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db9:	5b                   	pop    %ebx
  801dba:	5e                   	pop    %esi
  801dbb:	5f                   	pop    %edi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	56                   	push   %esi
  801dc2:	53                   	push   %ebx
  801dc3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc9:	50                   	push   %eax
  801dca:	e8 88 f0 ff ff       	call   800e57 <fd_alloc>
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	89 c2                	mov    %eax,%edx
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	0f 88 2c 01 00 00    	js     801f08 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddc:	83 ec 04             	sub    $0x4,%esp
  801ddf:	68 07 04 00 00       	push   $0x407
  801de4:	ff 75 f4             	pushl  -0xc(%ebp)
  801de7:	6a 00                	push   $0x0
  801de9:	e8 51 ee ff ff       	call   800c3f <sys_page_alloc>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	89 c2                	mov    %eax,%edx
  801df3:	85 c0                	test   %eax,%eax
  801df5:	0f 88 0d 01 00 00    	js     801f08 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e01:	50                   	push   %eax
  801e02:	e8 50 f0 ff ff       	call   800e57 <fd_alloc>
  801e07:	89 c3                	mov    %eax,%ebx
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	0f 88 e2 00 00 00    	js     801ef6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e14:	83 ec 04             	sub    $0x4,%esp
  801e17:	68 07 04 00 00       	push   $0x407
  801e1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1f:	6a 00                	push   $0x0
  801e21:	e8 19 ee ff ff       	call   800c3f <sys_page_alloc>
  801e26:	89 c3                	mov    %eax,%ebx
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	0f 88 c3 00 00 00    	js     801ef6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e33:	83 ec 0c             	sub    $0xc,%esp
  801e36:	ff 75 f4             	pushl  -0xc(%ebp)
  801e39:	e8 02 f0 ff ff       	call   800e40 <fd2data>
  801e3e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e40:	83 c4 0c             	add    $0xc,%esp
  801e43:	68 07 04 00 00       	push   $0x407
  801e48:	50                   	push   %eax
  801e49:	6a 00                	push   $0x0
  801e4b:	e8 ef ed ff ff       	call   800c3f <sys_page_alloc>
  801e50:	89 c3                	mov    %eax,%ebx
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	85 c0                	test   %eax,%eax
  801e57:	0f 88 89 00 00 00    	js     801ee6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5d:	83 ec 0c             	sub    $0xc,%esp
  801e60:	ff 75 f0             	pushl  -0x10(%ebp)
  801e63:	e8 d8 ef ff ff       	call   800e40 <fd2data>
  801e68:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e6f:	50                   	push   %eax
  801e70:	6a 00                	push   $0x0
  801e72:	56                   	push   %esi
  801e73:	6a 00                	push   $0x0
  801e75:	e8 08 ee ff ff       	call   800c82 <sys_page_map>
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	83 c4 20             	add    $0x20,%esp
  801e7f:	85 c0                	test   %eax,%eax
  801e81:	78 55                	js     801ed8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e83:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e98:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ead:	83 ec 0c             	sub    $0xc,%esp
  801eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb3:	e8 78 ef ff ff       	call   800e30 <fd2num>
  801eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ebb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ebd:	83 c4 04             	add    $0x4,%esp
  801ec0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec3:	e8 68 ef ff ff       	call   800e30 <fd2num>
  801ec8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ecb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed6:	eb 30                	jmp    801f08 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ed8:	83 ec 08             	sub    $0x8,%esp
  801edb:	56                   	push   %esi
  801edc:	6a 00                	push   $0x0
  801ede:	e8 e1 ed ff ff       	call   800cc4 <sys_page_unmap>
  801ee3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ee6:	83 ec 08             	sub    $0x8,%esp
  801ee9:	ff 75 f0             	pushl  -0x10(%ebp)
  801eec:	6a 00                	push   $0x0
  801eee:	e8 d1 ed ff ff       	call   800cc4 <sys_page_unmap>
  801ef3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	ff 75 f4             	pushl  -0xc(%ebp)
  801efc:	6a 00                	push   $0x0
  801efe:	e8 c1 ed ff ff       	call   800cc4 <sys_page_unmap>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f08:	89 d0                	mov    %edx,%eax
  801f0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5d                   	pop    %ebp
  801f10:	c3                   	ret    

00801f11 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1a:	50                   	push   %eax
  801f1b:	ff 75 08             	pushl  0x8(%ebp)
  801f1e:	e8 83 ef ff ff       	call   800ea6 <fd_lookup>
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 18                	js     801f42 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f2a:	83 ec 0c             	sub    $0xc,%esp
  801f2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f30:	e8 0b ef ff ff       	call   800e40 <fd2data>
	return _pipeisclosed(fd, p);
  801f35:	89 c2                	mov    %eax,%edx
  801f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3a:	e8 21 fd ff ff       	call   801c60 <_pipeisclosed>
  801f3f:	83 c4 10             	add    $0x10,%esp
}
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f47:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4c:	5d                   	pop    %ebp
  801f4d:	c3                   	ret    

00801f4e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f54:	68 27 2a 80 00       	push   $0x802a27
  801f59:	ff 75 0c             	pushl  0xc(%ebp)
  801f5c:	e8 db e8 ff ff       	call   80083c <strcpy>
	return 0;
}
  801f61:	b8 00 00 00 00       	mov    $0x0,%eax
  801f66:	c9                   	leave  
  801f67:	c3                   	ret    

00801f68 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	57                   	push   %edi
  801f6c:	56                   	push   %esi
  801f6d:	53                   	push   %ebx
  801f6e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f74:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f79:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f7f:	eb 2d                	jmp    801fae <devcons_write+0x46>
		m = n - tot;
  801f81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f84:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f86:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f89:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f8e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f91:	83 ec 04             	sub    $0x4,%esp
  801f94:	53                   	push   %ebx
  801f95:	03 45 0c             	add    0xc(%ebp),%eax
  801f98:	50                   	push   %eax
  801f99:	57                   	push   %edi
  801f9a:	e8 2f ea ff ff       	call   8009ce <memmove>
		sys_cputs(buf, m);
  801f9f:	83 c4 08             	add    $0x8,%esp
  801fa2:	53                   	push   %ebx
  801fa3:	57                   	push   %edi
  801fa4:	e8 da eb ff ff       	call   800b83 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fa9:	01 de                	add    %ebx,%esi
  801fab:	83 c4 10             	add    $0x10,%esp
  801fae:	89 f0                	mov    %esi,%eax
  801fb0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fb3:	72 cc                	jb     801f81 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5f                   	pop    %edi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    

00801fbd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	83 ec 08             	sub    $0x8,%esp
  801fc3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fcc:	74 2a                	je     801ff8 <devcons_read+0x3b>
  801fce:	eb 05                	jmp    801fd5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fd0:	e8 4b ec ff ff       	call   800c20 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fd5:	e8 c7 eb ff ff       	call   800ba1 <sys_cgetc>
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	74 f2                	je     801fd0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	78 16                	js     801ff8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fe2:	83 f8 04             	cmp    $0x4,%eax
  801fe5:	74 0c                	je     801ff3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fea:	88 02                	mov    %al,(%edx)
	return 1;
  801fec:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff1:	eb 05                	jmp    801ff8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    

00801ffa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802000:	8b 45 08             	mov    0x8(%ebp),%eax
  802003:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802006:	6a 01                	push   $0x1
  802008:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80200b:	50                   	push   %eax
  80200c:	e8 72 eb ff ff       	call   800b83 <sys_cputs>
}
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <getchar>:

int
getchar(void)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80201c:	6a 01                	push   $0x1
  80201e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802021:	50                   	push   %eax
  802022:	6a 00                	push   $0x0
  802024:	e8 e3 f0 ff ff       	call   80110c <read>
	if (r < 0)
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	85 c0                	test   %eax,%eax
  80202e:	78 0f                	js     80203f <getchar+0x29>
		return r;
	if (r < 1)
  802030:	85 c0                	test   %eax,%eax
  802032:	7e 06                	jle    80203a <getchar+0x24>
		return -E_EOF;
	return c;
  802034:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802038:	eb 05                	jmp    80203f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80203a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80203f:	c9                   	leave  
  802040:	c3                   	ret    

00802041 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802047:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204a:	50                   	push   %eax
  80204b:	ff 75 08             	pushl  0x8(%ebp)
  80204e:	e8 53 ee ff ff       	call   800ea6 <fd_lookup>
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	78 11                	js     80206b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802063:	39 10                	cmp    %edx,(%eax)
  802065:	0f 94 c0             	sete   %al
  802068:	0f b6 c0             	movzbl %al,%eax
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    

0080206d <opencons>:

int
opencons(void)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802076:	50                   	push   %eax
  802077:	e8 db ed ff ff       	call   800e57 <fd_alloc>
  80207c:	83 c4 10             	add    $0x10,%esp
		return r;
  80207f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802081:	85 c0                	test   %eax,%eax
  802083:	78 3e                	js     8020c3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802085:	83 ec 04             	sub    $0x4,%esp
  802088:	68 07 04 00 00       	push   $0x407
  80208d:	ff 75 f4             	pushl  -0xc(%ebp)
  802090:	6a 00                	push   $0x0
  802092:	e8 a8 eb ff ff       	call   800c3f <sys_page_alloc>
  802097:	83 c4 10             	add    $0x10,%esp
		return r;
  80209a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 23                	js     8020c3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020a0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020b5:	83 ec 0c             	sub    $0xc,%esp
  8020b8:	50                   	push   %eax
  8020b9:	e8 72 ed ff ff       	call   800e30 <fd2num>
  8020be:	89 c2                	mov    %eax,%edx
  8020c0:	83 c4 10             	add    $0x10,%esp
}
  8020c3:	89 d0                	mov    %edx,%eax
  8020c5:	c9                   	leave  
  8020c6:	c3                   	ret    

008020c7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	56                   	push   %esi
  8020cb:	53                   	push   %ebx
  8020cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020cf:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  8020d2:	83 ec 0c             	sub    $0xc,%esp
  8020d5:	ff 75 0c             	pushl  0xc(%ebp)
  8020d8:	e8 12 ed ff ff       	call   800def <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	85 f6                	test   %esi,%esi
  8020e2:	74 1c                	je     802100 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  8020e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e9:	8b 40 78             	mov    0x78(%eax),%eax
  8020ec:	89 06                	mov    %eax,(%esi)
  8020ee:	eb 10                	jmp    802100 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  8020f0:	83 ec 0c             	sub    $0xc,%esp
  8020f3:	68 33 2a 80 00       	push   $0x802a33
  8020f8:	e8 70 e1 ff ff       	call   80026d <cprintf>
  8020fd:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802100:	a1 04 40 80 00       	mov    0x804004,%eax
  802105:	8b 50 74             	mov    0x74(%eax),%edx
  802108:	85 d2                	test   %edx,%edx
  80210a:	74 e4                	je     8020f0 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  80210c:	85 db                	test   %ebx,%ebx
  80210e:	74 05                	je     802115 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802110:	8b 40 74             	mov    0x74(%eax),%eax
  802113:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802115:	a1 04 40 80 00       	mov    0x804004,%eax
  80211a:	8b 40 70             	mov    0x70(%eax),%eax

}
  80211d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	57                   	push   %edi
  802128:	56                   	push   %esi
  802129:	53                   	push   %ebx
  80212a:	83 ec 0c             	sub    $0xc,%esp
  80212d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802130:	8b 75 0c             	mov    0xc(%ebp),%esi
  802133:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  802136:	85 db                	test   %ebx,%ebx
  802138:	75 13                	jne    80214d <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  80213a:	6a 00                	push   $0x0
  80213c:	68 00 00 c0 ee       	push   $0xeec00000
  802141:	56                   	push   %esi
  802142:	57                   	push   %edi
  802143:	e8 84 ec ff ff       	call   800dcc <sys_ipc_try_send>
  802148:	83 c4 10             	add    $0x10,%esp
  80214b:	eb 0e                	jmp    80215b <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  80214d:	ff 75 14             	pushl  0x14(%ebp)
  802150:	53                   	push   %ebx
  802151:	56                   	push   %esi
  802152:	57                   	push   %edi
  802153:	e8 74 ec ff ff       	call   800dcc <sys_ipc_try_send>
  802158:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  80215b:	85 c0                	test   %eax,%eax
  80215d:	75 d7                	jne    802136 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  80215f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802162:	5b                   	pop    %ebx
  802163:	5e                   	pop    %esi
  802164:	5f                   	pop    %edi
  802165:	5d                   	pop    %ebp
  802166:	c3                   	ret    

00802167 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802167:	55                   	push   %ebp
  802168:	89 e5                	mov    %esp,%ebp
  80216a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80216d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802172:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802175:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80217b:	8b 52 50             	mov    0x50(%edx),%edx
  80217e:	39 ca                	cmp    %ecx,%edx
  802180:	75 0d                	jne    80218f <ipc_find_env+0x28>
			return envs[i].env_id;
  802182:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802185:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80218a:	8b 40 48             	mov    0x48(%eax),%eax
  80218d:	eb 0f                	jmp    80219e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80218f:	83 c0 01             	add    $0x1,%eax
  802192:	3d 00 04 00 00       	cmp    $0x400,%eax
  802197:	75 d9                	jne    802172 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    

008021a0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	c1 e8 16             	shr    $0x16,%eax
  8021ab:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021b2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b7:	f6 c1 01             	test   $0x1,%cl
  8021ba:	74 1d                	je     8021d9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021bc:	c1 ea 0c             	shr    $0xc,%edx
  8021bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021c6:	f6 c2 01             	test   $0x1,%dl
  8021c9:	74 0e                	je     8021d9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021cb:	c1 ea 0c             	shr    $0xc,%edx
  8021ce:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021d5:	ef 
  8021d6:	0f b7 c0             	movzwl %ax,%eax
}
  8021d9:	5d                   	pop    %ebp
  8021da:	c3                   	ret    
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
