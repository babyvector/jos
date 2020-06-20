
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 e0 1e 80 00       	push   $0x801ee0
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 62 0b 00 00       	call   800bc0 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 00 1f 80 00       	push   $0x801f00
  80006f:	6a 0f                	push   $0xf
  800071:	68 ea 1e 80 00       	push   $0x801eea
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 2c 1f 80 00       	push   $0x801f2c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 e1 06 00 00       	call   80076a <snprintf>
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
  80009c:	e8 10 0d 00 00       	call   800db1 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 54 0a 00 00       	call   800b04 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 bd 0a 00 00       	call   800b82 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 ff 0e 00 00       	call   801005 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 31 0a 00 00       	call   800b41 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 5a 0a 00 00       	call   800b82 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 58 1f 80 00       	push   $0x801f58
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 c3 23 80 00 	movl   $0x8023c3,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 79 09 00 00       	call   800b04 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 1e 09 00 00       	call   800b04 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 ea 19 00 00       	call   801c40 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 d7 1a 00 00       	call   801d70 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 d3 03 00 00    	je     800714 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 07                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8d 47 01             	lea    0x1(%edi),%eax
  800381:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 64 03 00 00    	ja     8006f9 <vprintfmt+0x3d4>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a6:	eb d6                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 39                	ja     8003fe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c8:	eb e9                	jmp    8003b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003db:	eb 27                	jmp    800404 <vprintfmt+0xdf>
  8003dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	0f 49 c8             	cmovns %eax,%ecx
  8003ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	eb 8c                	jmp    80037e <vprintfmt+0x59>
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fc:	eb 80                	jmp    80037e <vprintfmt+0x59>
  8003fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800401:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 89 70 ff ff ff    	jns    80037e <vprintfmt+0x59>
				width = precision, precision = -1;
  80040e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800414:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80041b:	e9 5e ff ff ff       	jmp    80037e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800420:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800426:	e9 53 ff ff ff       	jmp    80037e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800442:	e9 04 ff ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	99                   	cltd   
  800453:	31 d0                	xor    %edx,%eax
  800455:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 0f             	cmp    $0xf,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x142>
  80045c:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 93 1f 80 00       	push   $0x801f93
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 94 fe ff ff       	call   800308 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047a:	e9 cc fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047f:	52                   	push   %edx
  800480:	68 91 23 80 00       	push   $0x802391
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 7c fe ff ff       	call   800308 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 b4 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	b8 8c 1f 80 00       	mov    $0x801f8c,%eax
  8004a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	0f 8e 94 00 00 00    	jle    80054a <vprintfmt+0x225>
  8004b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ba:	0f 84 98 00 00 00    	je     800558 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 c8             	pushl  -0x38(%ebp)
  8004c6:	57                   	push   %edi
  8004c7:	e8 d0 02 00 00       	call   80079c <strnlen>
  8004cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	eb 0f                	jmp    8004f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ed                	jg     8004e5 <vprintfmt+0x1c0>
  8004f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004fe:	85 c9                	test   %ecx,%ecx
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 49 c1             	cmovns %ecx,%eax
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	eb 4d                	jmp    800564 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	74 1b                	je     800538 <vprintfmt+0x213>
  80051d:	0f be c0             	movsbl %al,%eax
  800520:	83 e8 20             	sub    $0x20,%eax
  800523:	83 f8 5e             	cmp    $0x5e,%eax
  800526:	76 10                	jbe    800538 <vprintfmt+0x213>
					putch('?', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	ff 75 0c             	pushl  0xc(%ebp)
  80052e:	6a 3f                	push   $0x3f
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	eb 0d                	jmp    800545 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	52                   	push   %edx
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	83 eb 01             	sub    $0x1,%ebx
  800548:	eb 1a                	jmp    800564 <vprintfmt+0x23f>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	eb 0c                	jmp    800564 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 23                	je     800595 <vprintfmt+0x270>
  800572:	85 f6                	test   %esi,%esi
  800574:	78 a1                	js     800517 <vprintfmt+0x1f2>
  800576:	83 ee 01             	sub    $0x1,%esi
  800579:	79 9c                	jns    800517 <vprintfmt+0x1f2>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	eb 18                	jmp    80059d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	6a 20                	push   $0x20
  80058b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	83 ef 01             	sub    $0x1,%edi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 08                	jmp    80059d <vprintfmt+0x278>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	85 ff                	test   %edi,%edi
  80059f:	7f e4                	jg     800585 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a4:	e9 a2 fd ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a9:	83 fa 01             	cmp    $0x1,%edx
  8005ac:	7e 16                	jle    8005c4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 08             	lea    0x8(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005bf:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005c2:	eb 32                	jmp    8005f6 <vprintfmt+0x2d1>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 18                	je     8005e0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005de:	eb 16                	jmp    8005f6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005f9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800607:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80060b:	0f 89 b0 00 00 00    	jns    8006c1 <vprintfmt+0x39c>
				putch('-', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 2d                	push   $0x2d
  800617:	ff d6                	call   *%esi
				num = -(long long) num;
  800619:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80061c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80061f:	f7 d8                	neg    %eax
  800621:	83 d2 00             	adc    $0x0,%edx
  800624:	f7 da                	neg    %edx
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800629:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800634:	e9 88 00 00 00       	jmp    8006c1 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800639:	8d 45 14             	lea    0x14(%ebp),%eax
  80063c:	e8 70 fc ff ff       	call   8002b1 <getuint>
  800641:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800644:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80064c:	eb 73                	jmp    8006c1 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 5b fc ff ff       	call   8002b1 <getuint>
  800656:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800659:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 58                	push   $0x58
  800662:	ff d6                	call   *%esi
			putch('X', putdat);
  800664:	83 c4 08             	add    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 58                	push   $0x58
  80066a:	ff d6                	call   *%esi
			putch('X', putdat);
  80066c:	83 c4 08             	add    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 58                	push   $0x58
  800672:	ff d6                	call   *%esi
			goto number;
  800674:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800677:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80067c:	eb 43                	jmp    8006c1 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 30                	push   $0x30
  800684:	ff d6                	call   *%esi
			putch('x', putdat);
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 78                	push   $0x78
  80068c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 50 04             	lea    0x4(%eax),%edx
  800694:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800697:	8b 00                	mov    (%eax),%eax
  800699:	ba 00 00 00 00       	mov    $0x0,%edx
  80069e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ac:	eb 13                	jmp    8006c1 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b1:	e8 fb fb ff ff       	call   8002b1 <getuint>
  8006b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006c8:	52                   	push   %edx
  8006c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cc:	50                   	push   %eax
  8006cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8006d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d3:	89 da                	mov    %ebx,%edx
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	e8 26 fb ff ff       	call   800202 <printnum>
			break;
  8006dc:	83 c4 20             	add    $0x20,%esp
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e2:	e9 64 fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	51                   	push   %ecx
  8006ec:	ff d6                	call   *%esi
			break;
  8006ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f4:	e9 52 fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	6a 25                	push   $0x25
  8006ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb 03                	jmp    800709 <vprintfmt+0x3e4>
  800706:	83 ef 01             	sub    $0x1,%edi
  800709:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070d:	75 f7                	jne    800706 <vprintfmt+0x3e1>
  80070f:	e9 37 fc ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800714:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800717:	5b                   	pop    %ebx
  800718:	5e                   	pop    %esi
  800719:	5f                   	pop    %edi
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 18             	sub    $0x18,%esp
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800728:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800732:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800739:	85 c0                	test   %eax,%eax
  80073b:	74 26                	je     800763 <vsnprintf+0x47>
  80073d:	85 d2                	test   %edx,%edx
  80073f:	7e 22                	jle    800763 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800741:	ff 75 14             	pushl  0x14(%ebp)
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074a:	50                   	push   %eax
  80074b:	68 eb 02 80 00       	push   $0x8002eb
  800750:	e8 d0 fb ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800755:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800758:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb 05                	jmp    800768 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800773:	50                   	push   %eax
  800774:	ff 75 10             	pushl  0x10(%ebp)
  800777:	ff 75 0c             	pushl  0xc(%ebp)
  80077a:	ff 75 08             	pushl  0x8(%ebp)
  80077d:	e8 9a ff ff ff       	call   80071c <vsnprintf>
	va_end(ap);

	return rc;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
  80078f:	eb 03                	jmp    800794 <strlen+0x10>
		n++;
  800791:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800794:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800798:	75 f7                	jne    800791 <strlen+0xd>
		n++;
	return n;
}
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007aa:	eb 03                	jmp    8007af <strnlen+0x13>
		n++;
  8007ac:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007af:	39 c2                	cmp    %eax,%edx
  8007b1:	74 08                	je     8007bb <strnlen+0x1f>
  8007b3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b7:	75 f3                	jne    8007ac <strnlen+0x10>
  8007b9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	53                   	push   %ebx
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	83 c1 01             	add    $0x1,%ecx
  8007cf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d6:	84 db                	test   %bl,%bl
  8007d8:	75 ef                	jne    8007c9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e4:	53                   	push   %ebx
  8007e5:	e8 9a ff ff ff       	call   800784 <strlen>
  8007ea:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ed:	ff 75 0c             	pushl  0xc(%ebp)
  8007f0:	01 d8                	add    %ebx,%eax
  8007f2:	50                   	push   %eax
  8007f3:	e8 c5 ff ff ff       	call   8007bd <strcpy>
	return dst;
}
  8007f8:	89 d8                	mov    %ebx,%eax
  8007fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	8b 75 08             	mov    0x8(%ebp),%esi
  800807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080a:	89 f3                	mov    %esi,%ebx
  80080c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080f:	89 f2                	mov    %esi,%edx
  800811:	eb 0f                	jmp    800822 <strncpy+0x23>
		*dst++ = *src;
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	0f b6 01             	movzbl (%ecx),%eax
  800819:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081c:	80 39 01             	cmpb   $0x1,(%ecx)
  80081f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	39 da                	cmp    %ebx,%edx
  800824:	75 ed                	jne    800813 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800826:	89 f0                	mov    %esi,%eax
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800837:	8b 55 10             	mov    0x10(%ebp),%edx
  80083a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	85 d2                	test   %edx,%edx
  80083e:	74 21                	je     800861 <strlcpy+0x35>
  800840:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 09                	jmp    800851 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800851:	39 c2                	cmp    %eax,%edx
  800853:	74 09                	je     80085e <strlcpy+0x32>
  800855:	0f b6 19             	movzbl (%ecx),%ebx
  800858:	84 db                	test   %bl,%bl
  80085a:	75 ec                	jne    800848 <strlcpy+0x1c>
  80085c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800861:	29 f0                	sub    %esi,%eax
}
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800870:	eb 06                	jmp    800878 <strcmp+0x11>
		p++, q++;
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800878:	0f b6 01             	movzbl (%ecx),%eax
  80087b:	84 c0                	test   %al,%al
  80087d:	74 04                	je     800883 <strcmp+0x1c>
  80087f:	3a 02                	cmp    (%edx),%al
  800881:	74 ef                	je     800872 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 c0             	movzbl %al,%eax
  800886:	0f b6 12             	movzbl (%edx),%edx
  800889:	29 d0                	sub    %edx,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	53                   	push   %ebx
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	89 c3                	mov    %eax,%ebx
  800899:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089c:	eb 06                	jmp    8008a4 <strncmp+0x17>
		n--, p++, q++;
  80089e:	83 c0 01             	add    $0x1,%eax
  8008a1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a4:	39 d8                	cmp    %ebx,%eax
  8008a6:	74 15                	je     8008bd <strncmp+0x30>
  8008a8:	0f b6 08             	movzbl (%eax),%ecx
  8008ab:	84 c9                	test   %cl,%cl
  8008ad:	74 04                	je     8008b3 <strncmp+0x26>
  8008af:	3a 0a                	cmp    (%edx),%cl
  8008b1:	74 eb                	je     80089e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 00             	movzbl (%eax),%eax
  8008b6:	0f b6 12             	movzbl (%edx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
  8008bb:	eb 05                	jmp    8008c2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c2:	5b                   	pop    %ebx
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cf:	eb 07                	jmp    8008d8 <strchr+0x13>
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 0f                	je     8008e4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d5:	83 c0 01             	add    $0x1,%eax
  8008d8:	0f b6 10             	movzbl (%eax),%edx
  8008db:	84 d2                	test   %dl,%dl
  8008dd:	75 f2                	jne    8008d1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	eb 03                	jmp    8008f5 <strfind+0xf>
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	74 04                	je     800900 <strfind+0x1a>
  8008fc:	84 d2                	test   %dl,%dl
  8008fe:	75 f2                	jne    8008f2 <strfind+0xc>
			break;
	return (char *) s;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090e:	85 c9                	test   %ecx,%ecx
  800910:	74 36                	je     800948 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800912:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800918:	75 28                	jne    800942 <memset+0x40>
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	75 23                	jne    800942 <memset+0x40>
		c &= 0xFF;
  80091f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800923:	89 d3                	mov    %edx,%ebx
  800925:	c1 e3 08             	shl    $0x8,%ebx
  800928:	89 d6                	mov    %edx,%esi
  80092a:	c1 e6 18             	shl    $0x18,%esi
  80092d:	89 d0                	mov    %edx,%eax
  80092f:	c1 e0 10             	shl    $0x10,%eax
  800932:	09 f0                	or     %esi,%eax
  800934:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800936:	89 d8                	mov    %ebx,%eax
  800938:	09 d0                	or     %edx,%eax
  80093a:	c1 e9 02             	shr    $0x2,%ecx
  80093d:	fc                   	cld    
  80093e:	f3 ab                	rep stos %eax,%es:(%edi)
  800940:	eb 06                	jmp    800948 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800942:	8b 45 0c             	mov    0xc(%ebp),%eax
  800945:	fc                   	cld    
  800946:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800948:	89 f8                	mov    %edi,%eax
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	57                   	push   %edi
  800953:	56                   	push   %esi
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095d:	39 c6                	cmp    %eax,%esi
  80095f:	73 35                	jae    800996 <memmove+0x47>
  800961:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800964:	39 d0                	cmp    %edx,%eax
  800966:	73 2e                	jae    800996 <memmove+0x47>
		s += n;
		d += n;
  800968:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096b:	89 d6                	mov    %edx,%esi
  80096d:	09 fe                	or     %edi,%esi
  80096f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800975:	75 13                	jne    80098a <memmove+0x3b>
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 0e                	jne    80098a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097c:	83 ef 04             	sub    $0x4,%edi
  80097f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800982:	c1 e9 02             	shr    $0x2,%ecx
  800985:	fd                   	std    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 09                	jmp    800993 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098a:	83 ef 01             	sub    $0x1,%edi
  80098d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800990:	fd                   	std    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800993:	fc                   	cld    
  800994:	eb 1d                	jmp    8009b3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	89 f2                	mov    %esi,%edx
  800998:	09 c2                	or     %eax,%edx
  80099a:	f6 c2 03             	test   $0x3,%dl
  80099d:	75 0f                	jne    8009ae <memmove+0x5f>
  80099f:	f6 c1 03             	test   $0x3,%cl
  8009a2:	75 0a                	jne    8009ae <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a4:	c1 e9 02             	shr    $0x2,%ecx
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ac:	eb 05                	jmp    8009b3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ae:	89 c7                	mov    %eax,%edi
  8009b0:	fc                   	cld    
  8009b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b3:	5e                   	pop    %esi
  8009b4:	5f                   	pop    %edi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ba:	ff 75 10             	pushl  0x10(%ebp)
  8009bd:	ff 75 0c             	pushl  0xc(%ebp)
  8009c0:	ff 75 08             	pushl  0x8(%ebp)
  8009c3:	e8 87 ff ff ff       	call   80094f <memmove>
}
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d5:	89 c6                	mov    %eax,%esi
  8009d7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009da:	eb 1a                	jmp    8009f6 <memcmp+0x2c>
		if (*s1 != *s2)
  8009dc:	0f b6 08             	movzbl (%eax),%ecx
  8009df:	0f b6 1a             	movzbl (%edx),%ebx
  8009e2:	38 d9                	cmp    %bl,%cl
  8009e4:	74 0a                	je     8009f0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e6:	0f b6 c1             	movzbl %cl,%eax
  8009e9:	0f b6 db             	movzbl %bl,%ebx
  8009ec:	29 d8                	sub    %ebx,%eax
  8009ee:	eb 0f                	jmp    8009ff <memcmp+0x35>
		s1++, s2++;
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f6:	39 f0                	cmp    %esi,%eax
  8009f8:	75 e2                	jne    8009dc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0a:	89 c1                	mov    %eax,%ecx
  800a0c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a13:	eb 0a                	jmp    800a1f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a15:	0f b6 10             	movzbl (%eax),%edx
  800a18:	39 da                	cmp    %ebx,%edx
  800a1a:	74 07                	je     800a23 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	39 c8                	cmp    %ecx,%eax
  800a21:	72 f2                	jb     800a15 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	eb 03                	jmp    800a37 <strtol+0x11>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a37:	0f b6 01             	movzbl (%ecx),%eax
  800a3a:	3c 20                	cmp    $0x20,%al
  800a3c:	74 f6                	je     800a34 <strtol+0xe>
  800a3e:	3c 09                	cmp    $0x9,%al
  800a40:	74 f2                	je     800a34 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a42:	3c 2b                	cmp    $0x2b,%al
  800a44:	75 0a                	jne    800a50 <strtol+0x2a>
		s++;
  800a46:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4e:	eb 11                	jmp    800a61 <strtol+0x3b>
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a55:	3c 2d                	cmp    $0x2d,%al
  800a57:	75 08                	jne    800a61 <strtol+0x3b>
		s++, neg = 1;
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a61:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a67:	75 15                	jne    800a7e <strtol+0x58>
  800a69:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6c:	75 10                	jne    800a7e <strtol+0x58>
  800a6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a72:	75 7c                	jne    800af0 <strtol+0xca>
		s += 2, base = 16;
  800a74:	83 c1 02             	add    $0x2,%ecx
  800a77:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7c:	eb 16                	jmp    800a94 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7e:	85 db                	test   %ebx,%ebx
  800a80:	75 12                	jne    800a94 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a82:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a87:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8a:	75 08                	jne    800a94 <strtol+0x6e>
		s++, base = 8;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
  800a99:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9c:	0f b6 11             	movzbl (%ecx),%edx
  800a9f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 09             	cmp    $0x9,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0x8b>
			dig = *s - '0';
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 30             	sub    $0x30,%edx
  800aaf:	eb 22                	jmp    800ad3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 57             	sub    $0x57,%edx
  800ac1:	eb 10                	jmp    800ad3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 16                	ja     800ae3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad6:	7d 0b                	jge    800ae3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae1:	eb b9                	jmp    800a9c <strtol+0x76>

	if (endptr)
  800ae3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae7:	74 0d                	je     800af6 <strtol+0xd0>
		*endptr = (char *) s;
  800ae9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aec:	89 0e                	mov    %ecx,(%esi)
  800aee:	eb 06                	jmp    800af6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af0:	85 db                	test   %ebx,%ebx
  800af2:	74 98                	je     800a8c <strtol+0x66>
  800af4:	eb 9e                	jmp    800a94 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af6:	89 c2                	mov    %eax,%edx
  800af8:	f7 da                	neg    %edx
  800afa:	85 ff                	test   %edi,%edi
  800afc:	0f 45 c2             	cmovne %edx,%eax
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	89 c3                	mov    %eax,%ebx
  800b17:	89 c7                	mov    %eax,%edi
  800b19:	89 c6                	mov    %eax,%esi
  800b1b:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b32:	89 d1                	mov    %edx,%ecx
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	89 cb                	mov    %ecx,%ebx
  800b59:	89 cf                	mov    %ecx,%edi
  800b5b:	89 ce                	mov    %ecx,%esi
  800b5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 17                	jle    800b7a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	6a 03                	push   $0x3
  800b69:	68 7f 22 80 00       	push   $0x80227f
  800b6e:	6a 23                	push   $0x23
  800b70:	68 9c 22 80 00       	push   $0x80229c
  800b75:	e8 9b f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_yield>:

void
sys_yield(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb1:	89 d1                	mov    %edx,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc9:	be 00 00 00 00       	mov    $0x0,%esi
  800bce:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdc:	89 f7                	mov    %esi,%edi
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 04                	push   $0x4
  800bea:	68 7f 22 80 00       	push   $0x80227f
  800bef:	6a 23                	push   $0x23
  800bf1:	68 9c 22 80 00       	push   $0x80229c
  800bf6:	e8 1a f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c0c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 05                	push   $0x5
  800c2c:	68 7f 22 80 00       	push   $0x80227f
  800c31:	6a 23                	push   $0x23
  800c33:	68 9c 22 80 00       	push   $0x80229c
  800c38:	e8 d8 f4 ff ff       	call   800115 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 06 00 00 00       	mov    $0x6,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 06                	push   $0x6
  800c6e:	68 7f 22 80 00       	push   $0x80227f
  800c73:	6a 23                	push   $0x23
  800c75:	68 9c 22 80 00       	push   $0x80229c
  800c7a:	e8 96 f4 ff ff       	call   800115 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 08                	push   $0x8
  800cb0:	68 7f 22 80 00       	push   $0x80227f
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 9c 22 80 00       	push   $0x80229c
  800cbc:	e8 54 f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 df                	mov    %ebx,%edi
  800ce4:	89 de                	mov    %ebx,%esi
  800ce6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	7e 17                	jle    800d03 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 09                	push   $0x9
  800cf2:	68 7f 22 80 00       	push   $0x80227f
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 9c 22 80 00       	push   $0x80229c
  800cfe:	e8 12 f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 df                	mov    %ebx,%edi
  800d26:	89 de                	mov    %ebx,%esi
  800d28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 0a                	push   $0xa
  800d34:	68 7f 22 80 00       	push   $0x80227f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 9c 22 80 00       	push   $0x80229c
  800d40:	e8 d0 f3 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d53:	be 00 00 00 00       	mov    $0x0,%esi
  800d58:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d69:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 cb                	mov    %ecx,%ebx
  800d88:	89 cf                	mov    %ecx,%edi
  800d8a:	89 ce                	mov    %ecx,%esi
  800d8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7e 17                	jle    800da9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	6a 0d                	push   $0xd
  800d98:	68 7f 22 80 00       	push   $0x80227f
  800d9d:	6a 23                	push   $0x23
  800d9f:	68 9c 22 80 00       	push   $0x80229c
  800da4:	e8 6c f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  800db7:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dbe:	75 4c                	jne    800e0c <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  800dc0:	a1 04 40 80 00       	mov    0x804004,%eax
  800dc5:	8b 40 48             	mov    0x48(%eax),%eax
  800dc8:	83 ec 04             	sub    $0x4,%esp
  800dcb:	6a 07                	push   $0x7
  800dcd:	68 00 f0 bf ee       	push   $0xeebff000
  800dd2:	50                   	push   %eax
  800dd3:	e8 e8 fd ff ff       	call   800bc0 <sys_page_alloc>
		if(retv != 0){
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	74 14                	je     800df3 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	68 ac 22 80 00       	push   $0x8022ac
  800de7:	6a 27                	push   $0x27
  800de9:	68 d8 22 80 00       	push   $0x8022d8
  800dee:	e8 22 f3 ff ff       	call   800115 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800df3:	a1 04 40 80 00       	mov    0x804004,%eax
  800df8:	8b 40 48             	mov    0x48(%eax),%eax
  800dfb:	83 ec 08             	sub    $0x8,%esp
  800dfe:	68 16 0e 80 00       	push   $0x800e16
  800e03:	50                   	push   %eax
  800e04:	e8 02 ff ff ff       	call   800d0b <sys_env_set_pgfault_upcall>
  800e09:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0f:	a3 08 40 80 00       	mov    %eax,0x804008

}
  800e14:	c9                   	leave  
  800e15:	c3                   	ret    

00800e16 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e16:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e17:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e1c:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  800e1e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  800e21:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  800e25:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  800e2a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  800e2e:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  800e30:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  800e33:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  800e34:	83 c4 04             	add    $0x4,%esp
	popfl
  800e37:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e38:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e39:	c3                   	ret    

00800e3a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	05 00 00 00 30       	add    $0x30000000,%eax
  800e45:	c1 e8 0c             	shr    $0xc,%eax
}
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e50:	05 00 00 00 30       	add    $0x30000000,%eax
  800e55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e5a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e67:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e6c:	89 c2                	mov    %eax,%edx
  800e6e:	c1 ea 16             	shr    $0x16,%edx
  800e71:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e78:	f6 c2 01             	test   $0x1,%dl
  800e7b:	74 11                	je     800e8e <fd_alloc+0x2d>
  800e7d:	89 c2                	mov    %eax,%edx
  800e7f:	c1 ea 0c             	shr    $0xc,%edx
  800e82:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e89:	f6 c2 01             	test   $0x1,%dl
  800e8c:	75 09                	jne    800e97 <fd_alloc+0x36>
			*fd_store = fd;
  800e8e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	eb 17                	jmp    800eae <fd_alloc+0x4d>
  800e97:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e9c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ea1:	75 c9                	jne    800e6c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb6:	83 f8 1f             	cmp    $0x1f,%eax
  800eb9:	77 36                	ja     800ef1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ebb:	c1 e0 0c             	shl    $0xc,%eax
  800ebe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec3:	89 c2                	mov    %eax,%edx
  800ec5:	c1 ea 16             	shr    $0x16,%edx
  800ec8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecf:	f6 c2 01             	test   $0x1,%dl
  800ed2:	74 24                	je     800ef8 <fd_lookup+0x48>
  800ed4:	89 c2                	mov    %eax,%edx
  800ed6:	c1 ea 0c             	shr    $0xc,%edx
  800ed9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee0:	f6 c2 01             	test   $0x1,%dl
  800ee3:	74 1a                	je     800eff <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee8:	89 02                	mov    %eax,(%edx)
	return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	eb 13                	jmp    800f04 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef6:	eb 0c                	jmp    800f04 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efd:	eb 05                	jmp    800f04 <fd_lookup+0x54>
  800eff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 08             	sub    $0x8,%esp
  800f0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0f:	ba 68 23 80 00       	mov    $0x802368,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f14:	eb 13                	jmp    800f29 <dev_lookup+0x23>
  800f16:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f19:	39 08                	cmp    %ecx,(%eax)
  800f1b:	75 0c                	jne    800f29 <dev_lookup+0x23>
			*dev = devtab[i];
  800f1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f20:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	eb 2e                	jmp    800f57 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f29:	8b 02                	mov    (%edx),%eax
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	75 e7                	jne    800f16 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f2f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f34:	8b 40 48             	mov    0x48(%eax),%eax
  800f37:	83 ec 04             	sub    $0x4,%esp
  800f3a:	51                   	push   %ecx
  800f3b:	50                   	push   %eax
  800f3c:	68 e8 22 80 00       	push   $0x8022e8
  800f41:	e8 a8 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f49:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
  800f5e:	83 ec 10             	sub    $0x10,%esp
  800f61:	8b 75 08             	mov    0x8(%ebp),%esi
  800f64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6a:	50                   	push   %eax
  800f6b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f71:	c1 e8 0c             	shr    $0xc,%eax
  800f74:	50                   	push   %eax
  800f75:	e8 36 ff ff ff       	call   800eb0 <fd_lookup>
  800f7a:	83 c4 08             	add    $0x8,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	78 05                	js     800f86 <fd_close+0x2d>
	    || fd != fd2)
  800f81:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f84:	74 0c                	je     800f92 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f86:	84 db                	test   %bl,%bl
  800f88:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8d:	0f 44 c2             	cmove  %edx,%eax
  800f90:	eb 41                	jmp    800fd3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f92:	83 ec 08             	sub    $0x8,%esp
  800f95:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	ff 36                	pushl  (%esi)
  800f9b:	e8 66 ff ff ff       	call   800f06 <dev_lookup>
  800fa0:	89 c3                	mov    %eax,%ebx
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 1a                	js     800fc3 <fd_close+0x6a>
		if (dev->dev_close)
  800fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fac:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800faf:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	74 0b                	je     800fc3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	56                   	push   %esi
  800fbc:	ff d0                	call   *%eax
  800fbe:	89 c3                	mov    %eax,%ebx
  800fc0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc3:	83 ec 08             	sub    $0x8,%esp
  800fc6:	56                   	push   %esi
  800fc7:	6a 00                	push   $0x0
  800fc9:	e8 77 fc ff ff       	call   800c45 <sys_page_unmap>
	return r;
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	89 d8                	mov    %ebx,%eax
}
  800fd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe3:	50                   	push   %eax
  800fe4:	ff 75 08             	pushl  0x8(%ebp)
  800fe7:	e8 c4 fe ff ff       	call   800eb0 <fd_lookup>
  800fec:	83 c4 08             	add    $0x8,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 10                	js     801003 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	6a 01                	push   $0x1
  800ff8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffb:	e8 59 ff ff ff       	call   800f59 <fd_close>
  801000:	83 c4 10             	add    $0x10,%esp
}
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <close_all>:

void
close_all(void)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	53                   	push   %ebx
  801009:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80100c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	53                   	push   %ebx
  801015:	e8 c0 ff ff ff       	call   800fda <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80101a:	83 c3 01             	add    $0x1,%ebx
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	83 fb 20             	cmp    $0x20,%ebx
  801023:	75 ec                	jne    801011 <close_all+0xc>
		close(i);
}
  801025:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801028:	c9                   	leave  
  801029:	c3                   	ret    

0080102a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	57                   	push   %edi
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	83 ec 2c             	sub    $0x2c,%esp
  801033:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801036:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801039:	50                   	push   %eax
  80103a:	ff 75 08             	pushl  0x8(%ebp)
  80103d:	e8 6e fe ff ff       	call   800eb0 <fd_lookup>
  801042:	83 c4 08             	add    $0x8,%esp
  801045:	85 c0                	test   %eax,%eax
  801047:	0f 88 c1 00 00 00    	js     80110e <dup+0xe4>
		return r;
	close(newfdnum);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	56                   	push   %esi
  801051:	e8 84 ff ff ff       	call   800fda <close>

	newfd = INDEX2FD(newfdnum);
  801056:	89 f3                	mov    %esi,%ebx
  801058:	c1 e3 0c             	shl    $0xc,%ebx
  80105b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801061:	83 c4 04             	add    $0x4,%esp
  801064:	ff 75 e4             	pushl  -0x1c(%ebp)
  801067:	e8 de fd ff ff       	call   800e4a <fd2data>
  80106c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80106e:	89 1c 24             	mov    %ebx,(%esp)
  801071:	e8 d4 fd ff ff       	call   800e4a <fd2data>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80107c:	89 f8                	mov    %edi,%eax
  80107e:	c1 e8 16             	shr    $0x16,%eax
  801081:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801088:	a8 01                	test   $0x1,%al
  80108a:	74 37                	je     8010c3 <dup+0x99>
  80108c:	89 f8                	mov    %edi,%eax
  80108e:	c1 e8 0c             	shr    $0xc,%eax
  801091:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801098:	f6 c2 01             	test   $0x1,%dl
  80109b:	74 26                	je     8010c3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80109d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ac:	50                   	push   %eax
  8010ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b0:	6a 00                	push   $0x0
  8010b2:	57                   	push   %edi
  8010b3:	6a 00                	push   $0x0
  8010b5:	e8 49 fb ff ff       	call   800c03 <sys_page_map>
  8010ba:	89 c7                	mov    %eax,%edi
  8010bc:	83 c4 20             	add    $0x20,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	78 2e                	js     8010f1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010c6:	89 d0                	mov    %edx,%eax
  8010c8:	c1 e8 0c             	shr    $0xc,%eax
  8010cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010da:	50                   	push   %eax
  8010db:	53                   	push   %ebx
  8010dc:	6a 00                	push   $0x0
  8010de:	52                   	push   %edx
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 1d fb ff ff       	call   800c03 <sys_page_map>
  8010e6:	89 c7                	mov    %eax,%edi
  8010e8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010eb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ed:	85 ff                	test   %edi,%edi
  8010ef:	79 1d                	jns    80110e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010f1:	83 ec 08             	sub    $0x8,%esp
  8010f4:	53                   	push   %ebx
  8010f5:	6a 00                	push   $0x0
  8010f7:	e8 49 fb ff ff       	call   800c45 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010fc:	83 c4 08             	add    $0x8,%esp
  8010ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801102:	6a 00                	push   $0x0
  801104:	e8 3c fb ff ff       	call   800c45 <sys_page_unmap>
	return r;
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	89 f8                	mov    %edi,%eax
}
  80110e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	53                   	push   %ebx
  80111a:	83 ec 14             	sub    $0x14,%esp
  80111d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801120:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	53                   	push   %ebx
  801125:	e8 86 fd ff ff       	call   800eb0 <fd_lookup>
  80112a:	83 c4 08             	add    $0x8,%esp
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 6d                	js     8011a0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801133:	83 ec 08             	sub    $0x8,%esp
  801136:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113d:	ff 30                	pushl  (%eax)
  80113f:	e8 c2 fd ff ff       	call   800f06 <dev_lookup>
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 4c                	js     801197 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80114b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114e:	8b 42 08             	mov    0x8(%edx),%eax
  801151:	83 e0 03             	and    $0x3,%eax
  801154:	83 f8 01             	cmp    $0x1,%eax
  801157:	75 21                	jne    80117a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801159:	a1 04 40 80 00       	mov    0x804004,%eax
  80115e:	8b 40 48             	mov    0x48(%eax),%eax
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	53                   	push   %ebx
  801165:	50                   	push   %eax
  801166:	68 2c 23 80 00       	push   $0x80232c
  80116b:	e8 7e f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801178:	eb 26                	jmp    8011a0 <read+0x8a>
	}
	if (!dev->dev_read)
  80117a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117d:	8b 40 08             	mov    0x8(%eax),%eax
  801180:	85 c0                	test   %eax,%eax
  801182:	74 17                	je     80119b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	ff 75 10             	pushl  0x10(%ebp)
  80118a:	ff 75 0c             	pushl  0xc(%ebp)
  80118d:	52                   	push   %edx
  80118e:	ff d0                	call   *%eax
  801190:	89 c2                	mov    %eax,%edx
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	eb 09                	jmp    8011a0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801197:	89 c2                	mov    %eax,%edx
  801199:	eb 05                	jmp    8011a0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80119b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011a0:	89 d0                	mov    %edx,%eax
  8011a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    

