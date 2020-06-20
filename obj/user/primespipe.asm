
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 fd 15 00 00       	call   80164e <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 00 24 80 00       	push   $0x802400
  80006d:	6a 15                	push   $0x15
  80006f:	68 2f 24 80 00       	push   $0x80242f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 41 24 80 00       	push   $0x802441
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 2a 1c 00 00       	call   801cbb <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 45 24 80 00       	push   $0x802445
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 2f 24 80 00       	push   $0x80242f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 3a 10 00 00       	call   8010ec <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 4e 24 80 00       	push   $0x80244e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 2f 24 80 00       	push   $0x80242f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 ac 13 00 00       	call   801481 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 a1 13 00 00       	call   801481 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 8b 13 00 00       	call   801481 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 43 15 00 00       	call   80164e <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 57 24 80 00       	push   $0x802457
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 2f 24 80 00       	push   $0x80242f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 49 15 00 00       	call   801697 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 73 24 80 00       	push   $0x802473
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 2f 24 80 00       	push   $0x80242f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 8d 	movl   $0x80248d,0x803000
  800187:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 28 1b 00 00       	call   801cbb <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 45 24 80 00       	push   $0x802445
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 2f 24 80 00       	push   $0x80242f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 38 0f 00 00       	call   8010ec <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 4e 24 80 00       	push   $0x80244e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 2f 24 80 00       	push   $0x80242f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 a8 12 00 00       	call   801481 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 92 12 00 00       	call   801481 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 8d 14 00 00       	call   801697 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 98 24 80 00       	push   $0x802498
  800226:	6a 4a                	push   $0x4a
  800228:	68 2f 24 80 00       	push   $0x80242f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 bd 0a 00 00       	call   800d05 <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 23 12 00 00       	call   8014ac <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 31 0a 00 00       	call   800cc4 <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 5a 0a 00 00       	call   800d05 <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 bc 24 80 00       	push   $0x8024bc
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 e3 28 80 00 	movl   $0x8028e3,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 79 09 00 00       	call   800c87 <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 1e 09 00 00       	call   800c87 <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 97 1d 00 00       	call   802170 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 84 1e 00 00       	call   8022a0 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 df 24 80 00 	movsbl 0x8024df(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 d3 03 00 00    	je     800897 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	eb 07                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 47 01             	lea    0x1(%edi),%eax
  800504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800507:	0f b6 07             	movzbl (%edi),%eax
  80050a:	0f b6 c8             	movzbl %al,%ecx
  80050d:	83 e8 23             	sub    $0x23,%eax
  800510:	3c 55                	cmp    $0x55,%al
  800512:	0f 87 64 03 00 00    	ja     80087c <vprintfmt+0x3d4>
  800518:	0f b6 c0             	movzbl %al,%eax
  80051b:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800529:	eb d6                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800536:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800539:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800540:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800543:	83 fa 09             	cmp    $0x9,%edx
  800546:	77 39                	ja     800581 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800548:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80054b:	eb e9                	jmp    800536 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 48 04             	lea    0x4(%eax),%ecx
  800553:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055e:	eb 27                	jmp    800587 <vprintfmt+0xdf>
  800560:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	0f 49 c8             	cmovns %eax,%ecx
  80056d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800573:	eb 8c                	jmp    800501 <vprintfmt+0x59>
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800578:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057f:	eb 80                	jmp    800501 <vprintfmt+0x59>
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 70 ff ff ff    	jns    800501 <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80059e:	e9 5e ff ff ff       	jmp    800501 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 53 ff ff ff       	jmp    800501 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 30                	pushl  (%eax)
  8005bd:	ff d6                	call   *%esi
			break;
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 04 ff ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	31 d0                	xor    %edx,%eax
  8005d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005da:	83 f8 0f             	cmp    $0xf,%eax
  8005dd:	7f 0b                	jg     8005ea <vprintfmt+0x142>
  8005df:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 f7 24 80 00       	push   $0x8024f7
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 94 fe ff ff       	call   80048b <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 cc fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 29 2a 80 00       	push   $0x802a29
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 7c fe ff ff       	call   80048b <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 b4 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800625:	85 ff                	test   %edi,%edi
  800627:	b8 f0 24 80 00       	mov    $0x8024f0,%eax
  80062c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 8e 94 00 00 00    	jle    8006cd <vprintfmt+0x225>
  800639:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063d:	0f 84 98 00 00 00    	je     8006db <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 c8             	pushl  -0x38(%ebp)
  800649:	57                   	push   %edi
  80064a:	e8 d0 02 00 00       	call   80091f <strnlen>
  80064f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800652:	29 c1                	sub    %eax,%ecx
  800654:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800661:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800664:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	eb 0f                	jmp    800677 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 ff                	test   %edi,%edi
  800679:	7f ed                	jg     800668 <vprintfmt+0x1c0>
  80067b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	0f 49 c1             	cmovns %ecx,%eax
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	89 cb                	mov    %ecx,%ebx
  800698:	eb 4d                	jmp    8006e7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069e:	74 1b                	je     8006bb <vprintfmt+0x213>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 10                	jbe    8006bb <vprintfmt+0x213>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 3f                	push   $0x3f
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	eb 1a                	jmp    8006e7 <vprintfmt+0x23f>
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d9:	eb 0c                	jmp    8006e7 <vprintfmt+0x23f>
  8006db:	89 75 08             	mov    %esi,0x8(%ebp)
  8006de:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	0f be d0             	movsbl %al,%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	74 23                	je     800718 <vprintfmt+0x270>
  8006f5:	85 f6                	test   %esi,%esi
  8006f7:	78 a1                	js     80069a <vprintfmt+0x1f2>
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	79 9c                	jns    80069a <vprintfmt+0x1f2>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	eb 18                	jmp    800720 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 08                	jmp    800720 <vprintfmt+0x278>
  800718:	89 df                	mov    %ebx,%edi
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	85 ff                	test   %edi,%edi
  800722:	7f e4                	jg     800708 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 a2 fd ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072c:	83 fa 01             	cmp    $0x1,%edx
  80072f:	7e 16                	jle    800747 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 08             	lea    0x8(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 50 04             	mov    0x4(%eax),%edx
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800742:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800745:	eb 32                	jmp    800779 <vprintfmt+0x2d1>
	else if (lflag)
  800747:	85 d2                	test   %edx,%edx
  800749:	74 18                	je     800763 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800759:	89 c1                	mov    %eax,%ecx
  80075b:	c1 f9 1f             	sar    $0x1f,%ecx
  80075e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800761:	eb 16                	jmp    800779 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800771:	89 c1                	mov    %eax,%ecx
  800773:	c1 f9 1f             	sar    $0x1f,%ecx
  800776:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80077c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80077f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800782:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800785:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80078e:	0f 89 b0 00 00 00    	jns    800844 <vprintfmt+0x39c>
				putch('-', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 2d                	push   $0x2d
  80079a:	ff d6                	call   *%esi
				num = -(long long) num;
  80079c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80079f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007a2:	f7 d8                	neg    %eax
  8007a4:	83 d2 00             	adc    $0x0,%edx
  8007a7:	f7 da                	neg    %edx
  8007a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007af:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b7:	e9 88 00 00 00       	jmp    800844 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bf:	e8 70 fc ff ff       	call   800434 <getuint>
  8007c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007cf:	eb 73                	jmp    800844 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8007d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d4:	e8 5b fc ff ff       	call   800434 <getuint>
  8007d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	6a 58                	push   $0x58
  8007e5:	ff d6                	call   *%esi
			putch('X', putdat);
  8007e7:	83 c4 08             	add    $0x8,%esp
  8007ea:	53                   	push   %ebx
  8007eb:	6a 58                	push   $0x58
  8007ed:	ff d6                	call   *%esi
			putch('X', putdat);
  8007ef:	83 c4 08             	add    $0x8,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	6a 58                	push   $0x58
  8007f5:	ff d6                	call   *%esi
			goto number;
  8007f7:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8007fa:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8007ff:	eb 43                	jmp    800844 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	53                   	push   %ebx
  800805:	6a 30                	push   $0x30
  800807:	ff d6                	call   *%esi
			putch('x', putdat);
  800809:	83 c4 08             	add    $0x8,%esp
  80080c:	53                   	push   %ebx
  80080d:	6a 78                	push   $0x78
  80080f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 50 04             	lea    0x4(%eax),%edx
  800817:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80081a:	8b 00                	mov    (%eax),%eax
  80081c:	ba 00 00 00 00       	mov    $0x0,%edx
  800821:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800824:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800827:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80082a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80082f:	eb 13                	jmp    800844 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800831:	8d 45 14             	lea    0x14(%ebp),%eax
  800834:	e8 fb fb ff ff       	call   800434 <getuint>
  800839:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80083f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800844:	83 ec 0c             	sub    $0xc,%esp
  800847:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80084b:	52                   	push   %edx
  80084c:	ff 75 e0             	pushl  -0x20(%ebp)
  80084f:	50                   	push   %eax
  800850:	ff 75 dc             	pushl  -0x24(%ebp)
  800853:	ff 75 d8             	pushl  -0x28(%ebp)
  800856:	89 da                	mov    %ebx,%edx
  800858:	89 f0                	mov    %esi,%eax
  80085a:	e8 26 fb ff ff       	call   800385 <printnum>
			break;
  80085f:	83 c4 20             	add    $0x20,%esp
  800862:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800865:	e9 64 fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	53                   	push   %ebx
  80086e:	51                   	push   %ecx
  80086f:	ff d6                	call   *%esi
			break;
  800871:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800874:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800877:	e9 52 fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	53                   	push   %ebx
  800880:	6a 25                	push   $0x25
  800882:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800884:	83 c4 10             	add    $0x10,%esp
  800887:	eb 03                	jmp    80088c <vprintfmt+0x3e4>
  800889:	83 ef 01             	sub    $0x1,%edi
  80088c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800890:	75 f7                	jne    800889 <vprintfmt+0x3e1>
  800892:	e9 37 fc ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800897:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5f                   	pop    %edi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 18             	sub    $0x18,%esp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	74 26                	je     8008e6 <vsnprintf+0x47>
  8008c0:	85 d2                	test   %edx,%edx
  8008c2:	7e 22                	jle    8008e6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c4:	ff 75 14             	pushl  0x14(%ebp)
  8008c7:	ff 75 10             	pushl  0x10(%ebp)
  8008ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cd:	50                   	push   %eax
  8008ce:	68 6e 04 80 00       	push   $0x80046e
  8008d3:	e8 d0 fb ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	eb 05                	jmp    8008eb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f6:	50                   	push   %eax
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	ff 75 08             	pushl  0x8(%ebp)
  800900:	e8 9a ff ff ff       	call   80089f <vsnprintf>
	va_end(ap);

	return rc;
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	eb 03                	jmp    800917 <strlen+0x10>
		n++;
  800914:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800917:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091b:	75 f7                	jne    800914 <strlen+0xd>
		n++;
	return n;
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800925:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800928:	ba 00 00 00 00       	mov    $0x0,%edx
  80092d:	eb 03                	jmp    800932 <strnlen+0x13>
		n++;
  80092f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800932:	39 c2                	cmp    %eax,%edx
  800934:	74 08                	je     80093e <strnlen+0x1f>
  800936:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80093a:	75 f3                	jne    80092f <strnlen+0x10>
  80093c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	53                   	push   %ebx
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094a:	89 c2                	mov    %eax,%edx
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800956:	88 5a ff             	mov    %bl,-0x1(%edx)
  800959:	84 db                	test   %bl,%bl
  80095b:	75 ef                	jne    80094c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095d:	5b                   	pop    %ebx
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800967:	53                   	push   %ebx
  800968:	e8 9a ff ff ff       	call   800907 <strlen>
  80096d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800970:	ff 75 0c             	pushl  0xc(%ebp)
  800973:	01 d8                	add    %ebx,%eax
  800975:	50                   	push   %eax
  800976:	e8 c5 ff ff ff       	call   800940 <strcpy>
	return dst;
}
  80097b:	89 d8                	mov    %ebx,%eax
  80097d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	89 f3                	mov    %esi,%ebx
  80098f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800992:	89 f2                	mov    %esi,%edx
  800994:	eb 0f                	jmp    8009a5 <strncpy+0x23>
		*dst++ = *src;
  800996:	83 c2 01             	add    $0x1,%edx
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099f:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a5:	39 da                	cmp    %ebx,%edx
  8009a7:	75 ed                	jne    800996 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a9:	89 f0                	mov    %esi,%eax
  8009ab:	5b                   	pop    %ebx
  8009ac:	5e                   	pop    %esi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8009bd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bf:	85 d2                	test   %edx,%edx
  8009c1:	74 21                	je     8009e4 <strlcpy+0x35>
  8009c3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c7:	89 f2                	mov    %esi,%edx
  8009c9:	eb 09                	jmp    8009d4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cb:	83 c2 01             	add    $0x1,%edx
  8009ce:	83 c1 01             	add    $0x1,%ecx
  8009d1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d4:	39 c2                	cmp    %eax,%edx
  8009d6:	74 09                	je     8009e1 <strlcpy+0x32>
  8009d8:	0f b6 19             	movzbl (%ecx),%ebx
  8009db:	84 db                	test   %bl,%bl
  8009dd:	75 ec                	jne    8009cb <strlcpy+0x1c>
  8009df:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e4:	29 f0                	sub    %esi,%eax
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f3:	eb 06                	jmp    8009fb <strcmp+0x11>
		p++, q++;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fb:	0f b6 01             	movzbl (%ecx),%eax
  8009fe:	84 c0                	test   %al,%al
  800a00:	74 04                	je     800a06 <strcmp+0x1c>
  800a02:	3a 02                	cmp    (%edx),%al
  800a04:	74 ef                	je     8009f5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a06:	0f b6 c0             	movzbl %al,%eax
  800a09:	0f b6 12             	movzbl (%edx),%edx
  800a0c:	29 d0                	sub    %edx,%eax
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	89 c3                	mov    %eax,%ebx
  800a1c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1f:	eb 06                	jmp    800a27 <strncmp+0x17>
		n--, p++, q++;
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a27:	39 d8                	cmp    %ebx,%eax
  800a29:	74 15                	je     800a40 <strncmp+0x30>
  800a2b:	0f b6 08             	movzbl (%eax),%ecx
  800a2e:	84 c9                	test   %cl,%cl
  800a30:	74 04                	je     800a36 <strncmp+0x26>
  800a32:	3a 0a                	cmp    (%edx),%cl
  800a34:	74 eb                	je     800a21 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 00             	movzbl (%eax),%eax
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	29 d0                	sub    %edx,%eax
  800a3e:	eb 05                	jmp    800a45 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a52:	eb 07                	jmp    800a5b <strchr+0x13>
		if (*s == c)
  800a54:	38 ca                	cmp    %cl,%dl
  800a56:	74 0f                	je     800a67 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	0f b6 10             	movzbl (%eax),%edx
  800a5e:	84 d2                	test   %dl,%dl
  800a60:	75 f2                	jne    800a54 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a73:	eb 03                	jmp    800a78 <strfind+0xf>
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7b:	38 ca                	cmp    %cl,%dl
  800a7d:	74 04                	je     800a83 <strfind+0x1a>
  800a7f:	84 d2                	test   %dl,%dl
  800a81:	75 f2                	jne    800a75 <strfind+0xc>
			break;
	return (char *) s;
}
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a91:	85 c9                	test   %ecx,%ecx
  800a93:	74 36                	je     800acb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9b:	75 28                	jne    800ac5 <memset+0x40>
  800a9d:	f6 c1 03             	test   $0x3,%cl
  800aa0:	75 23                	jne    800ac5 <memset+0x40>
		c &= 0xFF;
  800aa2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa6:	89 d3                	mov    %edx,%ebx
  800aa8:	c1 e3 08             	shl    $0x8,%ebx
  800aab:	89 d6                	mov    %edx,%esi
  800aad:	c1 e6 18             	shl    $0x18,%esi
  800ab0:	89 d0                	mov    %edx,%eax
  800ab2:	c1 e0 10             	shl    $0x10,%eax
  800ab5:	09 f0                	or     %esi,%eax
  800ab7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	09 d0                	or     %edx,%eax
  800abd:	c1 e9 02             	shr    $0x2,%ecx
  800ac0:	fc                   	cld    
  800ac1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac3:	eb 06                	jmp    800acb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	fc                   	cld    
  800ac9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acb:	89 f8                	mov    %edi,%eax
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	8b 75 0c             	mov    0xc(%ebp),%esi
  800add:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae0:	39 c6                	cmp    %eax,%esi
  800ae2:	73 35                	jae    800b19 <memmove+0x47>
  800ae4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae7:	39 d0                	cmp    %edx,%eax
  800ae9:	73 2e                	jae    800b19 <memmove+0x47>
		s += n;
		d += n;
  800aeb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	09 fe                	or     %edi,%esi
  800af2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af8:	75 13                	jne    800b0d <memmove+0x3b>
  800afa:	f6 c1 03             	test   $0x3,%cl
  800afd:	75 0e                	jne    800b0d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aff:	83 ef 04             	sub    $0x4,%edi
  800b02:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b05:	c1 e9 02             	shr    $0x2,%ecx
  800b08:	fd                   	std    
  800b09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0b:	eb 09                	jmp    800b16 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0d:	83 ef 01             	sub    $0x1,%edi
  800b10:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b13:	fd                   	std    
  800b14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b16:	fc                   	cld    
  800b17:	eb 1d                	jmp    800b36 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b19:	89 f2                	mov    %esi,%edx
  800b1b:	09 c2                	or     %eax,%edx
  800b1d:	f6 c2 03             	test   $0x3,%dl
  800b20:	75 0f                	jne    800b31 <memmove+0x5f>
  800b22:	f6 c1 03             	test   $0x3,%cl
  800b25:	75 0a                	jne    800b31 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b27:	c1 e9 02             	shr    $0x2,%ecx
  800b2a:	89 c7                	mov    %eax,%edi
  800b2c:	fc                   	cld    
  800b2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2f:	eb 05                	jmp    800b36 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	fc                   	cld    
  800b34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3d:	ff 75 10             	pushl  0x10(%ebp)
  800b40:	ff 75 0c             	pushl  0xc(%ebp)
  800b43:	ff 75 08             	pushl  0x8(%ebp)
  800b46:	e8 87 ff ff ff       	call   800ad2 <memmove>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b58:	89 c6                	mov    %eax,%esi
  800b5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5d:	eb 1a                	jmp    800b79 <memcmp+0x2c>
		if (*s1 != *s2)
  800b5f:	0f b6 08             	movzbl (%eax),%ecx
  800b62:	0f b6 1a             	movzbl (%edx),%ebx
  800b65:	38 d9                	cmp    %bl,%cl
  800b67:	74 0a                	je     800b73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b69:	0f b6 c1             	movzbl %cl,%eax
  800b6c:	0f b6 db             	movzbl %bl,%ebx
  800b6f:	29 d8                	sub    %ebx,%eax
  800b71:	eb 0f                	jmp    800b82 <memcmp+0x35>
		s1++, s2++;
  800b73:	83 c0 01             	add    $0x1,%eax
  800b76:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b79:	39 f0                	cmp    %esi,%eax
  800b7b:	75 e2                	jne    800b5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	53                   	push   %ebx
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b8d:	89 c1                	mov    %eax,%ecx
  800b8f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b92:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b96:	eb 0a                	jmp    800ba2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b98:	0f b6 10             	movzbl (%eax),%edx
  800b9b:	39 da                	cmp    %ebx,%edx
  800b9d:	74 07                	je     800ba6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9f:	83 c0 01             	add    $0x1,%eax
  800ba2:	39 c8                	cmp    %ecx,%eax
  800ba4:	72 f2                	jb     800b98 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	eb 03                	jmp    800bba <strtol+0x11>
		s++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 01             	movzbl (%ecx),%eax
  800bbd:	3c 20                	cmp    $0x20,%al
  800bbf:	74 f6                	je     800bb7 <strtol+0xe>
  800bc1:	3c 09                	cmp    $0x9,%al
  800bc3:	74 f2                	je     800bb7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc5:	3c 2b                	cmp    $0x2b,%al
  800bc7:	75 0a                	jne    800bd3 <strtol+0x2a>
		s++;
  800bc9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bcc:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd1:	eb 11                	jmp    800be4 <strtol+0x3b>
  800bd3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd8:	3c 2d                	cmp    $0x2d,%al
  800bda:	75 08                	jne    800be4 <strtol+0x3b>
		s++, neg = 1;
  800bdc:	83 c1 01             	add    $0x1,%ecx
  800bdf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bea:	75 15                	jne    800c01 <strtol+0x58>
  800bec:	80 39 30             	cmpb   $0x30,(%ecx)
  800bef:	75 10                	jne    800c01 <strtol+0x58>
  800bf1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf5:	75 7c                	jne    800c73 <strtol+0xca>
		s += 2, base = 16;
  800bf7:	83 c1 02             	add    $0x2,%ecx
  800bfa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bff:	eb 16                	jmp    800c17 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c01:	85 db                	test   %ebx,%ebx
  800c03:	75 12                	jne    800c17 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0d:	75 08                	jne    800c17 <strtol+0x6e>
		s++, base = 8;
  800c0f:	83 c1 01             	add    $0x1,%ecx
  800c12:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c17:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1f:	0f b6 11             	movzbl (%ecx),%edx
  800c22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c25:	89 f3                	mov    %esi,%ebx
  800c27:	80 fb 09             	cmp    $0x9,%bl
  800c2a:	77 08                	ja     800c34 <strtol+0x8b>
			dig = *s - '0';
  800c2c:	0f be d2             	movsbl %dl,%edx
  800c2f:	83 ea 30             	sub    $0x30,%edx
  800c32:	eb 22                	jmp    800c56 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c37:	89 f3                	mov    %esi,%ebx
  800c39:	80 fb 19             	cmp    $0x19,%bl
  800c3c:	77 08                	ja     800c46 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c3e:	0f be d2             	movsbl %dl,%edx
  800c41:	83 ea 57             	sub    $0x57,%edx
  800c44:	eb 10                	jmp    800c56 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c49:	89 f3                	mov    %esi,%ebx
  800c4b:	80 fb 19             	cmp    $0x19,%bl
  800c4e:	77 16                	ja     800c66 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c50:	0f be d2             	movsbl %dl,%edx
  800c53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c56:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c59:	7d 0b                	jge    800c66 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c5b:	83 c1 01             	add    $0x1,%ecx
  800c5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c62:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c64:	eb b9                	jmp    800c1f <strtol+0x76>

	if (endptr)
  800c66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6a:	74 0d                	je     800c79 <strtol+0xd0>
		*endptr = (char *) s;
  800c6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6f:	89 0e                	mov    %ecx,(%esi)
  800c71:	eb 06                	jmp    800c79 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c73:	85 db                	test   %ebx,%ebx
  800c75:	74 98                	je     800c0f <strtol+0x66>
  800c77:	eb 9e                	jmp    800c17 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	f7 da                	neg    %edx
  800c7d:	85 ff                	test   %edi,%edi
  800c7f:	0f 45 c2             	cmovne %edx,%eax
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 c3                	mov    %eax,%ebx
  800c9a:	89 c7                	mov    %eax,%edi
  800c9c:	89 c6                	mov    %eax,%esi
  800c9e:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800ccd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd2:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 cb                	mov    %ecx,%ebx
  800cdc:	89 cf                	mov    %ecx,%edi
  800cde:	89 ce                	mov    %ecx,%esi
  800ce0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 03                	push   $0x3
  800cec:	68 df 27 80 00       	push   $0x8027df
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 fc 27 80 00       	push   $0x8027fc
  800cf8:	e8 9b f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 02 00 00 00       	mov    $0x2,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_yield>:

void
sys_yield(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 d3                	mov    %edx,%ebx
  800d38:	89 d7                	mov    %edx,%edi
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 04 00 00 00       	mov    $0x4,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	89 f7                	mov    %esi,%edi
  800d61:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7e 17                	jle    800d7e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	50                   	push   %eax
  800d6b:	6a 04                	push   $0x4
  800d6d:	68 df 27 80 00       	push   $0x8027df
  800d72:	6a 23                	push   $0x23
  800d74:	68 fc 27 80 00       	push   $0x8027fc
  800d79:	e8 1a f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da0:	8b 75 18             	mov    0x18(%ebp),%esi
  800da3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 05                	push   $0x5
  800daf:	68 df 27 80 00       	push   $0x8027df
  800db4:	6a 23                	push   $0x23
  800db6:	68 fc 27 80 00       	push   $0x8027fc
  800dbb:	e8 d8 f4 ff ff       	call   800298 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 06                	push   $0x6
  800df1:	68 df 27 80 00       	push   $0x8027df
  800df6:	6a 23                	push   $0x23
  800df8:	68 fc 27 80 00       	push   $0x8027fc
  800dfd:	e8 96 f4 ff ff       	call   800298 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 08 00 00 00       	mov    $0x8,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 08                	push   $0x8
  800e33:	68 df 27 80 00       	push   $0x8027df
  800e38:	6a 23                	push   $0x23
  800e3a:	68 fc 27 80 00       	push   $0x8027fc
  800e3f:	e8 54 f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 09                	push   $0x9
  800e75:	68 df 27 80 00       	push   $0x8027df
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 fc 27 80 00       	push   $0x8027fc
  800e81:	e8 12 f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 17                	jle    800ec8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	6a 0a                	push   $0xa
  800eb7:	68 df 27 80 00       	push   $0x8027df
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 fc 27 80 00       	push   $0x8027fc
  800ec3:	e8 d0 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ed6:	be 00 00 00 00       	mov    $0x0,%esi
  800edb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eec:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800efc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f01:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f06:	8b 55 08             	mov    0x8(%ebp),%edx
  800f09:	89 cb                	mov    %ecx,%ebx
  800f0b:	89 cf                	mov    %ecx,%edi
  800f0d:	89 ce                	mov    %ecx,%esi
  800f0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7e 17                	jle    800f2c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	50                   	push   %eax
  800f19:	6a 0d                	push   $0xd
  800f1b:	68 df 27 80 00       	push   $0x8027df
  800f20:	6a 23                	push   $0x23
  800f22:	68 fc 27 80 00       	push   $0x8027fc
  800f27:	e8 6c f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3c:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800f3e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f42:	74 11                	je     800f55 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800f44:	89 d8                	mov    %ebx,%eax
  800f46:	c1 e8 0c             	shr    $0xc,%eax
  800f49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800f50:	f6 c4 08             	test   $0x8,%ah
  800f53:	75 14                	jne    800f69 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	68 0a 28 80 00       	push   $0x80280a
  800f5d:	6a 21                	push   $0x21
  800f5f:	68 20 28 80 00       	push   $0x802820
  800f64:	e8 2f f3 ff ff       	call   800298 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800f69:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f6f:	e8 91 fd ff ff       	call   800d05 <sys_getenvid>
  800f74:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	6a 07                	push   $0x7
  800f7b:	68 00 f0 7f 00       	push   $0x7ff000
  800f80:	50                   	push   %eax
  800f81:	e8 bd fd ff ff       	call   800d43 <sys_page_alloc>
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 14                	jns    800fa1 <pgfault+0x6d>
		panic("sys_page_alloc");
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	68 2b 28 80 00       	push   $0x80282b
  800f95:	6a 30                	push   $0x30
  800f97:	68 20 28 80 00       	push   $0x802820
  800f9c:	e8 f7 f2 ff ff       	call   800298 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	68 00 10 00 00       	push   $0x1000
  800fa9:	53                   	push   %ebx
  800faa:	68 00 f0 7f 00       	push   $0x7ff000
  800faf:	e8 86 fb ff ff       	call   800b3a <memcpy>
	retv = sys_page_unmap(envid, addr);
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	53                   	push   %ebx
  800fb8:	56                   	push   %esi
  800fb9:	e8 0a fe ff ff       	call   800dc8 <sys_page_unmap>
	if(retv < 0){
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	79 12                	jns    800fd7 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800fc5:	50                   	push   %eax
  800fc6:	68 18 29 80 00       	push   $0x802918
  800fcb:	6a 35                	push   $0x35
  800fcd:	68 20 28 80 00       	push   $0x802820
  800fd2:	e8 c1 f2 ff ff       	call   800298 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	6a 07                	push   $0x7
  800fdc:	53                   	push   %ebx
  800fdd:	56                   	push   %esi
  800fde:	68 00 f0 7f 00       	push   $0x7ff000
  800fe3:	56                   	push   %esi
  800fe4:	e8 9d fd ff ff       	call   800d86 <sys_page_map>
	if(retv < 0){
  800fe9:	83 c4 20             	add    $0x20,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	79 14                	jns    801004 <pgfault+0xd0>
		panic("sys_page_map");
  800ff0:	83 ec 04             	sub    $0x4,%esp
  800ff3:	68 3a 28 80 00       	push   $0x80283a
  800ff8:	6a 39                	push   $0x39
  800ffa:	68 20 28 80 00       	push   $0x802820
  800fff:	e8 94 f2 ff ff       	call   800298 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  801004:	83 ec 08             	sub    $0x8,%esp
  801007:	68 00 f0 7f 00       	push   $0x7ff000
  80100c:	56                   	push   %esi
  80100d:	e8 b6 fd ff ff       	call   800dc8 <sys_page_unmap>
	if(retv < 0){
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	79 14                	jns    80102d <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	68 47 28 80 00       	push   $0x802847
  801021:	6a 3d                	push   $0x3d
  801023:	68 20 28 80 00       	push   $0x802820
  801028:	e8 6b f2 ff ff       	call   800298 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  80102d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  80103c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80103f:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  801042:	83 ec 08             	sub    $0x8,%esp
  801045:	53                   	push   %ebx
  801046:	68 64 28 80 00       	push   $0x802864
  80104b:	e8 21 f3 ff ff       	call   800371 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801050:	83 c4 0c             	add    $0xc,%esp
  801053:	6a 07                	push   $0x7
  801055:	53                   	push   %ebx
  801056:	56                   	push   %esi
  801057:	e8 e7 fc ff ff       	call   800d43 <sys_page_alloc>
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 15                	jns    801078 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  801063:	50                   	push   %eax
  801064:	68 77 28 80 00       	push   $0x802877
  801069:	68 90 00 00 00       	push   $0x90
  80106e:	68 20 28 80 00       	push   $0x802820
  801073:	e8 20 f2 ff ff       	call   800298 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	68 8a 28 80 00       	push   $0x80288a
  801080:	e8 ec f2 ff ff       	call   800371 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801085:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80108c:	68 00 00 40 00       	push   $0x400000
  801091:	6a 00                	push   $0x0
  801093:	53                   	push   %ebx
  801094:	56                   	push   %esi
  801095:	e8 ec fc ff ff       	call   800d86 <sys_page_map>
  80109a:	83 c4 20             	add    $0x20,%esp
  80109d:	85 c0                	test   %eax,%eax
  80109f:	79 15                	jns    8010b6 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  8010a1:	50                   	push   %eax
  8010a2:	68 92 28 80 00       	push   $0x802892
  8010a7:	68 94 00 00 00       	push   $0x94
  8010ac:	68 20 28 80 00       	push   $0x802820
  8010b1:	e8 e2 f1 ff ff       	call   800298 <_panic>
        cprintf("af_p_m.");
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	68 a3 28 80 00       	push   $0x8028a3
  8010be:	e8 ae f2 ff ff       	call   800371 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  8010c3:	83 c4 0c             	add    $0xc,%esp
  8010c6:	68 00 10 00 00       	push   $0x1000
  8010cb:	53                   	push   %ebx
  8010cc:	68 00 00 40 00       	push   $0x400000
  8010d1:	e8 fc f9 ff ff       	call   800ad2 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  8010d6:	c7 04 24 ab 28 80 00 	movl   $0x8028ab,(%esp)
  8010dd:	e8 8f f2 ff ff       	call   800371 <cprintf>
}
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  8010f5:	68 34 0f 80 00       	push   $0x800f34
  8010fa:	e8 c5 0e 00 00       	call   801fc4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010ff:	b8 07 00 00 00       	mov    $0x7,%eax
  801104:	cd 30                	int    $0x30
  801106:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801109:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	79 17                	jns    80112a <fork+0x3e>
		panic("sys_exofork failed.");
  801113:	83 ec 04             	sub    $0x4,%esp
  801116:	68 b9 28 80 00       	push   $0x8028b9
  80111b:	68 b7 00 00 00       	push   $0xb7
  801120:	68 20 28 80 00       	push   $0x802820
  801125:	e8 6e f1 ff ff       	call   800298 <_panic>
  80112a:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  80112f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801133:	75 21                	jne    801156 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801135:	e8 cb fb ff ff       	call   800d05 <sys_getenvid>
  80113a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80113f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801142:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801147:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  80114c:	b8 00 00 00 00       	mov    $0x0,%eax
  801151:	e9 69 01 00 00       	jmp    8012bf <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801156:	89 d8                	mov    %ebx,%eax
  801158:	c1 e8 16             	shr    $0x16,%eax
  80115b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  801162:	a8 01                	test   $0x1,%al
  801164:	0f 84 d6 00 00 00    	je     801240 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  80116a:	89 de                	mov    %ebx,%esi
  80116c:	c1 ee 0c             	shr    $0xc,%esi
  80116f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801176:	a8 01                	test   $0x1,%al
  801178:	0f 84 c2 00 00 00    	je     801240 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  80117e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  801185:	89 f7                	mov    %esi,%edi
  801187:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  80118a:	e8 76 fb ff ff       	call   800d05 <sys_getenvid>
  80118f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  801192:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801199:	f6 c4 04             	test   $0x4,%ah
  80119c:	74 1c                	je     8011ba <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	68 07 0e 00 00       	push   $0xe07
  8011a6:	57                   	push   %edi
  8011a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011aa:	57                   	push   %edi
  8011ab:	6a 00                	push   $0x0
  8011ad:	e8 d4 fb ff ff       	call   800d86 <sys_page_map>
  8011b2:	83 c4 20             	add    $0x20,%esp
  8011b5:	e9 86 00 00 00       	jmp    801240 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  8011ba:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c1:	a8 02                	test   $0x2,%al
  8011c3:	75 0c                	jne    8011d1 <fork+0xe5>
  8011c5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011cc:	f6 c4 08             	test   $0x8,%ah
  8011cf:	74 5b                	je     80122c <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	68 05 08 00 00       	push   $0x805
  8011d9:	57                   	push   %edi
  8011da:	ff 75 e0             	pushl  -0x20(%ebp)
  8011dd:	57                   	push   %edi
  8011de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e1:	e8 a0 fb ff ff       	call   800d86 <sys_page_map>
  8011e6:	83 c4 20             	add    $0x20,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	79 12                	jns    8011ff <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  8011ed:	50                   	push   %eax
  8011ee:	68 3c 29 80 00       	push   $0x80293c
  8011f3:	6a 5f                	push   $0x5f
  8011f5:	68 20 28 80 00       	push   $0x802820
  8011fa:	e8 99 f0 ff ff       	call   800298 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  8011ff:	83 ec 0c             	sub    $0xc,%esp
  801202:	68 05 08 00 00       	push   $0x805
  801207:	57                   	push   %edi
  801208:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	57                   	push   %edi
  80120d:	50                   	push   %eax
  80120e:	e8 73 fb ff ff       	call   800d86 <sys_page_map>
  801213:	83 c4 20             	add    $0x20,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	79 26                	jns    801240 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  80121a:	50                   	push   %eax
  80121b:	68 60 29 80 00       	push   $0x802960
  801220:	6a 64                	push   $0x64
  801222:	68 20 28 80 00       	push   $0x802820
  801227:	e8 6c f0 ff ff       	call   800298 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80122c:	83 ec 0c             	sub    $0xc,%esp
  80122f:	6a 05                	push   $0x5
  801231:	57                   	push   %edi
  801232:	ff 75 e0             	pushl  -0x20(%ebp)
  801235:	57                   	push   %edi
  801236:	6a 00                	push   $0x0
  801238:	e8 49 fb ff ff       	call   800d86 <sys_page_map>
  80123d:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801240:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801246:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80124c:	0f 85 04 ff ff ff    	jne    801156 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  801252:	83 ec 04             	sub    $0x4,%esp
  801255:	6a 07                	push   $0x7
  801257:	68 00 f0 bf ee       	push   $0xeebff000
  80125c:	ff 75 dc             	pushl  -0x24(%ebp)
  80125f:	e8 df fa ff ff       	call   800d43 <sys_page_alloc>
	if(retv < 0){
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	79 17                	jns    801282 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  80126b:	83 ec 04             	sub    $0x4,%esp
  80126e:	68 cd 28 80 00       	push   $0x8028cd
  801273:	68 cc 00 00 00       	push   $0xcc
  801278:	68 20 28 80 00       	push   $0x802820
  80127d:	e8 16 f0 ff ff       	call   800298 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	68 29 20 80 00       	push   $0x802029
  80128a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80128d:	57                   	push   %edi
  80128e:	e8 fb fb ff ff       	call   800e8e <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  801293:	83 c4 08             	add    $0x8,%esp
  801296:	6a 02                	push   $0x2
  801298:	57                   	push   %edi
  801299:	e8 6c fb ff ff       	call   800e0a <sys_env_set_status>
	if(retv < 0){
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	79 17                	jns    8012bc <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  8012a5:	83 ec 04             	sub    $0x4,%esp
  8012a8:	68 e5 28 80 00       	push   $0x8028e5
  8012ad:	68 dd 00 00 00       	push   $0xdd
  8012b2:	68 20 28 80 00       	push   $0x802820
  8012b7:	e8 dc ef ff ff       	call   800298 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  8012bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  8012bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5f                   	pop    %edi
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <sfork>:

// Challenge!
int
sfork(void)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012cd:	68 01 29 80 00       	push   $0x802901
  8012d2:	68 e8 00 00 00       	push   $0xe8
  8012d7:	68 20 28 80 00       	push   $0x802820
  8012dc:	e8 b7 ef ff ff       	call   800298 <_panic>

008012e1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ec:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f7:	05 00 00 00 30       	add    $0x30000000,%eax
  8012fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801301:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801313:	89 c2                	mov    %eax,%edx
  801315:	c1 ea 16             	shr    $0x16,%edx
  801318:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80131f:	f6 c2 01             	test   $0x1,%dl
  801322:	74 11                	je     801335 <fd_alloc+0x2d>
  801324:	89 c2                	mov    %eax,%edx
  801326:	c1 ea 0c             	shr    $0xc,%edx
  801329:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801330:	f6 c2 01             	test   $0x1,%dl
  801333:	75 09                	jne    80133e <fd_alloc+0x36>
			*fd_store = fd;
  801335:	89 01                	mov    %eax,(%ecx)
			return 0;
  801337:	b8 00 00 00 00       	mov    $0x0,%eax
  80133c:	eb 17                	jmp    801355 <fd_alloc+0x4d>
  80133e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801343:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801348:	75 c9                	jne    801313 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80134a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801350:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    

00801357 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80135d:	83 f8 1f             	cmp    $0x1f,%eax
  801360:	77 36                	ja     801398 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801362:	c1 e0 0c             	shl    $0xc,%eax
  801365:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	c1 ea 16             	shr    $0x16,%edx
  80136f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801376:	f6 c2 01             	test   $0x1,%dl
  801379:	74 24                	je     80139f <fd_lookup+0x48>
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	c1 ea 0c             	shr    $0xc,%edx
  801380:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801387:	f6 c2 01             	test   $0x1,%dl
  80138a:	74 1a                	je     8013a6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80138c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138f:	89 02                	mov    %eax,(%edx)
	return 0;
  801391:	b8 00 00 00 00       	mov    $0x0,%eax
  801396:	eb 13                	jmp    8013ab <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801398:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139d:	eb 0c                	jmp    8013ab <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80139f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a4:	eb 05                	jmp    8013ab <fd_lookup+0x54>
  8013a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b6:	ba 00 2a 80 00       	mov    $0x802a00,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013bb:	eb 13                	jmp    8013d0 <dev_lookup+0x23>
  8013bd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013c0:	39 08                	cmp    %ecx,(%eax)
  8013c2:	75 0c                	jne    8013d0 <dev_lookup+0x23>
			*dev = devtab[i];
  8013c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ce:	eb 2e                	jmp    8013fe <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013d0:	8b 02                	mov    (%edx),%eax
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	75 e7                	jne    8013bd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8013db:	8b 40 48             	mov    0x48(%eax),%eax
  8013de:	83 ec 04             	sub    $0x4,%esp
  8013e1:	51                   	push   %ecx
  8013e2:	50                   	push   %eax
  8013e3:	68 84 29 80 00       	push   $0x802984
  8013e8:	e8 84 ef ff ff       	call   800371 <cprintf>
	*dev = 0;
  8013ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	56                   	push   %esi
  801404:	53                   	push   %ebx
  801405:	83 ec 10             	sub    $0x10,%esp
  801408:	8b 75 08             	mov    0x8(%ebp),%esi
  80140b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80140e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801411:	50                   	push   %eax
  801412:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801418:	c1 e8 0c             	shr    $0xc,%eax
  80141b:	50                   	push   %eax
  80141c:	e8 36 ff ff ff       	call   801357 <fd_lookup>
  801421:	83 c4 08             	add    $0x8,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 05                	js     80142d <fd_close+0x2d>
	    || fd != fd2)
  801428:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80142b:	74 0c                	je     801439 <fd_close+0x39>
		return (must_exist ? r : 0);
  80142d:	84 db                	test   %bl,%bl
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	0f 44 c2             	cmove  %edx,%eax
  801437:	eb 41                	jmp    80147a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	ff 36                	pushl  (%esi)
  801442:	e8 66 ff ff ff       	call   8013ad <dev_lookup>
  801447:	89 c3                	mov    %eax,%ebx
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 1a                	js     80146a <fd_close+0x6a>
		if (dev->dev_close)
  801450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801453:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801456:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80145b:	85 c0                	test   %eax,%eax
  80145d:	74 0b                	je     80146a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80145f:	83 ec 0c             	sub    $0xc,%esp
  801462:	56                   	push   %esi
  801463:	ff d0                	call   *%eax
  801465:	89 c3                	mov    %eax,%ebx
  801467:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	56                   	push   %esi
  80146e:	6a 00                	push   $0x0
  801470:	e8 53 f9 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	89 d8                	mov    %ebx,%eax
}
  80147a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    

00801481 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	ff 75 08             	pushl  0x8(%ebp)
  80148e:	e8 c4 fe ff ff       	call   801357 <fd_lookup>
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 10                	js     8014aa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	6a 01                	push   $0x1
  80149f:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a2:	e8 59 ff ff ff       	call   801400 <fd_close>
  8014a7:	83 c4 10             	add    $0x10,%esp
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <close_all>:

void
close_all(void)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	53                   	push   %ebx
  8014bc:	e8 c0 ff ff ff       	call   801481 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014c1:	83 c3 01             	add    $0x1,%ebx
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	83 fb 20             	cmp    $0x20,%ebx
  8014ca:	75 ec                	jne    8014b8 <close_all+0xc>
		close(i);
}
  8014cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    

008014d1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	57                   	push   %edi
  8014d5:	56                   	push   %esi
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 2c             	sub    $0x2c,%esp
  8014da:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	ff 75 08             	pushl  0x8(%ebp)
  8014e4:	e8 6e fe ff ff       	call   801357 <fd_lookup>
  8014e9:	83 c4 08             	add    $0x8,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	0f 88 c1 00 00 00    	js     8015b5 <dup+0xe4>
		return r;
	close(newfdnum);
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	56                   	push   %esi
  8014f8:	e8 84 ff ff ff       	call   801481 <close>

	newfd = INDEX2FD(newfdnum);
  8014fd:	89 f3                	mov    %esi,%ebx
  8014ff:	c1 e3 0c             	shl    $0xc,%ebx
  801502:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801508:	83 c4 04             	add    $0x4,%esp
  80150b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80150e:	e8 de fd ff ff       	call   8012f1 <fd2data>
  801513:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801515:	89 1c 24             	mov    %ebx,(%esp)
  801518:	e8 d4 fd ff ff       	call   8012f1 <fd2data>
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801523:	89 f8                	mov    %edi,%eax
  801525:	c1 e8 16             	shr    $0x16,%eax
  801528:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80152f:	a8 01                	test   $0x1,%al
  801531:	74 37                	je     80156a <dup+0x99>
  801533:	89 f8                	mov    %edi,%eax
  801535:	c1 e8 0c             	shr    $0xc,%eax
  801538:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80153f:	f6 c2 01             	test   $0x1,%dl
  801542:	74 26                	je     80156a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801544:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80154b:	83 ec 0c             	sub    $0xc,%esp
  80154e:	25 07 0e 00 00       	and    $0xe07,%eax
  801553:	50                   	push   %eax
  801554:	ff 75 d4             	pushl  -0x2c(%ebp)
  801557:	6a 00                	push   $0x0
  801559:	57                   	push   %edi
  80155a:	6a 00                	push   $0x0
  80155c:	e8 25 f8 ff ff       	call   800d86 <sys_page_map>
  801561:	89 c7                	mov    %eax,%edi
  801563:	83 c4 20             	add    $0x20,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 2e                	js     801598 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80156d:	89 d0                	mov    %edx,%eax
  80156f:	c1 e8 0c             	shr    $0xc,%eax
  801572:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801579:	83 ec 0c             	sub    $0xc,%esp
  80157c:	25 07 0e 00 00       	and    $0xe07,%eax
  801581:	50                   	push   %eax
  801582:	53                   	push   %ebx
  801583:	6a 00                	push   $0x0
  801585:	52                   	push   %edx
  801586:	6a 00                	push   $0x0
  801588:	e8 f9 f7 ff ff       	call   800d86 <sys_page_map>
  80158d:	89 c7                	mov    %eax,%edi
  80158f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801592:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801594:	85 ff                	test   %edi,%edi
  801596:	79 1d                	jns    8015b5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	53                   	push   %ebx
  80159c:	6a 00                	push   $0x0
  80159e:	e8 25 f8 ff ff       	call   800dc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015a9:	6a 00                	push   $0x0
  8015ab:	e8 18 f8 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	89 f8                	mov    %edi,%eax
}
  8015b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5f                   	pop    %edi
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 14             	sub    $0x14,%esp
  8015c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	53                   	push   %ebx
  8015cc:	e8 86 fd ff ff       	call   801357 <fd_lookup>
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	89 c2                	mov    %eax,%edx
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 6d                	js     801647 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e4:	ff 30                	pushl  (%eax)
  8015e6:	e8 c2 fd ff ff       	call   8013ad <dev_lookup>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 4c                	js     80163e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015f5:	8b 42 08             	mov    0x8(%edx),%eax
  8015f8:	83 e0 03             	and    $0x3,%eax
  8015fb:	83 f8 01             	cmp    $0x1,%eax
  8015fe:	75 21                	jne    801621 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801600:	a1 04 40 80 00       	mov    0x804004,%eax
  801605:	8b 40 48             	mov    0x48(%eax),%eax
  801608:	83 ec 04             	sub    $0x4,%esp
  80160b:	53                   	push   %ebx
  80160c:	50                   	push   %eax
  80160d:	68 c5 29 80 00       	push   $0x8029c5
  801612:	e8 5a ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80161f:	eb 26                	jmp    801647 <read+0x8a>
	}
	if (!dev->dev_read)
  801621:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801624:	8b 40 08             	mov    0x8(%eax),%eax
  801627:	85 c0                	test   %eax,%eax
  801629:	74 17                	je     801642 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	ff 75 10             	pushl  0x10(%ebp)
  801631:	ff 75 0c             	pushl  0xc(%ebp)
  801634:	52                   	push   %edx
  801635:	ff d0                	call   *%eax
  801637:	89 c2                	mov    %eax,%edx
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	eb 09                	jmp    801647 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163e:	89 c2                	mov    %eax,%edx
  801640:	eb 05                	jmp    801647 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801642:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801647:	89 d0                	mov    %edx,%eax
  801649:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	57                   	push   %edi
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 0c             	sub    $0xc,%esp
  801657:	8b 7d 08             	mov    0x8(%ebp),%edi
  80165a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801662:	eb 21                	jmp    801685 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801664:	83 ec 04             	sub    $0x4,%esp
  801667:	89 f0                	mov    %esi,%eax
  801669:	29 d8                	sub    %ebx,%eax
  80166b:	50                   	push   %eax
  80166c:	89 d8                	mov    %ebx,%eax
  80166e:	03 45 0c             	add    0xc(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	57                   	push   %edi
  801673:	e8 45 ff ff ff       	call   8015bd <read>
		if (m < 0)
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 10                	js     80168f <readn+0x41>
			return m;
		if (m == 0)
  80167f:	85 c0                	test   %eax,%eax
  801681:	74 0a                	je     80168d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801683:	01 c3                	add    %eax,%ebx
  801685:	39 f3                	cmp    %esi,%ebx
  801687:	72 db                	jb     801664 <readn+0x16>
  801689:	89 d8                	mov    %ebx,%eax
  80168b:	eb 02                	jmp    80168f <readn+0x41>
  80168d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80168f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5f                   	pop    %edi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 14             	sub    $0x14,%esp
  80169e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a4:	50                   	push   %eax
  8016a5:	53                   	push   %ebx
  8016a6:	e8 ac fc ff ff       	call   801357 <fd_lookup>
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 68                	js     80171c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ba:	50                   	push   %eax
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	ff 30                	pushl  (%eax)
  8016c0:	e8 e8 fc ff ff       	call   8013ad <dev_lookup>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 47                	js     801713 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d3:	75 21                	jne    8016f6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8016da:	8b 40 48             	mov    0x48(%eax),%eax
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	53                   	push   %ebx
  8016e1:	50                   	push   %eax
  8016e2:	68 e1 29 80 00       	push   $0x8029e1
  8016e7:	e8 85 ec ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f4:	eb 26                	jmp    80171c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8016fc:	85 d2                	test   %edx,%edx
  8016fe:	74 17                	je     801717 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	ff 75 10             	pushl  0x10(%ebp)
  801706:	ff 75 0c             	pushl  0xc(%ebp)
  801709:	50                   	push   %eax
  80170a:	ff d2                	call   *%edx
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	eb 09                	jmp    80171c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801713:	89 c2                	mov    %eax,%edx
  801715:	eb 05                	jmp    80171c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801717:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80171c:	89 d0                	mov    %edx,%eax
  80171e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <seek>:

int
seek(int fdnum, off_t offset)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801729:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	ff 75 08             	pushl  0x8(%ebp)
  801730:	e8 22 fc ff ff       	call   801357 <fd_lookup>
  801735:	83 c4 08             	add    $0x8,%esp
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 0e                	js     80174a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80173c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80173f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801742:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801745:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 14             	sub    $0x14,%esp
  801753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801759:	50                   	push   %eax
  80175a:	53                   	push   %ebx
  80175b:	e8 f7 fb ff ff       	call   801357 <fd_lookup>
  801760:	83 c4 08             	add    $0x8,%esp
  801763:	89 c2                	mov    %eax,%edx
  801765:	85 c0                	test   %eax,%eax
  801767:	78 65                	js     8017ce <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176f:	50                   	push   %eax
  801770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801773:	ff 30                	pushl  (%eax)
  801775:	e8 33 fc ff ff       	call   8013ad <dev_lookup>
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 44                	js     8017c5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801788:	75 21                	jne    8017ab <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80178a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80178f:	8b 40 48             	mov    0x48(%eax),%eax
  801792:	83 ec 04             	sub    $0x4,%esp
  801795:	53                   	push   %ebx
  801796:	50                   	push   %eax
  801797:	68 a4 29 80 00       	push   $0x8029a4
  80179c:	e8 d0 eb ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a9:	eb 23                	jmp    8017ce <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ae:	8b 52 18             	mov    0x18(%edx),%edx
  8017b1:	85 d2                	test   %edx,%edx
  8017b3:	74 14                	je     8017c9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	ff 75 0c             	pushl  0xc(%ebp)
  8017bb:	50                   	push   %eax
  8017bc:	ff d2                	call   *%edx
  8017be:	89 c2                	mov    %eax,%edx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	eb 09                	jmp    8017ce <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c5:	89 c2                	mov    %eax,%edx
  8017c7:	eb 05                	jmp    8017ce <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017ce:	89 d0                	mov    %edx,%eax
  8017d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 14             	sub    $0x14,%esp
  8017dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e2:	50                   	push   %eax
  8017e3:	ff 75 08             	pushl  0x8(%ebp)
  8017e6:	e8 6c fb ff ff       	call   801357 <fd_lookup>
  8017eb:	83 c4 08             	add    $0x8,%esp
  8017ee:	89 c2                	mov    %eax,%edx
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 58                	js     80184c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f4:	83 ec 08             	sub    $0x8,%esp
  8017f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fa:	50                   	push   %eax
  8017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fe:	ff 30                	pushl  (%eax)
  801800:	e8 a8 fb ff ff       	call   8013ad <dev_lookup>
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 37                	js     801843 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80180c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801813:	74 32                	je     801847 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801815:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801818:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80181f:	00 00 00 
	stat->st_isdir = 0;
  801822:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801829:	00 00 00 
	stat->st_dev = dev;
  80182c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801832:	83 ec 08             	sub    $0x8,%esp
  801835:	53                   	push   %ebx
  801836:	ff 75 f0             	pushl  -0x10(%ebp)
  801839:	ff 50 14             	call   *0x14(%eax)
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	eb 09                	jmp    80184c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801843:	89 c2                	mov    %eax,%edx
  801845:	eb 05                	jmp    80184c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801847:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80184c:	89 d0                	mov    %edx,%eax
  80184e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	56                   	push   %esi
  801857:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	6a 00                	push   $0x0
  80185d:	ff 75 08             	pushl  0x8(%ebp)
  801860:	e8 dc 01 00 00       	call   801a41 <open>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 1b                	js     801889 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	ff 75 0c             	pushl  0xc(%ebp)
  801874:	50                   	push   %eax
  801875:	e8 5b ff ff ff       	call   8017d5 <fstat>
  80187a:	89 c6                	mov    %eax,%esi
	close(fd);
  80187c:	89 1c 24             	mov    %ebx,(%esp)
  80187f:	e8 fd fb ff ff       	call   801481 <close>
	return r;
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	89 f0                	mov    %esi,%eax
}
  801889:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188c:	5b                   	pop    %ebx
  80188d:	5e                   	pop    %esi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	89 c6                	mov    %eax,%esi
  801897:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801899:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018a0:	75 12                	jne    8018b4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018a2:	83 ec 0c             	sub    $0xc,%esp
  8018a5:	6a 01                	push   $0x1
  8018a7:	e8 41 08 00 00       	call   8020ed <ipc_find_env>
  8018ac:	a3 00 40 80 00       	mov    %eax,0x804000
  8018b1:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018b4:	6a 07                	push   $0x7
  8018b6:	68 00 50 80 00       	push   $0x805000
  8018bb:	56                   	push   %esi
  8018bc:	ff 35 00 40 80 00    	pushl  0x804000
  8018c2:	e8 e3 07 00 00       	call   8020aa <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8018c7:	83 c4 0c             	add    $0xc,%esp
  8018ca:	6a 00                	push   $0x0
  8018cc:	53                   	push   %ebx
  8018cd:	6a 00                	push   $0x0
  8018cf:	e8 79 07 00 00       	call   80204d <ipc_recv>
}
  8018d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d7:	5b                   	pop    %ebx
  8018d8:	5e                   	pop    %esi
  8018d9:	5d                   	pop    %ebp
  8018da:	c3                   	ret    

