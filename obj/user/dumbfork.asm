
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
  80002c:	e8 0d 02 00 00       	call   80023e <libmain>
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
  800045:	e8 f7 0c 00 00       	call   800d41 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 80 11 80 00       	push   $0x801180
  800057:	6a 1f                	push   $0x1f
  800059:	68 93 11 80 00       	push   $0x801193
  80005e:	e8 33 02 00 00       	call   800296 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 0e 0d 00 00       	call   800d84 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 a3 11 80 00       	push   $0x8011a3
  800083:	6a 21                	push   $0x21
  800085:	68 93 11 80 00       	push   $0x801193
  80008a:	e8 07 02 00 00       	call   800296 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 2e 0a 00 00       	call   800ad0 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 15 0d 00 00       	call   800dc6 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 b4 11 80 00       	push   $0x8011b4
  8000be:	6a 24                	push   $0x24
  8000c0:	68 93 11 80 00       	push   $0x801193
  8000c5:	e8 cc 01 00 00       	call   800296 <_panic>
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
  8000d6:	83 ec 1c             	sub    $0x1c,%esp
	// Allocate a new child environment.
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	cprintf("! IN THE DUMBFORK.\n");
  8000d9:	68 c7 11 80 00       	push   $0x8011c7
  8000de:	e8 8c 02 00 00       	call   80036f <cprintf>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000e3:	b8 07 00 00 00       	mov    $0x7,%eax
  8000e8:	cd 30                	int    $0x30
  8000ea:	89 c3                	mov    %eax,%ebx
  8000ec:	89 c6                	mov    %eax,%esi
	envid = sys_exofork();
	cprintf("THE ENVID is:%d\n",envid);
  8000ee:	83 c4 08             	add    $0x8,%esp
  8000f1:	50                   	push   %eax
  8000f2:	68 db 11 80 00       	push   $0x8011db
  8000f7:	e8 73 02 00 00       	call   80036f <cprintf>
	if (envid < 0)
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 db                	test   %ebx,%ebx
  800101:	79 12                	jns    800115 <dumbfork+0x44>
		panic("sys_exofork: %e", envid);
  800103:	53                   	push   %ebx
  800104:	68 ec 11 80 00       	push   $0x8011ec
  800109:	6a 38                	push   $0x38
  80010b:	68 93 11 80 00       	push   $0x801193
  800110:	e8 81 01 00 00       	call   800296 <_panic>
	if (envid == 0) {
  800115:	85 db                	test   %ebx,%ebx
  800117:	75 21                	jne    80013a <dumbfork+0x69>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800119:	e8 e5 0b 00 00       	call   800d03 <sys_getenvid>
  80011e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800123:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012b:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800130:	b8 00 00 00 00       	mov    $0x0,%eax
  800135:	e9 99 00 00 00       	jmp    8001d3 <dumbfork+0x102>
	}
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	cprintf("	AT before for duppage.\n");
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	68 fc 11 80 00       	push   $0x8011fc
  800142:	e8 28 02 00 00       	call   80036f <cprintf>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800147:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	eb 14                	jmp    800167 <dumbfork+0x96>
		duppage(envid, addr);
  800153:	83 ec 08             	sub    $0x8,%esp
  800156:	52                   	push   %edx
  800157:	56                   	push   %esi
  800158:	e8 d6 fe ff ff       	call   800033 <duppage>
	}
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	cprintf("	AT before for duppage.\n");
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80015d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80016a:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800170:	72 e1                	jb     800153 <dumbfork+0x82>
		duppage(envid, addr);
	cprintf(" NOW IN DUMBFORK.\n");	
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	68 15 12 80 00       	push   $0x801215
  80017a:	e8 f0 01 00 00       	call   80036f <cprintf>
	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80017f:	83 c4 08             	add    $0x8,%esp
  800182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800185:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80018a:	50                   	push   %eax
  80018b:	53                   	push   %ebx
  80018c:	e8 a2 fe ff ff       	call   800033 <duppage>
	cprintf("	after duppage(envid,ROUNDDOWN(&addr,PGSIZE))\n");
  800191:	c7 04 24 78 12 80 00 	movl   $0x801278,(%esp)
  800198:	e8 d2 01 00 00       	call   80036f <cprintf>
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 02                	push   $0x2
  8001a2:	53                   	push   %ebx
  8001a3:	e8 60 0c 00 00       	call   800e08 <sys_env_set_status>
  8001a8:	83 c4 10             	add    $0x10,%esp
  8001ab:	85 c0                	test   %eax,%eax
  8001ad:	79 12                	jns    8001c1 <dumbfork+0xf0>
		panic("sys_env_set_status: %e", r);
  8001af:	50                   	push   %eax
  8001b0:	68 28 12 80 00       	push   $0x801228
  8001b5:	6a 4d                	push   $0x4d
  8001b7:	68 93 11 80 00       	push   $0x801193
  8001bc:	e8 d5 00 00 00       	call   800296 <_panic>
	cprintf("!OUT OF THE DUNBFORK.\n");
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	68 3f 12 80 00       	push   $0x80123f
  8001c9:	e8 a1 01 00 00       	call   80036f <cprintf>
	return envid;
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	89 d8                	mov    %ebx,%eax
}
  8001d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp

	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001e3:	e8 e9 fe ff ff       	call   8000d1 <dumbfork>
  8001e8:	89 c7                	mov    %eax,%edi
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	be 5d 12 80 00       	mov    $0x80125d,%esi
  8001f1:	b8 56 12 80 00       	mov    $0x801256,%eax
  8001f6:	0f 45 f0             	cmovne %eax,%esi
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fe:	eb 26                	jmp    800226 <umain+0x4c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800200:	83 ec 04             	sub    $0x4,%esp
  800203:	56                   	push   %esi
  800204:	53                   	push   %ebx
  800205:	68 63 12 80 00       	push   $0x801263
  80020a:	e8 60 01 00 00       	call   80036f <cprintf>
		sys_yield();
  80020f:	e8 0e 0b 00 00       	call   800d22 <sys_yield>
		cprintf("user/dumbfork.c/umain/for():AFTER SYS_YIELD.\n");
  800214:	c7 04 24 a8 12 80 00 	movl   $0x8012a8,(%esp)
  80021b:	e8 4f 01 00 00       	call   80036f <cprintf>
	int i;

	// fork a child process
	who = dumbfork();
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800220:	83 c3 01             	add    $0x1,%ebx
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	85 ff                	test   %edi,%edi
  800228:	74 07                	je     800231 <umain+0x57>
  80022a:	83 fb 09             	cmp    $0x9,%ebx
  80022d:	7e d1                	jle    800200 <umain+0x26>
  80022f:	eb 05                	jmp    800236 <umain+0x5c>
  800231:	83 fb 13             	cmp    $0x13,%ebx
  800234:	7e ca                	jle    800200 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
		cprintf("user/dumbfork.c/umain/for():AFTER SYS_YIELD.\n");
	}
}
  800236:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800239:	5b                   	pop    %ebx
  80023a:	5e                   	pop    %esi
  80023b:	5f                   	pop    %edi
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800246:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800249:	e8 b5 0a 00 00       	call   800d03 <sys_getenvid>
  80024e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800253:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800256:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80025b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800260:	85 db                	test   %ebx,%ebx
  800262:	7e 07                	jle    80026b <libmain+0x2d>
		binaryname = argv[0];
  800264:	8b 06                	mov    (%esi),%eax
  800266:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80026b:	83 ec 08             	sub    $0x8,%esp
  80026e:	56                   	push   %esi
  80026f:	53                   	push   %ebx
  800270:	e8 65 ff ff ff       	call   8001da <umain>

	// exit gracefully
	exit();
  800275:	e8 0a 00 00 00       	call   800284 <exit>
}
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800280:	5b                   	pop    %ebx
  800281:	5e                   	pop    %esi
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80028a:	6a 00                	push   $0x0
  80028c:	e8 31 0a 00 00       	call   800cc2 <sys_env_destroy>
}
  800291:	83 c4 10             	add    $0x10,%esp
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8002a4:	e8 5a 0a 00 00       	call   800d03 <sys_getenvid>
  8002a9:	83 ec 0c             	sub    $0xc,%esp
  8002ac:	ff 75 0c             	pushl  0xc(%ebp)
  8002af:	ff 75 08             	pushl  0x8(%ebp)
  8002b2:	56                   	push   %esi
  8002b3:	50                   	push   %eax
  8002b4:	68 e0 12 80 00       	push   $0x8012e0
  8002b9:	e8 b1 00 00 00       	call   80036f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002be:	83 c4 18             	add    $0x18,%esp
  8002c1:	53                   	push   %ebx
  8002c2:	ff 75 10             	pushl  0x10(%ebp)
  8002c5:	e8 54 00 00 00       	call   80031e <vcprintf>
	cprintf("\n");
  8002ca:	c7 04 24 73 12 80 00 	movl   $0x801273,(%esp)
  8002d1:	e8 99 00 00 00       	call   80036f <cprintf>
  8002d6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d9:	cc                   	int3   
  8002da:	eb fd                	jmp    8002d9 <_panic+0x43>

