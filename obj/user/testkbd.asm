
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 3b 02 00 00       	call   80026c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 07 0e 00 00       	call   800e4b <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 a8 11 00 00       	call   8011fb <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %e", r);
  80005f:	50                   	push   %eax
  800060:	68 80 20 80 00       	push   $0x802080
  800065:	6a 0f                	push   $0xf
  800067:	68 8d 20 80 00       	push   $0x80208d
  80006c:	e8 5b 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 9c 20 80 00       	push   $0x80209c
  80007b:	6a 11                	push   $0x11
  80007d:	68 8d 20 80 00       	push   $0x80208d
  800082:	e8 45 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 b8 11 00 00       	call   80124b <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 b6 20 80 00       	push   $0x8020b6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 8d 20 80 00       	push   $0x80208d
  8000a7:	e8 20 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 be 20 80 00       	push   $0x8020be
  8000b4:	e8 82 08 00 00       	call   80093b <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 cc 20 80 00       	push   $0x8020cc
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 72 18 00 00       	call   801942 <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 d0 20 80 00       	push   $0x8020d0
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 5e 18 00 00       	call   801942 <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 e8 20 80 00       	push   $0x8020e8
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 61 09 00 00       	call   800a67 <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2d                	jmp    800153 <devcons_write+0x46>
		m = n - tot;
  800126:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800129:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80012b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800133:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800136:	83 ec 04             	sub    $0x4,%esp
  800139:	53                   	push   %ebx
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 b5 0a 00 00       	call   800bf9 <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 60 0c 00 00       	call   800dae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	89 f0                	mov    %esi,%eax
  800155:	3b 75 10             	cmp    0x10(%ebp),%esi
  800158:	72 cc                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	74 2a                	je     80019d <devcons_read+0x3b>
  800173:	eb 05                	jmp    80017a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800175:	e8 d1 0c 00 00       	call   800e4b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017a:	e8 4d 0c 00 00       	call   800dcc <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 16                	js     80019d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb 05                	jmp    80019d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 f8 0b 00 00       	call   800dae <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:

int
getchar(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 69 11 00 00       	call   801337 <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 0f                	js     8001e4 <getchar+0x29>
		return r;
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
		return -E_EOF;
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001dd:	eb 05                	jmp    8001e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 d9 0e 00 00       	call   8010d1 <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:

int
opencons(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 61 0e 00 00       	call   801082 <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
		return r;
  800224:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	78 3e                	js     800268 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	68 07 04 00 00       	push   $0x407
  800232:	ff 75 f4             	pushl  -0xc(%ebp)
  800235:	6a 00                	push   $0x0
  800237:	e8 2e 0c 00 00       	call   800e6a <sys_page_alloc>
  80023c:	83 c4 10             	add    $0x10,%esp
		return r;
  80023f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	78 23                	js     800268 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800245:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800253:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	e8 f8 0d 00 00       	call   80105b <fd2num>
  800263:	89 c2                	mov    %eax,%edx
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	89 d0                	mov    %edx,%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800274:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800277:	e8 b0 0b 00 00       	call   800e2c <sys_getenvid>
  80027c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800281:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800289:	a3 04 44 80 00       	mov    %eax,0x804404
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028e:	85 db                	test   %ebx,%ebx
  800290:	7e 07                	jle    800299 <libmain+0x2d>
		binaryname = argv[0];
  800292:	8b 06                	mov    (%esi),%eax
  800294:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	e8 90 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002a3:	e8 0a 00 00 00       	call   8002b2 <exit>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b8:	e8 69 0f 00 00       	call   801226 <close_all>
	sys_env_destroy(0);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	6a 00                	push   $0x0
  8002c2:	e8 24 0b 00 00       	call   800deb <sys_env_destroy>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d4:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002da:	e8 4d 0b 00 00       	call   800e2c <sys_getenvid>
  8002df:	83 ec 0c             	sub    $0xc,%esp
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	56                   	push   %esi
  8002e9:	50                   	push   %eax
  8002ea:	68 00 21 80 00       	push   $0x802100
  8002ef:	e8 b1 00 00 00       	call   8003a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	53                   	push   %ebx
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	e8 54 00 00 00       	call   800354 <vcprintf>
	cprintf("\n");
  800300:	c7 04 24 e6 20 80 00 	movl   $0x8020e6,(%esp)
  800307:	e8 99 00 00 00       	call   8003a5 <cprintf>
  80030c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030f:	cc                   	int3   
  800310:	eb fd                	jmp    80030f <_panic+0x43>

00800312 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	53                   	push   %ebx
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031c:	8b 13                	mov    (%ebx),%edx
  80031e:	8d 42 01             	lea    0x1(%edx),%eax
  800321:	89 03                	mov    %eax,(%ebx)
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032f:	75 1a                	jne    80034b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	68 ff 00 00 00       	push   $0xff
  800339:	8d 43 08             	lea    0x8(%ebx),%eax
  80033c:	50                   	push   %eax
  80033d:	e8 6c 0a 00 00       	call   800dae <sys_cputs>
		b->idx = 0;
  800342:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800348:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80035d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800364:	00 00 00 
	b.cnt = 0;
  800367:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800371:	ff 75 0c             	pushl  0xc(%ebp)
  800374:	ff 75 08             	pushl  0x8(%ebp)
  800377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037d:	50                   	push   %eax
  80037e:	68 12 03 80 00       	push   $0x800312
  800383:	e8 54 01 00 00       	call   8004dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800388:	83 c4 08             	add    $0x8,%esp
  80038b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800391:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800397:	50                   	push   %eax
  800398:	e8 11 0a 00 00       	call   800dae <sys_cputs>

	return b.cnt;
}
  80039d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ae:	50                   	push   %eax
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 9d ff ff ff       	call   800354 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 1c             	sub    $0x1c,%esp
  8003c2:	89 c7                	mov    %eax,%edi
  8003c4:	89 d6                	mov    %edx,%esi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003dd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003e0:	39 d3                	cmp    %edx,%ebx
  8003e2:	72 05                	jb     8003e9 <printnum+0x30>
  8003e4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e7:	77 45                	ja     80042e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e9:	83 ec 0c             	sub    $0xc,%esp
  8003ec:	ff 75 18             	pushl  0x18(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003f5:	53                   	push   %ebx
  8003f6:	ff 75 10             	pushl  0x10(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800402:	ff 75 dc             	pushl  -0x24(%ebp)
  800405:	ff 75 d8             	pushl  -0x28(%ebp)
  800408:	e8 d3 19 00 00       	call   801de0 <__udivdi3>
  80040d:	83 c4 18             	add    $0x18,%esp
  800410:	52                   	push   %edx
  800411:	50                   	push   %eax
  800412:	89 f2                	mov    %esi,%edx
  800414:	89 f8                	mov    %edi,%eax
  800416:	e8 9e ff ff ff       	call   8003b9 <printnum>
  80041b:	83 c4 20             	add    $0x20,%esp
  80041e:	eb 18                	jmp    800438 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	56                   	push   %esi
  800424:	ff 75 18             	pushl  0x18(%ebp)
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	eb 03                	jmp    800431 <printnum+0x78>
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800431:	83 eb 01             	sub    $0x1,%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	7f e8                	jg     800420 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 c0 1a 00 00       	call   801f10 <__umoddi3>
  800450:	83 c4 14             	add    $0x14,%esp
  800453:	0f be 80 23 21 80 00 	movsbl 0x802123(%eax),%eax
  80045a:	50                   	push   %eax
  80045b:	ff d7                	call   *%edi
}
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80046b:	83 fa 01             	cmp    $0x1,%edx
  80046e:	7e 0e                	jle    80047e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 08             	lea    0x8(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	8b 52 04             	mov    0x4(%edx),%edx
  80047c:	eb 22                	jmp    8004a0 <getuint+0x38>
	else if (lflag)
  80047e:	85 d2                	test   %edx,%edx
  800480:	74 10                	je     800492 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 04             	lea    0x4(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	ba 00 00 00 00       	mov    $0x0,%edx
  800490:	eb 0e                	jmp    8004a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800492:	8b 10                	mov    (%eax),%edx
  800494:	8d 4a 04             	lea    0x4(%edx),%ecx
  800497:	89 08                	mov    %ecx,(%eax)
  800499:	8b 02                	mov    (%edx),%eax
  80049b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b1:	73 0a                	jae    8004bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	88 02                	mov    %al,(%edx)
}
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c8:	50                   	push   %eax
  8004c9:	ff 75 10             	pushl  0x10(%ebp)
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 05 00 00 00       	call   8004dc <vprintfmt>
	va_end(ap);
}
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 2c             	sub    $0x2c,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ee:	eb 12                	jmp    800502 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	0f 84 d3 03 00 00    	je     8008cb <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	50                   	push   %eax
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	83 f8 25             	cmp    $0x25,%eax
  80050c:	75 e2                	jne    8004f0 <vprintfmt+0x14>
  80050e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800512:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800519:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800520:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800527:	ba 00 00 00 00       	mov    $0x0,%edx
  80052c:	eb 07                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800531:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8d 47 01             	lea    0x1(%edi),%eax
  800538:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053b:	0f b6 07             	movzbl (%edi),%eax
  80053e:	0f b6 c8             	movzbl %al,%ecx
  800541:	83 e8 23             	sub    $0x23,%eax
  800544:	3c 55                	cmp    $0x55,%al
  800546:	0f 87 64 03 00 00    	ja     8008b0 <vprintfmt+0x3d4>
  80054c:	0f b6 c0             	movzbl %al,%eax
  80054f:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800559:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80055d:	eb d6                	jmp    800535 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	b8 00 00 00 00       	mov    $0x0,%eax
  800567:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80056a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80056d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800571:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800574:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800577:	83 fa 09             	cmp    $0x9,%edx
  80057a:	77 39                	ja     8005b5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80057c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80057f:	eb e9                	jmp    80056a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 48 04             	lea    0x4(%eax),%ecx
  800587:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800592:	eb 27                	jmp    8005bb <vprintfmt+0xdf>
  800594:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059e:	0f 49 c8             	cmovns %eax,%ecx
  8005a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	eb 8c                	jmp    800535 <vprintfmt+0x59>
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005b3:	eb 80                	jmp    800535 <vprintfmt+0x59>
  8005b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b8:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8005bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bf:	0f 89 70 ff ff ff    	jns    800535 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005c5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cb:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8005d2:	e9 5e ff ff ff       	jmp    800535 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005dd:	e9 53 ff ff ff       	jmp    800535 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	ff 30                	pushl  (%eax)
  8005f1:	ff d6                	call   *%esi
			break;
  8005f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f9:	e9 04 ff ff ff       	jmp    800502 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	99                   	cltd   
  80060a:	31 d0                	xor    %edx,%eax
  80060c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060e:	83 f8 0f             	cmp    $0xf,%eax
  800611:	7f 0b                	jg     80061e <vprintfmt+0x142>
  800613:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  80061a:	85 d2                	test   %edx,%edx
  80061c:	75 18                	jne    800636 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80061e:	50                   	push   %eax
  80061f:	68 3b 21 80 00       	push   $0x80213b
  800624:	53                   	push   %ebx
  800625:	56                   	push   %esi
  800626:	e8 94 fe ff ff       	call   8004bf <printfmt>
  80062b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800631:	e9 cc fe ff ff       	jmp    800502 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800636:	52                   	push   %edx
  800637:	68 05 25 80 00       	push   $0x802505
  80063c:	53                   	push   %ebx
  80063d:	56                   	push   %esi
  80063e:	e8 7c fe ff ff       	call   8004bf <printfmt>
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800649:	e9 b4 fe ff ff       	jmp    800502 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800659:	85 ff                	test   %edi,%edi
  80065b:	b8 34 21 80 00       	mov    $0x802134,%eax
  800660:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800663:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800667:	0f 8e 94 00 00 00    	jle    800701 <vprintfmt+0x225>
  80066d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800671:	0f 84 98 00 00 00    	je     80070f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	ff 75 c8             	pushl  -0x38(%ebp)
  80067d:	57                   	push   %edi
  80067e:	e8 c3 03 00 00       	call   800a46 <strnlen>
  800683:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800686:	29 c1                	sub    %eax,%ecx
  800688:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80068b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800692:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800695:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800698:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	eb 0f                	jmp    8006ab <vprintfmt+0x1cf>
					putch(padc, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 ff                	test   %edi,%edi
  8006ad:	7f ed                	jg     80069c <vprintfmt+0x1c0>
  8006af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	0f 49 c1             	cmovns %ecx,%eax
  8006bf:	29 c1                	sub    %eax,%ecx
  8006c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c4:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	89 cb                	mov    %ecx,%ebx
  8006cc:	eb 4d                	jmp    80071b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d2:	74 1b                	je     8006ef <vprintfmt+0x213>
  8006d4:	0f be c0             	movsbl %al,%eax
  8006d7:	83 e8 20             	sub    $0x20,%eax
  8006da:	83 f8 5e             	cmp    $0x5e,%eax
  8006dd:	76 10                	jbe    8006ef <vprintfmt+0x213>
					putch('?', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	6a 3f                	push   $0x3f
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 0d                	jmp    8006fc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	83 eb 01             	sub    $0x1,%ebx
  8006ff:	eb 1a                	jmp    80071b <vprintfmt+0x23f>
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070d:	eb 0c                	jmp    80071b <vprintfmt+0x23f>
  80070f:	89 75 08             	mov    %esi,0x8(%ebp)
  800712:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800715:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800718:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071b:	83 c7 01             	add    $0x1,%edi
  80071e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800722:	0f be d0             	movsbl %al,%edx
  800725:	85 d2                	test   %edx,%edx
  800727:	74 23                	je     80074c <vprintfmt+0x270>
  800729:	85 f6                	test   %esi,%esi
  80072b:	78 a1                	js     8006ce <vprintfmt+0x1f2>
  80072d:	83 ee 01             	sub    $0x1,%esi
  800730:	79 9c                	jns    8006ce <vprintfmt+0x1f2>
  800732:	89 df                	mov    %ebx,%edi
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	eb 18                	jmp    800754 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 20                	push   $0x20
  800742:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 ef 01             	sub    $0x1,%edi
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 08                	jmp    800754 <vprintfmt+0x278>
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800754:	85 ff                	test   %edi,%edi
  800756:	7f e4                	jg     80073c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 a2 fd ff ff       	jmp    800502 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800760:	83 fa 01             	cmp    $0x1,%edx
  800763:	7e 16                	jle    80077b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 08             	lea    0x8(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800776:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800779:	eb 32                	jmp    8007ad <vprintfmt+0x2d1>
	else if (lflag)
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 18                	je     800797 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80078d:	89 c1                	mov    %eax,%ecx
  80078f:	c1 f9 1f             	sar    $0x1f,%ecx
  800792:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800795:	eb 16                	jmp    8007ad <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007a5:	89 c1                	mov    %eax,%ecx
  8007a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ad:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007b0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007be:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007c2:	0f 89 b0 00 00 00    	jns    800878 <vprintfmt+0x39c>
				putch('-', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 2d                	push   $0x2d
  8007ce:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007d3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007d6:	f7 d8                	neg    %eax
  8007d8:	83 d2 00             	adc    $0x0,%edx
  8007db:	f7 da                	neg    %edx
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007eb:	e9 88 00 00 00       	jmp    800878 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f3:	e8 70 fc ff ff       	call   800468 <getuint>
  8007f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800803:	eb 73                	jmp    800878 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	e8 5b fc ff ff       	call   800468 <getuint>
  80080d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800810:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800813:	83 ec 08             	sub    $0x8,%esp
  800816:	53                   	push   %ebx
  800817:	6a 58                	push   $0x58
  800819:	ff d6                	call   *%esi
			putch('X', putdat);
  80081b:	83 c4 08             	add    $0x8,%esp
  80081e:	53                   	push   %ebx
  80081f:	6a 58                	push   $0x58
  800821:	ff d6                	call   *%esi
			putch('X', putdat);
  800823:	83 c4 08             	add    $0x8,%esp
  800826:	53                   	push   %ebx
  800827:	6a 58                	push   $0x58
  800829:	ff d6                	call   *%esi
			goto number;
  80082b:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80082e:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800833:	eb 43                	jmp    800878 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800835:	83 ec 08             	sub    $0x8,%esp
  800838:	53                   	push   %ebx
  800839:	6a 30                	push   $0x30
  80083b:	ff d6                	call   *%esi
			putch('x', putdat);
  80083d:	83 c4 08             	add    $0x8,%esp
  800840:	53                   	push   %ebx
  800841:	6a 78                	push   $0x78
  800843:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800845:	8b 45 14             	mov    0x14(%ebp),%eax
  800848:	8d 50 04             	lea    0x4(%eax),%edx
  80084b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80084e:	8b 00                	mov    (%eax),%eax
  800850:	ba 00 00 00 00       	mov    $0x0,%edx
  800855:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800858:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80085b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80085e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800863:	eb 13                	jmp    800878 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
  800868:	e8 fb fb ff ff       	call   800468 <getuint>
  80086d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800870:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800873:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800878:	83 ec 0c             	sub    $0xc,%esp
  80087b:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80087f:	52                   	push   %edx
  800880:	ff 75 e0             	pushl  -0x20(%ebp)
  800883:	50                   	push   %eax
  800884:	ff 75 dc             	pushl  -0x24(%ebp)
  800887:	ff 75 d8             	pushl  -0x28(%ebp)
  80088a:	89 da                	mov    %ebx,%edx
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	e8 26 fb ff ff       	call   8003b9 <printnum>
			break;
  800893:	83 c4 20             	add    $0x20,%esp
  800896:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800899:	e9 64 fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	53                   	push   %ebx
  8008a2:	51                   	push   %ecx
  8008a3:	ff d6                	call   *%esi
			break;
  8008a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ab:	e9 52 fc ff ff       	jmp    800502 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b0:	83 ec 08             	sub    $0x8,%esp
  8008b3:	53                   	push   %ebx
  8008b4:	6a 25                	push   $0x25
  8008b6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 03                	jmp    8008c0 <vprintfmt+0x3e4>
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c4:	75 f7                	jne    8008bd <vprintfmt+0x3e1>
  8008c6:	e9 37 fc ff ff       	jmp    800502 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5f                   	pop    %edi
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	83 ec 18             	sub    $0x18,%esp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f0:	85 c0                	test   %eax,%eax
  8008f2:	74 26                	je     80091a <vsnprintf+0x47>
  8008f4:	85 d2                	test   %edx,%edx
  8008f6:	7e 22                	jle    80091a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f8:	ff 75 14             	pushl  0x14(%ebp)
  8008fb:	ff 75 10             	pushl  0x10(%ebp)
  8008fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800901:	50                   	push   %eax
  800902:	68 a2 04 80 00       	push   $0x8004a2
  800907:	e8 d0 fb ff ff       	call   8004dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800912:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	eb 05                	jmp    80091f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80091a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800927:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80092a:	50                   	push   %eax
  80092b:	ff 75 10             	pushl  0x10(%ebp)
  80092e:	ff 75 0c             	pushl  0xc(%ebp)
  800931:	ff 75 08             	pushl  0x8(%ebp)
  800934:	e8 9a ff ff ff       	call   8008d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	57                   	push   %edi
  80093f:	56                   	push   %esi
  800940:	53                   	push   %ebx
  800941:	83 ec 0c             	sub    $0xc,%esp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800947:	85 c0                	test   %eax,%eax
  800949:	74 13                	je     80095e <readline+0x23>
		fprintf(1, "%s", prompt);
  80094b:	83 ec 04             	sub    $0x4,%esp
  80094e:	50                   	push   %eax
  80094f:	68 05 25 80 00       	push   $0x802505
  800954:	6a 01                	push   $0x1
  800956:	e8 e7 0f 00 00       	call   801942 <fprintf>
  80095b:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80095e:	83 ec 0c             	sub    $0xc,%esp
  800961:	6a 00                	push   $0x0
  800963:	e8 7e f8 ff ff       	call   8001e6 <iscons>
  800968:	89 c7                	mov    %eax,%edi
  80096a:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80096d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800972:	e8 44 f8 ff ff       	call   8001bb <getchar>
  800977:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800979:	85 c0                	test   %eax,%eax
  80097b:	79 29                	jns    8009a6 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800982:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800985:	0f 84 9b 00 00 00    	je     800a26 <readline+0xeb>
				cprintf("read error: %e\n", c);
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	53                   	push   %ebx
  80098f:	68 1f 24 80 00       	push   $0x80241f
  800994:	e8 0c fa ff ff       	call   8003a5 <cprintf>
  800999:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	e9 80 00 00 00       	jmp    800a26 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009a6:	83 f8 08             	cmp    $0x8,%eax
  8009a9:	0f 94 c2             	sete   %dl
  8009ac:	83 f8 7f             	cmp    $0x7f,%eax
  8009af:	0f 94 c0             	sete   %al
  8009b2:	08 c2                	or     %al,%dl
  8009b4:	74 1a                	je     8009d0 <readline+0x95>
  8009b6:	85 f6                	test   %esi,%esi
  8009b8:	7e 16                	jle    8009d0 <readline+0x95>
			if (echoing)
  8009ba:	85 ff                	test   %edi,%edi
  8009bc:	74 0d                	je     8009cb <readline+0x90>
				cputchar('\b');
  8009be:	83 ec 0c             	sub    $0xc,%esp
  8009c1:	6a 08                	push   $0x8
  8009c3:	e8 d7 f7 ff ff       	call   80019f <cputchar>
  8009c8:	83 c4 10             	add    $0x10,%esp
			i--;
  8009cb:	83 ee 01             	sub    $0x1,%esi
  8009ce:	eb a2                	jmp    800972 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009d0:	83 fb 1f             	cmp    $0x1f,%ebx
  8009d3:	7e 26                	jle    8009fb <readline+0xc0>
  8009d5:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009db:	7f 1e                	jg     8009fb <readline+0xc0>
			if (echoing)
  8009dd:	85 ff                	test   %edi,%edi
  8009df:	74 0c                	je     8009ed <readline+0xb2>
				cputchar(c);
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	53                   	push   %ebx
  8009e5:	e8 b5 f7 ff ff       	call   80019f <cputchar>
  8009ea:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009ed:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009f3:	8d 76 01             	lea    0x1(%esi),%esi
  8009f6:	e9 77 ff ff ff       	jmp    800972 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009fb:	83 fb 0a             	cmp    $0xa,%ebx
  8009fe:	74 09                	je     800a09 <readline+0xce>
  800a00:	83 fb 0d             	cmp    $0xd,%ebx
  800a03:	0f 85 69 ff ff ff    	jne    800972 <readline+0x37>
			if (echoing)
  800a09:	85 ff                	test   %edi,%edi
  800a0b:	74 0d                	je     800a1a <readline+0xdf>
				cputchar('\n');
  800a0d:	83 ec 0c             	sub    $0xc,%esp
  800a10:	6a 0a                	push   $0xa
  800a12:	e8 88 f7 ff ff       	call   80019f <cputchar>
  800a17:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800a1a:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a21:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800a26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	eb 03                	jmp    800a3e <strlen+0x10>
		n++;
  800a3b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a42:	75 f7                	jne    800a3b <strlen+0xd>
		n++;
	return n;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a54:	eb 03                	jmp    800a59 <strnlen+0x13>
		n++;
  800a56:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a59:	39 c2                	cmp    %eax,%edx
  800a5b:	74 08                	je     800a65 <strnlen+0x1f>
  800a5d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a61:	75 f3                	jne    800a56 <strnlen+0x10>
  800a63:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a71:	89 c2                	mov    %eax,%edx
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a7d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a80:	84 db                	test   %bl,%bl
  800a82:	75 ef                	jne    800a73 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a84:	5b                   	pop    %ebx
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	53                   	push   %ebx
  800a8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8e:	53                   	push   %ebx
  800a8f:	e8 9a ff ff ff       	call   800a2e <strlen>
  800a94:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a97:	ff 75 0c             	pushl  0xc(%ebp)
  800a9a:	01 d8                	add    %ebx,%eax
  800a9c:	50                   	push   %eax
  800a9d:	e8 c5 ff ff ff       	call   800a67 <strcpy>
	return dst;
}
  800aa2:	89 d8                	mov    %ebx,%eax
  800aa4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab9:	89 f2                	mov    %esi,%edx
  800abb:	eb 0f                	jmp    800acc <strncpy+0x23>
		*dst++ = *src;
  800abd:	83 c2 01             	add    $0x1,%edx
  800ac0:	0f b6 01             	movzbl (%ecx),%eax
  800ac3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac6:	80 39 01             	cmpb   $0x1,(%ecx)
  800ac9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acc:	39 da                	cmp    %ebx,%edx
  800ace:	75 ed                	jne    800abd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad0:	89 f0                	mov    %esi,%eax
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae1:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae6:	85 d2                	test   %edx,%edx
  800ae8:	74 21                	je     800b0b <strlcpy+0x35>
  800aea:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aee:	89 f2                	mov    %esi,%edx
  800af0:	eb 09                	jmp    800afb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800af2:	83 c2 01             	add    $0x1,%edx
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800afb:	39 c2                	cmp    %eax,%edx
  800afd:	74 09                	je     800b08 <strlcpy+0x32>
  800aff:	0f b6 19             	movzbl (%ecx),%ebx
  800b02:	84 db                	test   %bl,%bl
  800b04:	75 ec                	jne    800af2 <strlcpy+0x1c>
  800b06:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b08:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b0b:	29 f0                	sub    %esi,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1a:	eb 06                	jmp    800b22 <strcmp+0x11>
		p++, q++;
  800b1c:	83 c1 01             	add    $0x1,%ecx
  800b1f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b22:	0f b6 01             	movzbl (%ecx),%eax
  800b25:	84 c0                	test   %al,%al
  800b27:	74 04                	je     800b2d <strcmp+0x1c>
  800b29:	3a 02                	cmp    (%edx),%al
  800b2b:	74 ef                	je     800b1c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2d:	0f b6 c0             	movzbl %al,%eax
  800b30:	0f b6 12             	movzbl (%edx),%edx
  800b33:	29 d0                	sub    %edx,%eax
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b46:	eb 06                	jmp    800b4e <strncmp+0x17>
		n--, p++, q++;
  800b48:	83 c0 01             	add    $0x1,%eax
  800b4b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4e:	39 d8                	cmp    %ebx,%eax
  800b50:	74 15                	je     800b67 <strncmp+0x30>
  800b52:	0f b6 08             	movzbl (%eax),%ecx
  800b55:	84 c9                	test   %cl,%cl
  800b57:	74 04                	je     800b5d <strncmp+0x26>
  800b59:	3a 0a                	cmp    (%edx),%cl
  800b5b:	74 eb                	je     800b48 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5d:	0f b6 00             	movzbl (%eax),%eax
  800b60:	0f b6 12             	movzbl (%edx),%edx
  800b63:	29 d0                	sub    %edx,%eax
  800b65:	eb 05                	jmp    800b6c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b79:	eb 07                	jmp    800b82 <strchr+0x13>
		if (*s == c)
  800b7b:	38 ca                	cmp    %cl,%dl
  800b7d:	74 0f                	je     800b8e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b7f:	83 c0 01             	add    $0x1,%eax
  800b82:	0f b6 10             	movzbl (%eax),%edx
  800b85:	84 d2                	test   %dl,%dl
  800b87:	75 f2                	jne    800b7b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
  800b96:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9a:	eb 03                	jmp    800b9f <strfind+0xf>
  800b9c:	83 c0 01             	add    $0x1,%eax
  800b9f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ba2:	38 ca                	cmp    %cl,%dl
  800ba4:	74 04                	je     800baa <strfind+0x1a>
  800ba6:	84 d2                	test   %dl,%dl
  800ba8:	75 f2                	jne    800b9c <strfind+0xc>
			break;
	return (char *) s;
}
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb8:	85 c9                	test   %ecx,%ecx
  800bba:	74 36                	je     800bf2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc2:	75 28                	jne    800bec <memset+0x40>
  800bc4:	f6 c1 03             	test   $0x3,%cl
  800bc7:	75 23                	jne    800bec <memset+0x40>
		c &= 0xFF;
  800bc9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	c1 e3 08             	shl    $0x8,%ebx
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	c1 e6 18             	shl    $0x18,%esi
  800bd7:	89 d0                	mov    %edx,%eax
  800bd9:	c1 e0 10             	shl    $0x10,%eax
  800bdc:	09 f0                	or     %esi,%eax
  800bde:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800be0:	89 d8                	mov    %ebx,%eax
  800be2:	09 d0                	or     %edx,%eax
  800be4:	c1 e9 02             	shr    $0x2,%ecx
  800be7:	fc                   	cld    
  800be8:	f3 ab                	rep stos %eax,%es:(%edi)
  800bea:	eb 06                	jmp    800bf2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bef:	fc                   	cld    
  800bf0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf2:	89 f8                	mov    %edi,%eax
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c07:	39 c6                	cmp    %eax,%esi
  800c09:	73 35                	jae    800c40 <memmove+0x47>
  800c0b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c0e:	39 d0                	cmp    %edx,%eax
  800c10:	73 2e                	jae    800c40 <memmove+0x47>
		s += n;
		d += n;
  800c12:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	09 fe                	or     %edi,%esi
  800c19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c1f:	75 13                	jne    800c34 <memmove+0x3b>
  800c21:	f6 c1 03             	test   $0x3,%cl
  800c24:	75 0e                	jne    800c34 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c26:	83 ef 04             	sub    $0x4,%edi
  800c29:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c2c:	c1 e9 02             	shr    $0x2,%ecx
  800c2f:	fd                   	std    
  800c30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c32:	eb 09                	jmp    800c3d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c34:	83 ef 01             	sub    $0x1,%edi
  800c37:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c3a:	fd                   	std    
  800c3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3d:	fc                   	cld    
  800c3e:	eb 1d                	jmp    800c5d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c40:	89 f2                	mov    %esi,%edx
  800c42:	09 c2                	or     %eax,%edx
  800c44:	f6 c2 03             	test   $0x3,%dl
  800c47:	75 0f                	jne    800c58 <memmove+0x5f>
  800c49:	f6 c1 03             	test   $0x3,%cl
  800c4c:	75 0a                	jne    800c58 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c4e:	c1 e9 02             	shr    $0x2,%ecx
  800c51:	89 c7                	mov    %eax,%edi
  800c53:	fc                   	cld    
  800c54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c56:	eb 05                	jmp    800c5d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c58:	89 c7                	mov    %eax,%edi
  800c5a:	fc                   	cld    
  800c5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c64:	ff 75 10             	pushl  0x10(%ebp)
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	ff 75 08             	pushl  0x8(%ebp)
  800c6d:	e8 87 ff ff ff       	call   800bf9 <memmove>
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7f:	89 c6                	mov    %eax,%esi
  800c81:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c84:	eb 1a                	jmp    800ca0 <memcmp+0x2c>
		if (*s1 != *s2)
  800c86:	0f b6 08             	movzbl (%eax),%ecx
  800c89:	0f b6 1a             	movzbl (%edx),%ebx
  800c8c:	38 d9                	cmp    %bl,%cl
  800c8e:	74 0a                	je     800c9a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c90:	0f b6 c1             	movzbl %cl,%eax
  800c93:	0f b6 db             	movzbl %bl,%ebx
  800c96:	29 d8                	sub    %ebx,%eax
  800c98:	eb 0f                	jmp    800ca9 <memcmp+0x35>
		s1++, s2++;
  800c9a:	83 c0 01             	add    $0x1,%eax
  800c9d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca0:	39 f0                	cmp    %esi,%eax
  800ca2:	75 e2                	jne    800c86 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	53                   	push   %ebx
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cb4:	89 c1                	mov    %eax,%ecx
  800cb6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbd:	eb 0a                	jmp    800cc9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cbf:	0f b6 10             	movzbl (%eax),%edx
  800cc2:	39 da                	cmp    %ebx,%edx
  800cc4:	74 07                	je     800ccd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc6:	83 c0 01             	add    $0x1,%eax
  800cc9:	39 c8                	cmp    %ecx,%eax
  800ccb:	72 f2                	jb     800cbf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdc:	eb 03                	jmp    800ce1 <strtol+0x11>
		s++;
  800cde:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce1:	0f b6 01             	movzbl (%ecx),%eax
  800ce4:	3c 20                	cmp    $0x20,%al
  800ce6:	74 f6                	je     800cde <strtol+0xe>
  800ce8:	3c 09                	cmp    $0x9,%al
  800cea:	74 f2                	je     800cde <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cec:	3c 2b                	cmp    $0x2b,%al
  800cee:	75 0a                	jne    800cfa <strtol+0x2a>
		s++;
  800cf0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cf3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf8:	eb 11                	jmp    800d0b <strtol+0x3b>
  800cfa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cff:	3c 2d                	cmp    $0x2d,%al
  800d01:	75 08                	jne    800d0b <strtol+0x3b>
		s++, neg = 1;
  800d03:	83 c1 01             	add    $0x1,%ecx
  800d06:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d0b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d11:	75 15                	jne    800d28 <strtol+0x58>
  800d13:	80 39 30             	cmpb   $0x30,(%ecx)
  800d16:	75 10                	jne    800d28 <strtol+0x58>
  800d18:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d1c:	75 7c                	jne    800d9a <strtol+0xca>
		s += 2, base = 16;
  800d1e:	83 c1 02             	add    $0x2,%ecx
  800d21:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d26:	eb 16                	jmp    800d3e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800d28:	85 db                	test   %ebx,%ebx
  800d2a:	75 12                	jne    800d3e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d31:	80 39 30             	cmpb   $0x30,(%ecx)
  800d34:	75 08                	jne    800d3e <strtol+0x6e>
		s++, base = 8;
  800d36:	83 c1 01             	add    $0x1,%ecx
  800d39:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d43:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d46:	0f b6 11             	movzbl (%ecx),%edx
  800d49:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d4c:	89 f3                	mov    %esi,%ebx
  800d4e:	80 fb 09             	cmp    $0x9,%bl
  800d51:	77 08                	ja     800d5b <strtol+0x8b>
			dig = *s - '0';
  800d53:	0f be d2             	movsbl %dl,%edx
  800d56:	83 ea 30             	sub    $0x30,%edx
  800d59:	eb 22                	jmp    800d7d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d5b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d5e:	89 f3                	mov    %esi,%ebx
  800d60:	80 fb 19             	cmp    $0x19,%bl
  800d63:	77 08                	ja     800d6d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d65:	0f be d2             	movsbl %dl,%edx
  800d68:	83 ea 57             	sub    $0x57,%edx
  800d6b:	eb 10                	jmp    800d7d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d6d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d70:	89 f3                	mov    %esi,%ebx
  800d72:	80 fb 19             	cmp    $0x19,%bl
  800d75:	77 16                	ja     800d8d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d77:	0f be d2             	movsbl %dl,%edx
  800d7a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d7d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d80:	7d 0b                	jge    800d8d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d82:	83 c1 01             	add    $0x1,%ecx
  800d85:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d89:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d8b:	eb b9                	jmp    800d46 <strtol+0x76>

	if (endptr)
  800d8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d91:	74 0d                	je     800da0 <strtol+0xd0>
		*endptr = (char *) s;
  800d93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d96:	89 0e                	mov    %ecx,(%esi)
  800d98:	eb 06                	jmp    800da0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d9a:	85 db                	test   %ebx,%ebx
  800d9c:	74 98                	je     800d36 <strtol+0x66>
  800d9e:	eb 9e                	jmp    800d3e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800da0:	89 c2                	mov    %eax,%edx
  800da2:	f7 da                	neg    %edx
  800da4:	85 ff                	test   %edi,%edi
  800da6:	0f 45 c2             	cmovne %edx,%eax
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 c3                	mov    %eax,%ebx
  800dc1:	89 c7                	mov    %eax,%edi
  800dc3:	89 c6                	mov    %eax,%esi
  800dc5:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_cgetc>:

int
sys_cgetc(void)
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
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddc:	89 d1                	mov    %edx,%ecx
  800dde:	89 d3                	mov    %edx,%ebx
  800de0:	89 d7                	mov    %edx,%edi
  800de2:	89 d6                	mov    %edx,%esi
  800de4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	b8 03 00 00 00       	mov    $0x3,%eax
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 17                	jle    800e24 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	50                   	push   %eax
  800e11:	6a 03                	push   $0x3
  800e13:	68 2f 24 80 00       	push   $0x80242f
  800e18:	6a 23                	push   $0x23
  800e1a:	68 4c 24 80 00       	push   $0x80244c
  800e1f:	e8 a8 f4 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e32:	ba 00 00 00 00       	mov    $0x0,%edx
  800e37:	b8 02 00 00 00       	mov    $0x2,%eax
  800e3c:	89 d1                	mov    %edx,%ecx
  800e3e:	89 d3                	mov    %edx,%ebx
  800e40:	89 d7                	mov    %edx,%edi
  800e42:	89 d6                	mov    %edx,%esi
  800e44:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e46:	5b                   	pop    %ebx
  800e47:	5e                   	pop    %esi
  800e48:	5f                   	pop    %edi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <sys_yield>:

void
sys_yield(void)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e51:	ba 00 00 00 00       	mov    $0x0,%edx
  800e56:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e5b:	89 d1                	mov    %edx,%ecx
  800e5d:	89 d3                	mov    %edx,%ebx
  800e5f:	89 d7                	mov    %edx,%edi
  800e61:	89 d6                	mov    %edx,%esi
  800e63:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e73:	be 00 00 00 00       	mov    $0x0,%esi
  800e78:	b8 04 00 00 00       	mov    $0x4,%eax
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e86:	89 f7                	mov    %esi,%edi
  800e88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	7e 17                	jle    800ea5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8e:	83 ec 0c             	sub    $0xc,%esp
  800e91:	50                   	push   %eax
  800e92:	6a 04                	push   $0x4
  800e94:	68 2f 24 80 00       	push   $0x80242f
  800e99:	6a 23                	push   $0x23
  800e9b:	68 4c 24 80 00       	push   $0x80244c
  800ea0:	e8 27 f4 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ea5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800eb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec7:	8b 75 18             	mov    0x18(%ebp),%esi
  800eca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 17                	jle    800ee7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	50                   	push   %eax
  800ed4:	6a 05                	push   $0x5
  800ed6:	68 2f 24 80 00       	push   $0x80242f
  800edb:	6a 23                	push   $0x23
  800edd:	68 4c 24 80 00       	push   $0x80244c
  800ee2:	e8 e5 f3 ff ff       	call   8002cc <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efd:	b8 06 00 00 00       	mov    $0x6,%eax
  800f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f05:	8b 55 08             	mov    0x8(%ebp),%edx
  800f08:	89 df                	mov    %ebx,%edi
  800f0a:	89 de                	mov    %ebx,%esi
  800f0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	7e 17                	jle    800f29 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	50                   	push   %eax
  800f16:	6a 06                	push   $0x6
  800f18:	68 2f 24 80 00       	push   $0x80242f
  800f1d:	6a 23                	push   $0x23
  800f1f:	68 4c 24 80 00       	push   $0x80244c
  800f24:	e8 a3 f3 ff ff       	call   8002cc <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3f:	b8 08 00 00 00       	mov    $0x8,%eax
  800f44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f47:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4a:	89 df                	mov    %ebx,%edi
  800f4c:	89 de                	mov    %ebx,%esi
  800f4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	7e 17                	jle    800f6b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	50                   	push   %eax
  800f58:	6a 08                	push   $0x8
  800f5a:	68 2f 24 80 00       	push   $0x80242f
  800f5f:	6a 23                	push   $0x23
  800f61:	68 4c 24 80 00       	push   $0x80244c
  800f66:	e8 61 f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f81:	b8 09 00 00 00       	mov    $0x9,%eax
  800f86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f89:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8c:	89 df                	mov    %ebx,%edi
  800f8e:	89 de                	mov    %ebx,%esi
  800f90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f92:	85 c0                	test   %eax,%eax
  800f94:	7e 17                	jle    800fad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	50                   	push   %eax
  800f9a:	6a 09                	push   $0x9
  800f9c:	68 2f 24 80 00       	push   $0x80242f
  800fa1:	6a 23                	push   $0x23
  800fa3:	68 4c 24 80 00       	push   $0x80244c
  800fa8:	e8 1f f3 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800fbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fce:	89 df                	mov    %ebx,%edi
  800fd0:	89 de                	mov    %ebx,%esi
  800fd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	7e 17                	jle    800fef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd8:	83 ec 0c             	sub    $0xc,%esp
  800fdb:	50                   	push   %eax
  800fdc:	6a 0a                	push   $0xa
  800fde:	68 2f 24 80 00       	push   $0x80242f
  800fe3:	6a 23                	push   $0x23
  800fe5:	68 4c 24 80 00       	push   $0x80244c
  800fea:	e8 dd f2 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff2:	5b                   	pop    %ebx
  800ff3:	5e                   	pop    %esi
  800ff4:	5f                   	pop    %edi
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ffd:	be 00 00 00 00       	mov    $0x0,%esi
  801002:	b8 0c 00 00 00       	mov    $0xc,%eax
  801007:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100a:	8b 55 08             	mov    0x8(%ebp),%edx
  80100d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801010:	8b 7d 14             	mov    0x14(%ebp),%edi
  801013:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801023:	b9 00 00 00 00       	mov    $0x0,%ecx
  801028:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102d:	8b 55 08             	mov    0x8(%ebp),%edx
  801030:	89 cb                	mov    %ecx,%ebx
  801032:	89 cf                	mov    %ecx,%edi
  801034:	89 ce                	mov    %ecx,%esi
  801036:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801038:	85 c0                	test   %eax,%eax
  80103a:	7e 17                	jle    801053 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	50                   	push   %eax
  801040:	6a 0d                	push   $0xd
  801042:	68 2f 24 80 00       	push   $0x80242f
  801047:	6a 23                	push   $0x23
  801049:	68 4c 24 80 00       	push   $0x80244c
  80104e:	e8 79 f2 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801053:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80105e:	8b 45 08             	mov    0x8(%ebp),%eax
  801061:	05 00 00 00 30       	add    $0x30000000,%eax
  801066:	c1 e8 0c             	shr    $0xc,%eax
}
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
  801071:	05 00 00 00 30       	add    $0x30000000,%eax
  801076:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80107b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801088:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80108d:	89 c2                	mov    %eax,%edx
  80108f:	c1 ea 16             	shr    $0x16,%edx
  801092:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801099:	f6 c2 01             	test   $0x1,%dl
  80109c:	74 11                	je     8010af <fd_alloc+0x2d>
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	c1 ea 0c             	shr    $0xc,%edx
  8010a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010aa:	f6 c2 01             	test   $0x1,%dl
  8010ad:	75 09                	jne    8010b8 <fd_alloc+0x36>
			*fd_store = fd;
  8010af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b6:	eb 17                	jmp    8010cf <fd_alloc+0x4d>
  8010b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010c2:	75 c9                	jne    80108d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d7:	83 f8 1f             	cmp    $0x1f,%eax
  8010da:	77 36                	ja     801112 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010dc:	c1 e0 0c             	shl    $0xc,%eax
  8010df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e4:	89 c2                	mov    %eax,%edx
  8010e6:	c1 ea 16             	shr    $0x16,%edx
  8010e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f0:	f6 c2 01             	test   $0x1,%dl
  8010f3:	74 24                	je     801119 <fd_lookup+0x48>
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	c1 ea 0c             	shr    $0xc,%edx
  8010fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801101:	f6 c2 01             	test   $0x1,%dl
  801104:	74 1a                	je     801120 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801106:	8b 55 0c             	mov    0xc(%ebp),%edx
  801109:	89 02                	mov    %eax,(%edx)
	return 0;
  80110b:	b8 00 00 00 00       	mov    $0x0,%eax
  801110:	eb 13                	jmp    801125 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801112:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801117:	eb 0c                	jmp    801125 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801119:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111e:	eb 05                	jmp    801125 <fd_lookup+0x54>
  801120:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801130:	ba dc 24 80 00       	mov    $0x8024dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801135:	eb 13                	jmp    80114a <dev_lookup+0x23>
  801137:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80113a:	39 08                	cmp    %ecx,(%eax)
  80113c:	75 0c                	jne    80114a <dev_lookup+0x23>
			*dev = devtab[i];
  80113e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801141:	89 01                	mov    %eax,(%ecx)
			return 0;
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
  801148:	eb 2e                	jmp    801178 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80114a:	8b 02                	mov    (%edx),%eax
  80114c:	85 c0                	test   %eax,%eax
  80114e:	75 e7                	jne    801137 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801150:	a1 04 44 80 00       	mov    0x804404,%eax
  801155:	8b 40 48             	mov    0x48(%eax),%eax
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	51                   	push   %ecx
  80115c:	50                   	push   %eax
  80115d:	68 5c 24 80 00       	push   $0x80245c
  801162:	e8 3e f2 ff ff       	call   8003a5 <cprintf>
	*dev = 0;
  801167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
  80117f:	83 ec 10             	sub    $0x10,%esp
  801182:	8b 75 08             	mov    0x8(%ebp),%esi
  801185:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801188:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118b:	50                   	push   %eax
  80118c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801192:	c1 e8 0c             	shr    $0xc,%eax
  801195:	50                   	push   %eax
  801196:	e8 36 ff ff ff       	call   8010d1 <fd_lookup>
  80119b:	83 c4 08             	add    $0x8,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 05                	js     8011a7 <fd_close+0x2d>
	    || fd != fd2)
  8011a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011a5:	74 0c                	je     8011b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011a7:	84 db                	test   %bl,%bl
  8011a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ae:	0f 44 c2             	cmove  %edx,%eax
  8011b1:	eb 41                	jmp    8011f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	ff 36                	pushl  (%esi)
  8011bc:	e8 66 ff ff ff       	call   801127 <dev_lookup>
  8011c1:	89 c3                	mov    %eax,%ebx
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 1a                	js     8011e4 <fd_close+0x6a>
		if (dev->dev_close)
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	74 0b                	je     8011e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	56                   	push   %esi
  8011dd:	ff d0                	call   *%eax
  8011df:	89 c3                	mov    %eax,%ebx
  8011e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	56                   	push   %esi
  8011e8:	6a 00                	push   $0x0
  8011ea:	e8 00 fd ff ff       	call   800eef <sys_page_unmap>
	return r;
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	89 d8                	mov    %ebx,%eax
}
  8011f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f7:	5b                   	pop    %ebx
  8011f8:	5e                   	pop    %esi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	ff 75 08             	pushl  0x8(%ebp)
  801208:	e8 c4 fe ff ff       	call   8010d1 <fd_lookup>
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 10                	js     801224 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	6a 01                	push   $0x1
  801219:	ff 75 f4             	pushl  -0xc(%ebp)
  80121c:	e8 59 ff ff ff       	call   80117a <fd_close>
  801221:	83 c4 10             	add    $0x10,%esp
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <close_all>:

void
close_all(void)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	53                   	push   %ebx
  801236:	e8 c0 ff ff ff       	call   8011fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80123b:	83 c3 01             	add    $0x1,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	83 fb 20             	cmp    $0x20,%ebx
  801244:	75 ec                	jne    801232 <close_all+0xc>
		close(i);
}
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 2c             	sub    $0x2c,%esp
  801254:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801257:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 75 08             	pushl  0x8(%ebp)
  80125e:	e8 6e fe ff ff       	call   8010d1 <fd_lookup>
  801263:	83 c4 08             	add    $0x8,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	0f 88 c1 00 00 00    	js     80132f <dup+0xe4>
		return r;
	close(newfdnum);
  80126e:	83 ec 0c             	sub    $0xc,%esp
  801271:	56                   	push   %esi
  801272:	e8 84 ff ff ff       	call   8011fb <close>

	newfd = INDEX2FD(newfdnum);
  801277:	89 f3                	mov    %esi,%ebx
  801279:	c1 e3 0c             	shl    $0xc,%ebx
  80127c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801282:	83 c4 04             	add    $0x4,%esp
  801285:	ff 75 e4             	pushl  -0x1c(%ebp)
  801288:	e8 de fd ff ff       	call   80106b <fd2data>
  80128d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80128f:	89 1c 24             	mov    %ebx,(%esp)
  801292:	e8 d4 fd ff ff       	call   80106b <fd2data>
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80129d:	89 f8                	mov    %edi,%eax
  80129f:	c1 e8 16             	shr    $0x16,%eax
  8012a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a9:	a8 01                	test   $0x1,%al
  8012ab:	74 37                	je     8012e4 <dup+0x99>
  8012ad:	89 f8                	mov    %edi,%eax
  8012af:	c1 e8 0c             	shr    $0xc,%eax
  8012b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	74 26                	je     8012e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012cd:	50                   	push   %eax
  8012ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012d1:	6a 00                	push   $0x0
  8012d3:	57                   	push   %edi
  8012d4:	6a 00                	push   $0x0
  8012d6:	e8 d2 fb ff ff       	call   800ead <sys_page_map>
  8012db:	89 c7                	mov    %eax,%edi
  8012dd:	83 c4 20             	add    $0x20,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 2e                	js     801312 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012e7:	89 d0                	mov    %edx,%eax
  8012e9:	c1 e8 0c             	shr    $0xc,%eax
  8012ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fb:	50                   	push   %eax
  8012fc:	53                   	push   %ebx
  8012fd:	6a 00                	push   $0x0
  8012ff:	52                   	push   %edx
  801300:	6a 00                	push   $0x0
  801302:	e8 a6 fb ff ff       	call   800ead <sys_page_map>
  801307:	89 c7                	mov    %eax,%edi
  801309:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80130c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130e:	85 ff                	test   %edi,%edi
  801310:	79 1d                	jns    80132f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	53                   	push   %ebx
  801316:	6a 00                	push   $0x0
  801318:	e8 d2 fb ff ff       	call   800eef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80131d:	83 c4 08             	add    $0x8,%esp
  801320:	ff 75 d4             	pushl  -0x2c(%ebp)
  801323:	6a 00                	push   $0x0
  801325:	e8 c5 fb ff ff       	call   800eef <sys_page_unmap>
	return r;
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	89 f8                	mov    %edi,%eax
}
  80132f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	53                   	push   %ebx
  80133b:	83 ec 14             	sub    $0x14,%esp
  80133e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801341:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	53                   	push   %ebx
  801346:	e8 86 fd ff ff       	call   8010d1 <fd_lookup>
  80134b:	83 c4 08             	add    $0x8,%esp
  80134e:	89 c2                	mov    %eax,%edx
  801350:	85 c0                	test   %eax,%eax
  801352:	78 6d                	js     8013c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135e:	ff 30                	pushl  (%eax)
  801360:	e8 c2 fd ff ff       	call   801127 <dev_lookup>
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 4c                	js     8013b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80136c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80136f:	8b 42 08             	mov    0x8(%edx),%eax
  801372:	83 e0 03             	and    $0x3,%eax
  801375:	83 f8 01             	cmp    $0x1,%eax
  801378:	75 21                	jne    80139b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137a:	a1 04 44 80 00       	mov    0x804404,%eax
  80137f:	8b 40 48             	mov    0x48(%eax),%eax
  801382:	83 ec 04             	sub    $0x4,%esp
  801385:	53                   	push   %ebx
  801386:	50                   	push   %eax
  801387:	68 a0 24 80 00       	push   $0x8024a0
  80138c:	e8 14 f0 ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801399:	eb 26                	jmp    8013c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139e:	8b 40 08             	mov    0x8(%eax),%eax
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	74 17                	je     8013bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	ff 75 10             	pushl  0x10(%ebp)
  8013ab:	ff 75 0c             	pushl  0xc(%ebp)
  8013ae:	52                   	push   %edx
  8013af:	ff d0                	call   *%eax
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	eb 09                	jmp    8013c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b8:	89 c2                	mov    %eax,%edx
  8013ba:	eb 05                	jmp    8013c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013c1:	89 d0                	mov    %edx,%eax
  8013c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	57                   	push   %edi
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013dc:	eb 21                	jmp    8013ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013de:	83 ec 04             	sub    $0x4,%esp
  8013e1:	89 f0                	mov    %esi,%eax
  8013e3:	29 d8                	sub    %ebx,%eax
  8013e5:	50                   	push   %eax
  8013e6:	89 d8                	mov    %ebx,%eax
  8013e8:	03 45 0c             	add    0xc(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	57                   	push   %edi
  8013ed:	e8 45 ff ff ff       	call   801337 <read>
		if (m < 0)
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 10                	js     801409 <readn+0x41>
			return m;
		if (m == 0)
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	74 0a                	je     801407 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fd:	01 c3                	add    %eax,%ebx
  8013ff:	39 f3                	cmp    %esi,%ebx
  801401:	72 db                	jb     8013de <readn+0x16>
  801403:	89 d8                	mov    %ebx,%eax
  801405:	eb 02                	jmp    801409 <readn+0x41>
  801407:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801409:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140c:	5b                   	pop    %ebx
  80140d:	5e                   	pop    %esi
  80140e:	5f                   	pop    %edi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	53                   	push   %ebx
  801415:	83 ec 14             	sub    $0x14,%esp
  801418:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	53                   	push   %ebx
  801420:	e8 ac fc ff ff       	call   8010d1 <fd_lookup>
  801425:	83 c4 08             	add    $0x8,%esp
  801428:	89 c2                	mov    %eax,%edx
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 68                	js     801496 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801438:	ff 30                	pushl  (%eax)
  80143a:	e8 e8 fc ff ff       	call   801127 <dev_lookup>
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 47                	js     80148d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801446:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801449:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144d:	75 21                	jne    801470 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80144f:	a1 04 44 80 00       	mov    0x804404,%eax
  801454:	8b 40 48             	mov    0x48(%eax),%eax
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	53                   	push   %ebx
  80145b:	50                   	push   %eax
  80145c:	68 bc 24 80 00       	push   $0x8024bc
  801461:	e8 3f ef ff ff       	call   8003a5 <cprintf>
		return -E_INVAL;
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80146e:	eb 26                	jmp    801496 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801470:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801473:	8b 52 0c             	mov    0xc(%edx),%edx
  801476:	85 d2                	test   %edx,%edx
  801478:	74 17                	je     801491 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	ff 75 10             	pushl  0x10(%ebp)
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	50                   	push   %eax
  801484:	ff d2                	call   *%edx
  801486:	89 c2                	mov    %eax,%edx
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb 09                	jmp    801496 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	eb 05                	jmp    801496 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801491:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801496:	89 d0                	mov    %edx,%eax
  801498:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <seek>:

int
seek(int fdnum, off_t offset)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	ff 75 08             	pushl  0x8(%ebp)
  8014aa:	e8 22 fc ff ff       	call   8010d1 <fd_lookup>
  8014af:	83 c4 08             	add    $0x8,%esp
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 0e                	js     8014c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	53                   	push   %ebx
  8014ca:	83 ec 14             	sub    $0x14,%esp
  8014cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	53                   	push   %ebx
  8014d5:	e8 f7 fb ff ff       	call   8010d1 <fd_lookup>
  8014da:	83 c4 08             	add    $0x8,%esp
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 65                	js     801548 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e9:	50                   	push   %eax
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	ff 30                	pushl  (%eax)
  8014ef:	e8 33 fc ff ff       	call   801127 <dev_lookup>
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 44                	js     80153f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801502:	75 21                	jne    801525 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801504:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801509:	8b 40 48             	mov    0x48(%eax),%eax
  80150c:	83 ec 04             	sub    $0x4,%esp
  80150f:	53                   	push   %ebx
  801510:	50                   	push   %eax
  801511:	68 7c 24 80 00       	push   $0x80247c
  801516:	e8 8a ee ff ff       	call   8003a5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801523:	eb 23                	jmp    801548 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801525:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801528:	8b 52 18             	mov    0x18(%edx),%edx
  80152b:	85 d2                	test   %edx,%edx
  80152d:	74 14                	je     801543 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	ff 75 0c             	pushl  0xc(%ebp)
  801535:	50                   	push   %eax
  801536:	ff d2                	call   *%edx
  801538:	89 c2                	mov    %eax,%edx
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	eb 09                	jmp    801548 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153f:	89 c2                	mov    %eax,%edx
  801541:	eb 05                	jmp    801548 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801543:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801548:	89 d0                	mov    %edx,%eax
  80154a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	53                   	push   %ebx
  801553:	83 ec 14             	sub    $0x14,%esp
  801556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801559:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	ff 75 08             	pushl  0x8(%ebp)
  801560:	e8 6c fb ff ff       	call   8010d1 <fd_lookup>
  801565:	83 c4 08             	add    $0x8,%esp
  801568:	89 c2                	mov    %eax,%edx
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 58                	js     8015c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801578:	ff 30                	pushl  (%eax)
  80157a:	e8 a8 fb ff ff       	call   801127 <dev_lookup>
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 37                	js     8015bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801586:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801589:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80158d:	74 32                	je     8015c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80158f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801592:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801599:	00 00 00 
	stat->st_isdir = 0;
  80159c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a3:	00 00 00 
	stat->st_dev = dev;
  8015a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b3:	ff 50 14             	call   *0x14(%eax)
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	eb 09                	jmp    8015c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	eb 05                	jmp    8015c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015c6:	89 d0                	mov    %edx,%eax
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	6a 00                	push   $0x0
  8015d7:	ff 75 08             	pushl  0x8(%ebp)
  8015da:	e8 dc 01 00 00       	call   8017bb <open>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 1b                	js     801603 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ee:	50                   	push   %eax
  8015ef:	e8 5b ff ff ff       	call   80154f <fstat>
  8015f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f6:	89 1c 24             	mov    %ebx,(%esp)
  8015f9:	e8 fd fb ff ff       	call   8011fb <close>
	return r;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	89 f0                	mov    %esi,%eax
}
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	89 c6                	mov    %eax,%esi
  801611:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801613:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80161a:	75 12                	jne    80162e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	6a 01                	push   $0x1
  801621:	e8 45 07 00 00       	call   801d6b <ipc_find_env>
  801626:	a3 00 44 80 00       	mov    %eax,0x804400
  80162b:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80162e:	6a 07                	push   $0x7
  801630:	68 00 50 80 00       	push   $0x805000
  801635:	56                   	push   %esi
  801636:	ff 35 00 44 80 00    	pushl  0x804400
  80163c:	e8 e7 06 00 00       	call   801d28 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801641:	83 c4 0c             	add    $0xc,%esp
  801644:	6a 00                	push   $0x0
  801646:	53                   	push   %ebx
  801647:	6a 00                	push   $0x0
  801649:	e8 7d 06 00 00       	call   801ccb <ipc_recv>
}
  80164e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80165b:	8b 45 08             	mov    0x8(%ebp),%eax
  80165e:	8b 40 0c             	mov    0xc(%eax),%eax
  801661:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801666:	8b 45 0c             	mov    0xc(%ebp),%eax
  801669:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80166e:	ba 00 00 00 00       	mov    $0x0,%edx
  801673:	b8 02 00 00 00       	mov    $0x2,%eax
  801678:	e8 8d ff ff ff       	call   80160a <fsipc>
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801685:	8b 45 08             	mov    0x8(%ebp),%eax
  801688:	8b 40 0c             	mov    0xc(%eax),%eax
  80168b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801690:	ba 00 00 00 00       	mov    $0x0,%edx
  801695:	b8 06 00 00 00       	mov    $0x6,%eax
  80169a:	e8 6b ff ff ff       	call   80160a <fsipc>
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 04             	sub    $0x4,%esp
  8016a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c0:	e8 45 ff ff ff       	call   80160a <fsipc>
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 2c                	js     8016f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	68 00 50 80 00       	push   $0x805000
  8016d1:	53                   	push   %ebx
  8016d2:	e8 90 f3 ff ff       	call   800a67 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8016dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	83 ec 0c             	sub    $0xc,%esp
  801700:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801703:	8b 55 08             	mov    0x8(%ebp),%edx
  801706:	8b 52 0c             	mov    0xc(%edx),%edx
  801709:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80170f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801714:	50                   	push   %eax
  801715:	ff 75 0c             	pushl  0xc(%ebp)
  801718:	68 08 50 80 00       	push   $0x805008
  80171d:	e8 d7 f4 ff ff       	call   800bf9 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801722:	ba 00 00 00 00       	mov    $0x0,%edx
  801727:	b8 04 00 00 00       	mov    $0x4,%eax
  80172c:	e8 d9 fe ff ff       	call   80160a <fsipc>
	//panic("devfile_write not implemented");
}
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	8b 40 0c             	mov    0xc(%eax),%eax
  801741:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801746:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80174c:	ba 00 00 00 00       	mov    $0x0,%edx
  801751:	b8 03 00 00 00       	mov    $0x3,%eax
  801756:	e8 af fe ff ff       	call   80160a <fsipc>
  80175b:	89 c3                	mov    %eax,%ebx
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 51                	js     8017b2 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801761:	39 c6                	cmp    %eax,%esi
  801763:	73 19                	jae    80177e <devfile_read+0x4b>
  801765:	68 ec 24 80 00       	push   $0x8024ec
  80176a:	68 f3 24 80 00       	push   $0x8024f3
  80176f:	68 80 00 00 00       	push   $0x80
  801774:	68 08 25 80 00       	push   $0x802508
  801779:	e8 4e eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  80177e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801783:	7e 19                	jle    80179e <devfile_read+0x6b>
  801785:	68 13 25 80 00       	push   $0x802513
  80178a:	68 f3 24 80 00       	push   $0x8024f3
  80178f:	68 81 00 00 00       	push   $0x81
  801794:	68 08 25 80 00       	push   $0x802508
  801799:	e8 2e eb ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80179e:	83 ec 04             	sub    $0x4,%esp
  8017a1:	50                   	push   %eax
  8017a2:	68 00 50 80 00       	push   $0x805000
  8017a7:	ff 75 0c             	pushl  0xc(%ebp)
  8017aa:	e8 4a f4 ff ff       	call   800bf9 <memmove>
	return r;
  8017af:	83 c4 10             	add    $0x10,%esp
}
  8017b2:	89 d8                	mov    %ebx,%eax
  8017b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b7:	5b                   	pop    %ebx
  8017b8:	5e                   	pop    %esi
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	53                   	push   %ebx
  8017bf:	83 ec 20             	sub    $0x20,%esp
  8017c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c5:	53                   	push   %ebx
  8017c6:	e8 63 f2 ff ff       	call   800a2e <strlen>
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d3:	7f 67                	jg     80183c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d5:	83 ec 0c             	sub    $0xc,%esp
  8017d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017db:	50                   	push   %eax
  8017dc:	e8 a1 f8 ff ff       	call   801082 <fd_alloc>
  8017e1:	83 c4 10             	add    $0x10,%esp
		return r;
  8017e4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 57                	js     801841 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	53                   	push   %ebx
  8017ee:	68 00 50 80 00       	push   $0x805000
  8017f3:	e8 6f f2 ff ff       	call   800a67 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fb:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801800:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801803:	b8 01 00 00 00       	mov    $0x1,%eax
  801808:	e8 fd fd ff ff       	call   80160a <fsipc>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	85 c0                	test   %eax,%eax
  801814:	79 14                	jns    80182a <open+0x6f>
		
		fd_close(fd, 0);
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	6a 00                	push   $0x0
  80181b:	ff 75 f4             	pushl  -0xc(%ebp)
  80181e:	e8 57 f9 ff ff       	call   80117a <fd_close>
		return r;
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	89 da                	mov    %ebx,%edx
  801828:	eb 17                	jmp    801841 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	ff 75 f4             	pushl  -0xc(%ebp)
  801830:	e8 26 f8 ff ff       	call   80105b <fd2num>
  801835:	89 c2                	mov    %eax,%edx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	eb 05                	jmp    801841 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80183c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801841:	89 d0                	mov    %edx,%eax
  801843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80184e:	ba 00 00 00 00       	mov    $0x0,%edx
  801853:	b8 08 00 00 00       	mov    $0x8,%eax
  801858:	e8 ad fd ff ff       	call   80160a <fsipc>
}
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80185f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801863:	7e 37                	jle    80189c <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	53                   	push   %ebx
  801869:	83 ec 08             	sub    $0x8,%esp
  80186c:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80186e:	ff 70 04             	pushl  0x4(%eax)
  801871:	8d 40 10             	lea    0x10(%eax),%eax
  801874:	50                   	push   %eax
  801875:	ff 33                	pushl  (%ebx)
  801877:	e8 95 fb ff ff       	call   801411 <write>
		if (result > 0)
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	7e 03                	jle    801886 <writebuf+0x27>
			b->result += result;
  801883:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801886:	3b 43 04             	cmp    0x4(%ebx),%eax
  801889:	74 0d                	je     801898 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80188b:	85 c0                	test   %eax,%eax
  80188d:	ba 00 00 00 00       	mov    $0x0,%edx
  801892:	0f 4f c2             	cmovg  %edx,%eax
  801895:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189b:	c9                   	leave  
  80189c:	f3 c3                	repz ret 

