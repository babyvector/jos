
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 f0 01 00 00       	call   800221 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 e2 0c 00 00       	call   800d2c <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 c0 1f 80 00       	push   $0x801fc0
  800057:	6a 1f                	push   $0x1f
  800059:	68 d3 1f 80 00       	push   $0x801fd3
  80005e:	e8 1e 02 00 00       	call   800281 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 f9 0c 00 00       	call   800d6f <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 e3 1f 80 00       	push   $0x801fe3
  800083:	6a 21                	push   $0x21
  800085:	68 d3 1f 80 00       	push   $0x801fd3
  80008a:	e8 f2 01 00 00       	call   800281 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 19 0a 00 00       	call   800abb <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 00 0d 00 00       	call   800db1 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 f4 1f 80 00       	push   $0x801ff4
  8000be:	6a 24                	push   $0x24
  8000c0:	68 d3 1f 80 00       	push   $0x801fd3
  8000c5:	e8 b7 01 00 00       	call   800281 <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 18             	sub    $0x18,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
  8000e2:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	cprintf("THE RETURNED envid is:%d\n",envid);
  8000e4:	50                   	push   %eax
  8000e5:	68 07 20 80 00       	push   $0x802007
  8000ea:	e8 6b 02 00 00       	call   80035a <cprintf>
	if (envid < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 db                	test   %ebx,%ebx
  8000f4:	79 12                	jns    800108 <dumbfork+0x37>
		panic("sys_exofork: %e", envid);
  8000f6:	53                   	push   %ebx
  8000f7:	68 21 20 80 00       	push   $0x802021
  8000fc:	6a 37                	push   $0x37
  8000fe:	68 d3 1f 80 00       	push   $0x801fd3
  800103:	e8 79 01 00 00       	call   800281 <_panic>
	if (envid == 0) {
  800108:	85 db                	test   %ebx,%ebx
  80010a:	75 21                	jne    80012d <dumbfork+0x5c>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80010c:	e8 dd 0b 00 00       	call   800cee <sys_getenvid>
  800111:	25 ff 03 00 00       	and    $0x3ff,%eax
  800116:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800123:	b8 00 00 00 00       	mov    $0x0,%eax
  800128:	e9 89 00 00 00       	jmp    8001b6 <dumbfork+0xe5>
	}
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	cprintf("	AT before for duppage.\n");
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	68 31 20 80 00       	push   $0x802031
  800135:	e8 20 02 00 00       	call   80035a <cprintf>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80013a:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	eb 14                	jmp    80015a <dumbfork+0x89>
		duppage(envid, addr);
  800146:	83 ec 08             	sub    $0x8,%esp
  800149:	52                   	push   %edx
  80014a:	56                   	push   %esi
  80014b:	e8 e3 fe ff ff       	call   800033 <duppage>
	}
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	cprintf("	AT before for duppage.\n");
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800150:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80015d:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800163:	72 e1                	jb     800146 <dumbfork+0x75>
		duppage(envid, addr);
	cprintf(" NOW IN DUMBFORK.\n");	
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	68 4a 20 80 00       	push   $0x80204a
  80016d:	e8 e8 01 00 00       	call   80035a <cprintf>
	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800172:	83 c4 08             	add    $0x8,%esp
  800175:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800178:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80017d:	50                   	push   %eax
  80017e:	53                   	push   %ebx
  80017f:	e8 af fe ff ff       	call   800033 <duppage>
	cprintf("	after duppage(envid,ROUNDDOWN(&addr,PGSIZE))\n");
  800184:	c7 04 24 a8 20 80 00 	movl   $0x8020a8,(%esp)
  80018b:	e8 ca 01 00 00       	call   80035a <cprintf>
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800190:	83 c4 08             	add    $0x8,%esp
  800193:	6a 02                	push   $0x2
  800195:	53                   	push   %ebx
  800196:	e8 58 0c 00 00       	call   800df3 <sys_env_set_status>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <dumbfork+0xe3>
		panic("sys_env_set_status: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 5d 20 80 00       	push   $0x80205d
  8001a8:	6a 4c                	push   $0x4c
  8001aa:	68 d3 1f 80 00       	push   $0x801fd3
  8001af:	e8 cd 00 00 00       	call   800281 <_panic>

	return envid;
  8001b4:	89 d8                	mov    %ebx,%eax
}
  8001b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001b9:	5b                   	pop    %ebx
  8001ba:	5e                   	pop    %esi
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 0c             	sub    $0xc,%esp

	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001c6:	e8 06 ff ff ff       	call   8000d1 <dumbfork>
  8001cb:	89 c7                	mov    %eax,%edi
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	be 7b 20 80 00       	mov    $0x80207b,%esi
  8001d4:	b8 74 20 80 00       	mov    $0x802074,%eax
  8001d9:	0f 45 f0             	cmovne %eax,%esi
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	eb 26                	jmp    800209 <umain+0x4c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	56                   	push   %esi
  8001e7:	53                   	push   %ebx
  8001e8:	68 81 20 80 00       	push   $0x802081
  8001ed:	e8 68 01 00 00       	call   80035a <cprintf>
		sys_yield();
  8001f2:	e8 16 0b 00 00       	call   800d0d <sys_yield>
		cprintf("	AFTER SYS_YIELD.\n");
  8001f7:	c7 04 24 93 20 80 00 	movl   $0x802093,(%esp)
  8001fe:	e8 57 01 00 00       	call   80035a <cprintf>
	int i;

	// fork a child process
	who = dumbfork();
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800203:	83 c3 01             	add    $0x1,%ebx
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	85 ff                	test   %edi,%edi
  80020b:	74 07                	je     800214 <umain+0x57>
  80020d:	83 fb 09             	cmp    $0x9,%ebx
  800210:	7e d1                	jle    8001e3 <umain+0x26>
  800212:	eb 05                	jmp    800219 <umain+0x5c>
  800214:	83 fb 13             	cmp    $0x13,%ebx
  800217:	7e ca                	jle    8001e3 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
		cprintf("	AFTER SYS_YIELD.\n");
	}
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800229:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  80022c:	e8 bd 0a 00 00       	call   800cee <sys_getenvid>
  800231:	25 ff 03 00 00       	and    $0x3ff,%eax
  800236:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800239:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023e:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800243:	85 db                	test   %ebx,%ebx
  800245:	7e 07                	jle    80024e <libmain+0x2d>
		binaryname = argv[0];
  800247:	8b 06                	mov    (%esi),%eax
  800249:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	e8 65 ff ff ff       	call   8001bd <umain>

	// exit gracefully
	exit();
  800258:	e8 0a 00 00 00       	call   800267 <exit>
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80026d:	e8 76 0e 00 00       	call   8010e8 <close_all>
	sys_env_destroy(0);
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	6a 00                	push   $0x0
  800277:	e8 31 0a 00 00       	call   800cad <sys_env_destroy>
}
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800286:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800289:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80028f:	e8 5a 0a 00 00       	call   800cee <sys_getenvid>
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	ff 75 0c             	pushl  0xc(%ebp)
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	56                   	push   %esi
  80029e:	50                   	push   %eax
  80029f:	68 e4 20 80 00       	push   $0x8020e4
  8002a4:	e8 b1 00 00 00       	call   80035a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002a9:	83 c4 18             	add    $0x18,%esp
  8002ac:	53                   	push   %ebx
  8002ad:	ff 75 10             	pushl  0x10(%ebp)
  8002b0:	e8 54 00 00 00       	call   800309 <vcprintf>
	cprintf("\n");
  8002b5:	c7 04 24 91 20 80 00 	movl   $0x802091,(%esp)
  8002bc:	e8 99 00 00 00       	call   80035a <cprintf>
  8002c1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002c4:	cc                   	int3   
  8002c5:	eb fd                	jmp    8002c4 <_panic+0x43>

008002c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 04             	sub    $0x4,%esp
  8002ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002d1:	8b 13                	mov    (%ebx),%edx
  8002d3:	8d 42 01             	lea    0x1(%edx),%eax
  8002d6:	89 03                	mov    %eax,(%ebx)
  8002d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002e4:	75 1a                	jne    800300 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002e6:	83 ec 08             	sub    $0x8,%esp
  8002e9:	68 ff 00 00 00       	push   $0xff
  8002ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8002f1:	50                   	push   %eax
  8002f2:	e8 79 09 00 00       	call   800c70 <sys_cputs>
		b->idx = 0;
  8002f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002fd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800300:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800304:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800307:	c9                   	leave  
  800308:	c3                   	ret    

00800309 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800312:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800319:	00 00 00 
	b.cnt = 0;
  80031c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800323:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800326:	ff 75 0c             	pushl  0xc(%ebp)
  800329:	ff 75 08             	pushl  0x8(%ebp)
  80032c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800332:	50                   	push   %eax
  800333:	68 c7 02 80 00       	push   $0x8002c7
  800338:	e8 54 01 00 00       	call   800491 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800346:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80034c:	50                   	push   %eax
  80034d:	e8 1e 09 00 00       	call   800c70 <sys_cputs>

	return b.cnt;
}
  800352:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800358:	c9                   	leave  
  800359:	c3                   	ret    

0080035a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800360:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800363:	50                   	push   %eax
  800364:	ff 75 08             	pushl  0x8(%ebp)
  800367:	e8 9d ff ff ff       	call   800309 <vcprintf>
	va_end(ap);

	return cnt;
}
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
  800374:	83 ec 1c             	sub    $0x1c,%esp
  800377:	89 c7                	mov    %eax,%edi
  800379:	89 d6                	mov    %edx,%esi
  80037b:	8b 45 08             	mov    0x8(%ebp),%eax
  80037e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800381:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800384:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800387:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80038a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800392:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800395:	39 d3                	cmp    %edx,%ebx
  800397:	72 05                	jb     80039e <printnum+0x30>
  800399:	39 45 10             	cmp    %eax,0x10(%ebp)
  80039c:	77 45                	ja     8003e3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80039e:	83 ec 0c             	sub    $0xc,%esp
  8003a1:	ff 75 18             	pushl  0x18(%ebp)
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003aa:	53                   	push   %ebx
  8003ab:	ff 75 10             	pushl  0x10(%ebp)
  8003ae:	83 ec 08             	sub    $0x8,%esp
  8003b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bd:	e8 5e 19 00 00       	call   801d20 <__udivdi3>
  8003c2:	83 c4 18             	add    $0x18,%esp
  8003c5:	52                   	push   %edx
  8003c6:	50                   	push   %eax
  8003c7:	89 f2                	mov    %esi,%edx
  8003c9:	89 f8                	mov    %edi,%eax
  8003cb:	e8 9e ff ff ff       	call   80036e <printnum>
  8003d0:	83 c4 20             	add    $0x20,%esp
  8003d3:	eb 18                	jmp    8003ed <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d5:	83 ec 08             	sub    $0x8,%esp
  8003d8:	56                   	push   %esi
  8003d9:	ff 75 18             	pushl  0x18(%ebp)
  8003dc:	ff d7                	call   *%edi
  8003de:	83 c4 10             	add    $0x10,%esp
  8003e1:	eb 03                	jmp    8003e6 <printnum+0x78>
  8003e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e6:	83 eb 01             	sub    $0x1,%ebx
  8003e9:	85 db                	test   %ebx,%ebx
  8003eb:	7f e8                	jg     8003d5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ed:	83 ec 08             	sub    $0x8,%esp
  8003f0:	56                   	push   %esi
  8003f1:	83 ec 04             	sub    $0x4,%esp
  8003f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8003fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800400:	e8 4b 1a 00 00       	call   801e50 <__umoddi3>
  800405:	83 c4 14             	add    $0x14,%esp
  800408:	0f be 80 07 21 80 00 	movsbl 0x802107(%eax),%eax
  80040f:	50                   	push   %eax
  800410:	ff d7                	call   *%edi
}
  800412:	83 c4 10             	add    $0x10,%esp
  800415:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800418:	5b                   	pop    %ebx
  800419:	5e                   	pop    %esi
  80041a:	5f                   	pop    %edi
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800420:	83 fa 01             	cmp    $0x1,%edx
  800423:	7e 0e                	jle    800433 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800425:	8b 10                	mov    (%eax),%edx
  800427:	8d 4a 08             	lea    0x8(%edx),%ecx
  80042a:	89 08                	mov    %ecx,(%eax)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	8b 52 04             	mov    0x4(%edx),%edx
  800431:	eb 22                	jmp    800455 <getuint+0x38>
	else if (lflag)
  800433:	85 d2                	test   %edx,%edx
  800435:	74 10                	je     800447 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800437:	8b 10                	mov    (%eax),%edx
  800439:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043c:	89 08                	mov    %ecx,(%eax)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	eb 0e                	jmp    800455 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800447:	8b 10                	mov    (%eax),%edx
  800449:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044c:	89 08                	mov    %ecx,(%eax)
  80044e:	8b 02                	mov    (%edx),%eax
  800450:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800455:	5d                   	pop    %ebp
  800456:	c3                   	ret    

