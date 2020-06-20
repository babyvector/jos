
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 20 19 00 00       	call   80196f <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 16 19 00 00       	call   80196f <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 c0 2a 80 00 	movl   $0x802ac0,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 2b 2b 80 00 	movl   $0x802b2b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 50 0e 00 00       	call   800ed3 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 77 17 00 00       	call   801809 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 3a 2b 80 00       	push   $0x802b3a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 1b 0e 00 00       	call   800ed3 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 42 17 00 00       	call   801809 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 35 2b 80 00       	push   $0x802b35
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 d2 15 00 00       	call   8016cd <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 c6 15 00 00       	call   8016cd <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 48 2b 80 00       	push   $0x802b48
  80011b:	e8 6d 1b 00 00       	call   801c8d <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 55 2b 80 00       	push   $0x802b55
  80012f:	6a 13                	push   $0x13
  800131:	68 6b 2b 80 00       	push   $0x802b6b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 74 23 00 00       	call   8024bb <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 7c 2b 80 00       	push   $0x802b7c
  800154:	6a 15                	push   $0x15
  800156:	68 6b 2b 80 00       	push   $0x802b6b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 e4 2a 80 00       	push   $0x802ae4
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 c3 11 00 00       	call   801338 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 85 2b 80 00       	push   $0x802b85
  800182:	6a 1a                	push   $0x1a
  800184:	68 6b 2b 80 00       	push   $0x802b6b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 80 15 00 00       	call   80171d <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 75 15 00 00       	call   80171d <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 1d 15 00 00       	call   8016cd <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 15 15 00 00       	call   8016cd <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 8e 2b 80 00       	push   $0x802b8e
  8001bf:	68 52 2b 80 00       	push   $0x802b52
  8001c4:	68 91 2b 80 00       	push   $0x802b91
  8001c9:	e8 a4 20 00 00       	call   802272 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 95 2b 80 00       	push   $0x802b95
  8001dd:	6a 21                	push   $0x21
  8001df:	68 6b 2b 80 00       	push   $0x802b6b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 da 14 00 00       	call   8016cd <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 ce 14 00 00       	call   8016cd <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 3a 24 00 00       	call   802641 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 b5 14 00 00       	call   8016cd <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 ad 14 00 00       	call   8016cd <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 9f 2b 80 00       	push   $0x802b9f
  800230:	e8 58 1a 00 00       	call   801c8d <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 08 2b 80 00       	push   $0x802b08
  800245:	6a 2c                	push   $0x2c
  800247:	68 6b 2b 80 00       	push   $0x802b6b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 9d 15 00 00       	call   801809 <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 8a 15 00 00       	call   801809 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 ad 2b 80 00       	push   $0x802bad
  80028c:	6a 33                	push   $0x33
  80028e:	68 6b 2b 80 00       	push   $0x802b6b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 c7 2b 80 00       	push   $0x802bc7
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 6b 2b 80 00       	push   $0x802b6b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 e1 2b 80 00       	push   $0x802be1
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 f6 2b 80 00       	push   $0x802bf6
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 6e 08 00 00       	call   800b8c <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 c2 09 00 00       	call   800d1e <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 6d 0b 00 00       	call   800ed3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 de 0b 00 00       	call   800f70 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 5a 0b 00 00       	call   800ef1 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 05 0b 00 00       	call   800ed3 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 23 14 00 00       	call   801809 <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 93 11 00 00       	call   8015a3 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 1b 11 00 00       	call   801554 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 3b 0b 00 00       	call   800f8f <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 b2 10 00 00       	call   80152d <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 bd 0a 00 00       	call   800f51 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 23 12 00 00       	call   8016f8 <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 31 0a 00 00       	call   800f10 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 5a 0a 00 00       	call   800f51 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 0c 2c 80 00       	push   $0x802c0c
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 43 30 80 00 	movl   $0x803043,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 79 09 00 00       	call   800ed3 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 1e 09 00 00       	call   800ed3 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 0b 22 00 00       	call   802830 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 f8 22 00 00       	call   802960 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 2f 2c 80 00 	movsbl 0x802c2f(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 d3 03 00 00    	je     800ae3 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 64 03 00 00    	ja     800ac8 <vprintfmt+0x3d4>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 80 2d 80 00 	jmp    *0x802d80(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 e0 2e 80 00 	mov    0x802ee0(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 47 2c 80 00       	push   $0x802c47
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 89 31 80 00       	push   $0x803189
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 40 2c 80 00       	mov    $0x802c40,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 c8             	pushl  -0x38(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 d0 02 00 00       	call   800b6b <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80098e:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8009c8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009d1:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8009da:	0f 89 b0 00 00 00    	jns    800a90 <vprintfmt+0x39c>
				putch('-', putdat);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	53                   	push   %ebx
  8009e4:	6a 2d                	push   $0x2d
  8009e6:	ff d6                	call   *%esi
				num = -(long long) num;
  8009e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8009eb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8009ee:	f7 d8                	neg    %eax
  8009f0:	83 d2 00             	adc    $0x0,%edx
  8009f3:	f7 da                	neg    %edx
  8009f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8009fb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a03:	e9 88 00 00 00       	jmp    800a90 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a08:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0b:	e8 70 fc ff ff       	call   800680 <getuint>
  800a10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a13:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800a16:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a1b:	eb 73                	jmp    800a90 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800a1d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a20:	e8 5b fc ff ff       	call   800680 <getuint>
  800a25:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a28:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800a2b:	83 ec 08             	sub    $0x8,%esp
  800a2e:	53                   	push   %ebx
  800a2f:	6a 58                	push   $0x58
  800a31:	ff d6                	call   *%esi
			putch('X', putdat);
  800a33:	83 c4 08             	add    $0x8,%esp
  800a36:	53                   	push   %ebx
  800a37:	6a 58                	push   $0x58
  800a39:	ff d6                	call   *%esi
			putch('X', putdat);
  800a3b:	83 c4 08             	add    $0x8,%esp
  800a3e:	53                   	push   %ebx
  800a3f:	6a 58                	push   $0x58
  800a41:	ff d6                	call   *%esi
			goto number;
  800a43:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800a46:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800a4b:	eb 43                	jmp    800a90 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a4d:	83 ec 08             	sub    $0x8,%esp
  800a50:	53                   	push   %ebx
  800a51:	6a 30                	push   $0x30
  800a53:	ff d6                	call   *%esi
			putch('x', putdat);
  800a55:	83 c4 08             	add    $0x8,%esp
  800a58:	53                   	push   %ebx
  800a59:	6a 78                	push   $0x78
  800a5b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a60:	8d 50 04             	lea    0x4(%eax),%edx
  800a63:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a66:	8b 00                	mov    (%eax),%eax
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a70:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a73:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a76:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a7b:	eb 13                	jmp    800a90 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a7d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a80:	e8 fb fb ff ff       	call   800680 <getuint>
  800a85:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a88:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800a8b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a90:	83 ec 0c             	sub    $0xc,%esp
  800a93:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800a97:	52                   	push   %edx
  800a98:	ff 75 e0             	pushl  -0x20(%ebp)
  800a9b:	50                   	push   %eax
  800a9c:	ff 75 dc             	pushl  -0x24(%ebp)
  800a9f:	ff 75 d8             	pushl  -0x28(%ebp)
  800aa2:	89 da                	mov    %ebx,%edx
  800aa4:	89 f0                	mov    %esi,%eax
  800aa6:	e8 26 fb ff ff       	call   8005d1 <printnum>
			break;
  800aab:	83 c4 20             	add    $0x20,%esp
  800aae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ab1:	e9 64 fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab6:	83 ec 08             	sub    $0x8,%esp
  800ab9:	53                   	push   %ebx
  800aba:	51                   	push   %ecx
  800abb:	ff d6                	call   *%esi
			break;
  800abd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ac3:	e9 52 fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ac8:	83 ec 08             	sub    $0x8,%esp
  800acb:	53                   	push   %ebx
  800acc:	6a 25                	push   $0x25
  800ace:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad0:	83 c4 10             	add    $0x10,%esp
  800ad3:	eb 03                	jmp    800ad8 <vprintfmt+0x3e4>
  800ad5:	83 ef 01             	sub    $0x1,%edi
  800ad8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800adc:	75 f7                	jne    800ad5 <vprintfmt+0x3e1>
  800ade:	e9 37 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	83 ec 18             	sub    $0x18,%esp
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800af7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800afa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800afe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	74 26                	je     800b32 <vsnprintf+0x47>
  800b0c:	85 d2                	test   %edx,%edx
  800b0e:	7e 22                	jle    800b32 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b10:	ff 75 14             	pushl  0x14(%ebp)
  800b13:	ff 75 10             	pushl  0x10(%ebp)
  800b16:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b19:	50                   	push   %eax
  800b1a:	68 ba 06 80 00       	push   $0x8006ba
  800b1f:	e8 d0 fb ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b2d:	83 c4 10             	add    $0x10,%esp
  800b30:	eb 05                	jmp    800b37 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b3f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b42:	50                   	push   %eax
  800b43:	ff 75 10             	pushl  0x10(%ebp)
  800b46:	ff 75 0c             	pushl  0xc(%ebp)
  800b49:	ff 75 08             	pushl  0x8(%ebp)
  800b4c:	e8 9a ff ff ff       	call   800aeb <vsnprintf>
	va_end(ap);

	return rc;
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b59:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5e:	eb 03                	jmp    800b63 <strlen+0x10>
		n++;
  800b60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b67:	75 f7                	jne    800b60 <strlen+0xd>
		n++;
	return n;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b71:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	eb 03                	jmp    800b7e <strnlen+0x13>
		n++;
  800b7b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7e:	39 c2                	cmp    %eax,%edx
  800b80:	74 08                	je     800b8a <strnlen+0x1f>
  800b82:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b86:	75 f3                	jne    800b7b <strnlen+0x10>
  800b88:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	53                   	push   %ebx
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	83 c1 01             	add    $0x1,%ecx
  800b9e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ba2:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ba5:	84 db                	test   %bl,%bl
  800ba7:	75 ef                	jne    800b98 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	53                   	push   %ebx
  800bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb3:	53                   	push   %ebx
  800bb4:	e8 9a ff ff ff       	call   800b53 <strlen>
  800bb9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800bbc:	ff 75 0c             	pushl  0xc(%ebp)
  800bbf:	01 d8                	add    %ebx,%eax
  800bc1:	50                   	push   %eax
  800bc2:	e8 c5 ff ff ff       	call   800b8c <strcpy>
	return dst;
}
  800bc7:	89 d8                	mov    %ebx,%eax
  800bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	8b 75 08             	mov    0x8(%ebp),%esi
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	89 f3                	mov    %esi,%ebx
  800bdb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bde:	89 f2                	mov    %esi,%edx
  800be0:	eb 0f                	jmp    800bf1 <strncpy+0x23>
		*dst++ = *src;
  800be2:	83 c2 01             	add    $0x1,%edx
  800be5:	0f b6 01             	movzbl (%ecx),%eax
  800be8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800beb:	80 39 01             	cmpb   $0x1,(%ecx)
  800bee:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf1:	39 da                	cmp    %ebx,%edx
  800bf3:	75 ed                	jne    800be2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bf5:	89 f0                	mov    %esi,%eax
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	8b 75 08             	mov    0x8(%ebp),%esi
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 10             	mov    0x10(%ebp),%edx
  800c09:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c0b:	85 d2                	test   %edx,%edx
  800c0d:	74 21                	je     800c30 <strlcpy+0x35>
  800c0f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c13:	89 f2                	mov    %esi,%edx
  800c15:	eb 09                	jmp    800c20 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c17:	83 c2 01             	add    $0x1,%edx
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c20:	39 c2                	cmp    %eax,%edx
  800c22:	74 09                	je     800c2d <strlcpy+0x32>
  800c24:	0f b6 19             	movzbl (%ecx),%ebx
  800c27:	84 db                	test   %bl,%bl
  800c29:	75 ec                	jne    800c17 <strlcpy+0x1c>
  800c2b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c2d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c30:	29 f0                	sub    %esi,%eax
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c3f:	eb 06                	jmp    800c47 <strcmp+0x11>
		p++, q++;
  800c41:	83 c1 01             	add    $0x1,%ecx
  800c44:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c47:	0f b6 01             	movzbl (%ecx),%eax
  800c4a:	84 c0                	test   %al,%al
  800c4c:	74 04                	je     800c52 <strcmp+0x1c>
  800c4e:	3a 02                	cmp    (%edx),%al
  800c50:	74 ef                	je     800c41 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c52:	0f b6 c0             	movzbl %al,%eax
  800c55:	0f b6 12             	movzbl (%edx),%edx
  800c58:	29 d0                	sub    %edx,%eax
}
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	53                   	push   %ebx
  800c60:	8b 45 08             	mov    0x8(%ebp),%eax
  800c63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c66:	89 c3                	mov    %eax,%ebx
  800c68:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c6b:	eb 06                	jmp    800c73 <strncmp+0x17>
		n--, p++, q++;
  800c6d:	83 c0 01             	add    $0x1,%eax
  800c70:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c73:	39 d8                	cmp    %ebx,%eax
  800c75:	74 15                	je     800c8c <strncmp+0x30>
  800c77:	0f b6 08             	movzbl (%eax),%ecx
  800c7a:	84 c9                	test   %cl,%cl
  800c7c:	74 04                	je     800c82 <strncmp+0x26>
  800c7e:	3a 0a                	cmp    (%edx),%cl
  800c80:	74 eb                	je     800c6d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c82:	0f b6 00             	movzbl (%eax),%eax
  800c85:	0f b6 12             	movzbl (%edx),%edx
  800c88:	29 d0                	sub    %edx,%eax
  800c8a:	eb 05                	jmp    800c91 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c91:	5b                   	pop    %ebx
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c9e:	eb 07                	jmp    800ca7 <strchr+0x13>
		if (*s == c)
  800ca0:	38 ca                	cmp    %cl,%dl
  800ca2:	74 0f                	je     800cb3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ca4:	83 c0 01             	add    $0x1,%eax
  800ca7:	0f b6 10             	movzbl (%eax),%edx
  800caa:	84 d2                	test   %dl,%dl
  800cac:	75 f2                	jne    800ca0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800cae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cbf:	eb 03                	jmp    800cc4 <strfind+0xf>
  800cc1:	83 c0 01             	add    $0x1,%eax
  800cc4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cc7:	38 ca                	cmp    %cl,%dl
  800cc9:	74 04                	je     800ccf <strfind+0x1a>
  800ccb:	84 d2                	test   %dl,%dl
  800ccd:	75 f2                	jne    800cc1 <strfind+0xc>
			break;
	return (char *) s;
}
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cdd:	85 c9                	test   %ecx,%ecx
  800cdf:	74 36                	je     800d17 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ce1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ce7:	75 28                	jne    800d11 <memset+0x40>
  800ce9:	f6 c1 03             	test   $0x3,%cl
  800cec:	75 23                	jne    800d11 <memset+0x40>
		c &= 0xFF;
  800cee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cf2:	89 d3                	mov    %edx,%ebx
  800cf4:	c1 e3 08             	shl    $0x8,%ebx
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	c1 e6 18             	shl    $0x18,%esi
  800cfc:	89 d0                	mov    %edx,%eax
  800cfe:	c1 e0 10             	shl    $0x10,%eax
  800d01:	09 f0                	or     %esi,%eax
  800d03:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d05:	89 d8                	mov    %ebx,%eax
  800d07:	09 d0                	or     %edx,%eax
  800d09:	c1 e9 02             	shr    $0x2,%ecx
  800d0c:	fc                   	cld    
  800d0d:	f3 ab                	rep stos %eax,%es:(%edi)
  800d0f:	eb 06                	jmp    800d17 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d14:	fc                   	cld    
  800d15:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d17:	89 f8                	mov    %edi,%eax
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d2c:	39 c6                	cmp    %eax,%esi
  800d2e:	73 35                	jae    800d65 <memmove+0x47>
  800d30:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d33:	39 d0                	cmp    %edx,%eax
  800d35:	73 2e                	jae    800d65 <memmove+0x47>
		s += n;
		d += n;
  800d37:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	09 fe                	or     %edi,%esi
  800d3e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d44:	75 13                	jne    800d59 <memmove+0x3b>
  800d46:	f6 c1 03             	test   $0x3,%cl
  800d49:	75 0e                	jne    800d59 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d4b:	83 ef 04             	sub    $0x4,%edi
  800d4e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d51:	c1 e9 02             	shr    $0x2,%ecx
  800d54:	fd                   	std    
  800d55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d57:	eb 09                	jmp    800d62 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d59:	83 ef 01             	sub    $0x1,%edi
  800d5c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d5f:	fd                   	std    
  800d60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d62:	fc                   	cld    
  800d63:	eb 1d                	jmp    800d82 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d65:	89 f2                	mov    %esi,%edx
  800d67:	09 c2                	or     %eax,%edx
  800d69:	f6 c2 03             	test   $0x3,%dl
  800d6c:	75 0f                	jne    800d7d <memmove+0x5f>
  800d6e:	f6 c1 03             	test   $0x3,%cl
  800d71:	75 0a                	jne    800d7d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d73:	c1 e9 02             	shr    $0x2,%ecx
  800d76:	89 c7                	mov    %eax,%edi
  800d78:	fc                   	cld    
  800d79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d7b:	eb 05                	jmp    800d82 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d7d:	89 c7                	mov    %eax,%edi
  800d7f:	fc                   	cld    
  800d80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d89:	ff 75 10             	pushl  0x10(%ebp)
  800d8c:	ff 75 0c             	pushl  0xc(%ebp)
  800d8f:	ff 75 08             	pushl  0x8(%ebp)
  800d92:	e8 87 ff ff ff       	call   800d1e <memmove>
}
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da4:	89 c6                	mov    %eax,%esi
  800da6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da9:	eb 1a                	jmp    800dc5 <memcmp+0x2c>
		if (*s1 != *s2)
  800dab:	0f b6 08             	movzbl (%eax),%ecx
  800dae:	0f b6 1a             	movzbl (%edx),%ebx
  800db1:	38 d9                	cmp    %bl,%cl
  800db3:	74 0a                	je     800dbf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800db5:	0f b6 c1             	movzbl %cl,%eax
  800db8:	0f b6 db             	movzbl %bl,%ebx
  800dbb:	29 d8                	sub    %ebx,%eax
  800dbd:	eb 0f                	jmp    800dce <memcmp+0x35>
		s1++, s2++;
  800dbf:	83 c0 01             	add    $0x1,%eax
  800dc2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc5:	39 f0                	cmp    %esi,%eax
  800dc7:	75 e2                	jne    800dab <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	53                   	push   %ebx
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dd9:	89 c1                	mov    %eax,%ecx
  800ddb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800dde:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800de2:	eb 0a                	jmp    800dee <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de4:	0f b6 10             	movzbl (%eax),%edx
  800de7:	39 da                	cmp    %ebx,%edx
  800de9:	74 07                	je     800df2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800deb:	83 c0 01             	add    $0x1,%eax
  800dee:	39 c8                	cmp    %ecx,%eax
  800df0:	72 f2                	jb     800de4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800df2:	5b                   	pop    %ebx
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e01:	eb 03                	jmp    800e06 <strtol+0x11>
		s++;
  800e03:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e06:	0f b6 01             	movzbl (%ecx),%eax
  800e09:	3c 20                	cmp    $0x20,%al
  800e0b:	74 f6                	je     800e03 <strtol+0xe>
  800e0d:	3c 09                	cmp    $0x9,%al
  800e0f:	74 f2                	je     800e03 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e11:	3c 2b                	cmp    $0x2b,%al
  800e13:	75 0a                	jne    800e1f <strtol+0x2a>
		s++;
  800e15:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e18:	bf 00 00 00 00       	mov    $0x0,%edi
  800e1d:	eb 11                	jmp    800e30 <strtol+0x3b>
  800e1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e24:	3c 2d                	cmp    $0x2d,%al
  800e26:	75 08                	jne    800e30 <strtol+0x3b>
		s++, neg = 1;
  800e28:	83 c1 01             	add    $0x1,%ecx
  800e2b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e36:	75 15                	jne    800e4d <strtol+0x58>
  800e38:	80 39 30             	cmpb   $0x30,(%ecx)
  800e3b:	75 10                	jne    800e4d <strtol+0x58>
  800e3d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e41:	75 7c                	jne    800ebf <strtol+0xca>
		s += 2, base = 16;
  800e43:	83 c1 02             	add    $0x2,%ecx
  800e46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e4b:	eb 16                	jmp    800e63 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e4d:	85 db                	test   %ebx,%ebx
  800e4f:	75 12                	jne    800e63 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e51:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e56:	80 39 30             	cmpb   $0x30,(%ecx)
  800e59:	75 08                	jne    800e63 <strtol+0x6e>
		s++, base = 8;
  800e5b:	83 c1 01             	add    $0x1,%ecx
  800e5e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e63:	b8 00 00 00 00       	mov    $0x0,%eax
  800e68:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e6b:	0f b6 11             	movzbl (%ecx),%edx
  800e6e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	80 fb 09             	cmp    $0x9,%bl
  800e76:	77 08                	ja     800e80 <strtol+0x8b>
			dig = *s - '0';
  800e78:	0f be d2             	movsbl %dl,%edx
  800e7b:	83 ea 30             	sub    $0x30,%edx
  800e7e:	eb 22                	jmp    800ea2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e80:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e83:	89 f3                	mov    %esi,%ebx
  800e85:	80 fb 19             	cmp    $0x19,%bl
  800e88:	77 08                	ja     800e92 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e8a:	0f be d2             	movsbl %dl,%edx
  800e8d:	83 ea 57             	sub    $0x57,%edx
  800e90:	eb 10                	jmp    800ea2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e92:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e95:	89 f3                	mov    %esi,%ebx
  800e97:	80 fb 19             	cmp    $0x19,%bl
  800e9a:	77 16                	ja     800eb2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e9c:	0f be d2             	movsbl %dl,%edx
  800e9f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ea2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ea5:	7d 0b                	jge    800eb2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ea7:	83 c1 01             	add    $0x1,%ecx
  800eaa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800eae:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800eb0:	eb b9                	jmp    800e6b <strtol+0x76>

	if (endptr)
  800eb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eb6:	74 0d                	je     800ec5 <strtol+0xd0>
		*endptr = (char *) s;
  800eb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ebb:	89 0e                	mov    %ecx,(%esi)
  800ebd:	eb 06                	jmp    800ec5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ebf:	85 db                	test   %ebx,%ebx
  800ec1:	74 98                	je     800e5b <strtol+0x66>
  800ec3:	eb 9e                	jmp    800e63 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	f7 da                	neg    %edx
  800ec9:	85 ff                	test   %edi,%edi
  800ecb:	0f 45 c2             	cmovne %edx,%eax
}
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 c3                	mov    %eax,%ebx
  800ee6:	89 c7                	mov    %eax,%edi
  800ee8:	89 c6                	mov    %eax,%esi
  800eea:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  800efc:	b8 01 00 00 00       	mov    $0x1,%eax
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 d3                	mov    %edx,%ebx
  800f05:	89 d7                	mov    %edx,%edi
  800f07:	89 d6                	mov    %edx,%esi
  800f09:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	89 cb                	mov    %ecx,%ebx
  800f28:	89 cf                	mov    %ecx,%edi
  800f2a:	89 ce                	mov    %ecx,%esi
  800f2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	7e 17                	jle    800f49 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f32:	83 ec 0c             	sub    $0xc,%esp
  800f35:	50                   	push   %eax
  800f36:	6a 03                	push   $0x3
  800f38:	68 3f 2f 80 00       	push   $0x802f3f
  800f3d:	6a 23                	push   $0x23
  800f3f:	68 5c 2f 80 00       	push   $0x802f5c
  800f44:	e8 9b f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f57:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5c:	b8 02 00 00 00       	mov    $0x2,%eax
  800f61:	89 d1                	mov    %edx,%ecx
  800f63:	89 d3                	mov    %edx,%ebx
  800f65:	89 d7                	mov    %edx,%edi
  800f67:	89 d6                	mov    %edx,%esi
  800f69:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <sys_yield>:

void
sys_yield(void)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f76:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f80:	89 d1                	mov    %edx,%ecx
  800f82:	89 d3                	mov    %edx,%ebx
  800f84:	89 d7                	mov    %edx,%edi
  800f86:	89 d6                	mov    %edx,%esi
  800f88:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    

00800f8f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	57                   	push   %edi
  800f93:	56                   	push   %esi
  800f94:	53                   	push   %ebx
  800f95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f98:	be 00 00 00 00       	mov    $0x0,%esi
  800f9d:	b8 04 00 00 00       	mov    $0x4,%eax
  800fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fab:	89 f7                	mov    %esi,%edi
  800fad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	7e 17                	jle    800fca <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	50                   	push   %eax
  800fb7:	6a 04                	push   $0x4
  800fb9:	68 3f 2f 80 00       	push   $0x802f3f
  800fbe:	6a 23                	push   $0x23
  800fc0:	68 5c 2f 80 00       	push   $0x802f5c
  800fc5:	e8 1a f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5f                   	pop    %edi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800fdb:	b8 05 00 00 00       	mov    $0x5,%eax
  800fe0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fe9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fec:	8b 75 18             	mov    0x18(%ebp),%esi
  800fef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	7e 17                	jle    80100c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	50                   	push   %eax
  800ff9:	6a 05                	push   $0x5
  800ffb:	68 3f 2f 80 00       	push   $0x802f3f
  801000:	6a 23                	push   $0x23
  801002:	68 5c 2f 80 00       	push   $0x802f5c
  801007:	e8 d8 f4 ff ff       	call   8004e4 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80100c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
  80101a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80101d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801022:	b8 06 00 00 00       	mov    $0x6,%eax
  801027:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102a:	8b 55 08             	mov    0x8(%ebp),%edx
  80102d:	89 df                	mov    %ebx,%edi
  80102f:	89 de                	mov    %ebx,%esi
  801031:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	7e 17                	jle    80104e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	50                   	push   %eax
  80103b:	6a 06                	push   $0x6
  80103d:	68 3f 2f 80 00       	push   $0x802f3f
  801042:	6a 23                	push   $0x23
  801044:	68 5c 2f 80 00       	push   $0x802f5c
  801049:	e8 96 f4 ff ff       	call   8004e4 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80104e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80105f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801064:	b8 08 00 00 00       	mov    $0x8,%eax
  801069:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106c:	8b 55 08             	mov    0x8(%ebp),%edx
  80106f:	89 df                	mov    %ebx,%edi
  801071:	89 de                	mov    %ebx,%esi
  801073:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801075:	85 c0                	test   %eax,%eax
  801077:	7e 17                	jle    801090 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	50                   	push   %eax
  80107d:	6a 08                	push   $0x8
  80107f:	68 3f 2f 80 00       	push   $0x802f3f
  801084:	6a 23                	push   $0x23
  801086:	68 5c 2f 80 00       	push   $0x802f5c
  80108b:	e8 54 f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801090:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
  80109e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8010a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a6:	b8 09 00 00 00       	mov    $0x9,%eax
  8010ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b1:	89 df                	mov    %ebx,%edi
  8010b3:	89 de                	mov    %ebx,%esi
  8010b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	7e 17                	jle    8010d2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	50                   	push   %eax
  8010bf:	6a 09                	push   $0x9
  8010c1:	68 3f 2f 80 00       	push   $0x802f3f
  8010c6:	6a 23                	push   $0x23
  8010c8:	68 5c 2f 80 00       	push   $0x802f5c
  8010cd:	e8 12 f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	57                   	push   %edi
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8010e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f3:	89 df                	mov    %ebx,%edi
  8010f5:	89 de                	mov    %ebx,%esi
  8010f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	7e 17                	jle    801114 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	50                   	push   %eax
  801101:	6a 0a                	push   $0xa
  801103:	68 3f 2f 80 00       	push   $0x802f3f
  801108:	6a 23                	push   $0x23
  80110a:	68 5c 2f 80 00       	push   $0x802f5c
  80110f:	e8 d0 f3 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	57                   	push   %edi
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801122:	be 00 00 00 00       	mov    $0x0,%esi
  801127:	b8 0c 00 00 00       	mov    $0xc,%eax
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	8b 55 08             	mov    0x8(%ebp),%edx
  801132:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801135:	8b 7d 14             	mov    0x14(%ebp),%edi
  801138:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80113a:	5b                   	pop    %ebx
  80113b:	5e                   	pop    %esi
  80113c:	5f                   	pop    %edi
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	57                   	push   %edi
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801148:	b9 00 00 00 00       	mov    $0x0,%ecx
  80114d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801152:	8b 55 08             	mov    0x8(%ebp),%edx
  801155:	89 cb                	mov    %ecx,%ebx
  801157:	89 cf                	mov    %ecx,%edi
  801159:	89 ce                	mov    %ecx,%esi
  80115b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80115d:	85 c0                	test   %eax,%eax
  80115f:	7e 17                	jle    801178 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801161:	83 ec 0c             	sub    $0xc,%esp
  801164:	50                   	push   %eax
  801165:	6a 0d                	push   $0xd
  801167:	68 3f 2f 80 00       	push   $0x802f3f
  80116c:	6a 23                	push   $0x23
  80116e:	68 5c 2f 80 00       	push   $0x802f5c
  801173:	e8 6c f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801188:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  80118a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80118e:	74 11                	je     8011a1 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  801190:	89 d8                	mov    %ebx,%eax
  801192:	c1 e8 0c             	shr    $0xc,%eax
  801195:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  80119c:	f6 c4 08             	test   $0x8,%ah
  80119f:	75 14                	jne    8011b5 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	68 6a 2f 80 00       	push   $0x802f6a
  8011a9:	6a 21                	push   $0x21
  8011ab:	68 80 2f 80 00       	push   $0x802f80
  8011b0:	e8 2f f3 ff ff       	call   8004e4 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  8011b5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  8011bb:	e8 91 fd ff ff       	call   800f51 <sys_getenvid>
  8011c0:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	6a 07                	push   $0x7
  8011c7:	68 00 f0 7f 00       	push   $0x7ff000
  8011cc:	50                   	push   %eax
  8011cd:	e8 bd fd ff ff       	call   800f8f <sys_page_alloc>
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	79 14                	jns    8011ed <pgfault+0x6d>
		panic("sys_page_alloc");
  8011d9:	83 ec 04             	sub    $0x4,%esp
  8011dc:	68 8b 2f 80 00       	push   $0x802f8b
  8011e1:	6a 30                	push   $0x30
  8011e3:	68 80 2f 80 00       	push   $0x802f80
  8011e8:	e8 f7 f2 ff ff       	call   8004e4 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  8011ed:	83 ec 04             	sub    $0x4,%esp
  8011f0:	68 00 10 00 00       	push   $0x1000
  8011f5:	53                   	push   %ebx
  8011f6:	68 00 f0 7f 00       	push   $0x7ff000
  8011fb:	e8 86 fb ff ff       	call   800d86 <memcpy>
	retv = sys_page_unmap(envid, addr);
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	53                   	push   %ebx
  801204:	56                   	push   %esi
  801205:	e8 0a fe ff ff       	call   801014 <sys_page_unmap>
	if(retv < 0){
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	85 c0                	test   %eax,%eax
  80120f:	79 12                	jns    801223 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  801211:	50                   	push   %eax
  801212:	68 78 30 80 00       	push   $0x803078
  801217:	6a 35                	push   $0x35
  801219:	68 80 2f 80 00       	push   $0x802f80
  80121e:	e8 c1 f2 ff ff       	call   8004e4 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	6a 07                	push   $0x7
  801228:	53                   	push   %ebx
  801229:	56                   	push   %esi
  80122a:	68 00 f0 7f 00       	push   $0x7ff000
  80122f:	56                   	push   %esi
  801230:	e8 9d fd ff ff       	call   800fd2 <sys_page_map>
	if(retv < 0){
  801235:	83 c4 20             	add    $0x20,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	79 14                	jns    801250 <pgfault+0xd0>
		panic("sys_page_map");
  80123c:	83 ec 04             	sub    $0x4,%esp
  80123f:	68 9a 2f 80 00       	push   $0x802f9a
  801244:	6a 39                	push   $0x39
  801246:	68 80 2f 80 00       	push   $0x802f80
  80124b:	e8 94 f2 ff ff       	call   8004e4 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	68 00 f0 7f 00       	push   $0x7ff000
  801258:	56                   	push   %esi
  801259:	e8 b6 fd ff ff       	call   801014 <sys_page_unmap>
	if(retv < 0){
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	79 14                	jns    801279 <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  801265:	83 ec 04             	sub    $0x4,%esp
  801268:	68 a7 2f 80 00       	push   $0x802fa7
  80126d:	6a 3d                	push   $0x3d
  80126f:	68 80 2f 80 00       	push   $0x802f80
  801274:	e8 6b f2 ff ff       	call   8004e4 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  801279:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80127c:	5b                   	pop    %ebx
  80127d:	5e                   	pop    %esi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
  801285:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  801288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80128b:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	53                   	push   %ebx
  801292:	68 c4 2f 80 00       	push   $0x802fc4
  801297:	e8 21 f3 ff ff       	call   8005bd <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80129c:	83 c4 0c             	add    $0xc,%esp
  80129f:	6a 07                	push   $0x7
  8012a1:	53                   	push   %ebx
  8012a2:	56                   	push   %esi
  8012a3:	e8 e7 fc ff ff       	call   800f8f <sys_page_alloc>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	79 15                	jns    8012c4 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  8012af:	50                   	push   %eax
  8012b0:	68 d7 2f 80 00       	push   $0x802fd7
  8012b5:	68 90 00 00 00       	push   $0x90
  8012ba:	68 80 2f 80 00       	push   $0x802f80
  8012bf:	e8 20 f2 ff ff       	call   8004e4 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  8012c4:	83 ec 0c             	sub    $0xc,%esp
  8012c7:	68 ea 2f 80 00       	push   $0x802fea
  8012cc:	e8 ec f2 ff ff       	call   8005bd <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8012d1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8012d8:	68 00 00 40 00       	push   $0x400000
  8012dd:	6a 00                	push   $0x0
  8012df:	53                   	push   %ebx
  8012e0:	56                   	push   %esi
  8012e1:	e8 ec fc ff ff       	call   800fd2 <sys_page_map>
  8012e6:	83 c4 20             	add    $0x20,%esp
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	79 15                	jns    801302 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  8012ed:	50                   	push   %eax
  8012ee:	68 f2 2f 80 00       	push   $0x802ff2
  8012f3:	68 94 00 00 00       	push   $0x94
  8012f8:	68 80 2f 80 00       	push   $0x802f80
  8012fd:	e8 e2 f1 ff ff       	call   8004e4 <_panic>
        cprintf("af_p_m.");
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	68 03 30 80 00       	push   $0x803003
  80130a:	e8 ae f2 ff ff       	call   8005bd <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  80130f:	83 c4 0c             	add    $0xc,%esp
  801312:	68 00 10 00 00       	push   $0x1000
  801317:	53                   	push   %ebx
  801318:	68 00 00 40 00       	push   $0x400000
  80131d:	e8 fc f9 ff ff       	call   800d1e <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  801322:	c7 04 24 0b 30 80 00 	movl   $0x80300b,(%esp)
  801329:	e8 8f f2 ff ff       	call   8005bd <cprintf>
}
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	57                   	push   %edi
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  801341:	68 80 11 80 00       	push   $0x801180
  801346:	e8 45 13 00 00       	call   802690 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80134b:	b8 07 00 00 00       	mov    $0x7,%eax
  801350:	cd 30                	int    $0x30
  801352:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801355:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	79 17                	jns    801376 <fork+0x3e>
		panic("sys_exofork failed.");
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	68 19 30 80 00       	push   $0x803019
  801367:	68 b7 00 00 00       	push   $0xb7
  80136c:	68 80 2f 80 00       	push   $0x802f80
  801371:	e8 6e f1 ff ff       	call   8004e4 <_panic>
  801376:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  80137b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80137f:	75 21                	jne    8013a2 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801381:	e8 cb fb ff ff       	call   800f51 <sys_getenvid>
  801386:	25 ff 03 00 00       	and    $0x3ff,%eax
  80138b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80138e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801393:	a3 04 50 80 00       	mov    %eax,0x805004
//		cprintf("we are the child.\n");
		return 0;
  801398:	b8 00 00 00 00       	mov    $0x0,%eax
  80139d:	e9 69 01 00 00       	jmp    80150b <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8013a2:	89 d8                	mov    %ebx,%eax
  8013a4:	c1 e8 16             	shr    $0x16,%eax
  8013a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  8013ae:	a8 01                	test   $0x1,%al
  8013b0:	0f 84 d6 00 00 00    	je     80148c <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  8013b6:	89 de                	mov    %ebx,%esi
  8013b8:	c1 ee 0c             	shr    $0xc,%esi
  8013bb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8013c2:	a8 01                	test   $0x1,%al
  8013c4:	0f 84 c2 00 00 00    	je     80148c <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  8013ca:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  8013d1:	89 f7                	mov    %esi,%edi
  8013d3:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  8013d6:	e8 76 fb ff ff       	call   800f51 <sys_getenvid>
  8013db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  8013de:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8013e5:	f6 c4 04             	test   $0x4,%ah
  8013e8:	74 1c                	je     801406 <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	68 07 0e 00 00       	push   $0xe07
  8013f2:	57                   	push   %edi
  8013f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8013f6:	57                   	push   %edi
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 d4 fb ff ff       	call   800fd2 <sys_page_map>
  8013fe:	83 c4 20             	add    $0x20,%esp
  801401:	e9 86 00 00 00       	jmp    80148c <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  801406:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80140d:	a8 02                	test   $0x2,%al
  80140f:	75 0c                	jne    80141d <fork+0xe5>
  801411:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801418:	f6 c4 08             	test   $0x8,%ah
  80141b:	74 5b                	je     801478 <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  80141d:	83 ec 0c             	sub    $0xc,%esp
  801420:	68 05 08 00 00       	push   $0x805
  801425:	57                   	push   %edi
  801426:	ff 75 e0             	pushl  -0x20(%ebp)
  801429:	57                   	push   %edi
  80142a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80142d:	e8 a0 fb ff ff       	call   800fd2 <sys_page_map>
  801432:	83 c4 20             	add    $0x20,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	79 12                	jns    80144b <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  801439:	50                   	push   %eax
  80143a:	68 9c 30 80 00       	push   $0x80309c
  80143f:	6a 5f                	push   $0x5f
  801441:	68 80 2f 80 00       	push   $0x802f80
  801446:	e8 99 f0 ff ff       	call   8004e4 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	68 05 08 00 00       	push   $0x805
  801453:	57                   	push   %edi
  801454:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801457:	50                   	push   %eax
  801458:	57                   	push   %edi
  801459:	50                   	push   %eax
  80145a:	e8 73 fb ff ff       	call   800fd2 <sys_page_map>
  80145f:	83 c4 20             	add    $0x20,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	79 26                	jns    80148c <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  801466:	50                   	push   %eax
  801467:	68 c0 30 80 00       	push   $0x8030c0
  80146c:	6a 64                	push   $0x64
  80146e:	68 80 2f 80 00       	push   $0x802f80
  801473:	e8 6c f0 ff ff       	call   8004e4 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801478:	83 ec 0c             	sub    $0xc,%esp
  80147b:	6a 05                	push   $0x5
  80147d:	57                   	push   %edi
  80147e:	ff 75 e0             	pushl  -0x20(%ebp)
  801481:	57                   	push   %edi
  801482:	6a 00                	push   $0x0
  801484:	e8 49 fb ff ff       	call   800fd2 <sys_page_map>
  801489:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80148c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801492:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801498:	0f 85 04 ff ff ff    	jne    8013a2 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	6a 07                	push   $0x7
  8014a3:	68 00 f0 bf ee       	push   $0xeebff000
  8014a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8014ab:	e8 df fa ff ff       	call   800f8f <sys_page_alloc>
	if(retv < 0){
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	79 17                	jns    8014ce <fork+0x196>
		panic("sys_page_alloc failed.\n");
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	68 2d 30 80 00       	push   $0x80302d
  8014bf:	68 cc 00 00 00       	push   $0xcc
  8014c4:	68 80 2f 80 00       	push   $0x802f80
  8014c9:	e8 16 f0 ff ff       	call   8004e4 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	68 f5 26 80 00       	push   $0x8026f5
  8014d6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8014d9:	57                   	push   %edi
  8014da:	e8 fb fb ff ff       	call   8010da <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  8014df:	83 c4 08             	add    $0x8,%esp
  8014e2:	6a 02                	push   $0x2
  8014e4:	57                   	push   %edi
  8014e5:	e8 6c fb ff ff       	call   801056 <sys_env_set_status>
	if(retv < 0){
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	79 17                	jns    801508 <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  8014f1:	83 ec 04             	sub    $0x4,%esp
  8014f4:	68 45 30 80 00       	push   $0x803045
  8014f9:	68 dd 00 00 00       	push   $0xdd
  8014fe:	68 80 2f 80 00       	push   $0x802f80
  801503:	e8 dc ef ff ff       	call   8004e4 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  801508:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  80150b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5f                   	pop    %edi
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <sfork>:

// Challenge!
int
sfork(void)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801519:	68 61 30 80 00       	push   $0x803061
  80151e:	68 e8 00 00 00       	push   $0xe8
  801523:	68 80 2f 80 00       	push   $0x802f80
  801528:	e8 b7 ef ff ff       	call   8004e4 <_panic>

0080152d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	05 00 00 00 30       	add    $0x30000000,%eax
  801538:	c1 e8 0c             	shr    $0xc,%eax
}
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801540:	8b 45 08             	mov    0x8(%ebp),%eax
  801543:	05 00 00 00 30       	add    $0x30000000,%eax
  801548:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80154d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    

00801554 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80155f:	89 c2                	mov    %eax,%edx
  801561:	c1 ea 16             	shr    $0x16,%edx
  801564:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80156b:	f6 c2 01             	test   $0x1,%dl
  80156e:	74 11                	je     801581 <fd_alloc+0x2d>
  801570:	89 c2                	mov    %eax,%edx
  801572:	c1 ea 0c             	shr    $0xc,%edx
  801575:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80157c:	f6 c2 01             	test   $0x1,%dl
  80157f:	75 09                	jne    80158a <fd_alloc+0x36>
			*fd_store = fd;
  801581:	89 01                	mov    %eax,(%ecx)
			return 0;
  801583:	b8 00 00 00 00       	mov    $0x0,%eax
  801588:	eb 17                	jmp    8015a1 <fd_alloc+0x4d>
  80158a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80158f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801594:	75 c9                	jne    80155f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801596:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80159c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015a9:	83 f8 1f             	cmp    $0x1f,%eax
  8015ac:	77 36                	ja     8015e4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015ae:	c1 e0 0c             	shl    $0xc,%eax
  8015b1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	c1 ea 16             	shr    $0x16,%edx
  8015bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015c2:	f6 c2 01             	test   $0x1,%dl
  8015c5:	74 24                	je     8015eb <fd_lookup+0x48>
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	c1 ea 0c             	shr    $0xc,%edx
  8015cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015d3:	f6 c2 01             	test   $0x1,%dl
  8015d6:	74 1a                	je     8015f2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015db:	89 02                	mov    %eax,(%edx)
	return 0;
  8015dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e2:	eb 13                	jmp    8015f7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e9:	eb 0c                	jmp    8015f7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f0:	eb 05                	jmp    8015f7 <fd_lookup+0x54>
  8015f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    

008015f9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801602:	ba 60 31 80 00       	mov    $0x803160,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801607:	eb 13                	jmp    80161c <dev_lookup+0x23>
  801609:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80160c:	39 08                	cmp    %ecx,(%eax)
  80160e:	75 0c                	jne    80161c <dev_lookup+0x23>
			*dev = devtab[i];
  801610:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801613:	89 01                	mov    %eax,(%ecx)
			return 0;
  801615:	b8 00 00 00 00       	mov    $0x0,%eax
  80161a:	eb 2e                	jmp    80164a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80161c:	8b 02                	mov    (%edx),%eax
  80161e:	85 c0                	test   %eax,%eax
  801620:	75 e7                	jne    801609 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801622:	a1 04 50 80 00       	mov    0x805004,%eax
  801627:	8b 40 48             	mov    0x48(%eax),%eax
  80162a:	83 ec 04             	sub    $0x4,%esp
  80162d:	51                   	push   %ecx
  80162e:	50                   	push   %eax
  80162f:	68 e4 30 80 00       	push   $0x8030e4
  801634:	e8 84 ef ff ff       	call   8005bd <cprintf>
	*dev = 0;
  801639:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	56                   	push   %esi
  801650:	53                   	push   %ebx
  801651:	83 ec 10             	sub    $0x10,%esp
  801654:	8b 75 08             	mov    0x8(%ebp),%esi
  801657:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80165a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801664:	c1 e8 0c             	shr    $0xc,%eax
  801667:	50                   	push   %eax
  801668:	e8 36 ff ff ff       	call   8015a3 <fd_lookup>
  80166d:	83 c4 08             	add    $0x8,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	78 05                	js     801679 <fd_close+0x2d>
	    || fd != fd2)
  801674:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801677:	74 0c                	je     801685 <fd_close+0x39>
		return (must_exist ? r : 0);
  801679:	84 db                	test   %bl,%bl
  80167b:	ba 00 00 00 00       	mov    $0x0,%edx
  801680:	0f 44 c2             	cmove  %edx,%eax
  801683:	eb 41                	jmp    8016c6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	ff 36                	pushl  (%esi)
  80168e:	e8 66 ff ff ff       	call   8015f9 <dev_lookup>
  801693:	89 c3                	mov    %eax,%ebx
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 1a                	js     8016b6 <fd_close+0x6a>
		if (dev->dev_close)
  80169c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8016a2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	74 0b                	je     8016b6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	56                   	push   %esi
  8016af:	ff d0                	call   *%eax
  8016b1:	89 c3                	mov    %eax,%ebx
  8016b3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016b6:	83 ec 08             	sub    $0x8,%esp
  8016b9:	56                   	push   %esi
  8016ba:	6a 00                	push   $0x0
  8016bc:	e8 53 f9 ff ff       	call   801014 <sys_page_unmap>
	return r;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	89 d8                	mov    %ebx,%eax
}
  8016c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	ff 75 08             	pushl  0x8(%ebp)
  8016da:	e8 c4 fe ff ff       	call   8015a3 <fd_lookup>
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 10                	js     8016f6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	6a 01                	push   $0x1
  8016eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ee:	e8 59 ff ff ff       	call   80164c <fd_close>
  8016f3:	83 c4 10             	add    $0x10,%esp
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <close_all>:

void
close_all(void)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801704:	83 ec 0c             	sub    $0xc,%esp
  801707:	53                   	push   %ebx
  801708:	e8 c0 ff ff ff       	call   8016cd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80170d:	83 c3 01             	add    $0x1,%ebx
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	83 fb 20             	cmp    $0x20,%ebx
  801716:	75 ec                	jne    801704 <close_all+0xc>
		close(i);
}
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	57                   	push   %edi
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	83 ec 2c             	sub    $0x2c,%esp
  801726:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801729:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	ff 75 08             	pushl  0x8(%ebp)
  801730:	e8 6e fe ff ff       	call   8015a3 <fd_lookup>
  801735:	83 c4 08             	add    $0x8,%esp
  801738:	85 c0                	test   %eax,%eax
  80173a:	0f 88 c1 00 00 00    	js     801801 <dup+0xe4>
		return r;
	close(newfdnum);
  801740:	83 ec 0c             	sub    $0xc,%esp
  801743:	56                   	push   %esi
  801744:	e8 84 ff ff ff       	call   8016cd <close>

	newfd = INDEX2FD(newfdnum);
  801749:	89 f3                	mov    %esi,%ebx
  80174b:	c1 e3 0c             	shl    $0xc,%ebx
  80174e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801754:	83 c4 04             	add    $0x4,%esp
  801757:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175a:	e8 de fd ff ff       	call   80153d <fd2data>
  80175f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801761:	89 1c 24             	mov    %ebx,(%esp)
  801764:	e8 d4 fd ff ff       	call   80153d <fd2data>
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80176f:	89 f8                	mov    %edi,%eax
  801771:	c1 e8 16             	shr    $0x16,%eax
  801774:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80177b:	a8 01                	test   $0x1,%al
  80177d:	74 37                	je     8017b6 <dup+0x99>
  80177f:	89 f8                	mov    %edi,%eax
  801781:	c1 e8 0c             	shr    $0xc,%eax
  801784:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80178b:	f6 c2 01             	test   $0x1,%dl
  80178e:	74 26                	je     8017b6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801790:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801797:	83 ec 0c             	sub    $0xc,%esp
  80179a:	25 07 0e 00 00       	and    $0xe07,%eax
  80179f:	50                   	push   %eax
  8017a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017a3:	6a 00                	push   $0x0
  8017a5:	57                   	push   %edi
  8017a6:	6a 00                	push   $0x0
  8017a8:	e8 25 f8 ff ff       	call   800fd2 <sys_page_map>
  8017ad:	89 c7                	mov    %eax,%edi
  8017af:	83 c4 20             	add    $0x20,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 2e                	js     8017e4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017b9:	89 d0                	mov    %edx,%eax
  8017bb:	c1 e8 0c             	shr    $0xc,%eax
  8017be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017c5:	83 ec 0c             	sub    $0xc,%esp
  8017c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8017cd:	50                   	push   %eax
  8017ce:	53                   	push   %ebx
  8017cf:	6a 00                	push   $0x0
  8017d1:	52                   	push   %edx
  8017d2:	6a 00                	push   $0x0
  8017d4:	e8 f9 f7 ff ff       	call   800fd2 <sys_page_map>
  8017d9:	89 c7                	mov    %eax,%edi
  8017db:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8017de:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017e0:	85 ff                	test   %edi,%edi
  8017e2:	79 1d                	jns    801801 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017e4:	83 ec 08             	sub    $0x8,%esp
  8017e7:	53                   	push   %ebx
  8017e8:	6a 00                	push   $0x0
  8017ea:	e8 25 f8 ff ff       	call   801014 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ef:	83 c4 08             	add    $0x8,%esp
  8017f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017f5:	6a 00                	push   $0x0
  8017f7:	e8 18 f8 ff ff       	call   801014 <sys_page_unmap>
	return r;
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	89 f8                	mov    %edi,%eax
}
  801801:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801804:	5b                   	pop    %ebx
  801805:	5e                   	pop    %esi
  801806:	5f                   	pop    %edi
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	53                   	push   %ebx
  80180d:	83 ec 14             	sub    $0x14,%esp
  801810:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801813:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801816:	50                   	push   %eax
  801817:	53                   	push   %ebx
  801818:	e8 86 fd ff ff       	call   8015a3 <fd_lookup>
  80181d:	83 c4 08             	add    $0x8,%esp
  801820:	89 c2                	mov    %eax,%edx
  801822:	85 c0                	test   %eax,%eax
  801824:	78 6d                	js     801893 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182c:	50                   	push   %eax
  80182d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801830:	ff 30                	pushl  (%eax)
  801832:	e8 c2 fd ff ff       	call   8015f9 <dev_lookup>
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	78 4c                	js     80188a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80183e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801841:	8b 42 08             	mov    0x8(%edx),%eax
  801844:	83 e0 03             	and    $0x3,%eax
  801847:	83 f8 01             	cmp    $0x1,%eax
  80184a:	75 21                	jne    80186d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80184c:	a1 04 50 80 00       	mov    0x805004,%eax
  801851:	8b 40 48             	mov    0x48(%eax),%eax
  801854:	83 ec 04             	sub    $0x4,%esp
  801857:	53                   	push   %ebx
  801858:	50                   	push   %eax
  801859:	68 25 31 80 00       	push   $0x803125
  80185e:	e8 5a ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80186b:	eb 26                	jmp    801893 <read+0x8a>
	}
	if (!dev->dev_read)
  80186d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801870:	8b 40 08             	mov    0x8(%eax),%eax
  801873:	85 c0                	test   %eax,%eax
  801875:	74 17                	je     80188e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801877:	83 ec 04             	sub    $0x4,%esp
  80187a:	ff 75 10             	pushl  0x10(%ebp)
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	52                   	push   %edx
  801881:	ff d0                	call   *%eax
  801883:	89 c2                	mov    %eax,%edx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	eb 09                	jmp    801893 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188a:	89 c2                	mov    %eax,%edx
  80188c:	eb 05                	jmp    801893 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80188e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801893:	89 d0                	mov    %edx,%eax
  801895:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	57                   	push   %edi
  80189e:	56                   	push   %esi
  80189f:	53                   	push   %ebx
  8018a0:	83 ec 0c             	sub    $0xc,%esp
  8018a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ae:	eb 21                	jmp    8018d1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018b0:	83 ec 04             	sub    $0x4,%esp
  8018b3:	89 f0                	mov    %esi,%eax
  8018b5:	29 d8                	sub    %ebx,%eax
  8018b7:	50                   	push   %eax
  8018b8:	89 d8                	mov    %ebx,%eax
  8018ba:	03 45 0c             	add    0xc(%ebp),%eax
  8018bd:	50                   	push   %eax
  8018be:	57                   	push   %edi
  8018bf:	e8 45 ff ff ff       	call   801809 <read>
		if (m < 0)
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 10                	js     8018db <readn+0x41>
			return m;
		if (m == 0)
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	74 0a                	je     8018d9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018cf:	01 c3                	add    %eax,%ebx
  8018d1:	39 f3                	cmp    %esi,%ebx
  8018d3:	72 db                	jb     8018b0 <readn+0x16>
  8018d5:	89 d8                	mov    %ebx,%eax
  8018d7:	eb 02                	jmp    8018db <readn+0x41>
  8018d9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018de:	5b                   	pop    %ebx
  8018df:	5e                   	pop    %esi
  8018e0:	5f                   	pop    %edi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	53                   	push   %ebx
  8018e7:	83 ec 14             	sub    $0x14,%esp
  8018ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f0:	50                   	push   %eax
  8018f1:	53                   	push   %ebx
  8018f2:	e8 ac fc ff ff       	call   8015a3 <fd_lookup>
  8018f7:	83 c4 08             	add    $0x8,%esp
  8018fa:	89 c2                	mov    %eax,%edx
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 68                	js     801968 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801906:	50                   	push   %eax
  801907:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190a:	ff 30                	pushl  (%eax)
  80190c:	e8 e8 fc ff ff       	call   8015f9 <dev_lookup>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	78 47                	js     80195f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801918:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80191f:	75 21                	jne    801942 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801921:	a1 04 50 80 00       	mov    0x805004,%eax
  801926:	8b 40 48             	mov    0x48(%eax),%eax
  801929:	83 ec 04             	sub    $0x4,%esp
  80192c:	53                   	push   %ebx
  80192d:	50                   	push   %eax
  80192e:	68 41 31 80 00       	push   $0x803141
  801933:	e8 85 ec ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801940:	eb 26                	jmp    801968 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801942:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801945:	8b 52 0c             	mov    0xc(%edx),%edx
  801948:	85 d2                	test   %edx,%edx
  80194a:	74 17                	je     801963 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	ff 75 10             	pushl  0x10(%ebp)
  801952:	ff 75 0c             	pushl  0xc(%ebp)
  801955:	50                   	push   %eax
  801956:	ff d2                	call   *%edx
  801958:	89 c2                	mov    %eax,%edx
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	eb 09                	jmp    801968 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195f:	89 c2                	mov    %eax,%edx
  801961:	eb 05                	jmp    801968 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801963:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801968:	89 d0                	mov    %edx,%eax
  80196a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <seek>:

int
seek(int fdnum, off_t offset)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801975:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801978:	50                   	push   %eax
  801979:	ff 75 08             	pushl  0x8(%ebp)
  80197c:	e8 22 fc ff ff       	call   8015a3 <fd_lookup>
  801981:	83 c4 08             	add    $0x8,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 0e                	js     801996 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801988:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80198b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80198e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	53                   	push   %ebx
  80199c:	83 ec 14             	sub    $0x14,%esp
  80199f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019a5:	50                   	push   %eax
  8019a6:	53                   	push   %ebx
  8019a7:	e8 f7 fb ff ff       	call   8015a3 <fd_lookup>
  8019ac:	83 c4 08             	add    $0x8,%esp
  8019af:	89 c2                	mov    %eax,%edx
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	78 65                	js     801a1a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b5:	83 ec 08             	sub    $0x8,%esp
  8019b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bb:	50                   	push   %eax
  8019bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019bf:	ff 30                	pushl  (%eax)
  8019c1:	e8 33 fc ff ff       	call   8015f9 <dev_lookup>
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 44                	js     801a11 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019d4:	75 21                	jne    8019f7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019d6:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019db:	8b 40 48             	mov    0x48(%eax),%eax
  8019de:	83 ec 04             	sub    $0x4,%esp
  8019e1:	53                   	push   %ebx
  8019e2:	50                   	push   %eax
  8019e3:	68 04 31 80 00       	push   $0x803104
  8019e8:	e8 d0 eb ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019f5:	eb 23                	jmp    801a1a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8019f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019fa:	8b 52 18             	mov    0x18(%edx),%edx
  8019fd:	85 d2                	test   %edx,%edx
  8019ff:	74 14                	je     801a15 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a01:	83 ec 08             	sub    $0x8,%esp
  801a04:	ff 75 0c             	pushl  0xc(%ebp)
  801a07:	50                   	push   %eax
  801a08:	ff d2                	call   *%edx
  801a0a:	89 c2                	mov    %eax,%edx
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	eb 09                	jmp    801a1a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a11:	89 c2                	mov    %eax,%edx
  801a13:	eb 05                	jmp    801a1a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a15:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801a1a:	89 d0                	mov    %edx,%eax
  801a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	53                   	push   %ebx
  801a25:	83 ec 14             	sub    $0x14,%esp
  801a28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a2e:	50                   	push   %eax
  801a2f:	ff 75 08             	pushl  0x8(%ebp)
  801a32:	e8 6c fb ff ff       	call   8015a3 <fd_lookup>
  801a37:	83 c4 08             	add    $0x8,%esp
  801a3a:	89 c2                	mov    %eax,%edx
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 58                	js     801a98 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a46:	50                   	push   %eax
  801a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a4a:	ff 30                	pushl  (%eax)
  801a4c:	e8 a8 fb ff ff       	call   8015f9 <dev_lookup>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 37                	js     801a8f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a5f:	74 32                	je     801a93 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a61:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a64:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a6b:	00 00 00 
	stat->st_isdir = 0;
  801a6e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a75:	00 00 00 
	stat->st_dev = dev;
  801a78:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	53                   	push   %ebx
  801a82:	ff 75 f0             	pushl  -0x10(%ebp)
  801a85:	ff 50 14             	call   *0x14(%eax)
  801a88:	89 c2                	mov    %eax,%edx
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	eb 09                	jmp    801a98 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a8f:	89 c2                	mov    %eax,%edx
  801a91:	eb 05                	jmp    801a98 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a93:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a98:	89 d0                	mov    %edx,%eax
  801a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801aa4:	83 ec 08             	sub    $0x8,%esp
  801aa7:	6a 00                	push   $0x0
  801aa9:	ff 75 08             	pushl  0x8(%ebp)
  801aac:	e8 dc 01 00 00       	call   801c8d <open>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 1b                	js     801ad5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	ff 75 0c             	pushl  0xc(%ebp)
  801ac0:	50                   	push   %eax
  801ac1:	e8 5b ff ff ff       	call   801a21 <fstat>
  801ac6:	89 c6                	mov    %eax,%esi
	close(fd);
  801ac8:	89 1c 24             	mov    %ebx,(%esp)
  801acb:	e8 fd fb ff ff       	call   8016cd <close>
	return r;
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	89 f0                	mov    %esi,%eax
}
  801ad5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5d                   	pop    %ebp
  801adb:	c3                   	ret    

