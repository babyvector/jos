
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 a0 23 80 00       	push   $0x8023a0
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 08 1c 00 00       	call   801c59 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 ee 23 80 00       	push   $0x8023ee
  80005e:	6a 0d                	push   $0xd
  800060:	68 f7 23 80 00       	push   $0x8023f7
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 1b 10 00 00       	call   80108a <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 0c 24 80 00       	push   $0x80240c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 f7 23 80 00       	push   $0x8023f7
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 89 13 00 00       	call   80141f <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 15 24 80 00       	push   $0x802415
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 97 13 00 00       	call   80146f <dup>
			sys_yield();
  8000d8:	e8 e5 0b 00 00       	call   800cc2 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 36 13 00 00       	call   80141f <close>
			sys_yield();
  8000e9:	e8 d4 0b 00 00       	call   800cc2 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 8a 1c 00 00       	call   801dac <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 19 24 80 00       	push   $0x802419
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 24 0b 00 00       	call   800c62 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 35 24 80 00       	push   $0x802435
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 3b 1c 00 00       	call   801dac <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 c4 23 80 00       	push   $0x8023c4
  800180:	6a 40                	push   $0x40
  800182:	68 f7 23 80 00       	push   $0x8023f7
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 5a 11 00 00       	call   8012f5 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 4b 24 80 00       	push   $0x80244b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 f7 23 80 00       	push   $0x8023f7
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 d0 10 00 00       	call   80128f <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 63 24 80 00 	movl   $0x802463,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 bd 0a 00 00       	call   800ca3 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 23 12 00 00       	call   80144a <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 31 0a 00 00       	call   800c62 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 5a 0a 00 00       	call   800ca3 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 84 24 80 00       	push   $0x802484
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 a3 28 80 00 	movl   $0x8028a3,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 79 09 00 00       	call   800c25 <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 1e 09 00 00       	call   800c25 <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 89 1d 00 00       	call   802100 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 76 1e 00 00       	call   802230 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 a7 24 80 00 	movsbl 0x8024a7(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 d3 03 00 00    	je     800835 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 64 03 00 00    	ja     80081a <vprintfmt+0x3d4>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e1:	83 fa 09             	cmp    $0x9,%edx
  8004e4:	77 39                	ja     80051f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xdf>
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	0f 49 c8             	cmovns %eax,%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 8c                	jmp    80049f <vprintfmt+0x59>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 80                	jmp    80049f <vprintfmt+0x59>
  80051f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800522:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 70 ff ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  80052f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80053c:	e9 5e ff ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800541:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800547:	e9 53 ff ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 30                	pushl  (%eax)
  80055b:	ff d6                	call   *%esi
			break;
  80055d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800563:	e9 04 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
  800574:	31 d0                	xor    %edx,%eax
  800576:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 f8 0f             	cmp    $0xf,%eax
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x142>
  80057d:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 bf 24 80 00       	push   $0x8024bf
  80058e:	53                   	push   %ebx
  80058f:	56                   	push   %esi
  800590:	e8 94 fe ff ff       	call   800429 <printfmt>
  800595:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059b:	e9 cc fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a0:	52                   	push   %edx
  8005a1:	68 e9 29 80 00       	push   $0x8029e9
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 7c fe ff ff       	call   800429 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 b4 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	b8 b8 24 80 00       	mov    $0x8024b8,%eax
  8005ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 8e 94 00 00 00    	jle    80066b <vprintfmt+0x225>
  8005d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005db:	0f 84 98 00 00 00    	je     800679 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 c8             	pushl  -0x38(%ebp)
  8005e7:	57                   	push   %edi
  8005e8:	e8 d0 02 00 00       	call   8008bd <strnlen>
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c0>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	b8 00 00 00 00       	mov    $0x0,%eax
  800626:	0f 49 c1             	cmovns %ecx,%eax
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	89 cb                	mov    %ecx,%ebx
  800636:	eb 4d                	jmp    800685 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	74 1b                	je     800659 <vprintfmt+0x213>
  80063e:	0f be c0             	movsbl %al,%eax
  800641:	83 e8 20             	sub    $0x20,%eax
  800644:	83 f8 5e             	cmp    $0x5e,%eax
  800647:	76 10                	jbe    800659 <vprintfmt+0x213>
					putch('?', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 3f                	push   $0x3f
  800651:	ff 55 08             	call   *0x8(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	eb 1a                	jmp    800685 <vprintfmt+0x23f>
  80066b:	89 75 08             	mov    %esi,0x8(%ebp)
  80066e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800674:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800677:	eb 0c                	jmp    800685 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	83 c7 01             	add    $0x1,%edi
  800688:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 23                	je     8006b6 <vprintfmt+0x270>
  800693:	85 f6                	test   %esi,%esi
  800695:	78 a1                	js     800638 <vprintfmt+0x1f2>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	79 9c                	jns    800638 <vprintfmt+0x1f2>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	eb 18                	jmp    8006be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 20                	push   $0x20
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x278>
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f e4                	jg     8006a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 a2 fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ca:	83 fa 01             	cmp    $0x1,%edx
  8006cd:	7e 16                	jle    8006e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 08             	lea    0x8(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006e0:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006e3:	eb 32                	jmp    800717 <vprintfmt+0x2d1>
	else if (lflag)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 18                	je     800701 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800717:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80071a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80071d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800720:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800723:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800728:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80072c:	0f 89 b0 00 00 00    	jns    8007e2 <vprintfmt+0x39c>
				putch('-', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	6a 2d                	push   $0x2d
  800738:	ff d6                	call   *%esi
				num = -(long long) num;
  80073a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80073d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800740:	f7 d8                	neg    %eax
  800742:	83 d2 00             	adc    $0x0,%edx
  800745:	f7 da                	neg    %edx
  800747:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800750:	b8 0a 00 00 00       	mov    $0xa,%eax
  800755:	e9 88 00 00 00       	jmp    8007e2 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 70 fc ff ff       	call   8003d2 <getuint>
  800762:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800765:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800768:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80076d:	eb 73                	jmp    8007e2 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
  800772:	e8 5b fc ff ff       	call   8003d2 <getuint>
  800777:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 58                	push   $0x58
  800783:	ff d6                	call   *%esi
			putch('X', putdat);
  800785:	83 c4 08             	add    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 58                	push   $0x58
  80078b:	ff d6                	call   *%esi
			putch('X', putdat);
  80078d:	83 c4 08             	add    $0x8,%esp
  800790:	53                   	push   %ebx
  800791:	6a 58                	push   $0x58
  800793:	ff d6                	call   *%esi
			goto number;
  800795:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800798:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80079d:	eb 43                	jmp    8007e2 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 30                	push   $0x30
  8007a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a7:	83 c4 08             	add    $0x8,%esp
  8007aa:	53                   	push   %ebx
  8007ab:	6a 78                	push   $0x78
  8007ad:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b8:	8b 00                	mov    (%eax),%eax
  8007ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007cd:	eb 13                	jmp    8007e2 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 fb fb ff ff       	call   8003d2 <getuint>
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8007dd:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e2:	83 ec 0c             	sub    $0xc,%esp
  8007e5:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8007e9:	52                   	push   %edx
  8007ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ed:	50                   	push   %eax
  8007ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8007f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007f4:	89 da                	mov    %ebx,%edx
  8007f6:	89 f0                	mov    %esi,%eax
  8007f8:	e8 26 fb ff ff       	call   800323 <printnum>
			break;
  8007fd:	83 c4 20             	add    $0x20,%esp
  800800:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800803:	e9 64 fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	53                   	push   %ebx
  80080c:	51                   	push   %ecx
  80080d:	ff d6                	call   *%esi
			break;
  80080f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800815:	e9 52 fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	53                   	push   %ebx
  80081e:	6a 25                	push   $0x25
  800820:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	eb 03                	jmp    80082a <vprintfmt+0x3e4>
  800827:	83 ef 01             	sub    $0x1,%edi
  80082a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80082e:	75 f7                	jne    800827 <vprintfmt+0x3e1>
  800830:	e9 37 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800835:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5f                   	pop    %edi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 18             	sub    $0x18,%esp
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800850:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085a:	85 c0                	test   %eax,%eax
  80085c:	74 26                	je     800884 <vsnprintf+0x47>
  80085e:	85 d2                	test   %edx,%edx
  800860:	7e 22                	jle    800884 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800862:	ff 75 14             	pushl  0x14(%ebp)
  800865:	ff 75 10             	pushl  0x10(%ebp)
  800868:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086b:	50                   	push   %eax
  80086c:	68 0c 04 80 00       	push   $0x80040c
  800871:	e8 d0 fb ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800876:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800879:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	eb 05                	jmp    800889 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800884:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800891:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800894:	50                   	push   %eax
  800895:	ff 75 10             	pushl  0x10(%ebp)
  800898:	ff 75 0c             	pushl  0xc(%ebp)
  80089b:	ff 75 08             	pushl  0x8(%ebp)
  80089e:	e8 9a ff ff ff       	call   80083d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b0:	eb 03                	jmp    8008b5 <strlen+0x10>
		n++;
  8008b2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b9:	75 f7                	jne    8008b2 <strlen+0xd>
		n++;
	return n;
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8008cb:	eb 03                	jmp    8008d0 <strnlen+0x13>
		n++;
  8008cd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d0:	39 c2                	cmp    %eax,%edx
  8008d2:	74 08                	je     8008dc <strnlen+0x1f>
  8008d4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008d8:	75 f3                	jne    8008cd <strnlen+0x10>
  8008da:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	53                   	push   %ebx
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e8:	89 c2                	mov    %eax,%edx
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	83 c1 01             	add    $0x1,%ecx
  8008f0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	75 ef                	jne    8008ea <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008fb:	5b                   	pop    %ebx
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	53                   	push   %ebx
  800902:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800905:	53                   	push   %ebx
  800906:	e8 9a ff ff ff       	call   8008a5 <strlen>
  80090b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090e:	ff 75 0c             	pushl  0xc(%ebp)
  800911:	01 d8                	add    %ebx,%eax
  800913:	50                   	push   %eax
  800914:	e8 c5 ff ff ff       	call   8008de <strcpy>
	return dst;
}
  800919:	89 d8                	mov    %ebx,%eax
  80091b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 75 08             	mov    0x8(%ebp),%esi
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092b:	89 f3                	mov    %esi,%ebx
  80092d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800930:	89 f2                	mov    %esi,%edx
  800932:	eb 0f                	jmp    800943 <strncpy+0x23>
		*dst++ = *src;
  800934:	83 c2 01             	add    $0x1,%edx
  800937:	0f b6 01             	movzbl (%ecx),%eax
  80093a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093d:	80 39 01             	cmpb   $0x1,(%ecx)
  800940:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800943:	39 da                	cmp    %ebx,%edx
  800945:	75 ed                	jne    800934 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800947:	89 f0                	mov    %esi,%eax
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 75 08             	mov    0x8(%ebp),%esi
  800955:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800958:	8b 55 10             	mov    0x10(%ebp),%edx
  80095b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095d:	85 d2                	test   %edx,%edx
  80095f:	74 21                	je     800982 <strlcpy+0x35>
  800961:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800965:	89 f2                	mov    %esi,%edx
  800967:	eb 09                	jmp    800972 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800969:	83 c2 01             	add    $0x1,%edx
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800972:	39 c2                	cmp    %eax,%edx
  800974:	74 09                	je     80097f <strlcpy+0x32>
  800976:	0f b6 19             	movzbl (%ecx),%ebx
  800979:	84 db                	test   %bl,%bl
  80097b:	75 ec                	jne    800969 <strlcpy+0x1c>
  80097d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80097f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800982:	29 f0                	sub    %esi,%eax
}
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800991:	eb 06                	jmp    800999 <strcmp+0x11>
		p++, q++;
  800993:	83 c1 01             	add    $0x1,%ecx
  800996:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	84 c0                	test   %al,%al
  80099e:	74 04                	je     8009a4 <strcmp+0x1c>
  8009a0:	3a 02                	cmp    (%edx),%al
  8009a2:	74 ef                	je     800993 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a4:	0f b6 c0             	movzbl %al,%eax
  8009a7:	0f b6 12             	movzbl (%edx),%edx
  8009aa:	29 d0                	sub    %edx,%eax
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	53                   	push   %ebx
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b8:	89 c3                	mov    %eax,%ebx
  8009ba:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009bd:	eb 06                	jmp    8009c5 <strncmp+0x17>
		n--, p++, q++;
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c5:	39 d8                	cmp    %ebx,%eax
  8009c7:	74 15                	je     8009de <strncmp+0x30>
  8009c9:	0f b6 08             	movzbl (%eax),%ecx
  8009cc:	84 c9                	test   %cl,%cl
  8009ce:	74 04                	je     8009d4 <strncmp+0x26>
  8009d0:	3a 0a                	cmp    (%edx),%cl
  8009d2:	74 eb                	je     8009bf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d4:	0f b6 00             	movzbl (%eax),%eax
  8009d7:	0f b6 12             	movzbl (%edx),%edx
  8009da:	29 d0                	sub    %edx,%eax
  8009dc:	eb 05                	jmp    8009e3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f0:	eb 07                	jmp    8009f9 <strchr+0x13>
		if (*s == c)
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	74 0f                	je     800a05 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	0f b6 10             	movzbl (%eax),%edx
  8009fc:	84 d2                	test   %dl,%dl
  8009fe:	75 f2                	jne    8009f2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a11:	eb 03                	jmp    800a16 <strfind+0xf>
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a19:	38 ca                	cmp    %cl,%dl
  800a1b:	74 04                	je     800a21 <strfind+0x1a>
  800a1d:	84 d2                	test   %dl,%dl
  800a1f:	75 f2                	jne    800a13 <strfind+0xc>
			break;
	return (char *) s;
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2f:	85 c9                	test   %ecx,%ecx
  800a31:	74 36                	je     800a69 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a33:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a39:	75 28                	jne    800a63 <memset+0x40>
  800a3b:	f6 c1 03             	test   $0x3,%cl
  800a3e:	75 23                	jne    800a63 <memset+0x40>
		c &= 0xFF;
  800a40:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a44:	89 d3                	mov    %edx,%ebx
  800a46:	c1 e3 08             	shl    $0x8,%ebx
  800a49:	89 d6                	mov    %edx,%esi
  800a4b:	c1 e6 18             	shl    $0x18,%esi
  800a4e:	89 d0                	mov    %edx,%eax
  800a50:	c1 e0 10             	shl    $0x10,%eax
  800a53:	09 f0                	or     %esi,%eax
  800a55:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a57:	89 d8                	mov    %ebx,%eax
  800a59:	09 d0                	or     %edx,%eax
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
  800a5e:	fc                   	cld    
  800a5f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a61:	eb 06                	jmp    800a69 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	fc                   	cld    
  800a67:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a69:	89 f8                	mov    %edi,%eax
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7e:	39 c6                	cmp    %eax,%esi
  800a80:	73 35                	jae    800ab7 <memmove+0x47>
  800a82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a85:	39 d0                	cmp    %edx,%eax
  800a87:	73 2e                	jae    800ab7 <memmove+0x47>
		s += n;
		d += n;
  800a89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	09 fe                	or     %edi,%esi
  800a90:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a96:	75 13                	jne    800aab <memmove+0x3b>
  800a98:	f6 c1 03             	test   $0x3,%cl
  800a9b:	75 0e                	jne    800aab <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a9d:	83 ef 04             	sub    $0x4,%edi
  800aa0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa3:	c1 e9 02             	shr    $0x2,%ecx
  800aa6:	fd                   	std    
  800aa7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa9:	eb 09                	jmp    800ab4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aab:	83 ef 01             	sub    $0x1,%edi
  800aae:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab1:	fd                   	std    
  800ab2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab4:	fc                   	cld    
  800ab5:	eb 1d                	jmp    800ad4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab7:	89 f2                	mov    %esi,%edx
  800ab9:	09 c2                	or     %eax,%edx
  800abb:	f6 c2 03             	test   $0x3,%dl
  800abe:	75 0f                	jne    800acf <memmove+0x5f>
  800ac0:	f6 c1 03             	test   $0x3,%cl
  800ac3:	75 0a                	jne    800acf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ac5:	c1 e9 02             	shr    $0x2,%ecx
  800ac8:	89 c7                	mov    %eax,%edi
  800aca:	fc                   	cld    
  800acb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acd:	eb 05                	jmp    800ad4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	fc                   	cld    
  800ad2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800adb:	ff 75 10             	pushl  0x10(%ebp)
  800ade:	ff 75 0c             	pushl  0xc(%ebp)
  800ae1:	ff 75 08             	pushl  0x8(%ebp)
  800ae4:	e8 87 ff ff ff       	call   800a70 <memmove>
}
  800ae9:	c9                   	leave  
  800aea:	c3                   	ret    

00800aeb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	eb 1a                	jmp    800b17 <memcmp+0x2c>
		if (*s1 != *s2)
  800afd:	0f b6 08             	movzbl (%eax),%ecx
  800b00:	0f b6 1a             	movzbl (%edx),%ebx
  800b03:	38 d9                	cmp    %bl,%cl
  800b05:	74 0a                	je     800b11 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b07:	0f b6 c1             	movzbl %cl,%eax
  800b0a:	0f b6 db             	movzbl %bl,%ebx
  800b0d:	29 d8                	sub    %ebx,%eax
  800b0f:	eb 0f                	jmp    800b20 <memcmp+0x35>
		s1++, s2++;
  800b11:	83 c0 01             	add    $0x1,%eax
  800b14:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b17:	39 f0                	cmp    %esi,%eax
  800b19:	75 e2                	jne    800afd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	53                   	push   %ebx
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b2b:	89 c1                	mov    %eax,%ecx
  800b2d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b30:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b34:	eb 0a                	jmp    800b40 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	0f b6 10             	movzbl (%eax),%edx
  800b39:	39 da                	cmp    %ebx,%edx
  800b3b:	74 07                	je     800b44 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b3d:	83 c0 01             	add    $0x1,%eax
  800b40:	39 c8                	cmp    %ecx,%eax
  800b42:	72 f2                	jb     800b36 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b44:	5b                   	pop    %ebx
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b53:	eb 03                	jmp    800b58 <strtol+0x11>
		s++;
  800b55:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b58:	0f b6 01             	movzbl (%ecx),%eax
  800b5b:	3c 20                	cmp    $0x20,%al
  800b5d:	74 f6                	je     800b55 <strtol+0xe>
  800b5f:	3c 09                	cmp    $0x9,%al
  800b61:	74 f2                	je     800b55 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b63:	3c 2b                	cmp    $0x2b,%al
  800b65:	75 0a                	jne    800b71 <strtol+0x2a>
		s++;
  800b67:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6f:	eb 11                	jmp    800b82 <strtol+0x3b>
  800b71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b76:	3c 2d                	cmp    $0x2d,%al
  800b78:	75 08                	jne    800b82 <strtol+0x3b>
		s++, neg = 1;
  800b7a:	83 c1 01             	add    $0x1,%ecx
  800b7d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b82:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b88:	75 15                	jne    800b9f <strtol+0x58>
  800b8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8d:	75 10                	jne    800b9f <strtol+0x58>
  800b8f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b93:	75 7c                	jne    800c11 <strtol+0xca>
		s += 2, base = 16;
  800b95:	83 c1 02             	add    $0x2,%ecx
  800b98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9d:	eb 16                	jmp    800bb5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b9f:	85 db                	test   %ebx,%ebx
  800ba1:	75 12                	jne    800bb5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba8:	80 39 30             	cmpb   $0x30,(%ecx)
  800bab:	75 08                	jne    800bb5 <strtol+0x6e>
		s++, base = 8;
  800bad:	83 c1 01             	add    $0x1,%ecx
  800bb0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bba:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bbd:	0f b6 11             	movzbl (%ecx),%edx
  800bc0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc3:	89 f3                	mov    %esi,%ebx
  800bc5:	80 fb 09             	cmp    $0x9,%bl
  800bc8:	77 08                	ja     800bd2 <strtol+0x8b>
			dig = *s - '0';
  800bca:	0f be d2             	movsbl %dl,%edx
  800bcd:	83 ea 30             	sub    $0x30,%edx
  800bd0:	eb 22                	jmp    800bf4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bd2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd5:	89 f3                	mov    %esi,%ebx
  800bd7:	80 fb 19             	cmp    $0x19,%bl
  800bda:	77 08                	ja     800be4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bdc:	0f be d2             	movsbl %dl,%edx
  800bdf:	83 ea 57             	sub    $0x57,%edx
  800be2:	eb 10                	jmp    800bf4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800be4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be7:	89 f3                	mov    %esi,%ebx
  800be9:	80 fb 19             	cmp    $0x19,%bl
  800bec:	77 16                	ja     800c04 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bee:	0f be d2             	movsbl %dl,%edx
  800bf1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bf4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf7:	7d 0b                	jge    800c04 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bf9:	83 c1 01             	add    $0x1,%ecx
  800bfc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c00:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c02:	eb b9                	jmp    800bbd <strtol+0x76>

	if (endptr)
  800c04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c08:	74 0d                	je     800c17 <strtol+0xd0>
		*endptr = (char *) s;
  800c0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0d:	89 0e                	mov    %ecx,(%esi)
  800c0f:	eb 06                	jmp    800c17 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c11:	85 db                	test   %ebx,%ebx
  800c13:	74 98                	je     800bad <strtol+0x66>
  800c15:	eb 9e                	jmp    800bb5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c17:	89 c2                	mov    %eax,%edx
  800c19:	f7 da                	neg    %edx
  800c1b:	85 ff                	test   %edi,%edi
  800c1d:	0f 45 c2             	cmovne %edx,%eax
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	89 c3                	mov    %eax,%ebx
  800c38:	89 c7                	mov    %eax,%edi
  800c3a:	89 c6                	mov    %eax,%esi
  800c3c:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c49:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c53:	89 d1                	mov    %edx,%ecx
  800c55:	89 d3                	mov    %edx,%ebx
  800c57:	89 d7                	mov    %edx,%edi
  800c59:	89 d6                	mov    %edx,%esi
  800c5b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c70:	b8 03 00 00 00       	mov    $0x3,%eax
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	89 cb                	mov    %ecx,%ebx
  800c7a:	89 cf                	mov    %ecx,%edi
  800c7c:	89 ce                	mov    %ecx,%esi
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 03                	push   $0x3
  800c8a:	68 9f 27 80 00       	push   $0x80279f
  800c8f:	6a 23                	push   $0x23
  800c91:	68 bc 27 80 00       	push   $0x8027bc
  800c96:	e8 9b f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ca9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cae:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_yield>:

void
sys_yield(void)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cea:	be 00 00 00 00       	mov    $0x0,%esi
  800cef:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfd:	89 f7                	mov    %esi,%edi
  800cff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 04                	push   $0x4
  800d0b:	68 9f 27 80 00       	push   $0x80279f
  800d10:	6a 23                	push   $0x23
  800d12:	68 bc 27 80 00       	push   $0x8027bc
  800d17:	e8 1a f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800d2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 17                	jle    800d5e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 05                	push   $0x5
  800d4d:	68 9f 27 80 00       	push   $0x80279f
  800d52:	6a 23                	push   $0x23
  800d54:	68 bc 27 80 00       	push   $0x8027bc
  800d59:	e8 d8 f4 ff ff       	call   800236 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	b8 06 00 00 00       	mov    $0x6,%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7e 17                	jle    800da0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	50                   	push   %eax
  800d8d:	6a 06                	push   $0x6
  800d8f:	68 9f 27 80 00       	push   $0x80279f
  800d94:	6a 23                	push   $0x23
  800d96:	68 bc 27 80 00       	push   $0x8027bc
  800d9b:	e8 96 f4 ff ff       	call   800236 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800db1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db6:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	89 df                	mov    %ebx,%edi
  800dc3:	89 de                	mov    %ebx,%esi
  800dc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	7e 17                	jle    800de2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	50                   	push   %eax
  800dcf:	6a 08                	push   $0x8
  800dd1:	68 9f 27 80 00       	push   $0x80279f
  800dd6:	6a 23                	push   $0x23
  800dd8:	68 bc 27 80 00       	push   $0x8027bc
  800ddd:	e8 54 f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800df3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	89 df                	mov    %ebx,%edi
  800e05:	89 de                	mov    %ebx,%esi
  800e07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 17                	jle    800e24 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	50                   	push   %eax
  800e11:	6a 09                	push   $0x9
  800e13:	68 9f 27 80 00       	push   $0x80279f
  800e18:	6a 23                	push   $0x23
  800e1a:	68 bc 27 80 00       	push   $0x8027bc
  800e1f:	e8 12 f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	89 df                	mov    %ebx,%edi
  800e47:	89 de                	mov    %ebx,%esi
  800e49:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	7e 17                	jle    800e66 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4f:	83 ec 0c             	sub    $0xc,%esp
  800e52:	50                   	push   %eax
  800e53:	6a 0a                	push   $0xa
  800e55:	68 9f 27 80 00       	push   $0x80279f
  800e5a:	6a 23                	push   $0x23
  800e5c:	68 bc 27 80 00       	push   $0x8027bc
  800e61:	e8 d0 f3 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e74:	be 00 00 00 00       	mov    $0x0,%esi
  800e79:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e81:	8b 55 08             	mov    0x8(%ebp),%edx
  800e84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 cb                	mov    %ecx,%ebx
  800ea9:	89 cf                	mov    %ecx,%edi
  800eab:	89 ce                	mov    %ecx,%esi
  800ead:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	7e 17                	jle    800eca <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb3:	83 ec 0c             	sub    $0xc,%esp
  800eb6:	50                   	push   %eax
  800eb7:	6a 0d                	push   $0xd
  800eb9:	68 9f 27 80 00       	push   $0x80279f
  800ebe:	6a 23                	push   $0x23
  800ec0:	68 bc 27 80 00       	push   $0x8027bc
  800ec5:	e8 6c f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eda:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800edc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee0:	74 11                	je     800ef3 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800ee2:	89 d8                	mov    %ebx,%eax
  800ee4:	c1 e8 0c             	shr    $0xc,%eax
  800ee7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800eee:	f6 c4 08             	test   $0x8,%ah
  800ef1:	75 14                	jne    800f07 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 ca 27 80 00       	push   $0x8027ca
  800efb:	6a 21                	push   $0x21
  800efd:	68 e0 27 80 00       	push   $0x8027e0
  800f02:	e8 2f f3 ff ff       	call   800236 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800f07:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f0d:	e8 91 fd ff ff       	call   800ca3 <sys_getenvid>
  800f12:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	6a 07                	push   $0x7
  800f19:	68 00 f0 7f 00       	push   $0x7ff000
  800f1e:	50                   	push   %eax
  800f1f:	e8 bd fd ff ff       	call   800ce1 <sys_page_alloc>
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	79 14                	jns    800f3f <pgfault+0x6d>
		panic("sys_page_alloc");
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	68 eb 27 80 00       	push   $0x8027eb
  800f33:	6a 30                	push   $0x30
  800f35:	68 e0 27 80 00       	push   $0x8027e0
  800f3a:	e8 f7 f2 ff ff       	call   800236 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800f3f:	83 ec 04             	sub    $0x4,%esp
  800f42:	68 00 10 00 00       	push   $0x1000
  800f47:	53                   	push   %ebx
  800f48:	68 00 f0 7f 00       	push   $0x7ff000
  800f4d:	e8 86 fb ff ff       	call   800ad8 <memcpy>
	retv = sys_page_unmap(envid, addr);
  800f52:	83 c4 08             	add    $0x8,%esp
  800f55:	53                   	push   %ebx
  800f56:	56                   	push   %esi
  800f57:	e8 0a fe ff ff       	call   800d66 <sys_page_unmap>
	if(retv < 0){
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 12                	jns    800f75 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800f63:	50                   	push   %eax
  800f64:	68 d8 28 80 00       	push   $0x8028d8
  800f69:	6a 35                	push   $0x35
  800f6b:	68 e0 27 80 00       	push   $0x8027e0
  800f70:	e8 c1 f2 ff ff       	call   800236 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	6a 07                	push   $0x7
  800f7a:	53                   	push   %ebx
  800f7b:	56                   	push   %esi
  800f7c:	68 00 f0 7f 00       	push   $0x7ff000
  800f81:	56                   	push   %esi
  800f82:	e8 9d fd ff ff       	call   800d24 <sys_page_map>
	if(retv < 0){
  800f87:	83 c4 20             	add    $0x20,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	79 14                	jns    800fa2 <pgfault+0xd0>
		panic("sys_page_map");
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	68 fa 27 80 00       	push   $0x8027fa
  800f96:	6a 39                	push   $0x39
  800f98:	68 e0 27 80 00       	push   $0x8027e0
  800f9d:	e8 94 f2 ff ff       	call   800236 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800fa2:	83 ec 08             	sub    $0x8,%esp
  800fa5:	68 00 f0 7f 00       	push   $0x7ff000
  800faa:	56                   	push   %esi
  800fab:	e8 b6 fd ff ff       	call   800d66 <sys_page_unmap>
	if(retv < 0){
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 14                	jns    800fcb <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	68 07 28 80 00       	push   $0x802807
  800fbf:	6a 3d                	push   $0x3d
  800fc1:	68 e0 27 80 00       	push   $0x8027e0
  800fc6:	e8 6b f2 ff ff       	call   800236 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800fcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800fda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fdd:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	53                   	push   %ebx
  800fe4:	68 24 28 80 00       	push   $0x802824
  800fe9:	e8 21 f3 ff ff       	call   80030f <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800fee:	83 c4 0c             	add    $0xc,%esp
  800ff1:	6a 07                	push   $0x7
  800ff3:	53                   	push   %ebx
  800ff4:	56                   	push   %esi
  800ff5:	e8 e7 fc ff ff       	call   800ce1 <sys_page_alloc>
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	79 15                	jns    801016 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  801001:	50                   	push   %eax
  801002:	68 37 28 80 00       	push   $0x802837
  801007:	68 90 00 00 00       	push   $0x90
  80100c:	68 e0 27 80 00       	push   $0x8027e0
  801011:	e8 20 f2 ff ff       	call   800236 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	68 4a 28 80 00       	push   $0x80284a
  80101e:	e8 ec f2 ff ff       	call   80030f <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801023:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80102a:	68 00 00 40 00       	push   $0x400000
  80102f:	6a 00                	push   $0x0
  801031:	53                   	push   %ebx
  801032:	56                   	push   %esi
  801033:	e8 ec fc ff ff       	call   800d24 <sys_page_map>
  801038:	83 c4 20             	add    $0x20,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	79 15                	jns    801054 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  80103f:	50                   	push   %eax
  801040:	68 52 28 80 00       	push   $0x802852
  801045:	68 94 00 00 00       	push   $0x94
  80104a:	68 e0 27 80 00       	push   $0x8027e0
  80104f:	e8 e2 f1 ff ff       	call   800236 <_panic>
        cprintf("af_p_m.");
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	68 63 28 80 00       	push   $0x802863
  80105c:	e8 ae f2 ff ff       	call   80030f <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  801061:	83 c4 0c             	add    $0xc,%esp
  801064:	68 00 10 00 00       	push   $0x1000
  801069:	53                   	push   %ebx
  80106a:	68 00 00 40 00       	push   $0x400000
  80106f:	e8 fc f9 ff ff       	call   800a70 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  801074:	c7 04 24 6b 28 80 00 	movl   $0x80286b,(%esp)
  80107b:	e8 8f f2 ff ff       	call   80030f <cprintf>
}
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	57                   	push   %edi
  80108e:	56                   	push   %esi
  80108f:	53                   	push   %ebx
  801090:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  801093:	68 d2 0e 80 00       	push   $0x800ed2
  801098:	e8 c5 0e 00 00       	call   801f62 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80109d:	b8 07 00 00 00       	mov    $0x7,%eax
  8010a2:	cd 30                	int    $0x30
  8010a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	79 17                	jns    8010c8 <fork+0x3e>
		panic("sys_exofork failed.");
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	68 79 28 80 00       	push   $0x802879
  8010b9:	68 b7 00 00 00       	push   $0xb7
  8010be:	68 e0 27 80 00       	push   $0x8027e0
  8010c3:	e8 6e f1 ff ff       	call   800236 <_panic>
  8010c8:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  8010cd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010d1:	75 21                	jne    8010f4 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010d3:	e8 cb fb ff ff       	call   800ca3 <sys_getenvid>
  8010d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e5:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ef:	e9 69 01 00 00       	jmp    80125d <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8010f4:	89 d8                	mov    %ebx,%eax
  8010f6:	c1 e8 16             	shr    $0x16,%eax
  8010f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  801100:	a8 01                	test   $0x1,%al
  801102:	0f 84 d6 00 00 00    	je     8011de <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  801108:	89 de                	mov    %ebx,%esi
  80110a:	c1 ee 0c             	shr    $0xc,%esi
  80110d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801114:	a8 01                	test   $0x1,%al
  801116:	0f 84 c2 00 00 00    	je     8011de <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  80111c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  801123:	89 f7                	mov    %esi,%edi
  801125:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  801128:	e8 76 fb ff ff       	call   800ca3 <sys_getenvid>
  80112d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  801130:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801137:	f6 c4 04             	test   $0x4,%ah
  80113a:	74 1c                	je     801158 <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	68 07 0e 00 00       	push   $0xe07
  801144:	57                   	push   %edi
  801145:	ff 75 e0             	pushl  -0x20(%ebp)
  801148:	57                   	push   %edi
  801149:	6a 00                	push   $0x0
  80114b:	e8 d4 fb ff ff       	call   800d24 <sys_page_map>
  801150:	83 c4 20             	add    $0x20,%esp
  801153:	e9 86 00 00 00       	jmp    8011de <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  801158:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80115f:	a8 02                	test   $0x2,%al
  801161:	75 0c                	jne    80116f <fork+0xe5>
  801163:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116a:	f6 c4 08             	test   $0x8,%ah
  80116d:	74 5b                	je     8011ca <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	68 05 08 00 00       	push   $0x805
  801177:	57                   	push   %edi
  801178:	ff 75 e0             	pushl  -0x20(%ebp)
  80117b:	57                   	push   %edi
  80117c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117f:	e8 a0 fb ff ff       	call   800d24 <sys_page_map>
  801184:	83 c4 20             	add    $0x20,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	79 12                	jns    80119d <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  80118b:	50                   	push   %eax
  80118c:	68 fc 28 80 00       	push   $0x8028fc
  801191:	6a 5f                	push   $0x5f
  801193:	68 e0 27 80 00       	push   $0x8027e0
  801198:	e8 99 f0 ff ff       	call   800236 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	68 05 08 00 00       	push   $0x805
  8011a5:	57                   	push   %edi
  8011a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a9:	50                   	push   %eax
  8011aa:	57                   	push   %edi
  8011ab:	50                   	push   %eax
  8011ac:	e8 73 fb ff ff       	call   800d24 <sys_page_map>
  8011b1:	83 c4 20             	add    $0x20,%esp
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	79 26                	jns    8011de <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  8011b8:	50                   	push   %eax
  8011b9:	68 20 29 80 00       	push   $0x802920
  8011be:	6a 64                	push   $0x64
  8011c0:	68 e0 27 80 00       	push   $0x8027e0
  8011c5:	e8 6c f0 ff ff       	call   800236 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8011ca:	83 ec 0c             	sub    $0xc,%esp
  8011cd:	6a 05                	push   $0x5
  8011cf:	57                   	push   %edi
  8011d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d3:	57                   	push   %edi
  8011d4:	6a 00                	push   $0x0
  8011d6:	e8 49 fb ff ff       	call   800d24 <sys_page_map>
  8011db:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8011de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011e4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011ea:	0f 85 04 ff ff ff    	jne    8010f4 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	6a 07                	push   $0x7
  8011f5:	68 00 f0 bf ee       	push   $0xeebff000
  8011fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8011fd:	e8 df fa ff ff       	call   800ce1 <sys_page_alloc>
	if(retv < 0){
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	79 17                	jns    801220 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	68 8d 28 80 00       	push   $0x80288d
  801211:	68 cc 00 00 00       	push   $0xcc
  801216:	68 e0 27 80 00       	push   $0x8027e0
  80121b:	e8 16 f0 ff ff       	call   800236 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  801220:	83 ec 08             	sub    $0x8,%esp
  801223:	68 c7 1f 80 00       	push   $0x801fc7
  801228:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80122b:	57                   	push   %edi
  80122c:	e8 fb fb ff ff       	call   800e2c <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  801231:	83 c4 08             	add    $0x8,%esp
  801234:	6a 02                	push   $0x2
  801236:	57                   	push   %edi
  801237:	e8 6c fb ff ff       	call   800da8 <sys_env_set_status>
	if(retv < 0){
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	79 17                	jns    80125a <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	68 a5 28 80 00       	push   $0x8028a5
  80124b:	68 dd 00 00 00       	push   $0xdd
  801250:	68 e0 27 80 00       	push   $0x8027e0
  801255:	e8 dc ef ff ff       	call   800236 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  80125a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  80125d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <sfork>:

// Challenge!
int
sfork(void)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80126b:	68 c1 28 80 00       	push   $0x8028c1
  801270:	68 e8 00 00 00       	push   $0xe8
  801275:	68 e0 27 80 00       	push   $0x8027e0
  80127a:	e8 b7 ef ff ff       	call   800236 <_panic>

0080127f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801282:	8b 45 08             	mov    0x8(%ebp),%eax
  801285:	05 00 00 00 30       	add    $0x30000000,%eax
  80128a:	c1 e8 0c             	shr    $0xc,%eax
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	05 00 00 00 30       	add    $0x30000000,%eax
  80129a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ac:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	c1 ea 16             	shr    $0x16,%edx
  8012b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012bd:	f6 c2 01             	test   $0x1,%dl
  8012c0:	74 11                	je     8012d3 <fd_alloc+0x2d>
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	c1 ea 0c             	shr    $0xc,%edx
  8012c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ce:	f6 c2 01             	test   $0x1,%dl
  8012d1:	75 09                	jne    8012dc <fd_alloc+0x36>
			*fd_store = fd;
  8012d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012da:	eb 17                	jmp    8012f3 <fd_alloc+0x4d>
  8012dc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012e1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012e6:	75 c9                	jne    8012b1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012e8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012fb:	83 f8 1f             	cmp    $0x1f,%eax
  8012fe:	77 36                	ja     801336 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801300:	c1 e0 0c             	shl    $0xc,%eax
  801303:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801308:	89 c2                	mov    %eax,%edx
  80130a:	c1 ea 16             	shr    $0x16,%edx
  80130d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801314:	f6 c2 01             	test   $0x1,%dl
  801317:	74 24                	je     80133d <fd_lookup+0x48>
  801319:	89 c2                	mov    %eax,%edx
  80131b:	c1 ea 0c             	shr    $0xc,%edx
  80131e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801325:	f6 c2 01             	test   $0x1,%dl
  801328:	74 1a                	je     801344 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80132a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132d:	89 02                	mov    %eax,(%edx)
	return 0;
  80132f:	b8 00 00 00 00       	mov    $0x0,%eax
  801334:	eb 13                	jmp    801349 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801336:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133b:	eb 0c                	jmp    801349 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80133d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801342:	eb 05                	jmp    801349 <fd_lookup+0x54>
  801344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801354:	ba c0 29 80 00       	mov    $0x8029c0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801359:	eb 13                	jmp    80136e <dev_lookup+0x23>
  80135b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80135e:	39 08                	cmp    %ecx,(%eax)
  801360:	75 0c                	jne    80136e <dev_lookup+0x23>
			*dev = devtab[i];
  801362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801365:	89 01                	mov    %eax,(%ecx)
			return 0;
  801367:	b8 00 00 00 00       	mov    $0x0,%eax
  80136c:	eb 2e                	jmp    80139c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80136e:	8b 02                	mov    (%edx),%eax
  801370:	85 c0                	test   %eax,%eax
  801372:	75 e7                	jne    80135b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801374:	a1 04 40 80 00       	mov    0x804004,%eax
  801379:	8b 40 48             	mov    0x48(%eax),%eax
  80137c:	83 ec 04             	sub    $0x4,%esp
  80137f:	51                   	push   %ecx
  801380:	50                   	push   %eax
  801381:	68 44 29 80 00       	push   $0x802944
  801386:	e8 84 ef ff ff       	call   80030f <cprintf>
	*dev = 0;
  80138b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 10             	sub    $0x10,%esp
  8013a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013af:	50                   	push   %eax
  8013b0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013b6:	c1 e8 0c             	shr    $0xc,%eax
  8013b9:	50                   	push   %eax
  8013ba:	e8 36 ff ff ff       	call   8012f5 <fd_lookup>
  8013bf:	83 c4 08             	add    $0x8,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 05                	js     8013cb <fd_close+0x2d>
	    || fd != fd2)
  8013c6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013c9:	74 0c                	je     8013d7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013cb:	84 db                	test   %bl,%bl
  8013cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d2:	0f 44 c2             	cmove  %edx,%eax
  8013d5:	eb 41                	jmp    801418 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013dd:	50                   	push   %eax
  8013de:	ff 36                	pushl  (%esi)
  8013e0:	e8 66 ff ff ff       	call   80134b <dev_lookup>
  8013e5:	89 c3                	mov    %eax,%ebx
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 1a                	js     801408 <fd_close+0x6a>
		if (dev->dev_close)
  8013ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013f4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	74 0b                	je     801408 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	56                   	push   %esi
  801401:	ff d0                	call   *%eax
  801403:	89 c3                	mov    %eax,%ebx
  801405:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	56                   	push   %esi
  80140c:	6a 00                	push   $0x0
  80140e:	e8 53 f9 ff ff       	call   800d66 <sys_page_unmap>
	return r;
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	89 d8                	mov    %ebx,%eax
}
  801418:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801425:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	ff 75 08             	pushl  0x8(%ebp)
  80142c:	e8 c4 fe ff ff       	call   8012f5 <fd_lookup>
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	78 10                	js     801448 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	6a 01                	push   $0x1
  80143d:	ff 75 f4             	pushl  -0xc(%ebp)
  801440:	e8 59 ff ff ff       	call   80139e <fd_close>
  801445:	83 c4 10             	add    $0x10,%esp
}
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <close_all>:

void
close_all(void)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	53                   	push   %ebx
  80144e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801451:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	53                   	push   %ebx
  80145a:	e8 c0 ff ff ff       	call   80141f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80145f:	83 c3 01             	add    $0x1,%ebx
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	83 fb 20             	cmp    $0x20,%ebx
  801468:	75 ec                	jne    801456 <close_all+0xc>
		close(i);
}
  80146a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	57                   	push   %edi
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
  801475:	83 ec 2c             	sub    $0x2c,%esp
  801478:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80147b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	ff 75 08             	pushl  0x8(%ebp)
  801482:	e8 6e fe ff ff       	call   8012f5 <fd_lookup>
  801487:	83 c4 08             	add    $0x8,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	0f 88 c1 00 00 00    	js     801553 <dup+0xe4>
		return r;
	close(newfdnum);
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	56                   	push   %esi
  801496:	e8 84 ff ff ff       	call   80141f <close>

	newfd = INDEX2FD(newfdnum);
  80149b:	89 f3                	mov    %esi,%ebx
  80149d:	c1 e3 0c             	shl    $0xc,%ebx
  8014a0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014a6:	83 c4 04             	add    $0x4,%esp
  8014a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ac:	e8 de fd ff ff       	call   80128f <fd2data>
  8014b1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014b3:	89 1c 24             	mov    %ebx,(%esp)
  8014b6:	e8 d4 fd ff ff       	call   80128f <fd2data>
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014c1:	89 f8                	mov    %edi,%eax
  8014c3:	c1 e8 16             	shr    $0x16,%eax
  8014c6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014cd:	a8 01                	test   $0x1,%al
  8014cf:	74 37                	je     801508 <dup+0x99>
  8014d1:	89 f8                	mov    %edi,%eax
  8014d3:	c1 e8 0c             	shr    $0xc,%eax
  8014d6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014dd:	f6 c2 01             	test   $0x1,%dl
  8014e0:	74 26                	je     801508 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e9:	83 ec 0c             	sub    $0xc,%esp
  8014ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f1:	50                   	push   %eax
  8014f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f5:	6a 00                	push   $0x0
  8014f7:	57                   	push   %edi
  8014f8:	6a 00                	push   $0x0
  8014fa:	e8 25 f8 ff ff       	call   800d24 <sys_page_map>
  8014ff:	89 c7                	mov    %eax,%edi
  801501:	83 c4 20             	add    $0x20,%esp
  801504:	85 c0                	test   %eax,%eax
  801506:	78 2e                	js     801536 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801508:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80150b:	89 d0                	mov    %edx,%eax
  80150d:	c1 e8 0c             	shr    $0xc,%eax
  801510:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	25 07 0e 00 00       	and    $0xe07,%eax
  80151f:	50                   	push   %eax
  801520:	53                   	push   %ebx
  801521:	6a 00                	push   $0x0
  801523:	52                   	push   %edx
  801524:	6a 00                	push   $0x0
  801526:	e8 f9 f7 ff ff       	call   800d24 <sys_page_map>
  80152b:	89 c7                	mov    %eax,%edi
  80152d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801530:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801532:	85 ff                	test   %edi,%edi
  801534:	79 1d                	jns    801553 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	53                   	push   %ebx
  80153a:	6a 00                	push   $0x0
  80153c:	e8 25 f8 ff ff       	call   800d66 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801541:	83 c4 08             	add    $0x8,%esp
  801544:	ff 75 d4             	pushl  -0x2c(%ebp)
  801547:	6a 00                	push   $0x0
  801549:	e8 18 f8 ff ff       	call   800d66 <sys_page_unmap>
	return r;
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	89 f8                	mov    %edi,%eax
}
  801553:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801556:	5b                   	pop    %ebx
  801557:	5e                   	pop    %esi
  801558:	5f                   	pop    %edi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 14             	sub    $0x14,%esp
  801562:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801565:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	53                   	push   %ebx
  80156a:	e8 86 fd ff ff       	call   8012f5 <fd_lookup>
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	89 c2                	mov    %eax,%edx
  801574:	85 c0                	test   %eax,%eax
  801576:	78 6d                	js     8015e5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157e:	50                   	push   %eax
  80157f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801582:	ff 30                	pushl  (%eax)
  801584:	e8 c2 fd ff ff       	call   80134b <dev_lookup>
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 4c                	js     8015dc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801590:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801593:	8b 42 08             	mov    0x8(%edx),%eax
  801596:	83 e0 03             	and    $0x3,%eax
  801599:	83 f8 01             	cmp    $0x1,%eax
  80159c:	75 21                	jne    8015bf <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80159e:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a3:	8b 40 48             	mov    0x48(%eax),%eax
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	53                   	push   %ebx
  8015aa:	50                   	push   %eax
  8015ab:	68 85 29 80 00       	push   $0x802985
  8015b0:	e8 5a ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015bd:	eb 26                	jmp    8015e5 <read+0x8a>
	}
	if (!dev->dev_read)
  8015bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c2:	8b 40 08             	mov    0x8(%eax),%eax
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	74 17                	je     8015e0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	ff 75 10             	pushl  0x10(%ebp)
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	52                   	push   %edx
  8015d3:	ff d0                	call   *%eax
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	eb 09                	jmp    8015e5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	eb 05                	jmp    8015e5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	57                   	push   %edi
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801600:	eb 21                	jmp    801623 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	89 f0                	mov    %esi,%eax
  801607:	29 d8                	sub    %ebx,%eax
  801609:	50                   	push   %eax
  80160a:	89 d8                	mov    %ebx,%eax
  80160c:	03 45 0c             	add    0xc(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	57                   	push   %edi
  801611:	e8 45 ff ff ff       	call   80155b <read>
		if (m < 0)
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 10                	js     80162d <readn+0x41>
			return m;
		if (m == 0)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	74 0a                	je     80162b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801621:	01 c3                	add    %eax,%ebx
  801623:	39 f3                	cmp    %esi,%ebx
  801625:	72 db                	jb     801602 <readn+0x16>
  801627:	89 d8                	mov    %ebx,%eax
  801629:	eb 02                	jmp    80162d <readn+0x41>
  80162b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80162d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5f                   	pop    %edi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	53                   	push   %ebx
  801639:	83 ec 14             	sub    $0x14,%esp
  80163c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801642:	50                   	push   %eax
  801643:	53                   	push   %ebx
  801644:	e8 ac fc ff ff       	call   8012f5 <fd_lookup>
  801649:	83 c4 08             	add    $0x8,%esp
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 68                	js     8016ba <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801658:	50                   	push   %eax
  801659:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165c:	ff 30                	pushl  (%eax)
  80165e:	e8 e8 fc ff ff       	call   80134b <dev_lookup>
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	78 47                	js     8016b1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801671:	75 21                	jne    801694 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801673:	a1 04 40 80 00       	mov    0x804004,%eax
  801678:	8b 40 48             	mov    0x48(%eax),%eax
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	53                   	push   %ebx
  80167f:	50                   	push   %eax
  801680:	68 a1 29 80 00       	push   $0x8029a1
  801685:	e8 85 ec ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801692:	eb 26                	jmp    8016ba <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801694:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801697:	8b 52 0c             	mov    0xc(%edx),%edx
  80169a:	85 d2                	test   %edx,%edx
  80169c:	74 17                	je     8016b5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80169e:	83 ec 04             	sub    $0x4,%esp
  8016a1:	ff 75 10             	pushl  0x10(%ebp)
  8016a4:	ff 75 0c             	pushl  0xc(%ebp)
  8016a7:	50                   	push   %eax
  8016a8:	ff d2                	call   *%edx
  8016aa:	89 c2                	mov    %eax,%edx
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	eb 09                	jmp    8016ba <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	eb 05                	jmp    8016ba <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016ba:	89 d0                	mov    %edx,%eax
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	ff 75 08             	pushl  0x8(%ebp)
  8016ce:	e8 22 fc ff ff       	call   8012f5 <fd_lookup>
  8016d3:	83 c4 08             	add    $0x8,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 0e                	js     8016e8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 14             	sub    $0x14,%esp
  8016f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	53                   	push   %ebx
  8016f9:	e8 f7 fb ff ff       	call   8012f5 <fd_lookup>
  8016fe:	83 c4 08             	add    $0x8,%esp
  801701:	89 c2                	mov    %eax,%edx
  801703:	85 c0                	test   %eax,%eax
  801705:	78 65                	js     80176c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801711:	ff 30                	pushl  (%eax)
  801713:	e8 33 fc ff ff       	call   80134b <dev_lookup>
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 44                	js     801763 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801722:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801726:	75 21                	jne    801749 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801728:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80172d:	8b 40 48             	mov    0x48(%eax),%eax
  801730:	83 ec 04             	sub    $0x4,%esp
  801733:	53                   	push   %ebx
  801734:	50                   	push   %eax
  801735:	68 64 29 80 00       	push   $0x802964
  80173a:	e8 d0 eb ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801747:	eb 23                	jmp    80176c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801749:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174c:	8b 52 18             	mov    0x18(%edx),%edx
  80174f:	85 d2                	test   %edx,%edx
  801751:	74 14                	je     801767 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801753:	83 ec 08             	sub    $0x8,%esp
  801756:	ff 75 0c             	pushl  0xc(%ebp)
  801759:	50                   	push   %eax
  80175a:	ff d2                	call   *%edx
  80175c:	89 c2                	mov    %eax,%edx
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	eb 09                	jmp    80176c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801763:	89 c2                	mov    %eax,%edx
  801765:	eb 05                	jmp    80176c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801767:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80176c:	89 d0                	mov    %edx,%eax
  80176e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 14             	sub    $0x14,%esp
  80177a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801780:	50                   	push   %eax
  801781:	ff 75 08             	pushl  0x8(%ebp)
  801784:	e8 6c fb ff ff       	call   8012f5 <fd_lookup>
  801789:	83 c4 08             	add    $0x8,%esp
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 58                	js     8017ea <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801798:	50                   	push   %eax
  801799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179c:	ff 30                	pushl  (%eax)
  80179e:	e8 a8 fb ff ff       	call   80134b <dev_lookup>
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 37                	js     8017e1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ad:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017b1:	74 32                	je     8017e5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017b3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017b6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017bd:	00 00 00 
	stat->st_isdir = 0;
  8017c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017c7:	00 00 00 
	stat->st_dev = dev;
  8017ca:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	53                   	push   %ebx
  8017d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d7:	ff 50 14             	call   *0x14(%eax)
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	eb 09                	jmp    8017ea <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e1:	89 c2                	mov    %eax,%edx
  8017e3:	eb 05                	jmp    8017ea <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017ea:	89 d0                	mov    %edx,%eax
  8017ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	6a 00                	push   $0x0
  8017fb:	ff 75 08             	pushl  0x8(%ebp)
  8017fe:	e8 dc 01 00 00       	call   8019df <open>
  801803:	89 c3                	mov    %eax,%ebx
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 1b                	js     801827 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	ff 75 0c             	pushl  0xc(%ebp)
  801812:	50                   	push   %eax
  801813:	e8 5b ff ff ff       	call   801773 <fstat>
  801818:	89 c6                	mov    %eax,%esi
	close(fd);
  80181a:	89 1c 24             	mov    %ebx,(%esp)
  80181d:	e8 fd fb ff ff       	call   80141f <close>
	return r;
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	89 f0                	mov    %esi,%eax
}
  801827:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	89 c6                	mov    %eax,%esi
  801835:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801837:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80183e:	75 12                	jne    801852 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	6a 01                	push   $0x1
  801845:	e8 41 08 00 00       	call   80208b <ipc_find_env>
  80184a:	a3 00 40 80 00       	mov    %eax,0x804000
  80184f:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801852:	6a 07                	push   $0x7
  801854:	68 00 50 80 00       	push   $0x805000
  801859:	56                   	push   %esi
  80185a:	ff 35 00 40 80 00    	pushl  0x804000
  801860:	e8 e3 07 00 00       	call   802048 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801865:	83 c4 0c             	add    $0xc,%esp
  801868:	6a 00                	push   $0x0
  80186a:	53                   	push   %ebx
  80186b:	6a 00                	push   $0x0
  80186d:	e8 79 07 00 00       	call   801feb <ipc_recv>
}
  801872:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	8b 40 0c             	mov    0xc(%eax),%eax
  801885:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80188a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	b8 02 00 00 00       	mov    $0x2,%eax
  80189c:	e8 8d ff ff ff       	call   80182e <fsipc>
}
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8018af:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018be:	e8 6b ff ff ff       	call   80182e <fsipc>
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 04             	sub    $0x4,%esp
  8018cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018da:	ba 00 00 00 00       	mov    $0x0,%edx
  8018df:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e4:	e8 45 ff ff ff       	call   80182e <fsipc>
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 2c                	js     801919 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	68 00 50 80 00       	push   $0x805000
  8018f5:	53                   	push   %ebx
  8018f6:	e8 e3 ef ff ff       	call   8008de <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018fb:	a1 80 50 80 00       	mov    0x805080,%eax
  801900:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801906:	a1 84 50 80 00       	mov    0x805084,%eax
  80190b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801927:	8b 55 08             	mov    0x8(%ebp),%edx
  80192a:	8b 52 0c             	mov    0xc(%edx),%edx
  80192d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801933:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801938:	50                   	push   %eax
  801939:	ff 75 0c             	pushl  0xc(%ebp)
  80193c:	68 08 50 80 00       	push   $0x805008
  801941:	e8 2a f1 ff ff       	call   800a70 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801946:	ba 00 00 00 00       	mov    $0x0,%edx
  80194b:	b8 04 00 00 00       	mov    $0x4,%eax
  801950:	e8 d9 fe ff ff       	call   80182e <fsipc>
	//panic("devfile_write not implemented");
}
  801955:	c9                   	leave  
  801956:	c3                   	ret    

