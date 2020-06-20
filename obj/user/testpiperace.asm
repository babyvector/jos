
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 a0 23 80 00       	push   $0x8023a0
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 2b 1d 00 00       	call   801d7b <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 b9 23 80 00       	push   $0x8023b9
  80005d:	6a 0d                	push   $0xd
  80005f:	68 c2 23 80 00       	push   $0x8023c2
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 2a 10 00 00       	call   801098 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 d6 23 80 00       	push   $0x8023d6
  80007a:	6a 10                	push   $0x10
  80007c:	68 c2 23 80 00       	push   $0x8023c2
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 71 14 00 00       	call   801506 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 26 1e 00 00       	call   801ece <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 df 23 80 00       	push   $0x8023df
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 07 0c 00 00       	call   800cd0 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 b1 11 00 00       	call   80128d <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 fa 23 80 00       	push   $0x8023fa
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 05 24 80 00       	push   $0x802405
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 3c 14 00 00       	call   801556 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 21 14 00 00       	call   801556 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 10 24 80 00       	push   $0x802410
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 76 1d 00 00       	call   801ece <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 6c 24 80 00       	push   $0x80246c
  800167:	6a 3a                	push   $0x3a
  800169:	68 c2 23 80 00       	push   $0x8023c2
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 5a 12 00 00       	call   8013dc <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 26 24 80 00       	push   $0x802426
  80018f:	6a 3c                	push   $0x3c
  800191:	68 c2 23 80 00       	push   $0x8023c2
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 d0 11 00 00       	call   801376 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 bc 19 00 00       	call   801b6a <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 3e 24 80 00       	push   $0x80243e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 54 24 80 00       	push   $0x802454
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 bd 0a 00 00       	call   800cb1 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 fc 12 00 00       	call   801531 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 31 0a 00 00       	call   800c70 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 5a 0a 00 00       	call   800cb1 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 a0 24 80 00       	push   $0x8024a0
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 b7 23 80 00 	movl   $0x8023b7,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 79 09 00 00       	call   800c33 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 1e 09 00 00       	call   800c33 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 8b 1d 00 00       	call   802110 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 78 1e 00 00       	call   802240 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 c3 24 80 00 	movsbl 0x8024c3(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 d3 03 00 00    	je     800843 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 07                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 47 01             	lea    0x1(%edi),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 07             	movzbl (%edi),%eax
  8004b6:	0f b6 c8             	movzbl %al,%ecx
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 64 03 00 00    	ja     800828 <vprintfmt+0x3d4>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb d6                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 39                	ja     80052d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb e9                	jmp    8004e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050a:	eb 27                	jmp    800533 <vprintfmt+0xdf>
  80050c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	b9 00 00 00 00       	mov    $0x0,%ecx
  800516:	0f 49 c8             	cmovns %eax,%ecx
  800519:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051f:	eb 8c                	jmp    8004ad <vprintfmt+0x59>
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800524:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052b:	eb 80                	jmp    8004ad <vprintfmt+0x59>
  80052d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800530:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	0f 89 70 ff ff ff    	jns    8004ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80053d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800543:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80054a:	e9 5e ff ff ff       	jmp    8004ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800555:	e9 53 ff ff ff       	jmp    8004ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 30                	pushl  (%eax)
  800569:	ff d6                	call   *%esi
			break;
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800571:	e9 04 ff ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	99                   	cltd   
  800582:	31 d0                	xor    %edx,%eax
  800584:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800586:	83 f8 0f             	cmp    $0xf,%eax
  800589:	7f 0b                	jg     800596 <vprintfmt+0x142>
  80058b:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 db 24 80 00       	push   $0x8024db
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 94 fe ff ff       	call   800437 <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a9:	e9 cc fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ae:	52                   	push   %edx
  8005af:	68 19 2a 80 00       	push   $0x802a19
  8005b4:	53                   	push   %ebx
  8005b5:	56                   	push   %esi
  8005b6:	e8 7c fe ff ff       	call   800437 <printfmt>
  8005bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	e9 b4 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	b8 d4 24 80 00       	mov    $0x8024d4,%eax
  8005d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005df:	0f 8e 94 00 00 00    	jle    800679 <vprintfmt+0x225>
  8005e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e9:	0f 84 98 00 00 00    	je     800687 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 c8             	pushl  -0x38(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	e8 d0 02 00 00       	call   8008cb <strnlen>
  8005fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fe:	29 c1                	sub    %eax,%ecx
  800600:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800606:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800610:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	85 ff                	test   %edi,%edi
  800625:	7f ed                	jg     800614 <vprintfmt+0x1c0>
  800627:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	0f 49 c1             	cmovns %ecx,%eax
  800637:	29 c1                	sub    %eax,%ecx
  800639:	89 75 08             	mov    %esi,0x8(%ebp)
  80063c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80063f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800642:	89 cb                	mov    %ecx,%ebx
  800644:	eb 4d                	jmp    800693 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064a:	74 1b                	je     800667 <vprintfmt+0x213>
  80064c:	0f be c0             	movsbl %al,%eax
  80064f:	83 e8 20             	sub    $0x20,%eax
  800652:	83 f8 5e             	cmp    $0x5e,%eax
  800655:	76 10                	jbe    800667 <vprintfmt+0x213>
					putch('?', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	6a 3f                	push   $0x3f
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	52                   	push   %edx
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 1a                	jmp    800693 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	eb 0c                	jmp    800693 <vprintfmt+0x23f>
  800687:	89 75 08             	mov    %esi,0x8(%ebp)
  80068a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80068d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800690:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800693:	83 c7 01             	add    $0x1,%edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	0f be d0             	movsbl %al,%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	74 23                	je     8006c4 <vprintfmt+0x270>
  8006a1:	85 f6                	test   %esi,%esi
  8006a3:	78 a1                	js     800646 <vprintfmt+0x1f2>
  8006a5:	83 ee 01             	sub    $0x1,%esi
  8006a8:	79 9c                	jns    800646 <vprintfmt+0x1f2>
  8006aa:	89 df                	mov    %ebx,%edi
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b2:	eb 18                	jmp    8006cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 20                	push   $0x20
  8006ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 08                	jmp    8006cc <vprintfmt+0x278>
  8006c4:	89 df                	mov    %ebx,%edi
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7f e4                	jg     8006b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d3:	e9 a2 fd ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 16                	jle    8006f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 08             	lea    0x8(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 50 04             	mov    0x4(%eax),%edx
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006ee:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006f1:	eb 32                	jmp    800725 <vprintfmt+0x2d1>
	else if (lflag)
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	74 18                	je     80070f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80070d:	eb 16                	jmp    800725 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800728:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80072b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800731:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800736:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80073a:	0f 89 b0 00 00 00    	jns    8007f0 <vprintfmt+0x39c>
				putch('-', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 2d                	push   $0x2d
  800746:	ff d6                	call   *%esi
				num = -(long long) num;
  800748:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80074b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80074e:	f7 d8                	neg    %eax
  800750:	83 d2 00             	adc    $0x0,%edx
  800753:	f7 da                	neg    %edx
  800755:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800758:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80075b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80075e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800763:	e9 88 00 00 00       	jmp    8007f0 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
  80076b:	e8 70 fc ff ff       	call   8003e0 <getuint>
  800770:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800773:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800776:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80077b:	eb 73                	jmp    8007f0 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80077d:	8d 45 14             	lea    0x14(%ebp),%eax
  800780:	e8 5b fc ff ff       	call   8003e0 <getuint>
  800785:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800788:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	6a 58                	push   $0x58
  800791:	ff d6                	call   *%esi
			putch('X', putdat);
  800793:	83 c4 08             	add    $0x8,%esp
  800796:	53                   	push   %ebx
  800797:	6a 58                	push   $0x58
  800799:	ff d6                	call   *%esi
			putch('X', putdat);
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	53                   	push   %ebx
  80079f:	6a 58                	push   $0x58
  8007a1:	ff d6                	call   *%esi
			goto number;
  8007a3:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8007a6:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8007ab:	eb 43                	jmp    8007f0 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	6a 30                	push   $0x30
  8007b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b5:	83 c4 08             	add    $0x8,%esp
  8007b8:	53                   	push   %ebx
  8007b9:	6a 78                	push   $0x78
  8007bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 04             	lea    0x4(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c6:	8b 00                	mov    (%eax),%eax
  8007c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007d3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007db:	eb 13                	jmp    8007f0 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e0:	e8 fb fb ff ff       	call   8003e0 <getuint>
  8007e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8007eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f0:	83 ec 0c             	sub    $0xc,%esp
  8007f3:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8007f7:	52                   	push   %edx
  8007f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007fb:	50                   	push   %eax
  8007fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8007ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800802:	89 da                	mov    %ebx,%edx
  800804:	89 f0                	mov    %esi,%eax
  800806:	e8 26 fb ff ff       	call   800331 <printnum>
			break;
  80080b:	83 c4 20             	add    $0x20,%esp
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800811:	e9 64 fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	53                   	push   %ebx
  80081a:	51                   	push   %ecx
  80081b:	ff d6                	call   *%esi
			break;
  80081d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800820:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800823:	e9 52 fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	53                   	push   %ebx
  80082c:	6a 25                	push   $0x25
  80082e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	eb 03                	jmp    800838 <vprintfmt+0x3e4>
  800835:	83 ef 01             	sub    $0x1,%edi
  800838:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80083c:	75 f7                	jne    800835 <vprintfmt+0x3e1>
  80083e:	e9 37 fc ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800843:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5f                   	pop    %edi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 18             	sub    $0x18,%esp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800857:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800861:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800868:	85 c0                	test   %eax,%eax
  80086a:	74 26                	je     800892 <vsnprintf+0x47>
  80086c:	85 d2                	test   %edx,%edx
  80086e:	7e 22                	jle    800892 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800870:	ff 75 14             	pushl  0x14(%ebp)
  800873:	ff 75 10             	pushl  0x10(%ebp)
  800876:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800879:	50                   	push   %eax
  80087a:	68 1a 04 80 00       	push   $0x80041a
  80087f:	e8 d0 fb ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800884:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800887:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	eb 05                	jmp    800897 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800892:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a2:	50                   	push   %eax
  8008a3:	ff 75 10             	pushl  0x10(%ebp)
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 9a ff ff ff       	call   80084b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008be:	eb 03                	jmp    8008c3 <strlen+0x10>
		n++;
  8008c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c7:	75 f7                	jne    8008c0 <strlen+0xd>
		n++;
	return n;
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d9:	eb 03                	jmp    8008de <strnlen+0x13>
		n++;
  8008db:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008de:	39 c2                	cmp    %eax,%edx
  8008e0:	74 08                	je     8008ea <strnlen+0x1f>
  8008e2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008e6:	75 f3                	jne    8008db <strnlen+0x10>
  8008e8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f6:	89 c2                	mov    %eax,%edx
  8008f8:	83 c2 01             	add    $0x1,%edx
  8008fb:	83 c1 01             	add    $0x1,%ecx
  8008fe:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800902:	88 5a ff             	mov    %bl,-0x1(%edx)
  800905:	84 db                	test   %bl,%bl
  800907:	75 ef                	jne    8008f8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800909:	5b                   	pop    %ebx
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800913:	53                   	push   %ebx
  800914:	e8 9a ff ff ff       	call   8008b3 <strlen>
  800919:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80091c:	ff 75 0c             	pushl  0xc(%ebp)
  80091f:	01 d8                	add    %ebx,%eax
  800921:	50                   	push   %eax
  800922:	e8 c5 ff ff ff       	call   8008ec <strcpy>
	return dst;
}
  800927:	89 d8                	mov    %ebx,%eax
  800929:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 75 08             	mov    0x8(%ebp),%esi
  800936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800939:	89 f3                	mov    %esi,%ebx
  80093b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093e:	89 f2                	mov    %esi,%edx
  800940:	eb 0f                	jmp    800951 <strncpy+0x23>
		*dst++ = *src;
  800942:	83 c2 01             	add    $0x1,%edx
  800945:	0f b6 01             	movzbl (%ecx),%eax
  800948:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094b:	80 39 01             	cmpb   $0x1,(%ecx)
  80094e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800951:	39 da                	cmp    %ebx,%edx
  800953:	75 ed                	jne    800942 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800955:	89 f0                	mov    %esi,%eax
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 75 08             	mov    0x8(%ebp),%esi
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800966:	8b 55 10             	mov    0x10(%ebp),%edx
  800969:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096b:	85 d2                	test   %edx,%edx
  80096d:	74 21                	je     800990 <strlcpy+0x35>
  80096f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800973:	89 f2                	mov    %esi,%edx
  800975:	eb 09                	jmp    800980 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800977:	83 c2 01             	add    $0x1,%edx
  80097a:	83 c1 01             	add    $0x1,%ecx
  80097d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800980:	39 c2                	cmp    %eax,%edx
  800982:	74 09                	je     80098d <strlcpy+0x32>
  800984:	0f b6 19             	movzbl (%ecx),%ebx
  800987:	84 db                	test   %bl,%bl
  800989:	75 ec                	jne    800977 <strlcpy+0x1c>
  80098b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80098d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800990:	29 f0                	sub    %esi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strcmp+0x11>
		p++, q++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	84 c0                	test   %al,%al
  8009ac:	74 04                	je     8009b2 <strcmp+0x1c>
  8009ae:	3a 02                	cmp    (%edx),%al
  8009b0:	74 ef                	je     8009a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b2:	0f b6 c0             	movzbl %al,%eax
  8009b5:	0f b6 12             	movzbl (%edx),%edx
  8009b8:	29 d0                	sub    %edx,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cb:	eb 06                	jmp    8009d3 <strncmp+0x17>
		n--, p++, q++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d3:	39 d8                	cmp    %ebx,%eax
  8009d5:	74 15                	je     8009ec <strncmp+0x30>
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	84 c9                	test   %cl,%cl
  8009dc:	74 04                	je     8009e2 <strncmp+0x26>
  8009de:	3a 0a                	cmp    (%edx),%cl
  8009e0:	74 eb                	je     8009cd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e2:	0f b6 00             	movzbl (%eax),%eax
  8009e5:	0f b6 12             	movzbl (%edx),%edx
  8009e8:	29 d0                	sub    %edx,%eax
  8009ea:	eb 05                	jmp    8009f1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f1:	5b                   	pop    %ebx
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fe:	eb 07                	jmp    800a07 <strchr+0x13>
		if (*s == c)
  800a00:	38 ca                	cmp    %cl,%dl
  800a02:	74 0f                	je     800a13 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a04:	83 c0 01             	add    $0x1,%eax
  800a07:	0f b6 10             	movzbl (%eax),%edx
  800a0a:	84 d2                	test   %dl,%dl
  800a0c:	75 f2                	jne    800a00 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1f:	eb 03                	jmp    800a24 <strfind+0xf>
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 04                	je     800a2f <strfind+0x1a>
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	75 f2                	jne    800a21 <strfind+0xc>
			break;
	return (char *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3d:	85 c9                	test   %ecx,%ecx
  800a3f:	74 36                	je     800a77 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a41:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a47:	75 28                	jne    800a71 <memset+0x40>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	75 23                	jne    800a71 <memset+0x40>
		c &= 0xFF;
  800a4e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a52:	89 d3                	mov    %edx,%ebx
  800a54:	c1 e3 08             	shl    $0x8,%ebx
  800a57:	89 d6                	mov    %edx,%esi
  800a59:	c1 e6 18             	shl    $0x18,%esi
  800a5c:	89 d0                	mov    %edx,%eax
  800a5e:	c1 e0 10             	shl    $0x10,%eax
  800a61:	09 f0                	or     %esi,%eax
  800a63:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a65:	89 d8                	mov    %ebx,%eax
  800a67:	09 d0                	or     %edx,%eax
  800a69:	c1 e9 02             	shr    $0x2,%ecx
  800a6c:	fc                   	cld    
  800a6d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6f:	eb 06                	jmp    800a77 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	fc                   	cld    
  800a75:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a77:	89 f8                	mov    %edi,%eax
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8c:	39 c6                	cmp    %eax,%esi
  800a8e:	73 35                	jae    800ac5 <memmove+0x47>
  800a90:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a93:	39 d0                	cmp    %edx,%eax
  800a95:	73 2e                	jae    800ac5 <memmove+0x47>
		s += n;
		d += n;
  800a97:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	09 fe                	or     %edi,%esi
  800a9e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa4:	75 13                	jne    800ab9 <memmove+0x3b>
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 0e                	jne    800ab9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aab:	83 ef 04             	sub    $0x4,%edi
  800aae:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab1:	c1 e9 02             	shr    $0x2,%ecx
  800ab4:	fd                   	std    
  800ab5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab7:	eb 09                	jmp    800ac2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab9:	83 ef 01             	sub    $0x1,%edi
  800abc:	8d 72 ff             	lea    -0x1(%edx),%esi
  800abf:	fd                   	std    
  800ac0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac2:	fc                   	cld    
  800ac3:	eb 1d                	jmp    800ae2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac5:	89 f2                	mov    %esi,%edx
  800ac7:	09 c2                	or     %eax,%edx
  800ac9:	f6 c2 03             	test   $0x3,%dl
  800acc:	75 0f                	jne    800add <memmove+0x5f>
  800ace:	f6 c1 03             	test   $0x3,%cl
  800ad1:	75 0a                	jne    800add <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ad3:	c1 e9 02             	shr    $0x2,%ecx
  800ad6:	89 c7                	mov    %eax,%edi
  800ad8:	fc                   	cld    
  800ad9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800adb:	eb 05                	jmp    800ae2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800add:	89 c7                	mov    %eax,%edi
  800adf:	fc                   	cld    
  800ae0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae9:	ff 75 10             	pushl  0x10(%ebp)
  800aec:	ff 75 0c             	pushl  0xc(%ebp)
  800aef:	ff 75 08             	pushl  0x8(%ebp)
  800af2:	e8 87 ff ff ff       	call   800a7e <memmove>
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b04:	89 c6                	mov    %eax,%esi
  800b06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b09:	eb 1a                	jmp    800b25 <memcmp+0x2c>
		if (*s1 != *s2)
  800b0b:	0f b6 08             	movzbl (%eax),%ecx
  800b0e:	0f b6 1a             	movzbl (%edx),%ebx
  800b11:	38 d9                	cmp    %bl,%cl
  800b13:	74 0a                	je     800b1f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b15:	0f b6 c1             	movzbl %cl,%eax
  800b18:	0f b6 db             	movzbl %bl,%ebx
  800b1b:	29 d8                	sub    %ebx,%eax
  800b1d:	eb 0f                	jmp    800b2e <memcmp+0x35>
		s1++, s2++;
  800b1f:	83 c0 01             	add    $0x1,%eax
  800b22:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b25:	39 f0                	cmp    %esi,%eax
  800b27:	75 e2                	jne    800b0b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	53                   	push   %ebx
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b39:	89 c1                	mov    %eax,%ecx
  800b3b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b42:	eb 0a                	jmp    800b4e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	0f b6 10             	movzbl (%eax),%edx
  800b47:	39 da                	cmp    %ebx,%edx
  800b49:	74 07                	je     800b52 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4b:	83 c0 01             	add    $0x1,%eax
  800b4e:	39 c8                	cmp    %ecx,%eax
  800b50:	72 f2                	jb     800b44 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b52:	5b                   	pop    %ebx
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b61:	eb 03                	jmp    800b66 <strtol+0x11>
		s++;
  800b63:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b66:	0f b6 01             	movzbl (%ecx),%eax
  800b69:	3c 20                	cmp    $0x20,%al
  800b6b:	74 f6                	je     800b63 <strtol+0xe>
  800b6d:	3c 09                	cmp    $0x9,%al
  800b6f:	74 f2                	je     800b63 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b71:	3c 2b                	cmp    $0x2b,%al
  800b73:	75 0a                	jne    800b7f <strtol+0x2a>
		s++;
  800b75:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b78:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7d:	eb 11                	jmp    800b90 <strtol+0x3b>
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b84:	3c 2d                	cmp    $0x2d,%al
  800b86:	75 08                	jne    800b90 <strtol+0x3b>
		s++, neg = 1;
  800b88:	83 c1 01             	add    $0x1,%ecx
  800b8b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b90:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b96:	75 15                	jne    800bad <strtol+0x58>
  800b98:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9b:	75 10                	jne    800bad <strtol+0x58>
  800b9d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba1:	75 7c                	jne    800c1f <strtol+0xca>
		s += 2, base = 16;
  800ba3:	83 c1 02             	add    $0x2,%ecx
  800ba6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bab:	eb 16                	jmp    800bc3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bad:	85 db                	test   %ebx,%ebx
  800baf:	75 12                	jne    800bc3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb9:	75 08                	jne    800bc3 <strtol+0x6e>
		s++, base = 8;
  800bbb:	83 c1 01             	add    $0x1,%ecx
  800bbe:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bcb:	0f b6 11             	movzbl (%ecx),%edx
  800bce:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd1:	89 f3                	mov    %esi,%ebx
  800bd3:	80 fb 09             	cmp    $0x9,%bl
  800bd6:	77 08                	ja     800be0 <strtol+0x8b>
			dig = *s - '0';
  800bd8:	0f be d2             	movsbl %dl,%edx
  800bdb:	83 ea 30             	sub    $0x30,%edx
  800bde:	eb 22                	jmp    800c02 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be3:	89 f3                	mov    %esi,%ebx
  800be5:	80 fb 19             	cmp    $0x19,%bl
  800be8:	77 08                	ja     800bf2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bea:	0f be d2             	movsbl %dl,%edx
  800bed:	83 ea 57             	sub    $0x57,%edx
  800bf0:	eb 10                	jmp    800c02 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bf2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf5:	89 f3                	mov    %esi,%ebx
  800bf7:	80 fb 19             	cmp    $0x19,%bl
  800bfa:	77 16                	ja     800c12 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bfc:	0f be d2             	movsbl %dl,%edx
  800bff:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c02:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c05:	7d 0b                	jge    800c12 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c07:	83 c1 01             	add    $0x1,%ecx
  800c0a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c0e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c10:	eb b9                	jmp    800bcb <strtol+0x76>

	if (endptr)
  800c12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c16:	74 0d                	je     800c25 <strtol+0xd0>
		*endptr = (char *) s;
  800c18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1b:	89 0e                	mov    %ecx,(%esi)
  800c1d:	eb 06                	jmp    800c25 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c1f:	85 db                	test   %ebx,%ebx
  800c21:	74 98                	je     800bbb <strtol+0x66>
  800c23:	eb 9e                	jmp    800bc3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c25:	89 c2                	mov    %eax,%edx
  800c27:	f7 da                	neg    %edx
  800c29:	85 ff                	test   %edi,%edi
  800c2b:	0f 45 c2             	cmovne %edx,%eax
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 c3                	mov    %eax,%ebx
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	89 c6                	mov    %eax,%esi
  800c4a:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c57:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c61:	89 d1                	mov    %edx,%ecx
  800c63:	89 d3                	mov    %edx,%ebx
  800c65:	89 d7                	mov    %edx,%edi
  800c67:	89 d6                	mov    %edx,%esi
  800c69:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 cb                	mov    %ecx,%ebx
  800c88:	89 cf                	mov    %ecx,%edi
  800c8a:	89 ce                	mov    %ecx,%esi
  800c8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 17                	jle    800ca9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	6a 03                	push   $0x3
  800c98:	68 bf 27 80 00       	push   $0x8027bf
  800c9d:	6a 23                	push   $0x23
  800c9f:	68 dc 27 80 00       	push   $0x8027dc
  800ca4:	e8 9b f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbc:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc1:	89 d1                	mov    %edx,%ecx
  800cc3:	89 d3                	mov    %edx,%ebx
  800cc5:	89 d7                	mov    %edx,%edi
  800cc7:	89 d6                	mov    %edx,%esi
  800cc9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_yield>:

void
sys_yield(void)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce0:	89 d1                	mov    %edx,%ecx
  800ce2:	89 d3                	mov    %edx,%ebx
  800ce4:	89 d7                	mov    %edx,%edi
  800ce6:	89 d6                	mov    %edx,%esi
  800ce8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cf8:	be 00 00 00 00       	mov    $0x0,%esi
  800cfd:	b8 04 00 00 00       	mov    $0x4,%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0b:	89 f7                	mov    %esi,%edi
  800d0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 04                	push   $0x4
  800d19:	68 bf 27 80 00       	push   $0x8027bf
  800d1e:	6a 23                	push   $0x23
  800d20:	68 dc 27 80 00       	push   $0x8027dc
  800d25:	e8 1a f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d3b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 17                	jle    800d6c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 05                	push   $0x5
  800d5b:	68 bf 27 80 00       	push   $0x8027bf
  800d60:	6a 23                	push   $0x23
  800d62:	68 dc 27 80 00       	push   $0x8027dc
  800d67:	e8 d8 f4 ff ff       	call   800244 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d82:	b8 06 00 00 00       	mov    $0x6,%eax
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8d:	89 df                	mov    %ebx,%edi
  800d8f:	89 de                	mov    %ebx,%esi
  800d91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 17                	jle    800dae <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 06                	push   $0x6
  800d9d:	68 bf 27 80 00       	push   $0x8027bf
  800da2:	6a 23                	push   $0x23
  800da4:	68 dc 27 80 00       	push   $0x8027dc
  800da9:	e8 96 f4 ff ff       	call   800244 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 17                	jle    800df0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 08                	push   $0x8
  800ddf:	68 bf 27 80 00       	push   $0x8027bf
  800de4:	6a 23                	push   $0x23
  800de6:	68 dc 27 80 00       	push   $0x8027dc
  800deb:	e8 54 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 17                	jle    800e32 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 09                	push   $0x9
  800e21:	68 bf 27 80 00       	push   $0x8027bf
  800e26:	6a 23                	push   $0x23
  800e28:	68 dc 27 80 00       	push   $0x8027dc
  800e2d:	e8 12 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7e 17                	jle    800e74 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	50                   	push   %eax
  800e61:	6a 0a                	push   $0xa
  800e63:	68 bf 27 80 00       	push   $0x8027bf
  800e68:	6a 23                	push   $0x23
  800e6a:	68 dc 27 80 00       	push   $0x8027dc
  800e6f:	e8 d0 f3 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e82:	be 00 00 00 00       	mov    $0x0,%esi
  800e87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e98:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ead:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	89 cb                	mov    %ecx,%ebx
  800eb7:	89 cf                	mov    %ecx,%edi
  800eb9:	89 ce                	mov    %ecx,%esi
  800ebb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	7e 17                	jle    800ed8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	50                   	push   %eax
  800ec5:	6a 0d                	push   $0xd
  800ec7:	68 bf 27 80 00       	push   $0x8027bf
  800ecc:	6a 23                	push   $0x23
  800ece:	68 dc 27 80 00       	push   $0x8027dc
  800ed3:	e8 6c f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ee8:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800eea:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eee:	74 11                	je     800f01 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	c1 e8 0c             	shr    $0xc,%eax
  800ef5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800efc:	f6 c4 08             	test   $0x8,%ah
  800eff:	75 14                	jne    800f15 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	68 ea 27 80 00       	push   $0x8027ea
  800f09:	6a 21                	push   $0x21
  800f0b:	68 00 28 80 00       	push   $0x802800
  800f10:	e8 2f f3 ff ff       	call   800244 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800f15:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f1b:	e8 91 fd ff ff       	call   800cb1 <sys_getenvid>
  800f20:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	6a 07                	push   $0x7
  800f27:	68 00 f0 7f 00       	push   $0x7ff000
  800f2c:	50                   	push   %eax
  800f2d:	e8 bd fd ff ff       	call   800cef <sys_page_alloc>
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	79 14                	jns    800f4d <pgfault+0x6d>
		panic("sys_page_alloc");
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	68 0b 28 80 00       	push   $0x80280b
  800f41:	6a 30                	push   $0x30
  800f43:	68 00 28 80 00       	push   $0x802800
  800f48:	e8 f7 f2 ff ff       	call   800244 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800f4d:	83 ec 04             	sub    $0x4,%esp
  800f50:	68 00 10 00 00       	push   $0x1000
  800f55:	53                   	push   %ebx
  800f56:	68 00 f0 7f 00       	push   $0x7ff000
  800f5b:	e8 86 fb ff ff       	call   800ae6 <memcpy>
	retv = sys_page_unmap(envid, addr);
  800f60:	83 c4 08             	add    $0x8,%esp
  800f63:	53                   	push   %ebx
  800f64:	56                   	push   %esi
  800f65:	e8 0a fe ff ff       	call   800d74 <sys_page_unmap>
	if(retv < 0){
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	79 12                	jns    800f83 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800f71:	50                   	push   %eax
  800f72:	68 f8 28 80 00       	push   $0x8028f8
  800f77:	6a 35                	push   $0x35
  800f79:	68 00 28 80 00       	push   $0x802800
  800f7e:	e8 c1 f2 ff ff       	call   800244 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	6a 07                	push   $0x7
  800f88:	53                   	push   %ebx
  800f89:	56                   	push   %esi
  800f8a:	68 00 f0 7f 00       	push   $0x7ff000
  800f8f:	56                   	push   %esi
  800f90:	e8 9d fd ff ff       	call   800d32 <sys_page_map>
	if(retv < 0){
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	79 14                	jns    800fb0 <pgfault+0xd0>
		panic("sys_page_map");
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	68 1a 28 80 00       	push   $0x80281a
  800fa4:	6a 39                	push   $0x39
  800fa6:	68 00 28 80 00       	push   $0x802800
  800fab:	e8 94 f2 ff ff       	call   800244 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	68 00 f0 7f 00       	push   $0x7ff000
  800fb8:	56                   	push   %esi
  800fb9:	e8 b6 fd ff ff       	call   800d74 <sys_page_unmap>
	if(retv < 0){
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	79 14                	jns    800fd9 <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	68 27 28 80 00       	push   $0x802827
  800fcd:	6a 3d                	push   $0x3d
  800fcf:	68 00 28 80 00       	push   $0x802800
  800fd4:	e8 6b f2 ff ff       	call   800244 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800fd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800fe8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800feb:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	53                   	push   %ebx
  800ff2:	68 44 28 80 00       	push   $0x802844
  800ff7:	e8 21 f3 ff ff       	call   80031d <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800ffc:	83 c4 0c             	add    $0xc,%esp
  800fff:	6a 07                	push   $0x7
  801001:	53                   	push   %ebx
  801002:	56                   	push   %esi
  801003:	e8 e7 fc ff ff       	call   800cef <sys_page_alloc>
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	79 15                	jns    801024 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  80100f:	50                   	push   %eax
  801010:	68 57 28 80 00       	push   $0x802857
  801015:	68 90 00 00 00       	push   $0x90
  80101a:	68 00 28 80 00       	push   $0x802800
  80101f:	e8 20 f2 ff ff       	call   800244 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	68 6a 28 80 00       	push   $0x80286a
  80102c:	e8 ec f2 ff ff       	call   80031d <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801031:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801038:	68 00 00 40 00       	push   $0x400000
  80103d:	6a 00                	push   $0x0
  80103f:	53                   	push   %ebx
  801040:	56                   	push   %esi
  801041:	e8 ec fc ff ff       	call   800d32 <sys_page_map>
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 15                	jns    801062 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  80104d:	50                   	push   %eax
  80104e:	68 72 28 80 00       	push   $0x802872
  801053:	68 94 00 00 00       	push   $0x94
  801058:	68 00 28 80 00       	push   $0x802800
  80105d:	e8 e2 f1 ff ff       	call   800244 <_panic>
        cprintf("af_p_m.");
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	68 83 28 80 00       	push   $0x802883
  80106a:	e8 ae f2 ff ff       	call   80031d <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  80106f:	83 c4 0c             	add    $0xc,%esp
  801072:	68 00 10 00 00       	push   $0x1000
  801077:	53                   	push   %ebx
  801078:	68 00 00 40 00       	push   $0x400000
  80107d:	e8 fc f9 ff ff       	call   800a7e <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  801082:	c7 04 24 8b 28 80 00 	movl   $0x80288b,(%esp)
  801089:	e8 8f f2 ff ff       	call   80031d <cprintf>
}
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
  80109e:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  8010a1:	68 e0 0e 80 00       	push   $0x800ee0
  8010a6:	e8 d9 0f 00 00       	call   802084 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010ab:	b8 07 00 00 00       	mov    $0x7,%eax
  8010b0:	cd 30                	int    $0x30
  8010b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	79 17                	jns    8010d6 <fork+0x3e>
		panic("sys_exofork failed.");
  8010bf:	83 ec 04             	sub    $0x4,%esp
  8010c2:	68 99 28 80 00       	push   $0x802899
  8010c7:	68 b7 00 00 00       	push   $0xb7
  8010cc:	68 00 28 80 00       	push   $0x802800
  8010d1:	e8 6e f1 ff ff       	call   800244 <_panic>
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  8010db:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010df:	75 21                	jne    801102 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010e1:	e8 cb fb ff ff       	call   800cb1 <sys_getenvid>
  8010e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f3:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fd:	e9 69 01 00 00       	jmp    80126b <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801102:	89 d8                	mov    %ebx,%eax
  801104:	c1 e8 16             	shr    $0x16,%eax
  801107:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  80110e:	a8 01                	test   $0x1,%al
  801110:	0f 84 d6 00 00 00    	je     8011ec <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  801116:	89 de                	mov    %ebx,%esi
  801118:	c1 ee 0c             	shr    $0xc,%esi
  80111b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801122:	a8 01                	test   $0x1,%al
  801124:	0f 84 c2 00 00 00    	je     8011ec <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  80112a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  801131:	89 f7                	mov    %esi,%edi
  801133:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  801136:	e8 76 fb ff ff       	call   800cb1 <sys_getenvid>
  80113b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  80113e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801145:	f6 c4 04             	test   $0x4,%ah
  801148:	74 1c                	je     801166 <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	68 07 0e 00 00       	push   $0xe07
  801152:	57                   	push   %edi
  801153:	ff 75 e0             	pushl  -0x20(%ebp)
  801156:	57                   	push   %edi
  801157:	6a 00                	push   $0x0
  801159:	e8 d4 fb ff ff       	call   800d32 <sys_page_map>
  80115e:	83 c4 20             	add    $0x20,%esp
  801161:	e9 86 00 00 00       	jmp    8011ec <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  801166:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116d:	a8 02                	test   $0x2,%al
  80116f:	75 0c                	jne    80117d <fork+0xe5>
  801171:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801178:	f6 c4 08             	test   $0x8,%ah
  80117b:	74 5b                	je     8011d8 <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	68 05 08 00 00       	push   $0x805
  801185:	57                   	push   %edi
  801186:	ff 75 e0             	pushl  -0x20(%ebp)
  801189:	57                   	push   %edi
  80118a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118d:	e8 a0 fb ff ff       	call   800d32 <sys_page_map>
  801192:	83 c4 20             	add    $0x20,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	79 12                	jns    8011ab <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  801199:	50                   	push   %eax
  80119a:	68 1c 29 80 00       	push   $0x80291c
  80119f:	6a 5f                	push   $0x5f
  8011a1:	68 00 28 80 00       	push   $0x802800
  8011a6:	e8 99 f0 ff ff       	call   800244 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	68 05 08 00 00       	push   $0x805
  8011b3:	57                   	push   %edi
  8011b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	57                   	push   %edi
  8011b9:	50                   	push   %eax
  8011ba:	e8 73 fb ff ff       	call   800d32 <sys_page_map>
  8011bf:	83 c4 20             	add    $0x20,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	79 26                	jns    8011ec <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  8011c6:	50                   	push   %eax
  8011c7:	68 40 29 80 00       	push   $0x802940
  8011cc:	6a 64                	push   $0x64
  8011ce:	68 00 28 80 00       	push   $0x802800
  8011d3:	e8 6c f0 ff ff       	call   800244 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8011d8:	83 ec 0c             	sub    $0xc,%esp
  8011db:	6a 05                	push   $0x5
  8011dd:	57                   	push   %edi
  8011de:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e1:	57                   	push   %edi
  8011e2:	6a 00                	push   $0x0
  8011e4:	e8 49 fb ff ff       	call   800d32 <sys_page_map>
  8011e9:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8011ec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011f2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011f8:	0f 85 04 ff ff ff    	jne    801102 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	6a 07                	push   $0x7
  801203:	68 00 f0 bf ee       	push   $0xeebff000
  801208:	ff 75 dc             	pushl  -0x24(%ebp)
  80120b:	e8 df fa ff ff       	call   800cef <sys_page_alloc>
	if(retv < 0){
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	79 17                	jns    80122e <fork+0x196>
		panic("sys_page_alloc failed.\n");
  801217:	83 ec 04             	sub    $0x4,%esp
  80121a:	68 ad 28 80 00       	push   $0x8028ad
  80121f:	68 cc 00 00 00       	push   $0xcc
  801224:	68 00 28 80 00       	push   $0x802800
  801229:	e8 16 f0 ff ff       	call   800244 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	68 e9 20 80 00       	push   $0x8020e9
  801236:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801239:	57                   	push   %edi
  80123a:	e8 fb fb ff ff       	call   800e3a <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  80123f:	83 c4 08             	add    $0x8,%esp
  801242:	6a 02                	push   $0x2
  801244:	57                   	push   %edi
  801245:	e8 6c fb ff ff       	call   800db6 <sys_env_set_status>
	if(retv < 0){
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	79 17                	jns    801268 <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	68 c5 28 80 00       	push   $0x8028c5
  801259:	68 dd 00 00 00       	push   $0xdd
  80125e:	68 00 28 80 00       	push   $0x802800
  801263:	e8 dc ef ff ff       	call   800244 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  801268:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  80126b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <sfork>:

// Challenge!
int
sfork(void)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801279:	68 e1 28 80 00       	push   $0x8028e1
  80127e:	68 e8 00 00 00       	push   $0xe8
  801283:	68 00 28 80 00       	push   $0x802800
  801288:	e8 b7 ef ff ff       	call   800244 <_panic>

0080128d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
  801292:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801295:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	e8 fc fb ff ff       	call   800e9f <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 f6                	test   %esi,%esi
  8012a8:	74 1c                	je     8012c6 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  8012aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8012af:	8b 40 78             	mov    0x78(%eax),%eax
  8012b2:	89 06                	mov    %eax,(%esi)
  8012b4:	eb 10                	jmp    8012c6 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	68 62 29 80 00       	push   $0x802962
  8012be:	e8 5a f0 ff ff       	call   80031d <cprintf>
  8012c3:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  8012c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8012cb:	8b 50 74             	mov    0x74(%eax),%edx
  8012ce:	85 d2                	test   %edx,%edx
  8012d0:	74 e4                	je     8012b6 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  8012d2:	85 db                	test   %ebx,%ebx
  8012d4:	74 05                	je     8012db <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  8012d6:	8b 40 74             	mov    0x74(%eax),%eax
  8012d9:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8012db:	a1 04 40 80 00       	mov    0x804004,%eax
  8012e0:	8b 40 70             	mov    0x70(%eax),%eax

}
  8012e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e6:	5b                   	pop    %ebx
  8012e7:	5e                   	pop    %esi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	57                   	push   %edi
  8012ee:	56                   	push   %esi
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 0c             	sub    $0xc,%esp
  8012f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  8012fc:	85 db                	test   %ebx,%ebx
  8012fe:	75 13                	jne    801313 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801300:	6a 00                	push   $0x0
  801302:	68 00 00 c0 ee       	push   $0xeec00000
  801307:	56                   	push   %esi
  801308:	57                   	push   %edi
  801309:	e8 6e fb ff ff       	call   800e7c <sys_ipc_try_send>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	eb 0e                	jmp    801321 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801313:	ff 75 14             	pushl  0x14(%ebp)
  801316:	53                   	push   %ebx
  801317:	56                   	push   %esi
  801318:	57                   	push   %edi
  801319:	e8 5e fb ff ff       	call   800e7c <sys_ipc_try_send>
  80131e:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801321:	85 c0                	test   %eax,%eax
  801323:	75 d7                	jne    8012fc <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801325:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801333:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801338:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80133b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801341:	8b 52 50             	mov    0x50(%edx),%edx
  801344:	39 ca                	cmp    %ecx,%edx
  801346:	75 0d                	jne    801355 <ipc_find_env+0x28>
			return envs[i].env_id;
  801348:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80134b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801350:	8b 40 48             	mov    0x48(%eax),%eax
  801353:	eb 0f                	jmp    801364 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801355:	83 c0 01             	add    $0x1,%eax
  801358:	3d 00 04 00 00       	cmp    $0x400,%eax
  80135d:	75 d9                	jne    801338 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801369:	8b 45 08             	mov    0x8(%ebp),%eax
  80136c:	05 00 00 00 30       	add    $0x30000000,%eax
  801371:	c1 e8 0c             	shr    $0xc,%eax
}
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801379:	8b 45 08             	mov    0x8(%ebp),%eax
  80137c:	05 00 00 00 30       	add    $0x30000000,%eax
  801381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801386:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801393:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801398:	89 c2                	mov    %eax,%edx
  80139a:	c1 ea 16             	shr    $0x16,%edx
  80139d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a4:	f6 c2 01             	test   $0x1,%dl
  8013a7:	74 11                	je     8013ba <fd_alloc+0x2d>
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	c1 ea 0c             	shr    $0xc,%edx
  8013ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b5:	f6 c2 01             	test   $0x1,%dl
  8013b8:	75 09                	jne    8013c3 <fd_alloc+0x36>
			*fd_store = fd;
  8013ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c1:	eb 17                	jmp    8013da <fd_alloc+0x4d>
  8013c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013cd:	75 c9                	jne    801398 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013cf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013d5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e2:	83 f8 1f             	cmp    $0x1f,%eax
  8013e5:	77 36                	ja     80141d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e7:	c1 e0 0c             	shl    $0xc,%eax
  8013ea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	c1 ea 16             	shr    $0x16,%edx
  8013f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fb:	f6 c2 01             	test   $0x1,%dl
  8013fe:	74 24                	je     801424 <fd_lookup+0x48>
  801400:	89 c2                	mov    %eax,%edx
  801402:	c1 ea 0c             	shr    $0xc,%edx
  801405:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140c:	f6 c2 01             	test   $0x1,%dl
  80140f:	74 1a                	je     80142b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801411:	8b 55 0c             	mov    0xc(%ebp),%edx
  801414:	89 02                	mov    %eax,(%edx)
	return 0;
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
  80141b:	eb 13                	jmp    801430 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80141d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801422:	eb 0c                	jmp    801430 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801424:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801429:	eb 05                	jmp    801430 <fd_lookup+0x54>
  80142b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143b:	ba f0 29 80 00       	mov    $0x8029f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801440:	eb 13                	jmp    801455 <dev_lookup+0x23>
  801442:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801445:	39 08                	cmp    %ecx,(%eax)
  801447:	75 0c                	jne    801455 <dev_lookup+0x23>
			*dev = devtab[i];
  801449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80144e:	b8 00 00 00 00       	mov    $0x0,%eax
  801453:	eb 2e                	jmp    801483 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801455:	8b 02                	mov    (%edx),%eax
  801457:	85 c0                	test   %eax,%eax
  801459:	75 e7                	jne    801442 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80145b:	a1 04 40 80 00       	mov    0x804004,%eax
  801460:	8b 40 48             	mov    0x48(%eax),%eax
  801463:	83 ec 04             	sub    $0x4,%esp
  801466:	51                   	push   %ecx
  801467:	50                   	push   %eax
  801468:	68 74 29 80 00       	push   $0x802974
  80146d:	e8 ab ee ff ff       	call   80031d <cprintf>
	*dev = 0;
  801472:	8b 45 0c             	mov    0xc(%ebp),%eax
  801475:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	56                   	push   %esi
  801489:	53                   	push   %ebx
  80148a:	83 ec 10             	sub    $0x10,%esp
  80148d:	8b 75 08             	mov    0x8(%ebp),%esi
  801490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80149d:	c1 e8 0c             	shr    $0xc,%eax
  8014a0:	50                   	push   %eax
  8014a1:	e8 36 ff ff ff       	call   8013dc <fd_lookup>
  8014a6:	83 c4 08             	add    $0x8,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 05                	js     8014b2 <fd_close+0x2d>
	    || fd != fd2)
  8014ad:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014b0:	74 0c                	je     8014be <fd_close+0x39>
		return (must_exist ? r : 0);
  8014b2:	84 db                	test   %bl,%bl
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	0f 44 c2             	cmove  %edx,%eax
  8014bc:	eb 41                	jmp    8014ff <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014be:	83 ec 08             	sub    $0x8,%esp
  8014c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	ff 36                	pushl  (%esi)
  8014c7:	e8 66 ff ff ff       	call   801432 <dev_lookup>
  8014cc:	89 c3                	mov    %eax,%ebx
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 1a                	js     8014ef <fd_close+0x6a>
		if (dev->dev_close)
  8014d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014db:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	74 0b                	je     8014ef <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	56                   	push   %esi
  8014e8:	ff d0                	call   *%eax
  8014ea:	89 c3                	mov    %eax,%ebx
  8014ec:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	56                   	push   %esi
  8014f3:	6a 00                	push   $0x0
  8014f5:	e8 7a f8 ff ff       	call   800d74 <sys_page_unmap>
	return r;
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	89 d8                	mov    %ebx,%eax
}
  8014ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	ff 75 08             	pushl  0x8(%ebp)
  801513:	e8 c4 fe ff ff       	call   8013dc <fd_lookup>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 10                	js     80152f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80151f:	83 ec 08             	sub    $0x8,%esp
  801522:	6a 01                	push   $0x1
  801524:	ff 75 f4             	pushl  -0xc(%ebp)
  801527:	e8 59 ff ff ff       	call   801485 <fd_close>
  80152c:	83 c4 10             	add    $0x10,%esp
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <close_all>:

void
close_all(void)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801538:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	53                   	push   %ebx
  801541:	e8 c0 ff ff ff       	call   801506 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801546:	83 c3 01             	add    $0x1,%ebx
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	83 fb 20             	cmp    $0x20,%ebx
  80154f:	75 ec                	jne    80153d <close_all+0xc>
		close(i);
}
  801551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	57                   	push   %edi
  80155a:	56                   	push   %esi
  80155b:	53                   	push   %ebx
  80155c:	83 ec 2c             	sub    $0x2c,%esp
  80155f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801562:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	ff 75 08             	pushl  0x8(%ebp)
  801569:	e8 6e fe ff ff       	call   8013dc <fd_lookup>
  80156e:	83 c4 08             	add    $0x8,%esp
  801571:	85 c0                	test   %eax,%eax
  801573:	0f 88 c1 00 00 00    	js     80163a <dup+0xe4>
		return r;
	close(newfdnum);
  801579:	83 ec 0c             	sub    $0xc,%esp
  80157c:	56                   	push   %esi
  80157d:	e8 84 ff ff ff       	call   801506 <close>

	newfd = INDEX2FD(newfdnum);
  801582:	89 f3                	mov    %esi,%ebx
  801584:	c1 e3 0c             	shl    $0xc,%ebx
  801587:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80158d:	83 c4 04             	add    $0x4,%esp
  801590:	ff 75 e4             	pushl  -0x1c(%ebp)
  801593:	e8 de fd ff ff       	call   801376 <fd2data>
  801598:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80159a:	89 1c 24             	mov    %ebx,(%esp)
  80159d:	e8 d4 fd ff ff       	call   801376 <fd2data>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a8:	89 f8                	mov    %edi,%eax
  8015aa:	c1 e8 16             	shr    $0x16,%eax
  8015ad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b4:	a8 01                	test   $0x1,%al
  8015b6:	74 37                	je     8015ef <dup+0x99>
  8015b8:	89 f8                	mov    %edi,%eax
  8015ba:	c1 e8 0c             	shr    $0xc,%eax
  8015bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c4:	f6 c2 01             	test   $0x1,%dl
  8015c7:	74 26                	je     8015ef <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d8:	50                   	push   %eax
  8015d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015dc:	6a 00                	push   $0x0
  8015de:	57                   	push   %edi
  8015df:	6a 00                	push   $0x0
  8015e1:	e8 4c f7 ff ff       	call   800d32 <sys_page_map>
  8015e6:	89 c7                	mov    %eax,%edi
  8015e8:	83 c4 20             	add    $0x20,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 2e                	js     80161d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015f2:	89 d0                	mov    %edx,%eax
  8015f4:	c1 e8 0c             	shr    $0xc,%eax
  8015f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	25 07 0e 00 00       	and    $0xe07,%eax
  801606:	50                   	push   %eax
  801607:	53                   	push   %ebx
  801608:	6a 00                	push   $0x0
  80160a:	52                   	push   %edx
  80160b:	6a 00                	push   $0x0
  80160d:	e8 20 f7 ff ff       	call   800d32 <sys_page_map>
  801612:	89 c7                	mov    %eax,%edi
  801614:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801617:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801619:	85 ff                	test   %edi,%edi
  80161b:	79 1d                	jns    80163a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	53                   	push   %ebx
  801621:	6a 00                	push   $0x0
  801623:	e8 4c f7 ff ff       	call   800d74 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80162e:	6a 00                	push   $0x0
  801630:	e8 3f f7 ff ff       	call   800d74 <sys_page_unmap>
	return r;
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	89 f8                	mov    %edi,%eax
}
  80163a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163d:	5b                   	pop    %ebx
  80163e:	5e                   	pop    %esi
  80163f:	5f                   	pop    %edi
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    

00801642 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	53                   	push   %ebx
  801646:	83 ec 14             	sub    $0x14,%esp
  801649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164f:	50                   	push   %eax
  801650:	53                   	push   %ebx
  801651:	e8 86 fd ff ff       	call   8013dc <fd_lookup>
  801656:	83 c4 08             	add    $0x8,%esp
  801659:	89 c2                	mov    %eax,%edx
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 6d                	js     8016cc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801669:	ff 30                	pushl  (%eax)
  80166b:	e8 c2 fd ff ff       	call   801432 <dev_lookup>
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 4c                	js     8016c3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801677:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80167a:	8b 42 08             	mov    0x8(%edx),%eax
  80167d:	83 e0 03             	and    $0x3,%eax
  801680:	83 f8 01             	cmp    $0x1,%eax
  801683:	75 21                	jne    8016a6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801685:	a1 04 40 80 00       	mov    0x804004,%eax
  80168a:	8b 40 48             	mov    0x48(%eax),%eax
  80168d:	83 ec 04             	sub    $0x4,%esp
  801690:	53                   	push   %ebx
  801691:	50                   	push   %eax
  801692:	68 b5 29 80 00       	push   $0x8029b5
  801697:	e8 81 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a4:	eb 26                	jmp    8016cc <read+0x8a>
	}
	if (!dev->dev_read)
  8016a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a9:	8b 40 08             	mov    0x8(%eax),%eax
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	74 17                	je     8016c7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016b0:	83 ec 04             	sub    $0x4,%esp
  8016b3:	ff 75 10             	pushl  0x10(%ebp)
  8016b6:	ff 75 0c             	pushl  0xc(%ebp)
  8016b9:	52                   	push   %edx
  8016ba:	ff d0                	call   *%eax
  8016bc:	89 c2                	mov    %eax,%edx
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	eb 09                	jmp    8016cc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	eb 05                	jmp    8016cc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016cc:	89 d0                	mov    %edx,%eax
  8016ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d1:	c9                   	leave  
  8016d2:	c3                   	ret    

008016d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	57                   	push   %edi
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 0c             	sub    $0xc,%esp
  8016dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e7:	eb 21                	jmp    80170a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016e9:	83 ec 04             	sub    $0x4,%esp
  8016ec:	89 f0                	mov    %esi,%eax
  8016ee:	29 d8                	sub    %ebx,%eax
  8016f0:	50                   	push   %eax
  8016f1:	89 d8                	mov    %ebx,%eax
  8016f3:	03 45 0c             	add    0xc(%ebp),%eax
  8016f6:	50                   	push   %eax
  8016f7:	57                   	push   %edi
  8016f8:	e8 45 ff ff ff       	call   801642 <read>
		if (m < 0)
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	85 c0                	test   %eax,%eax
  801702:	78 10                	js     801714 <readn+0x41>
			return m;
		if (m == 0)
  801704:	85 c0                	test   %eax,%eax
  801706:	74 0a                	je     801712 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801708:	01 c3                	add    %eax,%ebx
  80170a:	39 f3                	cmp    %esi,%ebx
  80170c:	72 db                	jb     8016e9 <readn+0x16>
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	eb 02                	jmp    801714 <readn+0x41>
  801712:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801714:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801717:	5b                   	pop    %ebx
  801718:	5e                   	pop    %esi
  801719:	5f                   	pop    %edi
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	83 ec 14             	sub    $0x14,%esp
  801723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	53                   	push   %ebx
  80172b:	e8 ac fc ff ff       	call   8013dc <fd_lookup>
  801730:	83 c4 08             	add    $0x8,%esp
  801733:	89 c2                	mov    %eax,%edx
  801735:	85 c0                	test   %eax,%eax
  801737:	78 68                	js     8017a1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173f:	50                   	push   %eax
  801740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801743:	ff 30                	pushl  (%eax)
  801745:	e8 e8 fc ff ff       	call   801432 <dev_lookup>
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 47                	js     801798 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801754:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801758:	75 21                	jne    80177b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80175a:	a1 04 40 80 00       	mov    0x804004,%eax
  80175f:	8b 40 48             	mov    0x48(%eax),%eax
  801762:	83 ec 04             	sub    $0x4,%esp
  801765:	53                   	push   %ebx
  801766:	50                   	push   %eax
  801767:	68 d1 29 80 00       	push   $0x8029d1
  80176c:	e8 ac eb ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801779:	eb 26                	jmp    8017a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80177b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177e:	8b 52 0c             	mov    0xc(%edx),%edx
  801781:	85 d2                	test   %edx,%edx
  801783:	74 17                	je     80179c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	ff 75 10             	pushl  0x10(%ebp)
  80178b:	ff 75 0c             	pushl  0xc(%ebp)
  80178e:	50                   	push   %eax
  80178f:	ff d2                	call   *%edx
  801791:	89 c2                	mov    %eax,%edx
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	eb 09                	jmp    8017a1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801798:	89 c2                	mov    %eax,%edx
  80179a:	eb 05                	jmp    8017a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80179c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017a1:	89 d0                	mov    %edx,%eax
  8017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ae:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	ff 75 08             	pushl  0x8(%ebp)
  8017b5:	e8 22 fc ff ff       	call   8013dc <fd_lookup>
  8017ba:	83 c4 08             	add    $0x8,%esp
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	78 0e                	js     8017cf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	53                   	push   %ebx
  8017d5:	83 ec 14             	sub    $0x14,%esp
  8017d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017de:	50                   	push   %eax
  8017df:	53                   	push   %ebx
  8017e0:	e8 f7 fb ff ff       	call   8013dc <fd_lookup>
  8017e5:	83 c4 08             	add    $0x8,%esp
  8017e8:	89 c2                	mov    %eax,%edx
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 65                	js     801853 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f8:	ff 30                	pushl  (%eax)
  8017fa:	e8 33 fc ff ff       	call   801432 <dev_lookup>
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	85 c0                	test   %eax,%eax
  801804:	78 44                	js     80184a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801806:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801809:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80180d:	75 21                	jne    801830 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80180f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801814:	8b 40 48             	mov    0x48(%eax),%eax
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	53                   	push   %ebx
  80181b:	50                   	push   %eax
  80181c:	68 94 29 80 00       	push   $0x802994
  801821:	e8 f7 ea ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80182e:	eb 23                	jmp    801853 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801830:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801833:	8b 52 18             	mov    0x18(%edx),%edx
  801836:	85 d2                	test   %edx,%edx
  801838:	74 14                	je     80184e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	ff 75 0c             	pushl  0xc(%ebp)
  801840:	50                   	push   %eax
  801841:	ff d2                	call   *%edx
  801843:	89 c2                	mov    %eax,%edx
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	eb 09                	jmp    801853 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184a:	89 c2                	mov    %eax,%edx
  80184c:	eb 05                	jmp    801853 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80184e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801853:	89 d0                	mov    %edx,%eax
  801855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	53                   	push   %ebx
  80185e:	83 ec 14             	sub    $0x14,%esp
  801861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	ff 75 08             	pushl  0x8(%ebp)
  80186b:	e8 6c fb ff ff       	call   8013dc <fd_lookup>
  801870:	83 c4 08             	add    $0x8,%esp
  801873:	89 c2                	mov    %eax,%edx
  801875:	85 c0                	test   %eax,%eax
  801877:	78 58                	js     8018d1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801879:	83 ec 08             	sub    $0x8,%esp
  80187c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187f:	50                   	push   %eax
  801880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801883:	ff 30                	pushl  (%eax)
  801885:	e8 a8 fb ff ff       	call   801432 <dev_lookup>
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 37                	js     8018c8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801894:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801898:	74 32                	je     8018cc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80189a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80189d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018a4:	00 00 00 
	stat->st_isdir = 0;
  8018a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018ae:	00 00 00 
	stat->st_dev = dev;
  8018b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	53                   	push   %ebx
  8018bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8018be:	ff 50 14             	call   *0x14(%eax)
  8018c1:	89 c2                	mov    %eax,%edx
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	eb 09                	jmp    8018d1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c8:	89 c2                	mov    %eax,%edx
  8018ca:	eb 05                	jmp    8018d1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018d1:	89 d0                	mov    %edx,%eax
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	6a 00                	push   $0x0
  8018e2:	ff 75 08             	pushl  0x8(%ebp)
  8018e5:	e8 dc 01 00 00       	call   801ac6 <open>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 1b                	js     80190e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	ff 75 0c             	pushl  0xc(%ebp)
  8018f9:	50                   	push   %eax
  8018fa:	e8 5b ff ff ff       	call   80185a <fstat>
  8018ff:	89 c6                	mov    %eax,%esi
	close(fd);
  801901:	89 1c 24             	mov    %ebx,(%esp)
  801904:	e8 fd fb ff ff       	call   801506 <close>
	return r;
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	89 f0                	mov    %esi,%eax
}
  80190e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801911:	5b                   	pop    %ebx
  801912:	5e                   	pop    %esi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	89 c6                	mov    %eax,%esi
  80191c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80191e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801925:	75 12                	jne    801939 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801927:	83 ec 0c             	sub    $0xc,%esp
  80192a:	6a 01                	push   $0x1
  80192c:	e8 fc f9 ff ff       	call   80132d <ipc_find_env>
  801931:	a3 00 40 80 00       	mov    %eax,0x804000
  801936:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801939:	6a 07                	push   $0x7
  80193b:	68 00 50 80 00       	push   $0x805000
  801940:	56                   	push   %esi
  801941:	ff 35 00 40 80 00    	pushl  0x804000
  801947:	e8 9e f9 ff ff       	call   8012ea <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  80194c:	83 c4 0c             	add    $0xc,%esp
  80194f:	6a 00                	push   $0x0
  801951:	53                   	push   %ebx
  801952:	6a 00                	push   $0x0
  801954:	e8 34 f9 ff ff       	call   80128d <ipc_recv>
}
  801959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195c:	5b                   	pop    %ebx
  80195d:	5e                   	pop    %esi
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	8b 40 0c             	mov    0xc(%eax),%eax
  80196c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801971:	8b 45 0c             	mov    0xc(%ebp),%eax
  801974:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801979:	ba 00 00 00 00       	mov    $0x0,%edx
  80197e:	b8 02 00 00 00       	mov    $0x2,%eax
  801983:	e8 8d ff ff ff       	call   801915 <fsipc>
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	8b 40 0c             	mov    0xc(%eax),%eax
  801996:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80199b:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a5:	e8 6b ff ff ff       	call   801915 <fsipc>
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	53                   	push   %ebx
  8019b0:	83 ec 04             	sub    $0x4,%esp
  8019b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8019cb:	e8 45 ff ff ff       	call   801915 <fsipc>
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 2c                	js     801a00 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019d4:	83 ec 08             	sub    $0x8,%esp
  8019d7:	68 00 50 80 00       	push   $0x805000
  8019dc:	53                   	push   %ebx
  8019dd:	e8 0a ef ff ff       	call   8008ec <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019e2:	a1 80 50 80 00       	mov    0x805080,%eax
  8019e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019ed:	a1 84 50 80 00       	mov    0x805084,%eax
  8019f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  801a11:	8b 52 0c             	mov    0xc(%edx),%edx
  801a14:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a1a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a1f:	50                   	push   %eax
  801a20:	ff 75 0c             	pushl  0xc(%ebp)
  801a23:	68 08 50 80 00       	push   $0x805008
  801a28:	e8 51 f0 ff ff       	call   800a7e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a32:	b8 04 00 00 00       	mov    $0x4,%eax
  801a37:	e8 d9 fe ff ff       	call   801915 <fsipc>
	//panic("devfile_write not implemented");
}
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a46:	8b 45 08             	mov    0x8(%ebp),%eax
  801a49:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a51:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5c:	b8 03 00 00 00       	mov    $0x3,%eax
  801a61:	e8 af fe ff ff       	call   801915 <fsipc>
  801a66:	89 c3                	mov    %eax,%ebx
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 51                	js     801abd <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801a6c:	39 c6                	cmp    %eax,%esi
  801a6e:	73 19                	jae    801a89 <devfile_read+0x4b>
  801a70:	68 00 2a 80 00       	push   $0x802a00
  801a75:	68 07 2a 80 00       	push   $0x802a07
  801a7a:	68 80 00 00 00       	push   $0x80
  801a7f:	68 1c 2a 80 00       	push   $0x802a1c
  801a84:	e8 bb e7 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801a89:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a8e:	7e 19                	jle    801aa9 <devfile_read+0x6b>
  801a90:	68 27 2a 80 00       	push   $0x802a27
  801a95:	68 07 2a 80 00       	push   $0x802a07
  801a9a:	68 81 00 00 00       	push   $0x81
  801a9f:	68 1c 2a 80 00       	push   $0x802a1c
  801aa4:	e8 9b e7 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aa9:	83 ec 04             	sub    $0x4,%esp
  801aac:	50                   	push   %eax
  801aad:	68 00 50 80 00       	push   $0x805000
  801ab2:	ff 75 0c             	pushl  0xc(%ebp)
  801ab5:	e8 c4 ef ff ff       	call   800a7e <memmove>
	return r;
  801aba:	83 c4 10             	add    $0x10,%esp
}
  801abd:	89 d8                	mov    %ebx,%eax
  801abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 20             	sub    $0x20,%esp
  801acd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ad0:	53                   	push   %ebx
  801ad1:	e8 dd ed ff ff       	call   8008b3 <strlen>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ade:	7f 67                	jg     801b47 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae0:	83 ec 0c             	sub    $0xc,%esp
  801ae3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae6:	50                   	push   %eax
  801ae7:	e8 a1 f8 ff ff       	call   80138d <fd_alloc>
  801aec:	83 c4 10             	add    $0x10,%esp
		return r;
  801aef:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801af1:	85 c0                	test   %eax,%eax
  801af3:	78 57                	js     801b4c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801af5:	83 ec 08             	sub    $0x8,%esp
  801af8:	53                   	push   %ebx
  801af9:	68 00 50 80 00       	push   $0x805000
  801afe:	e8 e9 ed ff ff       	call   8008ec <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b06:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b13:	e8 fd fd ff ff       	call   801915 <fsipc>
  801b18:	89 c3                	mov    %eax,%ebx
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	79 14                	jns    801b35 <open+0x6f>
		
		fd_close(fd, 0);
  801b21:	83 ec 08             	sub    $0x8,%esp
  801b24:	6a 00                	push   $0x0
  801b26:	ff 75 f4             	pushl  -0xc(%ebp)
  801b29:	e8 57 f9 ff ff       	call   801485 <fd_close>
		return r;
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	89 da                	mov    %ebx,%edx
  801b33:	eb 17                	jmp    801b4c <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3b:	e8 26 f8 ff ff       	call   801366 <fd2num>
  801b40:	89 c2                	mov    %eax,%edx
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	eb 05                	jmp    801b4c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b47:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801b4c:	89 d0                	mov    %edx,%eax
  801b4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b59:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5e:	b8 08 00 00 00       	mov    $0x8,%eax
  801b63:	e8 ad fd ff ff       	call   801915 <fsipc>
}
  801b68:	c9                   	leave  
  801b69:	c3                   	ret    