008018db <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ef:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8018fe:	e8 8d ff ff ff       	call   801890 <fsipc>
}
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	8b 40 0c             	mov    0xc(%eax),%eax
  801911:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801916:	ba 00 00 00 00       	mov    $0x0,%edx
  80191b:	b8 06 00 00 00       	mov    $0x6,%eax
  801920:	e8 6b ff ff ff       	call   801890 <fsipc>
}
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	53                   	push   %ebx
  80192b:	83 ec 04             	sub    $0x4,%esp
  80192e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801931:	8b 45 08             	mov    0x8(%ebp),%eax
  801934:	8b 40 0c             	mov    0xc(%eax),%eax
  801937:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80193c:	ba 00 00 00 00       	mov    $0x0,%edx
  801941:	b8 05 00 00 00       	mov    $0x5,%eax
  801946:	e8 45 ff ff ff       	call   801890 <fsipc>
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 2c                	js     80197b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	68 00 50 80 00       	push   $0x805000
  801957:	53                   	push   %ebx
  801958:	e8 e3 ef ff ff       	call   800940 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80195d:	a1 80 50 80 00       	mov    0x805080,%eax
  801962:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801968:	a1 84 50 80 00       	mov    0x805084,%eax
  80196d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80197b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801989:	8b 55 08             	mov    0x8(%ebp),%edx
  80198c:	8b 52 0c             	mov    0xc(%edx),%edx
  80198f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801995:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80199a:	50                   	push   %eax
  80199b:	ff 75 0c             	pushl  0xc(%ebp)
  80199e:	68 08 50 80 00       	push   $0x805008
  8019a3:	e8 2a f1 ff ff       	call   800ad2 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8019a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b2:	e8 d9 fe ff ff       	call   801890 <fsipc>
	//panic("devfile_write not implemented");
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	56                   	push   %esi
  8019bd:	53                   	push   %ebx
  8019be:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019cc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8019dc:	e8 af fe ff ff       	call   801890 <fsipc>
  8019e1:	89 c3                	mov    %eax,%ebx
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 51                	js     801a38 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8019e7:	39 c6                	cmp    %eax,%esi
  8019e9:	73 19                	jae    801a04 <devfile_read+0x4b>
  8019eb:	68 10 2a 80 00       	push   $0x802a10
  8019f0:	68 17 2a 80 00       	push   $0x802a17
  8019f5:	68 80 00 00 00       	push   $0x80
  8019fa:	68 2c 2a 80 00       	push   $0x802a2c
  8019ff:	e8 94 e8 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801a04:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a09:	7e 19                	jle    801a24 <devfile_read+0x6b>
  801a0b:	68 37 2a 80 00       	push   $0x802a37
  801a10:	68 17 2a 80 00       	push   $0x802a17
  801a15:	68 81 00 00 00       	push   $0x81
  801a1a:	68 2c 2a 80 00       	push   $0x802a2c
  801a1f:	e8 74 e8 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	50                   	push   %eax
  801a28:	68 00 50 80 00       	push   $0x805000
  801a2d:	ff 75 0c             	pushl  0xc(%ebp)
  801a30:	e8 9d f0 ff ff       	call   800ad2 <memmove>
	return r;
  801a35:	83 c4 10             	add    $0x10,%esp
}
  801a38:	89 d8                	mov    %ebx,%eax
  801a3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5e                   	pop    %esi
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	53                   	push   %ebx
  801a45:	83 ec 20             	sub    $0x20,%esp
  801a48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a4b:	53                   	push   %ebx
  801a4c:	e8 b6 ee ff ff       	call   800907 <strlen>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a59:	7f 67                	jg     801ac2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a61:	50                   	push   %eax
  801a62:	e8 a1 f8 ff ff       	call   801308 <fd_alloc>
  801a67:	83 c4 10             	add    $0x10,%esp
		return r;
  801a6a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	78 57                	js     801ac7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	53                   	push   %ebx
  801a74:	68 00 50 80 00       	push   $0x805000
  801a79:	e8 c2 ee ff ff       	call   800940 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a81:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a89:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8e:	e8 fd fd ff ff       	call   801890 <fsipc>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	79 14                	jns    801ab0 <open+0x6f>
		
		fd_close(fd, 0);
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	6a 00                	push   $0x0
  801aa1:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa4:	e8 57 f9 ff ff       	call   801400 <fd_close>
		return r;
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	89 da                	mov    %ebx,%edx
  801aae:	eb 17                	jmp    801ac7 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801ab0:	83 ec 0c             	sub    $0xc,%esp
  801ab3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab6:	e8 26 f8 ff ff       	call   8012e1 <fd2num>
  801abb:	89 c2                	mov    %eax,%edx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	eb 05                	jmp    801ac7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ac2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801ac7:	89 d0                	mov    %edx,%eax
  801ac9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad9:	b8 08 00 00 00       	mov    $0x8,%eax
  801ade:	e8 ad fd ff ff       	call   801890 <fsipc>
}
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	56                   	push   %esi
  801ae9:	53                   	push   %ebx
  801aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	ff 75 08             	pushl  0x8(%ebp)
  801af3:	e8 f9 f7 ff ff       	call   8012f1 <fd2data>
  801af8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801afa:	83 c4 08             	add    $0x8,%esp
  801afd:	68 43 2a 80 00       	push   $0x802a43
  801b02:	53                   	push   %ebx
  801b03:	e8 38 ee ff ff       	call   800940 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b08:	8b 46 04             	mov    0x4(%esi),%eax
  801b0b:	2b 06                	sub    (%esi),%eax
  801b0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b1a:	00 00 00 
	stat->st_dev = &devpipe;
  801b1d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b24:	30 80 00 
	return 0;
}
  801b27:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b3d:	53                   	push   %ebx
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 83 f2 ff ff       	call   800dc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b45:	89 1c 24             	mov    %ebx,(%esp)
  801b48:	e8 a4 f7 ff ff       	call   8012f1 <fd2data>
  801b4d:	83 c4 08             	add    $0x8,%esp
  801b50:	50                   	push   %eax
  801b51:	6a 00                	push   $0x0
  801b53:	e8 70 f2 ff ff       	call   800dc8 <sys_page_unmap>
}
  801b58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5b:	c9                   	leave  
  801b5c:	c3                   	ret    