00801957 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195f:	8b 45 08             	mov    0x8(%ebp),%eax
  801962:	8b 40 0c             	mov    0xc(%eax),%eax
  801965:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80196a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801970:	ba 00 00 00 00       	mov    $0x0,%edx
  801975:	b8 03 00 00 00       	mov    $0x3,%eax
  80197a:	e8 af fe ff ff       	call   80182e <fsipc>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	85 c0                	test   %eax,%eax
  801983:	78 51                	js     8019d6 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801985:	39 c6                	cmp    %eax,%esi
  801987:	73 19                	jae    8019a2 <devfile_read+0x4b>
  801989:	68 d0 29 80 00       	push   $0x8029d0
  80198e:	68 d7 29 80 00       	push   $0x8029d7
  801993:	68 80 00 00 00       	push   $0x80
  801998:	68 ec 29 80 00       	push   $0x8029ec
  80199d:	e8 94 e8 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8019a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a7:	7e 19                	jle    8019c2 <devfile_read+0x6b>
  8019a9:	68 f7 29 80 00       	push   $0x8029f7
  8019ae:	68 d7 29 80 00       	push   $0x8029d7
  8019b3:	68 81 00 00 00       	push   $0x81
  8019b8:	68 ec 29 80 00       	push   $0x8029ec
  8019bd:	e8 74 e8 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c2:	83 ec 04             	sub    $0x4,%esp
  8019c5:	50                   	push   %eax
  8019c6:	68 00 50 80 00       	push   $0x805000
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	e8 9d f0 ff ff       	call   800a70 <memmove>
	return r;
  8019d3:	83 c4 10             	add    $0x10,%esp
}
  8019d6:	89 d8                	mov    %ebx,%eax
  8019d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5d                   	pop    %ebp
  8019de:	c3                   	ret    