00801b6a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b70:	89 d0                	mov    %edx,%eax
  801b72:	c1 e8 16             	shr    $0x16,%eax
  801b75:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b81:	f6 c1 01             	test   $0x1,%cl
  801b84:	74 1d                	je     801ba3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b86:	c1 ea 0c             	shr    $0xc,%edx
  801b89:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b90:	f6 c2 01             	test   $0x1,%dl
  801b93:	74 0e                	je     801ba3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b95:	c1 ea 0c             	shr    $0xc,%edx
  801b98:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b9f:	ef 
  801ba0:	0f b7 c0             	movzwl %ax,%eax
}
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	56                   	push   %esi
  801ba9:	53                   	push   %ebx
  801baa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bad:	83 ec 0c             	sub    $0xc,%esp
  801bb0:	ff 75 08             	pushl  0x8(%ebp)
  801bb3:	e8 be f7 ff ff       	call   801376 <fd2data>
  801bb8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bba:	83 c4 08             	add    $0x8,%esp
  801bbd:	68 33 2a 80 00       	push   $0x802a33
  801bc2:	53                   	push   %ebx
  801bc3:	e8 24 ed ff ff       	call   8008ec <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bc8:	8b 46 04             	mov    0x4(%esi),%eax
  801bcb:	2b 06                	sub    (%esi),%eax
  801bcd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bd3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bda:	00 00 00 
	stat->st_dev = &devpipe;
  801bdd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801be4:	30 80 00 
	return 0;
}
  801be7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5e                   	pop    %esi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bfd:	53                   	push   %ebx
  801bfe:	6a 00                	push   $0x0
  801c00:	e8 6f f1 ff ff       	call   800d74 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c05:	89 1c 24             	mov    %ebx,(%esp)
  801c08:	e8 69 f7 ff ff       	call   801376 <fd2data>
  801c0d:	83 c4 08             	add    $0x8,%esp
  801c10:	50                   	push   %eax
  801c11:	6a 00                	push   $0x0
  801c13:	e8 5c f1 ff ff       	call   800d74 <sys_page_unmap>
}
  801c18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	57                   	push   %edi
  801c21:	56                   	push   %esi
  801c22:	53                   	push   %ebx
  801c23:	83 ec 1c             	sub    $0x1c,%esp
  801c26:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c29:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c2b:	a1 04 40 80 00       	mov    0x804004,%eax
  801c30:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c33:	83 ec 0c             	sub    $0xc,%esp
  801c36:	ff 75 e0             	pushl  -0x20(%ebp)
  801c39:	e8 2c ff ff ff       	call   801b6a <pageref>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	89 3c 24             	mov    %edi,(%esp)
  801c43:	e8 22 ff ff ff       	call   801b6a <pageref>
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	39 c3                	cmp    %eax,%ebx
  801c4d:	0f 94 c1             	sete   %cl
  801c50:	0f b6 c9             	movzbl %cl,%ecx
  801c53:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c56:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c5c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c5f:	39 ce                	cmp    %ecx,%esi
  801c61:	74 1b                	je     801c7e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c63:	39 c3                	cmp    %eax,%ebx
  801c65:	75 c4                	jne    801c2b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c67:	8b 42 58             	mov    0x58(%edx),%eax
  801c6a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c6d:	50                   	push   %eax
  801c6e:	56                   	push   %esi
  801c6f:	68 3a 2a 80 00       	push   $0x802a3a
  801c74:	e8 a4 e6 ff ff       	call   80031d <cprintf>
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	eb ad                	jmp    801c2b <_pipeisclosed+0xe>
	}
}
  801c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5e                   	pop    %esi
  801c86:	5f                   	pop    %edi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	57                   	push   %edi
  801c8d:	56                   	push   %esi
  801c8e:	53                   	push   %ebx
  801c8f:	83 ec 28             	sub    $0x28,%esp
  801c92:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c95:	56                   	push   %esi
  801c96:	e8 db f6 ff ff       	call   801376 <fd2data>
  801c9b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ca5:	eb 4b                	jmp    801cf2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ca7:	89 da                	mov    %ebx,%edx
  801ca9:	89 f0                	mov    %esi,%eax
  801cab:	e8 6d ff ff ff       	call   801c1d <_pipeisclosed>
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	75 48                	jne    801cfc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cb4:	e8 17 f0 ff ff       	call   800cd0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cb9:	8b 43 04             	mov    0x4(%ebx),%eax
  801cbc:	8b 0b                	mov    (%ebx),%ecx
  801cbe:	8d 51 20             	lea    0x20(%ecx),%edx
  801cc1:	39 d0                	cmp    %edx,%eax
  801cc3:	73 e2                	jae    801ca7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ccc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ccf:	89 c2                	mov    %eax,%edx
  801cd1:	c1 fa 1f             	sar    $0x1f,%edx
  801cd4:	89 d1                	mov    %edx,%ecx
  801cd6:	c1 e9 1b             	shr    $0x1b,%ecx
  801cd9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cdc:	83 e2 1f             	and    $0x1f,%edx
  801cdf:	29 ca                	sub    %ecx,%edx
  801ce1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ce5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ce9:	83 c0 01             	add    $0x1,%eax
  801cec:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cef:	83 c7 01             	add    $0x1,%edi
  801cf2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cf5:	75 c2                	jne    801cb9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cf7:	8b 45 10             	mov    0x10(%ebp),%eax
  801cfa:	eb 05                	jmp    801d01 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cfc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	57                   	push   %edi
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
  801d0f:	83 ec 18             	sub    $0x18,%esp
  801d12:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d15:	57                   	push   %edi
  801d16:	e8 5b f6 ff ff       	call   801376 <fd2data>
  801d1b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d25:	eb 3d                	jmp    801d64 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d27:	85 db                	test   %ebx,%ebx
  801d29:	74 04                	je     801d2f <devpipe_read+0x26>
				return i;
  801d2b:	89 d8                	mov    %ebx,%eax
  801d2d:	eb 44                	jmp    801d73 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d2f:	89 f2                	mov    %esi,%edx
  801d31:	89 f8                	mov    %edi,%eax
  801d33:	e8 e5 fe ff ff       	call   801c1d <_pipeisclosed>
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	75 32                	jne    801d6e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d3c:	e8 8f ef ff ff       	call   800cd0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d41:	8b 06                	mov    (%esi),%eax
  801d43:	3b 46 04             	cmp    0x4(%esi),%eax
  801d46:	74 df                	je     801d27 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d48:	99                   	cltd   
  801d49:	c1 ea 1b             	shr    $0x1b,%edx
  801d4c:	01 d0                	add    %edx,%eax
  801d4e:	83 e0 1f             	and    $0x1f,%eax
  801d51:	29 d0                	sub    %edx,%eax
  801d53:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d5b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d5e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d61:	83 c3 01             	add    $0x1,%ebx
  801d64:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d67:	75 d8                	jne    801d41 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d69:	8b 45 10             	mov    0x10(%ebp),%eax
  801d6c:	eb 05                	jmp    801d73 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d6e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5e                   	pop    %esi
  801d78:	5f                   	pop    %edi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d86:	50                   	push   %eax
  801d87:	e8 01 f6 ff ff       	call   80138d <fd_alloc>
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	89 c2                	mov    %eax,%edx
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 88 2c 01 00 00    	js     801ec5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d99:	83 ec 04             	sub    $0x4,%esp
  801d9c:	68 07 04 00 00       	push   $0x407
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	6a 00                	push   $0x0
  801da6:	e8 44 ef ff ff       	call   800cef <sys_page_alloc>
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	89 c2                	mov    %eax,%edx
  801db0:	85 c0                	test   %eax,%eax
  801db2:	0f 88 0d 01 00 00    	js     801ec5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dbe:	50                   	push   %eax
  801dbf:	e8 c9 f5 ff ff       	call   80138d <fd_alloc>
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	0f 88 e2 00 00 00    	js     801eb3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd1:	83 ec 04             	sub    $0x4,%esp
  801dd4:	68 07 04 00 00       	push   $0x407
  801dd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddc:	6a 00                	push   $0x0
  801dde:	e8 0c ef ff ff       	call   800cef <sys_page_alloc>
  801de3:	89 c3                	mov    %eax,%ebx
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	0f 88 c3 00 00 00    	js     801eb3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801df0:	83 ec 0c             	sub    $0xc,%esp
  801df3:	ff 75 f4             	pushl  -0xc(%ebp)
  801df6:	e8 7b f5 ff ff       	call   801376 <fd2data>
  801dfb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfd:	83 c4 0c             	add    $0xc,%esp
  801e00:	68 07 04 00 00       	push   $0x407
  801e05:	50                   	push   %eax
  801e06:	6a 00                	push   $0x0
  801e08:	e8 e2 ee ff ff       	call   800cef <sys_page_alloc>
  801e0d:	89 c3                	mov    %eax,%ebx
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	0f 88 89 00 00 00    	js     801ea3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e20:	e8 51 f5 ff ff       	call   801376 <fd2data>
  801e25:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e2c:	50                   	push   %eax
  801e2d:	6a 00                	push   $0x0
  801e2f:	56                   	push   %esi
  801e30:	6a 00                	push   $0x0
  801e32:	e8 fb ee ff ff       	call   800d32 <sys_page_map>
  801e37:	89 c3                	mov    %eax,%ebx
  801e39:	83 c4 20             	add    $0x20,%esp
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 55                	js     801e95 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e40:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e49:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e55:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e5e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e63:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e6a:	83 ec 0c             	sub    $0xc,%esp
  801e6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e70:	e8 f1 f4 ff ff       	call   801366 <fd2num>
  801e75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e78:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e7a:	83 c4 04             	add    $0x4,%esp
  801e7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e80:	e8 e1 f4 ff ff       	call   801366 <fd2num>
  801e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e88:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801e93:	eb 30                	jmp    801ec5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e95:	83 ec 08             	sub    $0x8,%esp
  801e98:	56                   	push   %esi
  801e99:	6a 00                	push   $0x0
  801e9b:	e8 d4 ee ff ff       	call   800d74 <sys_page_unmap>
  801ea0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ea3:	83 ec 08             	sub    $0x8,%esp
  801ea6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea9:	6a 00                	push   $0x0
  801eab:	e8 c4 ee ff ff       	call   800d74 <sys_page_unmap>
  801eb0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801eb3:	83 ec 08             	sub    $0x8,%esp
  801eb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb9:	6a 00                	push   $0x0
  801ebb:	e8 b4 ee ff ff       	call   800d74 <sys_page_unmap>
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ec5:	89 d0                	mov    %edx,%eax
  801ec7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eca:	5b                   	pop    %ebx
  801ecb:	5e                   	pop    %esi
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	ff 75 08             	pushl  0x8(%ebp)
  801edb:	e8 fc f4 ff ff       	call   8013dc <fd_lookup>
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 18                	js     801eff <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ee7:	83 ec 0c             	sub    $0xc,%esp
  801eea:	ff 75 f4             	pushl  -0xc(%ebp)
  801eed:	e8 84 f4 ff ff       	call   801376 <fd2data>
	return _pipeisclosed(fd, p);
  801ef2:	89 c2                	mov    %eax,%edx
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	e8 21 fd ff ff       	call   801c1d <_pipeisclosed>
  801efc:	83 c4 10             	add    $0x10,%esp
}
  801eff:	c9                   	leave  
  801f00:	c3                   	ret    