00801b5d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	57                   	push   %edi
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
  801b63:	83 ec 1c             	sub    $0x1c,%esp
  801b66:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b69:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b70:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	ff 75 e0             	pushl  -0x20(%ebp)
  801b79:	e8 a8 05 00 00       	call   802126 <pageref>
  801b7e:	89 c3                	mov    %eax,%ebx
  801b80:	89 3c 24             	mov    %edi,(%esp)
  801b83:	e8 9e 05 00 00       	call   802126 <pageref>
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	39 c3                	cmp    %eax,%ebx
  801b8d:	0f 94 c1             	sete   %cl
  801b90:	0f b6 c9             	movzbl %cl,%ecx
  801b93:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b96:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b9c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b9f:	39 ce                	cmp    %ecx,%esi
  801ba1:	74 1b                	je     801bbe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ba3:	39 c3                	cmp    %eax,%ebx
  801ba5:	75 c4                	jne    801b6b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ba7:	8b 42 58             	mov    0x58(%edx),%eax
  801baa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bad:	50                   	push   %eax
  801bae:	56                   	push   %esi
  801baf:	68 4a 2a 80 00       	push   $0x802a4a
  801bb4:	e8 b8 e7 ff ff       	call   800371 <cprintf>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	eb ad                	jmp    801b6b <_pipeisclosed+0xe>
	}
}
  801bbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	57                   	push   %edi
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 28             	sub    $0x28,%esp
  801bd2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bd5:	56                   	push   %esi
  801bd6:	e8 16 f7 ff ff       	call   8012f1 <fd2data>
  801bdb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	bf 00 00 00 00       	mov    $0x0,%edi
  801be5:	eb 4b                	jmp    801c32 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801be7:	89 da                	mov    %ebx,%edx
  801be9:	89 f0                	mov    %esi,%eax
  801beb:	e8 6d ff ff ff       	call   801b5d <_pipeisclosed>
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	75 48                	jne    801c3c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bf4:	e8 2b f1 ff ff       	call   800d24 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bf9:	8b 43 04             	mov    0x4(%ebx),%eax
  801bfc:	8b 0b                	mov    (%ebx),%ecx
  801bfe:	8d 51 20             	lea    0x20(%ecx),%edx
  801c01:	39 d0                	cmp    %edx,%eax
  801c03:	73 e2                	jae    801be7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c08:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c0c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c0f:	89 c2                	mov    %eax,%edx
  801c11:	c1 fa 1f             	sar    $0x1f,%edx
  801c14:	89 d1                	mov    %edx,%ecx
  801c16:	c1 e9 1b             	shr    $0x1b,%ecx
  801c19:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c1c:	83 e2 1f             	and    $0x1f,%edx
  801c1f:	29 ca                	sub    %ecx,%edx
  801c21:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c25:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c29:	83 c0 01             	add    $0x1,%eax
  801c2c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2f:	83 c7 01             	add    $0x1,%edi
  801c32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c35:	75 c2                	jne    801bf9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c37:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3a:	eb 05                	jmp    801c41 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	57                   	push   %edi
  801c4d:	56                   	push   %esi
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 18             	sub    $0x18,%esp
  801c52:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c55:	57                   	push   %edi
  801c56:	e8 96 f6 ff ff       	call   8012f1 <fd2data>
  801c5b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c65:	eb 3d                	jmp    801ca4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c67:	85 db                	test   %ebx,%ebx
  801c69:	74 04                	je     801c6f <devpipe_read+0x26>
				return i;
  801c6b:	89 d8                	mov    %ebx,%eax
  801c6d:	eb 44                	jmp    801cb3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c6f:	89 f2                	mov    %esi,%edx
  801c71:	89 f8                	mov    %edi,%eax
  801c73:	e8 e5 fe ff ff       	call   801b5d <_pipeisclosed>
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	75 32                	jne    801cae <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c7c:	e8 a3 f0 ff ff       	call   800d24 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c81:	8b 06                	mov    (%esi),%eax
  801c83:	3b 46 04             	cmp    0x4(%esi),%eax
  801c86:	74 df                	je     801c67 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c88:	99                   	cltd   
  801c89:	c1 ea 1b             	shr    $0x1b,%edx
  801c8c:	01 d0                	add    %edx,%eax
  801c8e:	83 e0 1f             	and    $0x1f,%eax
  801c91:	29 d0                	sub    %edx,%eax
  801c93:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c9e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca1:	83 c3 01             	add    $0x1,%ebx
  801ca4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ca7:	75 d8                	jne    801c81 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ca9:	8b 45 10             	mov    0x10(%ebp),%eax
  801cac:	eb 05                	jmp    801cb3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5f                   	pop    %edi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	56                   	push   %esi
  801cbf:	53                   	push   %ebx
  801cc0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc6:	50                   	push   %eax
  801cc7:	e8 3c f6 ff ff       	call   801308 <fd_alloc>
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	89 c2                	mov    %eax,%edx
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	0f 88 2c 01 00 00    	js     801e05 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd9:	83 ec 04             	sub    $0x4,%esp
  801cdc:	68 07 04 00 00       	push   $0x407
  801ce1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce4:	6a 00                	push   $0x0
  801ce6:	e8 58 f0 ff ff       	call   800d43 <sys_page_alloc>
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	89 c2                	mov    %eax,%edx
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	0f 88 0d 01 00 00    	js     801e05 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cfe:	50                   	push   %eax
  801cff:	e8 04 f6 ff ff       	call   801308 <fd_alloc>
  801d04:	89 c3                	mov    %eax,%ebx
  801d06:	83 c4 10             	add    $0x10,%esp
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	0f 88 e2 00 00 00    	js     801df3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d11:	83 ec 04             	sub    $0x4,%esp
  801d14:	68 07 04 00 00       	push   $0x407
  801d19:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1c:	6a 00                	push   $0x0
  801d1e:	e8 20 f0 ff ff       	call   800d43 <sys_page_alloc>
  801d23:	89 c3                	mov    %eax,%ebx
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	0f 88 c3 00 00 00    	js     801df3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d30:	83 ec 0c             	sub    $0xc,%esp
  801d33:	ff 75 f4             	pushl  -0xc(%ebp)
  801d36:	e8 b6 f5 ff ff       	call   8012f1 <fd2data>
  801d3b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3d:	83 c4 0c             	add    $0xc,%esp
  801d40:	68 07 04 00 00       	push   $0x407
  801d45:	50                   	push   %eax
  801d46:	6a 00                	push   $0x0
  801d48:	e8 f6 ef ff ff       	call   800d43 <sys_page_alloc>
  801d4d:	89 c3                	mov    %eax,%ebx
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	85 c0                	test   %eax,%eax
  801d54:	0f 88 89 00 00 00    	js     801de3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d60:	e8 8c f5 ff ff       	call   8012f1 <fd2data>
  801d65:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d6c:	50                   	push   %eax
  801d6d:	6a 00                	push   $0x0
  801d6f:	56                   	push   %esi
  801d70:	6a 00                	push   $0x0
  801d72:	e8 0f f0 ff ff       	call   800d86 <sys_page_map>
  801d77:	89 c3                	mov    %eax,%ebx
  801d79:	83 c4 20             	add    $0x20,%esp
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	78 55                	js     801dd5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d80:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d89:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d95:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d9e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	ff 75 f4             	pushl  -0xc(%ebp)
  801db0:	e8 2c f5 ff ff       	call   8012e1 <fd2num>
  801db5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dba:	83 c4 04             	add    $0x4,%esp
  801dbd:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc0:	e8 1c f5 ff ff       	call   8012e1 <fd2num>
  801dc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd3:	eb 30                	jmp    801e05 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dd5:	83 ec 08             	sub    $0x8,%esp
  801dd8:	56                   	push   %esi
  801dd9:	6a 00                	push   $0x0
  801ddb:	e8 e8 ef ff ff       	call   800dc8 <sys_page_unmap>
  801de0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	ff 75 f0             	pushl  -0x10(%ebp)
  801de9:	6a 00                	push   $0x0
  801deb:	e8 d8 ef ff ff       	call   800dc8 <sys_page_unmap>
  801df0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801df3:	83 ec 08             	sub    $0x8,%esp
  801df6:	ff 75 f4             	pushl  -0xc(%ebp)
  801df9:	6a 00                	push   $0x0
  801dfb:	e8 c8 ef ff ff       	call   800dc8 <sys_page_unmap>
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e05:	89 d0                	mov    %edx,%eax
  801e07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0a:	5b                   	pop    %ebx
  801e0b:	5e                   	pop    %esi
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e17:	50                   	push   %eax
  801e18:	ff 75 08             	pushl  0x8(%ebp)
  801e1b:	e8 37 f5 ff ff       	call   801357 <fd_lookup>
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 18                	js     801e3f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e27:	83 ec 0c             	sub    $0xc,%esp
  801e2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2d:	e8 bf f4 ff ff       	call   8012f1 <fd2data>
	return _pipeisclosed(fd, p);
  801e32:	89 c2                	mov    %eax,%edx
  801e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e37:	e8 21 fd ff ff       	call   801b5d <_pipeisclosed>
  801e3c:	83 c4 10             	add    $0x10,%esp
}
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    