00801adc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	89 c6                	mov    %eax,%esi
  801ae3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801ae5:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801aec:	75 12                	jne    801b00 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	6a 01                	push   $0x1
  801af3:	e8 c1 0c 00 00       	call   8027b9 <ipc_find_env>
  801af8:	a3 00 50 80 00       	mov    %eax,0x805000
  801afd:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b00:	6a 07                	push   $0x7
  801b02:	68 00 60 80 00       	push   $0x806000
  801b07:	56                   	push   %esi
  801b08:	ff 35 00 50 80 00    	pushl  0x805000
  801b0e:	e8 63 0c 00 00       	call   802776 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801b13:	83 c4 0c             	add    $0xc,%esp
  801b16:	6a 00                	push   $0x0
  801b18:	53                   	push   %ebx
  801b19:	6a 00                	push   $0x0
  801b1b:	e8 f9 0b 00 00       	call   802719 <ipc_recv>
}
  801b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b30:	8b 40 0c             	mov    0xc(%eax),%eax
  801b33:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3b:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b40:	ba 00 00 00 00       	mov    $0x0,%edx
  801b45:	b8 02 00 00 00       	mov    $0x2,%eax
  801b4a:	e8 8d ff ff ff       	call   801adc <fsipc>
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5d:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b62:	ba 00 00 00 00       	mov    $0x0,%edx
  801b67:	b8 06 00 00 00       	mov    $0x6,%eax
  801b6c:	e8 6b ff ff ff       	call   801adc <fsipc>
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	53                   	push   %ebx
  801b77:	83 ec 04             	sub    $0x4,%esp
  801b7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b80:	8b 40 0c             	mov    0xc(%eax),%eax
  801b83:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b88:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8d:	b8 05 00 00 00       	mov    $0x5,%eax
  801b92:	e8 45 ff ff ff       	call   801adc <fsipc>
  801b97:	85 c0                	test   %eax,%eax
  801b99:	78 2c                	js     801bc7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	68 00 60 80 00       	push   $0x806000
  801ba3:	53                   	push   %ebx
  801ba4:	e8 e3 ef ff ff       	call   800b8c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ba9:	a1 80 60 80 00       	mov    0x806080,%eax
  801bae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bb4:	a1 84 60 80 00       	mov    0x806084,%eax
  801bb9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  801bd8:	8b 52 0c             	mov    0xc(%edx),%edx
  801bdb:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801be1:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801be6:	50                   	push   %eax
  801be7:	ff 75 0c             	pushl  0xc(%ebp)
  801bea:	68 08 60 80 00       	push   $0x806008
  801bef:	e8 2a f1 ff ff       	call   800d1e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf9:	b8 04 00 00 00       	mov    $0x4,%eax
  801bfe:	e8 d9 fe ff ff       	call   801adc <fsipc>
	//panic("devfile_write not implemented");
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	56                   	push   %esi
  801c09:	53                   	push   %ebx
  801c0a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	8b 40 0c             	mov    0xc(%eax),%eax
  801c13:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c18:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c23:	b8 03 00 00 00       	mov    $0x3,%eax
  801c28:	e8 af fe ff ff       	call   801adc <fsipc>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 51                	js     801c84 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801c33:	39 c6                	cmp    %eax,%esi
  801c35:	73 19                	jae    801c50 <devfile_read+0x4b>
  801c37:	68 70 31 80 00       	push   $0x803170
  801c3c:	68 77 31 80 00       	push   $0x803177
  801c41:	68 80 00 00 00       	push   $0x80
  801c46:	68 8c 31 80 00       	push   $0x80318c
  801c4b:	e8 94 e8 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801c50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c55:	7e 19                	jle    801c70 <devfile_read+0x6b>
  801c57:	68 97 31 80 00       	push   $0x803197
  801c5c:	68 77 31 80 00       	push   $0x803177
  801c61:	68 81 00 00 00       	push   $0x81
  801c66:	68 8c 31 80 00       	push   $0x80318c
  801c6b:	e8 74 e8 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c70:	83 ec 04             	sub    $0x4,%esp
  801c73:	50                   	push   %eax
  801c74:	68 00 60 80 00       	push   $0x806000
  801c79:	ff 75 0c             	pushl  0xc(%ebp)
  801c7c:	e8 9d f0 ff ff       	call   800d1e <memmove>
	return r;
  801c81:	83 c4 10             	add    $0x10,%esp
}
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c89:	5b                   	pop    %ebx
  801c8a:	5e                   	pop    %esi
  801c8b:	5d                   	pop    %ebp
  801c8c:	c3                   	ret    