00801f01 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    

00801f0b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f11:	68 52 2a 80 00       	push   $0x802a52
  801f16:	ff 75 0c             	pushl  0xc(%ebp)
  801f19:	e8 ce e9 ff ff       	call   8008ec <strcpy>
	return 0;
}
  801f1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f23:	c9                   	leave  
  801f24:	c3                   	ret    

00801f25 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	57                   	push   %edi
  801f29:	56                   	push   %esi
  801f2a:	53                   	push   %ebx
  801f2b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f31:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f36:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f3c:	eb 2d                	jmp    801f6b <devcons_write+0x46>
		m = n - tot;
  801f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f41:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f43:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f46:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f4b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f4e:	83 ec 04             	sub    $0x4,%esp
  801f51:	53                   	push   %ebx
  801f52:	03 45 0c             	add    0xc(%ebp),%eax
  801f55:	50                   	push   %eax
  801f56:	57                   	push   %edi
  801f57:	e8 22 eb ff ff       	call   800a7e <memmove>
		sys_cputs(buf, m);
  801f5c:	83 c4 08             	add    $0x8,%esp
  801f5f:	53                   	push   %ebx
  801f60:	57                   	push   %edi
  801f61:	e8 cd ec ff ff       	call   800c33 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f66:	01 de                	add    %ebx,%esi
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	89 f0                	mov    %esi,%eax
  801f6d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f70:	72 cc                	jb     801f3e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f75:	5b                   	pop    %ebx
  801f76:	5e                   	pop    %esi
  801f77:	5f                   	pop    %edi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	83 ec 08             	sub    $0x8,%esp
  801f80:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f89:	74 2a                	je     801fb5 <devcons_read+0x3b>
  801f8b:	eb 05                	jmp    801f92 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f8d:	e8 3e ed ff ff       	call   800cd0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f92:	e8 ba ec ff ff       	call   800c51 <sys_cgetc>
  801f97:	85 c0                	test   %eax,%eax
  801f99:	74 f2                	je     801f8d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 16                	js     801fb5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f9f:	83 f8 04             	cmp    $0x4,%eax
  801fa2:	74 0c                	je     801fb0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fa4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fa7:	88 02                	mov    %al,(%edx)
	return 1;
  801fa9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fae:	eb 05                	jmp    801fb5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fb0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fc3:	6a 01                	push   $0x1
  801fc5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fc8:	50                   	push   %eax
  801fc9:	e8 65 ec ff ff       	call   800c33 <sys_cputs>
}
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <getchar>:

int
getchar(void)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fd9:	6a 01                	push   $0x1
  801fdb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fde:	50                   	push   %eax
  801fdf:	6a 00                	push   $0x0
  801fe1:	e8 5c f6 ff ff       	call   801642 <read>
	if (r < 0)
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 0f                	js     801ffc <getchar+0x29>
		return r;
	if (r < 1)
  801fed:	85 c0                	test   %eax,%eax
  801fef:	7e 06                	jle    801ff7 <getchar+0x24>
		return -E_EOF;
	return c;
  801ff1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ff5:	eb 05                	jmp    801ffc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ff7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ffc:	c9                   	leave  
  801ffd:	c3                   	ret    

00801ffe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802004:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802007:	50                   	push   %eax
  802008:	ff 75 08             	pushl  0x8(%ebp)
  80200b:	e8 cc f3 ff ff       	call   8013dc <fd_lookup>
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	85 c0                	test   %eax,%eax
  802015:	78 11                	js     802028 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802020:	39 10                	cmp    %edx,(%eax)
  802022:	0f 94 c0             	sete   %al
  802025:	0f b6 c0             	movzbl %al,%eax
}
  802028:	c9                   	leave  
  802029:	c3                   	ret    

0080202a <opencons>:

int
opencons(void)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802030:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802033:	50                   	push   %eax
  802034:	e8 54 f3 ff ff       	call   80138d <fd_alloc>
  802039:	83 c4 10             	add    $0x10,%esp
		return r;
  80203c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80203e:	85 c0                	test   %eax,%eax
  802040:	78 3e                	js     802080 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802042:	83 ec 04             	sub    $0x4,%esp
  802045:	68 07 04 00 00       	push   $0x407
  80204a:	ff 75 f4             	pushl  -0xc(%ebp)
  80204d:	6a 00                	push   $0x0
  80204f:	e8 9b ec ff ff       	call   800cef <sys_page_alloc>
  802054:	83 c4 10             	add    $0x10,%esp
		return r;
  802057:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 23                	js     802080 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80205d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802066:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802072:	83 ec 0c             	sub    $0xc,%esp
  802075:	50                   	push   %eax
  802076:	e8 eb f2 ff ff       	call   801366 <fd2num>
  80207b:	89 c2                	mov    %eax,%edx
  80207d:	83 c4 10             	add    $0x10,%esp
}
  802080:	89 d0                	mov    %edx,%eax
  802082:	c9                   	leave  
  802083:	c3                   	ret    