00801e41 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e44:	b8 00 00 00 00       	mov    $0x0,%eax
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e51:	68 5d 2a 80 00       	push   $0x802a5d
  801e56:	ff 75 0c             	pushl  0xc(%ebp)
  801e59:	e8 e2 ea ff ff       	call   800940 <strcpy>
	return 0;
}
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	57                   	push   %edi
  801e69:	56                   	push   %esi
  801e6a:	53                   	push   %ebx
  801e6b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e71:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e76:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7c:	eb 2d                	jmp    801eab <devcons_write+0x46>
		m = n - tot;
  801e7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e81:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e83:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e86:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e8b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e8e:	83 ec 04             	sub    $0x4,%esp
  801e91:	53                   	push   %ebx
  801e92:	03 45 0c             	add    0xc(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	57                   	push   %edi
  801e97:	e8 36 ec ff ff       	call   800ad2 <memmove>
		sys_cputs(buf, m);
  801e9c:	83 c4 08             	add    $0x8,%esp
  801e9f:	53                   	push   %ebx
  801ea0:	57                   	push   %edi
  801ea1:	e8 e1 ed ff ff       	call   800c87 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ea6:	01 de                	add    %ebx,%esi
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	89 f0                	mov    %esi,%eax
  801ead:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb0:	72 cc                	jb     801e7e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5f                   	pop    %edi
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 08             	sub    $0x8,%esp
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ec5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ec9:	74 2a                	je     801ef5 <devcons_read+0x3b>
  801ecb:	eb 05                	jmp    801ed2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ecd:	e8 52 ee ff ff       	call   800d24 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ed2:	e8 ce ed ff ff       	call   800ca5 <sys_cgetc>
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	74 f2                	je     801ecd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 16                	js     801ef5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801edf:	83 f8 04             	cmp    $0x4,%eax
  801ee2:	74 0c                	je     801ef0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ee4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ee7:	88 02                	mov    %al,(%edx)
	return 1;
  801ee9:	b8 01 00 00 00       	mov    $0x1,%eax
  801eee:	eb 05                	jmp    801ef5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    

00801ef7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801efd:	8b 45 08             	mov    0x8(%ebp),%eax
  801f00:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f03:	6a 01                	push   $0x1
  801f05:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f08:	50                   	push   %eax
  801f09:	e8 79 ed ff ff       	call   800c87 <sys_cputs>
}
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <getchar>:

int
getchar(void)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f19:	6a 01                	push   $0x1
  801f1b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f1e:	50                   	push   %eax
  801f1f:	6a 00                	push   $0x0
  801f21:	e8 97 f6 ff ff       	call   8015bd <read>
	if (r < 0)
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 0f                	js     801f3c <getchar+0x29>
		return r;
	if (r < 1)
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	7e 06                	jle    801f37 <getchar+0x24>
		return -E_EOF;
	return c;
  801f31:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f35:	eb 05                	jmp    801f3c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f37:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f47:	50                   	push   %eax
  801f48:	ff 75 08             	pushl  0x8(%ebp)
  801f4b:	e8 07 f4 ff ff       	call   801357 <fd_lookup>
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	85 c0                	test   %eax,%eax
  801f55:	78 11                	js     801f68 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f60:	39 10                	cmp    %edx,(%eax)
  801f62:	0f 94 c0             	sete   %al
  801f65:	0f b6 c0             	movzbl %al,%eax
}
  801f68:	c9                   	leave  
  801f69:	c3                   	ret    

00801f6a <opencons>:

int
opencons(void)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f73:	50                   	push   %eax
  801f74:	e8 8f f3 ff ff       	call   801308 <fd_alloc>
  801f79:	83 c4 10             	add    $0x10,%esp
		return r;
  801f7c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	78 3e                	js     801fc0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f82:	83 ec 04             	sub    $0x4,%esp
  801f85:	68 07 04 00 00       	push   $0x407
  801f8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 af ed ff ff       	call   800d43 <sys_page_alloc>
  801f94:	83 c4 10             	add    $0x10,%esp
		return r;
  801f97:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	78 23                	js     801fc0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb2:	83 ec 0c             	sub    $0xc,%esp
  801fb5:	50                   	push   %eax
  801fb6:	e8 26 f3 ff ff       	call   8012e1 <fd2num>
  801fbb:	89 c2                	mov    %eax,%edx
  801fbd:	83 c4 10             	add    $0x10,%esp
}
  801fc0:	89 d0                	mov    %edx,%eax
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801fca:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fd1:	75 4c                	jne    80201f <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801fd3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd8:	8b 40 48             	mov    0x48(%eax),%eax
  801fdb:	83 ec 04             	sub    $0x4,%esp
  801fde:	6a 07                	push   $0x7
  801fe0:	68 00 f0 bf ee       	push   $0xeebff000
  801fe5:	50                   	push   %eax
  801fe6:	e8 58 ed ff ff       	call   800d43 <sys_page_alloc>
		if(retv != 0){
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	74 14                	je     802006 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801ff2:	83 ec 04             	sub    $0x4,%esp
  801ff5:	68 6c 2a 80 00       	push   $0x802a6c
  801ffa:	6a 27                	push   $0x27
  801ffc:	68 98 2a 80 00       	push   $0x802a98
  802001:	e8 92 e2 ff ff       	call   800298 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802006:	a1 04 40 80 00       	mov    0x804004,%eax
  80200b:	8b 40 48             	mov    0x48(%eax),%eax
  80200e:	83 ec 08             	sub    $0x8,%esp
  802011:	68 29 20 80 00       	push   $0x802029
  802016:	50                   	push   %eax
  802017:	e8 72 ee ff ff       	call   800e8e <sys_env_set_pgfault_upcall>
  80201c:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80201f:	8b 45 08             	mov    0x8(%ebp),%eax
  802022:	a3 00 60 80 00       	mov    %eax,0x806000

}
  802027:	c9                   	leave  
  802028:	c3                   	ret    