00800457 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80045d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800461:	8b 10                	mov    (%eax),%edx
  800463:	3b 50 04             	cmp    0x4(%eax),%edx
  800466:	73 0a                	jae    800472 <sprintputch+0x1b>
		*b->buf++ = ch;
  800468:	8d 4a 01             	lea    0x1(%edx),%ecx
  80046b:	89 08                	mov    %ecx,(%eax)
  80046d:	8b 45 08             	mov    0x8(%ebp),%eax
  800470:	88 02                	mov    %al,(%edx)
}
  800472:	5d                   	pop    %ebp
  800473:	c3                   	ret    

00800474 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80047a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80047d:	50                   	push   %eax
  80047e:	ff 75 10             	pushl  0x10(%ebp)
  800481:	ff 75 0c             	pushl  0xc(%ebp)
  800484:	ff 75 08             	pushl  0x8(%ebp)
  800487:	e8 05 00 00 00       	call   800491 <vprintfmt>
	va_end(ap);
}
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	57                   	push   %edi
  800495:	56                   	push   %esi
  800496:	53                   	push   %ebx
  800497:	83 ec 2c             	sub    $0x2c,%esp
  80049a:	8b 75 08             	mov    0x8(%ebp),%esi
  80049d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004a3:	eb 12                	jmp    8004b7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	0f 84 d3 03 00 00    	je     800880 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	53                   	push   %ebx
  8004b1:	50                   	push   %eax
  8004b2:	ff d6                	call   *%esi
  8004b4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b7:	83 c7 01             	add    $0x1,%edi
  8004ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004be:	83 f8 25             	cmp    $0x25,%eax
  8004c1:	75 e2                	jne    8004a5 <vprintfmt+0x14>
  8004c3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ce:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e1:	eb 07                	jmp    8004ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8d 47 01             	lea    0x1(%edi),%eax
  8004ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f0:	0f b6 07             	movzbl (%edi),%eax
  8004f3:	0f b6 c8             	movzbl %al,%ecx
  8004f6:	83 e8 23             	sub    $0x23,%eax
  8004f9:	3c 55                	cmp    $0x55,%al
  8004fb:	0f 87 64 03 00 00    	ja     800865 <vprintfmt+0x3d4>
  800501:	0f b6 c0             	movzbl %al,%eax
  800504:	ff 24 85 40 22 80 00 	jmp    *0x802240(,%eax,4)
  80050b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80050e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800512:	eb d6                	jmp    8004ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800517:	b8 00 00 00 00       	mov    $0x0,%eax
  80051c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80051f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800522:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800526:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800529:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80052c:	83 fa 09             	cmp    $0x9,%edx
  80052f:	77 39                	ja     80056a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800531:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800534:	eb e9                	jmp    80051f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 48 04             	lea    0x4(%eax),%ecx
  80053c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800547:	eb 27                	jmp    800570 <vprintfmt+0xdf>
  800549:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054c:	85 c0                	test   %eax,%eax
  80054e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800553:	0f 49 c8             	cmovns %eax,%ecx
  800556:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055c:	eb 8c                	jmp    8004ea <vprintfmt+0x59>
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800561:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800568:	eb 80                	jmp    8004ea <vprintfmt+0x59>
  80056a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80056d:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800570:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800574:	0f 89 70 ff ff ff    	jns    8004ea <vprintfmt+0x59>
				width = precision, precision = -1;
  80057a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800580:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800587:	e9 5e ff ff ff       	jmp    8004ea <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80058c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800592:	e9 53 ff ff ff       	jmp    8004ea <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 04             	lea    0x4(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	ff 30                	pushl  (%eax)
  8005a6:	ff d6                	call   *%esi
			break;
  8005a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005ae:	e9 04 ff ff ff       	jmp    8004b7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 50 04             	lea    0x4(%eax),%edx
  8005b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	99                   	cltd   
  8005bf:	31 d0                	xor    %edx,%eax
  8005c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c3:	83 f8 0f             	cmp    $0xf,%eax
  8005c6:	7f 0b                	jg     8005d3 <vprintfmt+0x142>
  8005c8:	8b 14 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%edx
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	75 18                	jne    8005eb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005d3:	50                   	push   %eax
  8005d4:	68 1f 21 80 00       	push   $0x80211f
  8005d9:	53                   	push   %ebx
  8005da:	56                   	push   %esi
  8005db:	e8 94 fe ff ff       	call   800474 <printfmt>
  8005e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e6:	e9 cc fe ff ff       	jmp    8004b7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005eb:	52                   	push   %edx
  8005ec:	68 d5 24 80 00       	push   $0x8024d5
  8005f1:	53                   	push   %ebx
  8005f2:	56                   	push   %esi
  8005f3:	e8 7c fe ff ff       	call   800474 <printfmt>
  8005f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fe:	e9 b4 fe ff ff       	jmp    8004b7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80060e:	85 ff                	test   %edi,%edi
  800610:	b8 18 21 80 00       	mov    $0x802118,%eax
  800615:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800618:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061c:	0f 8e 94 00 00 00    	jle    8006b6 <vprintfmt+0x225>
  800622:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800626:	0f 84 98 00 00 00    	je     8006c4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	ff 75 c8             	pushl  -0x38(%ebp)
  800632:	57                   	push   %edi
  800633:	e8 d0 02 00 00       	call   800908 <strnlen>
  800638:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80063b:	29 c1                	sub    %eax,%ecx
  80063d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800640:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800643:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800647:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80064d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	eb 0f                	jmp    800660 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	ff 75 e0             	pushl  -0x20(%ebp)
  800658:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065a:	83 ef 01             	sub    $0x1,%edi
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	85 ff                	test   %edi,%edi
  800662:	7f ed                	jg     800651 <vprintfmt+0x1c0>
  800664:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800667:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80066a:	85 c9                	test   %ecx,%ecx
  80066c:	b8 00 00 00 00       	mov    $0x0,%eax
  800671:	0f 49 c1             	cmovns %ecx,%eax
  800674:	29 c1                	sub    %eax,%ecx
  800676:	89 75 08             	mov    %esi,0x8(%ebp)
  800679:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80067c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067f:	89 cb                	mov    %ecx,%ebx
  800681:	eb 4d                	jmp    8006d0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800683:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800687:	74 1b                	je     8006a4 <vprintfmt+0x213>
  800689:	0f be c0             	movsbl %al,%eax
  80068c:	83 e8 20             	sub    $0x20,%eax
  80068f:	83 f8 5e             	cmp    $0x5e,%eax
  800692:	76 10                	jbe    8006a4 <vprintfmt+0x213>
					putch('?', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	6a 3f                	push   $0x3f
  80069c:	ff 55 08             	call   *0x8(%ebp)
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 0d                	jmp    8006b1 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff 55 08             	call   *0x8(%ebp)
  8006ae:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b1:	83 eb 01             	sub    $0x1,%ebx
  8006b4:	eb 1a                	jmp    8006d0 <vprintfmt+0x23f>
  8006b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006c2:	eb 0c                	jmp    8006d0 <vprintfmt+0x23f>
  8006c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c7:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d0:	83 c7 01             	add    $0x1,%edi
  8006d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d7:	0f be d0             	movsbl %al,%edx
  8006da:	85 d2                	test   %edx,%edx
  8006dc:	74 23                	je     800701 <vprintfmt+0x270>
  8006de:	85 f6                	test   %esi,%esi
  8006e0:	78 a1                	js     800683 <vprintfmt+0x1f2>
  8006e2:	83 ee 01             	sub    $0x1,%esi
  8006e5:	79 9c                	jns    800683 <vprintfmt+0x1f2>
  8006e7:	89 df                	mov    %ebx,%edi
  8006e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ef:	eb 18                	jmp    800709 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 20                	push   $0x20
  8006f7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f9:	83 ef 01             	sub    $0x1,%edi
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 08                	jmp    800709 <vprintfmt+0x278>
  800701:	89 df                	mov    %ebx,%edi
  800703:	8b 75 08             	mov    0x8(%ebp),%esi
  800706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800709:	85 ff                	test   %edi,%edi
  80070b:	7f e4                	jg     8006f1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800710:	e9 a2 fd ff ff       	jmp    8004b7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800715:	83 fa 01             	cmp    $0x1,%edx
  800718:	7e 16                	jle    800730 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 08             	lea    0x8(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)
  800723:	8b 50 04             	mov    0x4(%eax),%edx
  800726:	8b 00                	mov    (%eax),%eax
  800728:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80072b:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80072e:	eb 32                	jmp    800762 <vprintfmt+0x2d1>
	else if (lflag)
  800730:	85 d2                	test   %edx,%edx
  800732:	74 18                	je     80074c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8d 50 04             	lea    0x4(%eax),%edx
  80073a:	89 55 14             	mov    %edx,0x14(%ebp)
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800742:	89 c1                	mov    %eax,%ecx
  800744:	c1 f9 1f             	sar    $0x1f,%ecx
  800747:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80074a:	eb 16                	jmp    800762 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8d 50 04             	lea    0x4(%eax),%edx
  800752:	89 55 14             	mov    %edx,0x14(%ebp)
  800755:	8b 00                	mov    (%eax),%eax
  800757:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80075a:	89 c1                	mov    %eax,%ecx
  80075c:	c1 f9 1f             	sar    $0x1f,%ecx
  80075f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800762:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800765:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800768:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800773:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800777:	0f 89 b0 00 00 00    	jns    80082d <vprintfmt+0x39c>
				putch('-', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 2d                	push   $0x2d
  800783:	ff d6                	call   *%esi
				num = -(long long) num;
  800785:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800788:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80078b:	f7 d8                	neg    %eax
  80078d:	83 d2 00             	adc    $0x0,%edx
  800790:	f7 da                	neg    %edx
  800792:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800795:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800798:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80079b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a0:	e9 88 00 00 00       	jmp    80082d <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a8:	e8 70 fc ff ff       	call   80041d <getuint>
  8007ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007b3:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007b8:	eb 73                	jmp    80082d <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 5b fc ff ff       	call   80041d <getuint>
  8007c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 58                	push   $0x58
  8007ce:	ff d6                	call   *%esi
			putch('X', putdat);
  8007d0:	83 c4 08             	add    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 58                	push   $0x58
  8007d6:	ff d6                	call   *%esi
			putch('X', putdat);
  8007d8:	83 c4 08             	add    $0x8,%esp
  8007db:	53                   	push   %ebx
  8007dc:	6a 58                	push   $0x58
  8007de:	ff d6                	call   *%esi
			goto number;
  8007e0:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8007e3:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8007e8:	eb 43                	jmp    80082d <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	6a 30                	push   $0x30
  8007f0:	ff d6                	call   *%esi
			putch('x', putdat);
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	53                   	push   %ebx
  8007f6:	6a 78                	push   $0x78
  8007f8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800803:	8b 00                	mov    (%eax),%eax
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800810:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800818:	eb 13                	jmp    80082d <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80081a:	8d 45 14             	lea    0x14(%ebp),%eax
  80081d:	e8 fb fb ff ff       	call   80041d <getuint>
  800822:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800825:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800828:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80082d:	83 ec 0c             	sub    $0xc,%esp
  800830:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800834:	52                   	push   %edx
  800835:	ff 75 e0             	pushl  -0x20(%ebp)
  800838:	50                   	push   %eax
  800839:	ff 75 dc             	pushl  -0x24(%ebp)
  80083c:	ff 75 d8             	pushl  -0x28(%ebp)
  80083f:	89 da                	mov    %ebx,%edx
  800841:	89 f0                	mov    %esi,%eax
  800843:	e8 26 fb ff ff       	call   80036e <printnum>
			break;
  800848:	83 c4 20             	add    $0x20,%esp
  80084b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80084e:	e9 64 fc ff ff       	jmp    8004b7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	51                   	push   %ecx
  800858:	ff d6                	call   *%esi
			break;
  80085a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800860:	e9 52 fc ff ff       	jmp    8004b7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 25                	push   $0x25
  80086b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	eb 03                	jmp    800875 <vprintfmt+0x3e4>
  800872:	83 ef 01             	sub    $0x1,%edi
  800875:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800879:	75 f7                	jne    800872 <vprintfmt+0x3e1>
  80087b:	e9 37 fc ff ff       	jmp    8004b7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800880:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5f                   	pop    %edi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	83 ec 18             	sub    $0x18,%esp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800894:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800897:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	74 26                	je     8008cf <vsnprintf+0x47>
  8008a9:	85 d2                	test   %edx,%edx
  8008ab:	7e 22                	jle    8008cf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ad:	ff 75 14             	pushl  0x14(%ebp)
  8008b0:	ff 75 10             	pushl  0x10(%ebp)
  8008b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b6:	50                   	push   %eax
  8008b7:	68 57 04 80 00       	push   $0x800457
  8008bc:	e8 d0 fb ff ff       	call   800491 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	eb 05                	jmp    8008d4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008df:	50                   	push   %eax
  8008e0:	ff 75 10             	pushl  0x10(%ebp)
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	ff 75 08             	pushl  0x8(%ebp)
  8008e9:	e8 9a ff ff ff       	call   800888 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	eb 03                	jmp    800900 <strlen+0x10>
		n++;
  8008fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800900:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800904:	75 f7                	jne    8008fd <strlen+0xd>
		n++;
	return n;
}
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800911:	ba 00 00 00 00       	mov    $0x0,%edx
  800916:	eb 03                	jmp    80091b <strnlen+0x13>
		n++;
  800918:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091b:	39 c2                	cmp    %eax,%edx
  80091d:	74 08                	je     800927 <strnlen+0x1f>
  80091f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800923:	75 f3                	jne    800918 <strnlen+0x10>
  800925:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	53                   	push   %ebx
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800933:	89 c2                	mov    %eax,%edx
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	83 c1 01             	add    $0x1,%ecx
  80093b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80093f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800942:	84 db                	test   %bl,%bl
  800944:	75 ef                	jne    800935 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800946:	5b                   	pop    %ebx
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	53                   	push   %ebx
  80094d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800950:	53                   	push   %ebx
  800951:	e8 9a ff ff ff       	call   8008f0 <strlen>
  800956:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800959:	ff 75 0c             	pushl  0xc(%ebp)
  80095c:	01 d8                	add    %ebx,%eax
  80095e:	50                   	push   %eax
  80095f:	e8 c5 ff ff ff       	call   800929 <strcpy>
	return dst;
}
  800964:	89 d8                	mov    %ebx,%eax
  800966:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 75 08             	mov    0x8(%ebp),%esi
  800973:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800976:	89 f3                	mov    %esi,%ebx
  800978:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097b:	89 f2                	mov    %esi,%edx
  80097d:	eb 0f                	jmp    80098e <strncpy+0x23>
		*dst++ = *src;
  80097f:	83 c2 01             	add    $0x1,%edx
  800982:	0f b6 01             	movzbl (%ecx),%eax
  800985:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800988:	80 39 01             	cmpb   $0x1,(%ecx)
  80098b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098e:	39 da                	cmp    %ebx,%edx
  800990:	75 ed                	jne    80097f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800992:	89 f0                	mov    %esi,%eax
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a3:	8b 55 10             	mov    0x10(%ebp),%edx
  8009a6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a8:	85 d2                	test   %edx,%edx
  8009aa:	74 21                	je     8009cd <strlcpy+0x35>
  8009ac:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009b0:	89 f2                	mov    %esi,%edx
  8009b2:	eb 09                	jmp    8009bd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b4:	83 c2 01             	add    $0x1,%edx
  8009b7:	83 c1 01             	add    $0x1,%ecx
  8009ba:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009bd:	39 c2                	cmp    %eax,%edx
  8009bf:	74 09                	je     8009ca <strlcpy+0x32>
  8009c1:	0f b6 19             	movzbl (%ecx),%ebx
  8009c4:	84 db                	test   %bl,%bl
  8009c6:	75 ec                	jne    8009b4 <strlcpy+0x1c>
  8009c8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009ca:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009cd:	29 f0                	sub    %esi,%eax
}
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009dc:	eb 06                	jmp    8009e4 <strcmp+0x11>
		p++, q++;
  8009de:	83 c1 01             	add    $0x1,%ecx
  8009e1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e4:	0f b6 01             	movzbl (%ecx),%eax
  8009e7:	84 c0                	test   %al,%al
  8009e9:	74 04                	je     8009ef <strcmp+0x1c>
  8009eb:	3a 02                	cmp    (%edx),%al
  8009ed:	74 ef                	je     8009de <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ef:	0f b6 c0             	movzbl %al,%eax
  8009f2:	0f b6 12             	movzbl (%edx),%edx
  8009f5:	29 d0                	sub    %edx,%eax
}
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	53                   	push   %ebx
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a03:	89 c3                	mov    %eax,%ebx
  800a05:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a08:	eb 06                	jmp    800a10 <strncmp+0x17>
		n--, p++, q++;
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a10:	39 d8                	cmp    %ebx,%eax
  800a12:	74 15                	je     800a29 <strncmp+0x30>
  800a14:	0f b6 08             	movzbl (%eax),%ecx
  800a17:	84 c9                	test   %cl,%cl
  800a19:	74 04                	je     800a1f <strncmp+0x26>
  800a1b:	3a 0a                	cmp    (%edx),%cl
  800a1d:	74 eb                	je     800a0a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1f:	0f b6 00             	movzbl (%eax),%eax
  800a22:	0f b6 12             	movzbl (%edx),%edx
  800a25:	29 d0                	sub    %edx,%eax
  800a27:	eb 05                	jmp    800a2e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3b:	eb 07                	jmp    800a44 <strchr+0x13>
		if (*s == c)
  800a3d:	38 ca                	cmp    %cl,%dl
  800a3f:	74 0f                	je     800a50 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a41:	83 c0 01             	add    $0x1,%eax
  800a44:	0f b6 10             	movzbl (%eax),%edx
  800a47:	84 d2                	test   %dl,%dl
  800a49:	75 f2                	jne    800a3d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5c:	eb 03                	jmp    800a61 <strfind+0xf>
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a64:	38 ca                	cmp    %cl,%dl
  800a66:	74 04                	je     800a6c <strfind+0x1a>
  800a68:	84 d2                	test   %dl,%dl
  800a6a:	75 f2                	jne    800a5e <strfind+0xc>
			break;
	return (char *) s;
}
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a7a:	85 c9                	test   %ecx,%ecx
  800a7c:	74 36                	je     800ab4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a84:	75 28                	jne    800aae <memset+0x40>
  800a86:	f6 c1 03             	test   $0x3,%cl
  800a89:	75 23                	jne    800aae <memset+0x40>
		c &= 0xFF;
  800a8b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8f:	89 d3                	mov    %edx,%ebx
  800a91:	c1 e3 08             	shl    $0x8,%ebx
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	c1 e6 18             	shl    $0x18,%esi
  800a99:	89 d0                	mov    %edx,%eax
  800a9b:	c1 e0 10             	shl    $0x10,%eax
  800a9e:	09 f0                	or     %esi,%eax
  800aa0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aa2:	89 d8                	mov    %ebx,%eax
  800aa4:	09 d0                	or     %edx,%eax
  800aa6:	c1 e9 02             	shr    $0x2,%ecx
  800aa9:	fc                   	cld    
  800aaa:	f3 ab                	rep stos %eax,%es:(%edi)
  800aac:	eb 06                	jmp    800ab4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab1:	fc                   	cld    
  800ab2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab4:	89 f8                	mov    %edi,%eax
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac9:	39 c6                	cmp    %eax,%esi
  800acb:	73 35                	jae    800b02 <memmove+0x47>
  800acd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad0:	39 d0                	cmp    %edx,%eax
  800ad2:	73 2e                	jae    800b02 <memmove+0x47>
		s += n;
		d += n;
  800ad4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad7:	89 d6                	mov    %edx,%esi
  800ad9:	09 fe                	or     %edi,%esi
  800adb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae1:	75 13                	jne    800af6 <memmove+0x3b>
  800ae3:	f6 c1 03             	test   $0x3,%cl
  800ae6:	75 0e                	jne    800af6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ae8:	83 ef 04             	sub    $0x4,%edi
  800aeb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aee:	c1 e9 02             	shr    $0x2,%ecx
  800af1:	fd                   	std    
  800af2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af4:	eb 09                	jmp    800aff <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af6:	83 ef 01             	sub    $0x1,%edi
  800af9:	8d 72 ff             	lea    -0x1(%edx),%esi
  800afc:	fd                   	std    
  800afd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aff:	fc                   	cld    
  800b00:	eb 1d                	jmp    800b1f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b02:	89 f2                	mov    %esi,%edx
  800b04:	09 c2                	or     %eax,%edx
  800b06:	f6 c2 03             	test   $0x3,%dl
  800b09:	75 0f                	jne    800b1a <memmove+0x5f>
  800b0b:	f6 c1 03             	test   $0x3,%cl
  800b0e:	75 0a                	jne    800b1a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b10:	c1 e9 02             	shr    $0x2,%ecx
  800b13:	89 c7                	mov    %eax,%edi
  800b15:	fc                   	cld    
  800b16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b18:	eb 05                	jmp    800b1f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	fc                   	cld    
  800b1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b26:	ff 75 10             	pushl  0x10(%ebp)
  800b29:	ff 75 0c             	pushl  0xc(%ebp)
  800b2c:	ff 75 08             	pushl  0x8(%ebp)
  800b2f:	e8 87 ff ff ff       	call   800abb <memmove>
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b41:	89 c6                	mov    %eax,%esi
  800b43:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b46:	eb 1a                	jmp    800b62 <memcmp+0x2c>
		if (*s1 != *s2)
  800b48:	0f b6 08             	movzbl (%eax),%ecx
  800b4b:	0f b6 1a             	movzbl (%edx),%ebx
  800b4e:	38 d9                	cmp    %bl,%cl
  800b50:	74 0a                	je     800b5c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b52:	0f b6 c1             	movzbl %cl,%eax
  800b55:	0f b6 db             	movzbl %bl,%ebx
  800b58:	29 d8                	sub    %ebx,%eax
  800b5a:	eb 0f                	jmp    800b6b <memcmp+0x35>
		s1++, s2++;
  800b5c:	83 c0 01             	add    $0x1,%eax
  800b5f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b62:	39 f0                	cmp    %esi,%eax
  800b64:	75 e2                	jne    800b48 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	53                   	push   %ebx
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b76:	89 c1                	mov    %eax,%ecx
  800b78:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b7f:	eb 0a                	jmp    800b8b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b81:	0f b6 10             	movzbl (%eax),%edx
  800b84:	39 da                	cmp    %ebx,%edx
  800b86:	74 07                	je     800b8f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b88:	83 c0 01             	add    $0x1,%eax
  800b8b:	39 c8                	cmp    %ecx,%eax
  800b8d:	72 f2                	jb     800b81 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9e:	eb 03                	jmp    800ba3 <strtol+0x11>
		s++;
  800ba0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba3:	0f b6 01             	movzbl (%ecx),%eax
  800ba6:	3c 20                	cmp    $0x20,%al
  800ba8:	74 f6                	je     800ba0 <strtol+0xe>
  800baa:	3c 09                	cmp    $0x9,%al
  800bac:	74 f2                	je     800ba0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bae:	3c 2b                	cmp    $0x2b,%al
  800bb0:	75 0a                	jne    800bbc <strtol+0x2a>
		s++;
  800bb2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb5:	bf 00 00 00 00       	mov    $0x0,%edi
  800bba:	eb 11                	jmp    800bcd <strtol+0x3b>
  800bbc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bc1:	3c 2d                	cmp    $0x2d,%al
  800bc3:	75 08                	jne    800bcd <strtol+0x3b>
		s++, neg = 1;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd3:	75 15                	jne    800bea <strtol+0x58>
  800bd5:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd8:	75 10                	jne    800bea <strtol+0x58>
  800bda:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bde:	75 7c                	jne    800c5c <strtol+0xca>
		s += 2, base = 16;
  800be0:	83 c1 02             	add    $0x2,%ecx
  800be3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be8:	eb 16                	jmp    800c00 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bea:	85 db                	test   %ebx,%ebx
  800bec:	75 12                	jne    800c00 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bee:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf3:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf6:	75 08                	jne    800c00 <strtol+0x6e>
		s++, base = 8;
  800bf8:	83 c1 01             	add    $0x1,%ecx
  800bfb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c00:	b8 00 00 00 00       	mov    $0x0,%eax
  800c05:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c08:	0f b6 11             	movzbl (%ecx),%edx
  800c0b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c0e:	89 f3                	mov    %esi,%ebx
  800c10:	80 fb 09             	cmp    $0x9,%bl
  800c13:	77 08                	ja     800c1d <strtol+0x8b>
			dig = *s - '0';
  800c15:	0f be d2             	movsbl %dl,%edx
  800c18:	83 ea 30             	sub    $0x30,%edx
  800c1b:	eb 22                	jmp    800c3f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c1d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c20:	89 f3                	mov    %esi,%ebx
  800c22:	80 fb 19             	cmp    $0x19,%bl
  800c25:	77 08                	ja     800c2f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c27:	0f be d2             	movsbl %dl,%edx
  800c2a:	83 ea 57             	sub    $0x57,%edx
  800c2d:	eb 10                	jmp    800c3f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c2f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c32:	89 f3                	mov    %esi,%ebx
  800c34:	80 fb 19             	cmp    $0x19,%bl
  800c37:	77 16                	ja     800c4f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c39:	0f be d2             	movsbl %dl,%edx
  800c3c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c3f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c42:	7d 0b                	jge    800c4f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c44:	83 c1 01             	add    $0x1,%ecx
  800c47:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c4b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c4d:	eb b9                	jmp    800c08 <strtol+0x76>

	if (endptr)
  800c4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c53:	74 0d                	je     800c62 <strtol+0xd0>
		*endptr = (char *) s;
  800c55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c58:	89 0e                	mov    %ecx,(%esi)
  800c5a:	eb 06                	jmp    800c62 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5c:	85 db                	test   %ebx,%ebx
  800c5e:	74 98                	je     800bf8 <strtol+0x66>
  800c60:	eb 9e                	jmp    800c00 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c62:	89 c2                	mov    %eax,%edx
  800c64:	f7 da                	neg    %edx
  800c66:	85 ff                	test   %edi,%edi
  800c68:	0f 45 c2             	cmovne %edx,%eax
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c76:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 c3                	mov    %eax,%ebx
  800c83:	89 c7                	mov    %eax,%edi
  800c85:	89 c6                	mov    %eax,%esi
  800c87:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
  800c99:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9e:	89 d1                	mov    %edx,%ecx
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	89 d7                	mov    %edx,%edi
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 cb                	mov    %ecx,%ebx
  800cc5:	89 cf                	mov    %ecx,%edi
  800cc7:	89 ce                	mov    %ecx,%esi
  800cc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 03                	push   $0x3
  800cd5:	68 ff 23 80 00       	push   $0x8023ff
  800cda:	6a 23                	push   $0x23
  800cdc:	68 1c 24 80 00       	push   $0x80241c
  800ce1:	e8 9b f5 ff ff       	call   800281 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cfe:	89 d1                	mov    %edx,%ecx
  800d00:	89 d3                	mov    %edx,%ebx
  800d02:	89 d7                	mov    %edx,%edi
  800d04:	89 d6                	mov    %edx,%esi
  800d06:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_yield>:

void
sys_yield(void)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d13:	ba 00 00 00 00       	mov    $0x0,%edx
  800d18:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1d:	89 d1                	mov    %edx,%ecx
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	89 d7                	mov    %edx,%edi
  800d23:	89 d6                	mov    %edx,%esi
  800d25:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d35:	be 00 00 00 00       	mov    $0x0,%esi
  800d3a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d48:	89 f7                	mov    %esi,%edi
  800d4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 17                	jle    800d67 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	50                   	push   %eax
  800d54:	6a 04                	push   $0x4
  800d56:	68 ff 23 80 00       	push   $0x8023ff
  800d5b:	6a 23                	push   $0x23
  800d5d:	68 1c 24 80 00       	push   $0x80241c
  800d62:	e8 1a f5 ff ff       	call   800281 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d78:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d89:	8b 75 18             	mov    0x18(%ebp),%esi
  800d8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7e 17                	jle    800da9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	6a 05                	push   $0x5
  800d98:	68 ff 23 80 00       	push   $0x8023ff
  800d9d:	6a 23                	push   $0x23
  800d9f:	68 1c 24 80 00       	push   $0x80241c
  800da4:	e8 d8 f4 ff ff       	call   800281 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbf:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	89 df                	mov    %ebx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7e 17                	jle    800deb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 06                	push   $0x6
  800dda:	68 ff 23 80 00       	push   $0x8023ff
  800ddf:	6a 23                	push   $0x23
  800de1:	68 1c 24 80 00       	push   $0x80241c
  800de6:	e8 96 f4 ff ff       	call   800281 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e01:	b8 08 00 00 00       	mov    $0x8,%eax
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 df                	mov    %ebx,%edi
  800e0e:	89 de                	mov    %ebx,%esi
  800e10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 17                	jle    800e2d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	50                   	push   %eax
  800e1a:	6a 08                	push   $0x8
  800e1c:	68 ff 23 80 00       	push   $0x8023ff
  800e21:	6a 23                	push   $0x23
  800e23:	68 1c 24 80 00       	push   $0x80241c
  800e28:	e8 54 f4 ff ff       	call   800281 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e43:	b8 09 00 00 00       	mov    $0x9,%eax
  800e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4e:	89 df                	mov    %ebx,%edi
  800e50:	89 de                	mov    %ebx,%esi
  800e52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e54:	85 c0                	test   %eax,%eax
  800e56:	7e 17                	jle    800e6f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	50                   	push   %eax
  800e5c:	6a 09                	push   $0x9
  800e5e:	68 ff 23 80 00       	push   $0x8023ff
  800e63:	6a 23                	push   $0x23
  800e65:	68 1c 24 80 00       	push   $0x80241c
  800e6a:	e8 12 f4 ff ff       	call   800281 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 df                	mov    %ebx,%edi
  800e92:	89 de                	mov    %ebx,%esi
  800e94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	7e 17                	jle    800eb1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	50                   	push   %eax
  800e9e:	6a 0a                	push   $0xa
  800ea0:	68 ff 23 80 00       	push   $0x8023ff
  800ea5:	6a 23                	push   $0x23
  800ea7:	68 1c 24 80 00       	push   $0x80241c
  800eac:	e8 d0 f3 ff ff       	call   800281 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ebf:	be 00 00 00 00       	mov    $0x0,%esi
  800ec4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ee5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eea:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef2:	89 cb                	mov    %ecx,%ebx
  800ef4:	89 cf                	mov    %ecx,%edi
  800ef6:	89 ce                	mov    %ecx,%esi
  800ef8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800efa:	85 c0                	test   %eax,%eax
  800efc:	7e 17                	jle    800f15 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	50                   	push   %eax
  800f02:	6a 0d                	push   $0xd
  800f04:	68 ff 23 80 00       	push   $0x8023ff
  800f09:	6a 23                	push   $0x23
  800f0b:	68 1c 24 80 00       	push   $0x80241c
  800f10:	e8 6c f3 ff ff       	call   800281 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
  800f23:	05 00 00 00 30       	add    $0x30000000,%eax
  800f28:	c1 e8 0c             	shr    $0xc,%eax
}
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	05 00 00 00 30       	add    $0x30000000,%eax
  800f38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f3d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f4f:	89 c2                	mov    %eax,%edx
  800f51:	c1 ea 16             	shr    $0x16,%edx
  800f54:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f5b:	f6 c2 01             	test   $0x1,%dl
  800f5e:	74 11                	je     800f71 <fd_alloc+0x2d>
  800f60:	89 c2                	mov    %eax,%edx
  800f62:	c1 ea 0c             	shr    $0xc,%edx
  800f65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6c:	f6 c2 01             	test   $0x1,%dl
  800f6f:	75 09                	jne    800f7a <fd_alloc+0x36>
			*fd_store = fd;
  800f71:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
  800f78:	eb 17                	jmp    800f91 <fd_alloc+0x4d>
  800f7a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f7f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f84:	75 c9                	jne    800f4f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f86:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f8c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f99:	83 f8 1f             	cmp    $0x1f,%eax
  800f9c:	77 36                	ja     800fd4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f9e:	c1 e0 0c             	shl    $0xc,%eax
  800fa1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	c1 ea 16             	shr    $0x16,%edx
  800fab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb2:	f6 c2 01             	test   $0x1,%dl
  800fb5:	74 24                	je     800fdb <fd_lookup+0x48>
  800fb7:	89 c2                	mov    %eax,%edx
  800fb9:	c1 ea 0c             	shr    $0xc,%edx
  800fbc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc3:	f6 c2 01             	test   $0x1,%dl
  800fc6:	74 1a                	je     800fe2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fcb:	89 02                	mov    %eax,(%edx)
	return 0;
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd2:	eb 13                	jmp    800fe7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd9:	eb 0c                	jmp    800fe7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe0:	eb 05                	jmp    800fe7 <fd_lookup+0x54>
  800fe2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff2:	ba ac 24 80 00       	mov    $0x8024ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff7:	eb 13                	jmp    80100c <dev_lookup+0x23>
  800ff9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ffc:	39 08                	cmp    %ecx,(%eax)
  800ffe:	75 0c                	jne    80100c <dev_lookup+0x23>
			*dev = devtab[i];
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	89 01                	mov    %eax,(%ecx)
			return 0;
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
  80100a:	eb 2e                	jmp    80103a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80100c:	8b 02                	mov    (%edx),%eax
  80100e:	85 c0                	test   %eax,%eax
  801010:	75 e7                	jne    800ff9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801012:	a1 04 40 80 00       	mov    0x804004,%eax
  801017:	8b 40 48             	mov    0x48(%eax),%eax
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	51                   	push   %ecx
  80101e:	50                   	push   %eax
  80101f:	68 2c 24 80 00       	push   $0x80242c
  801024:	e8 31 f3 ff ff       	call   80035a <cprintf>
	*dev = 0;
  801029:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80103a:	c9                   	leave  
  80103b:	c3                   	ret    