0080189e <putch>:

static void
putch(int ch, void *thunk)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	53                   	push   %ebx
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018a8:	8b 53 04             	mov    0x4(%ebx),%edx
  8018ab:	8d 42 01             	lea    0x1(%edx),%eax
  8018ae:	89 43 04             	mov    %eax,0x4(%ebx)
  8018b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b4:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018b8:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018bd:	75 0e                	jne    8018cd <putch+0x2f>
		writebuf(b);
  8018bf:	89 d8                	mov    %ebx,%eax
  8018c1:	e8 99 ff ff ff       	call   80185f <writebuf>
		b->idx = 0;
  8018c6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018cd:	83 c4 04             	add    $0x4,%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018e5:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018ec:	00 00 00 
	b.result = 0;
  8018ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018f6:	00 00 00 
	b.error = 1;
  8018f9:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801900:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801903:	ff 75 10             	pushl  0x10(%ebp)
  801906:	ff 75 0c             	pushl  0xc(%ebp)
  801909:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80190f:	50                   	push   %eax
  801910:	68 9e 18 80 00       	push   $0x80189e
  801915:	e8 c2 eb ff ff       	call   8004dc <vprintfmt>
	if (b.idx > 0)
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801924:	7e 0b                	jle    801931 <vfprintf+0x5e>
		writebuf(&b);
  801926:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80192c:	e8 2e ff ff ff       	call   80185f <writebuf>

	return (b.result ? b.result : b.error);
  801931:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801937:	85 c0                	test   %eax,%eax
  801939:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801948:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80194b:	50                   	push   %eax
  80194c:	ff 75 0c             	pushl  0xc(%ebp)
  80194f:	ff 75 08             	pushl  0x8(%ebp)
  801952:	e8 7c ff ff ff       	call   8018d3 <vfprintf>
	va_end(ap);

	return cnt;
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <printf>:

int
printf(const char *fmt, ...)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80195f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801962:	50                   	push   %eax
  801963:	ff 75 08             	pushl  0x8(%ebp)
  801966:	6a 01                	push   $0x1
  801968:	e8 66 ff ff ff       	call   8018d3 <vfprintf>
	va_end(ap);

	return cnt;
}
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	ff 75 08             	pushl  0x8(%ebp)
  80197d:	e8 e9 f6 ff ff       	call   80106b <fd2data>
  801982:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801984:	83 c4 08             	add    $0x8,%esp
  801987:	68 1f 25 80 00       	push   $0x80251f
  80198c:	53                   	push   %ebx
  80198d:	e8 d5 f0 ff ff       	call   800a67 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801992:	8b 46 04             	mov    0x4(%esi),%eax
  801995:	2b 06                	sub    (%esi),%eax
  801997:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80199d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a4:	00 00 00 
	stat->st_dev = &devpipe;
  8019a7:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019ae:	30 80 00 
	return 0;
}
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b9:	5b                   	pop    %ebx
  8019ba:	5e                   	pop    %esi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c7:	53                   	push   %ebx
  8019c8:	6a 00                	push   $0x0
  8019ca:	e8 20 f5 ff ff       	call   800eef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019cf:	89 1c 24             	mov    %ebx,(%esp)
  8019d2:	e8 94 f6 ff ff       	call   80106b <fd2data>
  8019d7:	83 c4 08             	add    $0x8,%esp
  8019da:	50                   	push   %eax
  8019db:	6a 00                	push   $0x0
  8019dd:	e8 0d f5 ff ff       	call   800eef <sys_page_unmap>
}
  8019e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	57                   	push   %edi
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 1c             	sub    $0x1c,%esp
  8019f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019f3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f5:	a1 04 44 80 00       	mov    0x804404,%eax
  8019fa:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019fd:	83 ec 0c             	sub    $0xc,%esp
  801a00:	ff 75 e0             	pushl  -0x20(%ebp)
  801a03:	e8 9c 03 00 00       	call   801da4 <pageref>
  801a08:	89 c3                	mov    %eax,%ebx
  801a0a:	89 3c 24             	mov    %edi,(%esp)
  801a0d:	e8 92 03 00 00       	call   801da4 <pageref>
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	39 c3                	cmp    %eax,%ebx
  801a17:	0f 94 c1             	sete   %cl
  801a1a:	0f b6 c9             	movzbl %cl,%ecx
  801a1d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a20:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a26:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a29:	39 ce                	cmp    %ecx,%esi
  801a2b:	74 1b                	je     801a48 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a2d:	39 c3                	cmp    %eax,%ebx
  801a2f:	75 c4                	jne    8019f5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a31:	8b 42 58             	mov    0x58(%edx),%eax
  801a34:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a37:	50                   	push   %eax
  801a38:	56                   	push   %esi
  801a39:	68 26 25 80 00       	push   $0x802526
  801a3e:	e8 62 e9 ff ff       	call   8003a5 <cprintf>
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	eb ad                	jmp    8019f5 <_pipeisclosed+0xe>
	}
}
  801a48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5f                   	pop    %edi
  801a51:	5d                   	pop    %ebp
  801a52:	c3                   	ret    