008019df <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	53                   	push   %ebx
  8019e3:	83 ec 20             	sub    $0x20,%esp
  8019e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019e9:	53                   	push   %ebx
  8019ea:	e8 b6 ee ff ff       	call   8008a5 <strlen>
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f7:	7f 67                	jg     801a60 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ff:	50                   	push   %eax
  801a00:	e8 a1 f8 ff ff       	call   8012a6 <fd_alloc>
  801a05:	83 c4 10             	add    $0x10,%esp
		return r;
  801a08:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 57                	js     801a65 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	53                   	push   %ebx
  801a12:	68 00 50 80 00       	push   $0x805000
  801a17:	e8 c2 ee ff ff       	call   8008de <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a27:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2c:	e8 fd fd ff ff       	call   80182e <fsipc>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 c0                	test   %eax,%eax
  801a38:	79 14                	jns    801a4e <open+0x6f>
		
		fd_close(fd, 0);
  801a3a:	83 ec 08             	sub    $0x8,%esp
  801a3d:	6a 00                	push   $0x0
  801a3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a42:	e8 57 f9 ff ff       	call   80139e <fd_close>
		return r;
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	89 da                	mov    %ebx,%edx
  801a4c:	eb 17                	jmp    801a65 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	ff 75 f4             	pushl  -0xc(%ebp)
  801a54:	e8 26 f8 ff ff       	call   80127f <fd2num>
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	eb 05                	jmp    801a65 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a60:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801a65:	89 d0                	mov    %edx,%eax
  801a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a72:	ba 00 00 00 00       	mov    $0x0,%edx
  801a77:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7c:	e8 ad fd ff ff       	call   80182e <fsipc>
}
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8b:	83 ec 0c             	sub    $0xc,%esp
  801a8e:	ff 75 08             	pushl  0x8(%ebp)
  801a91:	e8 f9 f7 ff ff       	call   80128f <fd2data>
  801a96:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a98:	83 c4 08             	add    $0x8,%esp
  801a9b:	68 03 2a 80 00       	push   $0x802a03
  801aa0:	53                   	push   %ebx
  801aa1:	e8 38 ee ff ff       	call   8008de <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa6:	8b 46 04             	mov    0x4(%esi),%eax
  801aa9:	2b 06                	sub    (%esi),%eax
  801aab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab8:	00 00 00 
	stat->st_dev = &devpipe;
  801abb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ac2:	30 80 00 
	return 0;
}
  801ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801adb:	53                   	push   %ebx
  801adc:	6a 00                	push   $0x0
  801ade:	e8 83 f2 ff ff       	call   800d66 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae3:	89 1c 24             	mov    %ebx,(%esp)
  801ae6:	e8 a4 f7 ff ff       	call   80128f <fd2data>
  801aeb:	83 c4 08             	add    $0x8,%esp
  801aee:	50                   	push   %eax
  801aef:	6a 00                	push   $0x0
  801af1:	e8 70 f2 ff ff       	call   800d66 <sys_page_unmap>
}
  801af6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	57                   	push   %edi
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 1c             	sub    $0x1c,%esp
  801b04:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b07:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b09:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	ff 75 e0             	pushl  -0x20(%ebp)
  801b17:	e8 a8 05 00 00       	call   8020c4 <pageref>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	89 3c 24             	mov    %edi,(%esp)
  801b21:	e8 9e 05 00 00       	call   8020c4 <pageref>
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	39 c3                	cmp    %eax,%ebx
  801b2b:	0f 94 c1             	sete   %cl
  801b2e:	0f b6 c9             	movzbl %cl,%ecx
  801b31:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b34:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b3a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b3d:	39 ce                	cmp    %ecx,%esi
  801b3f:	74 1b                	je     801b5c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b41:	39 c3                	cmp    %eax,%ebx
  801b43:	75 c4                	jne    801b09 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b45:	8b 42 58             	mov    0x58(%edx),%eax
  801b48:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b4b:	50                   	push   %eax
  801b4c:	56                   	push   %esi
  801b4d:	68 0a 2a 80 00       	push   $0x802a0a
  801b52:	e8 b8 e7 ff ff       	call   80030f <cprintf>
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	eb ad                	jmp    801b09 <_pipeisclosed+0xe>
	}
}
  801b5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b62:	5b                   	pop    %ebx
  801b63:	5e                   	pop    %esi
  801b64:	5f                   	pop    %edi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	57                   	push   %edi
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 28             	sub    $0x28,%esp
  801b70:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b73:	56                   	push   %esi
  801b74:	e8 16 f7 ff ff       	call   80128f <fd2data>
  801b79:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b83:	eb 4b                	jmp    801bd0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b85:	89 da                	mov    %ebx,%edx
  801b87:	89 f0                	mov    %esi,%eax
  801b89:	e8 6d ff ff ff       	call   801afb <_pipeisclosed>
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	75 48                	jne    801bda <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b92:	e8 2b f1 ff ff       	call   800cc2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b97:	8b 43 04             	mov    0x4(%ebx),%eax
  801b9a:	8b 0b                	mov    (%ebx),%ecx
  801b9c:	8d 51 20             	lea    0x20(%ecx),%edx
  801b9f:	39 d0                	cmp    %edx,%eax
  801ba1:	73 e2                	jae    801b85 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801baa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bad:	89 c2                	mov    %eax,%edx
  801baf:	c1 fa 1f             	sar    $0x1f,%edx
  801bb2:	89 d1                	mov    %edx,%ecx
  801bb4:	c1 e9 1b             	shr    $0x1b,%ecx
  801bb7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bba:	83 e2 1f             	and    $0x1f,%edx
  801bbd:	29 ca                	sub    %ecx,%edx
  801bbf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bc3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bc7:	83 c0 01             	add    $0x1,%eax
  801bca:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bcd:	83 c7 01             	add    $0x1,%edi
  801bd0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bd3:	75 c2                	jne    801b97 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bd5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd8:	eb 05                	jmp    801bdf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bda:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be2:	5b                   	pop    %ebx
  801be3:	5e                   	pop    %esi
  801be4:	5f                   	pop    %edi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	57                   	push   %edi
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	83 ec 18             	sub    $0x18,%esp
  801bf0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bf3:	57                   	push   %edi
  801bf4:	e8 96 f6 ff ff       	call   80128f <fd2data>
  801bf9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c03:	eb 3d                	jmp    801c42 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c05:	85 db                	test   %ebx,%ebx
  801c07:	74 04                	je     801c0d <devpipe_read+0x26>
				return i;
  801c09:	89 d8                	mov    %ebx,%eax
  801c0b:	eb 44                	jmp    801c51 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c0d:	89 f2                	mov    %esi,%edx
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	e8 e5 fe ff ff       	call   801afb <_pipeisclosed>
  801c16:	85 c0                	test   %eax,%eax
  801c18:	75 32                	jne    801c4c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c1a:	e8 a3 f0 ff ff       	call   800cc2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c1f:	8b 06                	mov    (%esi),%eax
  801c21:	3b 46 04             	cmp    0x4(%esi),%eax
  801c24:	74 df                	je     801c05 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c26:	99                   	cltd   
  801c27:	c1 ea 1b             	shr    $0x1b,%edx
  801c2a:	01 d0                	add    %edx,%eax
  801c2c:	83 e0 1f             	and    $0x1f,%eax
  801c2f:	29 d0                	sub    %edx,%eax
  801c31:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c39:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c3c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3f:	83 c3 01             	add    $0x1,%ebx
  801c42:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c45:	75 d8                	jne    801c1f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c47:	8b 45 10             	mov    0x10(%ebp),%eax
  801c4a:	eb 05                	jmp    801c51 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c64:	50                   	push   %eax
  801c65:	e8 3c f6 ff ff       	call   8012a6 <fd_alloc>
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	89 c2                	mov    %eax,%edx
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	0f 88 2c 01 00 00    	js     801da3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	68 07 04 00 00       	push   $0x407
  801c7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c82:	6a 00                	push   $0x0
  801c84:	e8 58 f0 ff ff       	call   800ce1 <sys_page_alloc>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	89 c2                	mov    %eax,%edx
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	0f 88 0d 01 00 00    	js     801da3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c96:	83 ec 0c             	sub    $0xc,%esp
  801c99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c9c:	50                   	push   %eax
  801c9d:	e8 04 f6 ff ff       	call   8012a6 <fd_alloc>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	0f 88 e2 00 00 00    	js     801d91 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801caf:	83 ec 04             	sub    $0x4,%esp
  801cb2:	68 07 04 00 00       	push   $0x407
  801cb7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 20 f0 ff ff       	call   800ce1 <sys_page_alloc>
  801cc1:	89 c3                	mov    %eax,%ebx
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	0f 88 c3 00 00 00    	js     801d91 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd4:	e8 b6 f5 ff ff       	call   80128f <fd2data>
  801cd9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdb:	83 c4 0c             	add    $0xc,%esp
  801cde:	68 07 04 00 00       	push   $0x407
  801ce3:	50                   	push   %eax
  801ce4:	6a 00                	push   $0x0
  801ce6:	e8 f6 ef ff ff       	call   800ce1 <sys_page_alloc>
  801ceb:	89 c3                	mov    %eax,%ebx
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	0f 88 89 00 00 00    	js     801d81 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	e8 8c f5 ff ff       	call   80128f <fd2data>
  801d03:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d0a:	50                   	push   %eax
  801d0b:	6a 00                	push   $0x0
  801d0d:	56                   	push   %esi
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 0f f0 ff ff       	call   800d24 <sys_page_map>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	83 c4 20             	add    $0x20,%esp
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	78 55                	js     801d73 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d27:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d41:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d48:	83 ec 0c             	sub    $0xc,%esp
  801d4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4e:	e8 2c f5 ff ff       	call   80127f <fd2num>
  801d53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d56:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d58:	83 c4 04             	add    $0x4,%esp
  801d5b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5e:	e8 1c f5 ff ff       	call   80127f <fd2num>
  801d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d66:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d71:	eb 30                	jmp    801da3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d73:	83 ec 08             	sub    $0x8,%esp
  801d76:	56                   	push   %esi
  801d77:	6a 00                	push   $0x0
  801d79:	e8 e8 ef ff ff       	call   800d66 <sys_page_unmap>
  801d7e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d81:	83 ec 08             	sub    $0x8,%esp
  801d84:	ff 75 f0             	pushl  -0x10(%ebp)
  801d87:	6a 00                	push   $0x0
  801d89:	e8 d8 ef ff ff       	call   800d66 <sys_page_unmap>
  801d8e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d91:	83 ec 08             	sub    $0x8,%esp
  801d94:	ff 75 f4             	pushl  -0xc(%ebp)
  801d97:	6a 00                	push   $0x0
  801d99:	e8 c8 ef ff ff       	call   800d66 <sys_page_unmap>
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801da3:	89 d0                	mov    %edx,%eax
  801da5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    