00801c8d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	53                   	push   %ebx
  801c91:	83 ec 20             	sub    $0x20,%esp
  801c94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c97:	53                   	push   %ebx
  801c98:	e8 b6 ee ff ff       	call   800b53 <strlen>
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ca5:	7f 67                	jg     801d0e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ca7:	83 ec 0c             	sub    $0xc,%esp
  801caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cad:	50                   	push   %eax
  801cae:	e8 a1 f8 ff ff       	call   801554 <fd_alloc>
  801cb3:	83 c4 10             	add    $0x10,%esp
		return r;
  801cb6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	78 57                	js     801d13 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cbc:	83 ec 08             	sub    $0x8,%esp
  801cbf:	53                   	push   %ebx
  801cc0:	68 00 60 80 00       	push   $0x806000
  801cc5:	e8 c2 ee ff ff       	call   800b8c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccd:	a3 00 64 80 00       	mov    %eax,0x806400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cda:	e8 fd fd ff ff       	call   801adc <fsipc>
  801cdf:	89 c3                	mov    %eax,%ebx
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	79 14                	jns    801cfc <open+0x6f>
		
		fd_close(fd, 0);
  801ce8:	83 ec 08             	sub    $0x8,%esp
  801ceb:	6a 00                	push   $0x0
  801ced:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf0:	e8 57 f9 ff ff       	call   80164c <fd_close>
		return r;
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	89 da                	mov    %ebx,%edx
  801cfa:	eb 17                	jmp    801d13 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801cfc:	83 ec 0c             	sub    $0xc,%esp
  801cff:	ff 75 f4             	pushl  -0xc(%ebp)
  801d02:	e8 26 f8 ff ff       	call   80152d <fd2num>
  801d07:	89 c2                	mov    %eax,%edx
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	eb 05                	jmp    801d13 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d0e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801d13:	89 d0                	mov    %edx,%eax
  801d15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d20:	ba 00 00 00 00       	mov    $0x0,%edx
  801d25:	b8 08 00 00 00       	mov    $0x8,%eax
  801d2a:	e8 ad fd ff ff       	call   801adc <fsipc>
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	57                   	push   %edi
  801d35:	56                   	push   %esi
  801d36:	53                   	push   %ebx
  801d37:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801d3d:	6a 00                	push   $0x0
  801d3f:	ff 75 08             	pushl  0x8(%ebp)
  801d42:	e8 46 ff ff ff       	call   801c8d <open>
  801d47:	89 c7                	mov    %eax,%edi
  801d49:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	85 c0                	test   %eax,%eax
  801d54:	0f 88 ae 04 00 00    	js     802208 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801d5a:	83 ec 04             	sub    $0x4,%esp
  801d5d:	68 00 02 00 00       	push   $0x200
  801d62:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801d68:	50                   	push   %eax
  801d69:	57                   	push   %edi
  801d6a:	e8 2b fb ff ff       	call   80189a <readn>
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	3d 00 02 00 00       	cmp    $0x200,%eax
  801d77:	75 0c                	jne    801d85 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801d79:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d80:	45 4c 46 
  801d83:	74 33                	je     801db8 <spawn+0x87>
		close(fd);
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d8e:	e8 3a f9 ff ff       	call   8016cd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d93:	83 c4 0c             	add    $0xc,%esp
  801d96:	68 7f 45 4c 46       	push   $0x464c457f
  801d9b:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801da1:	68 a3 31 80 00       	push   $0x8031a3
  801da6:	e8 12 e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801db3:	e9 b0 04 00 00       	jmp    802268 <spawn+0x537>
  801db8:	b8 07 00 00 00       	mov    $0x7,%eax
  801dbd:	cd 30                	int    $0x30
  801dbf:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801dc5:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	0f 88 3d 04 00 00    	js     802210 <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801dd3:	89 c6                	mov    %eax,%esi
  801dd5:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801ddb:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801dde:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801de4:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801dea:	b9 11 00 00 00       	mov    $0x11,%ecx
  801def:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801df1:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801df7:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801dfd:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801e02:	be 00 00 00 00       	mov    $0x0,%esi
  801e07:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e0a:	eb 13                	jmp    801e1f <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801e0c:	83 ec 0c             	sub    $0xc,%esp
  801e0f:	50                   	push   %eax
  801e10:	e8 3e ed ff ff       	call   800b53 <strlen>
  801e15:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801e19:	83 c3 01             	add    $0x1,%ebx
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801e26:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	75 df                	jne    801e0c <spawn+0xdb>
  801e2d:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801e33:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801e39:	bf 00 10 40 00       	mov    $0x401000,%edi
  801e3e:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801e40:	89 fa                	mov    %edi,%edx
  801e42:	83 e2 fc             	and    $0xfffffffc,%edx
  801e45:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801e4c:	29 c2                	sub    %eax,%edx
  801e4e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801e54:	8d 42 f8             	lea    -0x8(%edx),%eax
  801e57:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801e5c:	0f 86 be 03 00 00    	jbe    802220 <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e62:	83 ec 04             	sub    $0x4,%esp
  801e65:	6a 07                	push   $0x7
  801e67:	68 00 00 40 00       	push   $0x400000
  801e6c:	6a 00                	push   $0x0
  801e6e:	e8 1c f1 ff ff       	call   800f8f <sys_page_alloc>
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	0f 88 a9 03 00 00    	js     802227 <spawn+0x4f6>
  801e7e:	be 00 00 00 00       	mov    $0x0,%esi
  801e83:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801e89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e8c:	eb 30                	jmp    801ebe <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801e8e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e94:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e9a:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801e9d:	83 ec 08             	sub    $0x8,%esp
  801ea0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ea3:	57                   	push   %edi
  801ea4:	e8 e3 ec ff ff       	call   800b8c <strcpy>
		string_store += strlen(argv[i]) + 1;
  801ea9:	83 c4 04             	add    $0x4,%esp
  801eac:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801eaf:	e8 9f ec ff ff       	call   800b53 <strlen>
  801eb4:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801eb8:	83 c6 01             	add    $0x1,%esi
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801ec4:	7f c8                	jg     801e8e <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ec6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ecc:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801ed2:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ed9:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801edf:	74 19                	je     801efa <spawn+0x1c9>
  801ee1:	68 18 32 80 00       	push   $0x803218
  801ee6:	68 77 31 80 00       	push   $0x803177
  801eeb:	68 f2 00 00 00       	push   $0xf2
  801ef0:	68 bd 31 80 00       	push   $0x8031bd
  801ef5:	e8 ea e5 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801efa:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801f00:	89 f8                	mov    %edi,%eax
  801f02:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801f07:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801f0a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f10:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801f13:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801f19:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801f1f:	83 ec 0c             	sub    $0xc,%esp
  801f22:	6a 07                	push   $0x7
  801f24:	68 00 d0 bf ee       	push   $0xeebfd000
  801f29:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f2f:	68 00 00 40 00       	push   $0x400000
  801f34:	6a 00                	push   $0x0
  801f36:	e8 97 f0 ff ff       	call   800fd2 <sys_page_map>
  801f3b:	89 c3                	mov    %eax,%ebx
  801f3d:	83 c4 20             	add    $0x20,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	0f 88 0e 03 00 00    	js     802256 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801f48:	83 ec 08             	sub    $0x8,%esp
  801f4b:	68 00 00 40 00       	push   $0x400000
  801f50:	6a 00                	push   $0x0
  801f52:	e8 bd f0 ff ff       	call   801014 <sys_page_unmap>
  801f57:	89 c3                	mov    %eax,%ebx
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	0f 88 f2 02 00 00    	js     802256 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f64:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801f6a:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801f71:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f77:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801f7e:	00 00 00 
  801f81:	e9 88 01 00 00       	jmp    80210e <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801f86:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801f8c:	83 38 01             	cmpl   $0x1,(%eax)
  801f8f:	0f 85 6b 01 00 00    	jne    802100 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f95:	89 c7                	mov    %eax,%edi
  801f97:	8b 40 18             	mov    0x18(%eax),%eax
  801f9a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801fa0:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801fa3:	83 f8 01             	cmp    $0x1,%eax
  801fa6:	19 c0                	sbb    %eax,%eax
  801fa8:	83 e0 fe             	and    $0xfffffffe,%eax
  801fab:	83 c0 07             	add    $0x7,%eax
  801fae:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801fb4:	89 f8                	mov    %edi,%eax
  801fb6:	8b 7f 04             	mov    0x4(%edi),%edi
  801fb9:	89 f9                	mov    %edi,%ecx
  801fbb:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801fc1:	8b 78 10             	mov    0x10(%eax),%edi
  801fc4:	8b 50 14             	mov    0x14(%eax),%edx
  801fc7:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801fcd:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801fd0:	89 f0                	mov    %esi,%eax
  801fd2:	25 ff 0f 00 00       	and    $0xfff,%eax
  801fd7:	74 14                	je     801fed <spawn+0x2bc>
		va -= i;
  801fd9:	29 c6                	sub    %eax,%esi
		memsz += i;
  801fdb:	01 c2                	add    %eax,%edx
  801fdd:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801fe3:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801fe5:	29 c1                	sub    %eax,%ecx
  801fe7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fed:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ff2:	e9 f7 00 00 00       	jmp    8020ee <spawn+0x3bd>
		if (i >= filesz) {
  801ff7:	39 df                	cmp    %ebx,%edi
  801ff9:	77 27                	ja     802022 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ffb:	83 ec 04             	sub    $0x4,%esp
  801ffe:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802004:	56                   	push   %esi
  802005:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80200b:	e8 7f ef ff ff       	call   800f8f <sys_page_alloc>
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	85 c0                	test   %eax,%eax
  802015:	0f 89 c7 00 00 00    	jns    8020e2 <spawn+0x3b1>
  80201b:	89 c3                	mov    %eax,%ebx
  80201d:	e9 13 02 00 00       	jmp    802235 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802022:	83 ec 04             	sub    $0x4,%esp
  802025:	6a 07                	push   $0x7
  802027:	68 00 00 40 00       	push   $0x400000
  80202c:	6a 00                	push   $0x0
  80202e:	e8 5c ef ff ff       	call   800f8f <sys_page_alloc>
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	85 c0                	test   %eax,%eax
  802038:	0f 88 ed 01 00 00    	js     80222b <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80203e:	83 ec 08             	sub    $0x8,%esp
  802041:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802047:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80204d:	50                   	push   %eax
  80204e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802054:	e8 16 f9 ff ff       	call   80196f <seek>
  802059:	83 c4 10             	add    $0x10,%esp
  80205c:	85 c0                	test   %eax,%eax
  80205e:	0f 88 cb 01 00 00    	js     80222f <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802064:	83 ec 04             	sub    $0x4,%esp
  802067:	89 f8                	mov    %edi,%eax
  802069:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80206f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802074:	ba 00 10 00 00       	mov    $0x1000,%edx
  802079:	0f 47 c2             	cmova  %edx,%eax
  80207c:	50                   	push   %eax
  80207d:	68 00 00 40 00       	push   $0x400000
  802082:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802088:	e8 0d f8 ff ff       	call   80189a <readn>
  80208d:	83 c4 10             	add    $0x10,%esp
  802090:	85 c0                	test   %eax,%eax
  802092:	0f 88 9b 01 00 00    	js     802233 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802098:	83 ec 0c             	sub    $0xc,%esp
  80209b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8020a1:	56                   	push   %esi
  8020a2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8020a8:	68 00 00 40 00       	push   $0x400000
  8020ad:	6a 00                	push   $0x0
  8020af:	e8 1e ef ff ff       	call   800fd2 <sys_page_map>
  8020b4:	83 c4 20             	add    $0x20,%esp
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	79 15                	jns    8020d0 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8020bb:	50                   	push   %eax
  8020bc:	68 c9 31 80 00       	push   $0x8031c9
  8020c1:	68 25 01 00 00       	push   $0x125
  8020c6:	68 bd 31 80 00       	push   $0x8031bd
  8020cb:	e8 14 e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  8020d0:	83 ec 08             	sub    $0x8,%esp
  8020d3:	68 00 00 40 00       	push   $0x400000
  8020d8:	6a 00                	push   $0x0
  8020da:	e8 35 ef ff ff       	call   801014 <sys_page_unmap>
  8020df:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8020e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020e8:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8020ee:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8020f4:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8020fa:	0f 87 f7 fe ff ff    	ja     801ff7 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802100:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802107:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80210e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802115:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80211b:	0f 8c 65 fe ff ff    	jl     801f86 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802121:	83 ec 0c             	sub    $0xc,%esp
  802124:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80212a:	e8 9e f5 ff ff       	call   8016cd <close>
  80212f:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  802132:	bb 00 00 00 00       	mov    $0x0,%ebx
  802137:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  80213d:	89 d8                	mov    %ebx,%eax
  80213f:	c1 e8 16             	shr    $0x16,%eax
  802142:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802149:	a8 01                	test   $0x1,%al
  80214b:	74 46                	je     802193 <spawn+0x462>
  80214d:	89 d8                	mov    %ebx,%eax
  80214f:	c1 e8 0c             	shr    $0xc,%eax
  802152:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802159:	f6 c2 01             	test   $0x1,%dl
  80215c:	74 35                	je     802193 <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  80215e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  802165:	f6 c2 04             	test   $0x4,%dl
  802168:	74 29                	je     802193 <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  80216a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802171:	f6 c6 04             	test   $0x4,%dh
  802174:	74 1d                	je     802193 <spawn+0x462>
            sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  802176:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80217d:	83 ec 0c             	sub    $0xc,%esp
  802180:	25 07 0e 00 00       	and    $0xe07,%eax
  802185:	50                   	push   %eax
  802186:	53                   	push   %ebx
  802187:	56                   	push   %esi
  802188:	53                   	push   %ebx
  802189:	6a 00                	push   $0x0
  80218b:	e8 42 ee ff ff       	call   800fd2 <sys_page_map>
  802190:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  802193:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802199:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80219f:	75 9c                	jne    80213d <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8021a1:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8021a8:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021ab:	83 ec 08             	sub    $0x8,%esp
  8021ae:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021b4:	50                   	push   %eax
  8021b5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021bb:	e8 d8 ee ff ff       	call   801098 <sys_env_set_trapframe>
  8021c0:	83 c4 10             	add    $0x10,%esp
  8021c3:	85 c0                	test   %eax,%eax
  8021c5:	79 15                	jns    8021dc <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  8021c7:	50                   	push   %eax
  8021c8:	68 e6 31 80 00       	push   $0x8031e6
  8021cd:	68 86 00 00 00       	push   $0x86
  8021d2:	68 bd 31 80 00       	push   $0x8031bd
  8021d7:	e8 08 e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8021dc:	83 ec 08             	sub    $0x8,%esp
  8021df:	6a 02                	push   $0x2
  8021e1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021e7:	e8 6a ee ff ff       	call   801056 <sys_env_set_status>
  8021ec:	83 c4 10             	add    $0x10,%esp
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	79 25                	jns    802218 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  8021f3:	50                   	push   %eax
  8021f4:	68 00 32 80 00       	push   $0x803200
  8021f9:	68 89 00 00 00       	push   $0x89
  8021fe:	68 bd 31 80 00       	push   $0x8031bd
  802203:	e8 dc e2 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802208:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  80220e:	eb 58                	jmp    802268 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802210:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802216:	eb 50                	jmp    802268 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802218:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80221e:	eb 48                	jmp    802268 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802220:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802225:	eb 41                	jmp    802268 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802227:	89 c3                	mov    %eax,%ebx
  802229:	eb 3d                	jmp    802268 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80222b:	89 c3                	mov    %eax,%ebx
  80222d:	eb 06                	jmp    802235 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80222f:	89 c3                	mov    %eax,%ebx
  802231:	eb 02                	jmp    802235 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802233:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802235:	83 ec 0c             	sub    $0xc,%esp
  802238:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80223e:	e8 cd ec ff ff       	call   800f10 <sys_env_destroy>
	close(fd);
  802243:	83 c4 04             	add    $0x4,%esp
  802246:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80224c:	e8 7c f4 ff ff       	call   8016cd <close>
	return r;
  802251:	83 c4 10             	add    $0x10,%esp
  802254:	eb 12                	jmp    802268 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802256:	83 ec 08             	sub    $0x8,%esp
  802259:	68 00 00 40 00       	push   $0x400000
  80225e:	6a 00                	push   $0x0
  802260:	e8 af ed ff ff       	call   801014 <sys_page_unmap>
  802265:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    

00802272 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	56                   	push   %esi
  802276:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802277:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80227a:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80227f:	eb 03                	jmp    802284 <spawnl+0x12>
		argc++;
  802281:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802284:	83 c2 04             	add    $0x4,%edx
  802287:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  80228b:	75 f4                	jne    802281 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80228d:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802294:	83 e2 f0             	and    $0xfffffff0,%edx
  802297:	29 d4                	sub    %edx,%esp
  802299:	8d 54 24 03          	lea    0x3(%esp),%edx
  80229d:	c1 ea 02             	shr    $0x2,%edx
  8022a0:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8022a7:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8022a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022ac:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8022b3:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8022ba:	00 
  8022bb:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8022bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c2:	eb 0a                	jmp    8022ce <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  8022c4:	83 c0 01             	add    $0x1,%eax
  8022c7:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  8022cb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8022ce:	39 d0                	cmp    %edx,%eax
  8022d0:	75 f2                	jne    8022c4 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8022d2:	83 ec 08             	sub    $0x8,%esp
  8022d5:	56                   	push   %esi
  8022d6:	ff 75 08             	pushl  0x8(%ebp)
  8022d9:	e8 53 fa ff ff       	call   801d31 <spawn>
}
  8022de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e1:	5b                   	pop    %ebx
  8022e2:	5e                   	pop    %esi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    