0080103c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	56                   	push   %esi
  801040:	53                   	push   %ebx
  801041:	83 ec 10             	sub    $0x10,%esp
  801044:	8b 75 08             	mov    0x8(%ebp),%esi
  801047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80104a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801054:	c1 e8 0c             	shr    $0xc,%eax
  801057:	50                   	push   %eax
  801058:	e8 36 ff ff ff       	call   800f93 <fd_lookup>
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	78 05                	js     801069 <fd_close+0x2d>
	    || fd != fd2)
  801064:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801067:	74 0c                	je     801075 <fd_close+0x39>
		return (must_exist ? r : 0);
  801069:	84 db                	test   %bl,%bl
  80106b:	ba 00 00 00 00       	mov    $0x0,%edx
  801070:	0f 44 c2             	cmove  %edx,%eax
  801073:	eb 41                	jmp    8010b6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80107b:	50                   	push   %eax
  80107c:	ff 36                	pushl  (%esi)
  80107e:	e8 66 ff ff ff       	call   800fe9 <dev_lookup>
  801083:	89 c3                	mov    %eax,%ebx
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 1a                	js     8010a6 <fd_close+0x6a>
		if (dev->dev_close)
  80108c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801097:	85 c0                	test   %eax,%eax
  801099:	74 0b                	je     8010a6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	56                   	push   %esi
  80109f:	ff d0                	call   *%eax
  8010a1:	89 c3                	mov    %eax,%ebx
  8010a3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	56                   	push   %esi
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 00 fd ff ff       	call   800db1 <sys_page_unmap>
	return r;
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	89 d8                	mov    %ebx,%eax
}
  8010b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b9:	5b                   	pop    %ebx
  8010ba:	5e                   	pop    %esi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	ff 75 08             	pushl  0x8(%ebp)
  8010ca:	e8 c4 fe ff ff       	call   800f93 <fd_lookup>
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 10                	js     8010e6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	6a 01                	push   $0x1
  8010db:	ff 75 f4             	pushl  -0xc(%ebp)
  8010de:	e8 59 ff ff ff       	call   80103c <fd_close>
  8010e3:	83 c4 10             	add    $0x10,%esp
}
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <close_all>:

void
close_all(void)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f4:	83 ec 0c             	sub    $0xc,%esp
  8010f7:	53                   	push   %ebx
  8010f8:	e8 c0 ff ff ff       	call   8010bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010fd:	83 c3 01             	add    $0x1,%ebx
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	83 fb 20             	cmp    $0x20,%ebx
  801106:	75 ec                	jne    8010f4 <close_all+0xc>
		close(i);
}
  801108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 2c             	sub    $0x2c,%esp
  801116:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801119:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80111c:	50                   	push   %eax
  80111d:	ff 75 08             	pushl  0x8(%ebp)
  801120:	e8 6e fe ff ff       	call   800f93 <fd_lookup>
  801125:	83 c4 08             	add    $0x8,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	0f 88 c1 00 00 00    	js     8011f1 <dup+0xe4>
		return r;
	close(newfdnum);
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	56                   	push   %esi
  801134:	e8 84 ff ff ff       	call   8010bd <close>

	newfd = INDEX2FD(newfdnum);
  801139:	89 f3                	mov    %esi,%ebx
  80113b:	c1 e3 0c             	shl    $0xc,%ebx
  80113e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801144:	83 c4 04             	add    $0x4,%esp
  801147:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114a:	e8 de fd ff ff       	call   800f2d <fd2data>
  80114f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801151:	89 1c 24             	mov    %ebx,(%esp)
  801154:	e8 d4 fd ff ff       	call   800f2d <fd2data>
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115f:	89 f8                	mov    %edi,%eax
  801161:	c1 e8 16             	shr    $0x16,%eax
  801164:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80116b:	a8 01                	test   $0x1,%al
  80116d:	74 37                	je     8011a6 <dup+0x99>
  80116f:	89 f8                	mov    %edi,%eax
  801171:	c1 e8 0c             	shr    $0xc,%eax
  801174:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80117b:	f6 c2 01             	test   $0x1,%dl
  80117e:	74 26                	je     8011a6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801180:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801187:	83 ec 0c             	sub    $0xc,%esp
  80118a:	25 07 0e 00 00       	and    $0xe07,%eax
  80118f:	50                   	push   %eax
  801190:	ff 75 d4             	pushl  -0x2c(%ebp)
  801193:	6a 00                	push   $0x0
  801195:	57                   	push   %edi
  801196:	6a 00                	push   $0x0
  801198:	e8 d2 fb ff ff       	call   800d6f <sys_page_map>
  80119d:	89 c7                	mov    %eax,%edi
  80119f:	83 c4 20             	add    $0x20,%esp
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 2e                	js     8011d4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011a9:	89 d0                	mov    %edx,%eax
  8011ab:	c1 e8 0c             	shr    $0xc,%eax
  8011ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bd:	50                   	push   %eax
  8011be:	53                   	push   %ebx
  8011bf:	6a 00                	push   $0x0
  8011c1:	52                   	push   %edx
  8011c2:	6a 00                	push   $0x0
  8011c4:	e8 a6 fb ff ff       	call   800d6f <sys_page_map>
  8011c9:	89 c7                	mov    %eax,%edi
  8011cb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011ce:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d0:	85 ff                	test   %edi,%edi
  8011d2:	79 1d                	jns    8011f1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	53                   	push   %ebx
  8011d8:	6a 00                	push   $0x0
  8011da:	e8 d2 fb ff ff       	call   800db1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011df:	83 c4 08             	add    $0x8,%esp
  8011e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011e5:	6a 00                	push   $0x0
  8011e7:	e8 c5 fb ff ff       	call   800db1 <sys_page_unmap>
	return r;
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	89 f8                	mov    %edi,%eax
}
  8011f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 14             	sub    $0x14,%esp
  801200:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801203:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	53                   	push   %ebx
  801208:	e8 86 fd ff ff       	call   800f93 <fd_lookup>
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	89 c2                	mov    %eax,%edx
  801212:	85 c0                	test   %eax,%eax
  801214:	78 6d                	js     801283 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801220:	ff 30                	pushl  (%eax)
  801222:	e8 c2 fd ff ff       	call   800fe9 <dev_lookup>
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 4c                	js     80127a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80122e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801231:	8b 42 08             	mov    0x8(%edx),%eax
  801234:	83 e0 03             	and    $0x3,%eax
  801237:	83 f8 01             	cmp    $0x1,%eax
  80123a:	75 21                	jne    80125d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80123c:	a1 04 40 80 00       	mov    0x804004,%eax
  801241:	8b 40 48             	mov    0x48(%eax),%eax
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	53                   	push   %ebx
  801248:	50                   	push   %eax
  801249:	68 70 24 80 00       	push   $0x802470
  80124e:	e8 07 f1 ff ff       	call   80035a <cprintf>
		return -E_INVAL;
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80125b:	eb 26                	jmp    801283 <read+0x8a>
	}
	if (!dev->dev_read)
  80125d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801260:	8b 40 08             	mov    0x8(%eax),%eax
  801263:	85 c0                	test   %eax,%eax
  801265:	74 17                	je     80127e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801267:	83 ec 04             	sub    $0x4,%esp
  80126a:	ff 75 10             	pushl  0x10(%ebp)
  80126d:	ff 75 0c             	pushl  0xc(%ebp)
  801270:	52                   	push   %edx
  801271:	ff d0                	call   *%eax
  801273:	89 c2                	mov    %eax,%edx
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	eb 09                	jmp    801283 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127a:	89 c2                	mov    %eax,%edx
  80127c:	eb 05                	jmp    801283 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80127e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801283:	89 d0                	mov    %edx,%eax
  801285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	57                   	push   %edi
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	8b 7d 08             	mov    0x8(%ebp),%edi
  801296:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801299:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129e:	eb 21                	jmp    8012c1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	89 f0                	mov    %esi,%eax
  8012a5:	29 d8                	sub    %ebx,%eax
  8012a7:	50                   	push   %eax
  8012a8:	89 d8                	mov    %ebx,%eax
  8012aa:	03 45 0c             	add    0xc(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	57                   	push   %edi
  8012af:	e8 45 ff ff ff       	call   8011f9 <read>
		if (m < 0)
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 10                	js     8012cb <readn+0x41>
			return m;
		if (m == 0)
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	74 0a                	je     8012c9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012bf:	01 c3                	add    %eax,%ebx
  8012c1:	39 f3                	cmp    %esi,%ebx
  8012c3:	72 db                	jb     8012a0 <readn+0x16>
  8012c5:	89 d8                	mov    %ebx,%eax
  8012c7:	eb 02                	jmp    8012cb <readn+0x41>
  8012c9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 14             	sub    $0x14,%esp
  8012da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	53                   	push   %ebx
  8012e2:	e8 ac fc ff ff       	call   800f93 <fd_lookup>
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 68                	js     801358 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fa:	ff 30                	pushl  (%eax)
  8012fc:	e8 e8 fc ff ff       	call   800fe9 <dev_lookup>
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 47                	js     80134f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801308:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130f:	75 21                	jne    801332 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801311:	a1 04 40 80 00       	mov    0x804004,%eax
  801316:	8b 40 48             	mov    0x48(%eax),%eax
  801319:	83 ec 04             	sub    $0x4,%esp
  80131c:	53                   	push   %ebx
  80131d:	50                   	push   %eax
  80131e:	68 8c 24 80 00       	push   $0x80248c
  801323:	e8 32 f0 ff ff       	call   80035a <cprintf>
		return -E_INVAL;
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801330:	eb 26                	jmp    801358 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801332:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801335:	8b 52 0c             	mov    0xc(%edx),%edx
  801338:	85 d2                	test   %edx,%edx
  80133a:	74 17                	je     801353 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133c:	83 ec 04             	sub    $0x4,%esp
  80133f:	ff 75 10             	pushl  0x10(%ebp)
  801342:	ff 75 0c             	pushl  0xc(%ebp)
  801345:	50                   	push   %eax
  801346:	ff d2                	call   *%edx
  801348:	89 c2                	mov    %eax,%edx
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	eb 09                	jmp    801358 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134f:	89 c2                	mov    %eax,%edx
  801351:	eb 05                	jmp    801358 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801353:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801358:	89 d0                	mov    %edx,%eax
  80135a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <seek>:

int
seek(int fdnum, off_t offset)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801365:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801368:	50                   	push   %eax
  801369:	ff 75 08             	pushl  0x8(%ebp)
  80136c:	e8 22 fc ff ff       	call   800f93 <fd_lookup>
  801371:	83 c4 08             	add    $0x8,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 0e                	js     801386 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801378:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801381:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	53                   	push   %ebx
  80138c:	83 ec 14             	sub    $0x14,%esp
  80138f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801392:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	53                   	push   %ebx
  801397:	e8 f7 fb ff ff       	call   800f93 <fd_lookup>
  80139c:	83 c4 08             	add    $0x8,%esp
  80139f:	89 c2                	mov    %eax,%edx
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 65                	js     80140a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ab:	50                   	push   %eax
  8013ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013af:	ff 30                	pushl  (%eax)
  8013b1:	e8 33 fc ff ff       	call   800fe9 <dev_lookup>
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 44                	js     801401 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c4:	75 21                	jne    8013e7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013cb:	8b 40 48             	mov    0x48(%eax),%eax
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	53                   	push   %ebx
  8013d2:	50                   	push   %eax
  8013d3:	68 4c 24 80 00       	push   $0x80244c
  8013d8:	e8 7d ef ff ff       	call   80035a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e5:	eb 23                	jmp    80140a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ea:	8b 52 18             	mov    0x18(%edx),%edx
  8013ed:	85 d2                	test   %edx,%edx
  8013ef:	74 14                	je     801405 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	ff 75 0c             	pushl  0xc(%ebp)
  8013f7:	50                   	push   %eax
  8013f8:	ff d2                	call   *%edx
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	eb 09                	jmp    80140a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801401:	89 c2                	mov    %eax,%edx
  801403:	eb 05                	jmp    80140a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801405:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80140a:	89 d0                	mov    %edx,%eax
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	53                   	push   %ebx
  801415:	83 ec 14             	sub    $0x14,%esp
  801418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 6c fb ff ff       	call   800f93 <fd_lookup>
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	89 c2                	mov    %eax,%edx
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 58                	js     801488 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	ff 30                	pushl  (%eax)
  80143c:	e8 a8 fb ff ff       	call   800fe9 <dev_lookup>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 37                	js     80147f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801448:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80144f:	74 32                	je     801483 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801451:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801454:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80145b:	00 00 00 
	stat->st_isdir = 0;
  80145e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801465:	00 00 00 
	stat->st_dev = dev;
  801468:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	53                   	push   %ebx
  801472:	ff 75 f0             	pushl  -0x10(%ebp)
  801475:	ff 50 14             	call   *0x14(%eax)
  801478:	89 c2                	mov    %eax,%edx
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	eb 09                	jmp    801488 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147f:	89 c2                	mov    %eax,%edx
  801481:	eb 05                	jmp    801488 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801483:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801488:	89 d0                	mov    %edx,%eax
  80148a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	6a 00                	push   $0x0
  801499:	ff 75 08             	pushl  0x8(%ebp)
  80149c:	e8 dc 01 00 00       	call   80167d <open>
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 1b                	js     8014c5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	ff 75 0c             	pushl  0xc(%ebp)
  8014b0:	50                   	push   %eax
  8014b1:	e8 5b ff ff ff       	call   801411 <fstat>
  8014b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b8:	89 1c 24             	mov    %ebx,(%esp)
  8014bb:	e8 fd fb ff ff       	call   8010bd <close>
	return r;
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	89 f0                	mov    %esi,%eax
}
  8014c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	89 c6                	mov    %eax,%esi
  8014d3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014d5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014dc:	75 12                	jne    8014f0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	6a 01                	push   $0x1
  8014e3:	e8 b8 07 00 00       	call   801ca0 <ipc_find_env>
  8014e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8014ed:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014f0:	6a 07                	push   $0x7
  8014f2:	68 00 50 80 00       	push   $0x805000
  8014f7:	56                   	push   %esi
  8014f8:	ff 35 00 40 80 00    	pushl  0x804000
  8014fe:	e8 5a 07 00 00       	call   801c5d <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801503:	83 c4 0c             	add    $0xc,%esp
  801506:	6a 00                	push   $0x0
  801508:	53                   	push   %ebx
  801509:	6a 00                	push   $0x0
  80150b:	e8 f0 06 00 00       	call   801c00 <ipc_recv>
}
  801510:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801513:	5b                   	pop    %ebx
  801514:	5e                   	pop    %esi
  801515:	5d                   	pop    %ebp
  801516:	c3                   	ret    