008002dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 04             	sub    $0x4,%esp
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e6:	8b 13                	mov    (%ebx),%edx
  8002e8:	8d 42 01             	lea    0x1(%edx),%eax
  8002eb:	89 03                	mov    %eax,(%ebx)
  8002ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f9:	75 1a                	jne    800315 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	68 ff 00 00 00       	push   $0xff
  800303:	8d 43 08             	lea    0x8(%ebx),%eax
  800306:	50                   	push   %eax
  800307:	e8 79 09 00 00       	call   800c85 <sys_cputs>
		b->idx = 0;
  80030c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800312:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800315:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800327:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032e:	00 00 00 
	b.cnt = 0;
  800331:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800338:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033b:	ff 75 0c             	pushl  0xc(%ebp)
  80033e:	ff 75 08             	pushl  0x8(%ebp)
  800341:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800347:	50                   	push   %eax
  800348:	68 dc 02 80 00       	push   $0x8002dc
  80034d:	e8 54 01 00 00       	call   8004a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800352:	83 c4 08             	add    $0x8,%esp
  800355:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800361:	50                   	push   %eax
  800362:	e8 1e 09 00 00       	call   800c85 <sys_cputs>

	return b.cnt;
}
  800367:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800375:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800378:	50                   	push   %eax
  800379:	ff 75 08             	pushl  0x8(%ebp)
  80037c:	e8 9d ff ff ff       	call   80031e <vcprintf>
	va_end(ap);

	return cnt;
}
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 1c             	sub    $0x1c,%esp
  80038c:	89 c7                	mov    %eax,%edi
  80038e:	89 d6                	mov    %edx,%esi
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	8b 55 0c             	mov    0xc(%ebp),%edx
  800396:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800399:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80039f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003aa:	39 d3                	cmp    %edx,%ebx
  8003ac:	72 05                	jb     8003b3 <printnum+0x30>
  8003ae:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b1:	77 45                	ja     8003f8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 75 18             	pushl  0x18(%ebp)
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003bf:	53                   	push   %ebx
  8003c0:	ff 75 10             	pushl  0x10(%ebp)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8003cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d2:	e8 19 0b 00 00       	call   800ef0 <__udivdi3>
  8003d7:	83 c4 18             	add    $0x18,%esp
  8003da:	52                   	push   %edx
  8003db:	50                   	push   %eax
  8003dc:	89 f2                	mov    %esi,%edx
  8003de:	89 f8                	mov    %edi,%eax
  8003e0:	e8 9e ff ff ff       	call   800383 <printnum>
  8003e5:	83 c4 20             	add    $0x20,%esp
  8003e8:	eb 18                	jmp    800402 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	56                   	push   %esi
  8003ee:	ff 75 18             	pushl  0x18(%ebp)
  8003f1:	ff d7                	call   *%edi
  8003f3:	83 c4 10             	add    $0x10,%esp
  8003f6:	eb 03                	jmp    8003fb <printnum+0x78>
  8003f8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fb:	83 eb 01             	sub    $0x1,%ebx
  8003fe:	85 db                	test   %ebx,%ebx
  800400:	7f e8                	jg     8003ea <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	56                   	push   %esi
  800406:	83 ec 04             	sub    $0x4,%esp
  800409:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040c:	ff 75 e0             	pushl  -0x20(%ebp)
  80040f:	ff 75 dc             	pushl  -0x24(%ebp)
  800412:	ff 75 d8             	pushl  -0x28(%ebp)
  800415:	e8 06 0c 00 00       	call   801020 <__umoddi3>
  80041a:	83 c4 14             	add    $0x14,%esp
  80041d:	0f be 80 04 13 80 00 	movsbl 0x801304(%eax),%eax
  800424:	50                   	push   %eax
  800425:	ff d7                	call   *%edi
}
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042d:	5b                   	pop    %ebx
  80042e:	5e                   	pop    %esi
  80042f:	5f                   	pop    %edi
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800435:	83 fa 01             	cmp    $0x1,%edx
  800438:	7e 0e                	jle    800448 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043a:	8b 10                	mov    (%eax),%edx
  80043c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043f:	89 08                	mov    %ecx,(%eax)
  800441:	8b 02                	mov    (%edx),%eax
  800443:	8b 52 04             	mov    0x4(%edx),%edx
  800446:	eb 22                	jmp    80046a <getuint+0x38>
	else if (lflag)
  800448:	85 d2                	test   %edx,%edx
  80044a:	74 10                	je     80045c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044c:	8b 10                	mov    (%eax),%edx
  80044e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800451:	89 08                	mov    %ecx,(%eax)
  800453:	8b 02                	mov    (%edx),%eax
  800455:	ba 00 00 00 00       	mov    $0x0,%edx
  80045a:	eb 0e                	jmp    80046a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045c:	8b 10                	mov    (%eax),%edx
  80045e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800461:	89 08                	mov    %ecx,(%eax)
  800463:	8b 02                	mov    (%edx),%eax
  800465:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800472:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800476:	8b 10                	mov    (%eax),%edx
  800478:	3b 50 04             	cmp    0x4(%eax),%edx
  80047b:	73 0a                	jae    800487 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800480:	89 08                	mov    %ecx,(%eax)
  800482:	8b 45 08             	mov    0x8(%ebp),%eax
  800485:	88 02                	mov    %al,(%edx)
}
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    