008022e5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	56                   	push   %esi
  8022e9:	53                   	push   %ebx
  8022ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022ed:	83 ec 0c             	sub    $0xc,%esp
  8022f0:	ff 75 08             	pushl  0x8(%ebp)
  8022f3:	e8 45 f2 ff ff       	call   80153d <fd2data>
  8022f8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8022fa:	83 c4 08             	add    $0x8,%esp
  8022fd:	68 3e 32 80 00       	push   $0x80323e
  802302:	53                   	push   %ebx
  802303:	e8 84 e8 ff ff       	call   800b8c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802308:	8b 46 04             	mov    0x4(%esi),%eax
  80230b:	2b 06                	sub    (%esi),%eax
  80230d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802313:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80231a:	00 00 00 
	stat->st_dev = &devpipe;
  80231d:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802324:	40 80 00 
	return 0;
}
  802327:	b8 00 00 00 00       	mov    $0x0,%eax
  80232c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80232f:	5b                   	pop    %ebx
  802330:	5e                   	pop    %esi
  802331:	5d                   	pop    %ebp
  802332:	c3                   	ret    

00802333 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802333:	55                   	push   %ebp
  802334:	89 e5                	mov    %esp,%ebp
  802336:	53                   	push   %ebx
  802337:	83 ec 0c             	sub    $0xc,%esp
  80233a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80233d:	53                   	push   %ebx
  80233e:	6a 00                	push   $0x0
  802340:	e8 cf ec ff ff       	call   801014 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802345:	89 1c 24             	mov    %ebx,(%esp)
  802348:	e8 f0 f1 ff ff       	call   80153d <fd2data>
  80234d:	83 c4 08             	add    $0x8,%esp
  802350:	50                   	push   %eax
  802351:	6a 00                	push   $0x0
  802353:	e8 bc ec ff ff       	call   801014 <sys_page_unmap>
}
  802358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80235b:	c9                   	leave  
  80235c:	c3                   	ret    

0080235d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	57                   	push   %edi
  802361:	56                   	push   %esi
  802362:	53                   	push   %ebx
  802363:	83 ec 1c             	sub    $0x1c,%esp
  802366:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802369:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80236b:	a1 04 50 80 00       	mov    0x805004,%eax
  802370:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802373:	83 ec 0c             	sub    $0xc,%esp
  802376:	ff 75 e0             	pushl  -0x20(%ebp)
  802379:	e8 74 04 00 00       	call   8027f2 <pageref>
  80237e:	89 c3                	mov    %eax,%ebx
  802380:	89 3c 24             	mov    %edi,(%esp)
  802383:	e8 6a 04 00 00       	call   8027f2 <pageref>
  802388:	83 c4 10             	add    $0x10,%esp
  80238b:	39 c3                	cmp    %eax,%ebx
  80238d:	0f 94 c1             	sete   %cl
  802390:	0f b6 c9             	movzbl %cl,%ecx
  802393:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802396:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80239c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80239f:	39 ce                	cmp    %ecx,%esi
  8023a1:	74 1b                	je     8023be <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8023a3:	39 c3                	cmp    %eax,%ebx
  8023a5:	75 c4                	jne    80236b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8023a7:	8b 42 58             	mov    0x58(%edx),%eax
  8023aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023ad:	50                   	push   %eax
  8023ae:	56                   	push   %esi
  8023af:	68 45 32 80 00       	push   $0x803245
  8023b4:	e8 04 e2 ff ff       	call   8005bd <cprintf>
  8023b9:	83 c4 10             	add    $0x10,%esp
  8023bc:	eb ad                	jmp    80236b <_pipeisclosed+0xe>
	}
}
  8023be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    

008023c9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023c9:	55                   	push   %ebp
  8023ca:	89 e5                	mov    %esp,%ebp
  8023cc:	57                   	push   %edi
  8023cd:	56                   	push   %esi
  8023ce:	53                   	push   %ebx
  8023cf:	83 ec 28             	sub    $0x28,%esp
  8023d2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023d5:	56                   	push   %esi
  8023d6:	e8 62 f1 ff ff       	call   80153d <fd2data>
  8023db:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023dd:	83 c4 10             	add    $0x10,%esp
  8023e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8023e5:	eb 4b                	jmp    802432 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8023e7:	89 da                	mov    %ebx,%edx
  8023e9:	89 f0                	mov    %esi,%eax
  8023eb:	e8 6d ff ff ff       	call   80235d <_pipeisclosed>
  8023f0:	85 c0                	test   %eax,%eax
  8023f2:	75 48                	jne    80243c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8023f4:	e8 77 eb ff ff       	call   800f70 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023f9:	8b 43 04             	mov    0x4(%ebx),%eax
  8023fc:	8b 0b                	mov    (%ebx),%ecx
  8023fe:	8d 51 20             	lea    0x20(%ecx),%edx
  802401:	39 d0                	cmp    %edx,%eax
  802403:	73 e2                	jae    8023e7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802405:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802408:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80240c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80240f:	89 c2                	mov    %eax,%edx
  802411:	c1 fa 1f             	sar    $0x1f,%edx
  802414:	89 d1                	mov    %edx,%ecx
  802416:	c1 e9 1b             	shr    $0x1b,%ecx
  802419:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80241c:	83 e2 1f             	and    $0x1f,%edx
  80241f:	29 ca                	sub    %ecx,%edx
  802421:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802425:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802429:	83 c0 01             	add    $0x1,%eax
  80242c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80242f:	83 c7 01             	add    $0x1,%edi
  802432:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802435:	75 c2                	jne    8023f9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802437:	8b 45 10             	mov    0x10(%ebp),%eax
  80243a:	eb 05                	jmp    802441 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80243c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802441:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802444:	5b                   	pop    %ebx
  802445:	5e                   	pop    %esi
  802446:	5f                   	pop    %edi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    