00801dac <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db5:	50                   	push   %eax
  801db6:	ff 75 08             	pushl  0x8(%ebp)
  801db9:	e8 37 f5 ff ff       	call   8012f5 <fd_lookup>
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	78 18                	js     801ddd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dc5:	83 ec 0c             	sub    $0xc,%esp
  801dc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcb:	e8 bf f4 ff ff       	call   80128f <fd2data>
	return _pipeisclosed(fd, p);
  801dd0:	89 c2                	mov    %eax,%edx
  801dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd5:	e8 21 fd ff ff       	call   801afb <_pipeisclosed>
  801dda:	83 c4 10             	add    $0x10,%esp
}
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801de2:	b8 00 00 00 00       	mov    $0x0,%eax
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    

00801de9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801def:	68 22 2a 80 00       	push   $0x802a22
  801df4:	ff 75 0c             	pushl  0xc(%ebp)
  801df7:	e8 e2 ea ff ff       	call   8008de <strcpy>
	return 0;
}
  801dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	57                   	push   %edi
  801e07:	56                   	push   %esi
  801e08:	53                   	push   %ebx
  801e09:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e14:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e1a:	eb 2d                	jmp    801e49 <devcons_write+0x46>
		m = n - tot;
  801e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e1f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e21:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e24:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e29:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e2c:	83 ec 04             	sub    $0x4,%esp
  801e2f:	53                   	push   %ebx
  801e30:	03 45 0c             	add    0xc(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	57                   	push   %edi
  801e35:	e8 36 ec ff ff       	call   800a70 <memmove>
		sys_cputs(buf, m);
  801e3a:	83 c4 08             	add    $0x8,%esp
  801e3d:	53                   	push   %ebx
  801e3e:	57                   	push   %edi
  801e3f:	e8 e1 ed ff ff       	call   800c25 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e44:	01 de                	add    %ebx,%esi
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	89 f0                	mov    %esi,%eax
  801e4b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e4e:	72 cc                	jb     801e1c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5f                   	pop    %edi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e63:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e67:	74 2a                	je     801e93 <devcons_read+0x3b>
  801e69:	eb 05                	jmp    801e70 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e6b:	e8 52 ee ff ff       	call   800cc2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e70:	e8 ce ed ff ff       	call   800c43 <sys_cgetc>
  801e75:	85 c0                	test   %eax,%eax
  801e77:	74 f2                	je     801e6b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	78 16                	js     801e93 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e7d:	83 f8 04             	cmp    $0x4,%eax
  801e80:	74 0c                	je     801e8e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e85:	88 02                	mov    %al,(%edx)
	return 1;
  801e87:	b8 01 00 00 00       	mov    $0x1,%eax
  801e8c:	eb 05                	jmp    801e93 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e93:	c9                   	leave  
  801e94:	c3                   	ret    

00801e95 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ea1:	6a 01                	push   $0x1
  801ea3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea6:	50                   	push   %eax
  801ea7:	e8 79 ed ff ff       	call   800c25 <sys_cputs>
}
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <getchar>:

int
getchar(void)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eb7:	6a 01                	push   $0x1
  801eb9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ebc:	50                   	push   %eax
  801ebd:	6a 00                	push   $0x0
  801ebf:	e8 97 f6 ff ff       	call   80155b <read>
	if (r < 0)
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 0f                	js     801eda <getchar+0x29>
		return r;
	if (r < 1)
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	7e 06                	jle    801ed5 <getchar+0x24>
		return -E_EOF;
	return c;
  801ecf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ed3:	eb 05                	jmp    801eda <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ed5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    

00801edc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ee2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee5:	50                   	push   %eax
  801ee6:	ff 75 08             	pushl  0x8(%ebp)
  801ee9:	e8 07 f4 ff ff       	call   8012f5 <fd_lookup>
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 11                	js     801f06 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801efe:	39 10                	cmp    %edx,(%eax)
  801f00:	0f 94 c0             	sete   %al
  801f03:	0f b6 c0             	movzbl %al,%eax
}
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <opencons>:

int
opencons(void)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f11:	50                   	push   %eax
  801f12:	e8 8f f3 ff ff       	call   8012a6 <fd_alloc>
  801f17:	83 c4 10             	add    $0x10,%esp
		return r;
  801f1a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	78 3e                	js     801f5e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f20:	83 ec 04             	sub    $0x4,%esp
  801f23:	68 07 04 00 00       	push   $0x407
  801f28:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2b:	6a 00                	push   $0x0
  801f2d:	e8 af ed ff ff       	call   800ce1 <sys_page_alloc>
  801f32:	83 c4 10             	add    $0x10,%esp
		return r;
  801f35:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 23                	js     801f5e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f3b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f44:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f49:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f50:	83 ec 0c             	sub    $0xc,%esp
  801f53:	50                   	push   %eax
  801f54:	e8 26 f3 ff ff       	call   80127f <fd2num>
  801f59:	89 c2                	mov    %eax,%edx
  801f5b:	83 c4 10             	add    $0x10,%esp
}
  801f5e:	89 d0                	mov    %edx,%eax
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    

