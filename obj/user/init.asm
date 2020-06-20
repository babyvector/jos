
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 6e 03 00 00       	call   80039f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 c0 25 80 00       	push   $0x8025c0
  800072:	e8 61 04 00 00       	call   8004d8 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 88 26 80 00       	push   $0x802688
  8000a1:	e8 32 04 00 00       	call   8004d8 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 cf 25 80 00       	push   $0x8025cf
  8000b3:	e8 20 04 00 00       	call   8004d8 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 20 50 80 00       	push   $0x805020
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 c4 26 80 00       	push   $0x8026c4
  8000dd:	e8 f6 03 00 00       	call   8004d8 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 e6 25 80 00       	push   $0x8025e6
  8000ef:	e8 e4 03 00 00       	call   8004d8 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 fc 25 80 00       	push   $0x8025fc
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 bc 09 00 00       	call   800ac7 <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 08 26 80 00       	push   $0x802608
  800123:	56                   	push   %esi
  800124:	e8 9e 09 00 00       	call   800ac7 <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 92 09 00 00       	call   800ac7 <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 09 26 80 00       	push   $0x802609
  80013d:	56                   	push   %esi
  80013e:	e8 84 09 00 00       	call   800ac7 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 0b 26 80 00       	push   $0x80260b
  80015d:	e8 76 03 00 00       	call   8004d8 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 0f 26 80 00 	movl   $0x80260f,(%esp)
  800169:	e8 6a 03 00 00       	call   8004d8 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 c1 10 00 00       	call   80123b <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c6 01 00 00       	call   800345 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %e", r);
  800186:	50                   	push   %eax
  800187:	68 21 26 80 00       	push   $0x802621
  80018c:	6a 37                	push   $0x37
  80018e:	68 2e 26 80 00       	push   $0x80262e
  800193:	e8 67 02 00 00       	call   8003ff <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 3a 26 80 00       	push   $0x80263a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 2e 26 80 00       	push   $0x80262e
  8001a9:	e8 51 02 00 00       	call   8003ff <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 d1 10 00 00       	call   80128b <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %e", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 54 26 80 00       	push   $0x802654
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 2e 26 80 00       	push   $0x80262e
  8001ce:	e8 2c 02 00 00       	call   8003ff <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 5c 26 80 00       	push   $0x80265c
  8001db:	e8 f8 02 00 00       	call   8004d8 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 70 26 80 00       	push   $0x802670
  8001ea:	68 6f 26 80 00       	push   $0x80266f
  8001ef:	e8 ec 1b 00 00       	call   801de0 <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %e\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 73 26 80 00       	push   $0x802673
  800204:	e8 cf 02 00 00       	call   8004d8 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 98 1f 00 00       	call   8021af <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 f3 26 80 00       	push   $0x8026f3
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 6e 08 00 00       	call   800aa7 <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2d                	jmp    800286 <devcons_write+0x46>
		m = n - tot;
  800259:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80025e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800261:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800266:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	53                   	push   %ebx
  80026d:	03 45 0c             	add    0xc(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	57                   	push   %edi
  800272:	e8 c2 09 00 00       	call   800c39 <memmove>
		sys_cputs(buf, m);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	57                   	push   %edi
  80027c:	e8 6d 0b 00 00       	call   800dee <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800281:	01 de                	add    %ebx,%esi
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	89 f0                	mov    %esi,%eax
  800288:	3b 75 10             	cmp    0x10(%ebp),%esi
  80028b:	72 cc                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8002a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a4:	74 2a                	je     8002d0 <devcons_read+0x3b>
  8002a6:	eb 05                	jmp    8002ad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a8:	e8 de 0b 00 00       	call   800e8b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ad:	e8 5a 0b 00 00       	call   800e0c <sys_cgetc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	74 f2                	je     8002a8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	78 16                	js     8002d0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ba:	83 f8 04             	cmp    $0x4,%eax
  8002bd:	74 0c                	je     8002cb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c2:	88 02                	mov    %al,(%edx)
	return 1;
  8002c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8002c9:	eb 05                	jmp    8002d0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002de:	6a 01                	push   $0x1
  8002e0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 05 0b 00 00       	call   800dee <sys_cputs>
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <getchar>:

int
getchar(void)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f4:	6a 01                	push   $0x1
  8002f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	6a 00                	push   $0x0
  8002fc:	e8 76 10 00 00       	call   801377 <read>
	if (r < 0)
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	85 c0                	test   %eax,%eax
  800306:	78 0f                	js     800317 <getchar+0x29>
		return r;
	if (r < 1)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 06                	jle    800312 <getchar+0x24>
		return -E_EOF;
	return c;
  80030c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800310:	eb 05                	jmp    800317 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800312:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80031f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800322:	50                   	push   %eax
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 e6 0d 00 00       	call   801111 <fd_lookup>
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	85 c0                	test   %eax,%eax
  800330:	78 11                	js     800343 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800335:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80033b:	39 10                	cmp    %edx,(%eax)
  80033d:	0f 94 c0             	sete   %al
  800340:	0f b6 c0             	movzbl %al,%eax
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <opencons>:

int
opencons(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 6e 0d 00 00       	call   8010c2 <fd_alloc>
  800354:	83 c4 10             	add    $0x10,%esp
		return r;
  800357:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800359:	85 c0                	test   %eax,%eax
  80035b:	78 3e                	js     80039b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	68 07 04 00 00       	push   $0x407
  800365:	ff 75 f4             	pushl  -0xc(%ebp)
  800368:	6a 00                	push   $0x0
  80036a:	e8 3b 0b 00 00       	call   800eaa <sys_page_alloc>
  80036f:	83 c4 10             	add    $0x10,%esp
		return r;
  800372:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	78 23                	js     80039b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800378:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800381:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800386:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	e8 05 0d 00 00       	call   80109b <fd2num>
  800396:	89 c2                	mov    %eax,%edx
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	89 d0                	mov    %edx,%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8003aa:	e8 bd 0a 00 00       	call   800e6c <sys_getenvid>
  8003af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bc:	a3 90 67 80 00       	mov    %eax,0x806790
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7e 07                	jle    8003cc <libmain+0x2d>
		binaryname = argv[0];
  8003c5:	8b 06                	mov    (%esi),%eax
  8003c7:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	e8 88 fc ff ff       	call   80005e <umain>

	// exit gracefully
	exit();
  8003d6:	e8 0a 00 00 00       	call   8003e5 <exit>
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003eb:	e8 76 0e 00 00       	call   801266 <close_all>
	sys_env_destroy(0);
  8003f0:	83 ec 0c             	sub    $0xc,%esp
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 31 0a 00 00       	call   800e2b <sys_env_destroy>
}
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800407:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040d:	e8 5a 0a 00 00       	call   800e6c <sys_getenvid>
  800412:	83 ec 0c             	sub    $0xc,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	56                   	push   %esi
  80041c:	50                   	push   %eax
  80041d:	68 0c 27 80 00       	push   $0x80270c
  800422:	e8 b1 00 00 00       	call   8004d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800427:	83 c4 18             	add    $0x18,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 54 00 00 00       	call   800487 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 e0 2b 80 00 	movl   $0x802be0,(%esp)
  80043a:	e8 99 00 00 00       	call   8004d8 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x43>

00800445 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	53                   	push   %ebx
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80044f:	8b 13                	mov    (%ebx),%edx
  800451:	8d 42 01             	lea    0x1(%edx),%eax
  800454:	89 03                	mov    %eax,(%ebx)
  800456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800459:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800462:	75 1a                	jne    80047e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 ff 00 00 00       	push   $0xff
  80046c:	8d 43 08             	lea    0x8(%ebx),%eax
  80046f:	50                   	push   %eax
  800470:	e8 79 09 00 00       	call   800dee <sys_cputs>
		b->idx = 0;
  800475:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	68 45 04 80 00       	push   $0x800445
  8004b6:	e8 54 01 00 00       	call   80060f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bb:	83 c4 08             	add    $0x8,%esp
  8004be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 1e 09 00 00       	call   800dee <sys_cputs>

	return b.cnt;
}
  8004d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e1:	50                   	push   %eax
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 9d ff ff ff       	call   800487 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	57                   	push   %edi
  8004f0:	56                   	push   %esi
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 1c             	sub    $0x1c,%esp
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 d6                	mov    %edx,%esi
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800505:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800510:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800513:	39 d3                	cmp    %edx,%ebx
  800515:	72 05                	jb     80051c <printnum+0x30>
  800517:	39 45 10             	cmp    %eax,0x10(%ebp)
  80051a:	77 45                	ja     800561 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	ff 75 18             	pushl  0x18(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800528:	53                   	push   %ebx
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	ff 75 e0             	pushl  -0x20(%ebp)
  800535:	ff 75 dc             	pushl  -0x24(%ebp)
  800538:	ff 75 d8             	pushl  -0x28(%ebp)
  80053b:	e8 e0 1d 00 00       	call   802320 <__udivdi3>
  800540:	83 c4 18             	add    $0x18,%esp
  800543:	52                   	push   %edx
  800544:	50                   	push   %eax
  800545:	89 f2                	mov    %esi,%edx
  800547:	89 f8                	mov    %edi,%eax
  800549:	e8 9e ff ff ff       	call   8004ec <printnum>
  80054e:	83 c4 20             	add    $0x20,%esp
  800551:	eb 18                	jmp    80056b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	56                   	push   %esi
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff d7                	call   *%edi
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 03                	jmp    800564 <printnum+0x78>
  800561:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800564:	83 eb 01             	sub    $0x1,%ebx
  800567:	85 db                	test   %ebx,%ebx
  800569:	7f e8                	jg     800553 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	56                   	push   %esi
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	ff 75 e4             	pushl  -0x1c(%ebp)
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 75 dc             	pushl  -0x24(%ebp)
  80057b:	ff 75 d8             	pushl  -0x28(%ebp)
  80057e:	e8 cd 1e 00 00       	call   802450 <__umoddi3>
  800583:	83 c4 14             	add    $0x14,%esp
  800586:	0f be 80 2f 27 80 00 	movsbl 0x80272f(%eax),%eax
  80058d:	50                   	push   %eax
  80058e:	ff d7                	call   *%edi
}
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800596:	5b                   	pop    %ebx
  800597:	5e                   	pop    %esi
  800598:	5f                   	pop    %edi
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059e:	83 fa 01             	cmp    $0x1,%edx
  8005a1:	7e 0e                	jle    8005b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a8:	89 08                	mov    %ecx,(%eax)
  8005aa:	8b 02                	mov    (%edx),%eax
  8005ac:	8b 52 04             	mov    0x4(%edx),%edx
  8005af:	eb 22                	jmp    8005d3 <getuint+0x38>
	else if (lflag)
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 10                	je     8005c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ba:	89 08                	mov    %ecx,(%eax)
  8005bc:	8b 02                	mov    (%edx),%eax
  8005be:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c3:	eb 0e                	jmp    8005d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ca:	89 08                	mov    %ecx,(%eax)
  8005cc:	8b 02                	mov    (%edx),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e4:	73 0a                	jae    8005f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e9:	89 08                	mov    %ecx,(%eax)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	88 02                	mov    %al,(%edx)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	50                   	push   %eax
  8005fc:	ff 75 10             	pushl  0x10(%ebp)
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	e8 05 00 00 00       	call   80060f <vprintfmt>
	va_end(ap);
}
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	57                   	push   %edi
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 2c             	sub    $0x2c,%esp
  800618:	8b 75 08             	mov    0x8(%ebp),%esi
  80061b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800621:	eb 12                	jmp    800635 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 d3 03 00 00    	je     8009fe <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800635:	83 c7 01             	add    $0x1,%edi
  800638:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063c:	83 f8 25             	cmp    $0x25,%eax
  80063f:	75 e2                	jne    800623 <vprintfmt+0x14>
  800641:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800645:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80064c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800653:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
  80065f:	eb 07                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800664:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8d 47 01             	lea    0x1(%edi),%eax
  80066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066e:	0f b6 07             	movzbl (%edi),%eax
  800671:	0f b6 c8             	movzbl %al,%ecx
  800674:	83 e8 23             	sub    $0x23,%eax
  800677:	3c 55                	cmp    $0x55,%al
  800679:	0f 87 64 03 00 00    	ja     8009e3 <vprintfmt+0x3d4>
  80067f:	0f b6 c0             	movzbl %al,%eax
  800682:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80068c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800690:	eb d6                	jmp    800668 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	b8 00 00 00 00       	mov    $0x0,%eax
  80069a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80069d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006a0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006a4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006a7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006aa:	83 fa 09             	cmp    $0x9,%edx
  8006ad:	77 39                	ja     8006e8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006b2:	eb e9                	jmp    80069d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c5:	eb 27                	jmp    8006ee <vprintfmt+0xdf>
  8006c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d1:	0f 49 c8             	cmovns %eax,%ecx
  8006d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	eb 8c                	jmp    800668 <vprintfmt+0x59>
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e6:	eb 80                	jmp    800668 <vprintfmt+0x59>
  8006e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006eb:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8006ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f2:	0f 89 70 ff ff ff    	jns    800668 <vprintfmt+0x59>
				width = precision, precision = -1;
  8006f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fe:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800705:	e9 5e ff ff ff       	jmp    800668 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80070a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800710:	e9 53 ff ff ff       	jmp    800668 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 50 04             	lea    0x4(%eax),%edx
  80071b:	89 55 14             	mov    %edx,0x14(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	ff 30                	pushl  (%eax)
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
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80072c:	e9 04 ff ff ff       	jmp    800635 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	99                   	cltd   
  80073d:	31 d0                	xor    %edx,%eax
  80073f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800741:	83 f8 0f             	cmp    $0xf,%eax
  800744:	7f 0b                	jg     800751 <vprintfmt+0x142>
  800746:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	75 18                	jne    800769 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800751:	50                   	push   %eax
  800752:	68 47 27 80 00       	push   $0x802747
  800757:	53                   	push   %ebx
  800758:	56                   	push   %esi
  800759:	e8 94 fe ff ff       	call   8005f2 <printfmt>
  80075e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800764:	e9 cc fe ff ff       	jmp    800635 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800769:	52                   	push   %edx
  80076a:	68 11 2b 80 00       	push   $0x802b11
  80076f:	53                   	push   %ebx
  800770:	56                   	push   %esi
  800771:	e8 7c fe ff ff       	call   8005f2 <printfmt>
  800776:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077c:	e9 b4 fe ff ff       	jmp    800635 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 50 04             	lea    0x4(%eax),%edx
  800787:	89 55 14             	mov    %edx,0x14(%ebp)
  80078a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80078c:	85 ff                	test   %edi,%edi
  80078e:	b8 40 27 80 00       	mov    $0x802740,%eax
  800793:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800796:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079a:	0f 8e 94 00 00 00    	jle    800834 <vprintfmt+0x225>
  8007a0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8007a4:	0f 84 98 00 00 00    	je     800842 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	ff 75 c8             	pushl  -0x38(%ebp)
  8007b0:	57                   	push   %edi
  8007b1:	e8 d0 02 00 00       	call   800a86 <strnlen>
  8007b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007b9:	29 c1                	sub    %eax,%ecx
  8007bb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8007be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007cb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007cd:	eb 0f                	jmp    8007de <vprintfmt+0x1cf>
					putch(padc, putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d8:	83 ef 01             	sub    $0x1,%edi
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 ff                	test   %edi,%edi
  8007e0:	7f ed                	jg     8007cf <vprintfmt+0x1c0>
  8007e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	0f 49 c1             	cmovns %ecx,%eax
  8007f2:	29 c1                	sub    %eax,%ecx
  8007f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f7:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8007fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007fd:	89 cb                	mov    %ecx,%ebx
  8007ff:	eb 4d                	jmp    80084e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800801:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800805:	74 1b                	je     800822 <vprintfmt+0x213>
  800807:	0f be c0             	movsbl %al,%eax
  80080a:	83 e8 20             	sub    $0x20,%eax
  80080d:	83 f8 5e             	cmp    $0x5e,%eax
  800810:	76 10                	jbe    800822 <vprintfmt+0x213>
					putch('?', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	6a 3f                	push   $0x3f
  80081a:	ff 55 08             	call   *0x8(%ebp)
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb 0d                	jmp    80082f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	52                   	push   %edx
  800829:	ff 55 08             	call   *0x8(%ebp)
  80082c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082f:	83 eb 01             	sub    $0x1,%ebx
  800832:	eb 1a                	jmp    80084e <vprintfmt+0x23f>
  800834:	89 75 08             	mov    %esi,0x8(%ebp)
  800837:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80083a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80083d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800840:	eb 0c                	jmp    80084e <vprintfmt+0x23f>
  800842:	89 75 08             	mov    %esi,0x8(%ebp)
  800845:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800848:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084e:	83 c7 01             	add    $0x1,%edi
  800851:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800855:	0f be d0             	movsbl %al,%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 23                	je     80087f <vprintfmt+0x270>
  80085c:	85 f6                	test   %esi,%esi
  80085e:	78 a1                	js     800801 <vprintfmt+0x1f2>
  800860:	83 ee 01             	sub    $0x1,%esi
  800863:	79 9c                	jns    800801 <vprintfmt+0x1f2>
  800865:	89 df                	mov    %ebx,%edi
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	eb 18                	jmp    800887 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 20                	push   $0x20
  800875:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800877:	83 ef 01             	sub    $0x1,%edi
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	eb 08                	jmp    800887 <vprintfmt+0x278>
  80087f:	89 df                	mov    %ebx,%edi
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800887:	85 ff                	test   %edi,%edi
  800889:	7f e4                	jg     80086f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088e:	e9 a2 fd ff ff       	jmp    800635 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800893:	83 fa 01             	cmp    $0x1,%edx
  800896:	7e 16                	jle    8008ae <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 08             	lea    0x8(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 50 04             	mov    0x4(%eax),%edx
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8008a9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8008ac:	eb 32                	jmp    8008e0 <vprintfmt+0x2d1>
	else if (lflag)
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 18                	je     8008ca <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8008c0:	89 c1                	mov    %eax,%ecx
  8008c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008c8:	eb 16                	jmp    8008e0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8008d8:	89 c1                	mov    %eax,%ecx
  8008da:	c1 f9 1f             	sar    $0x1f,%ecx
  8008dd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8008e3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008ec:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008f1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8008f5:	0f 89 b0 00 00 00    	jns    8009ab <vprintfmt+0x39c>
				putch('-', putdat);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	53                   	push   %ebx
  8008ff:	6a 2d                	push   $0x2d
  800901:	ff d6                	call   *%esi
				num = -(long long) num;
  800903:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800906:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800909:	f7 d8                	neg    %eax
  80090b:	83 d2 00             	adc    $0x0,%edx
  80090e:	f7 da                	neg    %edx
  800910:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800913:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800916:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800919:	b8 0a 00 00 00       	mov    $0xa,%eax
  80091e:	e9 88 00 00 00       	jmp    8009ab <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
  800926:	e8 70 fc ff ff       	call   80059b <getuint>
  80092b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800931:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800936:	eb 73                	jmp    8009ab <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800938:	8d 45 14             	lea    0x14(%ebp),%eax
  80093b:	e8 5b fc ff ff       	call   80059b <getuint>
  800940:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800943:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800946:	83 ec 08             	sub    $0x8,%esp
  800949:	53                   	push   %ebx
  80094a:	6a 58                	push   $0x58
  80094c:	ff d6                	call   *%esi
			putch('X', putdat);
  80094e:	83 c4 08             	add    $0x8,%esp
  800951:	53                   	push   %ebx
  800952:	6a 58                	push   $0x58
  800954:	ff d6                	call   *%esi
			putch('X', putdat);
  800956:	83 c4 08             	add    $0x8,%esp
  800959:	53                   	push   %ebx
  80095a:	6a 58                	push   $0x58
  80095c:	ff d6                	call   *%esi
			goto number;
  80095e:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800961:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800966:	eb 43                	jmp    8009ab <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800968:	83 ec 08             	sub    $0x8,%esp
  80096b:	53                   	push   %ebx
  80096c:	6a 30                	push   $0x30
  80096e:	ff d6                	call   *%esi
			putch('x', putdat);
  800970:	83 c4 08             	add    $0x8,%esp
  800973:	53                   	push   %ebx
  800974:	6a 78                	push   $0x78
  800976:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8d 50 04             	lea    0x4(%eax),%edx
  80097e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800981:	8b 00                	mov    (%eax),%eax
  800983:	ba 00 00 00 00       	mov    $0x0,%edx
  800988:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098b:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80098e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800991:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800996:	eb 13                	jmp    8009ab <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800998:	8d 45 14             	lea    0x14(%ebp),%eax
  80099b:	e8 fb fb ff ff       	call   80059b <getuint>
  8009a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8009a6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009ab:	83 ec 0c             	sub    $0xc,%esp
  8009ae:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8009b2:	52                   	push   %edx
  8009b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8009b6:	50                   	push   %eax
  8009b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8009ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8009bd:	89 da                	mov    %ebx,%edx
  8009bf:	89 f0                	mov    %esi,%eax
  8009c1:	e8 26 fb ff ff       	call   8004ec <printnum>
			break;
  8009c6:	83 c4 20             	add    $0x20,%esp
  8009c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009cc:	e9 64 fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009d1:	83 ec 08             	sub    $0x8,%esp
  8009d4:	53                   	push   %ebx
  8009d5:	51                   	push   %ecx
  8009d6:	ff d6                	call   *%esi
			break;
  8009d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009de:	e9 52 fc ff ff       	jmp    800635 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009e3:	83 ec 08             	sub    $0x8,%esp
  8009e6:	53                   	push   %ebx
  8009e7:	6a 25                	push   $0x25
  8009e9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009eb:	83 c4 10             	add    $0x10,%esp
  8009ee:	eb 03                	jmp    8009f3 <vprintfmt+0x3e4>
  8009f0:	83 ef 01             	sub    $0x1,%edi
  8009f3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009f7:	75 f7                	jne    8009f0 <vprintfmt+0x3e1>
  8009f9:	e9 37 fc ff ff       	jmp    800635 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5f                   	pop    %edi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 18             	sub    $0x18,%esp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a15:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a19:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a23:	85 c0                	test   %eax,%eax
  800a25:	74 26                	je     800a4d <vsnprintf+0x47>
  800a27:	85 d2                	test   %edx,%edx
  800a29:	7e 22                	jle    800a4d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a2b:	ff 75 14             	pushl  0x14(%ebp)
  800a2e:	ff 75 10             	pushl  0x10(%ebp)
  800a31:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a34:	50                   	push   %eax
  800a35:	68 d5 05 80 00       	push   $0x8005d5
  800a3a:	e8 d0 fb ff ff       	call   80060f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a42:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a48:	83 c4 10             	add    $0x10,%esp
  800a4b:	eb 05                	jmp    800a52 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a5a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a5d:	50                   	push   %eax
  800a5e:	ff 75 10             	pushl  0x10(%ebp)
  800a61:	ff 75 0c             	pushl  0xc(%ebp)
  800a64:	ff 75 08             	pushl  0x8(%ebp)
  800a67:	e8 9a ff ff ff       	call   800a06 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	eb 03                	jmp    800a7e <strlen+0x10>
		n++;
  800a7b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a7e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a82:	75 f7                	jne    800a7b <strlen+0xd>
		n++;
	return n;
}
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a94:	eb 03                	jmp    800a99 <strnlen+0x13>
		n++;
  800a96:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a99:	39 c2                	cmp    %eax,%edx
  800a9b:	74 08                	je     800aa5 <strnlen+0x1f>
  800a9d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800aa1:	75 f3                	jne    800a96 <strnlen+0x10>
  800aa3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab1:	89 c2                	mov    %eax,%edx
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800abd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ac0:	84 db                	test   %bl,%bl
  800ac2:	75 ef                	jne    800ab3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ace:	53                   	push   %ebx
  800acf:	e8 9a ff ff ff       	call   800a6e <strlen>
  800ad4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ad7:	ff 75 0c             	pushl  0xc(%ebp)
  800ada:	01 d8                	add    %ebx,%eax
  800adc:	50                   	push   %eax
  800add:	e8 c5 ff ff ff       	call   800aa7 <strcpy>
	return dst;
}
  800ae2:	89 d8                	mov    %ebx,%eax
  800ae4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	8b 75 08             	mov    0x8(%ebp),%esi
  800af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af9:	89 f2                	mov    %esi,%edx
  800afb:	eb 0f                	jmp    800b0c <strncpy+0x23>
		*dst++ = *src;
  800afd:	83 c2 01             	add    $0x1,%edx
  800b00:	0f b6 01             	movzbl (%ecx),%eax
  800b03:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b06:	80 39 01             	cmpb   $0x1,(%ecx)
  800b09:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b0c:	39 da                	cmp    %ebx,%edx
  800b0e:	75 ed                	jne    800afd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b10:	89 f0                	mov    %esi,%eax
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b21:	8b 55 10             	mov    0x10(%ebp),%edx
  800b24:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b26:	85 d2                	test   %edx,%edx
  800b28:	74 21                	je     800b4b <strlcpy+0x35>
  800b2a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b2e:	89 f2                	mov    %esi,%edx
  800b30:	eb 09                	jmp    800b3b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b32:	83 c2 01             	add    $0x1,%edx
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b3b:	39 c2                	cmp    %eax,%edx
  800b3d:	74 09                	je     800b48 <strlcpy+0x32>
  800b3f:	0f b6 19             	movzbl (%ecx),%ebx
  800b42:	84 db                	test   %bl,%bl
  800b44:	75 ec                	jne    800b32 <strlcpy+0x1c>
  800b46:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b48:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b4b:	29 f0                	sub    %esi,%eax
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b57:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b5a:	eb 06                	jmp    800b62 <strcmp+0x11>
		p++, q++;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b62:	0f b6 01             	movzbl (%ecx),%eax
  800b65:	84 c0                	test   %al,%al
  800b67:	74 04                	je     800b6d <strcmp+0x1c>
  800b69:	3a 02                	cmp    (%edx),%al
  800b6b:	74 ef                	je     800b5c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6d:	0f b6 c0             	movzbl %al,%eax
  800b70:	0f b6 12             	movzbl (%edx),%edx
  800b73:	29 d0                	sub    %edx,%eax
}
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	53                   	push   %ebx
  800b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b81:	89 c3                	mov    %eax,%ebx
  800b83:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b86:	eb 06                	jmp    800b8e <strncmp+0x17>
		n--, p++, q++;
  800b88:	83 c0 01             	add    $0x1,%eax
  800b8b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b8e:	39 d8                	cmp    %ebx,%eax
  800b90:	74 15                	je     800ba7 <strncmp+0x30>
  800b92:	0f b6 08             	movzbl (%eax),%ecx
  800b95:	84 c9                	test   %cl,%cl
  800b97:	74 04                	je     800b9d <strncmp+0x26>
  800b99:	3a 0a                	cmp    (%edx),%cl
  800b9b:	74 eb                	je     800b88 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b9d:	0f b6 00             	movzbl (%eax),%eax
  800ba0:	0f b6 12             	movzbl (%edx),%edx
  800ba3:	29 d0                	sub    %edx,%eax
  800ba5:	eb 05                	jmp    800bac <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb9:	eb 07                	jmp    800bc2 <strchr+0x13>
		if (*s == c)
  800bbb:	38 ca                	cmp    %cl,%dl
  800bbd:	74 0f                	je     800bce <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bbf:	83 c0 01             	add    $0x1,%eax
  800bc2:	0f b6 10             	movzbl (%eax),%edx
  800bc5:	84 d2                	test   %dl,%dl
  800bc7:	75 f2                	jne    800bbb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bda:	eb 03                	jmp    800bdf <strfind+0xf>
  800bdc:	83 c0 01             	add    $0x1,%eax
  800bdf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be2:	38 ca                	cmp    %cl,%dl
  800be4:	74 04                	je     800bea <strfind+0x1a>
  800be6:	84 d2                	test   %dl,%dl
  800be8:	75 f2                	jne    800bdc <strfind+0xc>
			break;
	return (char *) s;
}
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf8:	85 c9                	test   %ecx,%ecx
  800bfa:	74 36                	je     800c32 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bfc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c02:	75 28                	jne    800c2c <memset+0x40>
  800c04:	f6 c1 03             	test   $0x3,%cl
  800c07:	75 23                	jne    800c2c <memset+0x40>
		c &= 0xFF;
  800c09:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	c1 e3 08             	shl    $0x8,%ebx
  800c12:	89 d6                	mov    %edx,%esi
  800c14:	c1 e6 18             	shl    $0x18,%esi
  800c17:	89 d0                	mov    %edx,%eax
  800c19:	c1 e0 10             	shl    $0x10,%eax
  800c1c:	09 f0                	or     %esi,%eax
  800c1e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c20:	89 d8                	mov    %ebx,%eax
  800c22:	09 d0                	or     %edx,%eax
  800c24:	c1 e9 02             	shr    $0x2,%ecx
  800c27:	fc                   	cld    
  800c28:	f3 ab                	rep stos %eax,%es:(%edi)
  800c2a:	eb 06                	jmp    800c32 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2f:	fc                   	cld    
  800c30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c32:	89 f8                	mov    %edi,%eax
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c47:	39 c6                	cmp    %eax,%esi
  800c49:	73 35                	jae    800c80 <memmove+0x47>
  800c4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4e:	39 d0                	cmp    %edx,%eax
  800c50:	73 2e                	jae    800c80 <memmove+0x47>
		s += n;
		d += n;
  800c52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c55:	89 d6                	mov    %edx,%esi
  800c57:	09 fe                	or     %edi,%esi
  800c59:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5f:	75 13                	jne    800c74 <memmove+0x3b>
  800c61:	f6 c1 03             	test   $0x3,%cl
  800c64:	75 0e                	jne    800c74 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c66:	83 ef 04             	sub    $0x4,%edi
  800c69:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c6c:	c1 e9 02             	shr    $0x2,%ecx
  800c6f:	fd                   	std    
  800c70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c72:	eb 09                	jmp    800c7d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c74:	83 ef 01             	sub    $0x1,%edi
  800c77:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c7a:	fd                   	std    
  800c7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7d:	fc                   	cld    
  800c7e:	eb 1d                	jmp    800c9d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c80:	89 f2                	mov    %esi,%edx
  800c82:	09 c2                	or     %eax,%edx
  800c84:	f6 c2 03             	test   $0x3,%dl
  800c87:	75 0f                	jne    800c98 <memmove+0x5f>
  800c89:	f6 c1 03             	test   $0x3,%cl
  800c8c:	75 0a                	jne    800c98 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c8e:	c1 e9 02             	shr    $0x2,%ecx
  800c91:	89 c7                	mov    %eax,%edi
  800c93:	fc                   	cld    
  800c94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c96:	eb 05                	jmp    800c9d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c98:	89 c7                	mov    %eax,%edi
  800c9a:	fc                   	cld    
  800c9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ca4:	ff 75 10             	pushl  0x10(%ebp)
  800ca7:	ff 75 0c             	pushl  0xc(%ebp)
  800caa:	ff 75 08             	pushl  0x8(%ebp)
  800cad:	e8 87 ff ff ff       	call   800c39 <memmove>
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbf:	89 c6                	mov    %eax,%esi
  800cc1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc4:	eb 1a                	jmp    800ce0 <memcmp+0x2c>
		if (*s1 != *s2)
  800cc6:	0f b6 08             	movzbl (%eax),%ecx
  800cc9:	0f b6 1a             	movzbl (%edx),%ebx
  800ccc:	38 d9                	cmp    %bl,%cl
  800cce:	74 0a                	je     800cda <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800cd0:	0f b6 c1             	movzbl %cl,%eax
  800cd3:	0f b6 db             	movzbl %bl,%ebx
  800cd6:	29 d8                	sub    %ebx,%eax
  800cd8:	eb 0f                	jmp    800ce9 <memcmp+0x35>
		s1++, s2++;
  800cda:	83 c0 01             	add    $0x1,%eax
  800cdd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce0:	39 f0                	cmp    %esi,%eax
  800ce2:	75 e2                	jne    800cc6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	53                   	push   %ebx
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cf4:	89 c1                	mov    %eax,%ecx
  800cf6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cfd:	eb 0a                	jmp    800d09 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cff:	0f b6 10             	movzbl (%eax),%edx
  800d02:	39 da                	cmp    %ebx,%edx
  800d04:	74 07                	je     800d0d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d06:	83 c0 01             	add    $0x1,%eax
  800d09:	39 c8                	cmp    %ecx,%eax
  800d0b:	72 f2                	jb     800cff <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1c:	eb 03                	jmp    800d21 <strtol+0x11>
		s++;
  800d1e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d21:	0f b6 01             	movzbl (%ecx),%eax
  800d24:	3c 20                	cmp    $0x20,%al
  800d26:	74 f6                	je     800d1e <strtol+0xe>
  800d28:	3c 09                	cmp    $0x9,%al
  800d2a:	74 f2                	je     800d1e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d2c:	3c 2b                	cmp    $0x2b,%al
  800d2e:	75 0a                	jne    800d3a <strtol+0x2a>
		s++;
  800d30:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d33:	bf 00 00 00 00       	mov    $0x0,%edi
  800d38:	eb 11                	jmp    800d4b <strtol+0x3b>
  800d3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d3f:	3c 2d                	cmp    $0x2d,%al
  800d41:	75 08                	jne    800d4b <strtol+0x3b>
		s++, neg = 1;
  800d43:	83 c1 01             	add    $0x1,%ecx
  800d46:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d51:	75 15                	jne    800d68 <strtol+0x58>
  800d53:	80 39 30             	cmpb   $0x30,(%ecx)
  800d56:	75 10                	jne    800d68 <strtol+0x58>
  800d58:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d5c:	75 7c                	jne    800dda <strtol+0xca>
		s += 2, base = 16;
  800d5e:	83 c1 02             	add    $0x2,%ecx
  800d61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d66:	eb 16                	jmp    800d7e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d68:	85 db                	test   %ebx,%ebx
  800d6a:	75 12                	jne    800d7e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d71:	80 39 30             	cmpb   $0x30,(%ecx)
  800d74:	75 08                	jne    800d7e <strtol+0x6e>
		s++, base = 8;
  800d76:	83 c1 01             	add    $0x1,%ecx
  800d79:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d83:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d86:	0f b6 11             	movzbl (%ecx),%edx
  800d89:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d8c:	89 f3                	mov    %esi,%ebx
  800d8e:	80 fb 09             	cmp    $0x9,%bl
  800d91:	77 08                	ja     800d9b <strtol+0x8b>
			dig = *s - '0';
  800d93:	0f be d2             	movsbl %dl,%edx
  800d96:	83 ea 30             	sub    $0x30,%edx
  800d99:	eb 22                	jmp    800dbd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d9b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d9e:	89 f3                	mov    %esi,%ebx
  800da0:	80 fb 19             	cmp    $0x19,%bl
  800da3:	77 08                	ja     800dad <strtol+0x9d>
			dig = *s - 'a' + 10;
  800da5:	0f be d2             	movsbl %dl,%edx
  800da8:	83 ea 57             	sub    $0x57,%edx
  800dab:	eb 10                	jmp    800dbd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800dad:	8d 72 bf             	lea    -0x41(%edx),%esi
  800db0:	89 f3                	mov    %esi,%ebx
  800db2:	80 fb 19             	cmp    $0x19,%bl
  800db5:	77 16                	ja     800dcd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800db7:	0f be d2             	movsbl %dl,%edx
  800dba:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800dbd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dc0:	7d 0b                	jge    800dcd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800dc2:	83 c1 01             	add    $0x1,%ecx
  800dc5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dc9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800dcb:	eb b9                	jmp    800d86 <strtol+0x76>

	if (endptr)
  800dcd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd1:	74 0d                	je     800de0 <strtol+0xd0>
		*endptr = (char *) s;
  800dd3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd6:	89 0e                	mov    %ecx,(%esi)
  800dd8:	eb 06                	jmp    800de0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dda:	85 db                	test   %ebx,%ebx
  800ddc:	74 98                	je     800d76 <strtol+0x66>
  800dde:	eb 9e                	jmp    800d7e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800de0:	89 c2                	mov    %eax,%edx
  800de2:	f7 da                	neg    %edx
  800de4:	85 ff                	test   %edi,%edi
  800de6:	0f 45 c2             	cmovne %edx,%eax
}
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800df4:	b8 00 00 00 00       	mov    $0x0,%eax
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 c3                	mov    %eax,%ebx
  800e01:	89 c7                	mov    %eax,%edi
  800e03:	89 c6                	mov    %eax,%esi
  800e05:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_cgetc>:

int
sys_cgetc(void)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e12:	ba 00 00 00 00       	mov    $0x0,%edx
  800e17:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1c:	89 d1                	mov    %edx,%ecx
  800e1e:	89 d3                	mov    %edx,%ebx
  800e20:	89 d7                	mov    %edx,%edi
  800e22:	89 d6                	mov    %edx,%esi
  800e24:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e39:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	89 cb                	mov    %ecx,%ebx
  800e43:	89 cf                	mov    %ecx,%edi
  800e45:	89 ce                	mov    %ecx,%esi
  800e47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 17                	jle    800e64 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	50                   	push   %eax
  800e51:	6a 03                	push   $0x3
  800e53:	68 3f 2a 80 00       	push   $0x802a3f
  800e58:	6a 23                	push   $0x23
  800e5a:	68 5c 2a 80 00       	push   $0x802a5c
  800e5f:	e8 9b f5 ff ff       	call   8003ff <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7c:	89 d1                	mov    %edx,%ecx
  800e7e:	89 d3                	mov    %edx,%ebx
  800e80:	89 d7                	mov    %edx,%edi
  800e82:	89 d6                	mov    %edx,%esi
  800e84:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_yield>:

void
sys_yield(void)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e91:	ba 00 00 00 00       	mov    $0x0,%edx
  800e96:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e9b:	89 d1                	mov    %edx,%ecx
  800e9d:	89 d3                	mov    %edx,%ebx
  800e9f:	89 d7                	mov    %edx,%edi
  800ea1:	89 d6                	mov    %edx,%esi
  800ea3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800eb3:	be 00 00 00 00       	mov    $0x0,%esi
  800eb8:	b8 04 00 00 00       	mov    $0x4,%eax
  800ebd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec6:	89 f7                	mov    %esi,%edi
  800ec8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	7e 17                	jle    800ee5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	50                   	push   %eax
  800ed2:	6a 04                	push   $0x4
  800ed4:	68 3f 2a 80 00       	push   $0x802a3f
  800ed9:	6a 23                	push   $0x23
  800edb:	68 5c 2a 80 00       	push   $0x802a5c
  800ee0:	e8 1a f5 ff ff       	call   8003ff <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ee5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ef6:	b8 05 00 00 00       	mov    $0x5,%eax
  800efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f07:	8b 75 18             	mov    0x18(%ebp),%esi
  800f0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 17                	jle    800f27 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 05                	push   $0x5
  800f16:	68 3f 2a 80 00       	push   $0x802a3f
  800f1b:	6a 23                	push   $0x23
  800f1d:	68 5c 2a 80 00       	push   $0x802a5c
  800f22:	e8 d8 f4 ff ff       	call   8003ff <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	89 df                	mov    %ebx,%edi
  800f4a:	89 de                	mov    %ebx,%esi
  800f4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	7e 17                	jle    800f69 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	50                   	push   %eax
  800f56:	6a 06                	push   $0x6
  800f58:	68 3f 2a 80 00       	push   $0x802a3f
  800f5d:	6a 23                	push   $0x23
  800f5f:	68 5c 2a 80 00       	push   $0x802a5c
  800f64:	e8 96 f4 ff ff       	call   8003ff <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7f:	b8 08 00 00 00       	mov    $0x8,%eax
  800f84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f87:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8a:	89 df                	mov    %ebx,%edi
  800f8c:	89 de                	mov    %ebx,%esi
  800f8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	7e 17                	jle    800fab <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	50                   	push   %eax
  800f98:	6a 08                	push   $0x8
  800f9a:	68 3f 2a 80 00       	push   $0x802a3f
  800f9f:	6a 23                	push   $0x23
  800fa1:	68 5c 2a 80 00       	push   $0x802a5c
  800fa6:	e8 54 f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    

