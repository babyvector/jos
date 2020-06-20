
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 c0 	movl   $0x8024c0,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 e7 1c 00 00       	call   801d35 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 cc 24 80 00       	push   $0x8024cc
  80005d:	6a 0e                	push   $0xe
  80005f:	68 d5 24 80 00       	push   $0x8024d5
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 f8 10 00 00       	call   801166 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 e5 24 80 00       	push   $0x8024e5
  80007a:	6a 11                	push   $0x11
  80007c:	68 d5 24 80 00       	push   $0x8024d5
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ee 24 80 00       	push   $0x8024ee
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 49 14 00 00       	call   8014fb <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 0b 25 80 00       	push   $0x80250b
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 ec 15 00 00       	call   8016c8 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 28 25 80 00       	push   $0x802528
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 d5 24 80 00       	push   $0x8024d5
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 56 09 00 00       	call   800a64 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 31 25 80 00       	push   $0x802531
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 4d 25 80 00       	push   $0x80254d
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ee 24 80 00       	push   $0x8024ee
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 91 13 00 00       	call   8014fb <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 60 25 80 00       	push   $0x802560
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 f0 07 00 00       	call   800981 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 6e 15 00 00       	call   801711 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 ce 07 00 00       	call   800981 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 7d 25 80 00       	push   $0x80257d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 d5 24 80 00       	push   $0x8024d5
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 24 13 00 00       	call   8014fb <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 d8 1c 00 00       	call   801ebb <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 87 	movl   $0x802587,0x803004
  8001ea:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 3d 1b 00 00       	call   801d35 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 cc 24 80 00       	push   $0x8024cc
  800207:	6a 2c                	push   $0x2c
  800209:	68 d5 24 80 00       	push   $0x8024d5
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 4e 0f 00 00       	call   801166 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 e5 24 80 00       	push   $0x8024e5
  800224:	6a 2f                	push   $0x2f
  800226:	68 d5 24 80 00       	push   $0x8024d5
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 bc 12 00 00       	call   8014fb <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 f0 29 80 00       	push   $0x8029f0
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 94 25 80 00       	push   $0x802594
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 b0 14 00 00       	call   801711 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 96 25 80 00       	push   $0x802596
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 72 12 00 00       	call   8014fb <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 67 12 00 00       	call   8014fb <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 1f 1c 00 00       	call   801ebb <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 b3 25 80 00 	movl   $0x8025b3,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 bd 0a 00 00       	call   800d7f <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 23 12 00 00       	call   801526 <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 31 0a 00 00       	call   800d3e <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 5a 0a 00 00       	call   800d7f <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 18 26 80 00       	push   $0x802618
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 43 2a 80 00 	movl   $0x802a43,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 79 09 00 00       	call   800d01 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 54 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 1e 09 00 00       	call   800d01 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 dd 1d 00 00       	call   802230 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 ca 1e 00 00       	call   802360 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 3b 26 80 00 	movsbl 0x80263b(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b1:	83 fa 01             	cmp    $0x1,%edx
  8004b4:	7e 0e                	jle    8004c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	8b 52 04             	mov    0x4(%edx),%edx
  8004c2:	eb 22                	jmp    8004e6 <getuint+0x38>
	else if (lflag)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 10                	je     8004d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
	va_end(ap);
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 2c             	sub    $0x2c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	eb 12                	jmp    800548 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 d3 03 00 00    	je     800911 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	50                   	push   %eax
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e2                	jne    800536 <vprintfmt+0x14>
  800554:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800566:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056d:	ba 00 00 00 00       	mov    $0x0,%edx
  800572:	eb 07                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800577:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8d 47 01             	lea    0x1(%edi),%eax
  80057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800581:	0f b6 07             	movzbl (%edi),%eax
  800584:	0f b6 c8             	movzbl %al,%ecx
  800587:	83 e8 23             	sub    $0x23,%eax
  80058a:	3c 55                	cmp    $0x55,%al
  80058c:	0f 87 64 03 00 00    	ja     8008f6 <vprintfmt+0x3d4>
  800592:	0f b6 c0             	movzbl %al,%eax
  800595:	ff 24 85 80 27 80 00 	jmp    *0x802780(,%eax,4)
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a3:	eb d6                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ba:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bd:	83 fa 09             	cmp    $0x9,%edx
  8005c0:	77 39                	ja     8005fb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c5:	eb e9                	jmp    8005b0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d8:	eb 27                	jmp    800601 <vprintfmt+0xdf>
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	0f 49 c8             	cmovns %eax,%ecx
  8005e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	eb 8c                	jmp    80057b <vprintfmt+0x59>
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f9:	eb 80                	jmp    80057b <vprintfmt+0x59>
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 89 70 ff ff ff    	jns    80057b <vprintfmt+0x59>
				width = precision, precision = -1;
  80060b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80060e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800611:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800618:	e9 5e ff ff ff       	jmp    80057b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800623:	e9 53 ff ff ff       	jmp    80057b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	ff 30                	pushl  (%eax)
  800637:	ff d6                	call   *%esi
			break;
  800639:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063f:	e9 04 ff ff ff       	jmp    800548 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	99                   	cltd   
  800650:	31 d0                	xor    %edx,%eax
  800652:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800654:	83 f8 0f             	cmp    $0xf,%eax
  800657:	7f 0b                	jg     800664 <vprintfmt+0x142>
  800659:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 53 26 80 00       	push   $0x802653
  80066a:	53                   	push   %ebx
  80066b:	56                   	push   %esi
  80066c:	e8 94 fe ff ff       	call   800505 <printfmt>
  800671:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800677:	e9 cc fe ff ff       	jmp    800548 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067c:	52                   	push   %edx
  80067d:	68 89 2b 80 00       	push   $0x802b89
  800682:	53                   	push   %ebx
  800683:	56                   	push   %esi
  800684:	e8 7c fe ff ff       	call   800505 <printfmt>
  800689:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068f:	e9 b4 fe ff ff       	jmp    800548 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069f:	85 ff                	test   %edi,%edi
  8006a1:	b8 4c 26 80 00       	mov    $0x80264c,%eax
  8006a6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	0f 8e 94 00 00 00    	jle    800747 <vprintfmt+0x225>
  8006b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b7:	0f 84 98 00 00 00    	je     800755 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 c8             	pushl  -0x38(%ebp)
  8006c3:	57                   	push   %edi
  8006c4:	e8 d0 02 00 00       	call   800999 <strnlen>
  8006c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cc:	29 c1                	sub    %eax,%ecx
  8006ce:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	eb 0f                	jmp    8006f1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 ff                	test   %edi,%edi
  8006f3:	7f ed                	jg     8006e2 <vprintfmt+0x1c0>
  8006f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	0f 49 c1             	cmovns %ecx,%eax
  800705:	29 c1                	sub    %eax,%ecx
  800707:	89 75 08             	mov    %esi,0x8(%ebp)
  80070a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80070d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800710:	89 cb                	mov    %ecx,%ebx
  800712:	eb 4d                	jmp    800761 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	74 1b                	je     800735 <vprintfmt+0x213>
  80071a:	0f be c0             	movsbl %al,%eax
  80071d:	83 e8 20             	sub    $0x20,%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 10                	jbe    800735 <vprintfmt+0x213>
					putch('?', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff 55 08             	call   *0x8(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	52                   	push   %edx
  80073c:	ff 55 08             	call   *0x8(%ebp)
  80073f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	83 eb 01             	sub    $0x1,%ebx
  800745:	eb 1a                	jmp    800761 <vprintfmt+0x23f>
  800747:	89 75 08             	mov    %esi,0x8(%ebp)
  80074a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80074d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800750:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800753:	eb 0c                	jmp    800761 <vprintfmt+0x23f>
  800755:	89 75 08             	mov    %esi,0x8(%ebp)
  800758:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80075b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800761:	83 c7 01             	add    $0x1,%edi
  800764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800768:	0f be d0             	movsbl %al,%edx
  80076b:	85 d2                	test   %edx,%edx
  80076d:	74 23                	je     800792 <vprintfmt+0x270>
  80076f:	85 f6                	test   %esi,%esi
  800771:	78 a1                	js     800714 <vprintfmt+0x1f2>
  800773:	83 ee 01             	sub    $0x1,%esi
  800776:	79 9c                	jns    800714 <vprintfmt+0x1f2>
  800778:	89 df                	mov    %ebx,%edi
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	eb 18                	jmp    80079a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 20                	push   $0x20
  800788:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 08                	jmp    80079a <vprintfmt+0x278>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	85 ff                	test   %edi,%edi
  80079c:	7f e4                	jg     800782 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a1:	e9 a2 fd ff ff       	jmp    800548 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a6:	83 fa 01             	cmp    $0x1,%edx
  8007a9:	7e 16                	jle    8007c1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 08             	lea    0x8(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 50 04             	mov    0x4(%eax),%edx
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007bc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007bf:	eb 32                	jmp    8007f3 <vprintfmt+0x2d1>
	else if (lflag)
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	74 18                	je     8007dd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 04             	lea    0x4(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007d3:	89 c1                	mov    %eax,%ecx
  8007d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007db:	eb 16                	jmp    8007f3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007f6:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ff:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800804:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800808:	0f 89 b0 00 00 00    	jns    8008be <vprintfmt+0x39c>
				putch('-', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	53                   	push   %ebx
  800812:	6a 2d                	push   $0x2d
  800814:	ff d6                	call   *%esi
				num = -(long long) num;
  800816:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800819:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80081c:	f7 d8                	neg    %eax
  80081e:	83 d2 00             	adc    $0x0,%edx
  800821:	f7 da                	neg    %edx
  800823:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800826:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800829:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800831:	e9 88 00 00 00       	jmp    8008be <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800836:	8d 45 14             	lea    0x14(%ebp),%eax
  800839:	e8 70 fc ff ff       	call   8004ae <getuint>
  80083e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800841:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800844:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800849:	eb 73                	jmp    8008be <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80084b:	8d 45 14             	lea    0x14(%ebp),%eax
  80084e:	e8 5b fc ff ff       	call   8004ae <getuint>
  800853:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800856:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	53                   	push   %ebx
  80085d:	6a 58                	push   $0x58
  80085f:	ff d6                	call   *%esi
			putch('X', putdat);
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	53                   	push   %ebx
  800865:	6a 58                	push   $0x58
  800867:	ff d6                	call   *%esi
			putch('X', putdat);
  800869:	83 c4 08             	add    $0x8,%esp
  80086c:	53                   	push   %ebx
  80086d:	6a 58                	push   $0x58
  80086f:	ff d6                	call   *%esi
			goto number;
  800871:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800874:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800879:	eb 43                	jmp    8008be <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	53                   	push   %ebx
  80087f:	6a 30                	push   $0x30
  800881:	ff d6                	call   *%esi
			putch('x', putdat);
  800883:	83 c4 08             	add    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 78                	push   $0x78
  800889:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088b:	8b 45 14             	mov    0x14(%ebp),%eax
  80088e:	8d 50 04             	lea    0x4(%eax),%edx
  800891:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800894:	8b 00                	mov    (%eax),%eax
  800896:	ba 00 00 00 00       	mov    $0x0,%edx
  80089b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089e:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008a1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008a9:	eb 13                	jmp    8008be <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ae:	e8 fb fb ff ff       	call   8004ae <getuint>
  8008b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008b9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008be:	83 ec 0c             	sub    $0xc,%esp
  8008c1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008c5:	52                   	push   %edx
  8008c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c9:	50                   	push   %eax
  8008ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8008cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8008d0:	89 da                	mov    %ebx,%edx
  8008d2:	89 f0                	mov    %esi,%eax
  8008d4:	e8 26 fb ff ff       	call   8003ff <printnum>
			break;
  8008d9:	83 c4 20             	add    $0x20,%esp
  8008dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008df:	e9 64 fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	53                   	push   %ebx
  8008e8:	51                   	push   %ecx
  8008e9:	ff d6                	call   *%esi
			break;
  8008eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008f1:	e9 52 fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	6a 25                	push   $0x25
  8008fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	eb 03                	jmp    800906 <vprintfmt+0x3e4>
  800903:	83 ef 01             	sub    $0x1,%edi
  800906:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80090a:	75 f7                	jne    800903 <vprintfmt+0x3e1>
  80090c:	e9 37 fc ff ff       	jmp    800548 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800911:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	83 ec 18             	sub    $0x18,%esp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800925:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800928:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800936:	85 c0                	test   %eax,%eax
  800938:	74 26                	je     800960 <vsnprintf+0x47>
  80093a:	85 d2                	test   %edx,%edx
  80093c:	7e 22                	jle    800960 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093e:	ff 75 14             	pushl  0x14(%ebp)
  800941:	ff 75 10             	pushl  0x10(%ebp)
  800944:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800947:	50                   	push   %eax
  800948:	68 e8 04 80 00       	push   $0x8004e8
  80094d:	e8 d0 fb ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800952:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800955:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095b:	83 c4 10             	add    $0x10,%esp
  80095e:	eb 05                	jmp    800965 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800960:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800970:	50                   	push   %eax
  800971:	ff 75 10             	pushl  0x10(%ebp)
  800974:	ff 75 0c             	pushl  0xc(%ebp)
  800977:	ff 75 08             	pushl  0x8(%ebp)
  80097a:	e8 9a ff ff ff       	call   800919 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
  80098c:	eb 03                	jmp    800991 <strlen+0x10>
		n++;
  80098e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800991:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800995:	75 f7                	jne    80098e <strlen+0xd>
		n++;
	return n;
}
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	eb 03                	jmp    8009ac <strnlen+0x13>
		n++;
  8009a9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ac:	39 c2                	cmp    %eax,%edx
  8009ae:	74 08                	je     8009b8 <strnlen+0x1f>
  8009b0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009b4:	75 f3                	jne    8009a9 <strnlen+0x10>
  8009b6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c4:	89 c2                	mov    %eax,%edx
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009d0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d3:	84 db                	test   %bl,%bl
  8009d5:	75 ef                	jne    8009c6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e1:	53                   	push   %ebx
  8009e2:	e8 9a ff ff ff       	call   800981 <strlen>
  8009e7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009ea:	ff 75 0c             	pushl  0xc(%ebp)
  8009ed:	01 d8                	add    %ebx,%eax
  8009ef:	50                   	push   %eax
  8009f0:	e8 c5 ff ff ff       	call   8009ba <strcpy>
	return dst;
}
  8009f5:	89 d8                	mov    %ebx,%eax
  8009f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	8b 75 08             	mov    0x8(%ebp),%esi
  800a04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a07:	89 f3                	mov    %esi,%ebx
  800a09:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0c:	89 f2                	mov    %esi,%edx
  800a0e:	eb 0f                	jmp    800a1f <strncpy+0x23>
		*dst++ = *src;
  800a10:	83 c2 01             	add    $0x1,%edx
  800a13:	0f b6 01             	movzbl (%ecx),%eax
  800a16:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a19:	80 39 01             	cmpb   $0x1,(%ecx)
  800a1c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1f:	39 da                	cmp    %ebx,%edx
  800a21:	75 ed                	jne    800a10 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a23:	89 f0                	mov    %esi,%eax
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a34:	8b 55 10             	mov    0x10(%ebp),%edx
  800a37:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a39:	85 d2                	test   %edx,%edx
  800a3b:	74 21                	je     800a5e <strlcpy+0x35>
  800a3d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a41:	89 f2                	mov    %esi,%edx
  800a43:	eb 09                	jmp    800a4e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a45:	83 c2 01             	add    $0x1,%edx
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a4e:	39 c2                	cmp    %eax,%edx
  800a50:	74 09                	je     800a5b <strlcpy+0x32>
  800a52:	0f b6 19             	movzbl (%ecx),%ebx
  800a55:	84 db                	test   %bl,%bl
  800a57:	75 ec                	jne    800a45 <strlcpy+0x1c>
  800a59:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a5b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5e:	29 f0                	sub    %esi,%eax
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6d:	eb 06                	jmp    800a75 <strcmp+0x11>
		p++, q++;
  800a6f:	83 c1 01             	add    $0x1,%ecx
  800a72:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a75:	0f b6 01             	movzbl (%ecx),%eax
  800a78:	84 c0                	test   %al,%al
  800a7a:	74 04                	je     800a80 <strcmp+0x1c>
  800a7c:	3a 02                	cmp    (%edx),%al
  800a7e:	74 ef                	je     800a6f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a80:	0f b6 c0             	movzbl %al,%eax
  800a83:	0f b6 12             	movzbl (%edx),%edx
  800a86:	29 d0                	sub    %edx,%eax
}
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	53                   	push   %ebx
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a94:	89 c3                	mov    %eax,%ebx
  800a96:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a99:	eb 06                	jmp    800aa1 <strncmp+0x17>
		n--, p++, q++;
  800a9b:	83 c0 01             	add    $0x1,%eax
  800a9e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa1:	39 d8                	cmp    %ebx,%eax
  800aa3:	74 15                	je     800aba <strncmp+0x30>
  800aa5:	0f b6 08             	movzbl (%eax),%ecx
  800aa8:	84 c9                	test   %cl,%cl
  800aaa:	74 04                	je     800ab0 <strncmp+0x26>
  800aac:	3a 0a                	cmp    (%edx),%cl
  800aae:	74 eb                	je     800a9b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab0:	0f b6 00             	movzbl (%eax),%eax
  800ab3:	0f b6 12             	movzbl (%edx),%edx
  800ab6:	29 d0                	sub    %edx,%eax
  800ab8:	eb 05                	jmp    800abf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acc:	eb 07                	jmp    800ad5 <strchr+0x13>
		if (*s == c)
  800ace:	38 ca                	cmp    %cl,%dl
  800ad0:	74 0f                	je     800ae1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	0f b6 10             	movzbl (%eax),%edx
  800ad8:	84 d2                	test   %dl,%dl
  800ada:	75 f2                	jne    800ace <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aed:	eb 03                	jmp    800af2 <strfind+0xf>
  800aef:	83 c0 01             	add    $0x1,%eax
  800af2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af5:	38 ca                	cmp    %cl,%dl
  800af7:	74 04                	je     800afd <strfind+0x1a>
  800af9:	84 d2                	test   %dl,%dl
  800afb:	75 f2                	jne    800aef <strfind+0xc>
			break;
	return (char *) s;
}
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b0b:	85 c9                	test   %ecx,%ecx
  800b0d:	74 36                	je     800b45 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b15:	75 28                	jne    800b3f <memset+0x40>
  800b17:	f6 c1 03             	test   $0x3,%cl
  800b1a:	75 23                	jne    800b3f <memset+0x40>
		c &= 0xFF;
  800b1c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	c1 e3 08             	shl    $0x8,%ebx
  800b25:	89 d6                	mov    %edx,%esi
  800b27:	c1 e6 18             	shl    $0x18,%esi
  800b2a:	89 d0                	mov    %edx,%eax
  800b2c:	c1 e0 10             	shl    $0x10,%eax
  800b2f:	09 f0                	or     %esi,%eax
  800b31:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b33:	89 d8                	mov    %ebx,%eax
  800b35:	09 d0                	or     %edx,%eax
  800b37:	c1 e9 02             	shr    $0x2,%ecx
  800b3a:	fc                   	cld    
  800b3b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3d:	eb 06                	jmp    800b45 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	fc                   	cld    
  800b43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b45:	89 f8                	mov    %edi,%eax
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5a:	39 c6                	cmp    %eax,%esi
  800b5c:	73 35                	jae    800b93 <memmove+0x47>
  800b5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b61:	39 d0                	cmp    %edx,%eax
  800b63:	73 2e                	jae    800b93 <memmove+0x47>
		s += n;
		d += n;
  800b65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	09 fe                	or     %edi,%esi
  800b6c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b72:	75 13                	jne    800b87 <memmove+0x3b>
  800b74:	f6 c1 03             	test   $0x3,%cl
  800b77:	75 0e                	jne    800b87 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b79:	83 ef 04             	sub    $0x4,%edi
  800b7c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7f:	c1 e9 02             	shr    $0x2,%ecx
  800b82:	fd                   	std    
  800b83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b85:	eb 09                	jmp    800b90 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b87:	83 ef 01             	sub    $0x1,%edi
  800b8a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b8d:	fd                   	std    
  800b8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b90:	fc                   	cld    
  800b91:	eb 1d                	jmp    800bb0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b93:	89 f2                	mov    %esi,%edx
  800b95:	09 c2                	or     %eax,%edx
  800b97:	f6 c2 03             	test   $0x3,%dl
  800b9a:	75 0f                	jne    800bab <memmove+0x5f>
  800b9c:	f6 c1 03             	test   $0x3,%cl
  800b9f:	75 0a                	jne    800bab <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ba1:	c1 e9 02             	shr    $0x2,%ecx
  800ba4:	89 c7                	mov    %eax,%edi
  800ba6:	fc                   	cld    
  800ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba9:	eb 05                	jmp    800bb0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bab:	89 c7                	mov    %eax,%edi
  800bad:	fc                   	cld    
  800bae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bb7:	ff 75 10             	pushl  0x10(%ebp)
  800bba:	ff 75 0c             	pushl  0xc(%ebp)
  800bbd:	ff 75 08             	pushl  0x8(%ebp)
  800bc0:	e8 87 ff ff ff       	call   800b4c <memmove>
}
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd7:	eb 1a                	jmp    800bf3 <memcmp+0x2c>
		if (*s1 != *s2)
  800bd9:	0f b6 08             	movzbl (%eax),%ecx
  800bdc:	0f b6 1a             	movzbl (%edx),%ebx
  800bdf:	38 d9                	cmp    %bl,%cl
  800be1:	74 0a                	je     800bed <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be3:	0f b6 c1             	movzbl %cl,%eax
  800be6:	0f b6 db             	movzbl %bl,%ebx
  800be9:	29 d8                	sub    %ebx,%eax
  800beb:	eb 0f                	jmp    800bfc <memcmp+0x35>
		s1++, s2++;
  800bed:	83 c0 01             	add    $0x1,%eax
  800bf0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf3:	39 f0                	cmp    %esi,%eax
  800bf5:	75 e2                	jne    800bd9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	53                   	push   %ebx
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c07:	89 c1                	mov    %eax,%ecx
  800c09:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c10:	eb 0a                	jmp    800c1c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c12:	0f b6 10             	movzbl (%eax),%edx
  800c15:	39 da                	cmp    %ebx,%edx
  800c17:	74 07                	je     800c20 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c19:	83 c0 01             	add    $0x1,%eax
  800c1c:	39 c8                	cmp    %ecx,%eax
  800c1e:	72 f2                	jb     800c12 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c20:	5b                   	pop    %ebx
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2f:	eb 03                	jmp    800c34 <strtol+0x11>
		s++;
  800c31:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c34:	0f b6 01             	movzbl (%ecx),%eax
  800c37:	3c 20                	cmp    $0x20,%al
  800c39:	74 f6                	je     800c31 <strtol+0xe>
  800c3b:	3c 09                	cmp    $0x9,%al
  800c3d:	74 f2                	je     800c31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3f:	3c 2b                	cmp    $0x2b,%al
  800c41:	75 0a                	jne    800c4d <strtol+0x2a>
		s++;
  800c43:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c46:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4b:	eb 11                	jmp    800c5e <strtol+0x3b>
  800c4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c52:	3c 2d                	cmp    $0x2d,%al
  800c54:	75 08                	jne    800c5e <strtol+0x3b>
		s++, neg = 1;
  800c56:	83 c1 01             	add    $0x1,%ecx
  800c59:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c64:	75 15                	jne    800c7b <strtol+0x58>
  800c66:	80 39 30             	cmpb   $0x30,(%ecx)
  800c69:	75 10                	jne    800c7b <strtol+0x58>
  800c6b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c6f:	75 7c                	jne    800ced <strtol+0xca>
		s += 2, base = 16;
  800c71:	83 c1 02             	add    $0x2,%ecx
  800c74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c79:	eb 16                	jmp    800c91 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c7b:	85 db                	test   %ebx,%ebx
  800c7d:	75 12                	jne    800c91 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c7f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c84:	80 39 30             	cmpb   $0x30,(%ecx)
  800c87:	75 08                	jne    800c91 <strtol+0x6e>
		s++, base = 8;
  800c89:	83 c1 01             	add    $0x1,%ecx
  800c8c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c91:	b8 00 00 00 00       	mov    $0x0,%eax
  800c96:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c99:	0f b6 11             	movzbl (%ecx),%edx
  800c9c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c9f:	89 f3                	mov    %esi,%ebx
  800ca1:	80 fb 09             	cmp    $0x9,%bl
  800ca4:	77 08                	ja     800cae <strtol+0x8b>
			dig = *s - '0';
  800ca6:	0f be d2             	movsbl %dl,%edx
  800ca9:	83 ea 30             	sub    $0x30,%edx
  800cac:	eb 22                	jmp    800cd0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	80 fb 19             	cmp    $0x19,%bl
  800cb6:	77 08                	ja     800cc0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb8:	0f be d2             	movsbl %dl,%edx
  800cbb:	83 ea 57             	sub    $0x57,%edx
  800cbe:	eb 10                	jmp    800cd0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cc0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 19             	cmp    $0x19,%bl
  800cc8:	77 16                	ja     800ce0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cca:	0f be d2             	movsbl %dl,%edx
  800ccd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cd0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cd3:	7d 0b                	jge    800ce0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cd5:	83 c1 01             	add    $0x1,%ecx
  800cd8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cdc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cde:	eb b9                	jmp    800c99 <strtol+0x76>

	if (endptr)
  800ce0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce4:	74 0d                	je     800cf3 <strtol+0xd0>
		*endptr = (char *) s;
  800ce6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce9:	89 0e                	mov    %ecx,(%esi)
  800ceb:	eb 06                	jmp    800cf3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ced:	85 db                	test   %ebx,%ebx
  800cef:	74 98                	je     800c89 <strtol+0x66>
  800cf1:	eb 9e                	jmp    800c91 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cf3:	89 c2                	mov    %eax,%edx
  800cf5:	f7 da                	neg    %edx
  800cf7:	85 ff                	test   %edi,%edi
  800cf9:	0f 45 c2             	cmovne %edx,%eax
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800d07:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 c3                	mov    %eax,%ebx
  800d14:	89 c7                	mov    %eax,%edi
  800d16:	89 c6                	mov    %eax,%esi
  800d18:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2f:	89 d1                	mov    %edx,%ecx
  800d31:	89 d3                	mov    %edx,%ebx
  800d33:	89 d7                	mov    %edx,%edi
  800d35:	89 d6                	mov    %edx,%esi
  800d37:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	89 cb                	mov    %ecx,%ebx
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	89 ce                	mov    %ecx,%esi
  800d5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 17                	jle    800d77 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 03                	push   $0x3
  800d66:	68 3f 29 80 00       	push   $0x80293f
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 5c 29 80 00       	push   $0x80295c
  800d72:	e8 9b f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 d3                	mov    %edx,%ebx
  800d93:	89 d7                	mov    %edx,%edi
  800d95:	89 d6                	mov    %edx,%esi
  800d97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_yield>:

void
sys_yield(void)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800da4:	ba 00 00 00 00       	mov    $0x0,%edx
  800da9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dae:	89 d1                	mov    %edx,%ecx
  800db0:	89 d3                	mov    %edx,%ebx
  800db2:	89 d7                	mov    %edx,%edi
  800db4:	89 d6                	mov    %edx,%esi
  800db6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dc6:	be 00 00 00 00       	mov    $0x0,%esi
  800dcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd9:	89 f7                	mov    %esi,%edi
  800ddb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 04                	push   $0x4
  800de7:	68 3f 29 80 00       	push   $0x80293f
  800dec:	6a 23                	push   $0x23
  800dee:	68 5c 29 80 00       	push   $0x80295c
  800df3:	e8 1a f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e09:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1a:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 17                	jle    800e3a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 05                	push   $0x5
  800e29:	68 3f 29 80 00       	push   $0x80293f
  800e2e:	6a 23                	push   $0x23
  800e30:	68 5c 29 80 00       	push   $0x80295c
  800e35:	e8 d8 f4 ff ff       	call   800312 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e50:	b8 06 00 00 00       	mov    $0x6,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	89 df                	mov    %ebx,%edi
  800e5d:	89 de                	mov    %ebx,%esi
  800e5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7e 17                	jle    800e7c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e65:	83 ec 0c             	sub    $0xc,%esp
  800e68:	50                   	push   %eax
  800e69:	6a 06                	push   $0x6
  800e6b:	68 3f 29 80 00       	push   $0x80293f
  800e70:	6a 23                	push   $0x23
  800e72:	68 5c 29 80 00       	push   $0x80295c
  800e77:	e8 96 f4 ff ff       	call   800312 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e92:	b8 08 00 00 00       	mov    $0x8,%eax
  800e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	89 df                	mov    %ebx,%edi
  800e9f:	89 de                	mov    %ebx,%esi
  800ea1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	7e 17                	jle    800ebe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea7:	83 ec 0c             	sub    $0xc,%esp
  800eaa:	50                   	push   %eax
  800eab:	6a 08                	push   $0x8
  800ead:	68 3f 29 80 00       	push   $0x80293f
  800eb2:	6a 23                	push   $0x23
  800eb4:	68 5c 29 80 00       	push   $0x80295c
  800eb9:	e8 54 f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ecf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edc:	8b 55 08             	mov    0x8(%ebp),%edx
  800edf:	89 df                	mov    %ebx,%edi
  800ee1:	89 de                	mov    %ebx,%esi
  800ee3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 17                	jle    800f00 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	50                   	push   %eax
  800eed:	6a 09                	push   $0x9
  800eef:	68 3f 29 80 00       	push   $0x80293f
  800ef4:	6a 23                	push   $0x23
  800ef6:	68 5c 29 80 00       	push   $0x80295c
  800efb:	e8 12 f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f21:	89 df                	mov    %ebx,%edi
  800f23:	89 de                	mov    %ebx,%esi
  800f25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 17                	jle    800f42 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	50                   	push   %eax
  800f2f:	6a 0a                	push   $0xa
  800f31:	68 3f 29 80 00       	push   $0x80293f
  800f36:	6a 23                	push   $0x23
  800f38:	68 5c 29 80 00       	push   $0x80295c
  800f3d:	e8 d0 f3 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f50:	be 00 00 00 00       	mov    $0x0,%esi
  800f55:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f63:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f66:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 cb                	mov    %ecx,%ebx
  800f85:	89 cf                	mov    %ecx,%edi
  800f87:	89 ce                	mov    %ecx,%esi
  800f89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	7e 17                	jle    800fa6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	50                   	push   %eax
  800f93:	6a 0d                	push   $0xd
  800f95:	68 3f 29 80 00       	push   $0x80293f
  800f9a:	6a 23                	push   $0x23
  800f9c:	68 5c 29 80 00       	push   $0x80295c
  800fa1:	e8 6c f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fb6:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800fb8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fbc:	74 11                	je     800fcf <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800fbe:	89 d8                	mov    %ebx,%eax
  800fc0:	c1 e8 0c             	shr    $0xc,%eax
  800fc3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800fca:	f6 c4 08             	test   $0x8,%ah
  800fcd:	75 14                	jne    800fe3 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	68 6a 29 80 00       	push   $0x80296a
  800fd7:	6a 21                	push   $0x21
  800fd9:	68 80 29 80 00       	push   $0x802980
  800fde:	e8 2f f3 ff ff       	call   800312 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800fe3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800fe9:	e8 91 fd ff ff       	call   800d7f <sys_getenvid>
  800fee:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800ff0:	83 ec 04             	sub    $0x4,%esp
  800ff3:	6a 07                	push   $0x7
  800ff5:	68 00 f0 7f 00       	push   $0x7ff000
  800ffa:	50                   	push   %eax
  800ffb:	e8 bd fd ff ff       	call   800dbd <sys_page_alloc>
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	79 14                	jns    80101b <pgfault+0x6d>
		panic("sys_page_alloc");
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	68 8b 29 80 00       	push   $0x80298b
  80100f:	6a 30                	push   $0x30
  801011:	68 80 29 80 00       	push   $0x802980
  801016:	e8 f7 f2 ff ff       	call   800312 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  80101b:	83 ec 04             	sub    $0x4,%esp
  80101e:	68 00 10 00 00       	push   $0x1000
  801023:	53                   	push   %ebx
  801024:	68 00 f0 7f 00       	push   $0x7ff000
  801029:	e8 86 fb ff ff       	call   800bb4 <memcpy>
	retv = sys_page_unmap(envid, addr);
  80102e:	83 c4 08             	add    $0x8,%esp
  801031:	53                   	push   %ebx
  801032:	56                   	push   %esi
  801033:	e8 0a fe ff ff       	call   800e42 <sys_page_unmap>
	if(retv < 0){
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	79 12                	jns    801051 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  80103f:	50                   	push   %eax
  801040:	68 78 2a 80 00       	push   $0x802a78
  801045:	6a 35                	push   $0x35
  801047:	68 80 29 80 00       	push   $0x802980
  80104c:	e8 c1 f2 ff ff       	call   800312 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	6a 07                	push   $0x7
  801056:	53                   	push   %ebx
  801057:	56                   	push   %esi
  801058:	68 00 f0 7f 00       	push   $0x7ff000
  80105d:	56                   	push   %esi
  80105e:	e8 9d fd ff ff       	call   800e00 <sys_page_map>
	if(retv < 0){
  801063:	83 c4 20             	add    $0x20,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	79 14                	jns    80107e <pgfault+0xd0>
		panic("sys_page_map");
  80106a:	83 ec 04             	sub    $0x4,%esp
  80106d:	68 9a 29 80 00       	push   $0x80299a
  801072:	6a 39                	push   $0x39
  801074:	68 80 29 80 00       	push   $0x802980
  801079:	e8 94 f2 ff ff       	call   800312 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	68 00 f0 7f 00       	push   $0x7ff000
  801086:	56                   	push   %esi
  801087:	e8 b6 fd ff ff       	call   800e42 <sys_page_unmap>
	if(retv < 0){
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 14                	jns    8010a7 <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	68 a7 29 80 00       	push   $0x8029a7
  80109b:	6a 3d                	push   $0x3d
  80109d:	68 80 29 80 00       	push   $0x802980
  8010a2:	e8 6b f2 ff ff       	call   800312 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  8010a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	56                   	push   %esi
  8010b2:	53                   	push   %ebx
  8010b3:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  8010b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010b9:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	53                   	push   %ebx
  8010c0:	68 c4 29 80 00       	push   $0x8029c4
  8010c5:	e8 21 f3 ff ff       	call   8003eb <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  8010ca:	83 c4 0c             	add    $0xc,%esp
  8010cd:	6a 07                	push   $0x7
  8010cf:	53                   	push   %ebx
  8010d0:	56                   	push   %esi
  8010d1:	e8 e7 fc ff ff       	call   800dbd <sys_page_alloc>
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	79 15                	jns    8010f2 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  8010dd:	50                   	push   %eax
  8010de:	68 d7 29 80 00       	push   $0x8029d7
  8010e3:	68 90 00 00 00       	push   $0x90
  8010e8:	68 80 29 80 00       	push   $0x802980
  8010ed:	e8 20 f2 ff ff       	call   800312 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	68 ea 29 80 00       	push   $0x8029ea
  8010fa:	e8 ec f2 ff ff       	call   8003eb <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8010ff:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801106:	68 00 00 40 00       	push   $0x400000
  80110b:	6a 00                	push   $0x0
  80110d:	53                   	push   %ebx
  80110e:	56                   	push   %esi
  80110f:	e8 ec fc ff ff       	call   800e00 <sys_page_map>
  801114:	83 c4 20             	add    $0x20,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	79 15                	jns    801130 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  80111b:	50                   	push   %eax
  80111c:	68 f2 29 80 00       	push   $0x8029f2
  801121:	68 94 00 00 00       	push   $0x94
  801126:	68 80 29 80 00       	push   $0x802980
  80112b:	e8 e2 f1 ff ff       	call   800312 <_panic>
        cprintf("af_p_m.");
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	68 03 2a 80 00       	push   $0x802a03
  801138:	e8 ae f2 ff ff       	call   8003eb <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  80113d:	83 c4 0c             	add    $0xc,%esp
  801140:	68 00 10 00 00       	push   $0x1000
  801145:	53                   	push   %ebx
  801146:	68 00 00 40 00       	push   $0x400000
  80114b:	e8 fc f9 ff ff       	call   800b4c <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  801150:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  801157:	e8 8f f2 ff ff       	call   8003eb <cprintf>
}
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801162:	5b                   	pop    %ebx
  801163:	5e                   	pop    %esi
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
  80116c:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  80116f:	68 ae 0f 80 00       	push   $0x800fae
  801174:	e8 14 0f 00 00       	call   80208d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801179:	b8 07 00 00 00       	mov    $0x7,%eax
  80117e:	cd 30                	int    $0x30
  801180:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801183:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	79 17                	jns    8011a4 <fork+0x3e>
		panic("sys_exofork failed.");
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	68 19 2a 80 00       	push   $0x802a19
  801195:	68 b7 00 00 00       	push   $0xb7
  80119a:	68 80 29 80 00       	push   $0x802980
  80119f:	e8 6e f1 ff ff       	call   800312 <_panic>
  8011a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  8011a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011ad:	75 21                	jne    8011d0 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011af:	e8 cb fb ff ff       	call   800d7f <sys_getenvid>
  8011b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c1:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cb:	e9 69 01 00 00       	jmp    801339 <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8011d0:	89 d8                	mov    %ebx,%eax
  8011d2:	c1 e8 16             	shr    $0x16,%eax
  8011d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  8011dc:	a8 01                	test   $0x1,%al
  8011de:	0f 84 d6 00 00 00    	je     8012ba <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  8011e4:	89 de                	mov    %ebx,%esi
  8011e6:	c1 ee 0c             	shr    $0xc,%esi
  8011e9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8011f0:	a8 01                	test   $0x1,%al
  8011f2:	0f 84 c2 00 00 00    	je     8012ba <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  8011f8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  8011ff:	89 f7                	mov    %esi,%edi
  801201:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  801204:	e8 76 fb ff ff       	call   800d7f <sys_getenvid>
  801209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  80120c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801213:	f6 c4 04             	test   $0x4,%ah
  801216:	74 1c                	je     801234 <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  801218:	83 ec 0c             	sub    $0xc,%esp
  80121b:	68 07 0e 00 00       	push   $0xe07
  801220:	57                   	push   %edi
  801221:	ff 75 e0             	pushl  -0x20(%ebp)
  801224:	57                   	push   %edi
  801225:	6a 00                	push   $0x0
  801227:	e8 d4 fb ff ff       	call   800e00 <sys_page_map>
  80122c:	83 c4 20             	add    $0x20,%esp
  80122f:	e9 86 00 00 00       	jmp    8012ba <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  801234:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80123b:	a8 02                	test   $0x2,%al
  80123d:	75 0c                	jne    80124b <fork+0xe5>
  80123f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801246:	f6 c4 08             	test   $0x8,%ah
  801249:	74 5b                	je     8012a6 <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	68 05 08 00 00       	push   $0x805
  801253:	57                   	push   %edi
  801254:	ff 75 e0             	pushl  -0x20(%ebp)
  801257:	57                   	push   %edi
  801258:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125b:	e8 a0 fb ff ff       	call   800e00 <sys_page_map>
  801260:	83 c4 20             	add    $0x20,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	79 12                	jns    801279 <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  801267:	50                   	push   %eax
  801268:	68 9c 2a 80 00       	push   $0x802a9c
  80126d:	6a 5f                	push   $0x5f
  80126f:	68 80 29 80 00       	push   $0x802980
  801274:	e8 99 f0 ff ff       	call   800312 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  801279:	83 ec 0c             	sub    $0xc,%esp
  80127c:	68 05 08 00 00       	push   $0x805
  801281:	57                   	push   %edi
  801282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	57                   	push   %edi
  801287:	50                   	push   %eax
  801288:	e8 73 fb ff ff       	call   800e00 <sys_page_map>
  80128d:	83 c4 20             	add    $0x20,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	79 26                	jns    8012ba <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  801294:	50                   	push   %eax
  801295:	68 c0 2a 80 00       	push   $0x802ac0
  80129a:	6a 64                	push   $0x64
  80129c:	68 80 29 80 00       	push   $0x802980
  8012a1:	e8 6c f0 ff ff       	call   800312 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8012a6:	83 ec 0c             	sub    $0xc,%esp
  8012a9:	6a 05                	push   $0x5
  8012ab:	57                   	push   %edi
  8012ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8012af:	57                   	push   %edi
  8012b0:	6a 00                	push   $0x0
  8012b2:	e8 49 fb ff ff       	call   800e00 <sys_page_map>
  8012b7:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8012ba:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012c0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8012c6:	0f 85 04 ff ff ff    	jne    8011d0 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  8012cc:	83 ec 04             	sub    $0x4,%esp
  8012cf:	6a 07                	push   $0x7
  8012d1:	68 00 f0 bf ee       	push   $0xeebff000
  8012d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8012d9:	e8 df fa ff ff       	call   800dbd <sys_page_alloc>
	if(retv < 0){
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	79 17                	jns    8012fc <fork+0x196>
		panic("sys_page_alloc failed.\n");
  8012e5:	83 ec 04             	sub    $0x4,%esp
  8012e8:	68 2d 2a 80 00       	push   $0x802a2d
  8012ed:	68 cc 00 00 00       	push   $0xcc
  8012f2:	68 80 29 80 00       	push   $0x802980
  8012f7:	e8 16 f0 ff ff       	call   800312 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  8012fc:	83 ec 08             	sub    $0x8,%esp
  8012ff:	68 f2 20 80 00       	push   $0x8020f2
  801304:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801307:	57                   	push   %edi
  801308:	e8 fb fb ff ff       	call   800f08 <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  80130d:	83 c4 08             	add    $0x8,%esp
  801310:	6a 02                	push   $0x2
  801312:	57                   	push   %edi
  801313:	e8 6c fb ff ff       	call   800e84 <sys_env_set_status>
	if(retv < 0){
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	79 17                	jns    801336 <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  80131f:	83 ec 04             	sub    $0x4,%esp
  801322:	68 45 2a 80 00       	push   $0x802a45
  801327:	68 dd 00 00 00       	push   $0xdd
  80132c:	68 80 29 80 00       	push   $0x802980
  801331:	e8 dc ef ff ff       	call   800312 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  801336:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  801339:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5f                   	pop    %edi
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <sfork>:

// Challenge!
int
sfork(void)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801347:	68 61 2a 80 00       	push   $0x802a61
  80134c:	68 e8 00 00 00       	push   $0xe8
  801351:	68 80 29 80 00       	push   $0x802980
  801356:	e8 b7 ef ff ff       	call   800312 <_panic>

0080135b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80135e:	8b 45 08             	mov    0x8(%ebp),%eax
  801361:	05 00 00 00 30       	add    $0x30000000,%eax
  801366:	c1 e8 0c             	shr    $0xc,%eax
}
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	05 00 00 00 30       	add    $0x30000000,%eax
  801376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80137b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	c1 ea 16             	shr    $0x16,%edx
  801392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801399:	f6 c2 01             	test   $0x1,%dl
  80139c:	74 11                	je     8013af <fd_alloc+0x2d>
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	c1 ea 0c             	shr    $0xc,%edx
  8013a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013aa:	f6 c2 01             	test   $0x1,%dl
  8013ad:	75 09                	jne    8013b8 <fd_alloc+0x36>
			*fd_store = fd;
  8013af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b6:	eb 17                	jmp    8013cf <fd_alloc+0x4d>
  8013b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013c2:	75 c9                	jne    80138d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013cf:	5d                   	pop    %ebp
  8013d0:	c3                   	ret    

008013d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d7:	83 f8 1f             	cmp    $0x1f,%eax
  8013da:	77 36                	ja     801412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013dc:	c1 e0 0c             	shl    $0xc,%eax
  8013df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	c1 ea 16             	shr    $0x16,%edx
  8013e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f0:	f6 c2 01             	test   $0x1,%dl
  8013f3:	74 24                	je     801419 <fd_lookup+0x48>
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	c1 ea 0c             	shr    $0xc,%edx
  8013fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801401:	f6 c2 01             	test   $0x1,%dl
  801404:	74 1a                	je     801420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801406:	8b 55 0c             	mov    0xc(%ebp),%edx
  801409:	89 02                	mov    %eax,(%edx)
	return 0;
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
  801410:	eb 13                	jmp    801425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801417:	eb 0c                	jmp    801425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141e:	eb 05                	jmp    801425 <fd_lookup+0x54>
  801420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801430:	ba 60 2b 80 00       	mov    $0x802b60,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801435:	eb 13                	jmp    80144a <dev_lookup+0x23>
  801437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80143a:	39 08                	cmp    %ecx,(%eax)
  80143c:	75 0c                	jne    80144a <dev_lookup+0x23>
			*dev = devtab[i];
  80143e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801441:	89 01                	mov    %eax,(%ecx)
			return 0;
  801443:	b8 00 00 00 00       	mov    $0x0,%eax
  801448:	eb 2e                	jmp    801478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80144a:	8b 02                	mov    (%edx),%eax
  80144c:	85 c0                	test   %eax,%eax
  80144e:	75 e7                	jne    801437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801450:	a1 04 40 80 00       	mov    0x804004,%eax
  801455:	8b 40 48             	mov    0x48(%eax),%eax
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	51                   	push   %ecx
  80145c:	50                   	push   %eax
  80145d:	68 e4 2a 80 00       	push   $0x802ae4
  801462:	e8 84 ef ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	83 ec 10             	sub    $0x10,%esp
  801482:	8b 75 08             	mov    0x8(%ebp),%esi
  801485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801492:	c1 e8 0c             	shr    $0xc,%eax
  801495:	50                   	push   %eax
  801496:	e8 36 ff ff ff       	call   8013d1 <fd_lookup>
  80149b:	83 c4 08             	add    $0x8,%esp
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 05                	js     8014a7 <fd_close+0x2d>
	    || fd != fd2)
  8014a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014a5:	74 0c                	je     8014b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014a7:	84 db                	test   %bl,%bl
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	0f 44 c2             	cmove  %edx,%eax
  8014b1:	eb 41                	jmp    8014f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014b3:	83 ec 08             	sub    $0x8,%esp
  8014b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	ff 36                	pushl  (%esi)
  8014bc:	e8 66 ff ff ff       	call   801427 <dev_lookup>
  8014c1:	89 c3                	mov    %eax,%ebx
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 1a                	js     8014e4 <fd_close+0x6a>
		if (dev->dev_close)
  8014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	74 0b                	je     8014e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	56                   	push   %esi
  8014dd:	ff d0                	call   *%eax
  8014df:	89 c3                	mov    %eax,%ebx
  8014e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	56                   	push   %esi
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 53 f9 ff ff       	call   800e42 <sys_page_unmap>
	return r;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	89 d8                	mov    %ebx,%eax
}
  8014f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f7:	5b                   	pop    %ebx
  8014f8:	5e                   	pop    %esi
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	ff 75 08             	pushl  0x8(%ebp)
  801508:	e8 c4 fe ff ff       	call   8013d1 <fd_lookup>
  80150d:	83 c4 08             	add    $0x8,%esp
  801510:	85 c0                	test   %eax,%eax
  801512:	78 10                	js     801524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	6a 01                	push   $0x1
  801519:	ff 75 f4             	pushl  -0xc(%ebp)
  80151c:	e8 59 ff ff ff       	call   80147a <fd_close>
  801521:	83 c4 10             	add    $0x10,%esp
}
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <close_all>:

void
close_all(void)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	53                   	push   %ebx
  80152a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80152d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	53                   	push   %ebx
  801536:	e8 c0 ff ff ff       	call   8014fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80153b:	83 c3 01             	add    $0x1,%ebx
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	83 fb 20             	cmp    $0x20,%ebx
  801544:	75 ec                	jne    801532 <close_all+0xc>
		close(i);
}
  801546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	57                   	push   %edi
  80154f:	56                   	push   %esi
  801550:	53                   	push   %ebx
  801551:	83 ec 2c             	sub    $0x2c,%esp
  801554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	ff 75 08             	pushl  0x8(%ebp)
  80155e:	e8 6e fe ff ff       	call   8013d1 <fd_lookup>
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	0f 88 c1 00 00 00    	js     80162f <dup+0xe4>
		return r;
	close(newfdnum);
  80156e:	83 ec 0c             	sub    $0xc,%esp
  801571:	56                   	push   %esi
  801572:	e8 84 ff ff ff       	call   8014fb <close>

	newfd = INDEX2FD(newfdnum);
  801577:	89 f3                	mov    %esi,%ebx
  801579:	c1 e3 0c             	shl    $0xc,%ebx
  80157c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801582:	83 c4 04             	add    $0x4,%esp
  801585:	ff 75 e4             	pushl  -0x1c(%ebp)
  801588:	e8 de fd ff ff       	call   80136b <fd2data>
  80158d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80158f:	89 1c 24             	mov    %ebx,(%esp)
  801592:	e8 d4 fd ff ff       	call   80136b <fd2data>
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80159d:	89 f8                	mov    %edi,%eax
  80159f:	c1 e8 16             	shr    $0x16,%eax
  8015a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015a9:	a8 01                	test   $0x1,%al
  8015ab:	74 37                	je     8015e4 <dup+0x99>
  8015ad:	89 f8                	mov    %edi,%eax
  8015af:	c1 e8 0c             	shr    $0xc,%eax
  8015b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015b9:	f6 c2 01             	test   $0x1,%dl
  8015bc:	74 26                	je     8015e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8015cd:	50                   	push   %eax
  8015ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015d1:	6a 00                	push   $0x0
  8015d3:	57                   	push   %edi
  8015d4:	6a 00                	push   $0x0
  8015d6:	e8 25 f8 ff ff       	call   800e00 <sys_page_map>
  8015db:	89 c7                	mov    %eax,%edi
  8015dd:	83 c4 20             	add    $0x20,%esp
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 2e                	js     801612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015e7:	89 d0                	mov    %edx,%eax
  8015e9:	c1 e8 0c             	shr    $0xc,%eax
  8015ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8015fb:	50                   	push   %eax
  8015fc:	53                   	push   %ebx
  8015fd:	6a 00                	push   $0x0
  8015ff:	52                   	push   %edx
  801600:	6a 00                	push   $0x0
  801602:	e8 f9 f7 ff ff       	call   800e00 <sys_page_map>
  801607:	89 c7                	mov    %eax,%edi
  801609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80160c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80160e:	85 ff                	test   %edi,%edi
  801610:	79 1d                	jns    80162f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	53                   	push   %ebx
  801616:	6a 00                	push   $0x0
  801618:	e8 25 f8 ff ff       	call   800e42 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80161d:	83 c4 08             	add    $0x8,%esp
  801620:	ff 75 d4             	pushl  -0x2c(%ebp)
  801623:	6a 00                	push   $0x0
  801625:	e8 18 f8 ff ff       	call   800e42 <sys_page_unmap>
	return r;
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	89 f8                	mov    %edi,%eax
}
  80162f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801632:	5b                   	pop    %ebx
  801633:	5e                   	pop    %esi
  801634:	5f                   	pop    %edi
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 14             	sub    $0x14,%esp
  80163e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	53                   	push   %ebx
  801646:	e8 86 fd ff ff       	call   8013d1 <fd_lookup>
  80164b:	83 c4 08             	add    $0x8,%esp
  80164e:	89 c2                	mov    %eax,%edx
  801650:	85 c0                	test   %eax,%eax
  801652:	78 6d                	js     8016c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165e:	ff 30                	pushl  (%eax)
  801660:	e8 c2 fd ff ff       	call   801427 <dev_lookup>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 4c                	js     8016b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80166c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80166f:	8b 42 08             	mov    0x8(%edx),%eax
  801672:	83 e0 03             	and    $0x3,%eax
  801675:	83 f8 01             	cmp    $0x1,%eax
  801678:	75 21                	jne    80169b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80167a:	a1 04 40 80 00       	mov    0x804004,%eax
  80167f:	8b 40 48             	mov    0x48(%eax),%eax
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	53                   	push   %ebx
  801686:	50                   	push   %eax
  801687:	68 25 2b 80 00       	push   $0x802b25
  80168c:	e8 5a ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801699:	eb 26                	jmp    8016c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169e:	8b 40 08             	mov    0x8(%eax),%eax
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	74 17                	je     8016bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016a5:	83 ec 04             	sub    $0x4,%esp
  8016a8:	ff 75 10             	pushl  0x10(%ebp)
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	52                   	push   %edx
  8016af:	ff d0                	call   *%eax
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	eb 09                	jmp    8016c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	eb 05                	jmp    8016c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016c1:	89 d0                	mov    %edx,%eax
  8016c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	57                   	push   %edi
  8016cc:	56                   	push   %esi
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 0c             	sub    $0xc,%esp
  8016d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016dc:	eb 21                	jmp    8016ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016de:	83 ec 04             	sub    $0x4,%esp
  8016e1:	89 f0                	mov    %esi,%eax
  8016e3:	29 d8                	sub    %ebx,%eax
  8016e5:	50                   	push   %eax
  8016e6:	89 d8                	mov    %ebx,%eax
  8016e8:	03 45 0c             	add    0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	57                   	push   %edi
  8016ed:	e8 45 ff ff ff       	call   801637 <read>
		if (m < 0)
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 10                	js     801709 <readn+0x41>
			return m;
		if (m == 0)
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	74 0a                	je     801707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016fd:	01 c3                	add    %eax,%ebx
  8016ff:	39 f3                	cmp    %esi,%ebx
  801701:	72 db                	jb     8016de <readn+0x16>
  801703:	89 d8                	mov    %ebx,%eax
  801705:	eb 02                	jmp    801709 <readn+0x41>
  801707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170c:	5b                   	pop    %ebx
  80170d:	5e                   	pop    %esi
  80170e:	5f                   	pop    %edi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	53                   	push   %ebx
  801715:	83 ec 14             	sub    $0x14,%esp
  801718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	53                   	push   %ebx
  801720:	e8 ac fc ff ff       	call   8013d1 <fd_lookup>
  801725:	83 c4 08             	add    $0x8,%esp
  801728:	89 c2                	mov    %eax,%edx
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 68                	js     801796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	ff 30                	pushl  (%eax)
  80173a:	e8 e8 fc ff ff       	call   801427 <dev_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 47                	js     80178d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80174d:	75 21                	jne    801770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80174f:	a1 04 40 80 00       	mov    0x804004,%eax
  801754:	8b 40 48             	mov    0x48(%eax),%eax
  801757:	83 ec 04             	sub    $0x4,%esp
  80175a:	53                   	push   %ebx
  80175b:	50                   	push   %eax
  80175c:	68 41 2b 80 00       	push   $0x802b41
  801761:	e8 85 ec ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80176e:	eb 26                	jmp    801796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801773:	8b 52 0c             	mov    0xc(%edx),%edx
  801776:	85 d2                	test   %edx,%edx
  801778:	74 17                	je     801791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80177a:	83 ec 04             	sub    $0x4,%esp
  80177d:	ff 75 10             	pushl  0x10(%ebp)
  801780:	ff 75 0c             	pushl  0xc(%ebp)
  801783:	50                   	push   %eax
  801784:	ff d2                	call   *%edx
  801786:	89 c2                	mov    %eax,%edx
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	eb 09                	jmp    801796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178d:	89 c2                	mov    %eax,%edx
  80178f:	eb 05                	jmp    801796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801796:	89 d0                	mov    %edx,%eax
  801798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <seek>:

int
seek(int fdnum, off_t offset)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	ff 75 08             	pushl  0x8(%ebp)
  8017aa:	e8 22 fc ff ff       	call   8013d1 <fd_lookup>
  8017af:	83 c4 08             	add    $0x8,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 0e                	js     8017c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 14             	sub    $0x14,%esp
  8017cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d3:	50                   	push   %eax
  8017d4:	53                   	push   %ebx
  8017d5:	e8 f7 fb ff ff       	call   8013d1 <fd_lookup>
  8017da:	83 c4 08             	add    $0x8,%esp
  8017dd:	89 c2                	mov    %eax,%edx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 65                	js     801848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e9:	50                   	push   %eax
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	ff 30                	pushl  (%eax)
  8017ef:	e8 33 fc ff ff       	call   801427 <dev_lookup>
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 44                	js     80183f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801802:	75 21                	jne    801825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801809:	8b 40 48             	mov    0x48(%eax),%eax
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	53                   	push   %ebx
  801810:	50                   	push   %eax
  801811:	68 04 2b 80 00       	push   $0x802b04
  801816:	e8 d0 eb ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801823:	eb 23                	jmp    801848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801828:	8b 52 18             	mov    0x18(%edx),%edx
  80182b:	85 d2                	test   %edx,%edx
  80182d:	74 14                	je     801843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	ff 75 0c             	pushl  0xc(%ebp)
  801835:	50                   	push   %eax
  801836:	ff d2                	call   *%edx
  801838:	89 c2                	mov    %eax,%edx
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	eb 09                	jmp    801848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183f:	89 c2                	mov    %eax,%edx
  801841:	eb 05                	jmp    801848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801848:	89 d0                	mov    %edx,%eax
  80184a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	53                   	push   %ebx
  801853:	83 ec 14             	sub    $0x14,%esp
  801856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	ff 75 08             	pushl  0x8(%ebp)
  801860:	e8 6c fb ff ff       	call   8013d1 <fd_lookup>
  801865:	83 c4 08             	add    $0x8,%esp
  801868:	89 c2                	mov    %eax,%edx
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 58                	js     8018c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801874:	50                   	push   %eax
  801875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801878:	ff 30                	pushl  (%eax)
  80187a:	e8 a8 fb ff ff       	call   801427 <dev_lookup>
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	85 c0                	test   %eax,%eax
  801884:	78 37                	js     8018bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80188d:	74 32                	je     8018c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80188f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801899:	00 00 00 
	stat->st_isdir = 0;
  80189c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a3:	00 00 00 
	stat->st_dev = dev;
  8018a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018ac:	83 ec 08             	sub    $0x8,%esp
  8018af:	53                   	push   %ebx
  8018b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b3:	ff 50 14             	call   *0x14(%eax)
  8018b6:	89 c2                	mov    %eax,%edx
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	eb 09                	jmp    8018c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bd:	89 c2                	mov    %eax,%edx
  8018bf:	eb 05                	jmp    8018c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018c6:	89 d0                	mov    %edx,%eax
  8018c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	6a 00                	push   $0x0
  8018d7:	ff 75 08             	pushl  0x8(%ebp)
  8018da:	e8 dc 01 00 00       	call   801abb <open>
  8018df:	89 c3                	mov    %eax,%ebx
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 1b                	js     801903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018e8:	83 ec 08             	sub    $0x8,%esp
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	50                   	push   %eax
  8018ef:	e8 5b ff ff ff       	call   80184f <fstat>
  8018f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8018f6:	89 1c 24             	mov    %ebx,(%esp)
  8018f9:	e8 fd fb ff ff       	call   8014fb <close>
	return r;
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	89 f0                	mov    %esi,%eax
}
  801903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	56                   	push   %esi
  80190e:	53                   	push   %ebx
  80190f:	89 c6                	mov    %eax,%esi
  801911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80191a:	75 12                	jne    80192e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	6a 01                	push   $0x1
  801921:	e8 90 08 00 00       	call   8021b6 <ipc_find_env>
  801926:	a3 00 40 80 00       	mov    %eax,0x804000
  80192b:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80192e:	6a 07                	push   $0x7
  801930:	68 00 50 80 00       	push   $0x805000
  801935:	56                   	push   %esi
  801936:	ff 35 00 40 80 00    	pushl  0x804000
  80193c:	e8 32 08 00 00       	call   802173 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801941:	83 c4 0c             	add    $0xc,%esp
  801944:	6a 00                	push   $0x0
  801946:	53                   	push   %ebx
  801947:	6a 00                	push   $0x0
  801949:	e8 c8 07 00 00       	call   802116 <ipc_recv>
}
  80194e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801951:	5b                   	pop    %ebx
  801952:	5e                   	pop    %esi
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	8b 40 0c             	mov    0xc(%eax),%eax
  801961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801966:	8b 45 0c             	mov    0xc(%ebp),%eax
  801969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80196e:	ba 00 00 00 00       	mov    $0x0,%edx
  801973:	b8 02 00 00 00       	mov    $0x2,%eax
  801978:	e8 8d ff ff ff       	call   80190a <fsipc>
}
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	8b 40 0c             	mov    0xc(%eax),%eax
  80198b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801990:	ba 00 00 00 00       	mov    $0x0,%edx
  801995:	b8 06 00 00 00       	mov    $0x6,%eax
  80199a:	e8 6b ff ff ff       	call   80190a <fsipc>
}
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 04             	sub    $0x4,%esp
  8019a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8019c0:	e8 45 ff ff ff       	call   80190a <fsipc>
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 2c                	js     8019f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c9:	83 ec 08             	sub    $0x8,%esp
  8019cc:	68 00 50 80 00       	push   $0x805000
  8019d1:	53                   	push   %ebx
  8019d2:	e8 e3 ef ff ff       	call   8009ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8019dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 0c             	sub    $0xc,%esp
  801a00:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a03:	8b 55 08             	mov    0x8(%ebp),%edx
  801a06:	8b 52 0c             	mov    0xc(%edx),%edx
  801a09:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a0f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a14:	50                   	push   %eax
  801a15:	ff 75 0c             	pushl  0xc(%ebp)
  801a18:	68 08 50 80 00       	push   $0x805008
  801a1d:	e8 2a f1 ff ff       	call   800b4c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a22:	ba 00 00 00 00       	mov    $0x0,%edx
  801a27:	b8 04 00 00 00       	mov    $0x4,%eax
  801a2c:	e8 d9 fe ff ff       	call   80190a <fsipc>
	//panic("devfile_write not implemented");
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a46:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a51:	b8 03 00 00 00       	mov    $0x3,%eax
  801a56:	e8 af fe ff ff       	call   80190a <fsipc>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 51                	js     801ab2 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801a61:	39 c6                	cmp    %eax,%esi
  801a63:	73 19                	jae    801a7e <devfile_read+0x4b>
  801a65:	68 70 2b 80 00       	push   $0x802b70
  801a6a:	68 77 2b 80 00       	push   $0x802b77
  801a6f:	68 80 00 00 00       	push   $0x80
  801a74:	68 8c 2b 80 00       	push   $0x802b8c
  801a79:	e8 94 e8 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801a7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a83:	7e 19                	jle    801a9e <devfile_read+0x6b>
  801a85:	68 97 2b 80 00       	push   $0x802b97
  801a8a:	68 77 2b 80 00       	push   $0x802b77
  801a8f:	68 81 00 00 00       	push   $0x81
  801a94:	68 8c 2b 80 00       	push   $0x802b8c
  801a99:	e8 74 e8 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a9e:	83 ec 04             	sub    $0x4,%esp
  801aa1:	50                   	push   %eax
  801aa2:	68 00 50 80 00       	push   $0x805000
  801aa7:	ff 75 0c             	pushl  0xc(%ebp)
  801aaa:	e8 9d f0 ff ff       	call   800b4c <memmove>
	return r;
  801aaf:	83 c4 10             	add    $0x10,%esp
}
  801ab2:	89 d8                	mov    %ebx,%eax
  801ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	83 ec 20             	sub    $0x20,%esp
  801ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ac5:	53                   	push   %ebx
  801ac6:	e8 b6 ee ff ff       	call   800981 <strlen>
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ad3:	7f 67                	jg     801b3c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adb:	50                   	push   %eax
  801adc:	e8 a1 f8 ff ff       	call   801382 <fd_alloc>
  801ae1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	78 57                	js     801b41 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aea:	83 ec 08             	sub    $0x8,%esp
  801aed:	53                   	push   %ebx
  801aee:	68 00 50 80 00       	push   $0x805000
  801af3:	e8 c2 ee ff ff       	call   8009ba <strcpy>
	fsipcbuf.open.req_omode = mode;
  801af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afb:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b03:	b8 01 00 00 00       	mov    $0x1,%eax
  801b08:	e8 fd fd ff ff       	call   80190a <fsipc>
  801b0d:	89 c3                	mov    %eax,%ebx
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	79 14                	jns    801b2a <open+0x6f>
		
		fd_close(fd, 0);
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	6a 00                	push   $0x0
  801b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1e:	e8 57 f9 ff ff       	call   80147a <fd_close>
		return r;
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	89 da                	mov    %ebx,%edx
  801b28:	eb 17                	jmp    801b41 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b30:	e8 26 f8 ff ff       	call   80135b <fd2num>
  801b35:	89 c2                	mov    %eax,%edx
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	eb 05                	jmp    801b41 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b3c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801b41:	89 d0                	mov    %edx,%eax
  801b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b46:	c9                   	leave  
  801b47:	c3                   	ret    