00801f62 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801f68:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f6f:	75 4c                	jne    801fbd <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801f71:	a1 04 40 80 00       	mov    0x804004,%eax
  801f76:	8b 40 48             	mov    0x48(%eax),%eax
  801f79:	83 ec 04             	sub    $0x4,%esp
  801f7c:	6a 07                	push   $0x7
  801f7e:	68 00 f0 bf ee       	push   $0xeebff000
  801f83:	50                   	push   %eax
  801f84:	e8 58 ed ff ff       	call   800ce1 <sys_page_alloc>
		if(retv != 0){
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	74 14                	je     801fa4 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801f90:	83 ec 04             	sub    $0x4,%esp
  801f93:	68 30 2a 80 00       	push   $0x802a30
  801f98:	6a 27                	push   $0x27
  801f9a:	68 5c 2a 80 00       	push   $0x802a5c
  801f9f:	e8 92 e2 ff ff       	call   800236 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801fa4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa9:	8b 40 48             	mov    0x48(%eax),%eax
  801fac:	83 ec 08             	sub    $0x8,%esp
  801faf:	68 c7 1f 80 00       	push   $0x801fc7
  801fb4:	50                   	push   %eax
  801fb5:	e8 72 ee ff ff       	call   800e2c <sys_env_set_pgfault_upcall>
  801fba:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc0:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801fc5:	c9                   	leave  
  801fc6:	c3                   	ret    

00801fc7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fc7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fc8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fcd:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  801fcf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  801fd2:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  801fd6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  801fdb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  801fdf:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  801fe1:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  801fe4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  801fe5:	83 c4 04             	add    $0x4,%esp
	popfl
  801fe8:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fe9:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fea:	c3                   	ret    

00801feb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	56                   	push   %esi
  801fef:	53                   	push   %ebx
  801ff0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ff3:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801ff6:	83 ec 0c             	sub    $0xc,%esp
  801ff9:	ff 75 0c             	pushl  0xc(%ebp)
  801ffc:	e8 90 ee ff ff       	call   800e91 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  802001:	83 c4 10             	add    $0x10,%esp
  802004:	85 f6                	test   %esi,%esi
  802006:	74 1c                	je     802024 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  802008:	a1 04 40 80 00       	mov    0x804004,%eax
  80200d:	8b 40 78             	mov    0x78(%eax),%eax
  802010:	89 06                	mov    %eax,(%esi)
  802012:	eb 10                	jmp    802024 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802014:	83 ec 0c             	sub    $0xc,%esp
  802017:	68 6a 2a 80 00       	push   $0x802a6a
  80201c:	e8 ee e2 ff ff       	call   80030f <cprintf>
  802021:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802024:	a1 04 40 80 00       	mov    0x804004,%eax
  802029:	8b 50 74             	mov    0x74(%eax),%edx
  80202c:	85 d2                	test   %edx,%edx
  80202e:	74 e4                	je     802014 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  802030:	85 db                	test   %ebx,%ebx
  802032:	74 05                	je     802039 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802034:	8b 40 74             	mov    0x74(%eax),%eax
  802037:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802039:	a1 04 40 80 00       	mov    0x804004,%eax
  80203e:	8b 40 70             	mov    0x70(%eax),%eax

}
  802041:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    