00800fb3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	57                   	push   %edi
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc1:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcc:	89 df                	mov    %ebx,%edi
  800fce:	89 de                	mov    %ebx,%esi
  800fd0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	7e 17                	jle    800fed <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	50                   	push   %eax
  800fda:	6a 09                	push   $0x9
  800fdc:	68 3f 2a 80 00       	push   $0x802a3f
  800fe1:	6a 23                	push   $0x23
  800fe3:	68 5c 2a 80 00       	push   $0x802a5c
  800fe8:	e8 12 f4 ff ff       	call   8003ff <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801003:	b8 0a 00 00 00       	mov    $0xa,%eax
  801008:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100b:	8b 55 08             	mov    0x8(%ebp),%edx
  80100e:	89 df                	mov    %ebx,%edi
  801010:	89 de                	mov    %ebx,%esi
  801012:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801014:	85 c0                	test   %eax,%eax
  801016:	7e 17                	jle    80102f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	50                   	push   %eax
  80101c:	6a 0a                	push   $0xa
  80101e:	68 3f 2a 80 00       	push   $0x802a3f
  801023:	6a 23                	push   $0x23
  801025:	68 5c 2a 80 00       	push   $0x802a5c
  80102a:	e8 d0 f3 ff ff       	call   8003ff <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80102f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801032:	5b                   	pop    %ebx
  801033:	5e                   	pop    %esi
  801034:	5f                   	pop    %edi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80103d:	be 00 00 00 00       	mov    $0x0,%esi
  801042:	b8 0c 00 00 00       	mov    $0xc,%eax
  801047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104a:	8b 55 08             	mov    0x8(%ebp),%edx
  80104d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801050:	8b 7d 14             	mov    0x14(%ebp),%edi
  801053:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	57                   	push   %edi
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801063:	b9 00 00 00 00       	mov    $0x0,%ecx
  801068:	b8 0d 00 00 00       	mov    $0xd,%eax
  80106d:	8b 55 08             	mov    0x8(%ebp),%edx
  801070:	89 cb                	mov    %ecx,%ebx
  801072:	89 cf                	mov    %ecx,%edi
  801074:	89 ce                	mov    %ecx,%esi
  801076:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801078:	85 c0                	test   %eax,%eax
  80107a:	7e 17                	jle    801093 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	50                   	push   %eax
  801080:	6a 0d                	push   $0xd
  801082:	68 3f 2a 80 00       	push   $0x802a3f
  801087:	6a 23                	push   $0x23
  801089:	68 5c 2a 80 00       	push   $0x802a5c
  80108e:	e8 6c f3 ff ff       	call   8003ff <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801096:	5b                   	pop    %ebx
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a6:	c1 e8 0c             	shr    $0xc,%eax
}
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010bb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	c1 ea 16             	shr    $0x16,%edx
  8010d2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d9:	f6 c2 01             	test   $0x1,%dl
  8010dc:	74 11                	je     8010ef <fd_alloc+0x2d>
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	c1 ea 0c             	shr    $0xc,%edx
  8010e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ea:	f6 c2 01             	test   $0x1,%dl
  8010ed:	75 09                	jne    8010f8 <fd_alloc+0x36>
			*fd_store = fd;
  8010ef:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f6:	eb 17                	jmp    80110f <fd_alloc+0x4d>
  8010f8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801102:	75 c9                	jne    8010cd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801104:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80110a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801117:	83 f8 1f             	cmp    $0x1f,%eax
  80111a:	77 36                	ja     801152 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80111c:	c1 e0 0c             	shl    $0xc,%eax
  80111f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801124:	89 c2                	mov    %eax,%edx
  801126:	c1 ea 16             	shr    $0x16,%edx
  801129:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801130:	f6 c2 01             	test   $0x1,%dl
  801133:	74 24                	je     801159 <fd_lookup+0x48>
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 ea 0c             	shr    $0xc,%edx
  80113a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801141:	f6 c2 01             	test   $0x1,%dl
  801144:	74 1a                	je     801160 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801146:	8b 55 0c             	mov    0xc(%ebp),%edx
  801149:	89 02                	mov    %eax,(%edx)
	return 0;
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
  801150:	eb 13                	jmp    801165 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801152:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801157:	eb 0c                	jmp    801165 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801159:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115e:	eb 05                	jmp    801165 <fd_lookup+0x54>
  801160:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801170:	ba e8 2a 80 00       	mov    $0x802ae8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801175:	eb 13                	jmp    80118a <dev_lookup+0x23>
  801177:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80117a:	39 08                	cmp    %ecx,(%eax)
  80117c:	75 0c                	jne    80118a <dev_lookup+0x23>
			*dev = devtab[i];
  80117e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801181:	89 01                	mov    %eax,(%ecx)
			return 0;
  801183:	b8 00 00 00 00       	mov    $0x0,%eax
  801188:	eb 2e                	jmp    8011b8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80118a:	8b 02                	mov    (%edx),%eax
  80118c:	85 c0                	test   %eax,%eax
  80118e:	75 e7                	jne    801177 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801190:	a1 90 67 80 00       	mov    0x806790,%eax
  801195:	8b 40 48             	mov    0x48(%eax),%eax
  801198:	83 ec 04             	sub    $0x4,%esp
  80119b:	51                   	push   %ecx
  80119c:	50                   	push   %eax
  80119d:	68 6c 2a 80 00       	push   $0x802a6c
  8011a2:	e8 31 f3 ff ff       	call   8004d8 <cprintf>
	*dev = 0;
  8011a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 10             	sub    $0x10,%esp
  8011c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011d2:	c1 e8 0c             	shr    $0xc,%eax
  8011d5:	50                   	push   %eax
  8011d6:	e8 36 ff ff ff       	call   801111 <fd_lookup>
  8011db:	83 c4 08             	add    $0x8,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 05                	js     8011e7 <fd_close+0x2d>
	    || fd != fd2)
  8011e2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011e5:	74 0c                	je     8011f3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011e7:	84 db                	test   %bl,%bl
  8011e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ee:	0f 44 c2             	cmove  %edx,%eax
  8011f1:	eb 41                	jmp    801234 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	ff 36                	pushl  (%esi)
  8011fc:	e8 66 ff ff ff       	call   801167 <dev_lookup>
  801201:	89 c3                	mov    %eax,%ebx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	78 1a                	js     801224 <fd_close+0x6a>
		if (dev->dev_close)
  80120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801210:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801215:	85 c0                	test   %eax,%eax
  801217:	74 0b                	je     801224 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	56                   	push   %esi
  80121d:	ff d0                	call   *%eax
  80121f:	89 c3                	mov    %eax,%ebx
  801221:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	56                   	push   %esi
  801228:	6a 00                	push   $0x0
  80122a:	e8 00 fd ff ff       	call   800f2f <sys_page_unmap>
	return r;
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	89 d8                	mov    %ebx,%eax
}
  801234:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	ff 75 08             	pushl  0x8(%ebp)
  801248:	e8 c4 fe ff ff       	call   801111 <fd_lookup>
  80124d:	83 c4 08             	add    $0x8,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 10                	js     801264 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801254:	83 ec 08             	sub    $0x8,%esp
  801257:	6a 01                	push   $0x1
  801259:	ff 75 f4             	pushl  -0xc(%ebp)
  80125c:	e8 59 ff ff ff       	call   8011ba <fd_close>
  801261:	83 c4 10             	add    $0x10,%esp
}
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <close_all>:

void
close_all(void)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80126d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801272:	83 ec 0c             	sub    $0xc,%esp
  801275:	53                   	push   %ebx
  801276:	e8 c0 ff ff ff       	call   80123b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80127b:	83 c3 01             	add    $0x1,%ebx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	83 fb 20             	cmp    $0x20,%ebx
  801284:	75 ec                	jne    801272 <close_all+0xc>
		close(i);
}
  801286:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	57                   	push   %edi
  80128f:	56                   	push   %esi
  801290:	53                   	push   %ebx
  801291:	83 ec 2c             	sub    $0x2c,%esp
  801294:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801297:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	ff 75 08             	pushl  0x8(%ebp)
  80129e:	e8 6e fe ff ff       	call   801111 <fd_lookup>
  8012a3:	83 c4 08             	add    $0x8,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	0f 88 c1 00 00 00    	js     80136f <dup+0xe4>
		return r;
	close(newfdnum);
  8012ae:	83 ec 0c             	sub    $0xc,%esp
  8012b1:	56                   	push   %esi
  8012b2:	e8 84 ff ff ff       	call   80123b <close>

	newfd = INDEX2FD(newfdnum);
  8012b7:	89 f3                	mov    %esi,%ebx
  8012b9:	c1 e3 0c             	shl    $0xc,%ebx
  8012bc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012c2:	83 c4 04             	add    $0x4,%esp
  8012c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012c8:	e8 de fd ff ff       	call   8010ab <fd2data>
  8012cd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012cf:	89 1c 24             	mov    %ebx,(%esp)
  8012d2:	e8 d4 fd ff ff       	call   8010ab <fd2data>
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012dd:	89 f8                	mov    %edi,%eax
  8012df:	c1 e8 16             	shr    $0x16,%eax
  8012e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e9:	a8 01                	test   $0x1,%al
  8012eb:	74 37                	je     801324 <dup+0x99>
  8012ed:	89 f8                	mov    %edi,%eax
  8012ef:	c1 e8 0c             	shr    $0xc,%eax
  8012f2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f9:	f6 c2 01             	test   $0x1,%dl
  8012fc:	74 26                	je     801324 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	25 07 0e 00 00       	and    $0xe07,%eax
  80130d:	50                   	push   %eax
  80130e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801311:	6a 00                	push   $0x0
  801313:	57                   	push   %edi
  801314:	6a 00                	push   $0x0
  801316:	e8 d2 fb ff ff       	call   800eed <sys_page_map>
  80131b:	89 c7                	mov    %eax,%edi
  80131d:	83 c4 20             	add    $0x20,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 2e                	js     801352 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801324:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801327:	89 d0                	mov    %edx,%eax
  801329:	c1 e8 0c             	shr    $0xc,%eax
  80132c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	25 07 0e 00 00       	and    $0xe07,%eax
  80133b:	50                   	push   %eax
  80133c:	53                   	push   %ebx
  80133d:	6a 00                	push   $0x0
  80133f:	52                   	push   %edx
  801340:	6a 00                	push   $0x0
  801342:	e8 a6 fb ff ff       	call   800eed <sys_page_map>
  801347:	89 c7                	mov    %eax,%edi
  801349:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80134c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134e:	85 ff                	test   %edi,%edi
  801350:	79 1d                	jns    80136f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	53                   	push   %ebx
  801356:	6a 00                	push   $0x0
  801358:	e8 d2 fb ff ff       	call   800f2f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	ff 75 d4             	pushl  -0x2c(%ebp)
  801363:	6a 00                	push   $0x0
  801365:	e8 c5 fb ff ff       	call   800f2f <sys_page_unmap>
	return r;
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	89 f8                	mov    %edi,%eax
}
  80136f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801372:	5b                   	pop    %ebx
  801373:	5e                   	pop    %esi
  801374:	5f                   	pop    %edi
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 14             	sub    $0x14,%esp
  80137e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801381:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	53                   	push   %ebx
  801386:	e8 86 fd ff ff       	call   801111 <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	89 c2                	mov    %eax,%edx
  801390:	85 c0                	test   %eax,%eax
  801392:	78 6d                	js     801401 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139e:	ff 30                	pushl  (%eax)
  8013a0:	e8 c2 fd ff ff       	call   801167 <dev_lookup>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 4c                	js     8013f8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013af:	8b 42 08             	mov    0x8(%edx),%eax
  8013b2:	83 e0 03             	and    $0x3,%eax
  8013b5:	83 f8 01             	cmp    $0x1,%eax
  8013b8:	75 21                	jne    8013db <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ba:	a1 90 67 80 00       	mov    0x806790,%eax
  8013bf:	8b 40 48             	mov    0x48(%eax),%eax
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	53                   	push   %ebx
  8013c6:	50                   	push   %eax
  8013c7:	68 ad 2a 80 00       	push   $0x802aad
  8013cc:	e8 07 f1 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d9:	eb 26                	jmp    801401 <read+0x8a>
	}
	if (!dev->dev_read)
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	8b 40 08             	mov    0x8(%eax),%eax
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	74 17                	je     8013fc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013e5:	83 ec 04             	sub    $0x4,%esp
  8013e8:	ff 75 10             	pushl  0x10(%ebp)
  8013eb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ee:	52                   	push   %edx
  8013ef:	ff d0                	call   *%eax
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	eb 09                	jmp    801401 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f8:	89 c2                	mov    %eax,%edx
  8013fa:	eb 05                	jmp    801401 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801401:	89 d0                	mov    %edx,%eax
  801403:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	57                   	push   %edi
  80140c:	56                   	push   %esi
  80140d:	53                   	push   %ebx
  80140e:	83 ec 0c             	sub    $0xc,%esp
  801411:	8b 7d 08             	mov    0x8(%ebp),%edi
  801414:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801417:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141c:	eb 21                	jmp    80143f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80141e:	83 ec 04             	sub    $0x4,%esp
  801421:	89 f0                	mov    %esi,%eax
  801423:	29 d8                	sub    %ebx,%eax
  801425:	50                   	push   %eax
  801426:	89 d8                	mov    %ebx,%eax
  801428:	03 45 0c             	add    0xc(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	57                   	push   %edi
  80142d:	e8 45 ff ff ff       	call   801377 <read>
		if (m < 0)
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 10                	js     801449 <readn+0x41>
			return m;
		if (m == 0)
  801439:	85 c0                	test   %eax,%eax
  80143b:	74 0a                	je     801447 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80143d:	01 c3                	add    %eax,%ebx
  80143f:	39 f3                	cmp    %esi,%ebx
  801441:	72 db                	jb     80141e <readn+0x16>
  801443:	89 d8                	mov    %ebx,%eax
  801445:	eb 02                	jmp    801449 <readn+0x41>
  801447:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5f                   	pop    %edi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	53                   	push   %ebx
  801455:	83 ec 14             	sub    $0x14,%esp
  801458:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	53                   	push   %ebx
  801460:	e8 ac fc ff ff       	call   801111 <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	89 c2                	mov    %eax,%edx
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 68                	js     8014d6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801478:	ff 30                	pushl  (%eax)
  80147a:	e8 e8 fc ff ff       	call   801167 <dev_lookup>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 47                	js     8014cd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801486:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801489:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80148d:	75 21                	jne    8014b0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80148f:	a1 90 67 80 00       	mov    0x806790,%eax
  801494:	8b 40 48             	mov    0x48(%eax),%eax
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	53                   	push   %ebx
  80149b:	50                   	push   %eax
  80149c:	68 c9 2a 80 00       	push   $0x802ac9
  8014a1:	e8 32 f0 ff ff       	call   8004d8 <cprintf>
		return -E_INVAL;
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ae:	eb 26                	jmp    8014d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b6:	85 d2                	test   %edx,%edx
  8014b8:	74 17                	je     8014d1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	ff 75 10             	pushl  0x10(%ebp)
  8014c0:	ff 75 0c             	pushl  0xc(%ebp)
  8014c3:	50                   	push   %eax
  8014c4:	ff d2                	call   *%edx
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	eb 09                	jmp    8014d6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	eb 05                	jmp    8014d6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014d6:	89 d0                	mov    %edx,%eax
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <seek>:

int
seek(int fdnum, off_t offset)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	e8 22 fc ff ff       	call   801111 <fd_lookup>
  8014ef:	83 c4 08             	add    $0x8,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 0e                	js     801504 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 14             	sub    $0x14,%esp
  80150d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801510:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	53                   	push   %ebx
  801515:	e8 f7 fb ff ff       	call   801111 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 65                	js     801588 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152d:	ff 30                	pushl  (%eax)
  80152f:	e8 33 fc ff ff       	call   801167 <dev_lookup>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 44                	js     80157f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801542:	75 21                	jne    801565 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801544:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801549:	8b 40 48             	mov    0x48(%eax),%eax
  80154c:	83 ec 04             	sub    $0x4,%esp
  80154f:	53                   	push   %ebx
  801550:	50                   	push   %eax
  801551:	68 8c 2a 80 00       	push   $0x802a8c
  801556:	e8 7d ef ff ff       	call   8004d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801563:	eb 23                	jmp    801588 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801565:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801568:	8b 52 18             	mov    0x18(%edx),%edx
  80156b:	85 d2                	test   %edx,%edx
  80156d:	74 14                	je     801583 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	ff 75 0c             	pushl  0xc(%ebp)
  801575:	50                   	push   %eax
  801576:	ff d2                	call   *%edx
  801578:	89 c2                	mov    %eax,%edx
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	eb 09                	jmp    801588 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157f:	89 c2                	mov    %eax,%edx
  801581:	eb 05                	jmp    801588 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801583:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801588:	89 d0                	mov    %edx,%eax
  80158a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 14             	sub    $0x14,%esp
  801596:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801599:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 6c fb ff ff       	call   801111 <fd_lookup>
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 58                	js     801606 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b8:	ff 30                	pushl  (%eax)
  8015ba:	e8 a8 fb ff ff       	call   801167 <dev_lookup>
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 37                	js     8015fd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015cd:	74 32                	je     801601 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015d9:	00 00 00 
	stat->st_isdir = 0;
  8015dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e3:	00 00 00 
	stat->st_dev = dev;
  8015e6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f3:	ff 50 14             	call   *0x14(%eax)
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	eb 09                	jmp    801606 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	eb 05                	jmp    801606 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801601:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801606:	89 d0                	mov    %edx,%eax
  801608:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160b:	c9                   	leave  
  80160c:	c3                   	ret    

0080160d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	6a 00                	push   $0x0
  801617:	ff 75 08             	pushl  0x8(%ebp)
  80161a:	e8 dc 01 00 00       	call   8017fb <open>
  80161f:	89 c3                	mov    %eax,%ebx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	78 1b                	js     801643 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	50                   	push   %eax
  80162f:	e8 5b ff ff ff       	call   80158f <fstat>
  801634:	89 c6                	mov    %eax,%esi
	close(fd);
  801636:	89 1c 24             	mov    %ebx,(%esp)
  801639:	e8 fd fb ff ff       	call   80123b <close>
	return r;
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	89 f0                	mov    %esi,%eax
}
  801643:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	56                   	push   %esi
  80164e:	53                   	push   %ebx
  80164f:	89 c6                	mov    %eax,%esi
  801651:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801653:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80165a:	75 12                	jne    80166e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80165c:	83 ec 0c             	sub    $0xc,%esp
  80165f:	6a 01                	push   $0x1
  801661:	e8 38 0c 00 00       	call   80229e <ipc_find_env>
  801666:	a3 00 50 80 00       	mov    %eax,0x805000
  80166b:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80166e:	6a 07                	push   $0x7
  801670:	68 00 70 80 00       	push   $0x807000
  801675:	56                   	push   %esi
  801676:	ff 35 00 50 80 00    	pushl  0x805000
  80167c:	e8 da 0b 00 00       	call   80225b <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801681:	83 c4 0c             	add    $0xc,%esp
  801684:	6a 00                	push   $0x0
  801686:	53                   	push   %ebx
  801687:	6a 00                	push   $0x0
  801689:	e8 70 0b 00 00       	call   8021fe <ipc_recv>
}
  80168e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801691:	5b                   	pop    %ebx
  801692:	5e                   	pop    %esi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a1:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8016a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a9:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b8:	e8 8d ff ff ff       	call   80164a <fsipc>
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cb:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016da:	e8 6b ff ff ff       	call   80164a <fsipc>
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 04             	sub    $0x4,%esp
  8016e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f1:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fb:	b8 05 00 00 00       	mov    $0x5,%eax
  801700:	e8 45 ff ff ff       	call   80164a <fsipc>
  801705:	85 c0                	test   %eax,%eax
  801707:	78 2c                	js     801735 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	68 00 70 80 00       	push   $0x807000
  801711:	53                   	push   %ebx
  801712:	e8 90 f3 ff ff       	call   800aa7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801717:	a1 80 70 80 00       	mov    0x807080,%eax
  80171c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801722:	a1 84 70 80 00       	mov    0x807084,%eax
  801727:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801743:	8b 55 08             	mov    0x8(%ebp),%edx
  801746:	8b 52 0c             	mov    0xc(%edx),%edx
  801749:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  80174f:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801754:	50                   	push   %eax
  801755:	ff 75 0c             	pushl  0xc(%ebp)
  801758:	68 08 70 80 00       	push   $0x807008
  80175d:	e8 d7 f4 ff ff       	call   800c39 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801762:	ba 00 00 00 00       	mov    $0x0,%edx
  801767:	b8 04 00 00 00       	mov    $0x4,%eax
  80176c:	e8 d9 fe ff ff       	call   80164a <fsipc>
	//panic("devfile_write not implemented");
}
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	56                   	push   %esi
  801777:	53                   	push   %ebx
  801778:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
  80177e:	8b 40 0c             	mov    0xc(%eax),%eax
  801781:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801786:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178c:	ba 00 00 00 00       	mov    $0x0,%edx
  801791:	b8 03 00 00 00       	mov    $0x3,%eax
  801796:	e8 af fe ff ff       	call   80164a <fsipc>
  80179b:	89 c3                	mov    %eax,%ebx
  80179d:	85 c0                	test   %eax,%eax
  80179f:	78 51                	js     8017f2 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8017a1:	39 c6                	cmp    %eax,%esi
  8017a3:	73 19                	jae    8017be <devfile_read+0x4b>
  8017a5:	68 f8 2a 80 00       	push   $0x802af8
  8017aa:	68 ff 2a 80 00       	push   $0x802aff
  8017af:	68 80 00 00 00       	push   $0x80
  8017b4:	68 14 2b 80 00       	push   $0x802b14
  8017b9:	e8 41 ec ff ff       	call   8003ff <_panic>
	assert(r <= PGSIZE);
  8017be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c3:	7e 19                	jle    8017de <devfile_read+0x6b>
  8017c5:	68 1f 2b 80 00       	push   $0x802b1f
  8017ca:	68 ff 2a 80 00       	push   $0x802aff
  8017cf:	68 81 00 00 00       	push   $0x81
  8017d4:	68 14 2b 80 00       	push   $0x802b14
  8017d9:	e8 21 ec ff ff       	call   8003ff <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017de:	83 ec 04             	sub    $0x4,%esp
  8017e1:	50                   	push   %eax
  8017e2:	68 00 70 80 00       	push   $0x807000
  8017e7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ea:	e8 4a f4 ff ff       	call   800c39 <memmove>
	return r;
  8017ef:	83 c4 10             	add    $0x10,%esp
}
  8017f2:	89 d8                	mov    %ebx,%eax
  8017f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f7:	5b                   	pop    %ebx
  8017f8:	5e                   	pop    %esi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 20             	sub    $0x20,%esp
  801802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801805:	53                   	push   %ebx
  801806:	e8 63 f2 ff ff       	call   800a6e <strlen>
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801813:	7f 67                	jg     80187c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181b:	50                   	push   %eax
  80181c:	e8 a1 f8 ff ff       	call   8010c2 <fd_alloc>
  801821:	83 c4 10             	add    $0x10,%esp
		return r;
  801824:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801826:	85 c0                	test   %eax,%eax
  801828:	78 57                	js     801881 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80182a:	83 ec 08             	sub    $0x8,%esp
  80182d:	53                   	push   %ebx
  80182e:	68 00 70 80 00       	push   $0x807000
  801833:	e8 6f f2 ff ff       	call   800aa7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801838:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183b:	a3 00 74 80 00       	mov    %eax,0x807400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801840:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801843:	b8 01 00 00 00       	mov    $0x1,%eax
  801848:	e8 fd fd ff ff       	call   80164a <fsipc>
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	85 c0                	test   %eax,%eax
  801854:	79 14                	jns    80186a <open+0x6f>
		
		fd_close(fd, 0);
  801856:	83 ec 08             	sub    $0x8,%esp
  801859:	6a 00                	push   $0x0
  80185b:	ff 75 f4             	pushl  -0xc(%ebp)
  80185e:	e8 57 f9 ff ff       	call   8011ba <fd_close>
		return r;
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	89 da                	mov    %ebx,%edx
  801868:	eb 17                	jmp    801881 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  80186a:	83 ec 0c             	sub    $0xc,%esp
  80186d:	ff 75 f4             	pushl  -0xc(%ebp)
  801870:	e8 26 f8 ff ff       	call   80109b <fd2num>
  801875:	89 c2                	mov    %eax,%edx
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	eb 05                	jmp    801881 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80187c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801881:	89 d0                	mov    %edx,%eax
  801883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
  801893:	b8 08 00 00 00       	mov    $0x8,%eax
  801898:	e8 ad fd ff ff       	call   80164a <fsipc>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	57                   	push   %edi
  8018a3:	56                   	push   %esi
  8018a4:	53                   	push   %ebx
  8018a5:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018ab:	6a 00                	push   $0x0
  8018ad:	ff 75 08             	pushl  0x8(%ebp)
  8018b0:	e8 46 ff ff ff       	call   8017fb <open>
  8018b5:	89 c7                	mov    %eax,%edi
  8018b7:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	0f 88 ae 04 00 00    	js     801d76 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018c8:	83 ec 04             	sub    $0x4,%esp
  8018cb:	68 00 02 00 00       	push   $0x200
  8018d0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018d6:	50                   	push   %eax
  8018d7:	57                   	push   %edi
  8018d8:	e8 2b fb ff ff       	call   801408 <readn>
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018e5:	75 0c                	jne    8018f3 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018e7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018ee:	45 4c 46 
  8018f1:	74 33                	je     801926 <spawn+0x87>
		close(fd);
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018fc:	e8 3a f9 ff ff       	call   80123b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801901:	83 c4 0c             	add    $0xc,%esp
  801904:	68 7f 45 4c 46       	push   $0x464c457f
  801909:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80190f:	68 2b 2b 80 00       	push   $0x802b2b
  801914:	e8 bf eb ff ff       	call   8004d8 <cprintf>
		return -E_NOT_EXEC;
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801921:	e9 b0 04 00 00       	jmp    801dd6 <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801926:	b8 07 00 00 00       	mov    $0x7,%eax
  80192b:	cd 30                	int    $0x30
  80192d:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801933:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801939:	85 c0                	test   %eax,%eax
  80193b:	0f 88 3d 04 00 00    	js     801d7e <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801941:	89 c6                	mov    %eax,%esi
  801943:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801949:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80194c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801952:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801958:	b9 11 00 00 00       	mov    $0x11,%ecx
  80195d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80195f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801965:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80196b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801970:	be 00 00 00 00       	mov    $0x0,%esi
  801975:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801978:	eb 13                	jmp    80198d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80197a:	83 ec 0c             	sub    $0xc,%esp
  80197d:	50                   	push   %eax
  80197e:	e8 eb f0 ff ff       	call   800a6e <strlen>
  801983:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801987:	83 c3 01             	add    $0x1,%ebx
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801994:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801997:	85 c0                	test   %eax,%eax
  801999:	75 df                	jne    80197a <spawn+0xdb>
  80199b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019a1:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8019a7:	bf 00 10 40 00       	mov    $0x401000,%edi
  8019ac:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8019ae:	89 fa                	mov    %edi,%edx
  8019b0:	83 e2 fc             	and    $0xfffffffc,%edx
  8019b3:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019ba:	29 c2                	sub    %eax,%edx
  8019bc:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019c2:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019c5:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019ca:	0f 86 be 03 00 00    	jbe    801d8e <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	6a 07                	push   $0x7
  8019d5:	68 00 00 40 00       	push   $0x400000
  8019da:	6a 00                	push   $0x0
  8019dc:	e8 c9 f4 ff ff       	call   800eaa <sys_page_alloc>
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	0f 88 a9 03 00 00    	js     801d95 <spawn+0x4f6>
  8019ec:	be 00 00 00 00       	mov    $0x0,%esi
  8019f1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019fa:	eb 30                	jmp    801a2c <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8019fc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a02:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a08:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a0b:	83 ec 08             	sub    $0x8,%esp
  801a0e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a11:	57                   	push   %edi
  801a12:	e8 90 f0 ff ff       	call   800aa7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a17:	83 c4 04             	add    $0x4,%esp
  801a1a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a1d:	e8 4c f0 ff ff       	call   800a6e <strlen>
  801a22:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a26:	83 c6 01             	add    $0x1,%esi
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a32:	7f c8                	jg     8019fc <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a34:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a3a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a40:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a47:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a4d:	74 19                	je     801a68 <spawn+0x1c9>
  801a4f:	68 a0 2b 80 00       	push   $0x802ba0
  801a54:	68 ff 2a 80 00       	push   $0x802aff
  801a59:	68 f2 00 00 00       	push   $0xf2
  801a5e:	68 45 2b 80 00       	push   $0x802b45
  801a63:	e8 97 e9 ff ff       	call   8003ff <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a68:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a6e:	89 f8                	mov    %edi,%eax
  801a70:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801a75:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a78:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a7e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a81:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801a87:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	6a 07                	push   $0x7
  801a92:	68 00 d0 bf ee       	push   $0xeebfd000
  801a97:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a9d:	68 00 00 40 00       	push   $0x400000
  801aa2:	6a 00                	push   $0x0
  801aa4:	e8 44 f4 ff ff       	call   800eed <sys_page_map>
  801aa9:	89 c3                	mov    %eax,%ebx
  801aab:	83 c4 20             	add    $0x20,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	0f 88 0e 03 00 00    	js     801dc4 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801ab6:	83 ec 08             	sub    $0x8,%esp
  801ab9:	68 00 00 40 00       	push   $0x400000
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 6a f4 ff ff       	call   800f2f <sys_page_unmap>
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	0f 88 f2 02 00 00    	js     801dc4 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ad2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ad8:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801adf:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ae5:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801aec:	00 00 00 
  801aef:	e9 88 01 00 00       	jmp    801c7c <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801af4:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801afa:	83 38 01             	cmpl   $0x1,(%eax)
  801afd:	0f 85 6b 01 00 00    	jne    801c6e <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b03:	89 c7                	mov    %eax,%edi
  801b05:	8b 40 18             	mov    0x18(%eax),%eax
  801b08:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b0e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b11:	83 f8 01             	cmp    $0x1,%eax
  801b14:	19 c0                	sbb    %eax,%eax
  801b16:	83 e0 fe             	and    $0xfffffffe,%eax
  801b19:	83 c0 07             	add    $0x7,%eax
  801b1c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b22:	89 f8                	mov    %edi,%eax
  801b24:	8b 7f 04             	mov    0x4(%edi),%edi
  801b27:	89 f9                	mov    %edi,%ecx
  801b29:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b2f:	8b 78 10             	mov    0x10(%eax),%edi
  801b32:	8b 50 14             	mov    0x14(%eax),%edx
  801b35:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801b3b:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b3e:	89 f0                	mov    %esi,%eax
  801b40:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b45:	74 14                	je     801b5b <spawn+0x2bc>
		va -= i;
  801b47:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b49:	01 c2                	add    %eax,%edx
  801b4b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801b51:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b53:	29 c1                	sub    %eax,%ecx
  801b55:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b60:	e9 f7 00 00 00       	jmp    801c5c <spawn+0x3bd>
		if (i >= filesz) {
  801b65:	39 df                	cmp    %ebx,%edi
  801b67:	77 27                	ja     801b90 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b69:	83 ec 04             	sub    $0x4,%esp
  801b6c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b72:	56                   	push   %esi
  801b73:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b79:	e8 2c f3 ff ff       	call   800eaa <sys_page_alloc>
  801b7e:	83 c4 10             	add    $0x10,%esp
  801b81:	85 c0                	test   %eax,%eax
  801b83:	0f 89 c7 00 00 00    	jns    801c50 <spawn+0x3b1>
  801b89:	89 c3                	mov    %eax,%ebx
  801b8b:	e9 13 02 00 00       	jmp    801da3 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b90:	83 ec 04             	sub    $0x4,%esp
  801b93:	6a 07                	push   $0x7
  801b95:	68 00 00 40 00       	push   $0x400000
  801b9a:	6a 00                	push   $0x0
  801b9c:	e8 09 f3 ff ff       	call   800eaa <sys_page_alloc>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	0f 88 ed 01 00 00    	js     801d99 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bac:	83 ec 08             	sub    $0x8,%esp
  801baf:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bb5:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801bbb:	50                   	push   %eax
  801bbc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bc2:	e8 16 f9 ff ff       	call   8014dd <seek>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	0f 88 cb 01 00 00    	js     801d9d <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bd2:	83 ec 04             	sub    $0x4,%esp
  801bd5:	89 f8                	mov    %edi,%eax
  801bd7:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801bdd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be2:	ba 00 10 00 00       	mov    $0x1000,%edx
  801be7:	0f 47 c2             	cmova  %edx,%eax
  801bea:	50                   	push   %eax
  801beb:	68 00 00 40 00       	push   $0x400000
  801bf0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bf6:	e8 0d f8 ff ff       	call   801408 <readn>
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	0f 88 9b 01 00 00    	js     801da1 <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c06:	83 ec 0c             	sub    $0xc,%esp
  801c09:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c0f:	56                   	push   %esi
  801c10:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c16:	68 00 00 40 00       	push   $0x400000
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 cb f2 ff ff       	call   800eed <sys_page_map>
  801c22:	83 c4 20             	add    $0x20,%esp
  801c25:	85 c0                	test   %eax,%eax
  801c27:	79 15                	jns    801c3e <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c29:	50                   	push   %eax
  801c2a:	68 51 2b 80 00       	push   $0x802b51
  801c2f:	68 25 01 00 00       	push   $0x125
  801c34:	68 45 2b 80 00       	push   $0x802b45
  801c39:	e8 c1 e7 ff ff       	call   8003ff <_panic>
			sys_page_unmap(0, UTEMP);
  801c3e:	83 ec 08             	sub    $0x8,%esp
  801c41:	68 00 00 40 00       	push   $0x400000
  801c46:	6a 00                	push   $0x0
  801c48:	e8 e2 f2 ff ff       	call   800f2f <sys_page_unmap>
  801c4d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c50:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c56:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c5c:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c62:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801c68:	0f 87 f7 fe ff ff    	ja     801b65 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c6e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c75:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c7c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c83:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c89:	0f 8c 65 fe ff ff    	jl     801af4 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c98:	e8 9e f5 ff ff       	call   80123b <close>
  801c9d:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca5:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801cab:	89 d8                	mov    %ebx,%eax
  801cad:	c1 e8 16             	shr    $0x16,%eax
  801cb0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cb7:	a8 01                	test   $0x1,%al
  801cb9:	74 46                	je     801d01 <spawn+0x462>
  801cbb:	89 d8                	mov    %ebx,%eax
  801cbd:	c1 e8 0c             	shr    $0xc,%eax
  801cc0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cc7:	f6 c2 01             	test   $0x1,%dl
  801cca:	74 35                	je     801d01 <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801ccc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801cd3:	f6 c2 04             	test   $0x4,%dl
  801cd6:	74 29                	je     801d01 <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801cd8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801cdf:	f6 c6 04             	test   $0x4,%dh
  801ce2:	74 1d                	je     801d01 <spawn+0x462>
            sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801ce4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	25 07 0e 00 00       	and    $0xe07,%eax
  801cf3:	50                   	push   %eax
  801cf4:	53                   	push   %ebx
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
  801cf7:	6a 00                	push   $0x0
  801cf9:	e8 ef f1 ff ff       	call   800eed <sys_page_map>
  801cfe:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801d01:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d07:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801d0d:	75 9c                	jne    801cab <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801d0f:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801d16:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d19:	83 ec 08             	sub    $0x8,%esp
  801d1c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d22:	50                   	push   %eax
  801d23:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d29:	e8 85 f2 ff ff       	call   800fb3 <sys_env_set_trapframe>
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	79 15                	jns    801d4a <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801d35:	50                   	push   %eax
  801d36:	68 6e 2b 80 00       	push   $0x802b6e
  801d3b:	68 86 00 00 00       	push   $0x86
  801d40:	68 45 2b 80 00       	push   $0x802b45
  801d45:	e8 b5 e6 ff ff       	call   8003ff <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d4a:	83 ec 08             	sub    $0x8,%esp
  801d4d:	6a 02                	push   $0x2
  801d4f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d55:	e8 17 f2 ff ff       	call   800f71 <sys_env_set_status>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	79 25                	jns    801d86 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801d61:	50                   	push   %eax
  801d62:	68 88 2b 80 00       	push   $0x802b88
  801d67:	68 89 00 00 00       	push   $0x89
  801d6c:	68 45 2b 80 00       	push   $0x802b45
  801d71:	e8 89 e6 ff ff       	call   8003ff <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d76:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d7c:	eb 58                	jmp    801dd6 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d7e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d84:	eb 50                	jmp    801dd6 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d86:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d8c:	eb 48                	jmp    801dd6 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d8e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d93:	eb 41                	jmp    801dd6 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d95:	89 c3                	mov    %eax,%ebx
  801d97:	eb 3d                	jmp    801dd6 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	eb 06                	jmp    801da3 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	eb 02                	jmp    801da3 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801da1:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801da3:	83 ec 0c             	sub    $0xc,%esp
  801da6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dac:	e8 7a f0 ff ff       	call   800e2b <sys_env_destroy>
	close(fd);
  801db1:	83 c4 04             	add    $0x4,%esp
  801db4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dba:	e8 7c f4 ff ff       	call   80123b <close>
	return r;
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	eb 12                	jmp    801dd6 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	68 00 00 40 00       	push   $0x400000
  801dcc:	6a 00                	push   $0x0
  801dce:	e8 5c f1 ff ff       	call   800f2f <sys_page_unmap>
  801dd3:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801dd6:	89 d8                	mov    %ebx,%eax
  801dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801de5:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801de8:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ded:	eb 03                	jmp    801df2 <spawnl+0x12>
		argc++;
  801def:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801df2:	83 c2 04             	add    $0x4,%edx
  801df5:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801df9:	75 f4                	jne    801def <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dfb:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e02:	83 e2 f0             	and    $0xfffffff0,%edx
  801e05:	29 d4                	sub    %edx,%esp
  801e07:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e0b:	c1 ea 02             	shr    $0x2,%edx
  801e0e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e15:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e21:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e28:	00 
  801e29:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e30:	eb 0a                	jmp    801e3c <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e32:	83 c0 01             	add    $0x1,%eax
  801e35:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e39:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e3c:	39 d0                	cmp    %edx,%eax
  801e3e:	75 f2                	jne    801e32 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e40:	83 ec 08             	sub    $0x8,%esp
  801e43:	56                   	push   %esi
  801e44:	ff 75 08             	pushl  0x8(%ebp)
  801e47:	e8 53 fa ff ff       	call   80189f <spawn>
}
  801e4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e5b:	83 ec 0c             	sub    $0xc,%esp
  801e5e:	ff 75 08             	pushl  0x8(%ebp)
  801e61:	e8 45 f2 ff ff       	call   8010ab <fd2data>
  801e66:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e68:	83 c4 08             	add    $0x8,%esp
  801e6b:	68 c8 2b 80 00       	push   $0x802bc8
  801e70:	53                   	push   %ebx
  801e71:	e8 31 ec ff ff       	call   800aa7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e76:	8b 46 04             	mov    0x4(%esi),%eax
  801e79:	2b 06                	sub    (%esi),%eax
  801e7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e88:	00 00 00 
	stat->st_dev = &devpipe;
  801e8b:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801e92:	47 80 00 
	return 0;
}
  801e95:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	53                   	push   %ebx
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eab:	53                   	push   %ebx
  801eac:	6a 00                	push   $0x0
  801eae:	e8 7c f0 ff ff       	call   800f2f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eb3:	89 1c 24             	mov    %ebx,(%esp)
  801eb6:	e8 f0 f1 ff ff       	call   8010ab <fd2data>
  801ebb:	83 c4 08             	add    $0x8,%esp
  801ebe:	50                   	push   %eax
  801ebf:	6a 00                	push   $0x0
  801ec1:	e8 69 f0 ff ff       	call   800f2f <sys_page_unmap>
}
  801ec6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	57                   	push   %edi
  801ecf:	56                   	push   %esi
  801ed0:	53                   	push   %ebx
  801ed1:	83 ec 1c             	sub    $0x1c,%esp
  801ed4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ed7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ed9:	a1 90 67 80 00       	mov    0x806790,%eax
  801ede:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ee1:	83 ec 0c             	sub    $0xc,%esp
  801ee4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ee7:	e8 eb 03 00 00       	call   8022d7 <pageref>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	89 3c 24             	mov    %edi,(%esp)
  801ef1:	e8 e1 03 00 00       	call   8022d7 <pageref>
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	39 c3                	cmp    %eax,%ebx
  801efb:	0f 94 c1             	sete   %cl
  801efe:	0f b6 c9             	movzbl %cl,%ecx
  801f01:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f04:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f0a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f0d:	39 ce                	cmp    %ecx,%esi
  801f0f:	74 1b                	je     801f2c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f11:	39 c3                	cmp    %eax,%ebx
  801f13:	75 c4                	jne    801ed9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f15:	8b 42 58             	mov    0x58(%edx),%eax
  801f18:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f1b:	50                   	push   %eax
  801f1c:	56                   	push   %esi
  801f1d:	68 cf 2b 80 00       	push   $0x802bcf
  801f22:	e8 b1 e5 ff ff       	call   8004d8 <cprintf>
  801f27:	83 c4 10             	add    $0x10,%esp
  801f2a:	eb ad                	jmp    801ed9 <_pipeisclosed+0xe>
	}
}
  801f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	57                   	push   %edi
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	83 ec 28             	sub    $0x28,%esp
  801f40:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f43:	56                   	push   %esi
  801f44:	e8 62 f1 ff ff       	call   8010ab <fd2data>
  801f49:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	bf 00 00 00 00       	mov    $0x0,%edi
  801f53:	eb 4b                	jmp    801fa0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f55:	89 da                	mov    %ebx,%edx
  801f57:	89 f0                	mov    %esi,%eax
  801f59:	e8 6d ff ff ff       	call   801ecb <_pipeisclosed>
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	75 48                	jne    801faa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f62:	e8 24 ef ff ff       	call   800e8b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f67:	8b 43 04             	mov    0x4(%ebx),%eax
  801f6a:	8b 0b                	mov    (%ebx),%ecx
  801f6c:	8d 51 20             	lea    0x20(%ecx),%edx
  801f6f:	39 d0                	cmp    %edx,%eax
  801f71:	73 e2                	jae    801f55 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f76:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f7a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f7d:	89 c2                	mov    %eax,%edx
  801f7f:	c1 fa 1f             	sar    $0x1f,%edx
  801f82:	89 d1                	mov    %edx,%ecx
  801f84:	c1 e9 1b             	shr    $0x1b,%ecx
  801f87:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f8a:	83 e2 1f             	and    $0x1f,%edx
  801f8d:	29 ca                	sub    %ecx,%edx
  801f8f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f93:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f97:	83 c0 01             	add    $0x1,%eax
  801f9a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f9d:	83 c7 01             	add    $0x1,%edi
  801fa0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fa3:	75 c2                	jne    801f67 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fa5:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa8:	eb 05                	jmp    801faf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801faa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb2:	5b                   	pop    %ebx
  801fb3:	5e                   	pop    %esi
  801fb4:	5f                   	pop    %edi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	57                   	push   %edi
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
  801fbd:	83 ec 18             	sub    $0x18,%esp
  801fc0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fc3:	57                   	push   %edi
  801fc4:	e8 e2 f0 ff ff       	call   8010ab <fd2data>
  801fc9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fcb:	83 c4 10             	add    $0x10,%esp
  801fce:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fd3:	eb 3d                	jmp    802012 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fd5:	85 db                	test   %ebx,%ebx
  801fd7:	74 04                	je     801fdd <devpipe_read+0x26>
				return i;
  801fd9:	89 d8                	mov    %ebx,%eax
  801fdb:	eb 44                	jmp    802021 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fdd:	89 f2                	mov    %esi,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	e8 e5 fe ff ff       	call   801ecb <_pipeisclosed>
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	75 32                	jne    80201c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fea:	e8 9c ee ff ff       	call   800e8b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fef:	8b 06                	mov    (%esi),%eax
  801ff1:	3b 46 04             	cmp    0x4(%esi),%eax
  801ff4:	74 df                	je     801fd5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ff6:	99                   	cltd   
  801ff7:	c1 ea 1b             	shr    $0x1b,%edx
  801ffa:	01 d0                	add    %edx,%eax
  801ffc:	83 e0 1f             	and    $0x1f,%eax
  801fff:	29 d0                	sub    %edx,%eax
  802001:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802006:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802009:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80200c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80200f:	83 c3 01             	add    $0x1,%ebx
  802012:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802015:	75 d8                	jne    801fef <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802017:	8b 45 10             	mov    0x10(%ebp),%eax
  80201a:	eb 05                	jmp    802021 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80201c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802021:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	56                   	push   %esi
  80202d:	53                   	push   %ebx
  80202e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802034:	50                   	push   %eax
  802035:	e8 88 f0 ff ff       	call   8010c2 <fd_alloc>
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	89 c2                	mov    %eax,%edx
  80203f:	85 c0                	test   %eax,%eax
  802041:	0f 88 2c 01 00 00    	js     802173 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802047:	83 ec 04             	sub    $0x4,%esp
  80204a:	68 07 04 00 00       	push   $0x407
  80204f:	ff 75 f4             	pushl  -0xc(%ebp)
  802052:	6a 00                	push   $0x0
  802054:	e8 51 ee ff ff       	call   800eaa <sys_page_alloc>
  802059:	83 c4 10             	add    $0x10,%esp
  80205c:	89 c2                	mov    %eax,%edx
  80205e:	85 c0                	test   %eax,%eax
  802060:	0f 88 0d 01 00 00    	js     802173 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802066:	83 ec 0c             	sub    $0xc,%esp
  802069:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80206c:	50                   	push   %eax
  80206d:	e8 50 f0 ff ff       	call   8010c2 <fd_alloc>
  802072:	89 c3                	mov    %eax,%ebx
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	85 c0                	test   %eax,%eax
  802079:	0f 88 e2 00 00 00    	js     802161 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207f:	83 ec 04             	sub    $0x4,%esp
  802082:	68 07 04 00 00       	push   $0x407
  802087:	ff 75 f0             	pushl  -0x10(%ebp)
  80208a:	6a 00                	push   $0x0
  80208c:	e8 19 ee ff ff       	call   800eaa <sys_page_alloc>
  802091:	89 c3                	mov    %eax,%ebx
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	85 c0                	test   %eax,%eax
  802098:	0f 88 c3 00 00 00    	js     802161 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80209e:	83 ec 0c             	sub    $0xc,%esp
  8020a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a4:	e8 02 f0 ff ff       	call   8010ab <fd2data>
  8020a9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ab:	83 c4 0c             	add    $0xc,%esp
  8020ae:	68 07 04 00 00       	push   $0x407
  8020b3:	50                   	push   %eax
  8020b4:	6a 00                	push   $0x0
  8020b6:	e8 ef ed ff ff       	call   800eaa <sys_page_alloc>
  8020bb:	89 c3                	mov    %eax,%ebx
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	0f 88 89 00 00 00    	js     802151 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c8:	83 ec 0c             	sub    $0xc,%esp
  8020cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ce:	e8 d8 ef ff ff       	call   8010ab <fd2data>
  8020d3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020da:	50                   	push   %eax
  8020db:	6a 00                	push   $0x0
  8020dd:	56                   	push   %esi
  8020de:	6a 00                	push   $0x0
  8020e0:	e8 08 ee ff ff       	call   800eed <sys_page_map>
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	83 c4 20             	add    $0x20,%esp
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	78 55                	js     802143 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020ee:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802103:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802109:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80210c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80210e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802111:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802118:	83 ec 0c             	sub    $0xc,%esp
  80211b:	ff 75 f4             	pushl  -0xc(%ebp)
  80211e:	e8 78 ef ff ff       	call   80109b <fd2num>
  802123:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802126:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802128:	83 c4 04             	add    $0x4,%esp
  80212b:	ff 75 f0             	pushl  -0x10(%ebp)
  80212e:	e8 68 ef ff ff       	call   80109b <fd2num>
  802133:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802136:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802139:	83 c4 10             	add    $0x10,%esp
  80213c:	ba 00 00 00 00       	mov    $0x0,%edx
  802141:	eb 30                	jmp    802173 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802143:	83 ec 08             	sub    $0x8,%esp
  802146:	56                   	push   %esi
  802147:	6a 00                	push   $0x0
  802149:	e8 e1 ed ff ff       	call   800f2f <sys_page_unmap>
  80214e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802151:	83 ec 08             	sub    $0x8,%esp
  802154:	ff 75 f0             	pushl  -0x10(%ebp)
  802157:	6a 00                	push   $0x0
  802159:	e8 d1 ed ff ff       	call   800f2f <sys_page_unmap>
  80215e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802161:	83 ec 08             	sub    $0x8,%esp
  802164:	ff 75 f4             	pushl  -0xc(%ebp)
  802167:	6a 00                	push   $0x0
  802169:	e8 c1 ed ff ff       	call   800f2f <sys_page_unmap>
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802173:	89 d0                	mov    %edx,%eax
  802175:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802178:	5b                   	pop    %ebx
  802179:	5e                   	pop    %esi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    