00802084 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  80208a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802091:	75 4c                	jne    8020df <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  802093:	a1 04 40 80 00       	mov    0x804004,%eax
  802098:	8b 40 48             	mov    0x48(%eax),%eax
  80209b:	83 ec 04             	sub    $0x4,%esp
  80209e:	6a 07                	push   $0x7
  8020a0:	68 00 f0 bf ee       	push   $0xeebff000
  8020a5:	50                   	push   %eax
  8020a6:	e8 44 ec ff ff       	call   800cef <sys_page_alloc>
		if(retv != 0){
  8020ab:	83 c4 10             	add    $0x10,%esp
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	74 14                	je     8020c6 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  8020b2:	83 ec 04             	sub    $0x4,%esp
  8020b5:	68 60 2a 80 00       	push   $0x802a60
  8020ba:	6a 27                	push   $0x27
  8020bc:	68 8c 2a 80 00       	push   $0x802a8c
  8020c1:	e8 7e e1 ff ff       	call   800244 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8020c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8020cb:	8b 40 48             	mov    0x48(%eax),%eax
  8020ce:	83 ec 08             	sub    $0x8,%esp
  8020d1:	68 e9 20 80 00       	push   $0x8020e9
  8020d6:	50                   	push   %eax
  8020d7:	e8 5e ed ff ff       	call   800e3a <sys_env_set_pgfault_upcall>
  8020dc:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020df:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e2:	a3 00 60 80 00       	mov    %eax,0x806000

}
  8020e7:	c9                   	leave  
  8020e8:	c3                   	ret    

