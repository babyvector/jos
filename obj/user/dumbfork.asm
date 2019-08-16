
obj/user/dumbfork:     file format elf32-i386


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
  800045:	e8 da 0c 00 00       	call   800d24 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 80 11 80 00       	push   $0x801180
  800057:	6a 1f                	push   $0x1f
  800059:	68 93 11 80 00       	push   $0x801193
  80005e:	e8 16 02 00 00       	call   800279 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 f1 0c 00 00       	call   800d67 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 a3 11 80 00       	push   $0x8011a3
  800083:	6a 21                	push   $0x21
  800085:	68 93 11 80 00       	push   $0x801193
  80008a:	e8 ea 01 00 00       	call   800279 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 11 0a 00 00       	call   800ab3 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 f8 0c 00 00       	call   800da9 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 b4 11 80 00       	push   $0x8011b4
  8000be:	6a 24                	push   $0x24
  8000c0:	68 93 11 80 00       	push   $0x801193
  8000c5:	e8 af 01 00 00       	call   800279 <_panic>
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
  8000e5:	68 c7 11 80 00       	push   $0x8011c7
  8000ea:	e8 63 02 00 00       	call   800352 <cprintf>
	if (envid < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 db                	test   %ebx,%ebx
  8000f4:	79 12                	jns    800108 <dumbfork+0x37>
		panic("sys_exofork: %e", envid);
  8000f6:	53                   	push   %ebx
  8000f7:	68 e1 11 80 00       	push   $0x8011e1
  8000fc:	6a 37                	push   $0x37
  8000fe:	68 93 11 80 00       	push   $0x801193
  800103:	e8 71 01 00 00       	call   800279 <_panic>
	if (envid == 0) {
  800108:	85 db                	test   %ebx,%ebx
  80010a:	75 21                	jne    80012d <dumbfork+0x5c>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80010c:	e8 d5 0b 00 00       	call   800ce6 <sys_getenvid>
  800111:	25 ff 03 00 00       	and    $0x3ff,%eax
  800116:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800123:	b8 00 00 00 00       	mov    $0x0,%eax
  800128:	e9 89 00 00 00       	jmp    8001b6 <dumbfork+0xe5>
	}
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	cprintf("	AT before for duppage.\n");
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	68 f1 11 80 00       	push   $0x8011f1
  800135:	e8 18 02 00 00       	call   800352 <cprintf>
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
  80015d:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800163:	72 e1                	jb     800146 <dumbfork+0x75>
		duppage(envid, addr);
	cprintf(" NOW IN DUMBFORK.\n");	
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	68 0a 12 80 00       	push   $0x80120a
  80016d:	e8 e0 01 00 00       	call   800352 <cprintf>
	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800172:	83 c4 08             	add    $0x8,%esp
  800175:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800178:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80017d:	50                   	push   %eax
  80017e:	53                   	push   %ebx
  80017f:	e8 af fe ff ff       	call   800033 <duppage>
	cprintf("	after duppage(envid,ROUNDDOWN(&addr,PGSIZE))\n");
  800184:	c7 04 24 68 12 80 00 	movl   $0x801268,(%esp)
  80018b:	e8 c2 01 00 00       	call   800352 <cprintf>
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800190:	83 c4 08             	add    $0x8,%esp
  800193:	6a 02                	push   $0x2
  800195:	53                   	push   %ebx
  800196:	e8 50 0c 00 00       	call   800deb <sys_env_set_status>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <dumbfork+0xe3>
		panic("sys_env_set_status: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 1d 12 80 00       	push   $0x80121d
  8001a8:	6a 4c                	push   $0x4c
  8001aa:	68 93 11 80 00       	push   $0x801193
  8001af:	e8 c5 00 00 00       	call   800279 <_panic>

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
  8001cf:	be 3b 12 80 00       	mov    $0x80123b,%esi
  8001d4:	b8 34 12 80 00       	mov    $0x801234,%eax
  8001d9:	0f 45 f0             	cmovne %eax,%esi
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	eb 26                	jmp    800209 <umain+0x4c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	56                   	push   %esi
  8001e7:	53                   	push   %ebx
  8001e8:	68 41 12 80 00       	push   $0x801241
  8001ed:	e8 60 01 00 00       	call   800352 <cprintf>
		sys_yield();
  8001f2:	e8 0e 0b 00 00       	call   800d05 <sys_yield>
		cprintf("	AFTER SYS_YIELD.\n");
  8001f7:	c7 04 24 53 12 80 00 	movl   $0x801253,(%esp)
  8001fe:	e8 4f 01 00 00       	call   800352 <cprintf>
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
  80022c:	e8 b5 0a 00 00       	call   800ce6 <sys_getenvid>
  800231:	25 ff 03 00 00       	and    $0x3ff,%eax
  800236:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800239:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800243:	85 db                	test   %ebx,%ebx
  800245:	7e 07                	jle    80024e <libmain+0x2d>
		binaryname = argv[0];
  800247:	8b 06                	mov    (%esi),%eax
  800249:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80026a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80026d:	6a 00                	push   $0x0
  80026f:	e8 31 0a 00 00       	call   800ca5 <sys_env_destroy>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80027e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800281:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800287:	e8 5a 0a 00 00       	call   800ce6 <sys_getenvid>
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	ff 75 0c             	pushl  0xc(%ebp)
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	56                   	push   %esi
  800296:	50                   	push   %eax
  800297:	68 a4 12 80 00       	push   $0x8012a4
  80029c:	e8 b1 00 00 00       	call   800352 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002a1:	83 c4 18             	add    $0x18,%esp
  8002a4:	53                   	push   %ebx
  8002a5:	ff 75 10             	pushl  0x10(%ebp)
  8002a8:	e8 54 00 00 00       	call   800301 <vcprintf>
	cprintf("\n");
  8002ad:	c7 04 24 51 12 80 00 	movl   $0x801251,(%esp)
  8002b4:	e8 99 00 00 00       	call   800352 <cprintf>
  8002b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002bc:	cc                   	int3   
  8002bd:	eb fd                	jmp    8002bc <_panic+0x43>

008002bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 04             	sub    $0x4,%esp
  8002c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002c9:	8b 13                	mov    (%ebx),%edx
  8002cb:	8d 42 01             	lea    0x1(%edx),%eax
  8002ce:	89 03                	mov    %eax,(%ebx)
  8002d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002dc:	75 1a                	jne    8002f8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	68 ff 00 00 00       	push   $0xff
  8002e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002e9:	50                   	push   %eax
  8002ea:	e8 79 09 00 00       	call   800c68 <sys_cputs>
		b->idx = 0;
  8002ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002f5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ff:	c9                   	leave  
  800300:	c3                   	ret    

00800301 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80030a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800311:	00 00 00 
	b.cnt = 0;
  800314:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80031b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80032a:	50                   	push   %eax
  80032b:	68 bf 02 80 00       	push   $0x8002bf
  800330:	e8 54 01 00 00       	call   800489 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800335:	83 c4 08             	add    $0x8,%esp
  800338:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80033e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800344:	50                   	push   %eax
  800345:	e8 1e 09 00 00       	call   800c68 <sys_cputs>

	return b.cnt;
}
  80034a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800350:	c9                   	leave  
  800351:	c3                   	ret    

00800352 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800358:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80035b:	50                   	push   %eax
  80035c:	ff 75 08             	pushl  0x8(%ebp)
  80035f:	e8 9d ff ff ff       	call   800301 <vcprintf>
	va_end(ap);

	return cnt;
}
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
  80036c:	83 ec 1c             	sub    $0x1c,%esp
  80036f:	89 c7                	mov    %eax,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	8b 55 0c             	mov    0xc(%ebp),%edx
  800379:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80037c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80037f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800382:	bb 00 00 00 00       	mov    $0x0,%ebx
  800387:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80038a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80038d:	39 d3                	cmp    %edx,%ebx
  80038f:	72 05                	jb     800396 <printnum+0x30>
  800391:	39 45 10             	cmp    %eax,0x10(%ebp)
  800394:	77 45                	ja     8003db <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800396:	83 ec 0c             	sub    $0xc,%esp
  800399:	ff 75 18             	pushl  0x18(%ebp)
  80039c:	8b 45 14             	mov    0x14(%ebp),%eax
  80039f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003a2:	53                   	push   %ebx
  8003a3:	ff 75 10             	pushl  0x10(%ebp)
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 26 0b 00 00       	call   800ee0 <__udivdi3>
  8003ba:	83 c4 18             	add    $0x18,%esp
  8003bd:	52                   	push   %edx
  8003be:	50                   	push   %eax
  8003bf:	89 f2                	mov    %esi,%edx
  8003c1:	89 f8                	mov    %edi,%eax
  8003c3:	e8 9e ff ff ff       	call   800366 <printnum>
  8003c8:	83 c4 20             	add    $0x20,%esp
  8003cb:	eb 18                	jmp    8003e5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	56                   	push   %esi
  8003d1:	ff 75 18             	pushl  0x18(%ebp)
  8003d4:	ff d7                	call   *%edi
  8003d6:	83 c4 10             	add    $0x10,%esp
  8003d9:	eb 03                	jmp    8003de <printnum+0x78>
  8003db:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003de:	83 eb 01             	sub    $0x1,%ebx
  8003e1:	85 db                	test   %ebx,%ebx
  8003e3:	7f e8                	jg     8003cd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	56                   	push   %esi
  8003e9:	83 ec 04             	sub    $0x4,%esp
  8003ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f8:	e8 13 0c 00 00       	call   801010 <__umoddi3>
  8003fd:	83 c4 14             	add    $0x14,%esp
  800400:	0f be 80 c8 12 80 00 	movsbl 0x8012c8(%eax),%eax
  800407:	50                   	push   %eax
  800408:	ff d7                	call   *%edi
}
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800410:	5b                   	pop    %ebx
  800411:	5e                   	pop    %esi
  800412:	5f                   	pop    %edi
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800418:	83 fa 01             	cmp    $0x1,%edx
  80041b:	7e 0e                	jle    80042b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80041d:	8b 10                	mov    (%eax),%edx
  80041f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800422:	89 08                	mov    %ecx,(%eax)
  800424:	8b 02                	mov    (%edx),%eax
  800426:	8b 52 04             	mov    0x4(%edx),%edx
  800429:	eb 22                	jmp    80044d <getuint+0x38>
	else if (lflag)
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 10                	je     80043f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80042f:	8b 10                	mov    (%eax),%edx
  800431:	8d 4a 04             	lea    0x4(%edx),%ecx
  800434:	89 08                	mov    %ecx,(%eax)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	ba 00 00 00 00       	mov    $0x0,%edx
  80043d:	eb 0e                	jmp    80044d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80043f:	8b 10                	mov    (%eax),%edx
  800441:	8d 4a 04             	lea    0x4(%edx),%ecx
  800444:	89 08                	mov    %ecx,(%eax)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800455:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800459:	8b 10                	mov    (%eax),%edx
  80045b:	3b 50 04             	cmp    0x4(%eax),%edx
  80045e:	73 0a                	jae    80046a <sprintputch+0x1b>
		*b->buf++ = ch;
  800460:	8d 4a 01             	lea    0x1(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
  800468:	88 02                	mov    %al,(%edx)
}
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800472:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800475:	50                   	push   %eax
  800476:	ff 75 10             	pushl  0x10(%ebp)
  800479:	ff 75 0c             	pushl  0xc(%ebp)
  80047c:	ff 75 08             	pushl  0x8(%ebp)
  80047f:	e8 05 00 00 00       	call   800489 <vprintfmt>
	va_end(ap);
}
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	c9                   	leave  
  800488:	c3                   	ret    