0080217c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802185:	50                   	push   %eax
  802186:	ff 75 08             	pushl  0x8(%ebp)
  802189:	e8 83 ef ff ff       	call   801111 <fd_lookup>
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	85 c0                	test   %eax,%eax
  802193:	78 18                	js     8021ad <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802195:	83 ec 0c             	sub    $0xc,%esp
  802198:	ff 75 f4             	pushl  -0xc(%ebp)
  80219b:	e8 0b ef ff ff       	call   8010ab <fd2data>
	return _pipeisclosed(fd, p);
  8021a0:	89 c2                	mov    %eax,%edx
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	e8 21 fd ff ff       	call   801ecb <_pipeisclosed>
  8021aa:	83 c4 10             	add    $0x10,%esp
}
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    

008021af <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021b7:	85 f6                	test   %esi,%esi
  8021b9:	75 16                	jne    8021d1 <wait+0x22>
  8021bb:	68 e7 2b 80 00       	push   $0x802be7
  8021c0:	68 ff 2a 80 00       	push   $0x802aff
  8021c5:	6a 09                	push   $0x9
  8021c7:	68 f2 2b 80 00       	push   $0x802bf2
  8021cc:	e8 2e e2 ff ff       	call   8003ff <_panic>
	e = &envs[ENVX(envid)];
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021d9:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021dc:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8021e2:	eb 05                	jmp    8021e9 <wait+0x3a>
		sys_yield();
  8021e4:	e8 a2 ec ff ff       	call   800e8b <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021e9:	8b 43 48             	mov    0x48(%ebx),%eax
  8021ec:	39 c6                	cmp    %eax,%esi
  8021ee:	75 07                	jne    8021f7 <wait+0x48>
  8021f0:	8b 43 54             	mov    0x54(%ebx),%eax
  8021f3:	85 c0                	test   %eax,%eax
  8021f5:	75 ed                	jne    8021e4 <wait+0x35>
		sys_yield();
}
  8021f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fa:	5b                   	pop    %ebx
  8021fb:	5e                   	pop    %esi
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    