00801b48 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b53:	b8 08 00 00 00       	mov    $0x8,%eax
  801b58:	e8 ad fd ff ff       	call   80190a <fsipc>
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 75 08             	pushl  0x8(%ebp)
  801b6d:	e8 f9 f7 ff ff       	call   80136b <fd2data>
  801b72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b74:	83 c4 08             	add    $0x8,%esp
  801b77:	68 a3 2b 80 00       	push   $0x802ba3
  801b7c:	53                   	push   %ebx
  801b7d:	e8 38 ee ff ff       	call   8009ba <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b82:	8b 46 04             	mov    0x4(%esi),%eax
  801b85:	2b 06                	sub    (%esi),%eax
  801b87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b8d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b94:	00 00 00 
	stat->st_dev = &devpipe;
  801b97:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b9e:	30 80 00 
	return 0;
}
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 0c             	sub    $0xc,%esp
  801bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bb7:	53                   	push   %ebx
  801bb8:	6a 00                	push   $0x0
  801bba:	e8 83 f2 ff ff       	call   800e42 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bbf:	89 1c 24             	mov    %ebx,(%esp)
  801bc2:	e8 a4 f7 ff ff       	call   80136b <fd2data>
  801bc7:	83 c4 08             	add    $0x8,%esp
  801bca:	50                   	push   %eax
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 70 f2 ff ff       	call   800e42 <sys_page_unmap>
}
  801bd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd5:	c9                   	leave  
  801bd6:	c3                   	ret    