008020e9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020e9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020ea:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020ef:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  8020f1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  8020f4:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  8020f8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  8020fd:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  802101:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  802103:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  802106:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  802107:	83 c4 04             	add    $0x4,%esp
	popfl
  80210a:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80210b:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80210c:	c3                   	ret    
  80210d:	66 90                	xchg   %ax,%ax
  80210f:	90                   	nop

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 f6                	test   %esi,%esi
  802129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212d:	89 ca                	mov    %ecx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	75 3d                	jne    802170 <__udivdi3+0x60>
  802133:	39 cf                	cmp    %ecx,%edi
  802135:	0f 87 c5 00 00 00    	ja     802200 <__udivdi3+0xf0>
  80213b:	85 ff                	test   %edi,%edi
  80213d:	89 fd                	mov    %edi,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 c8                	mov    %ecx,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	89 cf                	mov    %ecx,%edi
  802158:	f7 f5                	div    %ebp
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	77 74                	ja     8021e8 <__udivdi3+0xd8>
  802174:	0f bd fe             	bsr    %esi,%edi
  802177:	83 f7 1f             	xor    $0x1f,%edi
  80217a:	0f 84 98 00 00 00    	je     802218 <__udivdi3+0x108>
  802180:	bb 20 00 00 00       	mov    $0x20,%ebx
  802185:	89 f9                	mov    %edi,%ecx
  802187:	89 c5                	mov    %eax,%ebp
  802189:	29 fb                	sub    %edi,%ebx
  80218b:	d3 e6                	shl    %cl,%esi
  80218d:	89 d9                	mov    %ebx,%ecx
  80218f:	d3 ed                	shr    %cl,%ebp
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	09 ee                	or     %ebp,%esi
  802197:	89 d9                	mov    %ebx,%ecx
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	89 d5                	mov    %edx,%ebp
  80219f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a3:	d3 ed                	shr    %cl,%ebp
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e2                	shl    %cl,%edx
  8021a9:	89 d9                	mov    %ebx,%ecx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	09 c2                	or     %eax,%edx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	89 ea                	mov    %ebp,%edx
  8021b3:	f7 f6                	div    %esi
  8021b5:	89 d5                	mov    %edx,%ebp
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	72 10                	jb     8021d1 <__udivdi3+0xc1>
  8021c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e6                	shl    %cl,%esi
  8021c9:	39 c6                	cmp    %eax,%esi
  8021cb:	73 07                	jae    8021d4 <__udivdi3+0xc4>
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	75 03                	jne    8021d4 <__udivdi3+0xc4>
  8021d1:	83 eb 01             	sub    $0x1,%ebx
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	31 db                	xor    %ebx,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	f7 f7                	div    %edi
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 c3                	mov    %eax,%ebx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5f                   	pop    %edi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	39 ce                	cmp    %ecx,%esi
  80221a:	72 0c                	jb     802228 <__udivdi3+0x118>
  80221c:	31 db                	xor    %ebx,%ebx
  80221e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802222:	0f 87 34 ff ff ff    	ja     80215c <__udivdi3+0x4c>
  802228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80222d:	e9 2a ff ff ff       	jmp    80215c <__udivdi3+0x4c>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80224b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 d2                	test   %edx,%edx
  802259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f3                	mov    %esi,%ebx
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	75 1c                	jne    802288 <__umoddi3+0x48>
  80226c:	39 f7                	cmp    %esi,%edi
  80226e:	76 50                	jbe    8022c0 <__umoddi3+0x80>
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	f7 f7                	div    %edi
  802276:	89 d0                	mov    %edx,%eax
  802278:	31 d2                	xor    %edx,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	77 52                	ja     8022e0 <__umoddi3+0xa0>
  80228e:	0f bd ea             	bsr    %edx,%ebp
  802291:	83 f5 1f             	xor    $0x1f,%ebp
  802294:	75 5a                	jne    8022f0 <__umoddi3+0xb0>
  802296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80229a:	0f 82 e0 00 00 00    	jb     802380 <__umoddi3+0x140>
  8022a0:	39 0c 24             	cmp    %ecx,(%esp)
  8022a3:	0f 86 d7 00 00 00    	jbe    802380 <__umoddi3+0x140>
  8022a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	85 ff                	test   %edi,%edi
  8022c2:	89 fd                	mov    %edi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0x91>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f7                	div    %edi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f5                	div    %ebp
  8022d7:	89 c8                	mov    %ecx,%eax
  8022d9:	f7 f5                	div    %ebp
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	eb 99                	jmp    802278 <__umoddi3+0x38>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	8b 34 24             	mov    (%esp),%esi
  8022f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022f8:	89 e9                	mov    %ebp,%ecx
  8022fa:	29 ef                	sub    %ebp,%edi
  8022fc:	d3 e0                	shl    %cl,%eax
  8022fe:	89 f9                	mov    %edi,%ecx
  802300:	89 f2                	mov    %esi,%edx
  802302:	d3 ea                	shr    %cl,%edx
  802304:	89 e9                	mov    %ebp,%ecx
  802306:	09 c2                	or     %eax,%edx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 14 24             	mov    %edx,(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	d3 e2                	shl    %cl,%edx
  802311:	89 f9                	mov    %edi,%ecx
  802313:	89 54 24 04          	mov    %edx,0x4(%esp)
  802317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	89 c6                	mov    %eax,%esi
  802321:	d3 e3                	shl    %cl,%ebx
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 d0                	mov    %edx,%eax
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	09 d8                	or     %ebx,%eax
  80232d:	89 d3                	mov    %edx,%ebx
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 34 24             	divl   (%esp)
  802334:	89 d6                	mov    %edx,%esi
  802336:	d3 e3                	shl    %cl,%ebx
  802338:	f7 64 24 04          	mull   0x4(%esp)
  80233c:	39 d6                	cmp    %edx,%esi
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 c3                	mov    %eax,%ebx
  802346:	72 08                	jb     802350 <__umoddi3+0x110>
  802348:	75 11                	jne    80235b <__umoddi3+0x11b>
  80234a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80234e:	73 0b                	jae    80235b <__umoddi3+0x11b>
  802350:	2b 44 24 04          	sub    0x4(%esp),%eax
  802354:	1b 14 24             	sbb    (%esp),%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80235f:	29 da                	sub    %ebx,%edx
  802361:	19 ce                	sbb    %ecx,%esi
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 f0                	mov    %esi,%eax
  802367:	d3 e0                	shl    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	d3 ee                	shr    %cl,%esi
  802371:	09 d0                	or     %edx,%eax
  802373:	89 f2                	mov    %esi,%edx
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	29 f9                	sub    %edi,%ecx
  802382:	19 d6                	sbb    %edx,%esi
  802384:	89 74 24 04          	mov    %esi,0x4(%esp)
  802388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238c:	e9 18 ff ff ff       	jmp    8022a9 <__umoddi3+0x69>
