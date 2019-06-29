
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 40 10 80 00       	push   $0x801040
  800045:	e8 b1 01 00 00       	call   8001fb <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 6f 0b 00 00       	call   800bcd <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 10 80 00       	push   $0x801060
  80006f:	6a 0e                	push   $0xe
  800071:	68 4a 10 80 00       	push   $0x80104a
  800076:	e8 a7 00 00 00       	call   800122 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 10 80 00       	push   $0x80108c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ee 06 00 00       	call   800777 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 db 0c 00 00       	call   800d7c <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 5c 10 80 00       	push   $0x80105c
  8000ae:	e8 48 01 00 00       	call   8001fb <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 5c 10 80 00       	push   $0x80105c
  8000c0:	e8 36 01 00 00       	call   8001fb <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 b5 0a 00 00       	call   800b8f <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 31 0a 00 00       	call   800b4e <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800130:	e8 5a 0a 00 00       	call   800b8f <sys_getenvid>
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	ff 75 0c             	pushl  0xc(%ebp)
  80013b:	ff 75 08             	pushl  0x8(%ebp)
  80013e:	56                   	push   %esi
  80013f:	50                   	push   %eax
  800140:	68 b8 10 80 00       	push   $0x8010b8
  800145:	e8 b1 00 00 00       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014a:	83 c4 18             	add    $0x18,%esp
  80014d:	53                   	push   %ebx
  80014e:	ff 75 10             	pushl  0x10(%ebp)
  800151:	e8 54 00 00 00       	call   8001aa <vcprintf>
	cprintf("\n");
  800156:	c7 04 24 5e 10 80 00 	movl   $0x80105e,(%esp)
  80015d:	e8 99 00 00 00       	call   8001fb <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800165:	cc                   	int3   
  800166:	eb fd                	jmp    800165 <_panic+0x43>

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	75 1a                	jne    8001a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 79 09 00 00       	call   800b11 <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	50                   	push   %eax
  8001d4:	68 68 01 80 00       	push   $0x800168
  8001d9:	e8 54 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001de:	83 c4 08             	add    $0x8,%esp
  8001e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 1e 09 00 00       	call   800b11 <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	50                   	push   %eax
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	e8 9d ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 1c             	sub    $0x1c,%esp
  800218:	89 c7                	mov    %eax,%edi
  80021a:	89 d6                	mov    %edx,%esi
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800222:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800225:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800228:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800233:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800236:	39 d3                	cmp    %edx,%ebx
  800238:	72 05                	jb     80023f <printnum+0x30>
  80023a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023d:	77 45                	ja     800284 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 18             	pushl  0x18(%ebp)
  800245:	8b 45 14             	mov    0x14(%ebp),%eax
  800248:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024b:	53                   	push   %ebx
  80024c:	ff 75 10             	pushl  0x10(%ebp)
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 4d 0b 00 00       	call   800db0 <__udivdi3>
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	52                   	push   %edx
  800267:	50                   	push   %eax
  800268:	89 f2                	mov    %esi,%edx
  80026a:	89 f8                	mov    %edi,%eax
  80026c:	e8 9e ff ff ff       	call   80020f <printnum>
  800271:	83 c4 20             	add    $0x20,%esp
  800274:	eb 18                	jmp    80028e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	eb 03                	jmp    800287 <printnum+0x78>
  800284:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	83 eb 01             	sub    $0x1,%ebx
  80028a:	85 db                	test   %ebx,%ebx
  80028c:	7f e8                	jg     800276 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	ff 75 e4             	pushl  -0x1c(%ebp)
  800298:	ff 75 e0             	pushl  -0x20(%ebp)
  80029b:	ff 75 dc             	pushl  -0x24(%ebp)
  80029e:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a1:	e8 3a 0c 00 00       	call   800ee0 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 db 10 80 00 	movsbl 0x8010db(%eax),%eax
  8002b0:	50                   	push   %eax
  8002b1:	ff d7                	call   *%edi
}
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	88 02                	mov    %al,(%edx)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	eb 12                	jmp    800358 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 d3 03 00 00    	je     800721 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	53                   	push   %ebx
  800352:	50                   	push   %eax
  800353:	ff d6                	call   *%esi
  800355:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800358:	83 c7 01             	add    $0x1,%edi
  80035b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035f:	83 f8 25             	cmp    $0x25,%eax
  800362:	75 e2                	jne    800346 <vprintfmt+0x14>
  800364:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800368:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800376:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
  800382:	eb 07                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800387:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8d 47 01             	lea    0x1(%edi),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	0f b6 07             	movzbl (%edi),%eax
  800394:	0f b6 c8             	movzbl %al,%ecx
  800397:	83 e8 23             	sub    $0x23,%eax
  80039a:	3c 55                	cmp    $0x55,%al
  80039c:	0f 87 64 03 00 00    	ja     800706 <vprintfmt+0x3d4>
  8003a2:	0f b6 c0             	movzbl %al,%eax
  8003a5:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b3:	eb d6                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003cd:	83 fa 09             	cmp    $0x9,%edx
  8003d0:	77 39                	ja     80040b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e8:	eb 27                	jmp    800411 <vprintfmt+0xdf>
  8003ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f4:	0f 49 c8             	cmovns %eax,%ecx
  8003f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fd:	eb 8c                	jmp    80038b <vprintfmt+0x59>
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800402:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800409:	eb 80                	jmp    80038b <vprintfmt+0x59>
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	0f 89 70 ff ff ff    	jns    80038b <vprintfmt+0x59>
				width = precision, precision = -1;
  80041b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80041e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800421:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800428:	e9 5e ff ff ff       	jmp    80038b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800433:	e9 53 ff ff ff       	jmp    80038b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	ff 30                	pushl  (%eax)
  800447:	ff d6                	call   *%esi
			break;
  800449:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044f:	e9 04 ff ff ff       	jmp    800358 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	99                   	cltd   
  800460:	31 d0                	xor    %edx,%eax
  800462:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800464:	83 f8 08             	cmp    $0x8,%eax
  800467:	7f 0b                	jg     800474 <vprintfmt+0x142>
  800469:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	75 18                	jne    80048c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800474:	50                   	push   %eax
  800475:	68 f3 10 80 00       	push   $0x8010f3
  80047a:	53                   	push   %ebx
  80047b:	56                   	push   %esi
  80047c:	e8 94 fe ff ff       	call   800315 <printfmt>
  800481:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800487:	e9 cc fe ff ff       	jmp    800358 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048c:	52                   	push   %edx
  80048d:	68 fc 10 80 00       	push   $0x8010fc
  800492:	53                   	push   %ebx
  800493:	56                   	push   %esi
  800494:	e8 7c fe ff ff       	call   800315 <printfmt>
  800499:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049f:	e9 b4 fe ff ff       	jmp    800358 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004af:	85 ff                	test   %edi,%edi
  8004b1:	b8 ec 10 80 00       	mov    $0x8010ec,%eax
  8004b6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bd:	0f 8e 94 00 00 00    	jle    800557 <vprintfmt+0x225>
  8004c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c7:	0f 84 98 00 00 00    	je     800565 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 c8             	pushl  -0x38(%ebp)
  8004d3:	57                   	push   %edi
  8004d4:	e8 d0 02 00 00       	call   8007a9 <strnlen>
  8004d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004dc:	29 c1                	sub    %eax,%ecx
  8004de:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004eb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ee:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	eb 0f                	jmp    800501 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ef 01             	sub    $0x1,%edi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 ff                	test   %edi,%edi
  800503:	7f ed                	jg     8004f2 <vprintfmt+0x1c0>
  800505:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800508:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80050b:	85 c9                	test   %ecx,%ecx
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	0f 49 c1             	cmovns %ecx,%eax
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 75 08             	mov    %esi,0x8(%ebp)
  80051a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80051d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800520:	89 cb                	mov    %ecx,%ebx
  800522:	eb 4d                	jmp    800571 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800524:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800528:	74 1b                	je     800545 <vprintfmt+0x213>
  80052a:	0f be c0             	movsbl %al,%eax
  80052d:	83 e8 20             	sub    $0x20,%eax
  800530:	83 f8 5e             	cmp    $0x5e,%eax
  800533:	76 10                	jbe    800545 <vprintfmt+0x213>
					putch('?', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 0c             	pushl  0xc(%ebp)
  80053b:	6a 3f                	push   $0x3f
  80053d:	ff 55 08             	call   *0x8(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb 0d                	jmp    800552 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	ff 75 0c             	pushl  0xc(%ebp)
  80054b:	52                   	push   %edx
  80054c:	ff 55 08             	call   *0x8(%ebp)
  80054f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	83 eb 01             	sub    $0x1,%ebx
  800555:	eb 1a                	jmp    800571 <vprintfmt+0x23f>
  800557:	89 75 08             	mov    %esi,0x8(%ebp)
  80055a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80055d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800560:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800563:	eb 0c                	jmp    800571 <vprintfmt+0x23f>
  800565:	89 75 08             	mov    %esi,0x8(%ebp)
  800568:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80056b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800571:	83 c7 01             	add    $0x1,%edi
  800574:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800578:	0f be d0             	movsbl %al,%edx
  80057b:	85 d2                	test   %edx,%edx
  80057d:	74 23                	je     8005a2 <vprintfmt+0x270>
  80057f:	85 f6                	test   %esi,%esi
  800581:	78 a1                	js     800524 <vprintfmt+0x1f2>
  800583:	83 ee 01             	sub    $0x1,%esi
  800586:	79 9c                	jns    800524 <vprintfmt+0x1f2>
  800588:	89 df                	mov    %ebx,%edi
  80058a:	8b 75 08             	mov    0x8(%ebp),%esi
  80058d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800590:	eb 18                	jmp    8005aa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	6a 20                	push   $0x20
  800598:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059a:	83 ef 01             	sub    $0x1,%edi
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	eb 08                	jmp    8005aa <vprintfmt+0x278>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	85 ff                	test   %edi,%edi
  8005ac:	7f e4                	jg     800592 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	e9 a2 fd ff ff       	jmp    800358 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b6:	83 fa 01             	cmp    $0x1,%edx
  8005b9:	7e 16                	jle    8005d1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 08             	lea    0x8(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 50 04             	mov    0x4(%eax),%edx
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005cc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005cf:	eb 32                	jmp    800603 <vprintfmt+0x2d1>
	else if (lflag)
  8005d1:	85 d2                	test   %edx,%edx
  8005d3:	74 18                	je     8005ed <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005eb:	eb 16                	jmp    800603 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005fb:	89 c1                	mov    %eax,%ecx
  8005fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800603:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800606:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800614:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800618:	0f 89 b0 00 00 00    	jns    8006ce <vprintfmt+0x39c>
				putch('-', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 2d                	push   $0x2d
  800624:	ff d6                	call   *%esi
				num = -(long long) num;
  800626:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800629:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80062c:	f7 d8                	neg    %eax
  80062e:	83 d2 00             	adc    $0x0,%edx
  800631:	f7 da                	neg    %edx
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800639:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800641:	e9 88 00 00 00       	jmp    8006ce <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 70 fc ff ff       	call   8002be <getuint>
  80064e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800651:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800654:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800659:	eb 73                	jmp    8006ce <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 5b fc ff ff       	call   8002be <getuint>
  800663:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800666:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	6a 58                	push   $0x58
  80066f:	ff d6                	call   *%esi
			putch('X', putdat);
  800671:	83 c4 08             	add    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 58                	push   $0x58
  800677:	ff d6                	call   *%esi
			putch('X', putdat);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 58                	push   $0x58
  80067f:	ff d6                	call   *%esi
			goto number;
  800681:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800684:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800689:	eb 43                	jmp    8006ce <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 30                	push   $0x30
  800691:	ff d6                	call   *%esi
			putch('x', putdat);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 78                	push   $0x78
  800699:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8d 50 04             	lea    0x4(%eax),%edx
  8006a1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a4:	8b 00                	mov    (%eax),%eax
  8006a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b9:	eb 13                	jmp    8006ce <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 fb fb ff ff       	call   8002be <getuint>
  8006c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006c9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006d5:	52                   	push   %edx
  8006d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d9:	50                   	push   %eax
  8006da:	ff 75 dc             	pushl  -0x24(%ebp)
  8006dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e0:	89 da                	mov    %ebx,%edx
  8006e2:	89 f0                	mov    %esi,%eax
  8006e4:	e8 26 fb ff ff       	call   80020f <printnum>
			break;
  8006e9:	83 c4 20             	add    $0x20,%esp
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ef:	e9 64 fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	51                   	push   %ecx
  8006f9:	ff d6                	call   *%esi
			break;
  8006fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800701:	e9 52 fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	6a 25                	push   $0x25
  80070c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb 03                	jmp    800716 <vprintfmt+0x3e4>
  800713:	83 ef 01             	sub    $0x1,%edi
  800716:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80071a:	75 f7                	jne    800713 <vprintfmt+0x3e1>
  80071c:	e9 37 fc ff ff       	jmp    800358 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800724:	5b                   	pop    %ebx
  800725:	5e                   	pop    %esi
  800726:	5f                   	pop    %edi
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	83 ec 18             	sub    $0x18,%esp
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800735:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800738:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800746:	85 c0                	test   %eax,%eax
  800748:	74 26                	je     800770 <vsnprintf+0x47>
  80074a:	85 d2                	test   %edx,%edx
  80074c:	7e 22                	jle    800770 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074e:	ff 75 14             	pushl  0x14(%ebp)
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800757:	50                   	push   %eax
  800758:	68 f8 02 80 00       	push   $0x8002f8
  80075d:	e8 d0 fb ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800762:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800765:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	eb 05                	jmp    800775 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800770:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800780:	50                   	push   %eax
  800781:	ff 75 10             	pushl  0x10(%ebp)
  800784:	ff 75 0c             	pushl  0xc(%ebp)
  800787:	ff 75 08             	pushl  0x8(%ebp)
  80078a:	e8 9a ff ff ff       	call   800729 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800797:	b8 00 00 00 00       	mov    $0x0,%eax
  80079c:	eb 03                	jmp    8007a1 <strlen+0x10>
		n++;
  80079e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a5:	75 f7                	jne    80079e <strlen+0xd>
		n++;
	return n;
}
  8007a7:	5d                   	pop    %ebp
  8007a8:	c3                   	ret    

008007a9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007af:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b7:	eb 03                	jmp    8007bc <strnlen+0x13>
		n++;
  8007b9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	39 c2                	cmp    %eax,%edx
  8007be:	74 08                	je     8007c8 <strnlen+0x1f>
  8007c0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c4:	75 f3                	jne    8007b9 <strnlen+0x10>
  8007c6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d4:	89 c2                	mov    %eax,%edx
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	83 c1 01             	add    $0x1,%ecx
  8007dc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e3:	84 db                	test   %bl,%bl
  8007e5:	75 ef                	jne    8007d6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e7:	5b                   	pop    %ebx
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f1:	53                   	push   %ebx
  8007f2:	e8 9a ff ff ff       	call   800791 <strlen>
  8007f7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007fa:	ff 75 0c             	pushl  0xc(%ebp)
  8007fd:	01 d8                	add    %ebx,%eax
  8007ff:	50                   	push   %eax
  800800:	e8 c5 ff ff ff       	call   8007ca <strcpy>
	return dst;
}
  800805:	89 d8                	mov    %ebx,%eax
  800807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	8b 75 08             	mov    0x8(%ebp),%esi
  800814:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800817:	89 f3                	mov    %esi,%ebx
  800819:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	89 f2                	mov    %esi,%edx
  80081e:	eb 0f                	jmp    80082f <strncpy+0x23>
		*dst++ = *src;
  800820:	83 c2 01             	add    $0x1,%edx
  800823:	0f b6 01             	movzbl (%ecx),%eax
  800826:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800829:	80 39 01             	cmpb   $0x1,(%ecx)
  80082c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082f:	39 da                	cmp    %ebx,%edx
  800831:	75 ed                	jne    800820 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800833:	89 f0                	mov    %esi,%eax
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800844:	8b 55 10             	mov    0x10(%ebp),%edx
  800847:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800849:	85 d2                	test   %edx,%edx
  80084b:	74 21                	je     80086e <strlcpy+0x35>
  80084d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800851:	89 f2                	mov    %esi,%edx
  800853:	eb 09                	jmp    80085e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800855:	83 c2 01             	add    $0x1,%edx
  800858:	83 c1 01             	add    $0x1,%ecx
  80085b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085e:	39 c2                	cmp    %eax,%edx
  800860:	74 09                	je     80086b <strlcpy+0x32>
  800862:	0f b6 19             	movzbl (%ecx),%ebx
  800865:	84 db                	test   %bl,%bl
  800867:	75 ec                	jne    800855 <strlcpy+0x1c>
  800869:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80086b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086e:	29 f0                	sub    %esi,%eax
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087d:	eb 06                	jmp    800885 <strcmp+0x11>
		p++, q++;
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800885:	0f b6 01             	movzbl (%ecx),%eax
  800888:	84 c0                	test   %al,%al
  80088a:	74 04                	je     800890 <strcmp+0x1c>
  80088c:	3a 02                	cmp    (%edx),%al
  80088e:	74 ef                	je     80087f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800890:	0f b6 c0             	movzbl %al,%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a4:	89 c3                	mov    %eax,%ebx
  8008a6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a9:	eb 06                	jmp    8008b1 <strncmp+0x17>
		n--, p++, q++;
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b1:	39 d8                	cmp    %ebx,%eax
  8008b3:	74 15                	je     8008ca <strncmp+0x30>
  8008b5:	0f b6 08             	movzbl (%eax),%ecx
  8008b8:	84 c9                	test   %cl,%cl
  8008ba:	74 04                	je     8008c0 <strncmp+0x26>
  8008bc:	3a 0a                	cmp    (%edx),%cl
  8008be:	74 eb                	je     8008ab <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c0:	0f b6 00             	movzbl (%eax),%eax
  8008c3:	0f b6 12             	movzbl (%edx),%edx
  8008c6:	29 d0                	sub    %edx,%eax
  8008c8:	eb 05                	jmp    8008cf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dc:	eb 07                	jmp    8008e5 <strchr+0x13>
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 0f                	je     8008f1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	0f b6 10             	movzbl (%eax),%edx
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 f2                	jne    8008de <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fd:	eb 03                	jmp    800902 <strfind+0xf>
  8008ff:	83 c0 01             	add    $0x1,%eax
  800902:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 04                	je     80090d <strfind+0x1a>
  800909:	84 d2                	test   %dl,%dl
  80090b:	75 f2                	jne    8008ff <strfind+0xc>
			break;
	return (char *) s;
}
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 7d 08             	mov    0x8(%ebp),%edi
  800918:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091b:	85 c9                	test   %ecx,%ecx
  80091d:	74 36                	je     800955 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800925:	75 28                	jne    80094f <memset+0x40>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 23                	jne    80094f <memset+0x40>
		c &= 0xFF;
  80092c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800930:	89 d3                	mov    %edx,%ebx
  800932:	c1 e3 08             	shl    $0x8,%ebx
  800935:	89 d6                	mov    %edx,%esi
  800937:	c1 e6 18             	shl    $0x18,%esi
  80093a:	89 d0                	mov    %edx,%eax
  80093c:	c1 e0 10             	shl    $0x10,%eax
  80093f:	09 f0                	or     %esi,%eax
  800941:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800943:	89 d8                	mov    %ebx,%eax
  800945:	09 d0                	or     %edx,%eax
  800947:	c1 e9 02             	shr    $0x2,%ecx
  80094a:	fc                   	cld    
  80094b:	f3 ab                	rep stos %eax,%es:(%edi)
  80094d:	eb 06                	jmp    800955 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	fc                   	cld    
  800953:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800955:	89 f8                	mov    %edi,%eax
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 75 0c             	mov    0xc(%ebp),%esi
  800967:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096a:	39 c6                	cmp    %eax,%esi
  80096c:	73 35                	jae    8009a3 <memmove+0x47>
  80096e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800971:	39 d0                	cmp    %edx,%eax
  800973:	73 2e                	jae    8009a3 <memmove+0x47>
		s += n;
		d += n;
  800975:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800978:	89 d6                	mov    %edx,%esi
  80097a:	09 fe                	or     %edi,%esi
  80097c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800982:	75 13                	jne    800997 <memmove+0x3b>
  800984:	f6 c1 03             	test   $0x3,%cl
  800987:	75 0e                	jne    800997 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800989:	83 ef 04             	sub    $0x4,%edi
  80098c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098f:	c1 e9 02             	shr    $0x2,%ecx
  800992:	fd                   	std    
  800993:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800995:	eb 09                	jmp    8009a0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800997:	83 ef 01             	sub    $0x1,%edi
  80099a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80099d:	fd                   	std    
  80099e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a0:	fc                   	cld    
  8009a1:	eb 1d                	jmp    8009c0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	89 f2                	mov    %esi,%edx
  8009a5:	09 c2                	or     %eax,%edx
  8009a7:	f6 c2 03             	test   $0x3,%dl
  8009aa:	75 0f                	jne    8009bb <memmove+0x5f>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0a                	jne    8009bb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b1:	c1 e9 02             	shr    $0x2,%ecx
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	fc                   	cld    
  8009b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b9:	eb 05                	jmp    8009c0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009bb:	89 c7                	mov    %eax,%edi
  8009bd:	fc                   	cld    
  8009be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c0:	5e                   	pop    %esi
  8009c1:	5f                   	pop    %edi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c7:	ff 75 10             	pushl  0x10(%ebp)
  8009ca:	ff 75 0c             	pushl  0xc(%ebp)
  8009cd:	ff 75 08             	pushl  0x8(%ebp)
  8009d0:	e8 87 ff ff ff       	call   80095c <memmove>
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e2:	89 c6                	mov    %eax,%esi
  8009e4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e7:	eb 1a                	jmp    800a03 <memcmp+0x2c>
		if (*s1 != *s2)
  8009e9:	0f b6 08             	movzbl (%eax),%ecx
  8009ec:	0f b6 1a             	movzbl (%edx),%ebx
  8009ef:	38 d9                	cmp    %bl,%cl
  8009f1:	74 0a                	je     8009fd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f3:	0f b6 c1             	movzbl %cl,%eax
  8009f6:	0f b6 db             	movzbl %bl,%ebx
  8009f9:	29 d8                	sub    %ebx,%eax
  8009fb:	eb 0f                	jmp    800a0c <memcmp+0x35>
		s1++, s2++;
  8009fd:	83 c0 01             	add    $0x1,%eax
  800a00:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a03:	39 f0                	cmp    %esi,%eax
  800a05:	75 e2                	jne    8009e9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5e                   	pop    %esi
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a17:	89 c1                	mov    %eax,%ecx
  800a19:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a20:	eb 0a                	jmp    800a2c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a22:	0f b6 10             	movzbl (%eax),%edx
  800a25:	39 da                	cmp    %ebx,%edx
  800a27:	74 07                	je     800a30 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	39 c8                	cmp    %ecx,%eax
  800a2e:	72 f2                	jb     800a22 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a30:	5b                   	pop    %ebx
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3f:	eb 03                	jmp    800a44 <strtol+0x11>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a44:	0f b6 01             	movzbl (%ecx),%eax
  800a47:	3c 20                	cmp    $0x20,%al
  800a49:	74 f6                	je     800a41 <strtol+0xe>
  800a4b:	3c 09                	cmp    $0x9,%al
  800a4d:	74 f2                	je     800a41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4f:	3c 2b                	cmp    $0x2b,%al
  800a51:	75 0a                	jne    800a5d <strtol+0x2a>
		s++;
  800a53:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a56:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5b:	eb 11                	jmp    800a6e <strtol+0x3b>
  800a5d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a62:	3c 2d                	cmp    $0x2d,%al
  800a64:	75 08                	jne    800a6e <strtol+0x3b>
		s++, neg = 1;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a74:	75 15                	jne    800a8b <strtol+0x58>
  800a76:	80 39 30             	cmpb   $0x30,(%ecx)
  800a79:	75 10                	jne    800a8b <strtol+0x58>
  800a7b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7f:	75 7c                	jne    800afd <strtol+0xca>
		s += 2, base = 16;
  800a81:	83 c1 02             	add    $0x2,%ecx
  800a84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a89:	eb 16                	jmp    800aa1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	75 12                	jne    800aa1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a94:	80 39 30             	cmpb   $0x30,(%ecx)
  800a97:	75 08                	jne    800aa1 <strtol+0x6e>
		s++, base = 8;
  800a99:	83 c1 01             	add    $0x1,%ecx
  800a9c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa9:	0f b6 11             	movzbl (%ecx),%edx
  800aac:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 09             	cmp    $0x9,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x8b>
			dig = *s - '0';
  800ab6:	0f be d2             	movsbl %dl,%edx
  800ab9:	83 ea 30             	sub    $0x30,%edx
  800abc:	eb 22                	jmp    800ae0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800abe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 19             	cmp    $0x19,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 57             	sub    $0x57,%edx
  800ace:	eb 10                	jmp    800ae0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad3:	89 f3                	mov    %esi,%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 16                	ja     800af0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ada:	0f be d2             	movsbl %dl,%edx
  800add:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae3:	7d 0b                	jge    800af0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ae5:	83 c1 01             	add    $0x1,%ecx
  800ae8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aec:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aee:	eb b9                	jmp    800aa9 <strtol+0x76>

	if (endptr)
  800af0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af4:	74 0d                	je     800b03 <strtol+0xd0>
		*endptr = (char *) s;
  800af6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af9:	89 0e                	mov    %ecx,(%esi)
  800afb:	eb 06                	jmp    800b03 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afd:	85 db                	test   %ebx,%ebx
  800aff:	74 98                	je     800a99 <strtol+0x66>
  800b01:	eb 9e                	jmp    800aa1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b03:	89 c2                	mov    %eax,%edx
  800b05:	f7 da                	neg    %edx
  800b07:	85 ff                	test   %edi,%edi
  800b09:	0f 45 c2             	cmovne %edx,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b22:	89 c3                	mov    %eax,%ebx
  800b24:	89 c7                	mov    %eax,%edi
  800b26:	89 c6                	mov    %eax,%esi
  800b28:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b61:	8b 55 08             	mov    0x8(%ebp),%edx
  800b64:	89 cb                	mov    %ecx,%ebx
  800b66:	89 cf                	mov    %ecx,%edi
  800b68:	89 ce                	mov    %ecx,%esi
  800b6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	7e 17                	jle    800b87 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	50                   	push   %eax
  800b74:	6a 03                	push   $0x3
  800b76:	68 24 13 80 00       	push   $0x801324
  800b7b:	6a 23                	push   $0x23
  800b7d:	68 41 13 80 00       	push   $0x801341
  800b82:	e8 9b f5 ff ff       	call   800122 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_yield>:

void
sys_yield(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bd6:	be 00 00 00 00       	mov    $0x0,%esi
  800bdb:	b8 04 00 00 00       	mov    $0x4,%eax
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be9:	89 f7                	mov    %esi,%edi
  800beb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 04                	push   $0x4
  800bf7:	68 24 13 80 00       	push   $0x801324
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 41 13 80 00       	push   $0x801341
  800c03:	e8 1a f5 ff ff       	call   800122 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c19:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 17                	jle    800c4a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 05                	push   $0x5
  800c39:	68 24 13 80 00       	push   $0x801324
  800c3e:	6a 23                	push   $0x23
  800c40:	68 41 13 80 00       	push   $0x801341
  800c45:	e8 d8 f4 ff ff       	call   800122 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 06 00 00 00       	mov    $0x6,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 17                	jle    800c8c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 06                	push   $0x6
  800c7b:	68 24 13 80 00       	push   $0x801324
  800c80:	6a 23                	push   $0x23
  800c82:	68 41 13 80 00       	push   $0x801341
  800c87:	e8 96 f4 ff ff       	call   800122 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 08                	push   $0x8
  800cbd:	68 24 13 80 00       	push   $0x801324
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 41 13 80 00       	push   $0x801341
  800cc9:	e8 54 f4 ff ff       	call   800122 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 17                	jle    800d10 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 09                	push   $0x9
  800cff:	68 24 13 80 00       	push   $0x801324
  800d04:	6a 23                	push   $0x23
  800d06:	68 41 13 80 00       	push   $0x801341
  800d0b:	e8 12 f4 ff ff       	call   800122 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d1e:	be 00 00 00 00       	mov    $0x0,%esi
  800d23:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d31:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d34:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d49:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 cb                	mov    %ecx,%ebx
  800d53:	89 cf                	mov    %ecx,%edi
  800d55:	89 ce                	mov    %ecx,%esi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 0c                	push   $0xc
  800d63:	68 24 13 80 00       	push   $0x801324
  800d68:	6a 23                	push   $0x23
  800d6a:	68 41 13 80 00       	push   $0x801341
  800d6f:	e8 ae f3 ff ff       	call   800122 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d82:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d89:	75 14                	jne    800d9f <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	68 50 13 80 00       	push   $0x801350
  800d93:	6a 20                	push   $0x20
  800d95:	68 74 13 80 00       	push   $0x801374
  800d9a:	e8 83 f3 ff ff       	call   800122 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    
  800da9:	66 90                	xchg   %ax,%ax
  800dab:	66 90                	xchg   %ax,%ax
  800dad:	66 90                	xchg   %ax,%ax
  800daf:	90                   	nop

00800db0 <__udivdi3>:
  800db0:	55                   	push   %ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 1c             	sub    $0x1c,%esp
  800db7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dc7:	85 f6                	test   %esi,%esi
  800dc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dcd:	89 ca                	mov    %ecx,%edx
  800dcf:	89 f8                	mov    %edi,%eax
  800dd1:	75 3d                	jne    800e10 <__udivdi3+0x60>
  800dd3:	39 cf                	cmp    %ecx,%edi
  800dd5:	0f 87 c5 00 00 00    	ja     800ea0 <__udivdi3+0xf0>
  800ddb:	85 ff                	test   %edi,%edi
  800ddd:	89 fd                	mov    %edi,%ebp
  800ddf:	75 0b                	jne    800dec <__udivdi3+0x3c>
  800de1:	b8 01 00 00 00       	mov    $0x1,%eax
  800de6:	31 d2                	xor    %edx,%edx
  800de8:	f7 f7                	div    %edi
  800dea:	89 c5                	mov    %eax,%ebp
  800dec:	89 c8                	mov    %ecx,%eax
  800dee:	31 d2                	xor    %edx,%edx
  800df0:	f7 f5                	div    %ebp
  800df2:	89 c1                	mov    %eax,%ecx
  800df4:	89 d8                	mov    %ebx,%eax
  800df6:	89 cf                	mov    %ecx,%edi
  800df8:	f7 f5                	div    %ebp
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	39 ce                	cmp    %ecx,%esi
  800e12:	77 74                	ja     800e88 <__udivdi3+0xd8>
  800e14:	0f bd fe             	bsr    %esi,%edi
  800e17:	83 f7 1f             	xor    $0x1f,%edi
  800e1a:	0f 84 98 00 00 00    	je     800eb8 <__udivdi3+0x108>
  800e20:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	89 c5                	mov    %eax,%ebp
  800e29:	29 fb                	sub    %edi,%ebx
  800e2b:	d3 e6                	shl    %cl,%esi
  800e2d:	89 d9                	mov    %ebx,%ecx
  800e2f:	d3 ed                	shr    %cl,%ebp
  800e31:	89 f9                	mov    %edi,%ecx
  800e33:	d3 e0                	shl    %cl,%eax
  800e35:	09 ee                	or     %ebp,%esi
  800e37:	89 d9                	mov    %ebx,%ecx
  800e39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e3d:	89 d5                	mov    %edx,%ebp
  800e3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e43:	d3 ed                	shr    %cl,%ebp
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	d3 e2                	shl    %cl,%edx
  800e49:	89 d9                	mov    %ebx,%ecx
  800e4b:	d3 e8                	shr    %cl,%eax
  800e4d:	09 c2                	or     %eax,%edx
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	89 ea                	mov    %ebp,%edx
  800e53:	f7 f6                	div    %esi
  800e55:	89 d5                	mov    %edx,%ebp
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	f7 64 24 0c          	mull   0xc(%esp)
  800e5d:	39 d5                	cmp    %edx,%ebp
  800e5f:	72 10                	jb     800e71 <__udivdi3+0xc1>
  800e61:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e65:	89 f9                	mov    %edi,%ecx
  800e67:	d3 e6                	shl    %cl,%esi
  800e69:	39 c6                	cmp    %eax,%esi
  800e6b:	73 07                	jae    800e74 <__udivdi3+0xc4>
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	75 03                	jne    800e74 <__udivdi3+0xc4>
  800e71:	83 eb 01             	sub    $0x1,%ebx
  800e74:	31 ff                	xor    %edi,%edi
  800e76:	89 d8                	mov    %ebx,%eax
  800e78:	89 fa                	mov    %edi,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	31 ff                	xor    %edi,%edi
  800e8a:	31 db                	xor    %ebx,%ebx
  800e8c:	89 d8                	mov    %ebx,%eax
  800e8e:	89 fa                	mov    %edi,%edx
  800e90:	83 c4 1c             	add    $0x1c,%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    
  800e98:	90                   	nop
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 d8                	mov    %ebx,%eax
  800ea2:	f7 f7                	div    %edi
  800ea4:	31 ff                	xor    %edi,%edi
  800ea6:	89 c3                	mov    %eax,%ebx
  800ea8:	89 d8                	mov    %ebx,%eax
  800eaa:	89 fa                	mov    %edi,%edx
  800eac:	83 c4 1c             	add    $0x1c,%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	39 ce                	cmp    %ecx,%esi
  800eba:	72 0c                	jb     800ec8 <__udivdi3+0x118>
  800ebc:	31 db                	xor    %ebx,%ebx
  800ebe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ec2:	0f 87 34 ff ff ff    	ja     800dfc <__udivdi3+0x4c>
  800ec8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ecd:	e9 2a ff ff ff       	jmp    800dfc <__udivdi3+0x4c>
  800ed2:	66 90                	xchg   %ax,%ax
  800ed4:	66 90                	xchg   %ax,%ax
  800ed6:	66 90                	xchg   %ax,%ax
  800ed8:	66 90                	xchg   %ax,%ax
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__umoddi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 1c             	sub    $0x1c,%esp
  800ee7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eeb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eef:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ef7:	85 d2                	test   %edx,%edx
  800ef9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f01:	89 f3                	mov    %esi,%ebx
  800f03:	89 3c 24             	mov    %edi,(%esp)
  800f06:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f0a:	75 1c                	jne    800f28 <__umoddi3+0x48>
  800f0c:	39 f7                	cmp    %esi,%edi
  800f0e:	76 50                	jbe    800f60 <__umoddi3+0x80>
  800f10:	89 c8                	mov    %ecx,%eax
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	f7 f7                	div    %edi
  800f16:	89 d0                	mov    %edx,%eax
  800f18:	31 d2                	xor    %edx,%edx
  800f1a:	83 c4 1c             	add    $0x1c,%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
  800f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f28:	39 f2                	cmp    %esi,%edx
  800f2a:	89 d0                	mov    %edx,%eax
  800f2c:	77 52                	ja     800f80 <__umoddi3+0xa0>
  800f2e:	0f bd ea             	bsr    %edx,%ebp
  800f31:	83 f5 1f             	xor    $0x1f,%ebp
  800f34:	75 5a                	jne    800f90 <__umoddi3+0xb0>
  800f36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f3a:	0f 82 e0 00 00 00    	jb     801020 <__umoddi3+0x140>
  800f40:	39 0c 24             	cmp    %ecx,(%esp)
  800f43:	0f 86 d7 00 00 00    	jbe    801020 <__umoddi3+0x140>
  800f49:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f51:	83 c4 1c             	add    $0x1c,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	85 ff                	test   %edi,%edi
  800f62:	89 fd                	mov    %edi,%ebp
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x91>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f7                	div    %edi
  800f6f:	89 c5                	mov    %eax,%ebp
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f5                	div    %ebp
  800f77:	89 c8                	mov    %ecx,%eax
  800f79:	f7 f5                	div    %ebp
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	eb 99                	jmp    800f18 <__umoddi3+0x38>
  800f7f:	90                   	nop
  800f80:	89 c8                	mov    %ecx,%eax
  800f82:	89 f2                	mov    %esi,%edx
  800f84:	83 c4 1c             	add    $0x1c,%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    
  800f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f90:	8b 34 24             	mov    (%esp),%esi
  800f93:	bf 20 00 00 00       	mov    $0x20,%edi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	29 ef                	sub    %ebp,%edi
  800f9c:	d3 e0                	shl    %cl,%eax
  800f9e:	89 f9                	mov    %edi,%ecx
  800fa0:	89 f2                	mov    %esi,%edx
  800fa2:	d3 ea                	shr    %cl,%edx
  800fa4:	89 e9                	mov    %ebp,%ecx
  800fa6:	09 c2                	or     %eax,%edx
  800fa8:	89 d8                	mov    %ebx,%eax
  800faa:	89 14 24             	mov    %edx,(%esp)
  800fad:	89 f2                	mov    %esi,%edx
  800faf:	d3 e2                	shl    %cl,%edx
  800fb1:	89 f9                	mov    %edi,%ecx
  800fb3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	89 e9                	mov    %ebp,%ecx
  800fbf:	89 c6                	mov    %eax,%esi
  800fc1:	d3 e3                	shl    %cl,%ebx
  800fc3:	89 f9                	mov    %edi,%ecx
  800fc5:	89 d0                	mov    %edx,%eax
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	09 d8                	or     %ebx,%eax
  800fcd:	89 d3                	mov    %edx,%ebx
  800fcf:	89 f2                	mov    %esi,%edx
  800fd1:	f7 34 24             	divl   (%esp)
  800fd4:	89 d6                	mov    %edx,%esi
  800fd6:	d3 e3                	shl    %cl,%ebx
  800fd8:	f7 64 24 04          	mull   0x4(%esp)
  800fdc:	39 d6                	cmp    %edx,%esi
  800fde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fe2:	89 d1                	mov    %edx,%ecx
  800fe4:	89 c3                	mov    %eax,%ebx
  800fe6:	72 08                	jb     800ff0 <__umoddi3+0x110>
  800fe8:	75 11                	jne    800ffb <__umoddi3+0x11b>
  800fea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fee:	73 0b                	jae    800ffb <__umoddi3+0x11b>
  800ff0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800ff4:	1b 14 24             	sbb    (%esp),%edx
  800ff7:	89 d1                	mov    %edx,%ecx
  800ff9:	89 c3                	mov    %eax,%ebx
  800ffb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fff:	29 da                	sub    %ebx,%edx
  801001:	19 ce                	sbb    %ecx,%esi
  801003:	89 f9                	mov    %edi,%ecx
  801005:	89 f0                	mov    %esi,%eax
  801007:	d3 e0                	shl    %cl,%eax
  801009:	89 e9                	mov    %ebp,%ecx
  80100b:	d3 ea                	shr    %cl,%edx
  80100d:	89 e9                	mov    %ebp,%ecx
  80100f:	d3 ee                	shr    %cl,%esi
  801011:	09 d0                	or     %edx,%eax
  801013:	89 f2                	mov    %esi,%edx
  801015:	83 c4 1c             	add    $0x1c,%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5f                   	pop    %edi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	29 f9                	sub    %edi,%ecx
  801022:	19 d6                	sbb    %edx,%esi
  801024:	89 74 24 04          	mov    %esi,0x4(%esp)
  801028:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80102c:	e9 18 ff ff ff       	jmp    800f49 <__umoddi3+0x69>