00801bd7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	57                   	push   %edi
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 1c             	sub    $0x1c,%esp
  801be0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801be3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801be5:	a1 04 40 80 00       	mov    0x804004,%eax
  801bea:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	ff 75 e0             	pushl  -0x20(%ebp)
  801bf3:	e8 f7 05 00 00       	call   8021ef <pageref>
  801bf8:	89 c3                	mov    %eax,%ebx
  801bfa:	89 3c 24             	mov    %edi,(%esp)
  801bfd:	e8 ed 05 00 00       	call   8021ef <pageref>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	39 c3                	cmp    %eax,%ebx
  801c07:	0f 94 c1             	sete   %cl
  801c0a:	0f b6 c9             	movzbl %cl,%ecx
  801c0d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c10:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c16:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c19:	39 ce                	cmp    %ecx,%esi
  801c1b:	74 1b                	je     801c38 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c1d:	39 c3                	cmp    %eax,%ebx
  801c1f:	75 c4                	jne    801be5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c21:	8b 42 58             	mov    0x58(%edx),%eax
  801c24:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c27:	50                   	push   %eax
  801c28:	56                   	push   %esi
  801c29:	68 aa 2b 80 00       	push   $0x802baa
  801c2e:	e8 b8 e7 ff ff       	call   8003eb <cprintf>
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	eb ad                	jmp    801be5 <_pipeisclosed+0xe>
	}
}
  801c38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5f                   	pop    %edi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	57                   	push   %edi
  801c47:	56                   	push   %esi
  801c48:	53                   	push   %ebx
  801c49:	83 ec 28             	sub    $0x28,%esp
  801c4c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c4f:	56                   	push   %esi
  801c50:	e8 16 f7 ff ff       	call   80136b <fd2data>
  801c55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  801c5f:	eb 4b                	jmp    801cac <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c61:	89 da                	mov    %ebx,%edx
  801c63:	89 f0                	mov    %esi,%eax
  801c65:	e8 6d ff ff ff       	call   801bd7 <_pipeisclosed>
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	75 48                	jne    801cb6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c6e:	e8 2b f1 ff ff       	call   800d9e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c73:	8b 43 04             	mov    0x4(%ebx),%eax
  801c76:	8b 0b                	mov    (%ebx),%ecx
  801c78:	8d 51 20             	lea    0x20(%ecx),%edx
  801c7b:	39 d0                	cmp    %edx,%eax
  801c7d:	73 e2                	jae    801c61 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c82:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c86:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c89:	89 c2                	mov    %eax,%edx
  801c8b:	c1 fa 1f             	sar    $0x1f,%edx
  801c8e:	89 d1                	mov    %edx,%ecx
  801c90:	c1 e9 1b             	shr    $0x1b,%ecx
  801c93:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c96:	83 e2 1f             	and    $0x1f,%edx
  801c99:	29 ca                	sub    %ecx,%edx
  801c9b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c9f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca3:	83 c0 01             	add    $0x1,%eax
  801ca6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca9:	83 c7 01             	add    $0x1,%edi
  801cac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801caf:	75 c2                	jne    801c73 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb4:	eb 05                	jmp    801cbb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5e                   	pop    %esi
  801cc0:	5f                   	pop    %edi
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	57                   	push   %edi
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 18             	sub    $0x18,%esp
  801ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ccf:	57                   	push   %edi
  801cd0:	e8 96 f6 ff ff       	call   80136b <fd2data>
  801cd5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cdf:	eb 3d                	jmp    801d1e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ce1:	85 db                	test   %ebx,%ebx
  801ce3:	74 04                	je     801ce9 <devpipe_read+0x26>
				return i;
  801ce5:	89 d8                	mov    %ebx,%eax
  801ce7:	eb 44                	jmp    801d2d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ce9:	89 f2                	mov    %esi,%edx
  801ceb:	89 f8                	mov    %edi,%eax
  801ced:	e8 e5 fe ff ff       	call   801bd7 <_pipeisclosed>
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	75 32                	jne    801d28 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cf6:	e8 a3 f0 ff ff       	call   800d9e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cfb:	8b 06                	mov    (%esi),%eax
  801cfd:	3b 46 04             	cmp    0x4(%esi),%eax
  801d00:	74 df                	je     801ce1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d02:	99                   	cltd   
  801d03:	c1 ea 1b             	shr    $0x1b,%edx
  801d06:	01 d0                	add    %edx,%eax
  801d08:	83 e0 1f             	and    $0x1f,%eax
  801d0b:	29 d0                	sub    %edx,%eax
  801d0d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d15:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d18:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1b:	83 c3 01             	add    $0x1,%ebx
  801d1e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d21:	75 d8                	jne    801cfb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d23:	8b 45 10             	mov    0x10(%ebp),%eax
  801d26:	eb 05                	jmp    801d2d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    