008011a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 0c             	sub    $0xc,%esp
  8011b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bb:	eb 21                	jmp    8011de <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011bd:	83 ec 04             	sub    $0x4,%esp
  8011c0:	89 f0                	mov    %esi,%eax
  8011c2:	29 d8                	sub    %ebx,%eax
  8011c4:	50                   	push   %eax
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	03 45 0c             	add    0xc(%ebp),%eax
  8011ca:	50                   	push   %eax
  8011cb:	57                   	push   %edi
  8011cc:	e8 45 ff ff ff       	call   801116 <read>
		if (m < 0)
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 10                	js     8011e8 <readn+0x41>
			return m;
		if (m == 0)
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	74 0a                	je     8011e6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011dc:	01 c3                	add    %eax,%ebx
  8011de:	39 f3                	cmp    %esi,%ebx
  8011e0:	72 db                	jb     8011bd <readn+0x16>
  8011e2:	89 d8                	mov    %ebx,%eax
  8011e4:	eb 02                	jmp    8011e8 <readn+0x41>
  8011e6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 14             	sub    $0x14,%esp
  8011f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	53                   	push   %ebx
  8011ff:	e8 ac fc ff ff       	call   800eb0 <fd_lookup>
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	89 c2                	mov    %eax,%edx
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 68                	js     801275 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801217:	ff 30                	pushl  (%eax)
  801219:	e8 e8 fc ff ff       	call   800f06 <dev_lookup>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	78 47                	js     80126c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801225:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801228:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122c:	75 21                	jne    80124f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80122e:	a1 04 40 80 00       	mov    0x804004,%eax
  801233:	8b 40 48             	mov    0x48(%eax),%eax
  801236:	83 ec 04             	sub    $0x4,%esp
  801239:	53                   	push   %ebx
  80123a:	50                   	push   %eax
  80123b:	68 48 23 80 00       	push   $0x802348
  801240:	e8 a9 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124d:	eb 26                	jmp    801275 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80124f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801252:	8b 52 0c             	mov    0xc(%edx),%edx
  801255:	85 d2                	test   %edx,%edx
  801257:	74 17                	je     801270 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801259:	83 ec 04             	sub    $0x4,%esp
  80125c:	ff 75 10             	pushl  0x10(%ebp)
  80125f:	ff 75 0c             	pushl  0xc(%ebp)
  801262:	50                   	push   %eax
  801263:	ff d2                	call   *%edx
  801265:	89 c2                	mov    %eax,%edx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	eb 09                	jmp    801275 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	eb 05                	jmp    801275 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801270:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801275:	89 d0                	mov    %edx,%eax
  801277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <seek>:

int
seek(int fdnum, off_t offset)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801282:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	ff 75 08             	pushl  0x8(%ebp)
  801289:	e8 22 fc ff ff       	call   800eb0 <fd_lookup>
  80128e:	83 c4 08             	add    $0x8,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	78 0e                	js     8012a3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801295:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801298:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    

008012a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 14             	sub    $0x14,%esp
  8012ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b2:	50                   	push   %eax
  8012b3:	53                   	push   %ebx
  8012b4:	e8 f7 fb ff ff       	call   800eb0 <fd_lookup>
  8012b9:	83 c4 08             	add    $0x8,%esp
  8012bc:	89 c2                	mov    %eax,%edx
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 65                	js     801327 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c8:	50                   	push   %eax
  8012c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cc:	ff 30                	pushl  (%eax)
  8012ce:	e8 33 fc ff ff       	call   800f06 <dev_lookup>
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 44                	js     80131e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e1:	75 21                	jne    801304 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012e3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e8:	8b 40 48             	mov    0x48(%eax),%eax
  8012eb:	83 ec 04             	sub    $0x4,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	50                   	push   %eax
  8012f0:	68 08 23 80 00       	push   $0x802308
  8012f5:	e8 f4 ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801302:	eb 23                	jmp    801327 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801304:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801307:	8b 52 18             	mov    0x18(%edx),%edx
  80130a:	85 d2                	test   %edx,%edx
  80130c:	74 14                	je     801322 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	ff 75 0c             	pushl  0xc(%ebp)
  801314:	50                   	push   %eax
  801315:	ff d2                	call   *%edx
  801317:	89 c2                	mov    %eax,%edx
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	eb 09                	jmp    801327 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131e:	89 c2                	mov    %eax,%edx
  801320:	eb 05                	jmp    801327 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801322:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801327:	89 d0                	mov    %edx,%eax
  801329:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132c:	c9                   	leave  
  80132d:	c3                   	ret    

0080132e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	53                   	push   %ebx
  801332:	83 ec 14             	sub    $0x14,%esp
  801335:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801338:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 6c fb ff ff       	call   800eb0 <fd_lookup>
  801344:	83 c4 08             	add    $0x8,%esp
  801347:	89 c2                	mov    %eax,%edx
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 58                	js     8013a5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801357:	ff 30                	pushl  (%eax)
  801359:	e8 a8 fb ff ff       	call   800f06 <dev_lookup>
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 37                	js     80139c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801368:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80136c:	74 32                	je     8013a0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80136e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801371:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801378:	00 00 00 
	stat->st_isdir = 0;
  80137b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801382:	00 00 00 
	stat->st_dev = dev;
  801385:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	53                   	push   %ebx
  80138f:	ff 75 f0             	pushl  -0x10(%ebp)
  801392:	ff 50 14             	call   *0x14(%eax)
  801395:	89 c2                	mov    %eax,%edx
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	eb 09                	jmp    8013a5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139c:	89 c2                	mov    %eax,%edx
  80139e:	eb 05                	jmp    8013a5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013a5:	89 d0                	mov    %edx,%eax
  8013a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	6a 00                	push   $0x0
  8013b6:	ff 75 08             	pushl  0x8(%ebp)
  8013b9:	e8 dc 01 00 00       	call   80159a <open>
  8013be:	89 c3                	mov    %eax,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 1b                	js     8013e2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	ff 75 0c             	pushl  0xc(%ebp)
  8013cd:	50                   	push   %eax
  8013ce:	e8 5b ff ff ff       	call   80132e <fstat>
  8013d3:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d5:	89 1c 24             	mov    %ebx,(%esp)
  8013d8:	e8 fd fb ff ff       	call   800fda <close>
	return r;
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	89 f0                	mov    %esi,%eax
}
  8013e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5e                   	pop    %esi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	56                   	push   %esi
  8013ed:	53                   	push   %ebx
  8013ee:	89 c6                	mov    %eax,%esi
  8013f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013f9:	75 12                	jne    80140d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	6a 01                	push   $0x1
  801400:	e8 b8 07 00 00       	call   801bbd <ipc_find_env>
  801405:	a3 00 40 80 00       	mov    %eax,0x804000
  80140a:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80140d:	6a 07                	push   $0x7
  80140f:	68 00 50 80 00       	push   $0x805000
  801414:	56                   	push   %esi
  801415:	ff 35 00 40 80 00    	pushl  0x804000
  80141b:	e8 5a 07 00 00       	call   801b7a <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801420:	83 c4 0c             	add    $0xc,%esp
  801423:	6a 00                	push   $0x0
  801425:	53                   	push   %ebx
  801426:	6a 00                	push   $0x0
  801428:	e8 f0 06 00 00       	call   801b1d <ipc_recv>
}
  80142d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801430:	5b                   	pop    %ebx
  801431:	5e                   	pop    %esi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80143a:	8b 45 08             	mov    0x8(%ebp),%eax
  80143d:	8b 40 0c             	mov    0xc(%eax),%eax
  801440:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801445:	8b 45 0c             	mov    0xc(%ebp),%eax
  801448:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80144d:	ba 00 00 00 00       	mov    $0x0,%edx
  801452:	b8 02 00 00 00       	mov    $0x2,%eax
  801457:	e8 8d ff ff ff       	call   8013e9 <fsipc>
}
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801464:	8b 45 08             	mov    0x8(%ebp),%eax
  801467:	8b 40 0c             	mov    0xc(%eax),%eax
  80146a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80146f:	ba 00 00 00 00       	mov    $0x0,%edx
  801474:	b8 06 00 00 00       	mov    $0x6,%eax
  801479:	e8 6b ff ff ff       	call   8013e9 <fsipc>
}
  80147e:	c9                   	leave  
  80147f:	c3                   	ret    

00801480 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	53                   	push   %ebx
  801484:	83 ec 04             	sub    $0x4,%esp
  801487:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	8b 40 0c             	mov    0xc(%eax),%eax
  801490:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	b8 05 00 00 00       	mov    $0x5,%eax
  80149f:	e8 45 ff ff ff       	call   8013e9 <fsipc>
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 2c                	js     8014d4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	68 00 50 80 00       	push   $0x805000
  8014b0:	53                   	push   %ebx
  8014b1:	e8 07 f3 ff ff       	call   8007bd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8014bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8014c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d7:	c9                   	leave  
  8014d8:	c3                   	ret    