00801517 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80151d:	8b 45 08             	mov    0x8(%ebp),%eax
  801520:	8b 40 0c             	mov    0xc(%eax),%eax
  801523:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801528:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801530:	ba 00 00 00 00       	mov    $0x0,%edx
  801535:	b8 02 00 00 00       	mov    $0x2,%eax
  80153a:	e8 8d ff ff ff       	call   8014cc <fsipc>
}
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801547:	8b 45 08             	mov    0x8(%ebp),%eax
  80154a:	8b 40 0c             	mov    0xc(%eax),%eax
  80154d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801552:	ba 00 00 00 00       	mov    $0x0,%edx
  801557:	b8 06 00 00 00       	mov    $0x6,%eax
  80155c:	e8 6b ff ff ff       	call   8014cc <fsipc>
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80156d:	8b 45 08             	mov    0x8(%ebp),%eax
  801570:	8b 40 0c             	mov    0xc(%eax),%eax
  801573:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801578:	ba 00 00 00 00       	mov    $0x0,%edx
  80157d:	b8 05 00 00 00       	mov    $0x5,%eax
  801582:	e8 45 ff ff ff       	call   8014cc <fsipc>
  801587:	85 c0                	test   %eax,%eax
  801589:	78 2c                	js     8015b7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	68 00 50 80 00       	push   $0x805000
  801593:	53                   	push   %ebx
  801594:	e8 90 f3 ff ff       	call   800929 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801599:	a1 80 50 80 00       	mov    0x805080,%eax
  80159e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015a4:	a1 84 50 80 00       	mov    0x805084,%eax
  8015a9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015cb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015d1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015d6:	50                   	push   %eax
  8015d7:	ff 75 0c             	pushl  0xc(%ebp)
  8015da:	68 08 50 80 00       	push   $0x805008
  8015df:	e8 d7 f4 ff ff       	call   800abb <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8015e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e9:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ee:	e8 d9 fe ff ff       	call   8014cc <fsipc>
	//panic("devfile_write not implemented");
}
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801600:	8b 40 0c             	mov    0xc(%eax),%eax
  801603:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801608:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80160e:	ba 00 00 00 00       	mov    $0x0,%edx
  801613:	b8 03 00 00 00       	mov    $0x3,%eax
  801618:	e8 af fe ff ff       	call   8014cc <fsipc>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 51                	js     801674 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801623:	39 c6                	cmp    %eax,%esi
  801625:	73 19                	jae    801640 <devfile_read+0x4b>
  801627:	68 bc 24 80 00       	push   $0x8024bc
  80162c:	68 c3 24 80 00       	push   $0x8024c3
  801631:	68 80 00 00 00       	push   $0x80
  801636:	68 d8 24 80 00       	push   $0x8024d8
  80163b:	e8 41 ec ff ff       	call   800281 <_panic>
	assert(r <= PGSIZE);
  801640:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801645:	7e 19                	jle    801660 <devfile_read+0x6b>
  801647:	68 e3 24 80 00       	push   $0x8024e3
  80164c:	68 c3 24 80 00       	push   $0x8024c3
  801651:	68 81 00 00 00       	push   $0x81
  801656:	68 d8 24 80 00       	push   $0x8024d8
  80165b:	e8 21 ec ff ff       	call   800281 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801660:	83 ec 04             	sub    $0x4,%esp
  801663:	50                   	push   %eax
  801664:	68 00 50 80 00       	push   $0x805000
  801669:	ff 75 0c             	pushl  0xc(%ebp)
  80166c:	e8 4a f4 ff ff       	call   800abb <memmove>
	return r;
  801671:	83 c4 10             	add    $0x10,%esp
}
  801674:	89 d8                	mov    %ebx,%eax
  801676:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	53                   	push   %ebx
  801681:	83 ec 20             	sub    $0x20,%esp
  801684:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801687:	53                   	push   %ebx
  801688:	e8 63 f2 ff ff       	call   8008f0 <strlen>
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801695:	7f 67                	jg     8016fe <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801697:	83 ec 0c             	sub    $0xc,%esp
  80169a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	e8 a1 f8 ff ff       	call   800f44 <fd_alloc>
  8016a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 57                	js     801703 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	53                   	push   %ebx
  8016b0:	68 00 50 80 00       	push   $0x805000
  8016b5:	e8 6f f2 ff ff       	call   800929 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016bd:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8016ca:	e8 fd fd ff ff       	call   8014cc <fsipc>
  8016cf:	89 c3                	mov    %eax,%ebx
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	79 14                	jns    8016ec <open+0x6f>
		
		fd_close(fd, 0);
  8016d8:	83 ec 08             	sub    $0x8,%esp
  8016db:	6a 00                	push   $0x0
  8016dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e0:	e8 57 f9 ff ff       	call   80103c <fd_close>
		return r;
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	89 da                	mov    %ebx,%edx
  8016ea:	eb 17                	jmp    801703 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8016ec:	83 ec 0c             	sub    $0xc,%esp
  8016ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f2:	e8 26 f8 ff ff       	call   800f1d <fd2num>
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	eb 05                	jmp    801703 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016fe:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801703:	89 d0                	mov    %edx,%eax
  801705:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801710:	ba 00 00 00 00       	mov    $0x0,%edx
  801715:	b8 08 00 00 00       	mov    $0x8,%eax
  80171a:	e8 ad fd ff ff       	call   8014cc <fsipc>
}
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801729:	83 ec 0c             	sub    $0xc,%esp
  80172c:	ff 75 08             	pushl  0x8(%ebp)
  80172f:	e8 f9 f7 ff ff       	call   800f2d <fd2data>
  801734:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801736:	83 c4 08             	add    $0x8,%esp
  801739:	68 ef 24 80 00       	push   $0x8024ef
  80173e:	53                   	push   %ebx
  80173f:	e8 e5 f1 ff ff       	call   800929 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801744:	8b 46 04             	mov    0x4(%esi),%eax
  801747:	2b 06                	sub    (%esi),%eax
  801749:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80174f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801756:	00 00 00 
	stat->st_dev = &devpipe;
  801759:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801760:	30 80 00 
	return 0;
}
  801763:	b8 00 00 00 00       	mov    $0x0,%eax
  801768:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	53                   	push   %ebx
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801779:	53                   	push   %ebx
  80177a:	6a 00                	push   $0x0
  80177c:	e8 30 f6 ff ff       	call   800db1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801781:	89 1c 24             	mov    %ebx,(%esp)
  801784:	e8 a4 f7 ff ff       	call   800f2d <fd2data>
  801789:	83 c4 08             	add    $0x8,%esp
  80178c:	50                   	push   %eax
  80178d:	6a 00                	push   $0x0
  80178f:	e8 1d f6 ff ff       	call   800db1 <sys_page_unmap>
}
  801794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	57                   	push   %edi
  80179d:	56                   	push   %esi
  80179e:	53                   	push   %ebx
  80179f:	83 ec 1c             	sub    $0x1c,%esp
  8017a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ac:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b5:	e8 1f 05 00 00       	call   801cd9 <pageref>
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	89 3c 24             	mov    %edi,(%esp)
  8017bf:	e8 15 05 00 00       	call   801cd9 <pageref>
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	39 c3                	cmp    %eax,%ebx
  8017c9:	0f 94 c1             	sete   %cl
  8017cc:	0f b6 c9             	movzbl %cl,%ecx
  8017cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017d2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017d8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017db:	39 ce                	cmp    %ecx,%esi
  8017dd:	74 1b                	je     8017fa <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017df:	39 c3                	cmp    %eax,%ebx
  8017e1:	75 c4                	jne    8017a7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017e3:	8b 42 58             	mov    0x58(%edx),%eax
  8017e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e9:	50                   	push   %eax
  8017ea:	56                   	push   %esi
  8017eb:	68 f6 24 80 00       	push   $0x8024f6
  8017f0:	e8 65 eb ff ff       	call   80035a <cprintf>
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	eb ad                	jmp    8017a7 <_pipeisclosed+0xe>
	}
}
  8017fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5f                   	pop    %edi
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	57                   	push   %edi
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	83 ec 28             	sub    $0x28,%esp
  80180e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801811:	56                   	push   %esi
  801812:	e8 16 f7 ff ff       	call   800f2d <fd2data>
  801817:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	bf 00 00 00 00       	mov    $0x0,%edi
  801821:	eb 4b                	jmp    80186e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801823:	89 da                	mov    %ebx,%edx
  801825:	89 f0                	mov    %esi,%eax
  801827:	e8 6d ff ff ff       	call   801799 <_pipeisclosed>
  80182c:	85 c0                	test   %eax,%eax
  80182e:	75 48                	jne    801878 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801830:	e8 d8 f4 ff ff       	call   800d0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801835:	8b 43 04             	mov    0x4(%ebx),%eax
  801838:	8b 0b                	mov    (%ebx),%ecx
  80183a:	8d 51 20             	lea    0x20(%ecx),%edx
  80183d:	39 d0                	cmp    %edx,%eax
  80183f:	73 e2                	jae    801823 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801844:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801848:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	c1 fa 1f             	sar    $0x1f,%edx
  801850:	89 d1                	mov    %edx,%ecx
  801852:	c1 e9 1b             	shr    $0x1b,%ecx
  801855:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801858:	83 e2 1f             	and    $0x1f,%edx
  80185b:	29 ca                	sub    %ecx,%edx
  80185d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801861:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801865:	83 c0 01             	add    $0x1,%eax
  801868:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80186b:	83 c7 01             	add    $0x1,%edi
  80186e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801871:	75 c2                	jne    801835 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801873:	8b 45 10             	mov    0x10(%ebp),%eax
  801876:	eb 05                	jmp    80187d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801878:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80187d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5f                   	pop    %edi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	57                   	push   %edi
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	83 ec 18             	sub    $0x18,%esp
  80188e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801891:	57                   	push   %edi
  801892:	e8 96 f6 ff ff       	call   800f2d <fd2data>
  801897:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a1:	eb 3d                	jmp    8018e0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018a3:	85 db                	test   %ebx,%ebx
  8018a5:	74 04                	je     8018ab <devpipe_read+0x26>
				return i;
  8018a7:	89 d8                	mov    %ebx,%eax
  8018a9:	eb 44                	jmp    8018ef <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018ab:	89 f2                	mov    %esi,%edx
  8018ad:	89 f8                	mov    %edi,%eax
  8018af:	e8 e5 fe ff ff       	call   801799 <_pipeisclosed>
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	75 32                	jne    8018ea <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018b8:	e8 50 f4 ff ff       	call   800d0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018bd:	8b 06                	mov    (%esi),%eax
  8018bf:	3b 46 04             	cmp    0x4(%esi),%eax
  8018c2:	74 df                	je     8018a3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018c4:	99                   	cltd   
  8018c5:	c1 ea 1b             	shr    $0x1b,%edx
  8018c8:	01 d0                	add    %edx,%eax
  8018ca:	83 e0 1f             	and    $0x1f,%eax
  8018cd:	29 d0                	sub    %edx,%eax
  8018cf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018da:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018dd:	83 c3 01             	add    $0x1,%ebx
  8018e0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018e3:	75 d8                	jne    8018bd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e8:	eb 05                	jmp    8018ef <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018ea:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f2:	5b                   	pop    %ebx
  8018f3:	5e                   	pop    %esi
  8018f4:	5f                   	pop    %edi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	56                   	push   %esi
  8018fb:	53                   	push   %ebx
  8018fc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801902:	50                   	push   %eax
  801903:	e8 3c f6 ff ff       	call   800f44 <fd_alloc>
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	85 c0                	test   %eax,%eax
  80190f:	0f 88 2c 01 00 00    	js     801a41 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801915:	83 ec 04             	sub    $0x4,%esp
  801918:	68 07 04 00 00       	push   $0x407
  80191d:	ff 75 f4             	pushl  -0xc(%ebp)
  801920:	6a 00                	push   $0x0
  801922:	e8 05 f4 ff ff       	call   800d2c <sys_page_alloc>
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	89 c2                	mov    %eax,%edx
  80192c:	85 c0                	test   %eax,%eax
  80192e:	0f 88 0d 01 00 00    	js     801a41 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801934:	83 ec 0c             	sub    $0xc,%esp
  801937:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193a:	50                   	push   %eax
  80193b:	e8 04 f6 ff ff       	call   800f44 <fd_alloc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	0f 88 e2 00 00 00    	js     801a2f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194d:	83 ec 04             	sub    $0x4,%esp
  801950:	68 07 04 00 00       	push   $0x407
  801955:	ff 75 f0             	pushl  -0x10(%ebp)
  801958:	6a 00                	push   $0x0
  80195a:	e8 cd f3 ff ff       	call   800d2c <sys_page_alloc>
  80195f:	89 c3                	mov    %eax,%ebx
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	0f 88 c3 00 00 00    	js     801a2f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80196c:	83 ec 0c             	sub    $0xc,%esp
  80196f:	ff 75 f4             	pushl  -0xc(%ebp)
  801972:	e8 b6 f5 ff ff       	call   800f2d <fd2data>
  801977:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801979:	83 c4 0c             	add    $0xc,%esp
  80197c:	68 07 04 00 00       	push   $0x407
  801981:	50                   	push   %eax
  801982:	6a 00                	push   $0x0
  801984:	e8 a3 f3 ff ff       	call   800d2c <sys_page_alloc>
  801989:	89 c3                	mov    %eax,%ebx
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	0f 88 89 00 00 00    	js     801a1f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	ff 75 f0             	pushl  -0x10(%ebp)
  80199c:	e8 8c f5 ff ff       	call   800f2d <fd2data>
  8019a1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019a8:	50                   	push   %eax
  8019a9:	6a 00                	push   $0x0
  8019ab:	56                   	push   %esi
  8019ac:	6a 00                	push   $0x0
  8019ae:	e8 bc f3 ff ff       	call   800d6f <sys_page_map>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	83 c4 20             	add    $0x20,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 55                	js     801a11 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019bc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019d1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019da:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019df:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ec:	e8 2c f5 ff ff       	call   800f1d <fd2num>
  8019f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019f6:	83 c4 04             	add    $0x4,%esp
  8019f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019fc:	e8 1c f5 ff ff       	call   800f1d <fd2num>
  801a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a04:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0f:	eb 30                	jmp    801a41 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	56                   	push   %esi
  801a15:	6a 00                	push   $0x0
  801a17:	e8 95 f3 ff ff       	call   800db1 <sys_page_unmap>
  801a1c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	ff 75 f0             	pushl  -0x10(%ebp)
  801a25:	6a 00                	push   $0x0
  801a27:	e8 85 f3 ff ff       	call   800db1 <sys_page_unmap>
  801a2c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a2f:	83 ec 08             	sub    $0x8,%esp
  801a32:	ff 75 f4             	pushl  -0xc(%ebp)
  801a35:	6a 00                	push   $0x0
  801a37:	e8 75 f3 ff ff       	call   800db1 <sys_page_unmap>
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a41:	89 d0                	mov    %edx,%eax
  801a43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a53:	50                   	push   %eax
  801a54:	ff 75 08             	pushl  0x8(%ebp)
  801a57:	e8 37 f5 ff ff       	call   800f93 <fd_lookup>
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 18                	js     801a7b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	ff 75 f4             	pushl  -0xc(%ebp)
  801a69:	e8 bf f4 ff ff       	call   800f2d <fd2data>
	return _pipeisclosed(fd, p);
  801a6e:	89 c2                	mov    %eax,%edx
  801a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a73:	e8 21 fd ff ff       	call   801799 <_pipeisclosed>
  801a78:	83 c4 10             	add    $0x10,%esp
}
  801a7b:	c9                   	leave  
  801a7c:	c3                   	ret    