008021fe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	56                   	push   %esi
  802202:	53                   	push   %ebx
  802203:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802206:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  802209:	83 ec 0c             	sub    $0xc,%esp
  80220c:	ff 75 0c             	pushl  0xc(%ebp)
  80220f:	e8 46 ee ff ff       	call   80105a <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	85 f6                	test   %esi,%esi
  802219:	74 1c                	je     802237 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  80221b:	a1 90 67 80 00       	mov    0x806790,%eax
  802220:	8b 40 78             	mov    0x78(%eax),%eax
  802223:	89 06                	mov    %eax,(%esi)
  802225:	eb 10                	jmp    802237 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802227:	83 ec 0c             	sub    $0xc,%esp
  80222a:	68 fd 2b 80 00       	push   $0x802bfd
  80222f:	e8 a4 e2 ff ff       	call   8004d8 <cprintf>
  802234:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802237:	a1 90 67 80 00       	mov    0x806790,%eax
  80223c:	8b 50 74             	mov    0x74(%eax),%edx
  80223f:	85 d2                	test   %edx,%edx
  802241:	74 e4                	je     802227 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  802243:	85 db                	test   %ebx,%ebx
  802245:	74 05                	je     80224c <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802247:	8b 40 74             	mov    0x74(%eax),%eax
  80224a:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80224c:	a1 90 67 80 00       	mov    0x806790,%eax
  802251:	8b 40 70             	mov    0x70(%eax),%eax

}
  802254:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	57                   	push   %edi
  80225f:	56                   	push   %esi
  802260:	53                   	push   %ebx
  802261:	83 ec 0c             	sub    $0xc,%esp
  802264:	8b 7d 08             	mov    0x8(%ebp),%edi
  802267:	8b 75 0c             	mov    0xc(%ebp),%esi
  80226a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  80226d:	85 db                	test   %ebx,%ebx
  80226f:	75 13                	jne    802284 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  802271:	6a 00                	push   $0x0
  802273:	68 00 00 c0 ee       	push   $0xeec00000
  802278:	56                   	push   %esi
  802279:	57                   	push   %edi
  80227a:	e8 b8 ed ff ff       	call   801037 <sys_ipc_try_send>
  80227f:	83 c4 10             	add    $0x10,%esp
  802282:	eb 0e                	jmp    802292 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  802284:	ff 75 14             	pushl  0x14(%ebp)
  802287:	53                   	push   %ebx
  802288:	56                   	push   %esi
  802289:	57                   	push   %edi
  80228a:	e8 a8 ed ff ff       	call   801037 <sys_ipc_try_send>
  80228f:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  802292:	85 c0                	test   %eax,%eax
  802294:	75 d7                	jne    80226d <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  802296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802299:	5b                   	pop    %ebx
  80229a:	5e                   	pop    %esi
  80229b:	5f                   	pop    %edi
  80229c:	5d                   	pop    %ebp
  80229d:	c3                   	ret    