00802048 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	57                   	push   %edi
  80204c:	56                   	push   %esi
  80204d:	53                   	push   %ebx
  80204e:	83 ec 0c             	sub    $0xc,%esp
  802051:	8b 7d 08             	mov    0x8(%ebp),%edi
  802054:	8b 75 0c             	mov    0xc(%ebp),%esi
  802057:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  80205a:	85 db                	test   %ebx,%ebx
  80205c:	75 13                	jne    802071 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  80205e:	6a 00                	push   $0x0
  802060:	68 00 00 c0 ee       	push   $0xeec00000
  802065:	56                   	push   %esi
  802066:	57                   	push   %edi
  802067:	e8 02 ee ff ff       	call   800e6e <sys_ipc_try_send>
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	eb 0e                	jmp    80207f <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  802071:	ff 75 14             	pushl  0x14(%ebp)
  802074:	53                   	push   %ebx
  802075:	56                   	push   %esi
  802076:	57                   	push   %edi
  802077:	e8 f2 ed ff ff       	call   800e6e <sys_ipc_try_send>
  80207c:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  80207f:	85 c0                	test   %eax,%eax
  802081:	75 d7                	jne    80205a <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  802083:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802086:	5b                   	pop    %ebx
  802087:	5e                   	pop    %esi
  802088:	5f                   	pop    %edi
  802089:	5d                   	pop    %ebp
  80208a:	c3                   	ret    