00801a7d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a80:	b8 00 00 00 00       	mov    $0x0,%eax
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a8d:	68 0e 25 80 00       	push   $0x80250e
  801a92:	ff 75 0c             	pushl  0xc(%ebp)
  801a95:	e8 8f ee ff ff       	call   800929 <strcpy>
	return 0;
}
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	57                   	push   %edi
  801aa5:	56                   	push   %esi
  801aa6:	53                   	push   %ebx
  801aa7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aad:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ab2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab8:	eb 2d                	jmp    801ae7 <devcons_write+0x46>
		m = n - tot;
  801aba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801abd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801abf:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ac2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ac7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801aca:	83 ec 04             	sub    $0x4,%esp
  801acd:	53                   	push   %ebx
  801ace:	03 45 0c             	add    0xc(%ebp),%eax
  801ad1:	50                   	push   %eax
  801ad2:	57                   	push   %edi
  801ad3:	e8 e3 ef ff ff       	call   800abb <memmove>
		sys_cputs(buf, m);
  801ad8:	83 c4 08             	add    $0x8,%esp
  801adb:	53                   	push   %ebx
  801adc:	57                   	push   %edi
  801add:	e8 8e f1 ff ff       	call   800c70 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ae2:	01 de                	add    %ebx,%esi
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	89 f0                	mov    %esi,%eax
  801ae9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aec:	72 cc                	jb     801aba <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801aee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5f                   	pop    %edi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 08             	sub    $0x8,%esp
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b05:	74 2a                	je     801b31 <devcons_read+0x3b>
  801b07:	eb 05                	jmp    801b0e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b09:	e8 ff f1 ff ff       	call   800d0d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b0e:	e8 7b f1 ff ff       	call   800c8e <sys_cgetc>
  801b13:	85 c0                	test   %eax,%eax
  801b15:	74 f2                	je     801b09 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 16                	js     801b31 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b1b:	83 f8 04             	cmp    $0x4,%eax
  801b1e:	74 0c                	je     801b2c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b20:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b23:	88 02                	mov    %al,(%edx)
	return 1;
  801b25:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2a:	eb 05                	jmp    801b31 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b2c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b3f:	6a 01                	push   $0x1
  801b41:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b44:	50                   	push   %eax
  801b45:	e8 26 f1 ff ff       	call   800c70 <sys_cputs>
}
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    

00801b4f <getchar>:

int
getchar(void)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b55:	6a 01                	push   $0x1
  801b57:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b5a:	50                   	push   %eax
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 97 f6 ff ff       	call   8011f9 <read>
	if (r < 0)
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	85 c0                	test   %eax,%eax
  801b67:	78 0f                	js     801b78 <getchar+0x29>
		return r;
	if (r < 1)
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	7e 06                	jle    801b73 <getchar+0x24>
		return -E_EOF;
	return c;
  801b6d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b71:	eb 05                	jmp    801b78 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b73:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b83:	50                   	push   %eax
  801b84:	ff 75 08             	pushl  0x8(%ebp)
  801b87:	e8 07 f4 ff ff       	call   800f93 <fd_lookup>
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 11                	js     801ba4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b96:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b9c:	39 10                	cmp    %edx,(%eax)
  801b9e:	0f 94 c0             	sete   %al
  801ba1:	0f b6 c0             	movzbl %al,%eax
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <opencons>:

int
opencons(void)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801baf:	50                   	push   %eax
  801bb0:	e8 8f f3 ff ff       	call   800f44 <fd_alloc>
  801bb5:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	78 3e                	js     801bfc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bbe:	83 ec 04             	sub    $0x4,%esp
  801bc1:	68 07 04 00 00       	push   $0x407
  801bc6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 5c f1 ff ff       	call   800d2c <sys_page_alloc>
  801bd0:	83 c4 10             	add    $0x10,%esp
		return r;
  801bd3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 23                	js     801bfc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bd9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bee:	83 ec 0c             	sub    $0xc,%esp
  801bf1:	50                   	push   %eax
  801bf2:	e8 26 f3 ff ff       	call   800f1d <fd2num>
  801bf7:	89 c2                	mov    %eax,%edx
  801bf9:	83 c4 10             	add    $0x10,%esp
}
  801bfc:	89 d0                	mov    %edx,%eax
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c08:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	ff 75 0c             	pushl  0xc(%ebp)
  801c11:	e8 c6 f2 ff ff       	call   800edc <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 f6                	test   %esi,%esi
  801c1b:	74 1c                	je     801c39 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801c1d:	a1 04 40 80 00       	mov    0x804004,%eax
  801c22:	8b 40 78             	mov    0x78(%eax),%eax
  801c25:	89 06                	mov    %eax,(%esi)
  801c27:	eb 10                	jmp    801c39 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	68 1a 25 80 00       	push   $0x80251a
  801c31:	e8 24 e7 ff ff       	call   80035a <cprintf>
  801c36:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801c39:	a1 04 40 80 00       	mov    0x804004,%eax
  801c3e:	8b 50 74             	mov    0x74(%eax),%edx
  801c41:	85 d2                	test   %edx,%edx
  801c43:	74 e4                	je     801c29 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801c45:	85 db                	test   %ebx,%ebx
  801c47:	74 05                	je     801c4e <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801c49:	8b 40 74             	mov    0x74(%eax),%eax
  801c4c:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c4e:	a1 04 40 80 00       	mov    0x804004,%eax
  801c53:	8b 40 70             	mov    0x70(%eax),%eax

}
  801c56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c59:	5b                   	pop    %ebx
  801c5a:	5e                   	pop    %esi
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	57                   	push   %edi
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	83 ec 0c             	sub    $0xc,%esp
  801c66:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c69:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801c6f:	85 db                	test   %ebx,%ebx
  801c71:	75 13                	jne    801c86 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801c73:	6a 00                	push   $0x0
  801c75:	68 00 00 c0 ee       	push   $0xeec00000
  801c7a:	56                   	push   %esi
  801c7b:	57                   	push   %edi
  801c7c:	e8 38 f2 ff ff       	call   800eb9 <sys_ipc_try_send>
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	eb 0e                	jmp    801c94 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801c86:	ff 75 14             	pushl  0x14(%ebp)
  801c89:	53                   	push   %ebx
  801c8a:	56                   	push   %esi
  801c8b:	57                   	push   %edi
  801c8c:	e8 28 f2 ff ff       	call   800eb9 <sys_ipc_try_send>
  801c91:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801c94:	85 c0                	test   %eax,%eax
  801c96:	75 d7                	jne    801c6f <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9b:	5b                   	pop    %ebx
  801c9c:	5e                   	pop    %esi
  801c9d:	5f                   	pop    %edi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ca6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cab:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cae:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cb4:	8b 52 50             	mov    0x50(%edx),%edx
  801cb7:	39 ca                	cmp    %ecx,%edx
  801cb9:	75 0d                	jne    801cc8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cbb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cbe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cc3:	8b 40 48             	mov    0x48(%eax),%eax
  801cc6:	eb 0f                	jmp    801cd7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cc8:	83 c0 01             	add    $0x1,%eax
  801ccb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cd0:	75 d9                	jne    801cab <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    