008014d9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	83 ec 0c             	sub    $0xc,%esp
  8014df:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014ee:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014f3:	50                   	push   %eax
  8014f4:	ff 75 0c             	pushl  0xc(%ebp)
  8014f7:	68 08 50 80 00       	push   $0x805008
  8014fc:	e8 4e f4 ff ff       	call   80094f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801501:	ba 00 00 00 00       	mov    $0x0,%edx
  801506:	b8 04 00 00 00       	mov    $0x4,%eax
  80150b:	e8 d9 fe ff ff       	call   8013e9 <fsipc>
	//panic("devfile_write not implemented");
}
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
  80151d:	8b 40 0c             	mov    0xc(%eax),%eax
  801520:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801525:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152b:	ba 00 00 00 00       	mov    $0x0,%edx
  801530:	b8 03 00 00 00       	mov    $0x3,%eax
  801535:	e8 af fe ff ff       	call   8013e9 <fsipc>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 51                	js     801591 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801540:	39 c6                	cmp    %eax,%esi
  801542:	73 19                	jae    80155d <devfile_read+0x4b>
  801544:	68 78 23 80 00       	push   $0x802378
  801549:	68 7f 23 80 00       	push   $0x80237f
  80154e:	68 80 00 00 00       	push   $0x80
  801553:	68 94 23 80 00       	push   $0x802394
  801558:	e8 b8 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  80155d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801562:	7e 19                	jle    80157d <devfile_read+0x6b>
  801564:	68 9f 23 80 00       	push   $0x80239f
  801569:	68 7f 23 80 00       	push   $0x80237f
  80156e:	68 81 00 00 00       	push   $0x81
  801573:	68 94 23 80 00       	push   $0x802394
  801578:	e8 98 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	50                   	push   %eax
  801581:	68 00 50 80 00       	push   $0x805000
  801586:	ff 75 0c             	pushl  0xc(%ebp)
  801589:	e8 c1 f3 ff ff       	call   80094f <memmove>
	return r;
  80158e:	83 c4 10             	add    $0x10,%esp
}
  801591:	89 d8                	mov    %ebx,%eax
  801593:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 20             	sub    $0x20,%esp
  8015a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a4:	53                   	push   %ebx
  8015a5:	e8 da f1 ff ff       	call   800784 <strlen>
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b2:	7f 67                	jg     80161b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	e8 a1 f8 ff ff       	call   800e61 <fd_alloc>
  8015c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 57                	js     801620 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	53                   	push   %ebx
  8015cd:	68 00 50 80 00       	push   $0x805000
  8015d2:	e8 e6 f1 ff ff       	call   8007bd <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015da:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e7:	e8 fd fd ff ff       	call   8013e9 <fsipc>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	79 14                	jns    801609 <open+0x6f>
		
		fd_close(fd, 0);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	6a 00                	push   $0x0
  8015fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fd:	e8 57 f9 ff ff       	call   800f59 <fd_close>
		return r;
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	89 da                	mov    %ebx,%edx
  801607:	eb 17                	jmp    801620 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801609:	83 ec 0c             	sub    $0xc,%esp
  80160c:	ff 75 f4             	pushl  -0xc(%ebp)
  80160f:	e8 26 f8 ff ff       	call   800e3a <fd2num>
  801614:	89 c2                	mov    %eax,%edx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	eb 05                	jmp    801620 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80161b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801620:	89 d0                	mov    %edx,%eax
  801622:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	b8 08 00 00 00       	mov    $0x8,%eax
  801637:	e8 ad fd ff ff       	call   8013e9 <fsipc>
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801646:	83 ec 0c             	sub    $0xc,%esp
  801649:	ff 75 08             	pushl  0x8(%ebp)
  80164c:	e8 f9 f7 ff ff       	call   800e4a <fd2data>
  801651:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	68 ab 23 80 00       	push   $0x8023ab
  80165b:	53                   	push   %ebx
  80165c:	e8 5c f1 ff ff       	call   8007bd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801661:	8b 46 04             	mov    0x4(%esi),%eax
  801664:	2b 06                	sub    (%esi),%eax
  801666:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80166c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801673:	00 00 00 
	stat->st_dev = &devpipe;
  801676:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80167d:	30 80 00 
	return 0;
}
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
  801685:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801688:	5b                   	pop    %ebx
  801689:	5e                   	pop    %esi
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	53                   	push   %ebx
  801690:	83 ec 0c             	sub    $0xc,%esp
  801693:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801696:	53                   	push   %ebx
  801697:	6a 00                	push   $0x0
  801699:	e8 a7 f5 ff ff       	call   800c45 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80169e:	89 1c 24             	mov    %ebx,(%esp)
  8016a1:	e8 a4 f7 ff ff       	call   800e4a <fd2data>
  8016a6:	83 c4 08             	add    $0x8,%esp
  8016a9:	50                   	push   %eax
  8016aa:	6a 00                	push   $0x0
  8016ac:	e8 94 f5 ff ff       	call   800c45 <sys_page_unmap>
}
  8016b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	57                   	push   %edi
  8016ba:	56                   	push   %esi
  8016bb:	53                   	push   %ebx
  8016bc:	83 ec 1c             	sub    $0x1c,%esp
  8016bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016c2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016cc:	83 ec 0c             	sub    $0xc,%esp
  8016cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8016d2:	e8 1f 05 00 00       	call   801bf6 <pageref>
  8016d7:	89 c3                	mov    %eax,%ebx
  8016d9:	89 3c 24             	mov    %edi,(%esp)
  8016dc:	e8 15 05 00 00       	call   801bf6 <pageref>
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	39 c3                	cmp    %eax,%ebx
  8016e6:	0f 94 c1             	sete   %cl
  8016e9:	0f b6 c9             	movzbl %cl,%ecx
  8016ec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016ef:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016f5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016f8:	39 ce                	cmp    %ecx,%esi
  8016fa:	74 1b                	je     801717 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016fc:	39 c3                	cmp    %eax,%ebx
  8016fe:	75 c4                	jne    8016c4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801700:	8b 42 58             	mov    0x58(%edx),%eax
  801703:	ff 75 e4             	pushl  -0x1c(%ebp)
  801706:	50                   	push   %eax
  801707:	56                   	push   %esi
  801708:	68 b2 23 80 00       	push   $0x8023b2
  80170d:	e8 dc ea ff ff       	call   8001ee <cprintf>
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	eb ad                	jmp    8016c4 <_pipeisclosed+0xe>
	}
}
  801717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5e                   	pop    %esi
  80171f:	5f                   	pop    %edi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	57                   	push   %edi
  801726:	56                   	push   %esi
  801727:	53                   	push   %ebx
  801728:	83 ec 28             	sub    $0x28,%esp
  80172b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80172e:	56                   	push   %esi
  80172f:	e8 16 f7 ff ff       	call   800e4a <fd2data>
  801734:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	bf 00 00 00 00       	mov    $0x0,%edi
  80173e:	eb 4b                	jmp    80178b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801740:	89 da                	mov    %ebx,%edx
  801742:	89 f0                	mov    %esi,%eax
  801744:	e8 6d ff ff ff       	call   8016b6 <_pipeisclosed>
  801749:	85 c0                	test   %eax,%eax
  80174b:	75 48                	jne    801795 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80174d:	e8 4f f4 ff ff       	call   800ba1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801752:	8b 43 04             	mov    0x4(%ebx),%eax
  801755:	8b 0b                	mov    (%ebx),%ecx
  801757:	8d 51 20             	lea    0x20(%ecx),%edx
  80175a:	39 d0                	cmp    %edx,%eax
  80175c:	73 e2                	jae    801740 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80175e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801761:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801765:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801768:	89 c2                	mov    %eax,%edx
  80176a:	c1 fa 1f             	sar    $0x1f,%edx
  80176d:	89 d1                	mov    %edx,%ecx
  80176f:	c1 e9 1b             	shr    $0x1b,%ecx
  801772:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801775:	83 e2 1f             	and    $0x1f,%edx
  801778:	29 ca                	sub    %ecx,%edx
  80177a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80177e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801782:	83 c0 01             	add    $0x1,%eax
  801785:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801788:	83 c7 01             	add    $0x1,%edi
  80178b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80178e:	75 c2                	jne    801752 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801790:	8b 45 10             	mov    0x10(%ebp),%eax
  801793:	eb 05                	jmp    80179a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801795:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80179a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5f                   	pop    %edi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	57                   	push   %edi
  8017a6:	56                   	push   %esi
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 18             	sub    $0x18,%esp
  8017ab:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017ae:	57                   	push   %edi
  8017af:	e8 96 f6 ff ff       	call   800e4a <fd2data>
  8017b4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017be:	eb 3d                	jmp    8017fd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017c0:	85 db                	test   %ebx,%ebx
  8017c2:	74 04                	je     8017c8 <devpipe_read+0x26>
				return i;
  8017c4:	89 d8                	mov    %ebx,%eax
  8017c6:	eb 44                	jmp    80180c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017c8:	89 f2                	mov    %esi,%edx
  8017ca:	89 f8                	mov    %edi,%eax
  8017cc:	e8 e5 fe ff ff       	call   8016b6 <_pipeisclosed>
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	75 32                	jne    801807 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017d5:	e8 c7 f3 ff ff       	call   800ba1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017da:	8b 06                	mov    (%esi),%eax
  8017dc:	3b 46 04             	cmp    0x4(%esi),%eax
  8017df:	74 df                	je     8017c0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017e1:	99                   	cltd   
  8017e2:	c1 ea 1b             	shr    $0x1b,%edx
  8017e5:	01 d0                	add    %edx,%eax
  8017e7:	83 e0 1f             	and    $0x1f,%eax
  8017ea:	29 d0                	sub    %edx,%eax
  8017ec:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017f7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017fa:	83 c3 01             	add    $0x1,%ebx
  8017fd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801800:	75 d8                	jne    8017da <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801802:	8b 45 10             	mov    0x10(%ebp),%eax
  801805:	eb 05                	jmp    80180c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801807:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80180c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5f                   	pop    %edi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80181c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	e8 3c f6 ff ff       	call   800e61 <fd_alloc>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	89 c2                	mov    %eax,%edx
  80182a:	85 c0                	test   %eax,%eax
  80182c:	0f 88 2c 01 00 00    	js     80195e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801832:	83 ec 04             	sub    $0x4,%esp
  801835:	68 07 04 00 00       	push   $0x407
  80183a:	ff 75 f4             	pushl  -0xc(%ebp)
  80183d:	6a 00                	push   $0x0
  80183f:	e8 7c f3 ff ff       	call   800bc0 <sys_page_alloc>
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	89 c2                	mov    %eax,%edx
  801849:	85 c0                	test   %eax,%eax
  80184b:	0f 88 0d 01 00 00    	js     80195e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801857:	50                   	push   %eax
  801858:	e8 04 f6 ff ff       	call   800e61 <fd_alloc>
  80185d:	89 c3                	mov    %eax,%ebx
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	0f 88 e2 00 00 00    	js     80194c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186a:	83 ec 04             	sub    $0x4,%esp
  80186d:	68 07 04 00 00       	push   $0x407
  801872:	ff 75 f0             	pushl  -0x10(%ebp)
  801875:	6a 00                	push   $0x0
  801877:	e8 44 f3 ff ff       	call   800bc0 <sys_page_alloc>
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	0f 88 c3 00 00 00    	js     80194c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	ff 75 f4             	pushl  -0xc(%ebp)
  80188f:	e8 b6 f5 ff ff       	call   800e4a <fd2data>
  801894:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801896:	83 c4 0c             	add    $0xc,%esp
  801899:	68 07 04 00 00       	push   $0x407
  80189e:	50                   	push   %eax
  80189f:	6a 00                	push   $0x0
  8018a1:	e8 1a f3 ff ff       	call   800bc0 <sys_page_alloc>
  8018a6:	89 c3                	mov    %eax,%ebx
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	0f 88 89 00 00 00    	js     80193c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b9:	e8 8c f5 ff ff       	call   800e4a <fd2data>
  8018be:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018c5:	50                   	push   %eax
  8018c6:	6a 00                	push   $0x0
  8018c8:	56                   	push   %esi
  8018c9:	6a 00                	push   $0x0
  8018cb:	e8 33 f3 ff ff       	call   800c03 <sys_page_map>
  8018d0:	89 c3                	mov    %eax,%ebx
  8018d2:	83 c4 20             	add    $0x20,%esp
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 55                	js     80192e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018d9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	ff 75 f4             	pushl  -0xc(%ebp)
  801909:	e8 2c f5 ff ff       	call   800e3a <fd2num>
  80190e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801911:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801913:	83 c4 04             	add    $0x4,%esp
  801916:	ff 75 f0             	pushl  -0x10(%ebp)
  801919:	e8 1c f5 ff ff       	call   800e3a <fd2num>
  80191e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801921:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	ba 00 00 00 00       	mov    $0x0,%edx
  80192c:	eb 30                	jmp    80195e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	56                   	push   %esi
  801932:	6a 00                	push   $0x0
  801934:	e8 0c f3 ff ff       	call   800c45 <sys_page_unmap>
  801939:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	ff 75 f0             	pushl  -0x10(%ebp)
  801942:	6a 00                	push   $0x0
  801944:	e8 fc f2 ff ff       	call   800c45 <sys_page_unmap>
  801949:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	ff 75 f4             	pushl  -0xc(%ebp)
  801952:	6a 00                	push   $0x0
  801954:	e8 ec f2 ff ff       	call   800c45 <sys_page_unmap>
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80195e:	89 d0                	mov    %edx,%eax
  801960:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    