00802029 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802029:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80202a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80202f:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  802031:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  802034:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  802038:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  80203d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  802041:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  802043:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  802046:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  802047:	83 c4 04             	add    $0x4,%esp
	popfl
  80204a:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80204b:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80204c:	c3                   	ret    

0080204d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	56                   	push   %esi
  802051:	53                   	push   %ebx
  802052:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802055:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  802058:	83 ec 0c             	sub    $0xc,%esp
  80205b:	ff 75 0c             	pushl  0xc(%ebp)
  80205e:	e8 90 ee ff ff       	call   800ef3 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	85 f6                	test   %esi,%esi
  802068:	74 1c                	je     802086 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  80206a:	a1 04 40 80 00       	mov    0x804004,%eax
  80206f:	8b 40 78             	mov    0x78(%eax),%eax
  802072:	89 06                	mov    %eax,(%esi)
  802074:	eb 10                	jmp    802086 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802076:	83 ec 0c             	sub    $0xc,%esp
  802079:	68 a6 2a 80 00       	push   $0x802aa6
  80207e:	e8 ee e2 ff ff       	call   800371 <cprintf>
  802083:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802086:	a1 04 40 80 00       	mov    0x804004,%eax
  80208b:	8b 50 74             	mov    0x74(%eax),%edx
  80208e:	85 d2                	test   %edx,%edx
  802090:	74 e4                	je     802076 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  802092:	85 db                	test   %ebx,%ebx
  802094:	74 05                	je     80209b <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802096:	8b 40 74             	mov    0x74(%eax),%eax
  802099:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80209b:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a0:	8b 40 70             	mov    0x70(%eax),%eax

}
  8020a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a6:	5b                   	pop    %ebx
  8020a7:	5e                   	pop    %esi
  8020a8:	5d                   	pop    %ebp
  8020a9:	c3                   	ret    