00801d35 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	56                   	push   %esi
  801d39:	53                   	push   %ebx
  801d3a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d40:	50                   	push   %eax
  801d41:	e8 3c f6 ff ff       	call   801382 <fd_alloc>
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	89 c2                	mov    %eax,%edx
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	0f 88 2c 01 00 00    	js     801e7f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d53:	83 ec 04             	sub    $0x4,%esp
  801d56:	68 07 04 00 00       	push   $0x407
  801d5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5e:	6a 00                	push   $0x0
  801d60:	e8 58 f0 ff ff       	call   800dbd <sys_page_alloc>
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	89 c2                	mov    %eax,%edx
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	0f 88 0d 01 00 00    	js     801e7f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d72:	83 ec 0c             	sub    $0xc,%esp
  801d75:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	e8 04 f6 ff ff       	call   801382 <fd_alloc>
  801d7e:	89 c3                	mov    %eax,%ebx
  801d80:	83 c4 10             	add    $0x10,%esp
  801d83:	85 c0                	test   %eax,%eax
  801d85:	0f 88 e2 00 00 00    	js     801e6d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8b:	83 ec 04             	sub    $0x4,%esp
  801d8e:	68 07 04 00 00       	push   $0x407
  801d93:	ff 75 f0             	pushl  -0x10(%ebp)
  801d96:	6a 00                	push   $0x0
  801d98:	e8 20 f0 ff ff       	call   800dbd <sys_page_alloc>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	85 c0                	test   %eax,%eax
  801da4:	0f 88 c3 00 00 00    	js     801e6d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	ff 75 f4             	pushl  -0xc(%ebp)
  801db0:	e8 b6 f5 ff ff       	call   80136b <fd2data>
  801db5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db7:	83 c4 0c             	add    $0xc,%esp
  801dba:	68 07 04 00 00       	push   $0x407
  801dbf:	50                   	push   %eax
  801dc0:	6a 00                	push   $0x0
  801dc2:	e8 f6 ef ff ff       	call   800dbd <sys_page_alloc>
  801dc7:	89 c3                	mov    %eax,%ebx
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	0f 88 89 00 00 00    	js     801e5d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd4:	83 ec 0c             	sub    $0xc,%esp
  801dd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dda:	e8 8c f5 ff ff       	call   80136b <fd2data>
  801ddf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801de6:	50                   	push   %eax
  801de7:	6a 00                	push   $0x0
  801de9:	56                   	push   %esi
  801dea:	6a 00                	push   $0x0
  801dec:	e8 0f f0 ff ff       	call   800e00 <sys_page_map>
  801df1:	89 c3                	mov    %eax,%ebx
  801df3:	83 c4 20             	add    $0x20,%esp
  801df6:	85 c0                	test   %eax,%eax
  801df8:	78 55                	js     801e4f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dfa:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e03:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e08:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e0f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e18:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e24:	83 ec 0c             	sub    $0xc,%esp
  801e27:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2a:	e8 2c f5 ff ff       	call   80135b <fd2num>
  801e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e32:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e34:	83 c4 04             	add    $0x4,%esp
  801e37:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3a:	e8 1c f5 ff ff       	call   80135b <fd2num>
  801e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e42:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4d:	eb 30                	jmp    801e7f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e4f:	83 ec 08             	sub    $0x8,%esp
  801e52:	56                   	push   %esi
  801e53:	6a 00                	push   $0x0
  801e55:	e8 e8 ef ff ff       	call   800e42 <sys_page_unmap>
  801e5a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e5d:	83 ec 08             	sub    $0x8,%esp
  801e60:	ff 75 f0             	pushl  -0x10(%ebp)
  801e63:	6a 00                	push   $0x0
  801e65:	e8 d8 ef ff ff       	call   800e42 <sys_page_unmap>
  801e6a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e6d:	83 ec 08             	sub    $0x8,%esp
  801e70:	ff 75 f4             	pushl  -0xc(%ebp)
  801e73:	6a 00                	push   $0x0
  801e75:	e8 c8 ef ff ff       	call   800e42 <sys_page_unmap>
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e7f:	89 d0                	mov    %edx,%eax
  801e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e91:	50                   	push   %eax
  801e92:	ff 75 08             	pushl  0x8(%ebp)
  801e95:	e8 37 f5 ff ff       	call   8013d1 <fd_lookup>
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 18                	js     801eb9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ea1:	83 ec 0c             	sub    $0xc,%esp
  801ea4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea7:	e8 bf f4 ff ff       	call   80136b <fd2data>
	return _pipeisclosed(fd, p);
  801eac:	89 c2                	mov    %eax,%edx
  801eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb1:	e8 21 fd ff ff       	call   801bd7 <_pipeisclosed>
  801eb6:	83 c4 10             	add    $0x10,%esp
}
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    