00801a53 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	57                   	push   %edi
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	83 ec 28             	sub    $0x28,%esp
  801a5c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a5f:	56                   	push   %esi
  801a60:	e8 06 f6 ff ff       	call   80106b <fd2data>
  801a65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	bf 00 00 00 00       	mov    $0x0,%edi
  801a6f:	eb 4b                	jmp    801abc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a71:	89 da                	mov    %ebx,%edx
  801a73:	89 f0                	mov    %esi,%eax
  801a75:	e8 6d ff ff ff       	call   8019e7 <_pipeisclosed>
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	75 48                	jne    801ac6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a7e:	e8 c8 f3 ff ff       	call   800e4b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a83:	8b 43 04             	mov    0x4(%ebx),%eax
  801a86:	8b 0b                	mov    (%ebx),%ecx
  801a88:	8d 51 20             	lea    0x20(%ecx),%edx
  801a8b:	39 d0                	cmp    %edx,%eax
  801a8d:	73 e2                	jae    801a71 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a92:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a96:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a99:	89 c2                	mov    %eax,%edx
  801a9b:	c1 fa 1f             	sar    $0x1f,%edx
  801a9e:	89 d1                	mov    %edx,%ecx
  801aa0:	c1 e9 1b             	shr    $0x1b,%ecx
  801aa3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aa6:	83 e2 1f             	and    $0x1f,%edx
  801aa9:	29 ca                	sub    %ecx,%edx
  801aab:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aaf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab3:	83 c0 01             	add    $0x1,%eax
  801ab6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab9:	83 c7 01             	add    $0x1,%edi
  801abc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801abf:	75 c2                	jne    801a83 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ac1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac4:	eb 05                	jmp    801acb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5f                   	pop    %edi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	57                   	push   %edi
  801ad7:	56                   	push   %esi
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 18             	sub    $0x18,%esp
  801adc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801adf:	57                   	push   %edi
  801ae0:	e8 86 f5 ff ff       	call   80106b <fd2data>
  801ae5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aef:	eb 3d                	jmp    801b2e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801af1:	85 db                	test   %ebx,%ebx
  801af3:	74 04                	je     801af9 <devpipe_read+0x26>
				return i;
  801af5:	89 d8                	mov    %ebx,%eax
  801af7:	eb 44                	jmp    801b3d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801af9:	89 f2                	mov    %esi,%edx
  801afb:	89 f8                	mov    %edi,%eax
  801afd:	e8 e5 fe ff ff       	call   8019e7 <_pipeisclosed>
  801b02:	85 c0                	test   %eax,%eax
  801b04:	75 32                	jne    801b38 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b06:	e8 40 f3 ff ff       	call   800e4b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b0b:	8b 06                	mov    (%esi),%eax
  801b0d:	3b 46 04             	cmp    0x4(%esi),%eax
  801b10:	74 df                	je     801af1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b12:	99                   	cltd   
  801b13:	c1 ea 1b             	shr    $0x1b,%edx
  801b16:	01 d0                	add    %edx,%eax
  801b18:	83 e0 1f             	and    $0x1f,%eax
  801b1b:	29 d0                	sub    %edx,%eax
  801b1d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b25:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b28:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2b:	83 c3 01             	add    $0x1,%ebx
  801b2e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b31:	75 d8                	jne    801b0b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b33:	8b 45 10             	mov    0x10(%ebp),%eax
  801b36:	eb 05                	jmp    801b3d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b38:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	56                   	push   %esi
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b50:	50                   	push   %eax
  801b51:	e8 2c f5 ff ff       	call   801082 <fd_alloc>
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	89 c2                	mov    %eax,%edx
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	0f 88 2c 01 00 00    	js     801c8f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b63:	83 ec 04             	sub    $0x4,%esp
  801b66:	68 07 04 00 00       	push   $0x407
  801b6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6e:	6a 00                	push   $0x0
  801b70:	e8 f5 f2 ff ff       	call   800e6a <sys_page_alloc>
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	89 c2                	mov    %eax,%edx
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	0f 88 0d 01 00 00    	js     801c8f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b88:	50                   	push   %eax
  801b89:	e8 f4 f4 ff ff       	call   801082 <fd_alloc>
  801b8e:	89 c3                	mov    %eax,%ebx
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 88 e2 00 00 00    	js     801c7d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9b:	83 ec 04             	sub    $0x4,%esp
  801b9e:	68 07 04 00 00       	push   $0x407
  801ba3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba6:	6a 00                	push   $0x0
  801ba8:	e8 bd f2 ff ff       	call   800e6a <sys_page_alloc>
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	0f 88 c3 00 00 00    	js     801c7d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc0:	e8 a6 f4 ff ff       	call   80106b <fd2data>
  801bc5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc7:	83 c4 0c             	add    $0xc,%esp
  801bca:	68 07 04 00 00       	push   $0x407
  801bcf:	50                   	push   %eax
  801bd0:	6a 00                	push   $0x0
  801bd2:	e8 93 f2 ff ff       	call   800e6a <sys_page_alloc>
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	0f 88 89 00 00 00    	js     801c6d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be4:	83 ec 0c             	sub    $0xc,%esp
  801be7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bea:	e8 7c f4 ff ff       	call   80106b <fd2data>
  801bef:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bf6:	50                   	push   %eax
  801bf7:	6a 00                	push   $0x0
  801bf9:	56                   	push   %esi
  801bfa:	6a 00                	push   $0x0
  801bfc:	e8 ac f2 ff ff       	call   800ead <sys_page_map>
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	83 c4 20             	add    $0x20,%esp
  801c06:	85 c0                	test   %eax,%eax
  801c08:	78 55                	js     801c5f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c13:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c1f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c28:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c34:	83 ec 0c             	sub    $0xc,%esp
  801c37:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3a:	e8 1c f4 ff ff       	call   80105b <fd2num>
  801c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c42:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c44:	83 c4 04             	add    $0x4,%esp
  801c47:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4a:	e8 0c f4 ff ff       	call   80105b <fd2num>
  801c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c52:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5d:	eb 30                	jmp    801c8f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c5f:	83 ec 08             	sub    $0x8,%esp
  801c62:	56                   	push   %esi
  801c63:	6a 00                	push   $0x0
  801c65:	e8 85 f2 ff ff       	call   800eef <sys_page_unmap>
  801c6a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c6d:	83 ec 08             	sub    $0x8,%esp
  801c70:	ff 75 f0             	pushl  -0x10(%ebp)
  801c73:	6a 00                	push   $0x0
  801c75:	e8 75 f2 ff ff       	call   800eef <sys_page_unmap>
  801c7a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c7d:	83 ec 08             	sub    $0x8,%esp
  801c80:	ff 75 f4             	pushl  -0xc(%ebp)
  801c83:	6a 00                	push   $0x0
  801c85:	e8 65 f2 ff ff       	call   800eef <sys_page_unmap>
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c8f:	89 d0                	mov    %edx,%eax
  801c91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca1:	50                   	push   %eax
  801ca2:	ff 75 08             	pushl  0x8(%ebp)
  801ca5:	e8 27 f4 ff ff       	call   8010d1 <fd_lookup>
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	85 c0                	test   %eax,%eax
  801caf:	78 18                	js     801cc9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cb1:	83 ec 0c             	sub    $0xc,%esp
  801cb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb7:	e8 af f3 ff ff       	call   80106b <fd2data>
	return _pipeisclosed(fd, p);
  801cbc:	89 c2                	mov    %eax,%edx
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	e8 21 fd ff ff       	call   8019e7 <_pipeisclosed>
  801cc6:	83 c4 10             	add    $0x10,%esp
}
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	56                   	push   %esi
  801ccf:	53                   	push   %ebx
  801cd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801cd3:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801cd6:	83 ec 0c             	sub    $0xc,%esp
  801cd9:	ff 75 0c             	pushl  0xc(%ebp)
  801cdc:	e8 39 f3 ff ff       	call   80101a <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	85 f6                	test   %esi,%esi
  801ce6:	74 1c                	je     801d04 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801ce8:	a1 04 44 80 00       	mov    0x804404,%eax
  801ced:	8b 40 78             	mov    0x78(%eax),%eax
  801cf0:	89 06                	mov    %eax,(%esi)
  801cf2:	eb 10                	jmp    801d04 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801cf4:	83 ec 0c             	sub    $0xc,%esp
  801cf7:	68 3e 25 80 00       	push   $0x80253e
  801cfc:	e8 a4 e6 ff ff       	call   8003a5 <cprintf>
  801d01:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801d04:	a1 04 44 80 00       	mov    0x804404,%eax
  801d09:	8b 50 74             	mov    0x74(%eax),%edx
  801d0c:	85 d2                	test   %edx,%edx
  801d0e:	74 e4                	je     801cf4 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801d10:	85 db                	test   %ebx,%ebx
  801d12:	74 05                	je     801d19 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801d14:	8b 40 74             	mov    0x74(%eax),%eax
  801d17:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d19:	a1 04 44 80 00       	mov    0x804404,%eax
  801d1e:	8b 40 70             	mov    0x70(%eax),%eax

}
  801d21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	57                   	push   %edi
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d34:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801d3a:	85 db                	test   %ebx,%ebx
  801d3c:	75 13                	jne    801d51 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801d3e:	6a 00                	push   $0x0
  801d40:	68 00 00 c0 ee       	push   $0xeec00000
  801d45:	56                   	push   %esi
  801d46:	57                   	push   %edi
  801d47:	e8 ab f2 ff ff       	call   800ff7 <sys_ipc_try_send>
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	eb 0e                	jmp    801d5f <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801d51:	ff 75 14             	pushl  0x14(%ebp)
  801d54:	53                   	push   %ebx
  801d55:	56                   	push   %esi
  801d56:	57                   	push   %edi
  801d57:	e8 9b f2 ff ff       	call   800ff7 <sys_ipc_try_send>
  801d5c:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	75 d7                	jne    801d3a <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d71:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d76:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d79:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d7f:	8b 52 50             	mov    0x50(%edx),%edx
  801d82:	39 ca                	cmp    %ecx,%edx
  801d84:	75 0d                	jne    801d93 <ipc_find_env+0x28>
			return envs[i].env_id;
  801d86:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d89:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d8e:	8b 40 48             	mov    0x48(%eax),%eax
  801d91:	eb 0f                	jmp    801da2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d93:	83 c0 01             	add    $0x1,%eax
  801d96:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d9b:	75 d9                	jne    801d76 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801daa:	89 d0                	mov    %edx,%eax
  801dac:	c1 e8 16             	shr    $0x16,%eax
  801daf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801db6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dbb:	f6 c1 01             	test   $0x1,%cl
  801dbe:	74 1d                	je     801ddd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801dc0:	c1 ea 0c             	shr    $0xc,%edx
  801dc3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dca:	f6 c2 01             	test   $0x1,%dl
  801dcd:	74 0e                	je     801ddd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dcf:	c1 ea 0c             	shr    $0xc,%edx
  801dd2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dd9:	ef 
  801dda:	0f b7 c0             	movzwl %ax,%eax
}
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    
  801ddf:	90                   	nop