008020aa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	57                   	push   %edi
  8020ae:	56                   	push   %esi
  8020af:	53                   	push   %ebx
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  8020bc:	85 db                	test   %ebx,%ebx
  8020be:	75 13                	jne    8020d3 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  8020c0:	6a 00                	push   $0x0
  8020c2:	68 00 00 c0 ee       	push   $0xeec00000
  8020c7:	56                   	push   %esi
  8020c8:	57                   	push   %edi
  8020c9:	e8 02 ee ff ff       	call   800ed0 <sys_ipc_try_send>
  8020ce:	83 c4 10             	add    $0x10,%esp
  8020d1:	eb 0e                	jmp    8020e1 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  8020d3:	ff 75 14             	pushl  0x14(%ebp)
  8020d6:	53                   	push   %ebx
  8020d7:	56                   	push   %esi
  8020d8:	57                   	push   %edi
  8020d9:	e8 f2 ed ff ff       	call   800ed0 <sys_ipc_try_send>
  8020de:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	75 d7                	jne    8020bc <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  8020e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    

008020ed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020fb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802101:	8b 52 50             	mov    0x50(%edx),%edx
  802104:	39 ca                	cmp    %ecx,%edx
  802106:	75 0d                	jne    802115 <ipc_find_env+0x28>
			return envs[i].env_id;
  802108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80210b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802110:	8b 40 48             	mov    0x48(%eax),%eax
  802113:	eb 0f                	jmp    802124 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802115:	83 c0 01             	add    $0x1,%eax
  802118:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211d:	75 d9                	jne    8020f8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802124:	5d                   	pop    %ebp
  802125:	c3                   	ret    