00801ebb <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801ec3:	85 f6                	test   %esi,%esi
  801ec5:	75 16                	jne    801edd <wait+0x22>
  801ec7:	68 c2 2b 80 00       	push   $0x802bc2
  801ecc:	68 77 2b 80 00       	push   $0x802b77
  801ed1:	6a 09                	push   $0x9
  801ed3:	68 cd 2b 80 00       	push   $0x802bcd
  801ed8:	e8 35 e4 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801edd:	89 f3                	mov    %esi,%ebx
  801edf:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801ee5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801ee8:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801eee:	eb 05                	jmp    801ef5 <wait+0x3a>
		sys_yield();
  801ef0:	e8 a9 ee ff ff       	call   800d9e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801ef5:	8b 43 48             	mov    0x48(%ebx),%eax
  801ef8:	39 c6                	cmp    %eax,%esi
  801efa:	75 07                	jne    801f03 <wait+0x48>
  801efc:	8b 43 54             	mov    0x54(%ebx),%eax
  801eff:	85 c0                	test   %eax,%eax
  801f01:	75 ed                	jne    801ef0 <wait+0x35>
		sys_yield();
}
  801f03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f06:	5b                   	pop    %ebx
  801f07:	5e                   	pop    %esi
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f1a:	68 d8 2b 80 00       	push   $0x802bd8
  801f1f:	ff 75 0c             	pushl  0xc(%ebp)
  801f22:	e8 93 ea ff ff       	call   8009ba <strcpy>
	return 0;
}
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f3a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f3f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f45:	eb 2d                	jmp    801f74 <devcons_write+0x46>
		m = n - tot;
  801f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f4a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f4c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f4f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f54:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f57:	83 ec 04             	sub    $0x4,%esp
  801f5a:	53                   	push   %ebx
  801f5b:	03 45 0c             	add    0xc(%ebp),%eax
  801f5e:	50                   	push   %eax
  801f5f:	57                   	push   %edi
  801f60:	e8 e7 eb ff ff       	call   800b4c <memmove>
		sys_cputs(buf, m);
  801f65:	83 c4 08             	add    $0x8,%esp
  801f68:	53                   	push   %ebx
  801f69:	57                   	push   %edi
  801f6a:	e8 92 ed ff ff       	call   800d01 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f6f:	01 de                	add    %ebx,%esi
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	89 f0                	mov    %esi,%eax
  801f76:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f79:	72 cc                	jb     801f47 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7e:	5b                   	pop    %ebx
  801f7f:	5e                   	pop    %esi
  801f80:	5f                   	pop    %edi
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    