00801de0 <__udivdi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	53                   	push   %ebx
  801de4:	83 ec 1c             	sub    $0x1c,%esp
  801de7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801deb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801def:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801df7:	85 f6                	test   %esi,%esi
  801df9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dfd:	89 ca                	mov    %ecx,%edx
  801dff:	89 f8                	mov    %edi,%eax
  801e01:	75 3d                	jne    801e40 <__udivdi3+0x60>
  801e03:	39 cf                	cmp    %ecx,%edi
  801e05:	0f 87 c5 00 00 00    	ja     801ed0 <__udivdi3+0xf0>
  801e0b:	85 ff                	test   %edi,%edi
  801e0d:	89 fd                	mov    %edi,%ebp
  801e0f:	75 0b                	jne    801e1c <__udivdi3+0x3c>
  801e11:	b8 01 00 00 00       	mov    $0x1,%eax
  801e16:	31 d2                	xor    %edx,%edx
  801e18:	f7 f7                	div    %edi
  801e1a:	89 c5                	mov    %eax,%ebp
  801e1c:	89 c8                	mov    %ecx,%eax
  801e1e:	31 d2                	xor    %edx,%edx
  801e20:	f7 f5                	div    %ebp
  801e22:	89 c1                	mov    %eax,%ecx
  801e24:	89 d8                	mov    %ebx,%eax
  801e26:	89 cf                	mov    %ecx,%edi
  801e28:	f7 f5                	div    %ebp
  801e2a:	89 c3                	mov    %eax,%ebx
  801e2c:	89 d8                	mov    %ebx,%eax
  801e2e:	89 fa                	mov    %edi,%edx
  801e30:	83 c4 1c             	add    $0x1c,%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5f                   	pop    %edi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    
  801e38:	90                   	nop
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	39 ce                	cmp    %ecx,%esi
  801e42:	77 74                	ja     801eb8 <__udivdi3+0xd8>
  801e44:	0f bd fe             	bsr    %esi,%edi
  801e47:	83 f7 1f             	xor    $0x1f,%edi
  801e4a:	0f 84 98 00 00 00    	je     801ee8 <__udivdi3+0x108>
  801e50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801e55:	89 f9                	mov    %edi,%ecx
  801e57:	89 c5                	mov    %eax,%ebp
  801e59:	29 fb                	sub    %edi,%ebx
  801e5b:	d3 e6                	shl    %cl,%esi
  801e5d:	89 d9                	mov    %ebx,%ecx
  801e5f:	d3 ed                	shr    %cl,%ebp
  801e61:	89 f9                	mov    %edi,%ecx
  801e63:	d3 e0                	shl    %cl,%eax
  801e65:	09 ee                	or     %ebp,%esi
  801e67:	89 d9                	mov    %ebx,%ecx
  801e69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e6d:	89 d5                	mov    %edx,%ebp
  801e6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e73:	d3 ed                	shr    %cl,%ebp
  801e75:	89 f9                	mov    %edi,%ecx
  801e77:	d3 e2                	shl    %cl,%edx
  801e79:	89 d9                	mov    %ebx,%ecx
  801e7b:	d3 e8                	shr    %cl,%eax
  801e7d:	09 c2                	or     %eax,%edx
  801e7f:	89 d0                	mov    %edx,%eax
  801e81:	89 ea                	mov    %ebp,%edx
  801e83:	f7 f6                	div    %esi
  801e85:	89 d5                	mov    %edx,%ebp
  801e87:	89 c3                	mov    %eax,%ebx
  801e89:	f7 64 24 0c          	mull   0xc(%esp)
  801e8d:	39 d5                	cmp    %edx,%ebp
  801e8f:	72 10                	jb     801ea1 <__udivdi3+0xc1>
  801e91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e95:	89 f9                	mov    %edi,%ecx
  801e97:	d3 e6                	shl    %cl,%esi
  801e99:	39 c6                	cmp    %eax,%esi
  801e9b:	73 07                	jae    801ea4 <__udivdi3+0xc4>
  801e9d:	39 d5                	cmp    %edx,%ebp
  801e9f:	75 03                	jne    801ea4 <__udivdi3+0xc4>
  801ea1:	83 eb 01             	sub    $0x1,%ebx
  801ea4:	31 ff                	xor    %edi,%edi
  801ea6:	89 d8                	mov    %ebx,%eax
  801ea8:	89 fa                	mov    %edi,%edx
  801eaa:	83 c4 1c             	add    $0x1c,%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5f                   	pop    %edi
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    
  801eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801eb8:	31 ff                	xor    %edi,%edi
  801eba:	31 db                	xor    %ebx,%ebx
  801ebc:	89 d8                	mov    %ebx,%eax
  801ebe:	89 fa                	mov    %edi,%edx
  801ec0:	83 c4 1c             	add    $0x1c,%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    
  801ec8:	90                   	nop
  801ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed0:	89 d8                	mov    %ebx,%eax
  801ed2:	f7 f7                	div    %edi
  801ed4:	31 ff                	xor    %edi,%edi
  801ed6:	89 c3                	mov    %eax,%ebx
  801ed8:	89 d8                	mov    %ebx,%eax
  801eda:	89 fa                	mov    %edi,%edx
  801edc:	83 c4 1c             	add    $0x1c,%esp
  801edf:	5b                   	pop    %ebx
  801ee0:	5e                   	pop    %esi
  801ee1:	5f                   	pop    %edi
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    
  801ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ee8:	39 ce                	cmp    %ecx,%esi
  801eea:	72 0c                	jb     801ef8 <__udivdi3+0x118>
  801eec:	31 db                	xor    %ebx,%ebx
  801eee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ef2:	0f 87 34 ff ff ff    	ja     801e2c <__udivdi3+0x4c>
  801ef8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801efd:	e9 2a ff ff ff       	jmp    801e2c <__udivdi3+0x4c>
  801f02:	66 90                	xchg   %ax,%ax
  801f04:	66 90                	xchg   %ax,%ax
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	66 90                	xchg   %ax,%ax
  801f0a:	66 90                	xchg   %ax,%ax
  801f0c:	66 90                	xchg   %ax,%ax
  801f0e:	66 90                	xchg   %ax,%ax