0080229e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022a9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022ac:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022b2:	8b 52 50             	mov    0x50(%edx),%edx
  8022b5:	39 ca                	cmp    %ecx,%edx
  8022b7:	75 0d                	jne    8022c6 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022c1:	8b 40 48             	mov    0x48(%eax),%eax
  8022c4:	eb 0f                	jmp    8022d5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022c6:	83 c0 01             	add    $0x1,%eax
  8022c9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022ce:	75 d9                	jne    8022a9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022d5:	5d                   	pop    %ebp
  8022d6:	c3                   	ret    

008022d7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022dd:	89 d0                	mov    %edx,%eax
  8022df:	c1 e8 16             	shr    $0x16,%eax
  8022e2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022e9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ee:	f6 c1 01             	test   $0x1,%cl
  8022f1:	74 1d                	je     802310 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022f3:	c1 ea 0c             	shr    $0xc,%edx
  8022f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022fd:	f6 c2 01             	test   $0x1,%dl
  802300:	74 0e                	je     802310 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802302:	c1 ea 0c             	shr    $0xc,%edx
  802305:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80230c:	ef 
  80230d:	0f b7 c0             	movzwl %ax,%eax
}
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	66 90                	xchg   %ax,%ax
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__udivdi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	83 ec 1c             	sub    $0x1c,%esp
  802327:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80232b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80232f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802333:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802337:	85 f6                	test   %esi,%esi
  802339:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80233d:	89 ca                	mov    %ecx,%edx
  80233f:	89 f8                	mov    %edi,%eax
  802341:	75 3d                	jne    802380 <__udivdi3+0x60>
  802343:	39 cf                	cmp    %ecx,%edi
  802345:	0f 87 c5 00 00 00    	ja     802410 <__udivdi3+0xf0>
  80234b:	85 ff                	test   %edi,%edi
  80234d:	89 fd                	mov    %edi,%ebp
  80234f:	75 0b                	jne    80235c <__udivdi3+0x3c>
  802351:	b8 01 00 00 00       	mov    $0x1,%eax
  802356:	31 d2                	xor    %edx,%edx
  802358:	f7 f7                	div    %edi
  80235a:	89 c5                	mov    %eax,%ebp
  80235c:	89 c8                	mov    %ecx,%eax
  80235e:	31 d2                	xor    %edx,%edx
  802360:	f7 f5                	div    %ebp
  802362:	89 c1                	mov    %eax,%ecx
  802364:	89 d8                	mov    %ebx,%eax
  802366:	89 cf                	mov    %ecx,%edi
  802368:	f7 f5                	div    %ebp
  80236a:	89 c3                	mov    %eax,%ebx
  80236c:	89 d8                	mov    %ebx,%eax
  80236e:	89 fa                	mov    %edi,%edx
  802370:	83 c4 1c             	add    $0x1c,%esp
  802373:	5b                   	pop    %ebx
  802374:	5e                   	pop    %esi
  802375:	5f                   	pop    %edi
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    
  802378:	90                   	nop
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	39 ce                	cmp    %ecx,%esi
  802382:	77 74                	ja     8023f8 <__udivdi3+0xd8>
  802384:	0f bd fe             	bsr    %esi,%edi
  802387:	83 f7 1f             	xor    $0x1f,%edi
  80238a:	0f 84 98 00 00 00    	je     802428 <__udivdi3+0x108>
  802390:	bb 20 00 00 00       	mov    $0x20,%ebx
  802395:	89 f9                	mov    %edi,%ecx
  802397:	89 c5                	mov    %eax,%ebp
  802399:	29 fb                	sub    %edi,%ebx
  80239b:	d3 e6                	shl    %cl,%esi
  80239d:	89 d9                	mov    %ebx,%ecx
  80239f:	d3 ed                	shr    %cl,%ebp
  8023a1:	89 f9                	mov    %edi,%ecx
  8023a3:	d3 e0                	shl    %cl,%eax
  8023a5:	09 ee                	or     %ebp,%esi
  8023a7:	89 d9                	mov    %ebx,%ecx
  8023a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ad:	89 d5                	mov    %edx,%ebp
  8023af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023b3:	d3 ed                	shr    %cl,%ebp
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e2                	shl    %cl,%edx
  8023b9:	89 d9                	mov    %ebx,%ecx
  8023bb:	d3 e8                	shr    %cl,%eax
  8023bd:	09 c2                	or     %eax,%edx
  8023bf:	89 d0                	mov    %edx,%eax
  8023c1:	89 ea                	mov    %ebp,%edx
  8023c3:	f7 f6                	div    %esi
  8023c5:	89 d5                	mov    %edx,%ebp
  8023c7:	89 c3                	mov    %eax,%ebx
  8023c9:	f7 64 24 0c          	mull   0xc(%esp)
  8023cd:	39 d5                	cmp    %edx,%ebp
  8023cf:	72 10                	jb     8023e1 <__udivdi3+0xc1>
  8023d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023d5:	89 f9                	mov    %edi,%ecx
  8023d7:	d3 e6                	shl    %cl,%esi
  8023d9:	39 c6                	cmp    %eax,%esi
  8023db:	73 07                	jae    8023e4 <__udivdi3+0xc4>
  8023dd:	39 d5                	cmp    %edx,%ebp
  8023df:	75 03                	jne    8023e4 <__udivdi3+0xc4>
  8023e1:	83 eb 01             	sub    $0x1,%ebx
  8023e4:	31 ff                	xor    %edi,%edi
  8023e6:	89 d8                	mov    %ebx,%eax
  8023e8:	89 fa                	mov    %edi,%edx
  8023ea:	83 c4 1c             	add    $0x1c,%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    
  8023f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f8:	31 ff                	xor    %edi,%edi
  8023fa:	31 db                	xor    %ebx,%ebx
  8023fc:	89 d8                	mov    %ebx,%eax
  8023fe:	89 fa                	mov    %edi,%edx
  802400:	83 c4 1c             	add    $0x1c,%esp
  802403:	5b                   	pop    %ebx
  802404:	5e                   	pop    %esi
  802405:	5f                   	pop    %edi
  802406:	5d                   	pop    %ebp
  802407:	c3                   	ret    
  802408:	90                   	nop
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	89 d8                	mov    %ebx,%eax
  802412:	f7 f7                	div    %edi
  802414:	31 ff                	xor    %edi,%edi
  802416:	89 c3                	mov    %eax,%ebx
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	89 fa                	mov    %edi,%edx
  80241c:	83 c4 1c             	add    $0x1c,%esp
  80241f:	5b                   	pop    %ebx
  802420:	5e                   	pop    %esi
  802421:	5f                   	pop    %edi
  802422:	5d                   	pop    %ebp
  802423:	c3                   	ret    
  802424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802428:	39 ce                	cmp    %ecx,%esi
  80242a:	72 0c                	jb     802438 <__udivdi3+0x118>
  80242c:	31 db                	xor    %ebx,%ebx
  80242e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802432:	0f 87 34 ff ff ff    	ja     80236c <__udivdi3+0x4c>
  802438:	bb 01 00 00 00       	mov    $0x1,%ebx
  80243d:	e9 2a ff ff ff       	jmp    80236c <__udivdi3+0x4c>
  802442:	66 90                	xchg   %ax,%ax
  802444:	66 90                	xchg   %ax,%ax
  802446:	66 90                	xchg   %ax,%ax
  802448:	66 90                	xchg   %ax,%ax
  80244a:	66 90                	xchg   %ax,%ax
  80244c:	66 90                	xchg   %ax,%ax
  80244e:	66 90                	xchg   %ax,%ax