00801f83 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	83 ec 08             	sub    $0x8,%esp
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f92:	74 2a                	je     801fbe <devcons_read+0x3b>
  801f94:	eb 05                	jmp    801f9b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f96:	e8 03 ee ff ff       	call   800d9e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f9b:	e8 7f ed ff ff       	call   800d1f <sys_cgetc>
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	74 f2                	je     801f96 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 16                	js     801fbe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fa8:	83 f8 04             	cmp    $0x4,%eax
  801fab:	74 0c                	je     801fb9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fad:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb0:	88 02                	mov    %al,(%edx)
	return 1;
  801fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb7:	eb 05                	jmp    801fbe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fb9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fbe:	c9                   	leave  
  801fbf:	c3                   	ret    

00801fc0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fcc:	6a 01                	push   $0x1
  801fce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd1:	50                   	push   %eax
  801fd2:	e8 2a ed ff ff       	call   800d01 <sys_cputs>
}
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	c9                   	leave  
  801fdb:	c3                   	ret    

00801fdc <getchar>:

int
getchar(void)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fe2:	6a 01                	push   $0x1
  801fe4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fe7:	50                   	push   %eax
  801fe8:	6a 00                	push   $0x0
  801fea:	e8 48 f6 ff ff       	call   801637 <read>
	if (r < 0)
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	78 0f                	js     802005 <getchar+0x29>
		return r;
	if (r < 1)
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	7e 06                	jle    802000 <getchar+0x24>
		return -E_EOF;
	return c;
  801ffa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ffe:	eb 05                	jmp    802005 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802000:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802005:	c9                   	leave  
  802006:	c3                   	ret    

00802007 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80200d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802010:	50                   	push   %eax
  802011:	ff 75 08             	pushl  0x8(%ebp)
  802014:	e8 b8 f3 ff ff       	call   8013d1 <fd_lookup>
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	85 c0                	test   %eax,%eax
  80201e:	78 11                	js     802031 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802023:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802029:	39 10                	cmp    %edx,(%eax)
  80202b:	0f 94 c0             	sete   %al
  80202e:	0f b6 c0             	movzbl %al,%eax
}
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <opencons>:

int
opencons(void)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203c:	50                   	push   %eax
  80203d:	e8 40 f3 ff ff       	call   801382 <fd_alloc>
  802042:	83 c4 10             	add    $0x10,%esp
		return r;
  802045:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802047:	85 c0                	test   %eax,%eax
  802049:	78 3e                	js     802089 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204b:	83 ec 04             	sub    $0x4,%esp
  80204e:	68 07 04 00 00       	push   $0x407
  802053:	ff 75 f4             	pushl  -0xc(%ebp)
  802056:	6a 00                	push   $0x0
  802058:	e8 60 ed ff ff       	call   800dbd <sys_page_alloc>
  80205d:	83 c4 10             	add    $0x10,%esp
		return r;
  802060:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802062:	85 c0                	test   %eax,%eax
  802064:	78 23                	js     802089 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802066:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80206c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802074:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80207b:	83 ec 0c             	sub    $0xc,%esp
  80207e:	50                   	push   %eax
  80207f:	e8 d7 f2 ff ff       	call   80135b <fd2num>
  802084:	89 c2                	mov    %eax,%edx
  802086:	83 c4 10             	add    $0x10,%esp
}
  802089:	89 d0                	mov    %edx,%eax
  80208b:	c9                   	leave  
  80208c:	c3                   	ret    

0080208d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  802093:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80209a:	75 4c                	jne    8020e8 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  80209c:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a1:	8b 40 48             	mov    0x48(%eax),%eax
  8020a4:	83 ec 04             	sub    $0x4,%esp
  8020a7:	6a 07                	push   $0x7
  8020a9:	68 00 f0 bf ee       	push   $0xeebff000
  8020ae:	50                   	push   %eax
  8020af:	e8 09 ed ff ff       	call   800dbd <sys_page_alloc>
		if(retv != 0){
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	74 14                	je     8020cf <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  8020bb:	83 ec 04             	sub    $0x4,%esp
  8020be:	68 e4 2b 80 00       	push   $0x802be4
  8020c3:	6a 27                	push   $0x27
  8020c5:	68 10 2c 80 00       	push   $0x802c10
  8020ca:	e8 43 e2 ff ff       	call   800312 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8020cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d4:	8b 40 48             	mov    0x48(%eax),%eax
  8020d7:	83 ec 08             	sub    $0x8,%esp
  8020da:	68 f2 20 80 00       	push   $0x8020f2
  8020df:	50                   	push   %eax
  8020e0:	e8 23 ee ff ff       	call   800f08 <sys_env_set_pgfault_upcall>
  8020e5:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020eb:	a3 00 60 80 00       	mov    %eax,0x806000

}
  8020f0:	c9                   	leave  
  8020f1:	c3                   	ret    

008020f2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020f2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020f3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020f8:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  8020fa:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  8020fd:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  802101:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  802106:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  80210a:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  80210c:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  80210f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  802110:	83 c4 04             	add    $0x4,%esp
	popfl
  802113:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802114:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802115:	c3                   	ret    

00802116 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	56                   	push   %esi
  80211a:	53                   	push   %ebx
  80211b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80211e:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  802121:	83 ec 0c             	sub    $0xc,%esp
  802124:	ff 75 0c             	pushl  0xc(%ebp)
  802127:	e8 41 ee ff ff       	call   800f6d <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	85 f6                	test   %esi,%esi
  802131:	74 1c                	je     80214f <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  802133:	a1 04 40 80 00       	mov    0x804004,%eax
  802138:	8b 40 78             	mov    0x78(%eax),%eax
  80213b:	89 06                	mov    %eax,(%esi)
  80213d:	eb 10                	jmp    80214f <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  80213f:	83 ec 0c             	sub    $0xc,%esp
  802142:	68 1e 2c 80 00       	push   $0x802c1e
  802147:	e8 9f e2 ff ff       	call   8003eb <cprintf>
  80214c:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  80214f:	a1 04 40 80 00       	mov    0x804004,%eax
  802154:	8b 50 74             	mov    0x74(%eax),%edx
  802157:	85 d2                	test   %edx,%edx
  802159:	74 e4                	je     80213f <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  80215b:	85 db                	test   %ebx,%ebx
  80215d:	74 05                	je     802164 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  80215f:	8b 40 74             	mov    0x74(%eax),%eax
  802162:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802164:	a1 04 40 80 00       	mov    0x804004,%eax
  802169:	8b 40 70             	mov    0x70(%eax),%eax

}
  80216c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    

00802173 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	57                   	push   %edi
  802177:	56                   	push   %esi
  802178:	53                   	push   %ebx
  802179:	83 ec 0c             	sub    $0xc,%esp
  80217c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80217f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802182:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  802185:	85 db                	test   %ebx,%ebx
  802187:	75 13                	jne    80219c <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  802189:	6a 00                	push   $0x0
  80218b:	68 00 00 c0 ee       	push   $0xeec00000
  802190:	56                   	push   %esi
  802191:	57                   	push   %edi
  802192:	e8 b3 ed ff ff       	call   800f4a <sys_ipc_try_send>
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	eb 0e                	jmp    8021aa <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  80219c:	ff 75 14             	pushl  0x14(%ebp)
  80219f:	53                   	push   %ebx
  8021a0:	56                   	push   %esi
  8021a1:	57                   	push   %edi
  8021a2:	e8 a3 ed ff ff       	call   800f4a <sys_ipc_try_send>
  8021a7:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  8021aa:	85 c0                	test   %eax,%eax
  8021ac:	75 d7                	jne    802185 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  8021ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b1:	5b                   	pop    %ebx
  8021b2:	5e                   	pop    %esi
  8021b3:	5f                   	pop    %edi
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    

008021b6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021bc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021c1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021c4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021ca:	8b 52 50             	mov    0x50(%edx),%edx
  8021cd:	39 ca                	cmp    %ecx,%edx
  8021cf:	75 0d                	jne    8021de <ipc_find_env+0x28>
			return envs[i].env_id;
  8021d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021d9:	8b 40 48             	mov    0x48(%eax),%eax
  8021dc:	eb 0f                	jmp    8021ed <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021de:	83 c0 01             	add    $0x1,%eax
  8021e1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021e6:	75 d9                	jne    8021c1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021ed:	5d                   	pop    %ebp
  8021ee:	c3                   	ret    