00802126 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212c:	89 d0                	mov    %edx,%eax
  80212e:	c1 e8 16             	shr    $0x16,%eax
  802131:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802138:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213d:	f6 c1 01             	test   $0x1,%cl
  802140:	74 1d                	je     80215f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802142:	c1 ea 0c             	shr    $0xc,%edx
  802145:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80214c:	f6 c2 01             	test   $0x1,%dl
  80214f:	74 0e                	je     80215f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802151:	c1 ea 0c             	shr    $0xc,%edx
  802154:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215b:	ef 
  80215c:	0f b7 c0             	movzwl %ax,%eax
}
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    
  802161:	66 90                	xchg   %ax,%ax
  802163:	66 90                	xchg   %ax,%ax
  802165:	66 90                	xchg   %ax,%ax
  802167:	66 90                	xchg   %ax,%ax
  802169:	66 90                	xchg   %ax,%ax
  80216b:	66 90                	xchg   %ax,%ax
  80216d:	66 90                	xchg   %ax,%ax
  80216f:	90                   	nop

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80217b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80217f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 f6                	test   %esi,%esi
  802189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218d:	89 ca                	mov    %ecx,%edx
  80218f:	89 f8                	mov    %edi,%eax
  802191:	75 3d                	jne    8021d0 <__udivdi3+0x60>
  802193:	39 cf                	cmp    %ecx,%edi
  802195:	0f 87 c5 00 00 00    	ja     802260 <__udivdi3+0xf0>
  80219b:	85 ff                	test   %edi,%edi
  80219d:	89 fd                	mov    %edi,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f7                	div    %edi
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 c8                	mov    %ecx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	89 cf                	mov    %ecx,%edi
  8021b8:	f7 f5                	div    %ebp
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 ce                	cmp    %ecx,%esi
  8021d2:	77 74                	ja     802248 <__udivdi3+0xd8>
  8021d4:	0f bd fe             	bsr    %esi,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0x108>
  8021e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	29 fb                	sub    %edi,%ebx
  8021eb:	d3 e6                	shl    %cl,%esi
  8021ed:	89 d9                	mov    %ebx,%ecx
  8021ef:	d3 ed                	shr    %cl,%ebp
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	09 ee                	or     %ebp,%esi
  8021f7:	89 d9                	mov    %ebx,%ecx
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 d5                	mov    %edx,%ebp
  8021ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802203:	d3 ed                	shr    %cl,%ebp
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e2                	shl    %cl,%edx
  802209:	89 d9                	mov    %ebx,%ecx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	09 c2                	or     %eax,%edx
  80220f:	89 d0                	mov    %edx,%eax
  802211:	89 ea                	mov    %ebp,%edx
  802213:	f7 f6                	div    %esi
  802215:	89 d5                	mov    %edx,%ebp
  802217:	89 c3                	mov    %eax,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	72 10                	jb     802231 <__udivdi3+0xc1>
  802221:	8b 74 24 08          	mov    0x8(%esp),%esi
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e6                	shl    %cl,%esi
  802229:	39 c6                	cmp    %eax,%esi
  80222b:	73 07                	jae    802234 <__udivdi3+0xc4>
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	75 03                	jne    802234 <__udivdi3+0xc4>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 d8                	mov    %ebx,%eax
  802238:	89 fa                	mov    %edi,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	31 ff                	xor    %edi,%edi
  80224a:	31 db                	xor    %ebx,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d8                	mov    %ebx,%eax
  802262:	f7 f7                	div    %edi
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 c3                	mov    %eax,%ebx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 fa                	mov    %edi,%edx
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 ce                	cmp    %ecx,%esi
  80227a:	72 0c                	jb     802288 <__udivdi3+0x118>
  80227c:	31 db                	xor    %ebx,%ebx
  80227e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802282:	0f 87 34 ff ff ff    	ja     8021bc <__udivdi3+0x4c>
  802288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80228d:	e9 2a ff ff ff       	jmp    8021bc <__udivdi3+0x4c>
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 d2                	test   %edx,%edx
  8022b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f3                	mov    %esi,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x48>
  8022cc:	39 f7                	cmp    %esi,%edi
  8022ce:	76 50                	jbe    802320 <__umoddi3+0x80>
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	f7 f7                	div    %edi
  8022d6:	89 d0                	mov    %edx,%eax
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	77 52                	ja     802340 <__umoddi3+0xa0>
  8022ee:	0f bd ea             	bsr    %edx,%ebp
  8022f1:	83 f5 1f             	xor    $0x1f,%ebp
  8022f4:	75 5a                	jne    802350 <__umoddi3+0xb0>
  8022f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	39 0c 24             	cmp    %ecx,(%esp)
  802303:	0f 86 d7 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  802309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	85 ff                	test   %edi,%edi
  802322:	89 fd                	mov    %edi,%ebp
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 f0                	mov    %esi,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 c8                	mov    %ecx,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	eb 99                	jmp    8022d8 <__umoddi3+0x38>
  80233f:	90                   	nop
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 1c             	add    $0x1c,%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	8b 34 24             	mov    (%esp),%esi
  802353:	bf 20 00 00 00       	mov    $0x20,%edi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	29 ef                	sub    %ebp,%edi
  80235c:	d3 e0                	shl    %cl,%eax
  80235e:	89 f9                	mov    %edi,%ecx
  802360:	89 f2                	mov    %esi,%edx
  802362:	d3 ea                	shr    %cl,%edx
  802364:	89 e9                	mov    %ebp,%ecx
  802366:	09 c2                	or     %eax,%edx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 14 24             	mov    %edx,(%esp)
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	d3 e2                	shl    %cl,%edx
  802371:	89 f9                	mov    %edi,%ecx
  802373:	89 54 24 04          	mov    %edx,0x4(%esp)
  802377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	89 c6                	mov    %eax,%esi
  802381:	d3 e3                	shl    %cl,%ebx
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 d0                	mov    %edx,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	09 d8                	or     %ebx,%eax
  80238d:	89 d3                	mov    %edx,%ebx
  80238f:	89 f2                	mov    %esi,%edx
  802391:	f7 34 24             	divl   (%esp)
  802394:	89 d6                	mov    %edx,%esi
  802396:	d3 e3                	shl    %cl,%ebx
  802398:	f7 64 24 04          	mull   0x4(%esp)
  80239c:	39 d6                	cmp    %edx,%esi
  80239e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	72 08                	jb     8023b0 <__umoddi3+0x110>
  8023a8:	75 11                	jne    8023bb <__umoddi3+0x11b>
  8023aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ae:	73 0b                	jae    8023bb <__umoddi3+0x11b>
  8023b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b4:	1b 14 24             	sbb    (%esp),%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 c3                	mov    %eax,%ebx
  8023bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023bf:	29 da                	sub    %ebx,%edx
  8023c1:	19 ce                	sbb    %ecx,%esi
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	d3 ee                	shr    %cl,%esi
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	83 c4 1c             	add    $0x1c,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 f9                	sub    %edi,%ecx
  8023e2:	19 d6                	sbb    %edx,%esi
  8023e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ec:	e9 18 ff ff ff       	jmp    802309 <__umoddi3+0x69>