00801cd9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cdf:	89 d0                	mov    %edx,%eax
  801ce1:	c1 e8 16             	shr    $0x16,%eax
  801ce4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ceb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cf0:	f6 c1 01             	test   $0x1,%cl
  801cf3:	74 1d                	je     801d12 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cf5:	c1 ea 0c             	shr    $0xc,%edx
  801cf8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cff:	f6 c2 01             	test   $0x1,%dl
  801d02:	74 0e                	je     801d12 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d04:	c1 ea 0c             	shr    $0xc,%edx
  801d07:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d0e:	ef 
  801d0f:	0f b7 c0             	movzwl %ax,%eax
}
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__udivdi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 f6                	test   %esi,%esi
  801d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d3d:	89 ca                	mov    %ecx,%edx
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	75 3d                	jne    801d80 <__udivdi3+0x60>
  801d43:	39 cf                	cmp    %ecx,%edi
  801d45:	0f 87 c5 00 00 00    	ja     801e10 <__udivdi3+0xf0>
  801d4b:	85 ff                	test   %edi,%edi
  801d4d:	89 fd                	mov    %edi,%ebp
  801d4f:	75 0b                	jne    801d5c <__udivdi3+0x3c>
  801d51:	b8 01 00 00 00       	mov    $0x1,%eax
  801d56:	31 d2                	xor    %edx,%edx
  801d58:	f7 f7                	div    %edi
  801d5a:	89 c5                	mov    %eax,%ebp
  801d5c:	89 c8                	mov    %ecx,%eax
  801d5e:	31 d2                	xor    %edx,%edx
  801d60:	f7 f5                	div    %ebp
  801d62:	89 c1                	mov    %eax,%ecx
  801d64:	89 d8                	mov    %ebx,%eax
  801d66:	89 cf                	mov    %ecx,%edi
  801d68:	f7 f5                	div    %ebp
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	39 ce                	cmp    %ecx,%esi
  801d82:	77 74                	ja     801df8 <__udivdi3+0xd8>
  801d84:	0f bd fe             	bsr    %esi,%edi
  801d87:	83 f7 1f             	xor    $0x1f,%edi
  801d8a:	0f 84 98 00 00 00    	je     801e28 <__udivdi3+0x108>
  801d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	89 c5                	mov    %eax,%ebp
  801d99:	29 fb                	sub    %edi,%ebx
  801d9b:	d3 e6                	shl    %cl,%esi
  801d9d:	89 d9                	mov    %ebx,%ecx
  801d9f:	d3 ed                	shr    %cl,%ebp
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	d3 e0                	shl    %cl,%eax
  801da5:	09 ee                	or     %ebp,%esi
  801da7:	89 d9                	mov    %ebx,%ecx
  801da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dad:	89 d5                	mov    %edx,%ebp
  801daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801db3:	d3 ed                	shr    %cl,%ebp
  801db5:	89 f9                	mov    %edi,%ecx
  801db7:	d3 e2                	shl    %cl,%edx
  801db9:	89 d9                	mov    %ebx,%ecx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	09 c2                	or     %eax,%edx
  801dbf:	89 d0                	mov    %edx,%eax
  801dc1:	89 ea                	mov    %ebp,%edx
  801dc3:	f7 f6                	div    %esi
  801dc5:	89 d5                	mov    %edx,%ebp
  801dc7:	89 c3                	mov    %eax,%ebx
  801dc9:	f7 64 24 0c          	mull   0xc(%esp)
  801dcd:	39 d5                	cmp    %edx,%ebp
  801dcf:	72 10                	jb     801de1 <__udivdi3+0xc1>
  801dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801dd5:	89 f9                	mov    %edi,%ecx
  801dd7:	d3 e6                	shl    %cl,%esi
  801dd9:	39 c6                	cmp    %eax,%esi
  801ddb:	73 07                	jae    801de4 <__udivdi3+0xc4>
  801ddd:	39 d5                	cmp    %edx,%ebp
  801ddf:	75 03                	jne    801de4 <__udivdi3+0xc4>
  801de1:	83 eb 01             	sub    $0x1,%ebx
  801de4:	31 ff                	xor    %edi,%edi
  801de6:	89 d8                	mov    %ebx,%eax
  801de8:	89 fa                	mov    %edi,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	31 ff                	xor    %edi,%edi
  801dfa:	31 db                	xor    %ebx,%ebx
  801dfc:	89 d8                	mov    %ebx,%eax
  801dfe:	89 fa                	mov    %edi,%edx
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
  801e08:	90                   	nop
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	f7 f7                	div    %edi
  801e14:	31 ff                	xor    %edi,%edi
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	89 fa                	mov    %edi,%edx
  801e1c:	83 c4 1c             	add    $0x1c,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	39 ce                	cmp    %ecx,%esi
  801e2a:	72 0c                	jb     801e38 <__udivdi3+0x118>
  801e2c:	31 db                	xor    %ebx,%ebx
  801e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e32:	0f 87 34 ff ff ff    	ja     801d6c <__udivdi3+0x4c>
  801e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e3d:	e9 2a ff ff ff       	jmp    801d6c <__udivdi3+0x4c>
  801e42:	66 90                	xchg   %ax,%ax
  801e44:	66 90                	xchg   %ax,%ax
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__umoddi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
  801e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e67:	85 d2                	test   %edx,%edx
  801e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e71:	89 f3                	mov    %esi,%ebx
  801e73:	89 3c 24             	mov    %edi,(%esp)
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	75 1c                	jne    801e98 <__umoddi3+0x48>
  801e7c:	39 f7                	cmp    %esi,%edi
  801e7e:	76 50                	jbe    801ed0 <__umoddi3+0x80>
  801e80:	89 c8                	mov    %ecx,%eax
  801e82:	89 f2                	mov    %esi,%edx
  801e84:	f7 f7                	div    %edi
  801e86:	89 d0                	mov    %edx,%eax
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	83 c4 1c             	add    $0x1c,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    
  801e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e98:	39 f2                	cmp    %esi,%edx
  801e9a:	89 d0                	mov    %edx,%eax
  801e9c:	77 52                	ja     801ef0 <__umoddi3+0xa0>
  801e9e:	0f bd ea             	bsr    %edx,%ebp
  801ea1:	83 f5 1f             	xor    $0x1f,%ebp
  801ea4:	75 5a                	jne    801f00 <__umoddi3+0xb0>
  801ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eaa:	0f 82 e0 00 00 00    	jb     801f90 <__umoddi3+0x140>
  801eb0:	39 0c 24             	cmp    %ecx,(%esp)
  801eb3:	0f 86 d7 00 00 00    	jbe    801f90 <__umoddi3+0x140>
  801eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ec1:	83 c4 1c             	add    $0x1c,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    
  801ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed0:	85 ff                	test   %edi,%edi
  801ed2:	89 fd                	mov    %edi,%ebp
  801ed4:	75 0b                	jne    801ee1 <__umoddi3+0x91>
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f7                	div    %edi
  801edf:	89 c5                	mov    %eax,%ebp
  801ee1:	89 f0                	mov    %esi,%eax
  801ee3:	31 d2                	xor    %edx,%edx
  801ee5:	f7 f5                	div    %ebp
  801ee7:	89 c8                	mov    %ecx,%eax
  801ee9:	f7 f5                	div    %ebp
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	eb 99                	jmp    801e88 <__umoddi3+0x38>
  801eef:	90                   	nop
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 f2                	mov    %esi,%edx
  801ef4:	83 c4 1c             	add    $0x1c,%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    
  801efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f00:	8b 34 24             	mov    (%esp),%esi
  801f03:	bf 20 00 00 00       	mov    $0x20,%edi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	29 ef                	sub    %ebp,%edi
  801f0c:	d3 e0                	shl    %cl,%eax
  801f0e:	89 f9                	mov    %edi,%ecx
  801f10:	89 f2                	mov    %esi,%edx
  801f12:	d3 ea                	shr    %cl,%edx
  801f14:	89 e9                	mov    %ebp,%ecx
  801f16:	09 c2                	or     %eax,%edx
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	89 14 24             	mov    %edx,(%esp)
  801f1d:	89 f2                	mov    %esi,%edx
  801f1f:	d3 e2                	shl    %cl,%edx
  801f21:	89 f9                	mov    %edi,%ecx
  801f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f2b:	d3 e8                	shr    %cl,%eax
  801f2d:	89 e9                	mov    %ebp,%ecx
  801f2f:	89 c6                	mov    %eax,%esi
  801f31:	d3 e3                	shl    %cl,%ebx
  801f33:	89 f9                	mov    %edi,%ecx
  801f35:	89 d0                	mov    %edx,%eax
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 e9                	mov    %ebp,%ecx
  801f3b:	09 d8                	or     %ebx,%eax
  801f3d:	89 d3                	mov    %edx,%ebx
  801f3f:	89 f2                	mov    %esi,%edx
  801f41:	f7 34 24             	divl   (%esp)
  801f44:	89 d6                	mov    %edx,%esi
  801f46:	d3 e3                	shl    %cl,%ebx
  801f48:	f7 64 24 04          	mull   0x4(%esp)
  801f4c:	39 d6                	cmp    %edx,%esi
  801f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f52:	89 d1                	mov    %edx,%ecx
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	72 08                	jb     801f60 <__umoddi3+0x110>
  801f58:	75 11                	jne    801f6b <__umoddi3+0x11b>
  801f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f5e:	73 0b                	jae    801f6b <__umoddi3+0x11b>
  801f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f64:	1b 14 24             	sbb    (%esp),%edx
  801f67:	89 d1                	mov    %edx,%ecx
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f6f:	29 da                	sub    %ebx,%edx
  801f71:	19 ce                	sbb    %ecx,%esi
  801f73:	89 f9                	mov    %edi,%ecx
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	d3 e0                	shl    %cl,%eax
  801f79:	89 e9                	mov    %ebp,%ecx
  801f7b:	d3 ea                	shr    %cl,%edx
  801f7d:	89 e9                	mov    %ebp,%ecx
  801f7f:	d3 ee                	shr    %cl,%esi
  801f81:	09 d0                	or     %edx,%eax
  801f83:	89 f2                	mov    %esi,%edx
  801f85:	83 c4 1c             	add    $0x1c,%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    
  801f8d:	8d 76 00             	lea    0x0(%esi),%esi
  801f90:	29 f9                	sub    %edi,%ecx
  801f92:	19 d6                	sbb    %edx,%esi
  801f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f9c:	e9 18 ff ff ff       	jmp    801eb9 <__umoddi3+0x69>