00801967 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80196d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801970:	50                   	push   %eax
  801971:	ff 75 08             	pushl  0x8(%ebp)
  801974:	e8 37 f5 ff ff       	call   800eb0 <fd_lookup>
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 18                	js     801998 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801980:	83 ec 0c             	sub    $0xc,%esp
  801983:	ff 75 f4             	pushl  -0xc(%ebp)
  801986:	e8 bf f4 ff ff       	call   800e4a <fd2data>
	return _pipeisclosed(fd, p);
  80198b:	89 c2                	mov    %eax,%edx
  80198d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801990:	e8 21 fd ff ff       	call   8016b6 <_pipeisclosed>
  801995:	83 c4 10             	add    $0x10,%esp
}
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80199d:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019aa:	68 ca 23 80 00       	push   $0x8023ca
  8019af:	ff 75 0c             	pushl  0xc(%ebp)
  8019b2:	e8 06 ee ff ff       	call   8007bd <strcpy>
	return 0;
}
  8019b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	57                   	push   %edi
  8019c2:	56                   	push   %esi
  8019c3:	53                   	push   %ebx
  8019c4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ca:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d5:	eb 2d                	jmp    801a04 <devcons_write+0x46>
		m = n - tot;
  8019d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019da:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019dc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019df:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019e4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019e7:	83 ec 04             	sub    $0x4,%esp
  8019ea:	53                   	push   %ebx
  8019eb:	03 45 0c             	add    0xc(%ebp),%eax
  8019ee:	50                   	push   %eax
  8019ef:	57                   	push   %edi
  8019f0:	e8 5a ef ff ff       	call   80094f <memmove>
		sys_cputs(buf, m);
  8019f5:	83 c4 08             	add    $0x8,%esp
  8019f8:	53                   	push   %ebx
  8019f9:	57                   	push   %edi
  8019fa:	e8 05 f1 ff ff       	call   800b04 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ff:	01 de                	add    %ebx,%esi
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	89 f0                	mov    %esi,%eax
  801a06:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a09:	72 cc                	jb     8019d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 08             	sub    $0x8,%esp
  801a19:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a22:	74 2a                	je     801a4e <devcons_read+0x3b>
  801a24:	eb 05                	jmp    801a2b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a26:	e8 76 f1 ff ff       	call   800ba1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a2b:	e8 f2 f0 ff ff       	call   800b22 <sys_cgetc>
  801a30:	85 c0                	test   %eax,%eax
  801a32:	74 f2                	je     801a26 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 16                	js     801a4e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a38:	83 f8 04             	cmp    $0x4,%eax
  801a3b:	74 0c                	je     801a49 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a40:	88 02                	mov    %al,(%edx)
	return 1;
  801a42:	b8 01 00 00 00       	mov    $0x1,%eax
  801a47:	eb 05                	jmp    801a4e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a49:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a5c:	6a 01                	push   $0x1
  801a5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a61:	50                   	push   %eax
  801a62:	e8 9d f0 ff ff       	call   800b04 <sys_cputs>
}
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <getchar>:

int
getchar(void)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a72:	6a 01                	push   $0x1
  801a74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a77:	50                   	push   %eax
  801a78:	6a 00                	push   $0x0
  801a7a:	e8 97 f6 ff ff       	call   801116 <read>
	if (r < 0)
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 0f                	js     801a95 <getchar+0x29>
		return r;
	if (r < 1)
  801a86:	85 c0                	test   %eax,%eax
  801a88:	7e 06                	jle    801a90 <getchar+0x24>
		return -E_EOF;
	return c;
  801a8a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a8e:	eb 05                	jmp    801a95 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a90:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa0:	50                   	push   %eax
  801aa1:	ff 75 08             	pushl  0x8(%ebp)
  801aa4:	e8 07 f4 ff ff       	call   800eb0 <fd_lookup>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 11                	js     801ac1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab9:	39 10                	cmp    %edx,(%eax)
  801abb:	0f 94 c0             	sete   %al
  801abe:	0f b6 c0             	movzbl %al,%eax
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <opencons>:

int
opencons(void)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acc:	50                   	push   %eax
  801acd:	e8 8f f3 ff ff       	call   800e61 <fd_alloc>
  801ad2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	78 3e                	js     801b19 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	68 07 04 00 00       	push   $0x407
  801ae3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 d3 f0 ff ff       	call   800bc0 <sys_page_alloc>
  801aed:	83 c4 10             	add    $0x10,%esp
		return r;
  801af0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 23                	js     801b19 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801af6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b04:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	50                   	push   %eax
  801b0f:	e8 26 f3 ff ff       	call   800e3a <fd2num>
  801b14:	89 c2                	mov    %eax,%edx
  801b16:	83 c4 10             	add    $0x10,%esp
}
  801b19:	89 d0                	mov    %edx,%eax
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b25:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	ff 75 0c             	pushl  0xc(%ebp)
  801b2e:	e8 3d f2 ff ff       	call   800d70 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	85 f6                	test   %esi,%esi
  801b38:	74 1c                	je     801b56 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801b3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3f:	8b 40 78             	mov    0x78(%eax),%eax
  801b42:	89 06                	mov    %eax,(%esi)
  801b44:	eb 10                	jmp    801b56 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	68 d6 23 80 00       	push   $0x8023d6
  801b4e:	e8 9b e6 ff ff       	call   8001ee <cprintf>
  801b53:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801b56:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5b:	8b 50 74             	mov    0x74(%eax),%edx
  801b5e:	85 d2                	test   %edx,%edx
  801b60:	74 e4                	je     801b46 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801b62:	85 db                	test   %ebx,%ebx
  801b64:	74 05                	je     801b6b <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801b66:	8b 40 74             	mov    0x74(%eax),%eax
  801b69:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b70:	8b 40 70             	mov    0x70(%eax),%eax

}
  801b73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	57                   	push   %edi
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b86:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801b8c:	85 db                	test   %ebx,%ebx
  801b8e:	75 13                	jne    801ba3 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801b90:	6a 00                	push   $0x0
  801b92:	68 00 00 c0 ee       	push   $0xeec00000
  801b97:	56                   	push   %esi
  801b98:	57                   	push   %edi
  801b99:	e8 af f1 ff ff       	call   800d4d <sys_ipc_try_send>
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	eb 0e                	jmp    801bb1 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801ba3:	ff 75 14             	pushl  0x14(%ebp)
  801ba6:	53                   	push   %ebx
  801ba7:	56                   	push   %esi
  801ba8:	57                   	push   %edi
  801ba9:	e8 9f f1 ff ff       	call   800d4d <sys_ipc_try_send>
  801bae:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	75 d7                	jne    801b8c <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb8:	5b                   	pop    %ebx
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bc8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bcb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bd1:	8b 52 50             	mov    0x50(%edx),%edx
  801bd4:	39 ca                	cmp    %ecx,%edx
  801bd6:	75 0d                	jne    801be5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bd8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bdb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801be0:	8b 40 48             	mov    0x48(%eax),%eax
  801be3:	eb 0f                	jmp    801bf4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801be5:	83 c0 01             	add    $0x1,%eax
  801be8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bed:	75 d9                	jne    801bc8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bfc:	89 d0                	mov    %edx,%eax
  801bfe:	c1 e8 16             	shr    $0x16,%eax
  801c01:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0d:	f6 c1 01             	test   $0x1,%cl
  801c10:	74 1d                	je     801c2f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c12:	c1 ea 0c             	shr    $0xc,%edx
  801c15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c1c:	f6 c2 01             	test   $0x1,%dl
  801c1f:	74 0e                	je     801c2f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c21:	c1 ea 0c             	shr    $0xc,%edx
  801c24:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c2b:	ef 
  801c2c:	0f b7 c0             	movzwl %ax,%eax
}
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    
  801c31:	66 90                	xchg   %ax,%ax
  801c33:	66 90                	xchg   %ax,%ax
  801c35:	66 90                	xchg   %ax,%ax
  801c37:	66 90                	xchg   %ax,%ax
  801c39:	66 90                	xchg   %ax,%ax
  801c3b:	66 90                	xchg   %ax,%ax
  801c3d:	66 90                	xchg   %ax,%ax
  801c3f:	90                   	nop

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 f6                	test   %esi,%esi
  801c59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c5d:	89 ca                	mov    %ecx,%edx
  801c5f:	89 f8                	mov    %edi,%eax
  801c61:	75 3d                	jne    801ca0 <__udivdi3+0x60>
  801c63:	39 cf                	cmp    %ecx,%edi
  801c65:	0f 87 c5 00 00 00    	ja     801d30 <__udivdi3+0xf0>
  801c6b:	85 ff                	test   %edi,%edi
  801c6d:	89 fd                	mov    %edi,%ebp
  801c6f:	75 0b                	jne    801c7c <__udivdi3+0x3c>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	31 d2                	xor    %edx,%edx
  801c78:	f7 f7                	div    %edi
  801c7a:	89 c5                	mov    %eax,%ebp
  801c7c:	89 c8                	mov    %ecx,%eax
  801c7e:	31 d2                	xor    %edx,%edx
  801c80:	f7 f5                	div    %ebp
  801c82:	89 c1                	mov    %eax,%ecx
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	89 cf                	mov    %ecx,%edi
  801c88:	f7 f5                	div    %ebp
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	39 ce                	cmp    %ecx,%esi
  801ca2:	77 74                	ja     801d18 <__udivdi3+0xd8>
  801ca4:	0f bd fe             	bsr    %esi,%edi
  801ca7:	83 f7 1f             	xor    $0x1f,%edi
  801caa:	0f 84 98 00 00 00    	je     801d48 <__udivdi3+0x108>
  801cb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	89 c5                	mov    %eax,%ebp
  801cb9:	29 fb                	sub    %edi,%ebx
  801cbb:	d3 e6                	shl    %cl,%esi
  801cbd:	89 d9                	mov    %ebx,%ecx
  801cbf:	d3 ed                	shr    %cl,%ebp
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 e0                	shl    %cl,%eax
  801cc5:	09 ee                	or     %ebp,%esi
  801cc7:	89 d9                	mov    %ebx,%ecx
  801cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ccd:	89 d5                	mov    %edx,%ebp
  801ccf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cd3:	d3 ed                	shr    %cl,%ebp
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	d3 e2                	shl    %cl,%edx
  801cd9:	89 d9                	mov    %ebx,%ecx
  801cdb:	d3 e8                	shr    %cl,%eax
  801cdd:	09 c2                	or     %eax,%edx
  801cdf:	89 d0                	mov    %edx,%eax
  801ce1:	89 ea                	mov    %ebp,%edx
  801ce3:	f7 f6                	div    %esi
  801ce5:	89 d5                	mov    %edx,%ebp
  801ce7:	89 c3                	mov    %eax,%ebx
  801ce9:	f7 64 24 0c          	mull   0xc(%esp)
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	72 10                	jb     801d01 <__udivdi3+0xc1>
  801cf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e6                	shl    %cl,%esi
  801cf9:	39 c6                	cmp    %eax,%esi
  801cfb:	73 07                	jae    801d04 <__udivdi3+0xc4>
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	75 03                	jne    801d04 <__udivdi3+0xc4>
  801d01:	83 eb 01             	sub    $0x1,%ebx
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 d8                	mov    %ebx,%eax
  801d08:	89 fa                	mov    %edi,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	31 ff                	xor    %edi,%edi
  801d1a:	31 db                	xor    %ebx,%ebx
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	89 fa                	mov    %edi,%edx
  801d20:	83 c4 1c             	add    $0x1c,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
  801d28:	90                   	nop
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	f7 f7                	div    %edi
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 fa                	mov    %edi,%edx
  801d3c:	83 c4 1c             	add    $0x1c,%esp
  801d3f:	5b                   	pop    %ebx
  801d40:	5e                   	pop    %esi
  801d41:	5f                   	pop    %edi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    
  801d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d48:	39 ce                	cmp    %ecx,%esi
  801d4a:	72 0c                	jb     801d58 <__udivdi3+0x118>
  801d4c:	31 db                	xor    %ebx,%ebx
  801d4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d52:	0f 87 34 ff ff ff    	ja     801c8c <__udivdi3+0x4c>
  801d58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d5d:	e9 2a ff ff ff       	jmp    801c8c <__udivdi3+0x4c>
  801d62:	66 90                	xchg   %ax,%ax
  801d64:	66 90                	xchg   %ax,%ax
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 1c             	sub    $0x1c,%esp
  801d77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d87:	85 d2                	test   %edx,%edx
  801d89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d91:	89 f3                	mov    %esi,%ebx
  801d93:	89 3c 24             	mov    %edi,(%esp)
  801d96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9a:	75 1c                	jne    801db8 <__umoddi3+0x48>
  801d9c:	39 f7                	cmp    %esi,%edi
  801d9e:	76 50                	jbe    801df0 <__umoddi3+0x80>
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	f7 f7                	div    %edi
  801da6:	89 d0                	mov    %edx,%eax
  801da8:	31 d2                	xor    %edx,%edx
  801daa:	83 c4 1c             	add    $0x1c,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    
  801db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db8:	39 f2                	cmp    %esi,%edx
  801dba:	89 d0                	mov    %edx,%eax
  801dbc:	77 52                	ja     801e10 <__umoddi3+0xa0>
  801dbe:	0f bd ea             	bsr    %edx,%ebp
  801dc1:	83 f5 1f             	xor    $0x1f,%ebp
  801dc4:	75 5a                	jne    801e20 <__umoddi3+0xb0>
  801dc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dca:	0f 82 e0 00 00 00    	jb     801eb0 <__umoddi3+0x140>
  801dd0:	39 0c 24             	cmp    %ecx,(%esp)
  801dd3:	0f 86 d7 00 00 00    	jbe    801eb0 <__umoddi3+0x140>
  801dd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ddd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801de1:	83 c4 1c             	add    $0x1c,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	85 ff                	test   %edi,%edi
  801df2:	89 fd                	mov    %edi,%ebp
  801df4:	75 0b                	jne    801e01 <__umoddi3+0x91>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f7                	div    %edi
  801dff:	89 c5                	mov    %eax,%ebp
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f5                	div    %ebp
  801e07:	89 c8                	mov    %ecx,%eax
  801e09:	f7 f5                	div    %ebp
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	eb 99                	jmp    801da8 <__umoddi3+0x38>
  801e0f:	90                   	nop
  801e10:	89 c8                	mov    %ecx,%eax
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	83 c4 1c             	add    $0x1c,%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5f                   	pop    %edi
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    
  801e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e20:	8b 34 24             	mov    (%esp),%esi
  801e23:	bf 20 00 00 00       	mov    $0x20,%edi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	29 ef                	sub    %ebp,%edi
  801e2c:	d3 e0                	shl    %cl,%eax
  801e2e:	89 f9                	mov    %edi,%ecx
  801e30:	89 f2                	mov    %esi,%edx
  801e32:	d3 ea                	shr    %cl,%edx
  801e34:	89 e9                	mov    %ebp,%ecx
  801e36:	09 c2                	or     %eax,%edx
  801e38:	89 d8                	mov    %ebx,%eax
  801e3a:	89 14 24             	mov    %edx,(%esp)
  801e3d:	89 f2                	mov    %esi,%edx
  801e3f:	d3 e2                	shl    %cl,%edx
  801e41:	89 f9                	mov    %edi,%ecx
  801e43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	89 c6                	mov    %eax,%esi
  801e51:	d3 e3                	shl    %cl,%ebx
  801e53:	89 f9                	mov    %edi,%ecx
  801e55:	89 d0                	mov    %edx,%eax
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	09 d8                	or     %ebx,%eax
  801e5d:	89 d3                	mov    %edx,%ebx
  801e5f:	89 f2                	mov    %esi,%edx
  801e61:	f7 34 24             	divl   (%esp)
  801e64:	89 d6                	mov    %edx,%esi
  801e66:	d3 e3                	shl    %cl,%ebx
  801e68:	f7 64 24 04          	mull   0x4(%esp)
  801e6c:	39 d6                	cmp    %edx,%esi
  801e6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e72:	89 d1                	mov    %edx,%ecx
  801e74:	89 c3                	mov    %eax,%ebx
  801e76:	72 08                	jb     801e80 <__umoddi3+0x110>
  801e78:	75 11                	jne    801e8b <__umoddi3+0x11b>
  801e7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e7e:	73 0b                	jae    801e8b <__umoddi3+0x11b>
  801e80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e84:	1b 14 24             	sbb    (%esp),%edx
  801e87:	89 d1                	mov    %edx,%ecx
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e8f:	29 da                	sub    %ebx,%edx
  801e91:	19 ce                	sbb    %ecx,%esi
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	d3 e0                	shl    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	d3 ea                	shr    %cl,%edx
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	d3 ee                	shr    %cl,%esi
  801ea1:	09 d0                	or     %edx,%eax
  801ea3:	89 f2                	mov    %esi,%edx
  801ea5:	83 c4 1c             	add    $0x1c,%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	29 f9                	sub    %edi,%ecx
  801eb2:	19 d6                	sbb    %edx,%esi
  801eb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ebc:	e9 18 ff ff ff       	jmp    801dd9 <__umoddi3+0x69>