008021ef <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021ef:	55                   	push   %ebp
  8021f0:	89 e5                	mov    %esp,%ebp
  8021f2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	c1 e8 16             	shr    $0x16,%eax
  8021fa:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802206:	f6 c1 01             	test   $0x1,%cl
  802209:	74 1d                	je     802228 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80220b:	c1 ea 0c             	shr    $0xc,%edx
  80220e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802215:	f6 c2 01             	test   $0x1,%dl
  802218:	74 0e                	je     802228 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80221a:	c1 ea 0c             	shr    $0xc,%edx
  80221d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802224:	ef 
  802225:	0f b7 c0             	movzwl %ax,%eax
}
  802228:	5d                   	pop    %ebp
  802229:	c3                   	ret    
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__udivdi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80223b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80223f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802247:	85 f6                	test   %esi,%esi
  802249:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80224d:	89 ca                	mov    %ecx,%edx
  80224f:	89 f8                	mov    %edi,%eax
  802251:	75 3d                	jne    802290 <__udivdi3+0x60>
  802253:	39 cf                	cmp    %ecx,%edi
  802255:	0f 87 c5 00 00 00    	ja     802320 <__udivdi3+0xf0>
  80225b:	85 ff                	test   %edi,%edi
  80225d:	89 fd                	mov    %edi,%ebp
  80225f:	75 0b                	jne    80226c <__udivdi3+0x3c>
  802261:	b8 01 00 00 00       	mov    $0x1,%eax
  802266:	31 d2                	xor    %edx,%edx
  802268:	f7 f7                	div    %edi
  80226a:	89 c5                	mov    %eax,%ebp
  80226c:	89 c8                	mov    %ecx,%eax
  80226e:	31 d2                	xor    %edx,%edx
  802270:	f7 f5                	div    %ebp
  802272:	89 c1                	mov    %eax,%ecx
  802274:	89 d8                	mov    %ebx,%eax
  802276:	89 cf                	mov    %ecx,%edi
  802278:	f7 f5                	div    %ebp
  80227a:	89 c3                	mov    %eax,%ebx
  80227c:	89 d8                	mov    %ebx,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	39 ce                	cmp    %ecx,%esi
  802292:	77 74                	ja     802308 <__udivdi3+0xd8>
  802294:	0f bd fe             	bsr    %esi,%edi
  802297:	83 f7 1f             	xor    $0x1f,%edi
  80229a:	0f 84 98 00 00 00    	je     802338 <__udivdi3+0x108>
  8022a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	89 c5                	mov    %eax,%ebp
  8022a9:	29 fb                	sub    %edi,%ebx
  8022ab:	d3 e6                	shl    %cl,%esi
  8022ad:	89 d9                	mov    %ebx,%ecx
  8022af:	d3 ed                	shr    %cl,%ebp
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	d3 e0                	shl    %cl,%eax
  8022b5:	09 ee                	or     %ebp,%esi
  8022b7:	89 d9                	mov    %ebx,%ecx
  8022b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022bd:	89 d5                	mov    %edx,%ebp
  8022bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022c3:	d3 ed                	shr    %cl,%ebp
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	d3 e2                	shl    %cl,%edx
  8022c9:	89 d9                	mov    %ebx,%ecx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	09 c2                	or     %eax,%edx
  8022cf:	89 d0                	mov    %edx,%eax
  8022d1:	89 ea                	mov    %ebp,%edx
  8022d3:	f7 f6                	div    %esi
  8022d5:	89 d5                	mov    %edx,%ebp
  8022d7:	89 c3                	mov    %eax,%ebx
  8022d9:	f7 64 24 0c          	mull   0xc(%esp)
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	72 10                	jb     8022f1 <__udivdi3+0xc1>
  8022e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	d3 e6                	shl    %cl,%esi
  8022e9:	39 c6                	cmp    %eax,%esi
  8022eb:	73 07                	jae    8022f4 <__udivdi3+0xc4>
  8022ed:	39 d5                	cmp    %edx,%ebp
  8022ef:	75 03                	jne    8022f4 <__udivdi3+0xc4>
  8022f1:	83 eb 01             	sub    $0x1,%ebx
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 d8                	mov    %ebx,%eax
  8022f8:	89 fa                	mov    %edi,%edx
  8022fa:	83 c4 1c             	add    $0x1c,%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5f                   	pop    %edi
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    
  802302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802308:	31 ff                	xor    %edi,%edi
  80230a:	31 db                	xor    %ebx,%ebx
  80230c:	89 d8                	mov    %ebx,%eax
  80230e:	89 fa                	mov    %edi,%edx
  802310:	83 c4 1c             	add    $0x1c,%esp
  802313:	5b                   	pop    %ebx
  802314:	5e                   	pop    %esi
  802315:	5f                   	pop    %edi
  802316:	5d                   	pop    %ebp
  802317:	c3                   	ret    
  802318:	90                   	nop
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	89 d8                	mov    %ebx,%eax
  802322:	f7 f7                	div    %edi
  802324:	31 ff                	xor    %edi,%edi
  802326:	89 c3                	mov    %eax,%ebx
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	89 fa                	mov    %edi,%edx
  80232c:	83 c4 1c             	add    $0x1c,%esp
  80232f:	5b                   	pop    %ebx
  802330:	5e                   	pop    %esi
  802331:	5f                   	pop    %edi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    
  802334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802338:	39 ce                	cmp    %ecx,%esi
  80233a:	72 0c                	jb     802348 <__udivdi3+0x118>
  80233c:	31 db                	xor    %ebx,%ebx
  80233e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802342:	0f 87 34 ff ff ff    	ja     80227c <__udivdi3+0x4c>
  802348:	bb 01 00 00 00       	mov    $0x1,%ebx
  80234d:	e9 2a ff ff ff       	jmp    80227c <__udivdi3+0x4c>
  802352:	66 90                	xchg   %ax,%ax
  802354:	66 90                	xchg   %ax,%ax
  802356:	66 90                	xchg   %ax,%ax
  802358:	66 90                	xchg   %ax,%ax
  80235a:	66 90                	xchg   %ax,%ax
  80235c:	66 90                	xchg   %ax,%ax
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__umoddi3>:
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	53                   	push   %ebx
  802364:	83 ec 1c             	sub    $0x1c,%esp
  802367:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80236b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80236f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802377:	85 d2                	test   %edx,%edx
  802379:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 f3                	mov    %esi,%ebx
  802383:	89 3c 24             	mov    %edi,(%esp)
  802386:	89 74 24 04          	mov    %esi,0x4(%esp)
  80238a:	75 1c                	jne    8023a8 <__umoddi3+0x48>
  80238c:	39 f7                	cmp    %esi,%edi
  80238e:	76 50                	jbe    8023e0 <__umoddi3+0x80>
  802390:	89 c8                	mov    %ecx,%eax
  802392:	89 f2                	mov    %esi,%edx
  802394:	f7 f7                	div    %edi
  802396:	89 d0                	mov    %edx,%eax
  802398:	31 d2                	xor    %edx,%edx
  80239a:	83 c4 1c             	add    $0x1c,%esp
  80239d:	5b                   	pop    %ebx
  80239e:	5e                   	pop    %esi
  80239f:	5f                   	pop    %edi
  8023a0:	5d                   	pop    %ebp
  8023a1:	c3                   	ret    
  8023a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023a8:	39 f2                	cmp    %esi,%edx
  8023aa:	89 d0                	mov    %edx,%eax
  8023ac:	77 52                	ja     802400 <__umoddi3+0xa0>
  8023ae:	0f bd ea             	bsr    %edx,%ebp
  8023b1:	83 f5 1f             	xor    $0x1f,%ebp
  8023b4:	75 5a                	jne    802410 <__umoddi3+0xb0>
  8023b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023ba:	0f 82 e0 00 00 00    	jb     8024a0 <__umoddi3+0x140>
  8023c0:	39 0c 24             	cmp    %ecx,(%esp)
  8023c3:	0f 86 d7 00 00 00    	jbe    8024a0 <__umoddi3+0x140>
  8023c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023d1:	83 c4 1c             	add    $0x1c,%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5e                   	pop    %esi
  8023d6:	5f                   	pop    %edi
  8023d7:	5d                   	pop    %ebp
  8023d8:	c3                   	ret    
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	85 ff                	test   %edi,%edi
  8023e2:	89 fd                	mov    %edi,%ebp
  8023e4:	75 0b                	jne    8023f1 <__umoddi3+0x91>
  8023e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	f7 f7                	div    %edi
  8023ef:	89 c5                	mov    %eax,%ebp
  8023f1:	89 f0                	mov    %esi,%eax
  8023f3:	31 d2                	xor    %edx,%edx
  8023f5:	f7 f5                	div    %ebp
  8023f7:	89 c8                	mov    %ecx,%eax
  8023f9:	f7 f5                	div    %ebp
  8023fb:	89 d0                	mov    %edx,%eax
  8023fd:	eb 99                	jmp    802398 <__umoddi3+0x38>
  8023ff:	90                   	nop
  802400:	89 c8                	mov    %ecx,%eax
  802402:	89 f2                	mov    %esi,%edx
  802404:	83 c4 1c             	add    $0x1c,%esp
  802407:	5b                   	pop    %ebx
  802408:	5e                   	pop    %esi
  802409:	5f                   	pop    %edi
  80240a:	5d                   	pop    %ebp
  80240b:	c3                   	ret    
  80240c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802410:	8b 34 24             	mov    (%esp),%esi
  802413:	bf 20 00 00 00       	mov    $0x20,%edi
  802418:	89 e9                	mov    %ebp,%ecx
  80241a:	29 ef                	sub    %ebp,%edi
  80241c:	d3 e0                	shl    %cl,%eax
  80241e:	89 f9                	mov    %edi,%ecx
  802420:	89 f2                	mov    %esi,%edx
  802422:	d3 ea                	shr    %cl,%edx
  802424:	89 e9                	mov    %ebp,%ecx
  802426:	09 c2                	or     %eax,%edx
  802428:	89 d8                	mov    %ebx,%eax
  80242a:	89 14 24             	mov    %edx,(%esp)
  80242d:	89 f2                	mov    %esi,%edx
  80242f:	d3 e2                	shl    %cl,%edx
  802431:	89 f9                	mov    %edi,%ecx
  802433:	89 54 24 04          	mov    %edx,0x4(%esp)
  802437:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80243b:	d3 e8                	shr    %cl,%eax
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	89 c6                	mov    %eax,%esi
  802441:	d3 e3                	shl    %cl,%ebx
  802443:	89 f9                	mov    %edi,%ecx
  802445:	89 d0                	mov    %edx,%eax
  802447:	d3 e8                	shr    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	09 d8                	or     %ebx,%eax
  80244d:	89 d3                	mov    %edx,%ebx
  80244f:	89 f2                	mov    %esi,%edx
  802451:	f7 34 24             	divl   (%esp)
  802454:	89 d6                	mov    %edx,%esi
  802456:	d3 e3                	shl    %cl,%ebx
  802458:	f7 64 24 04          	mull   0x4(%esp)
  80245c:	39 d6                	cmp    %edx,%esi
  80245e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802462:	89 d1                	mov    %edx,%ecx
  802464:	89 c3                	mov    %eax,%ebx
  802466:	72 08                	jb     802470 <__umoddi3+0x110>
  802468:	75 11                	jne    80247b <__umoddi3+0x11b>
  80246a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80246e:	73 0b                	jae    80247b <__umoddi3+0x11b>
  802470:	2b 44 24 04          	sub    0x4(%esp),%eax
  802474:	1b 14 24             	sbb    (%esp),%edx
  802477:	89 d1                	mov    %edx,%ecx
  802479:	89 c3                	mov    %eax,%ebx
  80247b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80247f:	29 da                	sub    %ebx,%edx
  802481:	19 ce                	sbb    %ecx,%esi
  802483:	89 f9                	mov    %edi,%ecx
  802485:	89 f0                	mov    %esi,%eax
  802487:	d3 e0                	shl    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	d3 ea                	shr    %cl,%edx
  80248d:	89 e9                	mov    %ebp,%ecx
  80248f:	d3 ee                	shr    %cl,%esi
  802491:	09 d0                	or     %edx,%eax
  802493:	89 f2                	mov    %esi,%edx
  802495:	83 c4 1c             	add    $0x1c,%esp
  802498:	5b                   	pop    %ebx
  802499:	5e                   	pop    %esi
  80249a:	5f                   	pop    %edi
  80249b:	5d                   	pop    %ebp
  80249c:	c3                   	ret    
  80249d:	8d 76 00             	lea    0x0(%esi),%esi
  8024a0:	29 f9                	sub    %edi,%ecx
  8024a2:	19 d6                	sbb    %edx,%esi
  8024a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ac:	e9 18 ff ff ff       	jmp    8023c9 <__umoddi3+0x69>