00802449 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802449:	55                   	push   %ebp
  80244a:	89 e5                	mov    %esp,%ebp
  80244c:	57                   	push   %edi
  80244d:	56                   	push   %esi
  80244e:	53                   	push   %ebx
  80244f:	83 ec 18             	sub    $0x18,%esp
  802452:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802455:	57                   	push   %edi
  802456:	e8 e2 f0 ff ff       	call   80153d <fd2data>
  80245b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80245d:	83 c4 10             	add    $0x10,%esp
  802460:	bb 00 00 00 00       	mov    $0x0,%ebx
  802465:	eb 3d                	jmp    8024a4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802467:	85 db                	test   %ebx,%ebx
  802469:	74 04                	je     80246f <devpipe_read+0x26>
				return i;
  80246b:	89 d8                	mov    %ebx,%eax
  80246d:	eb 44                	jmp    8024b3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80246f:	89 f2                	mov    %esi,%edx
  802471:	89 f8                	mov    %edi,%eax
  802473:	e8 e5 fe ff ff       	call   80235d <_pipeisclosed>
  802478:	85 c0                	test   %eax,%eax
  80247a:	75 32                	jne    8024ae <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80247c:	e8 ef ea ff ff       	call   800f70 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802481:	8b 06                	mov    (%esi),%eax
  802483:	3b 46 04             	cmp    0x4(%esi),%eax
  802486:	74 df                	je     802467 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802488:	99                   	cltd   
  802489:	c1 ea 1b             	shr    $0x1b,%edx
  80248c:	01 d0                	add    %edx,%eax
  80248e:	83 e0 1f             	and    $0x1f,%eax
  802491:	29 d0                	sub    %edx,%eax
  802493:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802498:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80249b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80249e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024a1:	83 c3 01             	add    $0x1,%ebx
  8024a4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8024a7:	75 d8                	jne    802481 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8024a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8024ac:	eb 05                	jmp    8024b3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024ae:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8024b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b6:	5b                   	pop    %ebx
  8024b7:	5e                   	pop    %esi
  8024b8:	5f                   	pop    %edi
  8024b9:	5d                   	pop    %ebp
  8024ba:	c3                   	ret    

008024bb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8024bb:	55                   	push   %ebp
  8024bc:	89 e5                	mov    %esp,%ebp
  8024be:	56                   	push   %esi
  8024bf:	53                   	push   %ebx
  8024c0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8024c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c6:	50                   	push   %eax
  8024c7:	e8 88 f0 ff ff       	call   801554 <fd_alloc>
  8024cc:	83 c4 10             	add    $0x10,%esp
  8024cf:	89 c2                	mov    %eax,%edx
  8024d1:	85 c0                	test   %eax,%eax
  8024d3:	0f 88 2c 01 00 00    	js     802605 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024d9:	83 ec 04             	sub    $0x4,%esp
  8024dc:	68 07 04 00 00       	push   $0x407
  8024e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8024e4:	6a 00                	push   $0x0
  8024e6:	e8 a4 ea ff ff       	call   800f8f <sys_page_alloc>
  8024eb:	83 c4 10             	add    $0x10,%esp
  8024ee:	89 c2                	mov    %eax,%edx
  8024f0:	85 c0                	test   %eax,%eax
  8024f2:	0f 88 0d 01 00 00    	js     802605 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8024f8:	83 ec 0c             	sub    $0xc,%esp
  8024fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8024fe:	50                   	push   %eax
  8024ff:	e8 50 f0 ff ff       	call   801554 <fd_alloc>
  802504:	89 c3                	mov    %eax,%ebx
  802506:	83 c4 10             	add    $0x10,%esp
  802509:	85 c0                	test   %eax,%eax
  80250b:	0f 88 e2 00 00 00    	js     8025f3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802511:	83 ec 04             	sub    $0x4,%esp
  802514:	68 07 04 00 00       	push   $0x407
  802519:	ff 75 f0             	pushl  -0x10(%ebp)
  80251c:	6a 00                	push   $0x0
  80251e:	e8 6c ea ff ff       	call   800f8f <sys_page_alloc>
  802523:	89 c3                	mov    %eax,%ebx
  802525:	83 c4 10             	add    $0x10,%esp
  802528:	85 c0                	test   %eax,%eax
  80252a:	0f 88 c3 00 00 00    	js     8025f3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802530:	83 ec 0c             	sub    $0xc,%esp
  802533:	ff 75 f4             	pushl  -0xc(%ebp)
  802536:	e8 02 f0 ff ff       	call   80153d <fd2data>
  80253b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80253d:	83 c4 0c             	add    $0xc,%esp
  802540:	68 07 04 00 00       	push   $0x407
  802545:	50                   	push   %eax
  802546:	6a 00                	push   $0x0
  802548:	e8 42 ea ff ff       	call   800f8f <sys_page_alloc>
  80254d:	89 c3                	mov    %eax,%ebx
  80254f:	83 c4 10             	add    $0x10,%esp
  802552:	85 c0                	test   %eax,%eax
  802554:	0f 88 89 00 00 00    	js     8025e3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80255a:	83 ec 0c             	sub    $0xc,%esp
  80255d:	ff 75 f0             	pushl  -0x10(%ebp)
  802560:	e8 d8 ef ff ff       	call   80153d <fd2data>
  802565:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80256c:	50                   	push   %eax
  80256d:	6a 00                	push   $0x0
  80256f:	56                   	push   %esi
  802570:	6a 00                	push   $0x0
  802572:	e8 5b ea ff ff       	call   800fd2 <sys_page_map>
  802577:	89 c3                	mov    %eax,%ebx
  802579:	83 c4 20             	add    $0x20,%esp
  80257c:	85 c0                	test   %eax,%eax
  80257e:	78 55                	js     8025d5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802580:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802586:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802589:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80258b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80258e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802595:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80259b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80259e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8025a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8025a3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8025aa:	83 ec 0c             	sub    $0xc,%esp
  8025ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8025b0:	e8 78 ef ff ff       	call   80152d <fd2num>
  8025b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025b8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8025ba:	83 c4 04             	add    $0x4,%esp
  8025bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8025c0:	e8 68 ef ff ff       	call   80152d <fd2num>
  8025c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025c8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8025cb:	83 c4 10             	add    $0x10,%esp
  8025ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8025d3:	eb 30                	jmp    802605 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8025d5:	83 ec 08             	sub    $0x8,%esp
  8025d8:	56                   	push   %esi
  8025d9:	6a 00                	push   $0x0
  8025db:	e8 34 ea ff ff       	call   801014 <sys_page_unmap>
  8025e0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8025e3:	83 ec 08             	sub    $0x8,%esp
  8025e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8025e9:	6a 00                	push   $0x0
  8025eb:	e8 24 ea ff ff       	call   801014 <sys_page_unmap>
  8025f0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8025f3:	83 ec 08             	sub    $0x8,%esp
  8025f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8025f9:	6a 00                	push   $0x0
  8025fb:	e8 14 ea ff ff       	call   801014 <sys_page_unmap>
  802600:	83 c4 10             	add    $0x10,%esp
  802603:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802605:	89 d0                	mov    %edx,%eax
  802607:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80260a:	5b                   	pop    %ebx
  80260b:	5e                   	pop    %esi
  80260c:	5d                   	pop    %ebp
  80260d:	c3                   	ret    

0080260e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80260e:	55                   	push   %ebp
  80260f:	89 e5                	mov    %esp,%ebp
  802611:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802617:	50                   	push   %eax
  802618:	ff 75 08             	pushl  0x8(%ebp)
  80261b:	e8 83 ef ff ff       	call   8015a3 <fd_lookup>
  802620:	83 c4 10             	add    $0x10,%esp
  802623:	85 c0                	test   %eax,%eax
  802625:	78 18                	js     80263f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802627:	83 ec 0c             	sub    $0xc,%esp
  80262a:	ff 75 f4             	pushl  -0xc(%ebp)
  80262d:	e8 0b ef ff ff       	call   80153d <fd2data>
	return _pipeisclosed(fd, p);
  802632:	89 c2                	mov    %eax,%edx
  802634:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802637:	e8 21 fd ff ff       	call   80235d <_pipeisclosed>
  80263c:	83 c4 10             	add    $0x10,%esp
}
  80263f:	c9                   	leave  
  802640:	c3                   	ret    

00802641 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802641:	55                   	push   %ebp
  802642:	89 e5                	mov    %esp,%ebp
  802644:	56                   	push   %esi
  802645:	53                   	push   %ebx
  802646:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802649:	85 f6                	test   %esi,%esi
  80264b:	75 16                	jne    802663 <wait+0x22>
  80264d:	68 5d 32 80 00       	push   $0x80325d
  802652:	68 77 31 80 00       	push   $0x803177
  802657:	6a 09                	push   $0x9
  802659:	68 68 32 80 00       	push   $0x803268
  80265e:	e8 81 de ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802663:	89 f3                	mov    %esi,%ebx
  802665:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80266b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80266e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802674:	eb 05                	jmp    80267b <wait+0x3a>
		sys_yield();
  802676:	e8 f5 e8 ff ff       	call   800f70 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80267b:	8b 43 48             	mov    0x48(%ebx),%eax
  80267e:	39 c6                	cmp    %eax,%esi
  802680:	75 07                	jne    802689 <wait+0x48>
  802682:	8b 43 54             	mov    0x54(%ebx),%eax
  802685:	85 c0                	test   %eax,%eax
  802687:	75 ed                	jne    802676 <wait+0x35>
		sys_yield();
}
  802689:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80268c:	5b                   	pop    %ebx
  80268d:	5e                   	pop    %esi
  80268e:	5d                   	pop    %ebp
  80268f:	c3                   	ret    

00802690 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802690:	55                   	push   %ebp
  802691:	89 e5                	mov    %esp,%ebp
  802693:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  802696:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80269d:	75 4c                	jne    8026eb <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  80269f:	a1 04 50 80 00       	mov    0x805004,%eax
  8026a4:	8b 40 48             	mov    0x48(%eax),%eax
  8026a7:	83 ec 04             	sub    $0x4,%esp
  8026aa:	6a 07                	push   $0x7
  8026ac:	68 00 f0 bf ee       	push   $0xeebff000
  8026b1:	50                   	push   %eax
  8026b2:	e8 d8 e8 ff ff       	call   800f8f <sys_page_alloc>
		if(retv != 0){
  8026b7:	83 c4 10             	add    $0x10,%esp
  8026ba:	85 c0                	test   %eax,%eax
  8026bc:	74 14                	je     8026d2 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  8026be:	83 ec 04             	sub    $0x4,%esp
  8026c1:	68 74 32 80 00       	push   $0x803274
  8026c6:	6a 27                	push   $0x27
  8026c8:	68 a0 32 80 00       	push   $0x8032a0
  8026cd:	e8 12 de ff ff       	call   8004e4 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8026d2:	a1 04 50 80 00       	mov    0x805004,%eax
  8026d7:	8b 40 48             	mov    0x48(%eax),%eax
  8026da:	83 ec 08             	sub    $0x8,%esp
  8026dd:	68 f5 26 80 00       	push   $0x8026f5
  8026e2:	50                   	push   %eax
  8026e3:	e8 f2 e9 ff ff       	call   8010da <sys_env_set_pgfault_upcall>
  8026e8:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ee:	a3 00 70 80 00       	mov    %eax,0x807000

}
  8026f3:	c9                   	leave  
  8026f4:	c3                   	ret    

008026f5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026f5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026f6:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026fb:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  8026fd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  802700:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  802704:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  802709:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  80270d:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  80270f:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  802712:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  802713:	83 c4 04             	add    $0x4,%esp
	popfl
  802716:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802717:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802718:	c3                   	ret    

00802719 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802719:	55                   	push   %ebp
  80271a:	89 e5                	mov    %esp,%ebp
  80271c:	56                   	push   %esi
  80271d:	53                   	push   %ebx
  80271e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802721:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  802724:	83 ec 0c             	sub    $0xc,%esp
  802727:	ff 75 0c             	pushl  0xc(%ebp)
  80272a:	e8 10 ea ff ff       	call   80113f <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  80272f:	83 c4 10             	add    $0x10,%esp
  802732:	85 f6                	test   %esi,%esi
  802734:	74 1c                	je     802752 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  802736:	a1 04 50 80 00       	mov    0x805004,%eax
  80273b:	8b 40 78             	mov    0x78(%eax),%eax
  80273e:	89 06                	mov    %eax,(%esi)
  802740:	eb 10                	jmp    802752 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802742:	83 ec 0c             	sub    $0xc,%esp
  802745:	68 ae 32 80 00       	push   $0x8032ae
  80274a:	e8 6e de ff ff       	call   8005bd <cprintf>
  80274f:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802752:	a1 04 50 80 00       	mov    0x805004,%eax
  802757:	8b 50 74             	mov    0x74(%eax),%edx
  80275a:	85 d2                	test   %edx,%edx
  80275c:	74 e4                	je     802742 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  80275e:	85 db                	test   %ebx,%ebx
  802760:	74 05                	je     802767 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802762:	8b 40 74             	mov    0x74(%eax),%eax
  802765:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802767:	a1 04 50 80 00       	mov    0x805004,%eax
  80276c:	8b 40 70             	mov    0x70(%eax),%eax

}
  80276f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802772:	5b                   	pop    %ebx
  802773:	5e                   	pop    %esi
  802774:	5d                   	pop    %ebp
  802775:	c3                   	ret    

00802776 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802776:	55                   	push   %ebp
  802777:	89 e5                	mov    %esp,%ebp
  802779:	57                   	push   %edi
  80277a:	56                   	push   %esi
  80277b:	53                   	push   %ebx
  80277c:	83 ec 0c             	sub    $0xc,%esp
  80277f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802782:	8b 75 0c             	mov    0xc(%ebp),%esi
  802785:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  802788:	85 db                	test   %ebx,%ebx
  80278a:	75 13                	jne    80279f <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  80278c:	6a 00                	push   $0x0
  80278e:	68 00 00 c0 ee       	push   $0xeec00000
  802793:	56                   	push   %esi
  802794:	57                   	push   %edi
  802795:	e8 82 e9 ff ff       	call   80111c <sys_ipc_try_send>
  80279a:	83 c4 10             	add    $0x10,%esp
  80279d:	eb 0e                	jmp    8027ad <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  80279f:	ff 75 14             	pushl  0x14(%ebp)
  8027a2:	53                   	push   %ebx
  8027a3:	56                   	push   %esi
  8027a4:	57                   	push   %edi
  8027a5:	e8 72 e9 ff ff       	call   80111c <sys_ipc_try_send>
  8027aa:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  8027ad:	85 c0                	test   %eax,%eax
  8027af:	75 d7                	jne    802788 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  8027b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027b4:	5b                   	pop    %ebx
  8027b5:	5e                   	pop    %esi
  8027b6:	5f                   	pop    %edi
  8027b7:	5d                   	pop    %ebp
  8027b8:	c3                   	ret    

008027b9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027b9:	55                   	push   %ebp
  8027ba:	89 e5                	mov    %esp,%ebp
  8027bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027bf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027c4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027c7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027cd:	8b 52 50             	mov    0x50(%edx),%edx
  8027d0:	39 ca                	cmp    %ecx,%edx
  8027d2:	75 0d                	jne    8027e1 <ipc_find_env+0x28>
			return envs[i].env_id;
  8027d4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027dc:	8b 40 48             	mov    0x48(%eax),%eax
  8027df:	eb 0f                	jmp    8027f0 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027e1:	83 c0 01             	add    $0x1,%eax
  8027e4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027e9:	75 d9                	jne    8027c4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027f0:	5d                   	pop    %ebp
  8027f1:	c3                   	ret    