00800489 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	57                   	push   %edi
  80048d:	56                   	push   %esi
  80048e:	53                   	push   %ebx
  80048f:	83 ec 2c             	sub    $0x2c,%esp
  800492:	8b 75 08             	mov    0x8(%ebp),%esi
  800495:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800498:	8b 7d 10             	mov    0x10(%ebp),%edi
  80049b:	eb 12                	jmp    8004af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049d:	85 c0                	test   %eax,%eax
  80049f:	0f 84 d3 03 00 00    	je     800878 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	53                   	push   %ebx
  8004a9:	50                   	push   %eax
  8004aa:	ff d6                	call   *%esi
  8004ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004af:	83 c7 01             	add    $0x1,%edi
  8004b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b6:	83 f8 25             	cmp    $0x25,%eax
  8004b9:	75 e2                	jne    80049d <vprintfmt+0x14>
  8004bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004c6:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d9:	eb 07                	jmp    8004e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8d 47 01             	lea    0x1(%edi),%eax
  8004e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e8:	0f b6 07             	movzbl (%edi),%eax
  8004eb:	0f b6 c8             	movzbl %al,%ecx
  8004ee:	83 e8 23             	sub    $0x23,%eax
  8004f1:	3c 55                	cmp    $0x55,%al
  8004f3:	0f 87 64 03 00 00    	ja     80085d <vprintfmt+0x3d4>
  8004f9:	0f b6 c0             	movzbl %al,%eax
  8004fc:	ff 24 85 80 13 80 00 	jmp    *0x801380(,%eax,4)
  800503:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800506:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80050a:	eb d6                	jmp    8004e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800517:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80051a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80051e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800521:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800524:	83 fa 09             	cmp    $0x9,%edx
  800527:	77 39                	ja     800562 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800529:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80052c:	eb e9                	jmp    800517 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 48 04             	lea    0x4(%eax),%ecx
  800534:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80053f:	eb 27                	jmp    800568 <vprintfmt+0xdf>
  800541:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800544:	85 c0                	test   %eax,%eax
  800546:	b9 00 00 00 00       	mov    $0x0,%ecx
  80054b:	0f 49 c8             	cmovns %eax,%ecx
  80054e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800554:	eb 8c                	jmp    8004e2 <vprintfmt+0x59>
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800559:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800560:	eb 80                	jmp    8004e2 <vprintfmt+0x59>
  800562:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800565:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800568:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80056c:	0f 89 70 ff ff ff    	jns    8004e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800572:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800575:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800578:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80057f:	e9 5e ff ff ff       	jmp    8004e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800584:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80058a:	e9 53 ff ff ff       	jmp    8004e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 04             	lea    0x4(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	53                   	push   %ebx
  80059c:	ff 30                	pushl  (%eax)
  80059e:	ff d6                	call   *%esi
			break;
  8005a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005a6:	e9 04 ff ff ff       	jmp    8004af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 50 04             	lea    0x4(%eax),%edx
  8005b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b4:	8b 00                	mov    (%eax),%eax
  8005b6:	99                   	cltd   
  8005b7:	31 d0                	xor    %edx,%eax
  8005b9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005bb:	83 f8 08             	cmp    $0x8,%eax
  8005be:	7f 0b                	jg     8005cb <vprintfmt+0x142>
  8005c0:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	75 18                	jne    8005e3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005cb:	50                   	push   %eax
  8005cc:	68 e0 12 80 00       	push   $0x8012e0
  8005d1:	53                   	push   %ebx
  8005d2:	56                   	push   %esi
  8005d3:	e8 94 fe ff ff       	call   80046c <printfmt>
  8005d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005de:	e9 cc fe ff ff       	jmp    8004af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005e3:	52                   	push   %edx
  8005e4:	68 e9 12 80 00       	push   $0x8012e9
  8005e9:	53                   	push   %ebx
  8005ea:	56                   	push   %esi
  8005eb:	e8 7c fe ff ff       	call   80046c <printfmt>
  8005f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f6:	e9 b4 fe ff ff       	jmp    8004af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800606:	85 ff                	test   %edi,%edi
  800608:	b8 d9 12 80 00       	mov    $0x8012d9,%eax
  80060d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800610:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800614:	0f 8e 94 00 00 00    	jle    8006ae <vprintfmt+0x225>
  80061a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80061e:	0f 84 98 00 00 00    	je     8006bc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	ff 75 c8             	pushl  -0x38(%ebp)
  80062a:	57                   	push   %edi
  80062b:	e8 d0 02 00 00       	call   800900 <strnlen>
  800630:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800633:	29 c1                	sub    %eax,%ecx
  800635:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800638:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80063b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80063f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800642:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800645:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800647:	eb 0f                	jmp    800658 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	ff 75 e0             	pushl  -0x20(%ebp)
  800650:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800652:	83 ef 01             	sub    $0x1,%edi
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 ff                	test   %edi,%edi
  80065a:	7f ed                	jg     800649 <vprintfmt+0x1c0>
  80065c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80065f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800662:	85 c9                	test   %ecx,%ecx
  800664:	b8 00 00 00 00       	mov    $0x0,%eax
  800669:	0f 49 c1             	cmovns %ecx,%eax
  80066c:	29 c1                	sub    %eax,%ecx
  80066e:	89 75 08             	mov    %esi,0x8(%ebp)
  800671:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800674:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800677:	89 cb                	mov    %ecx,%ebx
  800679:	eb 4d                	jmp    8006c8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80067b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067f:	74 1b                	je     80069c <vprintfmt+0x213>
  800681:	0f be c0             	movsbl %al,%eax
  800684:	83 e8 20             	sub    $0x20,%eax
  800687:	83 f8 5e             	cmp    $0x5e,%eax
  80068a:	76 10                	jbe    80069c <vprintfmt+0x213>
					putch('?', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	6a 3f                	push   $0x3f
  800694:	ff 55 08             	call   *0x8(%ebp)
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	eb 0d                	jmp    8006a9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff 55 08             	call   *0x8(%ebp)
  8006a6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a9:	83 eb 01             	sub    $0x1,%ebx
  8006ac:	eb 1a                	jmp    8006c8 <vprintfmt+0x23f>
  8006ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b1:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ba:	eb 0c                	jmp    8006c8 <vprintfmt+0x23f>
  8006bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006bf:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006c8:	83 c7 01             	add    $0x1,%edi
  8006cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006cf:	0f be d0             	movsbl %al,%edx
  8006d2:	85 d2                	test   %edx,%edx
  8006d4:	74 23                	je     8006f9 <vprintfmt+0x270>
  8006d6:	85 f6                	test   %esi,%esi
  8006d8:	78 a1                	js     80067b <vprintfmt+0x1f2>
  8006da:	83 ee 01             	sub    $0x1,%esi
  8006dd:	79 9c                	jns    80067b <vprintfmt+0x1f2>
  8006df:	89 df                	mov    %ebx,%edi
  8006e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e7:	eb 18                	jmp    800701 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	6a 20                	push   $0x20
  8006ef:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f1:	83 ef 01             	sub    $0x1,%edi
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 08                	jmp    800701 <vprintfmt+0x278>
  8006f9:	89 df                	mov    %ebx,%edi
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800701:	85 ff                	test   %edi,%edi
  800703:	7f e4                	jg     8006e9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800708:	e9 a2 fd ff ff       	jmp    8004af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80070d:	83 fa 01             	cmp    $0x1,%edx
  800710:	7e 16                	jle    800728 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 08             	lea    0x8(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)
  80071b:	8b 50 04             	mov    0x4(%eax),%edx
  80071e:	8b 00                	mov    (%eax),%eax
  800720:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800723:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800726:	eb 32                	jmp    80075a <vprintfmt+0x2d1>
	else if (lflag)
  800728:	85 d2                	test   %edx,%edx
  80072a:	74 18                	je     800744 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80073a:	89 c1                	mov    %eax,%ecx
  80073c:	c1 f9 1f             	sar    $0x1f,%ecx
  80073f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800742:	eb 16                	jmp    80075a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 04             	lea    0x4(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)
  80074d:	8b 00                	mov    (%eax),%eax
  80074f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800752:	89 c1                	mov    %eax,%ecx
  800754:	c1 f9 1f             	sar    $0x1f,%ecx
  800757:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80075d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800760:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800763:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800766:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80076b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80076f:	0f 89 b0 00 00 00    	jns    800825 <vprintfmt+0x39c>
				putch('-', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 2d                	push   $0x2d
  80077b:	ff d6                	call   *%esi
				num = -(long long) num;
  80077d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800780:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800783:	f7 d8                	neg    %eax
  800785:	83 d2 00             	adc    $0x0,%edx
  800788:	f7 da                	neg    %edx
  80078a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800790:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800793:	b8 0a 00 00 00       	mov    $0xa,%eax
  800798:	e9 88 00 00 00       	jmp    800825 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a0:	e8 70 fc ff ff       	call   800415 <getuint>
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007ab:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007b0:	eb 73                	jmp    800825 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b5:	e8 5b fc ff ff       	call   800415 <getuint>
  8007ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	53                   	push   %ebx
  8007c4:	6a 58                	push   $0x58
  8007c6:	ff d6                	call   *%esi
			putch('X', putdat);
  8007c8:	83 c4 08             	add    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 58                	push   $0x58
  8007ce:	ff d6                	call   *%esi
			putch('X', putdat);
  8007d0:	83 c4 08             	add    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 58                	push   $0x58
  8007d6:	ff d6                	call   *%esi
			goto number;
  8007d8:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8007db:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8007e0:	eb 43                	jmp    800825 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	53                   	push   %ebx
  8007e6:	6a 30                	push   $0x30
  8007e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ea:	83 c4 08             	add    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	6a 78                	push   $0x78
  8007f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800802:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800805:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800808:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800810:	eb 13                	jmp    800825 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800812:	8d 45 14             	lea    0x14(%ebp),%eax
  800815:	e8 fb fb ff ff       	call   800415 <getuint>
  80081a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800820:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800825:	83 ec 0c             	sub    $0xc,%esp
  800828:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80082c:	52                   	push   %edx
  80082d:	ff 75 e0             	pushl  -0x20(%ebp)
  800830:	50                   	push   %eax
  800831:	ff 75 dc             	pushl  -0x24(%ebp)
  800834:	ff 75 d8             	pushl  -0x28(%ebp)
  800837:	89 da                	mov    %ebx,%edx
  800839:	89 f0                	mov    %esi,%eax
  80083b:	e8 26 fb ff ff       	call   800366 <printnum>
			break;
  800840:	83 c4 20             	add    $0x20,%esp
  800843:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800846:	e9 64 fc ff ff       	jmp    8004af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	53                   	push   %ebx
  80084f:	51                   	push   %ecx
  800850:	ff d6                	call   *%esi
			break;
  800852:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800858:	e9 52 fc ff ff       	jmp    8004af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 25                	push   $0x25
  800863:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	eb 03                	jmp    80086d <vprintfmt+0x3e4>
  80086a:	83 ef 01             	sub    $0x1,%edi
  80086d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800871:	75 f7                	jne    80086a <vprintfmt+0x3e1>
  800873:	e9 37 fc ff ff       	jmp    8004af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800878:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 18             	sub    $0x18,%esp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800893:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089d:	85 c0                	test   %eax,%eax
  80089f:	74 26                	je     8008c7 <vsnprintf+0x47>
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	7e 22                	jle    8008c7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a5:	ff 75 14             	pushl  0x14(%ebp)
  8008a8:	ff 75 10             	pushl  0x10(%ebp)
  8008ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ae:	50                   	push   %eax
  8008af:	68 4f 04 80 00       	push   $0x80044f
  8008b4:	e8 d0 fb ff ff       	call   800489 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 05                	jmp    8008cc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    

008008ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d7:	50                   	push   %eax
  8008d8:	ff 75 10             	pushl  0x10(%ebp)
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	ff 75 08             	pushl  0x8(%ebp)
  8008e1:	e8 9a ff ff ff       	call   800880 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	eb 03                	jmp    8008f8 <strlen+0x10>
		n++;
  8008f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fc:	75 f7                	jne    8008f5 <strlen+0xd>
		n++;
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800909:	ba 00 00 00 00       	mov    $0x0,%edx
  80090e:	eb 03                	jmp    800913 <strnlen+0x13>
		n++;
  800910:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800913:	39 c2                	cmp    %eax,%edx
  800915:	74 08                	je     80091f <strnlen+0x1f>
  800917:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80091b:	75 f3                	jne    800910 <strnlen+0x10>
  80091d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80092b:	89 c2                	mov    %eax,%edx
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800937:	88 5a ff             	mov    %bl,-0x1(%edx)
  80093a:	84 db                	test   %bl,%bl
  80093c:	75 ef                	jne    80092d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800948:	53                   	push   %ebx
  800949:	e8 9a ff ff ff       	call   8008e8 <strlen>
  80094e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800951:	ff 75 0c             	pushl  0xc(%ebp)
  800954:	01 d8                	add    %ebx,%eax
  800956:	50                   	push   %eax
  800957:	e8 c5 ff ff ff       	call   800921 <strcpy>
	return dst;
}
  80095c:	89 d8                	mov    %ebx,%eax
  80095e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 75 08             	mov    0x8(%ebp),%esi
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	89 f3                	mov    %esi,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800973:	89 f2                	mov    %esi,%edx
  800975:	eb 0f                	jmp    800986 <strncpy+0x23>
		*dst++ = *src;
  800977:	83 c2 01             	add    $0x1,%edx
  80097a:	0f b6 01             	movzbl (%ecx),%eax
  80097d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800980:	80 39 01             	cmpb   $0x1,(%ecx)
  800983:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800986:	39 da                	cmp    %ebx,%edx
  800988:	75 ed                	jne    800977 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80098a:	89 f0                	mov    %esi,%eax
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 75 08             	mov    0x8(%ebp),%esi
  800998:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099b:	8b 55 10             	mov    0x10(%ebp),%edx
  80099e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a0:	85 d2                	test   %edx,%edx
  8009a2:	74 21                	je     8009c5 <strlcpy+0x35>
  8009a4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a8:	89 f2                	mov    %esi,%edx
  8009aa:	eb 09                	jmp    8009b5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ac:	83 c2 01             	add    $0x1,%edx
  8009af:	83 c1 01             	add    $0x1,%ecx
  8009b2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b5:	39 c2                	cmp    %eax,%edx
  8009b7:	74 09                	je     8009c2 <strlcpy+0x32>
  8009b9:	0f b6 19             	movzbl (%ecx),%ebx
  8009bc:	84 db                	test   %bl,%bl
  8009be:	75 ec                	jne    8009ac <strlcpy+0x1c>
  8009c0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c5:	29 f0                	sub    %esi,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d4:	eb 06                	jmp    8009dc <strcmp+0x11>
		p++, q++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009dc:	0f b6 01             	movzbl (%ecx),%eax
  8009df:	84 c0                	test   %al,%al
  8009e1:	74 04                	je     8009e7 <strcmp+0x1c>
  8009e3:	3a 02                	cmp    (%edx),%al
  8009e5:	74 ef                	je     8009d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e7:	0f b6 c0             	movzbl %al,%eax
  8009ea:	0f b6 12             	movzbl (%edx),%edx
  8009ed:	29 d0                	sub    %edx,%eax
}
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fb:	89 c3                	mov    %eax,%ebx
  8009fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a00:	eb 06                	jmp    800a08 <strncmp+0x17>
		n--, p++, q++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a08:	39 d8                	cmp    %ebx,%eax
  800a0a:	74 15                	je     800a21 <strncmp+0x30>
  800a0c:	0f b6 08             	movzbl (%eax),%ecx
  800a0f:	84 c9                	test   %cl,%cl
  800a11:	74 04                	je     800a17 <strncmp+0x26>
  800a13:	3a 0a                	cmp    (%edx),%cl
  800a15:	74 eb                	je     800a02 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a17:	0f b6 00             	movzbl (%eax),%eax
  800a1a:	0f b6 12             	movzbl (%edx),%edx
  800a1d:	29 d0                	sub    %edx,%eax
  800a1f:	eb 05                	jmp    800a26 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a33:	eb 07                	jmp    800a3c <strchr+0x13>
		if (*s == c)
  800a35:	38 ca                	cmp    %cl,%dl
  800a37:	74 0f                	je     800a48 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	0f b6 10             	movzbl (%eax),%edx
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	75 f2                	jne    800a35 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	eb 03                	jmp    800a59 <strfind+0xf>
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5c:	38 ca                	cmp    %cl,%dl
  800a5e:	74 04                	je     800a64 <strfind+0x1a>
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 f2                	jne    800a56 <strfind+0xc>
			break;
	return (char *) s;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a72:	85 c9                	test   %ecx,%ecx
  800a74:	74 36                	je     800aac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a76:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7c:	75 28                	jne    800aa6 <memset+0x40>
  800a7e:	f6 c1 03             	test   $0x3,%cl
  800a81:	75 23                	jne    800aa6 <memset+0x40>
		c &= 0xFF;
  800a83:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a87:	89 d3                	mov    %edx,%ebx
  800a89:	c1 e3 08             	shl    $0x8,%ebx
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	c1 e6 18             	shl    $0x18,%esi
  800a91:	89 d0                	mov    %edx,%eax
  800a93:	c1 e0 10             	shl    $0x10,%eax
  800a96:	09 f0                	or     %esi,%eax
  800a98:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a9a:	89 d8                	mov    %ebx,%eax
  800a9c:	09 d0                	or     %edx,%eax
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
  800aa1:	fc                   	cld    
  800aa2:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa4:	eb 06                	jmp    800aac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	fc                   	cld    
  800aaa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aac:	89 f8                	mov    %edi,%eax
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac1:	39 c6                	cmp    %eax,%esi
  800ac3:	73 35                	jae    800afa <memmove+0x47>
  800ac5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac8:	39 d0                	cmp    %edx,%eax
  800aca:	73 2e                	jae    800afa <memmove+0x47>
		s += n;
		d += n;
  800acc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	09 fe                	or     %edi,%esi
  800ad3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad9:	75 13                	jne    800aee <memmove+0x3b>
  800adb:	f6 c1 03             	test   $0x3,%cl
  800ade:	75 0e                	jne    800aee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ae0:	83 ef 04             	sub    $0x4,%edi
  800ae3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae6:	c1 e9 02             	shr    $0x2,%ecx
  800ae9:	fd                   	std    
  800aea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aec:	eb 09                	jmp    800af7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aee:	83 ef 01             	sub    $0x1,%edi
  800af1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800af4:	fd                   	std    
  800af5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af7:	fc                   	cld    
  800af8:	eb 1d                	jmp    800b17 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afa:	89 f2                	mov    %esi,%edx
  800afc:	09 c2                	or     %eax,%edx
  800afe:	f6 c2 03             	test   $0x3,%dl
  800b01:	75 0f                	jne    800b12 <memmove+0x5f>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 0a                	jne    800b12 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b08:	c1 e9 02             	shr    $0x2,%ecx
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b10:	eb 05                	jmp    800b17 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	fc                   	cld    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1e:	ff 75 10             	pushl  0x10(%ebp)
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	ff 75 08             	pushl  0x8(%ebp)
  800b27:	e8 87 ff ff ff       	call   800ab3 <memmove>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 c6                	mov    %eax,%esi
  800b3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3e:	eb 1a                	jmp    800b5a <memcmp+0x2c>
		if (*s1 != *s2)
  800b40:	0f b6 08             	movzbl (%eax),%ecx
  800b43:	0f b6 1a             	movzbl (%edx),%ebx
  800b46:	38 d9                	cmp    %bl,%cl
  800b48:	74 0a                	je     800b54 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b4a:	0f b6 c1             	movzbl %cl,%eax
  800b4d:	0f b6 db             	movzbl %bl,%ebx
  800b50:	29 d8                	sub    %ebx,%eax
  800b52:	eb 0f                	jmp    800b63 <memcmp+0x35>
		s1++, s2++;
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5a:	39 f0                	cmp    %esi,%eax
  800b5c:	75 e2                	jne    800b40 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	53                   	push   %ebx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b6e:	89 c1                	mov    %eax,%ecx
  800b70:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b73:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b77:	eb 0a                	jmp    800b83 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b79:	0f b6 10             	movzbl (%eax),%edx
  800b7c:	39 da                	cmp    %ebx,%edx
  800b7e:	74 07                	je     800b87 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b80:	83 c0 01             	add    $0x1,%eax
  800b83:	39 c8                	cmp    %ecx,%eax
  800b85:	72 f2                	jb     800b79 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b87:	5b                   	pop    %ebx
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b96:	eb 03                	jmp    800b9b <strtol+0x11>
		s++;
  800b98:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	3c 20                	cmp    $0x20,%al
  800ba0:	74 f6                	je     800b98 <strtol+0xe>
  800ba2:	3c 09                	cmp    $0x9,%al
  800ba4:	74 f2                	je     800b98 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba6:	3c 2b                	cmp    $0x2b,%al
  800ba8:	75 0a                	jne    800bb4 <strtol+0x2a>
		s++;
  800baa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bad:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb2:	eb 11                	jmp    800bc5 <strtol+0x3b>
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	75 08                	jne    800bc5 <strtol+0x3b>
		s++, neg = 1;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bcb:	75 15                	jne    800be2 <strtol+0x58>
  800bcd:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd0:	75 10                	jne    800be2 <strtol+0x58>
  800bd2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd6:	75 7c                	jne    800c54 <strtol+0xca>
		s += 2, base = 16;
  800bd8:	83 c1 02             	add    $0x2,%ecx
  800bdb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be0:	eb 16                	jmp    800bf8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800be2:	85 db                	test   %ebx,%ebx
  800be4:	75 12                	jne    800bf8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800beb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bee:	75 08                	jne    800bf8 <strtol+0x6e>
		s++, base = 8;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c00:	0f b6 11             	movzbl (%ecx),%edx
  800c03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c06:	89 f3                	mov    %esi,%ebx
  800c08:	80 fb 09             	cmp    $0x9,%bl
  800c0b:	77 08                	ja     800c15 <strtol+0x8b>
			dig = *s - '0';
  800c0d:	0f be d2             	movsbl %dl,%edx
  800c10:	83 ea 30             	sub    $0x30,%edx
  800c13:	eb 22                	jmp    800c37 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c15:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c18:	89 f3                	mov    %esi,%ebx
  800c1a:	80 fb 19             	cmp    $0x19,%bl
  800c1d:	77 08                	ja     800c27 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c1f:	0f be d2             	movsbl %dl,%edx
  800c22:	83 ea 57             	sub    $0x57,%edx
  800c25:	eb 10                	jmp    800c37 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c27:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c2a:	89 f3                	mov    %esi,%ebx
  800c2c:	80 fb 19             	cmp    $0x19,%bl
  800c2f:	77 16                	ja     800c47 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c31:	0f be d2             	movsbl %dl,%edx
  800c34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c37:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c3a:	7d 0b                	jge    800c47 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c3c:	83 c1 01             	add    $0x1,%ecx
  800c3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c45:	eb b9                	jmp    800c00 <strtol+0x76>

	if (endptr)
  800c47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4b:	74 0d                	je     800c5a <strtol+0xd0>
		*endptr = (char *) s;
  800c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c50:	89 0e                	mov    %ecx,(%esi)
  800c52:	eb 06                	jmp    800c5a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c54:	85 db                	test   %ebx,%ebx
  800c56:	74 98                	je     800bf0 <strtol+0x66>
  800c58:	eb 9e                	jmp    800bf8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	f7 da                	neg    %edx
  800c5e:	85 ff                	test   %edi,%edi
  800c60:	0f 45 c2             	cmovne %edx,%eax
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 c3                	mov    %eax,%ebx
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	89 c6                	mov    %eax,%esi
  800c7f:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 cb                	mov    %ecx,%ebx
  800cbd:	89 cf                	mov    %ecx,%edi
  800cbf:	89 ce                	mov    %ecx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 03                	push   $0x3
  800ccd:	68 04 15 80 00       	push   $0x801504
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 21 15 80 00       	push   $0x801521
  800cd9:	e8 9b f5 ff ff       	call   800279 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf1:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf6:	89 d1                	mov    %edx,%ecx
  800cf8:	89 d3                	mov    %edx,%ebx
  800cfa:	89 d7                	mov    %edx,%edi
  800cfc:	89 d6                	mov    %edx,%esi
  800cfe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_yield>:

void
sys_yield(void)
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
  800d10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d2d:	be 00 00 00 00       	mov    $0x0,%esi
  800d32:	b8 04 00 00 00       	mov    $0x4,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d40:	89 f7                	mov    %esi,%edi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 04                	push   $0x4
  800d4e:	68 04 15 80 00       	push   $0x801504
  800d53:	6a 23                	push   $0x23
  800d55:	68 21 15 80 00       	push   $0x801521
  800d5a:	e8 1a f5 ff ff       	call   800279 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d70:	b8 05 00 00 00       	mov    $0x5,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	8b 75 18             	mov    0x18(%ebp),%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 05                	push   $0x5
  800d90:	68 04 15 80 00       	push   $0x801504
  800d95:	6a 23                	push   $0x23
  800d97:	68 21 15 80 00       	push   $0x801521
  800d9c:	e8 d8 f4 ff ff       	call   800279 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800db2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db7:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 17                	jle    800de3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 06                	push   $0x6
  800dd2:	68 04 15 80 00       	push   $0x801504
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 21 15 80 00       	push   $0x801521
  800dde:	e8 96 f4 ff ff       	call   800279 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800df4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df9:	b8 08 00 00 00       	mov    $0x8,%eax
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	89 df                	mov    %ebx,%edi
  800e06:	89 de                	mov    %ebx,%esi
  800e08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7e 17                	jle    800e25 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	6a 08                	push   $0x8
  800e14:	68 04 15 80 00       	push   $0x801504
  800e19:	6a 23                	push   $0x23
  800e1b:	68 21 15 80 00       	push   $0x801521
  800e20:	e8 54 f4 ff ff       	call   800279 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e43:	8b 55 08             	mov    0x8(%ebp),%edx
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 17                	jle    800e67 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	50                   	push   %eax
  800e54:	6a 09                	push   $0x9
  800e56:	68 04 15 80 00       	push   $0x801504
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 21 15 80 00       	push   $0x801521
  800e62:	e8 12 f4 ff ff       	call   800279 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e75:	be 00 00 00 00       	mov    $0x0,%esi
  800e7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	89 cb                	mov    %ecx,%ebx
  800eaa:	89 cf                	mov    %ecx,%edi
  800eac:	89 ce                	mov    %ecx,%esi
  800eae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7e 17                	jle    800ecb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	50                   	push   %eax
  800eb8:	6a 0c                	push   $0xc
  800eba:	68 04 15 80 00       	push   $0x801504
  800ebf:	6a 23                	push   $0x23
  800ec1:	68 21 15 80 00       	push   $0x801521
  800ec6:	e8 ae f3 ff ff       	call   800279 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    
  800ed3:	66 90                	xchg   %ax,%ax
  800ed5:	66 90                	xchg   %ax,%ax
  800ed7:	66 90                	xchg   %ax,%ax
  800ed9:	66 90                	xchg   %ax,%ax
  800edb:	66 90                	xchg   %ax,%ax
  800edd:	66 90                	xchg   %ax,%ax
  800edf:	90                   	nop

00800ee0 <__udivdi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 1c             	sub    $0x1c,%esp
  800ee7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800eeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800eef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ef7:	85 f6                	test   %esi,%esi
  800ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800efd:	89 ca                	mov    %ecx,%edx
  800eff:	89 f8                	mov    %edi,%eax
  800f01:	75 3d                	jne    800f40 <__udivdi3+0x60>
  800f03:	39 cf                	cmp    %ecx,%edi
  800f05:	0f 87 c5 00 00 00    	ja     800fd0 <__udivdi3+0xf0>
  800f0b:	85 ff                	test   %edi,%edi
  800f0d:	89 fd                	mov    %edi,%ebp
  800f0f:	75 0b                	jne    800f1c <__udivdi3+0x3c>
  800f11:	b8 01 00 00 00       	mov    $0x1,%eax
  800f16:	31 d2                	xor    %edx,%edx
  800f18:	f7 f7                	div    %edi
  800f1a:	89 c5                	mov    %eax,%ebp
  800f1c:	89 c8                	mov    %ecx,%eax
  800f1e:	31 d2                	xor    %edx,%edx
  800f20:	f7 f5                	div    %ebp
  800f22:	89 c1                	mov    %eax,%ecx
  800f24:	89 d8                	mov    %ebx,%eax
  800f26:	89 cf                	mov    %ecx,%edi
  800f28:	f7 f5                	div    %ebp
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	89 d8                	mov    %ebx,%eax
  800f2e:	89 fa                	mov    %edi,%edx
  800f30:	83 c4 1c             	add    $0x1c,%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
  800f38:	90                   	nop
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	39 ce                	cmp    %ecx,%esi
  800f42:	77 74                	ja     800fb8 <__udivdi3+0xd8>
  800f44:	0f bd fe             	bsr    %esi,%edi
  800f47:	83 f7 1f             	xor    $0x1f,%edi
  800f4a:	0f 84 98 00 00 00    	je     800fe8 <__udivdi3+0x108>
  800f50:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f55:	89 f9                	mov    %edi,%ecx
  800f57:	89 c5                	mov    %eax,%ebp
  800f59:	29 fb                	sub    %edi,%ebx
  800f5b:	d3 e6                	shl    %cl,%esi
  800f5d:	89 d9                	mov    %ebx,%ecx
  800f5f:	d3 ed                	shr    %cl,%ebp
  800f61:	89 f9                	mov    %edi,%ecx
  800f63:	d3 e0                	shl    %cl,%eax
  800f65:	09 ee                	or     %ebp,%esi
  800f67:	89 d9                	mov    %ebx,%ecx
  800f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6d:	89 d5                	mov    %edx,%ebp
  800f6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f73:	d3 ed                	shr    %cl,%ebp
  800f75:	89 f9                	mov    %edi,%ecx
  800f77:	d3 e2                	shl    %cl,%edx
  800f79:	89 d9                	mov    %ebx,%ecx
  800f7b:	d3 e8                	shr    %cl,%eax
  800f7d:	09 c2                	or     %eax,%edx
  800f7f:	89 d0                	mov    %edx,%eax
  800f81:	89 ea                	mov    %ebp,%edx
  800f83:	f7 f6                	div    %esi
  800f85:	89 d5                	mov    %edx,%ebp
  800f87:	89 c3                	mov    %eax,%ebx
  800f89:	f7 64 24 0c          	mull   0xc(%esp)
  800f8d:	39 d5                	cmp    %edx,%ebp
  800f8f:	72 10                	jb     800fa1 <__udivdi3+0xc1>
  800f91:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f95:	89 f9                	mov    %edi,%ecx
  800f97:	d3 e6                	shl    %cl,%esi
  800f99:	39 c6                	cmp    %eax,%esi
  800f9b:	73 07                	jae    800fa4 <__udivdi3+0xc4>
  800f9d:	39 d5                	cmp    %edx,%ebp
  800f9f:	75 03                	jne    800fa4 <__udivdi3+0xc4>
  800fa1:	83 eb 01             	sub    $0x1,%ebx
  800fa4:	31 ff                	xor    %edi,%edi
  800fa6:	89 d8                	mov    %ebx,%eax
  800fa8:	89 fa                	mov    %edi,%edx
  800faa:	83 c4 1c             	add    $0x1c,%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    
  800fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb8:	31 ff                	xor    %edi,%edi
  800fba:	31 db                	xor    %ebx,%ebx
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	89 fa                	mov    %edi,%edx
  800fc0:	83 c4 1c             	add    $0x1c,%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    
  800fc8:	90                   	nop
  800fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	f7 f7                	div    %edi
  800fd4:	31 ff                	xor    %edi,%edi
  800fd6:	89 c3                	mov    %eax,%ebx
  800fd8:	89 d8                	mov    %ebx,%eax
  800fda:	89 fa                	mov    %edi,%edx
  800fdc:	83 c4 1c             	add    $0x1c,%esp
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    
  800fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	39 ce                	cmp    %ecx,%esi
  800fea:	72 0c                	jb     800ff8 <__udivdi3+0x118>
  800fec:	31 db                	xor    %ebx,%ebx
  800fee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ff2:	0f 87 34 ff ff ff    	ja     800f2c <__udivdi3+0x4c>
  800ff8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ffd:	e9 2a ff ff ff       	jmp    800f2c <__udivdi3+0x4c>
  801002:	66 90                	xchg   %ax,%ax
  801004:	66 90                	xchg   %ax,%ax
  801006:	66 90                	xchg   %ax,%ax
  801008:	66 90                	xchg   %ax,%ax
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 1c             	sub    $0x1c,%esp
  801017:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80101b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80101f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801027:	85 d2                	test   %edx,%edx
  801029:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80102d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801031:	89 f3                	mov    %esi,%ebx
  801033:	89 3c 24             	mov    %edi,(%esp)
  801036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80103a:	75 1c                	jne    801058 <__umoddi3+0x48>
  80103c:	39 f7                	cmp    %esi,%edi
  80103e:	76 50                	jbe    801090 <__umoddi3+0x80>
  801040:	89 c8                	mov    %ecx,%eax
  801042:	89 f2                	mov    %esi,%edx
  801044:	f7 f7                	div    %edi
  801046:	89 d0                	mov    %edx,%eax
  801048:	31 d2                	xor    %edx,%edx
  80104a:	83 c4 1c             	add    $0x1c,%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    
  801052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801058:	39 f2                	cmp    %esi,%edx
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	77 52                	ja     8010b0 <__umoddi3+0xa0>
  80105e:	0f bd ea             	bsr    %edx,%ebp
  801061:	83 f5 1f             	xor    $0x1f,%ebp
  801064:	75 5a                	jne    8010c0 <__umoddi3+0xb0>
  801066:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80106a:	0f 82 e0 00 00 00    	jb     801150 <__umoddi3+0x140>
  801070:	39 0c 24             	cmp    %ecx,(%esp)
  801073:	0f 86 d7 00 00 00    	jbe    801150 <__umoddi3+0x140>
  801079:	8b 44 24 08          	mov    0x8(%esp),%eax
  80107d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801081:	83 c4 1c             	add    $0x1c,%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    
  801089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801090:	85 ff                	test   %edi,%edi
  801092:	89 fd                	mov    %edi,%ebp
  801094:	75 0b                	jne    8010a1 <__umoddi3+0x91>
  801096:	b8 01 00 00 00       	mov    $0x1,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	f7 f7                	div    %edi
  80109f:	89 c5                	mov    %eax,%ebp
  8010a1:	89 f0                	mov    %esi,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	f7 f5                	div    %ebp
  8010a7:	89 c8                	mov    %ecx,%eax
  8010a9:	f7 f5                	div    %ebp
  8010ab:	89 d0                	mov    %edx,%eax
  8010ad:	eb 99                	jmp    801048 <__umoddi3+0x38>
  8010af:	90                   	nop
  8010b0:	89 c8                	mov    %ecx,%eax
  8010b2:	89 f2                	mov    %esi,%edx
  8010b4:	83 c4 1c             	add    $0x1c,%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    
  8010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	8b 34 24             	mov    (%esp),%esi
  8010c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010c8:	89 e9                	mov    %ebp,%ecx
  8010ca:	29 ef                	sub    %ebp,%edi
  8010cc:	d3 e0                	shl    %cl,%eax
  8010ce:	89 f9                	mov    %edi,%ecx
  8010d0:	89 f2                	mov    %esi,%edx
  8010d2:	d3 ea                	shr    %cl,%edx
  8010d4:	89 e9                	mov    %ebp,%ecx
  8010d6:	09 c2                	or     %eax,%edx
  8010d8:	89 d8                	mov    %ebx,%eax
  8010da:	89 14 24             	mov    %edx,(%esp)
  8010dd:	89 f2                	mov    %esi,%edx
  8010df:	d3 e2                	shl    %cl,%edx
  8010e1:	89 f9                	mov    %edi,%ecx
  8010e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010eb:	d3 e8                	shr    %cl,%eax
  8010ed:	89 e9                	mov    %ebp,%ecx
  8010ef:	89 c6                	mov    %eax,%esi
  8010f1:	d3 e3                	shl    %cl,%ebx
  8010f3:	89 f9                	mov    %edi,%ecx
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	d3 e8                	shr    %cl,%eax
  8010f9:	89 e9                	mov    %ebp,%ecx
  8010fb:	09 d8                	or     %ebx,%eax
  8010fd:	89 d3                	mov    %edx,%ebx
  8010ff:	89 f2                	mov    %esi,%edx
  801101:	f7 34 24             	divl   (%esp)
  801104:	89 d6                	mov    %edx,%esi
  801106:	d3 e3                	shl    %cl,%ebx
  801108:	f7 64 24 04          	mull   0x4(%esp)
  80110c:	39 d6                	cmp    %edx,%esi
  80110e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801112:	89 d1                	mov    %edx,%ecx
  801114:	89 c3                	mov    %eax,%ebx
  801116:	72 08                	jb     801120 <__umoddi3+0x110>
  801118:	75 11                	jne    80112b <__umoddi3+0x11b>
  80111a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80111e:	73 0b                	jae    80112b <__umoddi3+0x11b>
  801120:	2b 44 24 04          	sub    0x4(%esp),%eax
  801124:	1b 14 24             	sbb    (%esp),%edx
  801127:	89 d1                	mov    %edx,%ecx
  801129:	89 c3                	mov    %eax,%ebx
  80112b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80112f:	29 da                	sub    %ebx,%edx
  801131:	19 ce                	sbb    %ecx,%esi
  801133:	89 f9                	mov    %edi,%ecx
  801135:	89 f0                	mov    %esi,%eax
  801137:	d3 e0                	shl    %cl,%eax
  801139:	89 e9                	mov    %ebp,%ecx
  80113b:	d3 ea                	shr    %cl,%edx
  80113d:	89 e9                	mov    %ebp,%ecx
  80113f:	d3 ee                	shr    %cl,%esi
  801141:	09 d0                	or     %edx,%eax
  801143:	89 f2                	mov    %esi,%edx
  801145:	83 c4 1c             	add    $0x1c,%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    
  80114d:	8d 76 00             	lea    0x0(%esi),%esi
  801150:	29 f9                	sub    %edi,%ecx
  801152:	19 d6                	sbb    %edx,%esi
  801154:	89 74 24 04          	mov    %esi,0x4(%esp)
  801158:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80115c:	e9 18 ff ff ff       	jmp    801079 <__umoddi3+0x69>