0080208b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802091:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802096:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802099:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80209f:	8b 52 50             	mov    0x50(%edx),%edx
  8020a2:	39 ca                	cmp    %ecx,%edx
  8020a4:	75 0d                	jne    8020b3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020ae:	8b 40 48             	mov    0x48(%eax),%eax
  8020b1:	eb 0f                	jmp    8020c2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020b3:	83 c0 01             	add    $0x1,%eax
  8020b6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020bb:	75 d9                	jne    802096 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    

008020c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ca:	89 d0                	mov    %edx,%eax
  8020cc:	c1 e8 16             	shr    $0x16,%eax
  8020cf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020db:	f6 c1 01             	test   $0x1,%cl
  8020de:	74 1d                	je     8020fd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e0:	c1 ea 0c             	shr    $0xc,%edx
  8020e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ea:	f6 c2 01             	test   $0x1,%dl
  8020ed:	74 0e                	je     8020fd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ef:	c1 ea 0c             	shr    $0xc,%edx
  8020f2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020f9:	ef 
  8020fa:	0f b7 c0             	movzwl %ax,%eax
}
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    
  8020ff:	90                   	nop

00802100 <__udivdi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80210b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80210f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 f6                	test   %esi,%esi
  802119:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80211d:	89 ca                	mov    %ecx,%edx
  80211f:	89 f8                	mov    %edi,%eax
  802121:	75 3d                	jne    802160 <__udivdi3+0x60>
  802123:	39 cf                	cmp    %ecx,%edi
  802125:	0f 87 c5 00 00 00    	ja     8021f0 <__udivdi3+0xf0>
  80212b:	85 ff                	test   %edi,%edi
  80212d:	89 fd                	mov    %edi,%ebp
  80212f:	75 0b                	jne    80213c <__udivdi3+0x3c>
  802131:	b8 01 00 00 00       	mov    $0x1,%eax
  802136:	31 d2                	xor    %edx,%edx
  802138:	f7 f7                	div    %edi
  80213a:	89 c5                	mov    %eax,%ebp
  80213c:	89 c8                	mov    %ecx,%eax
  80213e:	31 d2                	xor    %edx,%edx
  802140:	f7 f5                	div    %ebp
  802142:	89 c1                	mov    %eax,%ecx
  802144:	89 d8                	mov    %ebx,%eax
  802146:	89 cf                	mov    %ecx,%edi
  802148:	f7 f5                	div    %ebp
  80214a:	89 c3                	mov    %eax,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	39 ce                	cmp    %ecx,%esi
  802162:	77 74                	ja     8021d8 <__udivdi3+0xd8>
  802164:	0f bd fe             	bsr    %esi,%edi
  802167:	83 f7 1f             	xor    $0x1f,%edi
  80216a:	0f 84 98 00 00 00    	je     802208 <__udivdi3+0x108>
  802170:	bb 20 00 00 00       	mov    $0x20,%ebx
  802175:	89 f9                	mov    %edi,%ecx
  802177:	89 c5                	mov    %eax,%ebp
  802179:	29 fb                	sub    %edi,%ebx
  80217b:	d3 e6                	shl    %cl,%esi
  80217d:	89 d9                	mov    %ebx,%ecx
  80217f:	d3 ed                	shr    %cl,%ebp
  802181:	89 f9                	mov    %edi,%ecx
  802183:	d3 e0                	shl    %cl,%eax
  802185:	09 ee                	or     %ebp,%esi
  802187:	89 d9                	mov    %ebx,%ecx
  802189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218d:	89 d5                	mov    %edx,%ebp
  80218f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802193:	d3 ed                	shr    %cl,%ebp
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e2                	shl    %cl,%edx
  802199:	89 d9                	mov    %ebx,%ecx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	09 c2                	or     %eax,%edx
  80219f:	89 d0                	mov    %edx,%eax
  8021a1:	89 ea                	mov    %ebp,%edx
  8021a3:	f7 f6                	div    %esi
  8021a5:	89 d5                	mov    %edx,%ebp
  8021a7:	89 c3                	mov    %eax,%ebx
  8021a9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	72 10                	jb     8021c1 <__udivdi3+0xc1>
  8021b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e6                	shl    %cl,%esi
  8021b9:	39 c6                	cmp    %eax,%esi
  8021bb:	73 07                	jae    8021c4 <__udivdi3+0xc4>
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	75 03                	jne    8021c4 <__udivdi3+0xc4>
  8021c1:	83 eb 01             	sub    $0x1,%ebx
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 d8                	mov    %ebx,%eax
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	31 ff                	xor    %edi,%edi
  8021da:	31 db                	xor    %ebx,%ebx
  8021dc:	89 d8                	mov    %ebx,%eax
  8021de:	89 fa                	mov    %edi,%edx
  8021e0:	83 c4 1c             	add    $0x1c,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5f                   	pop    %edi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	90                   	nop
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 d8                	mov    %ebx,%eax
  8021f2:	f7 f7                	div    %edi
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 c3                	mov    %eax,%ebx
  8021f8:	89 d8                	mov    %ebx,%eax
  8021fa:	89 fa                	mov    %edi,%edx
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	5b                   	pop    %ebx
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	39 ce                	cmp    %ecx,%esi
  80220a:	72 0c                	jb     802218 <__udivdi3+0x118>
  80220c:	31 db                	xor    %ebx,%ebx
  80220e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802212:	0f 87 34 ff ff ff    	ja     80214c <__udivdi3+0x4c>
  802218:	bb 01 00 00 00       	mov    $0x1,%ebx
  80221d:	e9 2a ff ff ff       	jmp    80214c <__udivdi3+0x4c>
  802222:	66 90                	xchg   %ax,%ax
  802224:	66 90                	xchg   %ax,%ax
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80223b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80223f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802247:	85 d2                	test   %edx,%edx
  802249:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f3                	mov    %esi,%ebx
  802253:	89 3c 24             	mov    %edi,(%esp)
  802256:	89 74 24 04          	mov    %esi,0x4(%esp)
  80225a:	75 1c                	jne    802278 <__umoddi3+0x48>
  80225c:	39 f7                	cmp    %esi,%edi
  80225e:	76 50                	jbe    8022b0 <__umoddi3+0x80>
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	f7 f7                	div    %edi
  802266:	89 d0                	mov    %edx,%eax
  802268:	31 d2                	xor    %edx,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	39 f2                	cmp    %esi,%edx
  80227a:	89 d0                	mov    %edx,%eax
  80227c:	77 52                	ja     8022d0 <__umoddi3+0xa0>
  80227e:	0f bd ea             	bsr    %edx,%ebp
  802281:	83 f5 1f             	xor    $0x1f,%ebp
  802284:	75 5a                	jne    8022e0 <__umoddi3+0xb0>
  802286:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80228a:	0f 82 e0 00 00 00    	jb     802370 <__umoddi3+0x140>
  802290:	39 0c 24             	cmp    %ecx,(%esp)
  802293:	0f 86 d7 00 00 00    	jbe    802370 <__umoddi3+0x140>
  802299:	8b 44 24 08          	mov    0x8(%esp),%eax
  80229d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022a1:	83 c4 1c             	add    $0x1c,%esp
  8022a4:	5b                   	pop    %ebx
  8022a5:	5e                   	pop    %esi
  8022a6:	5f                   	pop    %edi
  8022a7:	5d                   	pop    %ebp
  8022a8:	c3                   	ret    
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	85 ff                	test   %edi,%edi
  8022b2:	89 fd                	mov    %edi,%ebp
  8022b4:	75 0b                	jne    8022c1 <__umoddi3+0x91>
  8022b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	f7 f7                	div    %edi
  8022bf:	89 c5                	mov    %eax,%ebp
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f5                	div    %ebp
  8022c7:	89 c8                	mov    %ecx,%eax
  8022c9:	f7 f5                	div    %ebp
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	eb 99                	jmp    802268 <__umoddi3+0x38>
  8022cf:	90                   	nop
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	83 c4 1c             	add    $0x1c,%esp
  8022d7:	5b                   	pop    %ebx
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	8b 34 24             	mov    (%esp),%esi
  8022e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022e8:	89 e9                	mov    %ebp,%ecx
  8022ea:	29 ef                	sub    %ebp,%edi
  8022ec:	d3 e0                	shl    %cl,%eax
  8022ee:	89 f9                	mov    %edi,%ecx
  8022f0:	89 f2                	mov    %esi,%edx
  8022f2:	d3 ea                	shr    %cl,%edx
  8022f4:	89 e9                	mov    %ebp,%ecx
  8022f6:	09 c2                	or     %eax,%edx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 14 24             	mov    %edx,(%esp)
  8022fd:	89 f2                	mov    %esi,%edx
  8022ff:	d3 e2                	shl    %cl,%edx
  802301:	89 f9                	mov    %edi,%ecx
  802303:	89 54 24 04          	mov    %edx,0x4(%esp)
  802307:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80230b:	d3 e8                	shr    %cl,%eax
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	89 c6                	mov    %eax,%esi
  802311:	d3 e3                	shl    %cl,%ebx
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 d0                	mov    %edx,%eax
  802317:	d3 e8                	shr    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	09 d8                	or     %ebx,%eax
  80231d:	89 d3                	mov    %edx,%ebx
  80231f:	89 f2                	mov    %esi,%edx
  802321:	f7 34 24             	divl   (%esp)
  802324:	89 d6                	mov    %edx,%esi
  802326:	d3 e3                	shl    %cl,%ebx
  802328:	f7 64 24 04          	mull   0x4(%esp)
  80232c:	39 d6                	cmp    %edx,%esi
  80232e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802332:	89 d1                	mov    %edx,%ecx
  802334:	89 c3                	mov    %eax,%ebx
  802336:	72 08                	jb     802340 <__umoddi3+0x110>
  802338:	75 11                	jne    80234b <__umoddi3+0x11b>
  80233a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80233e:	73 0b                	jae    80234b <__umoddi3+0x11b>
  802340:	2b 44 24 04          	sub    0x4(%esp),%eax
  802344:	1b 14 24             	sbb    (%esp),%edx
  802347:	89 d1                	mov    %edx,%ecx
  802349:	89 c3                	mov    %eax,%ebx
  80234b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80234f:	29 da                	sub    %ebx,%edx
  802351:	19 ce                	sbb    %ecx,%esi
  802353:	89 f9                	mov    %edi,%ecx
  802355:	89 f0                	mov    %esi,%eax
  802357:	d3 e0                	shl    %cl,%eax
  802359:	89 e9                	mov    %ebp,%ecx
  80235b:	d3 ea                	shr    %cl,%edx
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	d3 ee                	shr    %cl,%esi
  802361:	09 d0                	or     %edx,%eax
  802363:	89 f2                	mov    %esi,%edx
  802365:	83 c4 1c             	add    $0x1c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	29 f9                	sub    %edi,%ecx
  802372:	19 d6                	sbb    %edx,%esi
  802374:	89 74 24 04          	mov    %esi,0x4(%esp)
  802378:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80237c:	e9 18 ff ff ff       	jmp    802299 <__umoddi3+0x69>