00801f10 <__umoddi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	83 ec 1c             	sub    $0x1c,%esp
  801f17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f27:	85 d2                	test   %edx,%edx
  801f29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f31:	89 f3                	mov    %esi,%ebx
  801f33:	89 3c 24             	mov    %edi,(%esp)
  801f36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f3a:	75 1c                	jne    801f58 <__umoddi3+0x48>
  801f3c:	39 f7                	cmp    %esi,%edi
  801f3e:	76 50                	jbe    801f90 <__umoddi3+0x80>
  801f40:	89 c8                	mov    %ecx,%eax
  801f42:	89 f2                	mov    %esi,%edx
  801f44:	f7 f7                	div    %edi
  801f46:	89 d0                	mov    %edx,%eax
  801f48:	31 d2                	xor    %edx,%edx
  801f4a:	83 c4 1c             	add    $0x1c,%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    
  801f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f58:	39 f2                	cmp    %esi,%edx
  801f5a:	89 d0                	mov    %edx,%eax
  801f5c:	77 52                	ja     801fb0 <__umoddi3+0xa0>
  801f5e:	0f bd ea             	bsr    %edx,%ebp
  801f61:	83 f5 1f             	xor    $0x1f,%ebp
  801f64:	75 5a                	jne    801fc0 <__umoddi3+0xb0>
  801f66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801f6a:	0f 82 e0 00 00 00    	jb     802050 <__umoddi3+0x140>
  801f70:	39 0c 24             	cmp    %ecx,(%esp)
  801f73:	0f 86 d7 00 00 00    	jbe    802050 <__umoddi3+0x140>
  801f79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f81:	83 c4 1c             	add    $0x1c,%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5e                   	pop    %esi
  801f86:	5f                   	pop    %edi
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	85 ff                	test   %edi,%edi
  801f92:	89 fd                	mov    %edi,%ebp
  801f94:	75 0b                	jne    801fa1 <__umoddi3+0x91>
  801f96:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	f7 f7                	div    %edi
  801f9f:	89 c5                	mov    %eax,%ebp
  801fa1:	89 f0                	mov    %esi,%eax
  801fa3:	31 d2                	xor    %edx,%edx
  801fa5:	f7 f5                	div    %ebp
  801fa7:	89 c8                	mov    %ecx,%eax
  801fa9:	f7 f5                	div    %ebp
  801fab:	89 d0                	mov    %edx,%eax
  801fad:	eb 99                	jmp    801f48 <__umoddi3+0x38>
  801faf:	90                   	nop
  801fb0:	89 c8                	mov    %ecx,%eax
  801fb2:	89 f2                	mov    %esi,%edx
  801fb4:	83 c4 1c             	add    $0x1c,%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5f                   	pop    %edi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    
  801fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	8b 34 24             	mov    (%esp),%esi
  801fc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801fc8:	89 e9                	mov    %ebp,%ecx
  801fca:	29 ef                	sub    %ebp,%edi
  801fcc:	d3 e0                	shl    %cl,%eax
  801fce:	89 f9                	mov    %edi,%ecx
  801fd0:	89 f2                	mov    %esi,%edx
  801fd2:	d3 ea                	shr    %cl,%edx
  801fd4:	89 e9                	mov    %ebp,%ecx
  801fd6:	09 c2                	or     %eax,%edx
  801fd8:	89 d8                	mov    %ebx,%eax
  801fda:	89 14 24             	mov    %edx,(%esp)
  801fdd:	89 f2                	mov    %esi,%edx
  801fdf:	d3 e2                	shl    %cl,%edx
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fe7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801feb:	d3 e8                	shr    %cl,%eax
  801fed:	89 e9                	mov    %ebp,%ecx
  801fef:	89 c6                	mov    %eax,%esi
  801ff1:	d3 e3                	shl    %cl,%ebx
  801ff3:	89 f9                	mov    %edi,%ecx
  801ff5:	89 d0                	mov    %edx,%eax
  801ff7:	d3 e8                	shr    %cl,%eax
  801ff9:	89 e9                	mov    %ebp,%ecx
  801ffb:	09 d8                	or     %ebx,%eax
  801ffd:	89 d3                	mov    %edx,%ebx
  801fff:	89 f2                	mov    %esi,%edx
  802001:	f7 34 24             	divl   (%esp)
  802004:	89 d6                	mov    %edx,%esi
  802006:	d3 e3                	shl    %cl,%ebx
  802008:	f7 64 24 04          	mull   0x4(%esp)
  80200c:	39 d6                	cmp    %edx,%esi
  80200e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802012:	89 d1                	mov    %edx,%ecx
  802014:	89 c3                	mov    %eax,%ebx
  802016:	72 08                	jb     802020 <__umoddi3+0x110>
  802018:	75 11                	jne    80202b <__umoddi3+0x11b>
  80201a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80201e:	73 0b                	jae    80202b <__umoddi3+0x11b>
  802020:	2b 44 24 04          	sub    0x4(%esp),%eax
  802024:	1b 14 24             	sbb    (%esp),%edx
  802027:	89 d1                	mov    %edx,%ecx
  802029:	89 c3                	mov    %eax,%ebx
  80202b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80202f:	29 da                	sub    %ebx,%edx
  802031:	19 ce                	sbb    %ecx,%esi
  802033:	89 f9                	mov    %edi,%ecx
  802035:	89 f0                	mov    %esi,%eax
  802037:	d3 e0                	shl    %cl,%eax
  802039:	89 e9                	mov    %ebp,%ecx
  80203b:	d3 ea                	shr    %cl,%edx
  80203d:	89 e9                	mov    %ebp,%ecx
  80203f:	d3 ee                	shr    %cl,%esi
  802041:	09 d0                	or     %edx,%eax
  802043:	89 f2                	mov    %esi,%edx
  802045:	83 c4 1c             	add    $0x1c,%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5f                   	pop    %edi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    
  80204d:	8d 76 00             	lea    0x0(%esi),%esi
  802050:	29 f9                	sub    %edi,%ecx
  802052:	19 d6                	sbb    %edx,%esi
  802054:	89 74 24 04          	mov    %esi,0x4(%esp)
  802058:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80205c:	e9 18 ff ff ff       	jmp    801f79 <__umoddi3+0x69>