008027f2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027f2:	55                   	push   %ebp
  8027f3:	89 e5                	mov    %esp,%ebp
  8027f5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027f8:	89 d0                	mov    %edx,%eax
  8027fa:	c1 e8 16             	shr    $0x16,%eax
  8027fd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802804:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802809:	f6 c1 01             	test   $0x1,%cl
  80280c:	74 1d                	je     80282b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80280e:	c1 ea 0c             	shr    $0xc,%edx
  802811:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802818:	f6 c2 01             	test   $0x1,%dl
  80281b:	74 0e                	je     80282b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80281d:	c1 ea 0c             	shr    $0xc,%edx
  802820:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802827:	ef 
  802828:	0f b7 c0             	movzwl %ax,%eax
}
  80282b:	5d                   	pop    %ebp
  80282c:	c3                   	ret    
  80282d:	66 90                	xchg   %ax,%ax
  80282f:	90                   	nop

00802830 <__udivdi3>:
  802830:	55                   	push   %ebp
  802831:	57                   	push   %edi
  802832:	56                   	push   %esi
  802833:	53                   	push   %ebx
  802834:	83 ec 1c             	sub    $0x1c,%esp
  802837:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80283b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80283f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802843:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802847:	85 f6                	test   %esi,%esi
  802849:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80284d:	89 ca                	mov    %ecx,%edx
  80284f:	89 f8                	mov    %edi,%eax
  802851:	75 3d                	jne    802890 <__udivdi3+0x60>
  802853:	39 cf                	cmp    %ecx,%edi
  802855:	0f 87 c5 00 00 00    	ja     802920 <__udivdi3+0xf0>
  80285b:	85 ff                	test   %edi,%edi
  80285d:	89 fd                	mov    %edi,%ebp
  80285f:	75 0b                	jne    80286c <__udivdi3+0x3c>
  802861:	b8 01 00 00 00       	mov    $0x1,%eax
  802866:	31 d2                	xor    %edx,%edx
  802868:	f7 f7                	div    %edi
  80286a:	89 c5                	mov    %eax,%ebp
  80286c:	89 c8                	mov    %ecx,%eax
  80286e:	31 d2                	xor    %edx,%edx
  802870:	f7 f5                	div    %ebp
  802872:	89 c1                	mov    %eax,%ecx
  802874:	89 d8                	mov    %ebx,%eax
  802876:	89 cf                	mov    %ecx,%edi
  802878:	f7 f5                	div    %ebp
  80287a:	89 c3                	mov    %eax,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	39 ce                	cmp    %ecx,%esi
  802892:	77 74                	ja     802908 <__udivdi3+0xd8>
  802894:	0f bd fe             	bsr    %esi,%edi
  802897:	83 f7 1f             	xor    $0x1f,%edi
  80289a:	0f 84 98 00 00 00    	je     802938 <__udivdi3+0x108>
  8028a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8028a5:	89 f9                	mov    %edi,%ecx
  8028a7:	89 c5                	mov    %eax,%ebp
  8028a9:	29 fb                	sub    %edi,%ebx
  8028ab:	d3 e6                	shl    %cl,%esi
  8028ad:	89 d9                	mov    %ebx,%ecx
  8028af:	d3 ed                	shr    %cl,%ebp
  8028b1:	89 f9                	mov    %edi,%ecx
  8028b3:	d3 e0                	shl    %cl,%eax
  8028b5:	09 ee                	or     %ebp,%esi
  8028b7:	89 d9                	mov    %ebx,%ecx
  8028b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028bd:	89 d5                	mov    %edx,%ebp
  8028bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028c3:	d3 ed                	shr    %cl,%ebp
  8028c5:	89 f9                	mov    %edi,%ecx
  8028c7:	d3 e2                	shl    %cl,%edx
  8028c9:	89 d9                	mov    %ebx,%ecx
  8028cb:	d3 e8                	shr    %cl,%eax
  8028cd:	09 c2                	or     %eax,%edx
  8028cf:	89 d0                	mov    %edx,%eax
  8028d1:	89 ea                	mov    %ebp,%edx
  8028d3:	f7 f6                	div    %esi
  8028d5:	89 d5                	mov    %edx,%ebp
  8028d7:	89 c3                	mov    %eax,%ebx
  8028d9:	f7 64 24 0c          	mull   0xc(%esp)
  8028dd:	39 d5                	cmp    %edx,%ebp
  8028df:	72 10                	jb     8028f1 <__udivdi3+0xc1>
  8028e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8028e5:	89 f9                	mov    %edi,%ecx
  8028e7:	d3 e6                	shl    %cl,%esi
  8028e9:	39 c6                	cmp    %eax,%esi
  8028eb:	73 07                	jae    8028f4 <__udivdi3+0xc4>
  8028ed:	39 d5                	cmp    %edx,%ebp
  8028ef:	75 03                	jne    8028f4 <__udivdi3+0xc4>
  8028f1:	83 eb 01             	sub    $0x1,%ebx
  8028f4:	31 ff                	xor    %edi,%edi
  8028f6:	89 d8                	mov    %ebx,%eax
  8028f8:	89 fa                	mov    %edi,%edx
  8028fa:	83 c4 1c             	add    $0x1c,%esp
  8028fd:	5b                   	pop    %ebx
  8028fe:	5e                   	pop    %esi
  8028ff:	5f                   	pop    %edi
  802900:	5d                   	pop    %ebp
  802901:	c3                   	ret    
  802902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802908:	31 ff                	xor    %edi,%edi
  80290a:	31 db                	xor    %ebx,%ebx
  80290c:	89 d8                	mov    %ebx,%eax
  80290e:	89 fa                	mov    %edi,%edx
  802910:	83 c4 1c             	add    $0x1c,%esp
  802913:	5b                   	pop    %ebx
  802914:	5e                   	pop    %esi
  802915:	5f                   	pop    %edi
  802916:	5d                   	pop    %ebp
  802917:	c3                   	ret    
  802918:	90                   	nop
  802919:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802920:	89 d8                	mov    %ebx,%eax
  802922:	f7 f7                	div    %edi
  802924:	31 ff                	xor    %edi,%edi
  802926:	89 c3                	mov    %eax,%ebx
  802928:	89 d8                	mov    %ebx,%eax
  80292a:	89 fa                	mov    %edi,%edx
  80292c:	83 c4 1c             	add    $0x1c,%esp
  80292f:	5b                   	pop    %ebx
  802930:	5e                   	pop    %esi
  802931:	5f                   	pop    %edi
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    
  802934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802938:	39 ce                	cmp    %ecx,%esi
  80293a:	72 0c                	jb     802948 <__udivdi3+0x118>
  80293c:	31 db                	xor    %ebx,%ebx
  80293e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802942:	0f 87 34 ff ff ff    	ja     80287c <__udivdi3+0x4c>
  802948:	bb 01 00 00 00       	mov    $0x1,%ebx
  80294d:	e9 2a ff ff ff       	jmp    80287c <__udivdi3+0x4c>
  802952:	66 90                	xchg   %ax,%ax
  802954:	66 90                	xchg   %ax,%ax
  802956:	66 90                	xchg   %ax,%ax
  802958:	66 90                	xchg   %ax,%ax
  80295a:	66 90                	xchg   %ax,%ax
  80295c:	66 90                	xchg   %ax,%ax
  80295e:	66 90                	xchg   %ax,%ax

00802960 <__umoddi3>:
  802960:	55                   	push   %ebp
  802961:	57                   	push   %edi
  802962:	56                   	push   %esi
  802963:	53                   	push   %ebx
  802964:	83 ec 1c             	sub    $0x1c,%esp
  802967:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80296b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80296f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802973:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802977:	85 d2                	test   %edx,%edx
  802979:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80297d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802981:	89 f3                	mov    %esi,%ebx
  802983:	89 3c 24             	mov    %edi,(%esp)
  802986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80298a:	75 1c                	jne    8029a8 <__umoddi3+0x48>
  80298c:	39 f7                	cmp    %esi,%edi
  80298e:	76 50                	jbe    8029e0 <__umoddi3+0x80>
  802990:	89 c8                	mov    %ecx,%eax
  802992:	89 f2                	mov    %esi,%edx
  802994:	f7 f7                	div    %edi
  802996:	89 d0                	mov    %edx,%eax
  802998:	31 d2                	xor    %edx,%edx
  80299a:	83 c4 1c             	add    $0x1c,%esp
  80299d:	5b                   	pop    %ebx
  80299e:	5e                   	pop    %esi
  80299f:	5f                   	pop    %edi
  8029a0:	5d                   	pop    %ebp
  8029a1:	c3                   	ret    
  8029a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029a8:	39 f2                	cmp    %esi,%edx
  8029aa:	89 d0                	mov    %edx,%eax
  8029ac:	77 52                	ja     802a00 <__umoddi3+0xa0>
  8029ae:	0f bd ea             	bsr    %edx,%ebp
  8029b1:	83 f5 1f             	xor    $0x1f,%ebp
  8029b4:	75 5a                	jne    802a10 <__umoddi3+0xb0>
  8029b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8029ba:	0f 82 e0 00 00 00    	jb     802aa0 <__umoddi3+0x140>
  8029c0:	39 0c 24             	cmp    %ecx,(%esp)
  8029c3:	0f 86 d7 00 00 00    	jbe    802aa0 <__umoddi3+0x140>
  8029c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029d1:	83 c4 1c             	add    $0x1c,%esp
  8029d4:	5b                   	pop    %ebx
  8029d5:	5e                   	pop    %esi
  8029d6:	5f                   	pop    %edi
  8029d7:	5d                   	pop    %ebp
  8029d8:	c3                   	ret    
  8029d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029e0:	85 ff                	test   %edi,%edi
  8029e2:	89 fd                	mov    %edi,%ebp
  8029e4:	75 0b                	jne    8029f1 <__umoddi3+0x91>
  8029e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029eb:	31 d2                	xor    %edx,%edx
  8029ed:	f7 f7                	div    %edi
  8029ef:	89 c5                	mov    %eax,%ebp
  8029f1:	89 f0                	mov    %esi,%eax
  8029f3:	31 d2                	xor    %edx,%edx
  8029f5:	f7 f5                	div    %ebp
  8029f7:	89 c8                	mov    %ecx,%eax
  8029f9:	f7 f5                	div    %ebp
  8029fb:	89 d0                	mov    %edx,%eax
  8029fd:	eb 99                	jmp    802998 <__umoddi3+0x38>
  8029ff:	90                   	nop
  802a00:	89 c8                	mov    %ecx,%eax
  802a02:	89 f2                	mov    %esi,%edx
  802a04:	83 c4 1c             	add    $0x1c,%esp
  802a07:	5b                   	pop    %ebx
  802a08:	5e                   	pop    %esi
  802a09:	5f                   	pop    %edi
  802a0a:	5d                   	pop    %ebp
  802a0b:	c3                   	ret    
  802a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a10:	8b 34 24             	mov    (%esp),%esi
  802a13:	bf 20 00 00 00       	mov    $0x20,%edi
  802a18:	89 e9                	mov    %ebp,%ecx
  802a1a:	29 ef                	sub    %ebp,%edi
  802a1c:	d3 e0                	shl    %cl,%eax
  802a1e:	89 f9                	mov    %edi,%ecx
  802a20:	89 f2                	mov    %esi,%edx
  802a22:	d3 ea                	shr    %cl,%edx
  802a24:	89 e9                	mov    %ebp,%ecx
  802a26:	09 c2                	or     %eax,%edx
  802a28:	89 d8                	mov    %ebx,%eax
  802a2a:	89 14 24             	mov    %edx,(%esp)
  802a2d:	89 f2                	mov    %esi,%edx
  802a2f:	d3 e2                	shl    %cl,%edx
  802a31:	89 f9                	mov    %edi,%ecx
  802a33:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802a3b:	d3 e8                	shr    %cl,%eax
  802a3d:	89 e9                	mov    %ebp,%ecx
  802a3f:	89 c6                	mov    %eax,%esi
  802a41:	d3 e3                	shl    %cl,%ebx
  802a43:	89 f9                	mov    %edi,%ecx
  802a45:	89 d0                	mov    %edx,%eax
  802a47:	d3 e8                	shr    %cl,%eax
  802a49:	89 e9                	mov    %ebp,%ecx
  802a4b:	09 d8                	or     %ebx,%eax
  802a4d:	89 d3                	mov    %edx,%ebx
  802a4f:	89 f2                	mov    %esi,%edx
  802a51:	f7 34 24             	divl   (%esp)
  802a54:	89 d6                	mov    %edx,%esi
  802a56:	d3 e3                	shl    %cl,%ebx
  802a58:	f7 64 24 04          	mull   0x4(%esp)
  802a5c:	39 d6                	cmp    %edx,%esi
  802a5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a62:	89 d1                	mov    %edx,%ecx
  802a64:	89 c3                	mov    %eax,%ebx
  802a66:	72 08                	jb     802a70 <__umoddi3+0x110>
  802a68:	75 11                	jne    802a7b <__umoddi3+0x11b>
  802a6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a6e:	73 0b                	jae    802a7b <__umoddi3+0x11b>
  802a70:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a74:	1b 14 24             	sbb    (%esp),%edx
  802a77:	89 d1                	mov    %edx,%ecx
  802a79:	89 c3                	mov    %eax,%ebx
  802a7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a7f:	29 da                	sub    %ebx,%edx
  802a81:	19 ce                	sbb    %ecx,%esi
  802a83:	89 f9                	mov    %edi,%ecx
  802a85:	89 f0                	mov    %esi,%eax
  802a87:	d3 e0                	shl    %cl,%eax
  802a89:	89 e9                	mov    %ebp,%ecx
  802a8b:	d3 ea                	shr    %cl,%edx
  802a8d:	89 e9                	mov    %ebp,%ecx
  802a8f:	d3 ee                	shr    %cl,%esi
  802a91:	09 d0                	or     %edx,%eax
  802a93:	89 f2                	mov    %esi,%edx
  802a95:	83 c4 1c             	add    $0x1c,%esp
  802a98:	5b                   	pop    %ebx
  802a99:	5e                   	pop    %esi
  802a9a:	5f                   	pop    %edi
  802a9b:	5d                   	pop    %ebp
  802a9c:	c3                   	ret    
  802a9d:	8d 76 00             	lea    0x0(%esi),%esi
  802aa0:	29 f9                	sub    %edi,%ecx
  802aa2:	19 d6                	sbb    %edx,%esi
  802aa4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802aa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802aac:	e9 18 ff ff ff       	jmp    8029c9 <__umoddi3+0x69>