00802450 <__umoddi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	53                   	push   %ebx
  802454:	83 ec 1c             	sub    $0x1c,%esp
  802457:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80245b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80245f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802463:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802467:	85 d2                	test   %edx,%edx
  802469:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80246d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802471:	89 f3                	mov    %esi,%ebx
  802473:	89 3c 24             	mov    %edi,(%esp)
  802476:	89 74 24 04          	mov    %esi,0x4(%esp)
  80247a:	75 1c                	jne    802498 <__umoddi3+0x48>
  80247c:	39 f7                	cmp    %esi,%edi
  80247e:	76 50                	jbe    8024d0 <__umoddi3+0x80>
  802480:	89 c8                	mov    %ecx,%eax
  802482:	89 f2                	mov    %esi,%edx
  802484:	f7 f7                	div    %edi
  802486:	89 d0                	mov    %edx,%eax
  802488:	31 d2                	xor    %edx,%edx
  80248a:	83 c4 1c             	add    $0x1c,%esp
  80248d:	5b                   	pop    %ebx
  80248e:	5e                   	pop    %esi
  80248f:	5f                   	pop    %edi
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    
  802492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802498:	39 f2                	cmp    %esi,%edx
  80249a:	89 d0                	mov    %edx,%eax
  80249c:	77 52                	ja     8024f0 <__umoddi3+0xa0>
  80249e:	0f bd ea             	bsr    %edx,%ebp
  8024a1:	83 f5 1f             	xor    $0x1f,%ebp
  8024a4:	75 5a                	jne    802500 <__umoddi3+0xb0>
  8024a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024aa:	0f 82 e0 00 00 00    	jb     802590 <__umoddi3+0x140>
  8024b0:	39 0c 24             	cmp    %ecx,(%esp)
  8024b3:	0f 86 d7 00 00 00    	jbe    802590 <__umoddi3+0x140>
  8024b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024c1:	83 c4 1c             	add    $0x1c,%esp
  8024c4:	5b                   	pop    %ebx
  8024c5:	5e                   	pop    %esi
  8024c6:	5f                   	pop    %edi
  8024c7:	5d                   	pop    %ebp
  8024c8:	c3                   	ret    
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	85 ff                	test   %edi,%edi
  8024d2:	89 fd                	mov    %edi,%ebp
  8024d4:	75 0b                	jne    8024e1 <__umoddi3+0x91>
  8024d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024db:	31 d2                	xor    %edx,%edx
  8024dd:	f7 f7                	div    %edi
  8024df:	89 c5                	mov    %eax,%ebp
  8024e1:	89 f0                	mov    %esi,%eax
  8024e3:	31 d2                	xor    %edx,%edx
  8024e5:	f7 f5                	div    %ebp
  8024e7:	89 c8                	mov    %ecx,%eax
  8024e9:	f7 f5                	div    %ebp
  8024eb:	89 d0                	mov    %edx,%eax
  8024ed:	eb 99                	jmp    802488 <__umoddi3+0x38>
  8024ef:	90                   	nop
  8024f0:	89 c8                	mov    %ecx,%eax
  8024f2:	89 f2                	mov    %esi,%edx
  8024f4:	83 c4 1c             	add    $0x1c,%esp
  8024f7:	5b                   	pop    %ebx
  8024f8:	5e                   	pop    %esi
  8024f9:	5f                   	pop    %edi
  8024fa:	5d                   	pop    %ebp
  8024fb:	c3                   	ret    
  8024fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802500:	8b 34 24             	mov    (%esp),%esi
  802503:	bf 20 00 00 00       	mov    $0x20,%edi
  802508:	89 e9                	mov    %ebp,%ecx
  80250a:	29 ef                	sub    %ebp,%edi
  80250c:	d3 e0                	shl    %cl,%eax
  80250e:	89 f9                	mov    %edi,%ecx
  802510:	89 f2                	mov    %esi,%edx
  802512:	d3 ea                	shr    %cl,%edx
  802514:	89 e9                	mov    %ebp,%ecx
  802516:	09 c2                	or     %eax,%edx
  802518:	89 d8                	mov    %ebx,%eax
  80251a:	89 14 24             	mov    %edx,(%esp)
  80251d:	89 f2                	mov    %esi,%edx
  80251f:	d3 e2                	shl    %cl,%edx
  802521:	89 f9                	mov    %edi,%ecx
  802523:	89 54 24 04          	mov    %edx,0x4(%esp)
  802527:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80252b:	d3 e8                	shr    %cl,%eax
  80252d:	89 e9                	mov    %ebp,%ecx
  80252f:	89 c6                	mov    %eax,%esi
  802531:	d3 e3                	shl    %cl,%ebx
  802533:	89 f9                	mov    %edi,%ecx
  802535:	89 d0                	mov    %edx,%eax
  802537:	d3 e8                	shr    %cl,%eax
  802539:	89 e9                	mov    %ebp,%ecx
  80253b:	09 d8                	or     %ebx,%eax
  80253d:	89 d3                	mov    %edx,%ebx
  80253f:	89 f2                	mov    %esi,%edx
  802541:	f7 34 24             	divl   (%esp)
  802544:	89 d6                	mov    %edx,%esi
  802546:	d3 e3                	shl    %cl,%ebx
  802548:	f7 64 24 04          	mull   0x4(%esp)
  80254c:	39 d6                	cmp    %edx,%esi
  80254e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802552:	89 d1                	mov    %edx,%ecx
  802554:	89 c3                	mov    %eax,%ebx
  802556:	72 08                	jb     802560 <__umoddi3+0x110>
  802558:	75 11                	jne    80256b <__umoddi3+0x11b>
  80255a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80255e:	73 0b                	jae    80256b <__umoddi3+0x11b>
  802560:	2b 44 24 04          	sub    0x4(%esp),%eax
  802564:	1b 14 24             	sbb    (%esp),%edx
  802567:	89 d1                	mov    %edx,%ecx
  802569:	89 c3                	mov    %eax,%ebx
  80256b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80256f:	29 da                	sub    %ebx,%edx
  802571:	19 ce                	sbb    %ecx,%esi
  802573:	89 f9                	mov    %edi,%ecx
  802575:	89 f0                	mov    %esi,%eax
  802577:	d3 e0                	shl    %cl,%eax
  802579:	89 e9                	mov    %ebp,%ecx
  80257b:	d3 ea                	shr    %cl,%edx
  80257d:	89 e9                	mov    %ebp,%ecx
  80257f:	d3 ee                	shr    %cl,%esi
  802581:	09 d0                	or     %edx,%eax
  802583:	89 f2                	mov    %esi,%edx
  802585:	83 c4 1c             	add    $0x1c,%esp
  802588:	5b                   	pop    %ebx
  802589:	5e                   	pop    %esi
  80258a:	5f                   	pop    %edi
  80258b:	5d                   	pop    %ebp
  80258c:	c3                   	ret    
  80258d:	8d 76 00             	lea    0x0(%esi),%esi
  802590:	29 f9                	sub    %edi,%ecx
  802592:	19 d6                	sbb    %edx,%esi
  802594:	89 74 24 04          	mov    %esi,0x4(%esp)
  802598:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80259c:	e9 18 ff ff ff       	jmp    8024b9 <__umoddi3+0x69>