00800489 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80048f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800492:	50                   	push   %eax
  800493:	ff 75 10             	pushl  0x10(%ebp)
  800496:	ff 75 0c             	pushl  0xc(%ebp)
  800499:	ff 75 08             	pushl  0x8(%ebp)
  80049c:	e8 05 00 00 00       	call   8004a6 <vprintfmt>
	va_end(ap);
}
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	57                   	push   %edi
  8004aa:	56                   	push   %esi
  8004ab:	53                   	push   %ebx
  8004ac:	83 ec 2c             	sub    $0x2c,%esp
  8004af:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004b8:	eb 12                	jmp    8004cc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	0f 84 d3 03 00 00    	je     800895 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	53                   	push   %ebx
  8004c6:	50                   	push   %eax
  8004c7:	ff d6                	call   *%esi
  8004c9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004cc:	83 c7 01             	add    $0x1,%edi
  8004cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d3:	83 f8 25             	cmp    $0x25,%eax
  8004d6:	75 e2                	jne    8004ba <vprintfmt+0x14>
  8004d8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e3:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004ea:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f6:	eb 07                	jmp    8004ff <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8d 47 01             	lea    0x1(%edi),%eax
  800502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800505:	0f b6 07             	movzbl (%edi),%eax
  800508:	0f b6 c8             	movzbl %al,%ecx
  80050b:	83 e8 23             	sub    $0x23,%eax
  80050e:	3c 55                	cmp    $0x55,%al
  800510:	0f 87 64 03 00 00    	ja     80087a <vprintfmt+0x3d4>
  800516:	0f b6 c0             	movzbl %al,%eax
  800519:	ff 24 85 c0 13 80 00 	jmp    *0x8013c0(,%eax,4)
  800520:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800523:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800527:	eb d6                	jmp    8004ff <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052c:	b8 00 00 00 00       	mov    $0x0,%eax
  800531:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800534:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800537:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80053e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800541:	83 fa 09             	cmp    $0x9,%edx
  800544:	77 39                	ja     80057f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800546:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800549:	eb e9                	jmp    800534 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 48 04             	lea    0x4(%eax),%ecx
  800551:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800554:	8b 00                	mov    (%eax),%eax
  800556:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800559:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055c:	eb 27                	jmp    800585 <vprintfmt+0xdf>
  80055e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800561:	85 c0                	test   %eax,%eax
  800563:	b9 00 00 00 00       	mov    $0x0,%ecx
  800568:	0f 49 c8             	cmovns %eax,%ecx
  80056b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800571:	eb 8c                	jmp    8004ff <vprintfmt+0x59>
  800573:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800576:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057d:	eb 80                	jmp    8004ff <vprintfmt+0x59>
  80057f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800582:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800585:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800589:	0f 89 70 ff ff ff    	jns    8004ff <vprintfmt+0x59>
				width = precision, precision = -1;
  80058f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800592:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800595:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80059c:	e9 5e ff ff ff       	jmp    8004ff <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a7:	e9 53 ff ff ff       	jmp    8004ff <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	ff 30                	pushl  (%eax)
  8005bb:	ff d6                	call   *%esi
			break;
  8005bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c3:	e9 04 ff ff ff       	jmp    8004cc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	99                   	cltd   
  8005d4:	31 d0                	xor    %edx,%eax
  8005d6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d8:	83 f8 08             	cmp    $0x8,%eax
  8005db:	7f 0b                	jg     8005e8 <vprintfmt+0x142>
  8005dd:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	75 18                	jne    800600 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005e8:	50                   	push   %eax
  8005e9:	68 1c 13 80 00       	push   $0x80131c
  8005ee:	53                   	push   %ebx
  8005ef:	56                   	push   %esi
  8005f0:	e8 94 fe ff ff       	call   800489 <printfmt>
  8005f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fb:	e9 cc fe ff ff       	jmp    8004cc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800600:	52                   	push   %edx
  800601:	68 25 13 80 00       	push   $0x801325
  800606:	53                   	push   %ebx
  800607:	56                   	push   %esi
  800608:	e8 7c fe ff ff       	call   800489 <printfmt>
  80060d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800613:	e9 b4 fe ff ff       	jmp    8004cc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800623:	85 ff                	test   %edi,%edi
  800625:	b8 15 13 80 00       	mov    $0x801315,%eax
  80062a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800631:	0f 8e 94 00 00 00    	jle    8006cb <vprintfmt+0x225>
  800637:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063b:	0f 84 98 00 00 00    	je     8006d9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	ff 75 c8             	pushl  -0x38(%ebp)
  800647:	57                   	push   %edi
  800648:	e8 d0 02 00 00       	call   80091d <strnlen>
  80064d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800650:	29 c1                	sub    %eax,%ecx
  800652:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800655:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800658:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80065f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800662:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800664:	eb 0f                	jmp    800675 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	ff 75 e0             	pushl  -0x20(%ebp)
  80066d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066f:	83 ef 01             	sub    $0x1,%edi
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	85 ff                	test   %edi,%edi
  800677:	7f ed                	jg     800666 <vprintfmt+0x1c0>
  800679:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80067f:	85 c9                	test   %ecx,%ecx
  800681:	b8 00 00 00 00       	mov    $0x0,%eax
  800686:	0f 49 c1             	cmovns %ecx,%eax
  800689:	29 c1                	sub    %eax,%ecx
  80068b:	89 75 08             	mov    %esi,0x8(%ebp)
  80068e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800691:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800694:	89 cb                	mov    %ecx,%ebx
  800696:	eb 4d                	jmp    8006e5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800698:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069c:	74 1b                	je     8006b9 <vprintfmt+0x213>
  80069e:	0f be c0             	movsbl %al,%eax
  8006a1:	83 e8 20             	sub    $0x20,%eax
  8006a4:	83 f8 5e             	cmp    $0x5e,%eax
  8006a7:	76 10                	jbe    8006b9 <vprintfmt+0x213>
					putch('?', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	ff 75 0c             	pushl  0xc(%ebp)
  8006af:	6a 3f                	push   $0x3f
  8006b1:	ff 55 08             	call   *0x8(%ebp)
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	eb 0d                	jmp    8006c6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	ff 75 0c             	pushl  0xc(%ebp)
  8006bf:	52                   	push   %edx
  8006c0:	ff 55 08             	call   *0x8(%ebp)
  8006c3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c6:	83 eb 01             	sub    $0x1,%ebx
  8006c9:	eb 1a                	jmp    8006e5 <vprintfmt+0x23f>
  8006cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ce:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d7:	eb 0c                	jmp    8006e5 <vprintfmt+0x23f>
  8006d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8006dc:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e5:	83 c7 01             	add    $0x1,%edi
  8006e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ec:	0f be d0             	movsbl %al,%edx
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	74 23                	je     800716 <vprintfmt+0x270>
  8006f3:	85 f6                	test   %esi,%esi
  8006f5:	78 a1                	js     800698 <vprintfmt+0x1f2>
  8006f7:	83 ee 01             	sub    $0x1,%esi
  8006fa:	79 9c                	jns    800698 <vprintfmt+0x1f2>
  8006fc:	89 df                	mov    %ebx,%edi
  8006fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800701:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800704:	eb 18                	jmp    80071e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	6a 20                	push   $0x20
  80070c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80070e:	83 ef 01             	sub    $0x1,%edi
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	eb 08                	jmp    80071e <vprintfmt+0x278>
  800716:	89 df                	mov    %ebx,%edi
  800718:	8b 75 08             	mov    0x8(%ebp),%esi
  80071b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071e:	85 ff                	test   %edi,%edi
  800720:	7f e4                	jg     800706 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800725:	e9 a2 fd ff ff       	jmp    8004cc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072a:	83 fa 01             	cmp    $0x1,%edx
  80072d:	7e 16                	jle    800745 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8d 50 08             	lea    0x8(%eax),%edx
  800735:	89 55 14             	mov    %edx,0x14(%ebp)
  800738:	8b 50 04             	mov    0x4(%eax),%edx
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800740:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800743:	eb 32                	jmp    800777 <vprintfmt+0x2d1>
	else if (lflag)
  800745:	85 d2                	test   %edx,%edx
  800747:	74 18                	je     800761 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8d 50 04             	lea    0x4(%eax),%edx
  80074f:	89 55 14             	mov    %edx,0x14(%ebp)
  800752:	8b 00                	mov    (%eax),%eax
  800754:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800757:	89 c1                	mov    %eax,%ecx
  800759:	c1 f9 1f             	sar    $0x1f,%ecx
  80075c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80075f:	eb 16                	jmp    800777 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8d 50 04             	lea    0x4(%eax),%edx
  800767:	89 55 14             	mov    %edx,0x14(%ebp)
  80076a:	8b 00                	mov    (%eax),%eax
  80076c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80076f:	89 c1                	mov    %eax,%ecx
  800771:	c1 f9 1f             	sar    $0x1f,%ecx
  800774:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800777:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80077a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80077d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800780:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800783:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800788:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80078c:	0f 89 b0 00 00 00    	jns    800842 <vprintfmt+0x39c>
				putch('-', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 2d                	push   $0x2d
  800798:	ff d6                	call   *%esi
				num = -(long long) num;
  80079a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80079d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007a0:	f7 d8                	neg    %eax
  8007a2:	83 d2 00             	adc    $0x0,%edx
  8007a5:	f7 da                	neg    %edx
  8007a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ad:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b5:	e9 88 00 00 00       	jmp    800842 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 70 fc ff ff       	call   800432 <getuint>
  8007c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007c8:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007cd:	eb 73                	jmp    800842 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 5b fc ff ff       	call   800432 <getuint>
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	53                   	push   %ebx
  8007e1:	6a 58                	push   $0x58
  8007e3:	ff d6                	call   *%esi
			putch('X', putdat);
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	53                   	push   %ebx
  8007e9:	6a 58                	push   $0x58
  8007eb:	ff d6                	call   *%esi
			putch('X', putdat);
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	53                   	push   %ebx
  8007f1:	6a 58                	push   $0x58
  8007f3:	ff d6                	call   *%esi
			goto number;
  8007f5:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8007f8:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8007fd:	eb 43                	jmp    800842 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007ff:	83 ec 08             	sub    $0x8,%esp
  800802:	53                   	push   %ebx
  800803:	6a 30                	push   $0x30
  800805:	ff d6                	call   *%esi
			putch('x', putdat);
  800807:	83 c4 08             	add    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	6a 78                	push   $0x78
  80080d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 50 04             	lea    0x4(%eax),%edx
  800815:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	ba 00 00 00 00       	mov    $0x0,%edx
  80081f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800822:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800825:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800828:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80082d:	eb 13                	jmp    800842 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	e8 fb fb ff ff       	call   800432 <getuint>
  800837:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80083d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800842:	83 ec 0c             	sub    $0xc,%esp
  800845:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800849:	52                   	push   %edx
  80084a:	ff 75 e0             	pushl  -0x20(%ebp)
  80084d:	50                   	push   %eax
  80084e:	ff 75 dc             	pushl  -0x24(%ebp)
  800851:	ff 75 d8             	pushl  -0x28(%ebp)
  800854:	89 da                	mov    %ebx,%edx
  800856:	89 f0                	mov    %esi,%eax
  800858:	e8 26 fb ff ff       	call   800383 <printnum>
			break;
  80085d:	83 c4 20             	add    $0x20,%esp
  800860:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800863:	e9 64 fc ff ff       	jmp    8004cc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	51                   	push   %ecx
  80086d:	ff d6                	call   *%esi
			break;
  80086f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800872:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800875:	e9 52 fc ff ff       	jmp    8004cc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	6a 25                	push   $0x25
  800880:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	eb 03                	jmp    80088a <vprintfmt+0x3e4>
  800887:	83 ef 01             	sub    $0x1,%edi
  80088a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80088e:	75 f7                	jne    800887 <vprintfmt+0x3e1>
  800890:	e9 37 fc ff ff       	jmp    8004cc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800895:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5f                   	pop    %edi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	83 ec 18             	sub    $0x18,%esp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	74 26                	je     8008e4 <vsnprintf+0x47>
  8008be:	85 d2                	test   %edx,%edx
  8008c0:	7e 22                	jle    8008e4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c2:	ff 75 14             	pushl  0x14(%ebp)
  8008c5:	ff 75 10             	pushl  0x10(%ebp)
  8008c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cb:	50                   	push   %eax
  8008cc:	68 6c 04 80 00       	push   $0x80046c
  8008d1:	e8 d0 fb ff ff       	call   8004a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	eb 05                	jmp    8008e9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f4:	50                   	push   %eax
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 9a ff ff ff       	call   80089d <vsnprintf>
	va_end(ap);

	return rc;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb 03                	jmp    800915 <strlen+0x10>
		n++;
  800912:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800915:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800919:	75 f7                	jne    800912 <strlen+0xd>
		n++;
	return n;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
  80092b:	eb 03                	jmp    800930 <strnlen+0x13>
		n++;
  80092d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800930:	39 c2                	cmp    %eax,%edx
  800932:	74 08                	je     80093c <strnlen+0x1f>
  800934:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800938:	75 f3                	jne    80092d <strnlen+0x10>
  80093a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800948:	89 c2                	mov    %eax,%edx
  80094a:	83 c2 01             	add    $0x1,%edx
  80094d:	83 c1 01             	add    $0x1,%ecx
  800950:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800954:	88 5a ff             	mov    %bl,-0x1(%edx)
  800957:	84 db                	test   %bl,%bl
  800959:	75 ef                	jne    80094a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095b:	5b                   	pop    %ebx
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	53                   	push   %ebx
  800962:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800965:	53                   	push   %ebx
  800966:	e8 9a ff ff ff       	call   800905 <strlen>
  80096b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096e:	ff 75 0c             	pushl  0xc(%ebp)
  800971:	01 d8                	add    %ebx,%eax
  800973:	50                   	push   %eax
  800974:	e8 c5 ff ff ff       	call   80093e <strcpy>
	return dst;
}
  800979:	89 d8                	mov    %ebx,%eax
  80097b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 75 08             	mov    0x8(%ebp),%esi
  800988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098b:	89 f3                	mov    %esi,%ebx
  80098d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800990:	89 f2                	mov    %esi,%edx
  800992:	eb 0f                	jmp    8009a3 <strncpy+0x23>
		*dst++ = *src;
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	0f b6 01             	movzbl (%ecx),%eax
  80099a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099d:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a3:	39 da                	cmp    %ebx,%edx
  8009a5:	75 ed                	jne    800994 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a7:	89 f0                	mov    %esi,%eax
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b8:	8b 55 10             	mov    0x10(%ebp),%edx
  8009bb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bd:	85 d2                	test   %edx,%edx
  8009bf:	74 21                	je     8009e2 <strlcpy+0x35>
  8009c1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c5:	89 f2                	mov    %esi,%edx
  8009c7:	eb 09                	jmp    8009d2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c9:	83 c2 01             	add    $0x1,%edx
  8009cc:	83 c1 01             	add    $0x1,%ecx
  8009cf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d2:	39 c2                	cmp    %eax,%edx
  8009d4:	74 09                	je     8009df <strlcpy+0x32>
  8009d6:	0f b6 19             	movzbl (%ecx),%ebx
  8009d9:	84 db                	test   %bl,%bl
  8009db:	75 ec                	jne    8009c9 <strlcpy+0x1c>
  8009dd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009df:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e2:	29 f0                	sub    %esi,%eax
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f1:	eb 06                	jmp    8009f9 <strcmp+0x11>
		p++, q++;
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	84 c0                	test   %al,%al
  8009fe:	74 04                	je     800a04 <strcmp+0x1c>
  800a00:	3a 02                	cmp    (%edx),%al
  800a02:	74 ef                	je     8009f3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a04:	0f b6 c0             	movzbl %al,%eax
  800a07:	0f b6 12             	movzbl (%edx),%edx
  800a0a:	29 d0                	sub    %edx,%eax
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	53                   	push   %ebx
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a18:	89 c3                	mov    %eax,%ebx
  800a1a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1d:	eb 06                	jmp    800a25 <strncmp+0x17>
		n--, p++, q++;
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a25:	39 d8                	cmp    %ebx,%eax
  800a27:	74 15                	je     800a3e <strncmp+0x30>
  800a29:	0f b6 08             	movzbl (%eax),%ecx
  800a2c:	84 c9                	test   %cl,%cl
  800a2e:	74 04                	je     800a34 <strncmp+0x26>
  800a30:	3a 0a                	cmp    (%edx),%cl
  800a32:	74 eb                	je     800a1f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a34:	0f b6 00             	movzbl (%eax),%eax
  800a37:	0f b6 12             	movzbl (%edx),%edx
  800a3a:	29 d0                	sub    %edx,%eax
  800a3c:	eb 05                	jmp    800a43 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a50:	eb 07                	jmp    800a59 <strchr+0x13>
		if (*s == c)
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	74 0f                	je     800a65 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	0f b6 10             	movzbl (%eax),%edx
  800a5c:	84 d2                	test   %dl,%dl
  800a5e:	75 f2                	jne    800a52 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a71:	eb 03                	jmp    800a76 <strfind+0xf>
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a79:	38 ca                	cmp    %cl,%dl
  800a7b:	74 04                	je     800a81 <strfind+0x1a>
  800a7d:	84 d2                	test   %dl,%dl
  800a7f:	75 f2                	jne    800a73 <strfind+0xc>
			break;
	return (char *) s;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8f:	85 c9                	test   %ecx,%ecx
  800a91:	74 36                	je     800ac9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a93:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a99:	75 28                	jne    800ac3 <memset+0x40>
  800a9b:	f6 c1 03             	test   $0x3,%cl
  800a9e:	75 23                	jne    800ac3 <memset+0x40>
		c &= 0xFF;
  800aa0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	c1 e3 08             	shl    $0x8,%ebx
  800aa9:	89 d6                	mov    %edx,%esi
  800aab:	c1 e6 18             	shl    $0x18,%esi
  800aae:	89 d0                	mov    %edx,%eax
  800ab0:	c1 e0 10             	shl    $0x10,%eax
  800ab3:	09 f0                	or     %esi,%eax
  800ab5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ab7:	89 d8                	mov    %ebx,%eax
  800ab9:	09 d0                	or     %edx,%eax
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fc                   	cld    
  800abf:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac1:	eb 06                	jmp    800ac9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	fc                   	cld    
  800ac7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac9:	89 f8                	mov    %edi,%eax
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ade:	39 c6                	cmp    %eax,%esi
  800ae0:	73 35                	jae    800b17 <memmove+0x47>
  800ae2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae5:	39 d0                	cmp    %edx,%eax
  800ae7:	73 2e                	jae    800b17 <memmove+0x47>
		s += n;
		d += n;
  800ae9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	89 d6                	mov    %edx,%esi
  800aee:	09 fe                	or     %edi,%esi
  800af0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af6:	75 13                	jne    800b0b <memmove+0x3b>
  800af8:	f6 c1 03             	test   $0x3,%cl
  800afb:	75 0e                	jne    800b0b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800afd:	83 ef 04             	sub    $0x4,%edi
  800b00:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b03:	c1 e9 02             	shr    $0x2,%ecx
  800b06:	fd                   	std    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 09                	jmp    800b14 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0b:	83 ef 01             	sub    $0x1,%edi
  800b0e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b11:	fd                   	std    
  800b12:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b14:	fc                   	cld    
  800b15:	eb 1d                	jmp    800b34 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b17:	89 f2                	mov    %esi,%edx
  800b19:	09 c2                	or     %eax,%edx
  800b1b:	f6 c2 03             	test   $0x3,%dl
  800b1e:	75 0f                	jne    800b2f <memmove+0x5f>
  800b20:	f6 c1 03             	test   $0x3,%cl
  800b23:	75 0a                	jne    800b2f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b25:	c1 e9 02             	shr    $0x2,%ecx
  800b28:	89 c7                	mov    %eax,%edi
  800b2a:	fc                   	cld    
  800b2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2d:	eb 05                	jmp    800b34 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2f:	89 c7                	mov    %eax,%edi
  800b31:	fc                   	cld    
  800b32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3b:	ff 75 10             	pushl  0x10(%ebp)
  800b3e:	ff 75 0c             	pushl  0xc(%ebp)
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	e8 87 ff ff ff       	call   800ad0 <memmove>
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5b:	eb 1a                	jmp    800b77 <memcmp+0x2c>
		if (*s1 != *s2)
  800b5d:	0f b6 08             	movzbl (%eax),%ecx
  800b60:	0f b6 1a             	movzbl (%edx),%ebx
  800b63:	38 d9                	cmp    %bl,%cl
  800b65:	74 0a                	je     800b71 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b67:	0f b6 c1             	movzbl %cl,%eax
  800b6a:	0f b6 db             	movzbl %bl,%ebx
  800b6d:	29 d8                	sub    %ebx,%eax
  800b6f:	eb 0f                	jmp    800b80 <memcmp+0x35>
		s1++, s2++;
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b77:	39 f0                	cmp    %esi,%eax
  800b79:	75 e2                	jne    800b5d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	53                   	push   %ebx
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b8b:	89 c1                	mov    %eax,%ecx
  800b8d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b90:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b94:	eb 0a                	jmp    800ba0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b96:	0f b6 10             	movzbl (%eax),%edx
  800b99:	39 da                	cmp    %ebx,%edx
  800b9b:	74 07                	je     800ba4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9d:	83 c0 01             	add    $0x1,%eax
  800ba0:	39 c8                	cmp    %ecx,%eax
  800ba2:	72 f2                	jb     800b96 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb3:	eb 03                	jmp    800bb8 <strtol+0x11>
		s++;
  800bb5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	0f b6 01             	movzbl (%ecx),%eax
  800bbb:	3c 20                	cmp    $0x20,%al
  800bbd:	74 f6                	je     800bb5 <strtol+0xe>
  800bbf:	3c 09                	cmp    $0x9,%al
  800bc1:	74 f2                	je     800bb5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc3:	3c 2b                	cmp    $0x2b,%al
  800bc5:	75 0a                	jne    800bd1 <strtol+0x2a>
		s++;
  800bc7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bca:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcf:	eb 11                	jmp    800be2 <strtol+0x3b>
  800bd1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd6:	3c 2d                	cmp    $0x2d,%al
  800bd8:	75 08                	jne    800be2 <strtol+0x3b>
		s++, neg = 1;
  800bda:	83 c1 01             	add    $0x1,%ecx
  800bdd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800be8:	75 15                	jne    800bff <strtol+0x58>
  800bea:	80 39 30             	cmpb   $0x30,(%ecx)
  800bed:	75 10                	jne    800bff <strtol+0x58>
  800bef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf3:	75 7c                	jne    800c71 <strtol+0xca>
		s += 2, base = 16;
  800bf5:	83 c1 02             	add    $0x2,%ecx
  800bf8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfd:	eb 16                	jmp    800c15 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bff:	85 db                	test   %ebx,%ebx
  800c01:	75 12                	jne    800c15 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c03:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c08:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0b:	75 08                	jne    800c15 <strtol+0x6e>
		s++, base = 8;
  800c0d:	83 c1 01             	add    $0x1,%ecx
  800c10:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c15:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1d:	0f b6 11             	movzbl (%ecx),%edx
  800c20:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c23:	89 f3                	mov    %esi,%ebx
  800c25:	80 fb 09             	cmp    $0x9,%bl
  800c28:	77 08                	ja     800c32 <strtol+0x8b>
			dig = *s - '0';
  800c2a:	0f be d2             	movsbl %dl,%edx
  800c2d:	83 ea 30             	sub    $0x30,%edx
  800c30:	eb 22                	jmp    800c54 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c35:	89 f3                	mov    %esi,%ebx
  800c37:	80 fb 19             	cmp    $0x19,%bl
  800c3a:	77 08                	ja     800c44 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c3c:	0f be d2             	movsbl %dl,%edx
  800c3f:	83 ea 57             	sub    $0x57,%edx
  800c42:	eb 10                	jmp    800c54 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c44:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c47:	89 f3                	mov    %esi,%ebx
  800c49:	80 fb 19             	cmp    $0x19,%bl
  800c4c:	77 16                	ja     800c64 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c4e:	0f be d2             	movsbl %dl,%edx
  800c51:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c54:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c57:	7d 0b                	jge    800c64 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c60:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c62:	eb b9                	jmp    800c1d <strtol+0x76>

	if (endptr)
  800c64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c68:	74 0d                	je     800c77 <strtol+0xd0>
		*endptr = (char *) s;
  800c6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6d:	89 0e                	mov    %ecx,(%esi)
  800c6f:	eb 06                	jmp    800c77 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c71:	85 db                	test   %ebx,%ebx
  800c73:	74 98                	je     800c0d <strtol+0x66>
  800c75:	eb 9e                	jmp    800c15 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c77:	89 c2                	mov    %eax,%edx
  800c79:	f7 da                	neg    %edx
  800c7b:	85 ff                	test   %edi,%edi
  800c7d:	0f 45 c2             	cmovne %edx,%eax
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 c3                	mov    %eax,%ebx
  800c98:	89 c7                	mov    %eax,%edi
  800c9a:	89 c6                	mov    %eax,%esi
  800c9c:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_cgetc>:

int
sys_cgetc(void)
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
  800cae:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	89 d3                	mov    %edx,%ebx
  800cb7:	89 d7                	mov    %edx,%edi
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd0:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 cb                	mov    %ecx,%ebx
  800cda:	89 cf                	mov    %ecx,%edi
  800cdc:	89 ce                	mov    %ecx,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 03                	push   $0x3
  800cea:	68 44 15 80 00       	push   $0x801544
  800cef:	6a 23                	push   $0x23
  800cf1:	68 61 15 80 00       	push   $0x801561
  800cf6:	e8 9b f5 ff ff       	call   800296 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	89 d3                	mov    %edx,%ebx
  800d17:	89 d7                	mov    %edx,%edi
  800d19:	89 d6                	mov    %edx,%esi
  800d1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_yield>:

void
sys_yield(void)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d32:	89 d1                	mov    %edx,%ecx
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d4a:	be 00 00 00 00       	mov    $0x0,%esi
  800d4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5d:	89 f7                	mov    %esi,%edi
  800d5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 04                	push   $0x4
  800d6b:	68 44 15 80 00       	push   $0x801544
  800d70:	6a 23                	push   $0x23
  800d72:	68 61 15 80 00       	push   $0x801561
  800d77:	e8 1a f5 ff ff       	call   800296 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9e:	8b 75 18             	mov    0x18(%ebp),%esi
  800da1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 05                	push   $0x5
  800dad:	68 44 15 80 00       	push   $0x801544
  800db2:	6a 23                	push   $0x23
  800db4:	68 61 15 80 00       	push   $0x801561
  800db9:	e8 d8 f4 ff ff       	call   800296 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd4:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 df                	mov    %ebx,%edi
  800de1:	89 de                	mov    %ebx,%esi
  800de3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	7e 17                	jle    800e00 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	50                   	push   %eax
  800ded:	6a 06                	push   $0x6
  800def:	68 44 15 80 00       	push   $0x801544
  800df4:	6a 23                	push   $0x23
  800df6:	68 61 15 80 00       	push   $0x801561
  800dfb:	e8 96 f4 ff ff       	call   800296 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e16:	b8 08 00 00 00       	mov    $0x8,%eax
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 df                	mov    %ebx,%edi
  800e23:	89 de                	mov    %ebx,%esi
  800e25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7e 17                	jle    800e42 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	50                   	push   %eax
  800e2f:	6a 08                	push   $0x8
  800e31:	68 44 15 80 00       	push   $0x801544
  800e36:	6a 23                	push   $0x23
  800e38:	68 61 15 80 00       	push   $0x801561
  800e3d:	e8 54 f4 ff ff       	call   800296 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 df                	mov    %ebx,%edi
  800e65:	89 de                	mov    %ebx,%esi
  800e67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	7e 17                	jle    800e84 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	50                   	push   %eax
  800e71:	6a 09                	push   $0x9
  800e73:	68 44 15 80 00       	push   $0x801544
  800e78:	6a 23                	push   $0x23
  800e7a:	68 61 15 80 00       	push   $0x801561
  800e7f:	e8 12 f4 ff ff       	call   800296 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e92:	be 00 00 00 00       	mov    $0x0,%esi
  800e97:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800eb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	89 cb                	mov    %ecx,%ebx
  800ec7:	89 cf                	mov    %ecx,%edi
  800ec9:	89 ce                	mov    %ecx,%esi
  800ecb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7e 17                	jle    800ee8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed1:	83 ec 0c             	sub    $0xc,%esp
  800ed4:	50                   	push   %eax
  800ed5:	6a 0c                	push   $0xc
  800ed7:	68 44 15 80 00       	push   $0x801544
  800edc:	6a 23                	push   $0x23
  800ede:	68 61 15 80 00       	push   $0x801561
  800ee3:	e8 ae f3 ff ff       	call   800296 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <__udivdi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800efb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800eff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 f6                	test   %esi,%esi
  800f09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f0d:	89 ca                	mov    %ecx,%edx
  800f0f:	89 f8                	mov    %edi,%eax
  800f11:	75 3d                	jne    800f50 <__udivdi3+0x60>
  800f13:	39 cf                	cmp    %ecx,%edi
  800f15:	0f 87 c5 00 00 00    	ja     800fe0 <__udivdi3+0xf0>
  800f1b:	85 ff                	test   %edi,%edi
  800f1d:	89 fd                	mov    %edi,%ebp
  800f1f:	75 0b                	jne    800f2c <__udivdi3+0x3c>
  800f21:	b8 01 00 00 00       	mov    $0x1,%eax
  800f26:	31 d2                	xor    %edx,%edx
  800f28:	f7 f7                	div    %edi
  800f2a:	89 c5                	mov    %eax,%ebp
  800f2c:	89 c8                	mov    %ecx,%eax
  800f2e:	31 d2                	xor    %edx,%edx
  800f30:	f7 f5                	div    %ebp
  800f32:	89 c1                	mov    %eax,%ecx
  800f34:	89 d8                	mov    %ebx,%eax
  800f36:	89 cf                	mov    %ecx,%edi
  800f38:	f7 f5                	div    %ebp
  800f3a:	89 c3                	mov    %eax,%ebx
  800f3c:	89 d8                	mov    %ebx,%eax
  800f3e:	89 fa                	mov    %edi,%edx
  800f40:	83 c4 1c             	add    $0x1c,%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    
  800f48:	90                   	nop
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	39 ce                	cmp    %ecx,%esi
  800f52:	77 74                	ja     800fc8 <__udivdi3+0xd8>
  800f54:	0f bd fe             	bsr    %esi,%edi
  800f57:	83 f7 1f             	xor    $0x1f,%edi
  800f5a:	0f 84 98 00 00 00    	je     800ff8 <__udivdi3+0x108>
  800f60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f65:	89 f9                	mov    %edi,%ecx
  800f67:	89 c5                	mov    %eax,%ebp
  800f69:	29 fb                	sub    %edi,%ebx
  800f6b:	d3 e6                	shl    %cl,%esi
  800f6d:	89 d9                	mov    %ebx,%ecx
  800f6f:	d3 ed                	shr    %cl,%ebp
  800f71:	89 f9                	mov    %edi,%ecx
  800f73:	d3 e0                	shl    %cl,%eax
  800f75:	09 ee                	or     %ebp,%esi
  800f77:	89 d9                	mov    %ebx,%ecx
  800f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7d:	89 d5                	mov    %edx,%ebp
  800f7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f83:	d3 ed                	shr    %cl,%ebp
  800f85:	89 f9                	mov    %edi,%ecx
  800f87:	d3 e2                	shl    %cl,%edx
  800f89:	89 d9                	mov    %ebx,%ecx
  800f8b:	d3 e8                	shr    %cl,%eax
  800f8d:	09 c2                	or     %eax,%edx
  800f8f:	89 d0                	mov    %edx,%eax
  800f91:	89 ea                	mov    %ebp,%edx
  800f93:	f7 f6                	div    %esi
  800f95:	89 d5                	mov    %edx,%ebp
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	f7 64 24 0c          	mull   0xc(%esp)
  800f9d:	39 d5                	cmp    %edx,%ebp
  800f9f:	72 10                	jb     800fb1 <__udivdi3+0xc1>
  800fa1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fa5:	89 f9                	mov    %edi,%ecx
  800fa7:	d3 e6                	shl    %cl,%esi
  800fa9:	39 c6                	cmp    %eax,%esi
  800fab:	73 07                	jae    800fb4 <__udivdi3+0xc4>
  800fad:	39 d5                	cmp    %edx,%ebp
  800faf:	75 03                	jne    800fb4 <__udivdi3+0xc4>
  800fb1:	83 eb 01             	sub    $0x1,%ebx
  800fb4:	31 ff                	xor    %edi,%edi
  800fb6:	89 d8                	mov    %ebx,%eax
  800fb8:	89 fa                	mov    %edi,%edx
  800fba:	83 c4 1c             	add    $0x1c,%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	31 ff                	xor    %edi,%edi
  800fca:	31 db                	xor    %ebx,%ebx
  800fcc:	89 d8                	mov    %ebx,%eax
  800fce:	89 fa                	mov    %edi,%edx
  800fd0:	83 c4 1c             	add    $0x1c,%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    
  800fd8:	90                   	nop
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	89 d8                	mov    %ebx,%eax
  800fe2:	f7 f7                	div    %edi
  800fe4:	31 ff                	xor    %edi,%edi
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	89 d8                	mov    %ebx,%eax
  800fea:	89 fa                	mov    %edi,%edx
  800fec:	83 c4 1c             	add    $0x1c,%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    
  800ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	39 ce                	cmp    %ecx,%esi
  800ffa:	72 0c                	jb     801008 <__udivdi3+0x118>
  800ffc:	31 db                	xor    %ebx,%ebx
  800ffe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801002:	0f 87 34 ff ff ff    	ja     800f3c <__udivdi3+0x4c>
  801008:	bb 01 00 00 00       	mov    $0x1,%ebx
  80100d:	e9 2a ff ff ff       	jmp    800f3c <__udivdi3+0x4c>
  801012:	66 90                	xchg   %ax,%ax
  801014:	66 90                	xchg   %ax,%ax
  801016:	66 90                	xchg   %ax,%ax
  801018:	66 90                	xchg   %ax,%ax
  80101a:	66 90                	xchg   %ax,%ax
  80101c:	66 90                	xchg   %ax,%ax
  80101e:	66 90                	xchg   %ax,%ax

00801020 <__umoddi3>:
  801020:	55                   	push   %ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 1c             	sub    $0x1c,%esp
  801027:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80102b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80102f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801037:	85 d2                	test   %edx,%edx
  801039:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80103d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801041:	89 f3                	mov    %esi,%ebx
  801043:	89 3c 24             	mov    %edi,(%esp)
  801046:	89 74 24 04          	mov    %esi,0x4(%esp)
  80104a:	75 1c                	jne    801068 <__umoddi3+0x48>
  80104c:	39 f7                	cmp    %esi,%edi
  80104e:	76 50                	jbe    8010a0 <__umoddi3+0x80>
  801050:	89 c8                	mov    %ecx,%eax
  801052:	89 f2                	mov    %esi,%edx
  801054:	f7 f7                	div    %edi
  801056:	89 d0                	mov    %edx,%eax
  801058:	31 d2                	xor    %edx,%edx
  80105a:	83 c4 1c             	add    $0x1c,%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5f                   	pop    %edi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    
  801062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801068:	39 f2                	cmp    %esi,%edx
  80106a:	89 d0                	mov    %edx,%eax
  80106c:	77 52                	ja     8010c0 <__umoddi3+0xa0>
  80106e:	0f bd ea             	bsr    %edx,%ebp
  801071:	83 f5 1f             	xor    $0x1f,%ebp
  801074:	75 5a                	jne    8010d0 <__umoddi3+0xb0>
  801076:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80107a:	0f 82 e0 00 00 00    	jb     801160 <__umoddi3+0x140>
  801080:	39 0c 24             	cmp    %ecx,(%esp)
  801083:	0f 86 d7 00 00 00    	jbe    801160 <__umoddi3+0x140>
  801089:	8b 44 24 08          	mov    0x8(%esp),%eax
  80108d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801091:	83 c4 1c             	add    $0x1c,%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    
  801099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	85 ff                	test   %edi,%edi
  8010a2:	89 fd                	mov    %edi,%ebp
  8010a4:	75 0b                	jne    8010b1 <__umoddi3+0x91>
  8010a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f7                	div    %edi
  8010af:	89 c5                	mov    %eax,%ebp
  8010b1:	89 f0                	mov    %esi,%eax
  8010b3:	31 d2                	xor    %edx,%edx
  8010b5:	f7 f5                	div    %ebp
  8010b7:	89 c8                	mov    %ecx,%eax
  8010b9:	f7 f5                	div    %ebp
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	eb 99                	jmp    801058 <__umoddi3+0x38>
  8010bf:	90                   	nop
  8010c0:	89 c8                	mov    %ecx,%eax
  8010c2:	89 f2                	mov    %esi,%edx
  8010c4:	83 c4 1c             	add    $0x1c,%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    
  8010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	8b 34 24             	mov    (%esp),%esi
  8010d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010d8:	89 e9                	mov    %ebp,%ecx
  8010da:	29 ef                	sub    %ebp,%edi
  8010dc:	d3 e0                	shl    %cl,%eax
  8010de:	89 f9                	mov    %edi,%ecx
  8010e0:	89 f2                	mov    %esi,%edx
  8010e2:	d3 ea                	shr    %cl,%edx
  8010e4:	89 e9                	mov    %ebp,%ecx
  8010e6:	09 c2                	or     %eax,%edx
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	89 14 24             	mov    %edx,(%esp)
  8010ed:	89 f2                	mov    %esi,%edx
  8010ef:	d3 e2                	shl    %cl,%edx
  8010f1:	89 f9                	mov    %edi,%ecx
  8010f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010fb:	d3 e8                	shr    %cl,%eax
  8010fd:	89 e9                	mov    %ebp,%ecx
  8010ff:	89 c6                	mov    %eax,%esi
  801101:	d3 e3                	shl    %cl,%ebx
  801103:	89 f9                	mov    %edi,%ecx
  801105:	89 d0                	mov    %edx,%eax
  801107:	d3 e8                	shr    %cl,%eax
  801109:	89 e9                	mov    %ebp,%ecx
  80110b:	09 d8                	or     %ebx,%eax
  80110d:	89 d3                	mov    %edx,%ebx
  80110f:	89 f2                	mov    %esi,%edx
  801111:	f7 34 24             	divl   (%esp)
  801114:	89 d6                	mov    %edx,%esi
  801116:	d3 e3                	shl    %cl,%ebx
  801118:	f7 64 24 04          	mull   0x4(%esp)
  80111c:	39 d6                	cmp    %edx,%esi
  80111e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801122:	89 d1                	mov    %edx,%ecx
  801124:	89 c3                	mov    %eax,%ebx
  801126:	72 08                	jb     801130 <__umoddi3+0x110>
  801128:	75 11                	jne    80113b <__umoddi3+0x11b>
  80112a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80112e:	73 0b                	jae    80113b <__umoddi3+0x11b>
  801130:	2b 44 24 04          	sub    0x4(%esp),%eax
  801134:	1b 14 24             	sbb    (%esp),%edx
  801137:	89 d1                	mov    %edx,%ecx
  801139:	89 c3                	mov    %eax,%ebx
  80113b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80113f:	29 da                	sub    %ebx,%edx
  801141:	19 ce                	sbb    %ecx,%esi
  801143:	89 f9                	mov    %edi,%ecx
  801145:	89 f0                	mov    %esi,%eax
  801147:	d3 e0                	shl    %cl,%eax
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	d3 ea                	shr    %cl,%edx
  80114d:	89 e9                	mov    %ebp,%ecx
  80114f:	d3 ee                	shr    %cl,%esi
  801151:	09 d0                	or     %edx,%eax
  801153:	89 f2                	mov    %esi,%edx
  801155:	83 c4 1c             	add    $0x1c,%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    
  80115d:	8d 76 00             	lea    0x0(%esi),%esi
  801160:	29 f9                	sub    %edi,%ecx
  801162:	19 d6                	sbb    %edx,%esi
  801164:	89 74 24 04          	mov    %esi,0x4(%esp)
  801168:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80116c:	e9 18 ff ff ff       	jmp    801089 <__umoddi3+0x69>
