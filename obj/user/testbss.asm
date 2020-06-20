
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 60 1e 80 00       	push   $0x801e60
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 db 1e 80 00       	push   $0x801edb
  80005b:	6a 11                	push   $0x11
  80005d:	68 f8 1e 80 00       	push   $0x801ef8
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 80 1e 80 00       	push   $0x801e80
  80009b:	6a 16                	push   $0x16
  80009d:	68 f8 1e 80 00       	push   $0x801ef8
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 a8 1e 80 00       	push   $0x801ea8
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 07 1f 80 00       	push   $0x801f07
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 f8 1e 80 00       	push   $0x801ef8
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e7:	e8 bd 0a 00 00       	call   800ba9 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 76 0e 00 00       	call   800fa3 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 31 0a 00 00       	call   800b68 <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 5a 0a 00 00       	call   800ba9 <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 28 1f 80 00       	push   $0x801f28
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 f6 1e 80 00 	movl   $0x801ef6,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 79 09 00 00       	call   800b2b <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 54 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 1e 09 00 00       	call   800b2b <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 53 19 00 00       	call   801bd0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 40 1a 00 00       	call   801d00 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 4b 1f 80 00 	movsbl 0x801f4b(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 05 00 00 00       	call   80034c <vprintfmt>
	va_end(ap);
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	eb 12                	jmp    800372 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 84 d3 03 00 00    	je     80073b <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	53                   	push   %ebx
  80036c:	50                   	push   %eax
  80036d:	ff d6                	call   *%esi
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	83 c7 01             	add    $0x1,%edi
  800375:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e2                	jne    800360 <vprintfmt+0x14>
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800389:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 07                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8d 47 01             	lea    0x1(%edi),%eax
  8003a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	0f b6 c8             	movzbl %al,%ecx
  8003b1:	83 e8 23             	sub    $0x23,%eax
  8003b4:	3c 55                	cmp    $0x55,%al
  8003b6:	0f 87 64 03 00 00    	ja     800720 <vprintfmt+0x3d4>
  8003bc:	0f b6 c0             	movzbl %al,%eax
  8003bf:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cd:	eb d6                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e7:	83 fa 09             	cmp    $0x9,%edx
  8003ea:	77 39                	ja     800425 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ef:	eb e9                	jmp    8003da <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 27                	jmp    80042b <vprintfmt+0xdf>
  800404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	0f 49 c8             	cmovns %eax,%ecx
  800411:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	eb 8c                	jmp    8003a5 <vprintfmt+0x59>
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800423:	eb 80                	jmp    8003a5 <vprintfmt+0x59>
  800425:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800428:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80042b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042f:	0f 89 70 ff ff ff    	jns    8003a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800435:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800442:	e9 5e ff ff ff       	jmp    8003a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044d:	e9 53 ff ff ff       	jmp    8003a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	53                   	push   %ebx
  80045f:	ff 30                	pushl  (%eax)
  800461:	ff d6                	call   *%esi
			break;
  800463:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800469:	e9 04 ff ff ff       	jmp    800372 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	99                   	cltd   
  80047a:	31 d0                	xor    %edx,%eax
  80047c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	83 f8 0f             	cmp    $0xf,%eax
  800481:	7f 0b                	jg     80048e <vprintfmt+0x142>
  800483:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	75 18                	jne    8004a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048e:	50                   	push   %eax
  80048f:	68 63 1f 80 00       	push   $0x801f63
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 94 fe ff ff       	call   80032f <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a1:	e9 cc fe ff ff       	jmp    800372 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a6:	52                   	push   %edx
  8004a7:	68 15 23 80 00       	push   $0x802315
  8004ac:	53                   	push   %ebx
  8004ad:	56                   	push   %esi
  8004ae:	e8 7c fe ff ff       	call   80032f <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b9:	e9 b4 fe ff ff       	jmp    800372 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	b8 5c 1f 80 00       	mov    $0x801f5c,%eax
  8004d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 8e 94 00 00 00    	jle    800571 <vprintfmt+0x225>
  8004dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e1:	0f 84 98 00 00 00    	je     80057f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 c8             	pushl  -0x38(%ebp)
  8004ed:	57                   	push   %edi
  8004ee:	e8 d0 02 00 00       	call   8007c3 <strnlen>
  8004f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1c0>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800525:	85 c9                	test   %ecx,%ecx
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 49 c1             	cmovns %ecx,%eax
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	89 cb                	mov    %ecx,%ebx
  80053c:	eb 4d                	jmp    80058b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800542:	74 1b                	je     80055f <vprintfmt+0x213>
  800544:	0f be c0             	movsbl %al,%eax
  800547:	83 e8 20             	sub    $0x20,%eax
  80054a:	83 f8 5e             	cmp    $0x5e,%eax
  80054d:	76 10                	jbe    80055f <vprintfmt+0x213>
					putch('?', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	6a 3f                	push   $0x3f
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 0d                	jmp    80056c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	52                   	push   %edx
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 eb 01             	sub    $0x1,%ebx
  80056f:	eb 1a                	jmp    80058b <vprintfmt+0x23f>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	eb 0c                	jmp    80058b <vprintfmt+0x23f>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	83 c7 01             	add    $0x1,%edi
  80058e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800592:	0f be d0             	movsbl %al,%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	74 23                	je     8005bc <vprintfmt+0x270>
  800599:	85 f6                	test   %esi,%esi
  80059b:	78 a1                	js     80053e <vprintfmt+0x1f2>
  80059d:	83 ee 01             	sub    $0x1,%esi
  8005a0:	79 9c                	jns    80053e <vprintfmt+0x1f2>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	eb 18                	jmp    8005c4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x278>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f e4                	jg     8005ac <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 a2 fd ff ff       	jmp    800372 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 fa 01             	cmp    $0x1,%edx
  8005d3:	7e 16                	jle    8005eb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 08             	lea    0x8(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 50 04             	mov    0x4(%eax),%edx
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e6:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005e9:	eb 32                	jmp    80061d <vprintfmt+0x2d1>
	else if (lflag)
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	74 18                	je     800607 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800605:	eb 16                	jmp    80061d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800615:	89 c1                	mov    %eax,%ecx
  800617:	c1 f9 1f             	sar    $0x1f,%ecx
  80061a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800620:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800632:	0f 89 b0 00 00 00    	jns    8006e8 <vprintfmt+0x39c>
				putch('-', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 2d                	push   $0x2d
  80063e:	ff d6                	call   *%esi
				num = -(long long) num;
  800640:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800643:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800646:	f7 d8                	neg    %eax
  800648:	83 d2 00             	adc    $0x0,%edx
  80064b:	f7 da                	neg    %edx
  80064d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800650:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800653:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 88 00 00 00       	jmp    8006e8 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 70 fc ff ff       	call   8002d8 <getuint>
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800673:	eb 73                	jmp    8006e8 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 5b fc ff ff       	call   8002d8 <getuint>
  80067d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800680:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	6a 58                	push   $0x58
  800689:	ff d6                	call   *%esi
			putch('X', putdat);
  80068b:	83 c4 08             	add    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 58                	push   $0x58
  800691:	ff d6                	call   *%esi
			putch('X', putdat);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 58                	push   $0x58
  800699:	ff d6                	call   *%esi
			goto number;
  80069b:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80069e:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006a3:	eb 43                	jmp    8006e8 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 30                	push   $0x30
  8006ab:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 78                	push   $0x78
  8006b3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 50 04             	lea    0x4(%eax),%edx
  8006bb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006be:	8b 00                	mov    (%eax),%eax
  8006c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d3:	eb 13                	jmp    8006e8 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d8:	e8 fb fb ff ff       	call   8002d8 <getuint>
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006ef:	52                   	push   %edx
  8006f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f3:	50                   	push   %eax
  8006f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8006f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8006fa:	89 da                	mov    %ebx,%edx
  8006fc:	89 f0                	mov    %esi,%eax
  8006fe:	e8 26 fb ff ff       	call   800229 <printnum>
			break;
  800703:	83 c4 20             	add    $0x20,%esp
  800706:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800709:	e9 64 fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	51                   	push   %ecx
  800713:	ff d6                	call   *%esi
			break;
  800715:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800718:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071b:	e9 52 fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	6a 25                	push   $0x25
  800726:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb 03                	jmp    800730 <vprintfmt+0x3e4>
  80072d:	83 ef 01             	sub    $0x1,%edi
  800730:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800734:	75 f7                	jne    80072d <vprintfmt+0x3e1>
  800736:	e9 37 fc ff ff       	jmp    800372 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80073b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073e:	5b                   	pop    %ebx
  80073f:	5e                   	pop    %esi
  800740:	5f                   	pop    %edi
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 18             	sub    $0x18,%esp
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800752:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800756:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800759:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800760:	85 c0                	test   %eax,%eax
  800762:	74 26                	je     80078a <vsnprintf+0x47>
  800764:	85 d2                	test   %edx,%edx
  800766:	7e 22                	jle    80078a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800768:	ff 75 14             	pushl  0x14(%ebp)
  80076b:	ff 75 10             	pushl  0x10(%ebp)
  80076e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800771:	50                   	push   %eax
  800772:	68 12 03 80 00       	push   $0x800312
  800777:	e8 d0 fb ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	eb 05                	jmp    80078f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079a:	50                   	push   %eax
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	ff 75 0c             	pushl  0xc(%ebp)
  8007a1:	ff 75 08             	pushl  0x8(%ebp)
  8007a4:	e8 9a ff ff ff       	call   800743 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb 03                	jmp    8007bb <strlen+0x10>
		n++;
  8007b8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bf:	75 f7                	jne    8007b8 <strlen+0xd>
		n++;
	return n;
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d1:	eb 03                	jmp    8007d6 <strnlen+0x13>
		n++;
  8007d3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d6:	39 c2                	cmp    %eax,%edx
  8007d8:	74 08                	je     8007e2 <strnlen+0x1f>
  8007da:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007de:	75 f3                	jne    8007d3 <strnlen+0x10>
  8007e0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	83 c2 01             	add    $0x1,%edx
  8007f3:	83 c1 01             	add    $0x1,%ecx
  8007f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007fd:	84 db                	test   %bl,%bl
  8007ff:	75 ef                	jne    8007f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800801:	5b                   	pop    %ebx
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080b:	53                   	push   %ebx
  80080c:	e8 9a ff ff ff       	call   8007ab <strlen>
  800811:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800814:	ff 75 0c             	pushl  0xc(%ebp)
  800817:	01 d8                	add    %ebx,%eax
  800819:	50                   	push   %eax
  80081a:	e8 c5 ff ff ff       	call   8007e4 <strcpy>
	return dst;
}
  80081f:	89 d8                	mov    %ebx,%eax
  800821:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800824:	c9                   	leave  
  800825:	c3                   	ret    

00800826 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800831:	89 f3                	mov    %esi,%ebx
  800833:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800836:	89 f2                	mov    %esi,%edx
  800838:	eb 0f                	jmp    800849 <strncpy+0x23>
		*dst++ = *src;
  80083a:	83 c2 01             	add    $0x1,%edx
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800843:	80 39 01             	cmpb   $0x1,(%ecx)
  800846:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	39 da                	cmp    %ebx,%edx
  80084b:	75 ed                	jne    80083a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	8b 55 10             	mov    0x10(%ebp),%edx
  800861:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800863:	85 d2                	test   %edx,%edx
  800865:	74 21                	je     800888 <strlcpy+0x35>
  800867:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086b:	89 f2                	mov    %esi,%edx
  80086d:	eb 09                	jmp    800878 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086f:	83 c2 01             	add    $0x1,%edx
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800878:	39 c2                	cmp    %eax,%edx
  80087a:	74 09                	je     800885 <strlcpy+0x32>
  80087c:	0f b6 19             	movzbl (%ecx),%ebx
  80087f:	84 db                	test   %bl,%bl
  800881:	75 ec                	jne    80086f <strlcpy+0x1c>
  800883:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800885:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800888:	29 f0                	sub    %esi,%eax
}
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800897:	eb 06                	jmp    80089f <strcmp+0x11>
		p++, q++;
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089f:	0f b6 01             	movzbl (%ecx),%eax
  8008a2:	84 c0                	test   %al,%al
  8008a4:	74 04                	je     8008aa <strcmp+0x1c>
  8008a6:	3a 02                	cmp    (%edx),%al
  8008a8:	74 ef                	je     800899 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008aa:	0f b6 c0             	movzbl %al,%eax
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	29 d0                	sub    %edx,%eax
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 c3                	mov    %eax,%ebx
  8008c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c3:	eb 06                	jmp    8008cb <strncmp+0x17>
		n--, p++, q++;
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cb:	39 d8                	cmp    %ebx,%eax
  8008cd:	74 15                	je     8008e4 <strncmp+0x30>
  8008cf:	0f b6 08             	movzbl (%eax),%ecx
  8008d2:	84 c9                	test   %cl,%cl
  8008d4:	74 04                	je     8008da <strncmp+0x26>
  8008d6:	3a 0a                	cmp    (%edx),%cl
  8008d8:	74 eb                	je     8008c5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008da:	0f b6 00             	movzbl (%eax),%eax
  8008dd:	0f b6 12             	movzbl (%edx),%edx
  8008e0:	29 d0                	sub    %edx,%eax
  8008e2:	eb 05                	jmp    8008e9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f6:	eb 07                	jmp    8008ff <strchr+0x13>
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	74 0f                	je     80090b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	0f b6 10             	movzbl (%eax),%edx
  800902:	84 d2                	test   %dl,%dl
  800904:	75 f2                	jne    8008f8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800917:	eb 03                	jmp    80091c <strfind+0xf>
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091f:	38 ca                	cmp    %cl,%dl
  800921:	74 04                	je     800927 <strfind+0x1a>
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f2                	jne    800919 <strfind+0xc>
			break;
	return (char *) s;
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 36                	je     80096f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800939:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093f:	75 28                	jne    800969 <memset+0x40>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 23                	jne    800969 <memset+0x40>
		c &= 0xFF;
  800946:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094a:	89 d3                	mov    %edx,%ebx
  80094c:	c1 e3 08             	shl    $0x8,%ebx
  80094f:	89 d6                	mov    %edx,%esi
  800951:	c1 e6 18             	shl    $0x18,%esi
  800954:	89 d0                	mov    %edx,%eax
  800956:	c1 e0 10             	shl    $0x10,%eax
  800959:	09 f0                	or     %esi,%eax
  80095b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80095d:	89 d8                	mov    %ebx,%eax
  80095f:	09 d0                	or     %edx,%eax
  800961:	c1 e9 02             	shr    $0x2,%ecx
  800964:	fc                   	cld    
  800965:	f3 ab                	rep stos %eax,%es:(%edi)
  800967:	eb 06                	jmp    80096f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800969:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096c:	fc                   	cld    
  80096d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096f:	89 f8                	mov    %edi,%eax
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	57                   	push   %edi
  80097a:	56                   	push   %esi
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800981:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800984:	39 c6                	cmp    %eax,%esi
  800986:	73 35                	jae    8009bd <memmove+0x47>
  800988:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098b:	39 d0                	cmp    %edx,%eax
  80098d:	73 2e                	jae    8009bd <memmove+0x47>
		s += n;
		d += n;
  80098f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	89 d6                	mov    %edx,%esi
  800994:	09 fe                	or     %edi,%esi
  800996:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099c:	75 13                	jne    8009b1 <memmove+0x3b>
  80099e:	f6 c1 03             	test   $0x3,%cl
  8009a1:	75 0e                	jne    8009b1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a3:	83 ef 04             	sub    $0x4,%edi
  8009a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
  8009ac:	fd                   	std    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 09                	jmp    8009ba <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b1:	83 ef 01             	sub    $0x1,%edi
  8009b4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b7:	fd                   	std    
  8009b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ba:	fc                   	cld    
  8009bb:	eb 1d                	jmp    8009da <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	89 f2                	mov    %esi,%edx
  8009bf:	09 c2                	or     %eax,%edx
  8009c1:	f6 c2 03             	test   $0x3,%dl
  8009c4:	75 0f                	jne    8009d5 <memmove+0x5f>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 0a                	jne    8009d5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 05                	jmp    8009da <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e1:	ff 75 10             	pushl  0x10(%ebp)
  8009e4:	ff 75 0c             	pushl  0xc(%ebp)
  8009e7:	ff 75 08             	pushl  0x8(%ebp)
  8009ea:	e8 87 ff ff ff       	call   800976 <memmove>
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 c6                	mov    %eax,%esi
  8009fe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a01:	eb 1a                	jmp    800a1d <memcmp+0x2c>
		if (*s1 != *s2)
  800a03:	0f b6 08             	movzbl (%eax),%ecx
  800a06:	0f b6 1a             	movzbl (%edx),%ebx
  800a09:	38 d9                	cmp    %bl,%cl
  800a0b:	74 0a                	je     800a17 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a0d:	0f b6 c1             	movzbl %cl,%eax
  800a10:	0f b6 db             	movzbl %bl,%ebx
  800a13:	29 d8                	sub    %ebx,%eax
  800a15:	eb 0f                	jmp    800a26 <memcmp+0x35>
		s1++, s2++;
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	39 f0                	cmp    %esi,%eax
  800a1f:	75 e2                	jne    800a03 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	53                   	push   %ebx
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a31:	89 c1                	mov    %eax,%ecx
  800a33:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a36:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3a:	eb 0a                	jmp    800a46 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3c:	0f b6 10             	movzbl (%eax),%edx
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	74 07                	je     800a4a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	39 c8                	cmp    %ecx,%eax
  800a48:	72 f2                	jb     800a3c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a59:	eb 03                	jmp    800a5e <strtol+0x11>
		s++;
  800a5b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5e:	0f b6 01             	movzbl (%ecx),%eax
  800a61:	3c 20                	cmp    $0x20,%al
  800a63:	74 f6                	je     800a5b <strtol+0xe>
  800a65:	3c 09                	cmp    $0x9,%al
  800a67:	74 f2                	je     800a5b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a69:	3c 2b                	cmp    $0x2b,%al
  800a6b:	75 0a                	jne    800a77 <strtol+0x2a>
		s++;
  800a6d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
  800a75:	eb 11                	jmp    800a88 <strtol+0x3b>
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a7c:	3c 2d                	cmp    $0x2d,%al
  800a7e:	75 08                	jne    800a88 <strtol+0x3b>
		s++, neg = 1;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8e:	75 15                	jne    800aa5 <strtol+0x58>
  800a90:	80 39 30             	cmpb   $0x30,(%ecx)
  800a93:	75 10                	jne    800aa5 <strtol+0x58>
  800a95:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a99:	75 7c                	jne    800b17 <strtol+0xca>
		s += 2, base = 16;
  800a9b:	83 c1 02             	add    $0x2,%ecx
  800a9e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa3:	eb 16                	jmp    800abb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa5:	85 db                	test   %ebx,%ebx
  800aa7:	75 12                	jne    800abb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aae:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab1:	75 08                	jne    800abb <strtol+0x6e>
		s++, base = 8;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac3:	0f b6 11             	movzbl (%ecx),%edx
  800ac6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 09             	cmp    $0x9,%bl
  800ace:	77 08                	ja     800ad8 <strtol+0x8b>
			dig = *s - '0';
  800ad0:	0f be d2             	movsbl %dl,%edx
  800ad3:	83 ea 30             	sub    $0x30,%edx
  800ad6:	eb 22                	jmp    800afa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 57             	sub    $0x57,%edx
  800ae8:	eb 10                	jmp    800afa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aea:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 16                	ja     800b0a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af4:	0f be d2             	movsbl %dl,%edx
  800af7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800afa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800afd:	7d 0b                	jge    800b0a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aff:	83 c1 01             	add    $0x1,%ecx
  800b02:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b06:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b08:	eb b9                	jmp    800ac3 <strtol+0x76>

	if (endptr)
  800b0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0e:	74 0d                	je     800b1d <strtol+0xd0>
		*endptr = (char *) s;
  800b10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b13:	89 0e                	mov    %ecx,(%esi)
  800b15:	eb 06                	jmp    800b1d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	74 98                	je     800ab3 <strtol+0x66>
  800b1b:	eb 9e                	jmp    800abb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	f7 da                	neg    %edx
  800b21:	85 ff                	test   %edi,%edi
  800b23:	0f 45 c2             	cmovne %edx,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	89 c3                	mov    %eax,%ebx
  800b3e:	89 c7                	mov    %eax,%edi
  800b40:	89 c6                	mov    %eax,%esi
  800b42:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b54:	b8 01 00 00 00       	mov    $0x1,%eax
  800b59:	89 d1                	mov    %edx,%ecx
  800b5b:	89 d3                	mov    %edx,%ebx
  800b5d:	89 d7                	mov    %edx,%edi
  800b5f:	89 d6                	mov    %edx,%esi
  800b61:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b76:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	89 cb                	mov    %ecx,%ebx
  800b80:	89 cf                	mov    %ecx,%edi
  800b82:	89 ce                	mov    %ecx,%esi
  800b84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b86:	85 c0                	test   %eax,%eax
  800b88:	7e 17                	jle    800ba1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 03                	push   $0x3
  800b90:	68 3f 22 80 00       	push   $0x80223f
  800b95:	6a 23                	push   $0x23
  800b97:	68 5c 22 80 00       	push   $0x80225c
  800b9c:	e8 9b f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800baf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb4:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb9:	89 d1                	mov    %edx,%ecx
  800bbb:	89 d3                	mov    %edx,%ebx
  800bbd:	89 d7                	mov    %edx,%edi
  800bbf:	89 d6                	mov    %edx,%esi
  800bc1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_yield>:

void
sys_yield(void)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd8:	89 d1                	mov    %edx,%ecx
  800bda:	89 d3                	mov    %edx,%ebx
  800bdc:	89 d7                	mov    %edx,%edi
  800bde:	89 d6                	mov    %edx,%esi
  800be0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bf0:	be 00 00 00 00       	mov    $0x0,%esi
  800bf5:	b8 04 00 00 00       	mov    $0x4,%eax
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c03:	89 f7                	mov    %esi,%edi
  800c05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7e 17                	jle    800c22 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 04                	push   $0x4
  800c11:	68 3f 22 80 00       	push   $0x80223f
  800c16:	6a 23                	push   $0x23
  800c18:	68 5c 22 80 00       	push   $0x80225c
  800c1d:	e8 1a f5 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c33:	b8 05 00 00 00       	mov    $0x5,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c41:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c44:	8b 75 18             	mov    0x18(%ebp),%esi
  800c47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7e 17                	jle    800c64 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 05                	push   $0x5
  800c53:	68 3f 22 80 00       	push   $0x80223f
  800c58:	6a 23                	push   $0x23
  800c5a:	68 5c 22 80 00       	push   $0x80225c
  800c5f:	e8 d8 f4 ff ff       	call   80013c <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	89 df                	mov    %ebx,%edi
  800c87:	89 de                	mov    %ebx,%esi
  800c89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 17                	jle    800ca6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 06                	push   $0x6
  800c95:	68 3f 22 80 00       	push   $0x80223f
  800c9a:	6a 23                	push   $0x23
  800c9c:	68 5c 22 80 00       	push   $0x80225c
  800ca1:	e8 96 f4 ff ff       	call   80013c <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbc:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 df                	mov    %ebx,%edi
  800cc9:	89 de                	mov    %ebx,%esi
  800ccb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 17                	jle    800ce8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 08                	push   $0x8
  800cd7:	68 3f 22 80 00       	push   $0x80223f
  800cdc:	6a 23                	push   $0x23
  800cde:	68 5c 22 80 00       	push   $0x80225c
  800ce3:	e8 54 f4 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 df                	mov    %ebx,%edi
  800d0b:	89 de                	mov    %ebx,%esi
  800d0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 09                	push   $0x9
  800d19:	68 3f 22 80 00       	push   $0x80223f
  800d1e:	6a 23                	push   $0x23
  800d20:	68 5c 22 80 00       	push   $0x80225c
  800d25:	e8 12 f4 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	89 df                	mov    %ebx,%edi
  800d4d:	89 de                	mov    %ebx,%esi
  800d4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 17                	jle    800d6c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 0a                	push   $0xa
  800d5b:	68 3f 22 80 00       	push   $0x80223f
  800d60:	6a 23                	push   $0x23
  800d62:	68 5c 22 80 00       	push   $0x80225c
  800d67:	e8 d0 f3 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d7a:	be 00 00 00 00       	mov    $0x0,%esi
  800d7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d90:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800da0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	89 cb                	mov    %ecx,%ebx
  800daf:	89 cf                	mov    %ecx,%edi
  800db1:	89 ce                	mov    %ecx,%esi
  800db3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7e 17                	jle    800dd0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	50                   	push   %eax
  800dbd:	6a 0d                	push   $0xd
  800dbf:	68 3f 22 80 00       	push   $0x80223f
  800dc4:	6a 23                	push   $0x23
  800dc6:	68 5c 22 80 00       	push   $0x80225c
  800dcb:	e8 6c f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	05 00 00 00 30       	add    $0x30000000,%eax
  800de3:	c1 e8 0c             	shr    $0xc,%eax
}
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	05 00 00 00 30       	add    $0x30000000,%eax
  800df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e05:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e0a:	89 c2                	mov    %eax,%edx
  800e0c:	c1 ea 16             	shr    $0x16,%edx
  800e0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e16:	f6 c2 01             	test   $0x1,%dl
  800e19:	74 11                	je     800e2c <fd_alloc+0x2d>
  800e1b:	89 c2                	mov    %eax,%edx
  800e1d:	c1 ea 0c             	shr    $0xc,%edx
  800e20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e27:	f6 c2 01             	test   $0x1,%dl
  800e2a:	75 09                	jne    800e35 <fd_alloc+0x36>
			*fd_store = fd;
  800e2c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e33:	eb 17                	jmp    800e4c <fd_alloc+0x4d>
  800e35:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e3a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3f:	75 c9                	jne    800e0a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e41:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e47:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e54:	83 f8 1f             	cmp    $0x1f,%eax
  800e57:	77 36                	ja     800e8f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e59:	c1 e0 0c             	shl    $0xc,%eax
  800e5c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	c1 ea 16             	shr    $0x16,%edx
  800e66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6d:	f6 c2 01             	test   $0x1,%dl
  800e70:	74 24                	je     800e96 <fd_lookup+0x48>
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	c1 ea 0c             	shr    $0xc,%edx
  800e77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7e:	f6 c2 01             	test   $0x1,%dl
  800e81:	74 1a                	je     800e9d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e86:	89 02                	mov    %eax,(%edx)
	return 0;
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	eb 13                	jmp    800ea2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e94:	eb 0c                	jmp    800ea2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9b:	eb 05                	jmp    800ea2 <fd_lookup+0x54>
  800e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ead:	ba ec 22 80 00       	mov    $0x8022ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb2:	eb 13                	jmp    800ec7 <dev_lookup+0x23>
  800eb4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eb7:	39 08                	cmp    %ecx,(%eax)
  800eb9:	75 0c                	jne    800ec7 <dev_lookup+0x23>
			*dev = devtab[i];
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	eb 2e                	jmp    800ef5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec7:	8b 02                	mov    (%edx),%eax
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	75 e7                	jne    800eb4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ecd:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800ed2:	8b 40 48             	mov    0x48(%eax),%eax
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	51                   	push   %ecx
  800ed9:	50                   	push   %eax
  800eda:	68 6c 22 80 00       	push   $0x80226c
  800edf:	e8 31 f3 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	83 ec 10             	sub    $0x10,%esp
  800eff:	8b 75 08             	mov    0x8(%ebp),%esi
  800f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f08:	50                   	push   %eax
  800f09:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f0f:	c1 e8 0c             	shr    $0xc,%eax
  800f12:	50                   	push   %eax
  800f13:	e8 36 ff ff ff       	call   800e4e <fd_lookup>
  800f18:	83 c4 08             	add    $0x8,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	78 05                	js     800f24 <fd_close+0x2d>
	    || fd != fd2)
  800f1f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f22:	74 0c                	je     800f30 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f24:	84 db                	test   %bl,%bl
  800f26:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2b:	0f 44 c2             	cmove  %edx,%eax
  800f2e:	eb 41                	jmp    800f71 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f36:	50                   	push   %eax
  800f37:	ff 36                	pushl  (%esi)
  800f39:	e8 66 ff ff ff       	call   800ea4 <dev_lookup>
  800f3e:	89 c3                	mov    %eax,%ebx
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 1a                	js     800f61 <fd_close+0x6a>
		if (dev->dev_close)
  800f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f4d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f52:	85 c0                	test   %eax,%eax
  800f54:	74 0b                	je     800f61 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f56:	83 ec 0c             	sub    $0xc,%esp
  800f59:	56                   	push   %esi
  800f5a:	ff d0                	call   *%eax
  800f5c:	89 c3                	mov    %eax,%ebx
  800f5e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f61:	83 ec 08             	sub    $0x8,%esp
  800f64:	56                   	push   %esi
  800f65:	6a 00                	push   $0x0
  800f67:	e8 00 fd ff ff       	call   800c6c <sys_page_unmap>
	return r;
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	89 d8                	mov    %ebx,%eax
}
  800f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f81:	50                   	push   %eax
  800f82:	ff 75 08             	pushl  0x8(%ebp)
  800f85:	e8 c4 fe ff ff       	call   800e4e <fd_lookup>
  800f8a:	83 c4 08             	add    $0x8,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 10                	js     800fa1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f91:	83 ec 08             	sub    $0x8,%esp
  800f94:	6a 01                	push   $0x1
  800f96:	ff 75 f4             	pushl  -0xc(%ebp)
  800f99:	e8 59 ff ff ff       	call   800ef7 <fd_close>
  800f9e:	83 c4 10             	add    $0x10,%esp
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <close_all>:

void
close_all(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	53                   	push   %ebx
  800fb3:	e8 c0 ff ff ff       	call   800f78 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb8:	83 c3 01             	add    $0x1,%ebx
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	83 fb 20             	cmp    $0x20,%ebx
  800fc1:	75 ec                	jne    800faf <close_all+0xc>
		close(i);
}
  800fc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	57                   	push   %edi
  800fcc:	56                   	push   %esi
  800fcd:	53                   	push   %ebx
  800fce:	83 ec 2c             	sub    $0x2c,%esp
  800fd1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	ff 75 08             	pushl  0x8(%ebp)
  800fdb:	e8 6e fe ff ff       	call   800e4e <fd_lookup>
  800fe0:	83 c4 08             	add    $0x8,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	0f 88 c1 00 00 00    	js     8010ac <dup+0xe4>
		return r;
	close(newfdnum);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	56                   	push   %esi
  800fef:	e8 84 ff ff ff       	call   800f78 <close>

	newfd = INDEX2FD(newfdnum);
  800ff4:	89 f3                	mov    %esi,%ebx
  800ff6:	c1 e3 0c             	shl    $0xc,%ebx
  800ff9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fff:	83 c4 04             	add    $0x4,%esp
  801002:	ff 75 e4             	pushl  -0x1c(%ebp)
  801005:	e8 de fd ff ff       	call   800de8 <fd2data>
  80100a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80100c:	89 1c 24             	mov    %ebx,(%esp)
  80100f:	e8 d4 fd ff ff       	call   800de8 <fd2data>
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80101a:	89 f8                	mov    %edi,%eax
  80101c:	c1 e8 16             	shr    $0x16,%eax
  80101f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801026:	a8 01                	test   $0x1,%al
  801028:	74 37                	je     801061 <dup+0x99>
  80102a:	89 f8                	mov    %edi,%eax
  80102c:	c1 e8 0c             	shr    $0xc,%eax
  80102f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801036:	f6 c2 01             	test   $0x1,%dl
  801039:	74 26                	je     801061 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80103b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	25 07 0e 00 00       	and    $0xe07,%eax
  80104a:	50                   	push   %eax
  80104b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104e:	6a 00                	push   $0x0
  801050:	57                   	push   %edi
  801051:	6a 00                	push   $0x0
  801053:	e8 d2 fb ff ff       	call   800c2a <sys_page_map>
  801058:	89 c7                	mov    %eax,%edi
  80105a:	83 c4 20             	add    $0x20,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 2e                	js     80108f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801061:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801064:	89 d0                	mov    %edx,%eax
  801066:	c1 e8 0c             	shr    $0xc,%eax
  801069:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	25 07 0e 00 00       	and    $0xe07,%eax
  801078:	50                   	push   %eax
  801079:	53                   	push   %ebx
  80107a:	6a 00                	push   $0x0
  80107c:	52                   	push   %edx
  80107d:	6a 00                	push   $0x0
  80107f:	e8 a6 fb ff ff       	call   800c2a <sys_page_map>
  801084:	89 c7                	mov    %eax,%edi
  801086:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801089:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108b:	85 ff                	test   %edi,%edi
  80108d:	79 1d                	jns    8010ac <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80108f:	83 ec 08             	sub    $0x8,%esp
  801092:	53                   	push   %ebx
  801093:	6a 00                	push   $0x0
  801095:	e8 d2 fb ff ff       	call   800c6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80109a:	83 c4 08             	add    $0x8,%esp
  80109d:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 c5 fb ff ff       	call   800c6c <sys_page_unmap>
	return r;
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	89 f8                	mov    %edi,%eax
}
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 14             	sub    $0x14,%esp
  8010bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c1:	50                   	push   %eax
  8010c2:	53                   	push   %ebx
  8010c3:	e8 86 fd ff ff       	call   800e4e <fd_lookup>
  8010c8:	83 c4 08             	add    $0x8,%esp
  8010cb:	89 c2                	mov    %eax,%edx
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 6d                	js     80113e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d1:	83 ec 08             	sub    $0x8,%esp
  8010d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d7:	50                   	push   %eax
  8010d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010db:	ff 30                	pushl  (%eax)
  8010dd:	e8 c2 fd ff ff       	call   800ea4 <dev_lookup>
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 4c                	js     801135 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ec:	8b 42 08             	mov    0x8(%edx),%eax
  8010ef:	83 e0 03             	and    $0x3,%eax
  8010f2:	83 f8 01             	cmp    $0x1,%eax
  8010f5:	75 21                	jne    801118 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f7:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8010fc:	8b 40 48             	mov    0x48(%eax),%eax
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	53                   	push   %ebx
  801103:	50                   	push   %eax
  801104:	68 b0 22 80 00       	push   $0x8022b0
  801109:	e8 07 f1 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801116:	eb 26                	jmp    80113e <read+0x8a>
	}
	if (!dev->dev_read)
  801118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111b:	8b 40 08             	mov    0x8(%eax),%eax
  80111e:	85 c0                	test   %eax,%eax
  801120:	74 17                	je     801139 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	ff 75 10             	pushl  0x10(%ebp)
  801128:	ff 75 0c             	pushl  0xc(%ebp)
  80112b:	52                   	push   %edx
  80112c:	ff d0                	call   *%eax
  80112e:	89 c2                	mov    %eax,%edx
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	eb 09                	jmp    80113e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801135:	89 c2                	mov    %eax,%edx
  801137:	eb 05                	jmp    80113e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801139:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80113e:	89 d0                	mov    %edx,%eax
  801140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801151:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801154:	bb 00 00 00 00       	mov    $0x0,%ebx
  801159:	eb 21                	jmp    80117c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	89 f0                	mov    %esi,%eax
  801160:	29 d8                	sub    %ebx,%eax
  801162:	50                   	push   %eax
  801163:	89 d8                	mov    %ebx,%eax
  801165:	03 45 0c             	add    0xc(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	57                   	push   %edi
  80116a:	e8 45 ff ff ff       	call   8010b4 <read>
		if (m < 0)
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	78 10                	js     801186 <readn+0x41>
			return m;
		if (m == 0)
  801176:	85 c0                	test   %eax,%eax
  801178:	74 0a                	je     801184 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117a:	01 c3                	add    %eax,%ebx
  80117c:	39 f3                	cmp    %esi,%ebx
  80117e:	72 db                	jb     80115b <readn+0x16>
  801180:	89 d8                	mov    %ebx,%eax
  801182:	eb 02                	jmp    801186 <readn+0x41>
  801184:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	53                   	push   %ebx
  801192:	83 ec 14             	sub    $0x14,%esp
  801195:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801198:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	53                   	push   %ebx
  80119d:	e8 ac fc ff ff       	call   800e4e <fd_lookup>
  8011a2:	83 c4 08             	add    $0x8,%esp
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 68                	js     801213 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b5:	ff 30                	pushl  (%eax)
  8011b7:	e8 e8 fc ff ff       	call   800ea4 <dev_lookup>
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 47                	js     80120a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ca:	75 21                	jne    8011ed <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cc:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011d1:	8b 40 48             	mov    0x48(%eax),%eax
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	53                   	push   %ebx
  8011d8:	50                   	push   %eax
  8011d9:	68 cc 22 80 00       	push   $0x8022cc
  8011de:	e8 32 f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011eb:	eb 26                	jmp    801213 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f3:	85 d2                	test   %edx,%edx
  8011f5:	74 17                	je     80120e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	ff 75 10             	pushl  0x10(%ebp)
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	50                   	push   %eax
  801201:	ff d2                	call   *%edx
  801203:	89 c2                	mov    %eax,%edx
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	eb 09                	jmp    801213 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	eb 05                	jmp    801213 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80120e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801213:	89 d0                	mov    %edx,%eax
  801215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <seek>:

int
seek(int fdnum, off_t offset)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801220:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801223:	50                   	push   %eax
  801224:	ff 75 08             	pushl  0x8(%ebp)
  801227:	e8 22 fc ff ff       	call   800e4e <fd_lookup>
  80122c:	83 c4 08             	add    $0x8,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 0e                	js     801241 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801233:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801236:	8b 55 0c             	mov    0xc(%ebp),%edx
  801239:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 14             	sub    $0x14,%esp
  80124a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	53                   	push   %ebx
  801252:	e8 f7 fb ff ff       	call   800e4e <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 65                	js     8012c5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	ff 30                	pushl  (%eax)
  80126c:	e8 33 fc ff ff       	call   800ea4 <dev_lookup>
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 44                	js     8012bc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127f:	75 21                	jne    8012a2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801281:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	53                   	push   %ebx
  80128d:	50                   	push   %eax
  80128e:	68 8c 22 80 00       	push   $0x80228c
  801293:	e8 7d ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a0:	eb 23                	jmp    8012c5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a5:	8b 52 18             	mov    0x18(%edx),%edx
  8012a8:	85 d2                	test   %edx,%edx
  8012aa:	74 14                	je     8012c0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ac:	83 ec 08             	sub    $0x8,%esp
  8012af:	ff 75 0c             	pushl  0xc(%ebp)
  8012b2:	50                   	push   %eax
  8012b3:	ff d2                	call   *%edx
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	eb 09                	jmp    8012c5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bc:	89 c2                	mov    %eax,%edx
  8012be:	eb 05                	jmp    8012c5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012c5:	89 d0                	mov    %edx,%eax
  8012c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 14             	sub    $0x14,%esp
  8012d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d9:	50                   	push   %eax
  8012da:	ff 75 08             	pushl  0x8(%ebp)
  8012dd:	e8 6c fb ff ff       	call   800e4e <fd_lookup>
  8012e2:	83 c4 08             	add    $0x8,%esp
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 58                	js     801343 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	ff 30                	pushl  (%eax)
  8012f7:	e8 a8 fb ff ff       	call   800ea4 <dev_lookup>
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 37                	js     80133a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801306:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80130a:	74 32                	je     80133e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80130c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80130f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801316:	00 00 00 
	stat->st_isdir = 0;
  801319:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801320:	00 00 00 
	stat->st_dev = dev;
  801323:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	53                   	push   %ebx
  80132d:	ff 75 f0             	pushl  -0x10(%ebp)
  801330:	ff 50 14             	call   *0x14(%eax)
  801333:	89 c2                	mov    %eax,%edx
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	eb 09                	jmp    801343 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133a:	89 c2                	mov    %eax,%edx
  80133c:	eb 05                	jmp    801343 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80133e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801343:	89 d0                	mov    %edx,%eax
  801345:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	6a 00                	push   $0x0
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 dc 01 00 00       	call   801538 <open>
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 1b                	js     801380 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	ff 75 0c             	pushl  0xc(%ebp)
  80136b:	50                   	push   %eax
  80136c:	e8 5b ff ff ff       	call   8012cc <fstat>
  801371:	89 c6                	mov    %eax,%esi
	close(fd);
  801373:	89 1c 24             	mov    %ebx,(%esp)
  801376:	e8 fd fb ff ff       	call   800f78 <close>
	return r;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	89 f0                	mov    %esi,%eax
}
  801380:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	89 c6                	mov    %eax,%esi
  80138e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801390:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801397:	75 12                	jne    8013ab <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	6a 01                	push   $0x1
  80139e:	e8 b8 07 00 00       	call   801b5b <ipc_find_env>
  8013a3:	a3 00 40 80 00       	mov    %eax,0x804000
  8013a8:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ab:	6a 07                	push   $0x7
  8013ad:	68 00 50 c0 00       	push   $0xc05000
  8013b2:	56                   	push   %esi
  8013b3:	ff 35 00 40 80 00    	pushl  0x804000
  8013b9:	e8 5a 07 00 00       	call   801b18 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8013be:	83 c4 0c             	add    $0xc,%esp
  8013c1:	6a 00                	push   $0x0
  8013c3:	53                   	push   %ebx
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 f0 06 00 00       	call   801abb <ipc_recv>
}
  8013cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ce:	5b                   	pop    %ebx
  8013cf:	5e                   	pop    %esi
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	8b 40 0c             	mov    0xc(%eax),%eax
  8013de:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e6:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f5:	e8 8d ff ff ff       	call   801387 <fsipc>
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	8b 40 0c             	mov    0xc(%eax),%eax
  801408:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 06 00 00 00       	mov    $0x6,%eax
  801417:	e8 6b ff ff ff       	call   801387 <fsipc>
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 04             	sub    $0x4,%esp
  801425:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801428:	8b 45 08             	mov    0x8(%ebp),%eax
  80142b:	8b 40 0c             	mov    0xc(%eax),%eax
  80142e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801433:	ba 00 00 00 00       	mov    $0x0,%edx
  801438:	b8 05 00 00 00       	mov    $0x5,%eax
  80143d:	e8 45 ff ff ff       	call   801387 <fsipc>
  801442:	85 c0                	test   %eax,%eax
  801444:	78 2c                	js     801472 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	68 00 50 c0 00       	push   $0xc05000
  80144e:	53                   	push   %ebx
  80144f:	e8 90 f3 ff ff       	call   8007e4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801454:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801459:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80145f:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801464:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 0c             	sub    $0xc,%esp
  80147d:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801480:	8b 55 08             	mov    0x8(%ebp),%edx
  801483:	8b 52 0c             	mov    0xc(%edx),%edx
  801486:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  80148c:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801491:	50                   	push   %eax
  801492:	ff 75 0c             	pushl  0xc(%ebp)
  801495:	68 08 50 c0 00       	push   $0xc05008
  80149a:	e8 d7 f4 ff ff       	call   800976 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80149f:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a9:	e8 d9 fe ff ff       	call   801387 <fsipc>
	//panic("devfile_write not implemented");
}
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	56                   	push   %esi
  8014b4:	53                   	push   %ebx
  8014b5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8014be:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014c3:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ce:	b8 03 00 00 00       	mov    $0x3,%eax
  8014d3:	e8 af fe ff ff       	call   801387 <fsipc>
  8014d8:	89 c3                	mov    %eax,%ebx
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 51                	js     80152f <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8014de:	39 c6                	cmp    %eax,%esi
  8014e0:	73 19                	jae    8014fb <devfile_read+0x4b>
  8014e2:	68 fc 22 80 00       	push   $0x8022fc
  8014e7:	68 03 23 80 00       	push   $0x802303
  8014ec:	68 80 00 00 00       	push   $0x80
  8014f1:	68 18 23 80 00       	push   $0x802318
  8014f6:	e8 41 ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  8014fb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801500:	7e 19                	jle    80151b <devfile_read+0x6b>
  801502:	68 23 23 80 00       	push   $0x802323
  801507:	68 03 23 80 00       	push   $0x802303
  80150c:	68 81 00 00 00       	push   $0x81
  801511:	68 18 23 80 00       	push   $0x802318
  801516:	e8 21 ec ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80151b:	83 ec 04             	sub    $0x4,%esp
  80151e:	50                   	push   %eax
  80151f:	68 00 50 c0 00       	push   $0xc05000
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	e8 4a f4 ff ff       	call   800976 <memmove>
	return r;
  80152c:	83 c4 10             	add    $0x10,%esp
}
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    

00801538 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	53                   	push   %ebx
  80153c:	83 ec 20             	sub    $0x20,%esp
  80153f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801542:	53                   	push   %ebx
  801543:	e8 63 f2 ff ff       	call   8007ab <strlen>
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801550:	7f 67                	jg     8015b9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801552:	83 ec 0c             	sub    $0xc,%esp
  801555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	e8 a1 f8 ff ff       	call   800dff <fd_alloc>
  80155e:	83 c4 10             	add    $0x10,%esp
		return r;
  801561:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801563:	85 c0                	test   %eax,%eax
  801565:	78 57                	js     8015be <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	53                   	push   %ebx
  80156b:	68 00 50 c0 00       	push   $0xc05000
  801570:	e8 6f f2 ff ff       	call   8007e4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801575:	8b 45 0c             	mov    0xc(%ebp),%eax
  801578:	a3 00 54 c0 00       	mov    %eax,0xc05400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80157d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801580:	b8 01 00 00 00       	mov    $0x1,%eax
  801585:	e8 fd fd ff ff       	call   801387 <fsipc>
  80158a:	89 c3                	mov    %eax,%ebx
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	79 14                	jns    8015a7 <open+0x6f>
		
		fd_close(fd, 0);
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	6a 00                	push   $0x0
  801598:	ff 75 f4             	pushl  -0xc(%ebp)
  80159b:	e8 57 f9 ff ff       	call   800ef7 <fd_close>
		return r;
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	89 da                	mov    %ebx,%edx
  8015a5:	eb 17                	jmp    8015be <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ad:	e8 26 f8 ff ff       	call   800dd8 <fd2num>
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	eb 05                	jmp    8015be <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015b9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8015be:	89 d0                	mov    %edx,%eax
  8015c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c3:	c9                   	leave  
  8015c4:	c3                   	ret    

008015c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015c5:	55                   	push   %ebp
  8015c6:	89 e5                	mov    %esp,%ebp
  8015c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8015d5:	e8 ad fd ff ff       	call   801387 <fsipc>
}
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	ff 75 08             	pushl  0x8(%ebp)
  8015ea:	e8 f9 f7 ff ff       	call   800de8 <fd2data>
  8015ef:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015f1:	83 c4 08             	add    $0x8,%esp
  8015f4:	68 2f 23 80 00       	push   $0x80232f
  8015f9:	53                   	push   %ebx
  8015fa:	e8 e5 f1 ff ff       	call   8007e4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015ff:	8b 46 04             	mov    0x4(%esi),%eax
  801602:	2b 06                	sub    (%esi),%eax
  801604:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80160a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801611:	00 00 00 
	stat->st_dev = &devpipe;
  801614:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80161b:	30 80 00 
	return 0;
}
  80161e:	b8 00 00 00 00       	mov    $0x0,%eax
  801623:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	53                   	push   %ebx
  80162e:	83 ec 0c             	sub    $0xc,%esp
  801631:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801634:	53                   	push   %ebx
  801635:	6a 00                	push   $0x0
  801637:	e8 30 f6 ff ff       	call   800c6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80163c:	89 1c 24             	mov    %ebx,(%esp)
  80163f:	e8 a4 f7 ff ff       	call   800de8 <fd2data>
  801644:	83 c4 08             	add    $0x8,%esp
  801647:	50                   	push   %eax
  801648:	6a 00                	push   $0x0
  80164a:	e8 1d f6 ff ff       	call   800c6c <sys_page_unmap>
}
  80164f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	57                   	push   %edi
  801658:	56                   	push   %esi
  801659:	53                   	push   %ebx
  80165a:	83 ec 1c             	sub    $0x1c,%esp
  80165d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801660:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801662:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801667:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	ff 75 e0             	pushl  -0x20(%ebp)
  801670:	e8 1f 05 00 00       	call   801b94 <pageref>
  801675:	89 c3                	mov    %eax,%ebx
  801677:	89 3c 24             	mov    %edi,(%esp)
  80167a:	e8 15 05 00 00       	call   801b94 <pageref>
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	39 c3                	cmp    %eax,%ebx
  801684:	0f 94 c1             	sete   %cl
  801687:	0f b6 c9             	movzbl %cl,%ecx
  80168a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80168d:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801693:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801696:	39 ce                	cmp    %ecx,%esi
  801698:	74 1b                	je     8016b5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80169a:	39 c3                	cmp    %eax,%ebx
  80169c:	75 c4                	jne    801662 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80169e:	8b 42 58             	mov    0x58(%edx),%eax
  8016a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a4:	50                   	push   %eax
  8016a5:	56                   	push   %esi
  8016a6:	68 36 23 80 00       	push   $0x802336
  8016ab:	e8 65 eb ff ff       	call   800215 <cprintf>
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	eb ad                	jmp    801662 <_pipeisclosed+0xe>
	}
}
  8016b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	57                   	push   %edi
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 28             	sub    $0x28,%esp
  8016c9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016cc:	56                   	push   %esi
  8016cd:	e8 16 f7 ff ff       	call   800de8 <fd2data>
  8016d2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8016dc:	eb 4b                	jmp    801729 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016de:	89 da                	mov    %ebx,%edx
  8016e0:	89 f0                	mov    %esi,%eax
  8016e2:	e8 6d ff ff ff       	call   801654 <_pipeisclosed>
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	75 48                	jne    801733 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016eb:	e8 d8 f4 ff ff       	call   800bc8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f3:	8b 0b                	mov    (%ebx),%ecx
  8016f5:	8d 51 20             	lea    0x20(%ecx),%edx
  8016f8:	39 d0                	cmp    %edx,%eax
  8016fa:	73 e2                	jae    8016de <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ff:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801703:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801706:	89 c2                	mov    %eax,%edx
  801708:	c1 fa 1f             	sar    $0x1f,%edx
  80170b:	89 d1                	mov    %edx,%ecx
  80170d:	c1 e9 1b             	shr    $0x1b,%ecx
  801710:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801713:	83 e2 1f             	and    $0x1f,%edx
  801716:	29 ca                	sub    %ecx,%edx
  801718:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80171c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801720:	83 c0 01             	add    $0x1,%eax
  801723:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801726:	83 c7 01             	add    $0x1,%edi
  801729:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80172c:	75 c2                	jne    8016f0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80172e:	8b 45 10             	mov    0x10(%ebp),%eax
  801731:	eb 05                	jmp    801738 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801738:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173b:	5b                   	pop    %ebx
  80173c:	5e                   	pop    %esi
  80173d:	5f                   	pop    %edi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	57                   	push   %edi
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
  801746:	83 ec 18             	sub    $0x18,%esp
  801749:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80174c:	57                   	push   %edi
  80174d:	e8 96 f6 ff ff       	call   800de8 <fd2data>
  801752:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175c:	eb 3d                	jmp    80179b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80175e:	85 db                	test   %ebx,%ebx
  801760:	74 04                	je     801766 <devpipe_read+0x26>
				return i;
  801762:	89 d8                	mov    %ebx,%eax
  801764:	eb 44                	jmp    8017aa <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801766:	89 f2                	mov    %esi,%edx
  801768:	89 f8                	mov    %edi,%eax
  80176a:	e8 e5 fe ff ff       	call   801654 <_pipeisclosed>
  80176f:	85 c0                	test   %eax,%eax
  801771:	75 32                	jne    8017a5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801773:	e8 50 f4 ff ff       	call   800bc8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801778:	8b 06                	mov    (%esi),%eax
  80177a:	3b 46 04             	cmp    0x4(%esi),%eax
  80177d:	74 df                	je     80175e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80177f:	99                   	cltd   
  801780:	c1 ea 1b             	shr    $0x1b,%edx
  801783:	01 d0                	add    %edx,%eax
  801785:	83 e0 1f             	and    $0x1f,%eax
  801788:	29 d0                	sub    %edx,%eax
  80178a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80178f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801792:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801795:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801798:	83 c3 01             	add    $0x1,%ebx
  80179b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80179e:	75 d8                	jne    801778 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a3:	eb 05                	jmp    8017aa <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ad:	5b                   	pop    %ebx
  8017ae:	5e                   	pop    %esi
  8017af:	5f                   	pop    %edi
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    

008017b2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bd:	50                   	push   %eax
  8017be:	e8 3c f6 ff ff       	call   800dff <fd_alloc>
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	89 c2                	mov    %eax,%edx
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	0f 88 2c 01 00 00    	js     8018fc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d0:	83 ec 04             	sub    $0x4,%esp
  8017d3:	68 07 04 00 00       	push   $0x407
  8017d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017db:	6a 00                	push   $0x0
  8017dd:	e8 05 f4 ff ff       	call   800be7 <sys_page_alloc>
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	89 c2                	mov    %eax,%edx
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	0f 88 0d 01 00 00    	js     8018fc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017ef:	83 ec 0c             	sub    $0xc,%esp
  8017f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f5:	50                   	push   %eax
  8017f6:	e8 04 f6 ff ff       	call   800dff <fd_alloc>
  8017fb:	89 c3                	mov    %eax,%ebx
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	85 c0                	test   %eax,%eax
  801802:	0f 88 e2 00 00 00    	js     8018ea <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801808:	83 ec 04             	sub    $0x4,%esp
  80180b:	68 07 04 00 00       	push   $0x407
  801810:	ff 75 f0             	pushl  -0x10(%ebp)
  801813:	6a 00                	push   $0x0
  801815:	e8 cd f3 ff ff       	call   800be7 <sys_page_alloc>
  80181a:	89 c3                	mov    %eax,%ebx
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	85 c0                	test   %eax,%eax
  801821:	0f 88 c3 00 00 00    	js     8018ea <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	ff 75 f4             	pushl  -0xc(%ebp)
  80182d:	e8 b6 f5 ff ff       	call   800de8 <fd2data>
  801832:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801834:	83 c4 0c             	add    $0xc,%esp
  801837:	68 07 04 00 00       	push   $0x407
  80183c:	50                   	push   %eax
  80183d:	6a 00                	push   $0x0
  80183f:	e8 a3 f3 ff ff       	call   800be7 <sys_page_alloc>
  801844:	89 c3                	mov    %eax,%ebx
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	85 c0                	test   %eax,%eax
  80184b:	0f 88 89 00 00 00    	js     8018da <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	ff 75 f0             	pushl  -0x10(%ebp)
  801857:	e8 8c f5 ff ff       	call   800de8 <fd2data>
  80185c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801863:	50                   	push   %eax
  801864:	6a 00                	push   $0x0
  801866:	56                   	push   %esi
  801867:	6a 00                	push   $0x0
  801869:	e8 bc f3 ff ff       	call   800c2a <sys_page_map>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	83 c4 20             	add    $0x20,%esp
  801873:	85 c0                	test   %eax,%eax
  801875:	78 55                	js     8018cc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801877:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801880:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801885:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80188c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801892:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801895:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018a1:	83 ec 0c             	sub    $0xc,%esp
  8018a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a7:	e8 2c f5 ff ff       	call   800dd8 <fd2num>
  8018ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018af:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018b1:	83 c4 04             	add    $0x4,%esp
  8018b4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b7:	e8 1c f5 ff ff       	call   800dd8 <fd2num>
  8018bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018bf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	eb 30                	jmp    8018fc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	56                   	push   %esi
  8018d0:	6a 00                	push   $0x0
  8018d2:	e8 95 f3 ff ff       	call   800c6c <sys_page_unmap>
  8018d7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018da:	83 ec 08             	sub    $0x8,%esp
  8018dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e0:	6a 00                	push   $0x0
  8018e2:	e8 85 f3 ff ff       	call   800c6c <sys_page_unmap>
  8018e7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f0:	6a 00                	push   $0x0
  8018f2:	e8 75 f3 ff ff       	call   800c6c <sys_page_unmap>
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018fc:	89 d0                	mov    %edx,%eax
  8018fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801901:	5b                   	pop    %ebx
  801902:	5e                   	pop    %esi
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80190b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190e:	50                   	push   %eax
  80190f:	ff 75 08             	pushl  0x8(%ebp)
  801912:	e8 37 f5 ff ff       	call   800e4e <fd_lookup>
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	78 18                	js     801936 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80191e:	83 ec 0c             	sub    $0xc,%esp
  801921:	ff 75 f4             	pushl  -0xc(%ebp)
  801924:	e8 bf f4 ff ff       	call   800de8 <fd2data>
	return _pipeisclosed(fd, p);
  801929:	89 c2                	mov    %eax,%edx
  80192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192e:	e8 21 fd ff ff       	call   801654 <_pipeisclosed>
  801933:	83 c4 10             	add    $0x10,%esp
}
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
  801940:	5d                   	pop    %ebp
  801941:	c3                   	ret    

00801942 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801948:	68 4e 23 80 00       	push   $0x80234e
  80194d:	ff 75 0c             	pushl  0xc(%ebp)
  801950:	e8 8f ee ff ff       	call   8007e4 <strcpy>
	return 0;
}
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	57                   	push   %edi
  801960:	56                   	push   %esi
  801961:	53                   	push   %ebx
  801962:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801968:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80196d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801973:	eb 2d                	jmp    8019a2 <devcons_write+0x46>
		m = n - tot;
  801975:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801978:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80197a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80197d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801982:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801985:	83 ec 04             	sub    $0x4,%esp
  801988:	53                   	push   %ebx
  801989:	03 45 0c             	add    0xc(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	57                   	push   %edi
  80198e:	e8 e3 ef ff ff       	call   800976 <memmove>
		sys_cputs(buf, m);
  801993:	83 c4 08             	add    $0x8,%esp
  801996:	53                   	push   %ebx
  801997:	57                   	push   %edi
  801998:	e8 8e f1 ff ff       	call   800b2b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80199d:	01 de                	add    %ebx,%esi
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	89 f0                	mov    %esi,%eax
  8019a4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019a7:	72 cc                	jb     801975 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5e                   	pop    %esi
  8019ae:	5f                   	pop    %edi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019c0:	74 2a                	je     8019ec <devcons_read+0x3b>
  8019c2:	eb 05                	jmp    8019c9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019c4:	e8 ff f1 ff ff       	call   800bc8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019c9:	e8 7b f1 ff ff       	call   800b49 <sys_cgetc>
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	74 f2                	je     8019c4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	78 16                	js     8019ec <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019d6:	83 f8 04             	cmp    $0x4,%eax
  8019d9:	74 0c                	je     8019e7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019de:	88 02                	mov    %al,(%edx)
	return 1;
  8019e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e5:	eb 05                	jmp    8019ec <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019fa:	6a 01                	push   $0x1
  8019fc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019ff:	50                   	push   %eax
  801a00:	e8 26 f1 ff ff       	call   800b2b <sys_cputs>
}
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <getchar>:

int
getchar(void)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a10:	6a 01                	push   $0x1
  801a12:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a15:	50                   	push   %eax
  801a16:	6a 00                	push   $0x0
  801a18:	e8 97 f6 ff ff       	call   8010b4 <read>
	if (r < 0)
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 0f                	js     801a33 <getchar+0x29>
		return r;
	if (r < 1)
  801a24:	85 c0                	test   %eax,%eax
  801a26:	7e 06                	jle    801a2e <getchar+0x24>
		return -E_EOF;
	return c;
  801a28:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a2c:	eb 05                	jmp    801a33 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a2e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3e:	50                   	push   %eax
  801a3f:	ff 75 08             	pushl  0x8(%ebp)
  801a42:	e8 07 f4 ff ff       	call   800e4e <fd_lookup>
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 11                	js     801a5f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a51:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a57:	39 10                	cmp    %edx,(%eax)
  801a59:	0f 94 c0             	sete   %al
  801a5c:	0f b6 c0             	movzbl %al,%eax
}
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <opencons>:

int
opencons(void)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6a:	50                   	push   %eax
  801a6b:	e8 8f f3 ff ff       	call   800dff <fd_alloc>
  801a70:	83 c4 10             	add    $0x10,%esp
		return r;
  801a73:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 3e                	js     801ab7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a79:	83 ec 04             	sub    $0x4,%esp
  801a7c:	68 07 04 00 00       	push   $0x407
  801a81:	ff 75 f4             	pushl  -0xc(%ebp)
  801a84:	6a 00                	push   $0x0
  801a86:	e8 5c f1 ff ff       	call   800be7 <sys_page_alloc>
  801a8b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a8e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 23                	js     801ab7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a94:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	50                   	push   %eax
  801aad:	e8 26 f3 ff ff       	call   800dd8 <fd2num>
  801ab2:	89 c2                	mov    %eax,%edx
  801ab4:	83 c4 10             	add    $0x10,%esp
}
  801ab7:	89 d0                	mov    %edx,%eax
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	56                   	push   %esi
  801abf:	53                   	push   %ebx
  801ac0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ac3:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	ff 75 0c             	pushl  0xc(%ebp)
  801acc:	e8 c6 f2 ff ff       	call   800d97 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 f6                	test   %esi,%esi
  801ad6:	74 1c                	je     801af4 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801ad8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801add:	8b 40 78             	mov    0x78(%eax),%eax
  801ae0:	89 06                	mov    %eax,(%esi)
  801ae2:	eb 10                	jmp    801af4 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	68 5a 23 80 00       	push   $0x80235a
  801aec:	e8 24 e7 ff ff       	call   800215 <cprintf>
  801af1:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801af4:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801af9:	8b 50 74             	mov    0x74(%eax),%edx
  801afc:	85 d2                	test   %edx,%edx
  801afe:	74 e4                	je     801ae4 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801b00:	85 db                	test   %ebx,%ebx
  801b02:	74 05                	je     801b09 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801b04:	8b 40 74             	mov    0x74(%eax),%eax
  801b07:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b09:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b0e:	8b 40 70             	mov    0x70(%eax),%eax

}
  801b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b14:	5b                   	pop    %ebx
  801b15:	5e                   	pop    %esi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b24:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801b2a:	85 db                	test   %ebx,%ebx
  801b2c:	75 13                	jne    801b41 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801b2e:	6a 00                	push   $0x0
  801b30:	68 00 00 c0 ee       	push   $0xeec00000
  801b35:	56                   	push   %esi
  801b36:	57                   	push   %edi
  801b37:	e8 38 f2 ff ff       	call   800d74 <sys_ipc_try_send>
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	eb 0e                	jmp    801b4f <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801b41:	ff 75 14             	pushl  0x14(%ebp)
  801b44:	53                   	push   %ebx
  801b45:	56                   	push   %esi
  801b46:	57                   	push   %edi
  801b47:	e8 28 f2 ff ff       	call   800d74 <sys_ipc_try_send>
  801b4c:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	75 d7                	jne    801b2a <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b56:	5b                   	pop    %ebx
  801b57:	5e                   	pop    %esi
  801b58:	5f                   	pop    %edi
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b66:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b69:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b6f:	8b 52 50             	mov    0x50(%edx),%edx
  801b72:	39 ca                	cmp    %ecx,%edx
  801b74:	75 0d                	jne    801b83 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b76:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b79:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b7e:	8b 40 48             	mov    0x48(%eax),%eax
  801b81:	eb 0f                	jmp    801b92 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b83:	83 c0 01             	add    $0x1,%eax
  801b86:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b8b:	75 d9                	jne    801b66 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9a:	89 d0                	mov    %edx,%eax
  801b9c:	c1 e8 16             	shr    $0x16,%eax
  801b9f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bab:	f6 c1 01             	test   $0x1,%cl
  801bae:	74 1d                	je     801bcd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb0:	c1 ea 0c             	shr    $0xc,%edx
  801bb3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bba:	f6 c2 01             	test   $0x1,%dl
  801bbd:	74 0e                	je     801bcd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bbf:	c1 ea 0c             	shr    $0xc,%edx
  801bc2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bc9:	ef 
  801bca:	0f b7 c0             	movzwl %ax,%eax
}
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    
  801bcf:	90                   	nop

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801be7:	85 f6                	test   %esi,%esi
  801be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bed:	89 ca                	mov    %ecx,%edx
  801bef:	89 f8                	mov    %edi,%eax
  801bf1:	75 3d                	jne    801c30 <__udivdi3+0x60>
  801bf3:	39 cf                	cmp    %ecx,%edi
  801bf5:	0f 87 c5 00 00 00    	ja     801cc0 <__udivdi3+0xf0>
  801bfb:	85 ff                	test   %edi,%edi
  801bfd:	89 fd                	mov    %edi,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f7                	div    %edi
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 c8                	mov    %ecx,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c1                	mov    %eax,%ecx
  801c14:	89 d8                	mov    %ebx,%eax
  801c16:	89 cf                	mov    %ecx,%edi
  801c18:	f7 f5                	div    %ebp
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 74                	ja     801ca8 <__udivdi3+0xd8>
  801c34:	0f bd fe             	bsr    %esi,%edi
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	0f 84 98 00 00 00    	je     801cd8 <__udivdi3+0x108>
  801c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	89 c5                	mov    %eax,%ebp
  801c49:	29 fb                	sub    %edi,%ebx
  801c4b:	d3 e6                	shl    %cl,%esi
  801c4d:	89 d9                	mov    %ebx,%ecx
  801c4f:	d3 ed                	shr    %cl,%ebp
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	09 ee                	or     %ebp,%esi
  801c57:	89 d9                	mov    %ebx,%ecx
  801c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5d:	89 d5                	mov    %edx,%ebp
  801c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c63:	d3 ed                	shr    %cl,%ebp
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 d9                	mov    %ebx,%ecx
  801c6b:	d3 e8                	shr    %cl,%eax
  801c6d:	09 c2                	or     %eax,%edx
  801c6f:	89 d0                	mov    %edx,%eax
  801c71:	89 ea                	mov    %ebp,%edx
  801c73:	f7 f6                	div    %esi
  801c75:	89 d5                	mov    %edx,%ebp
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	f7 64 24 0c          	mull   0xc(%esp)
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	72 10                	jb     801c91 <__udivdi3+0xc1>
  801c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	39 c6                	cmp    %eax,%esi
  801c8b:	73 07                	jae    801c94 <__udivdi3+0xc4>
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	75 03                	jne    801c94 <__udivdi3+0xc4>
  801c91:	83 eb 01             	sub    $0x1,%ebx
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	89 fa                	mov    %edi,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	31 ff                	xor    %edi,%edi
  801caa:	31 db                	xor    %ebx,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	72 0c                	jb     801ce8 <__udivdi3+0x118>
  801cdc:	31 db                	xor    %ebx,%ebx
  801cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce2:	0f 87 34 ff ff ff    	ja     801c1c <__udivdi3+0x4c>
  801ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ced:	e9 2a ff ff ff       	jmp    801c1c <__udivdi3+0x4c>
  801cf2:	66 90                	xchg   %ax,%ax
  801cf4:	66 90                	xchg   %ax,%ax
  801cf6:	66 90                	xchg   %ax,%ax
  801cf8:	66 90                	xchg   %ax,%ax
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	85 d2                	test   %edx,%edx
  801d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f3                	mov    %esi,%ebx
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2a:	75 1c                	jne    801d48 <__umoddi3+0x48>
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	76 50                	jbe    801d80 <__umoddi3+0x80>
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	f7 f7                	div    %edi
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	31 d2                	xor    %edx,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	77 52                	ja     801da0 <__umoddi3+0xa0>
  801d4e:	0f bd ea             	bsr    %edx,%ebp
  801d51:	83 f5 1f             	xor    $0x1f,%ebp
  801d54:	75 5a                	jne    801db0 <__umoddi3+0xb0>
  801d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d5a:	0f 82 e0 00 00 00    	jb     801e40 <__umoddi3+0x140>
  801d60:	39 0c 24             	cmp    %ecx,(%esp)
  801d63:	0f 86 d7 00 00 00    	jbe    801e40 <__umoddi3+0x140>
  801d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	85 ff                	test   %edi,%edi
  801d82:	89 fd                	mov    %edi,%ebp
  801d84:	75 0b                	jne    801d91 <__umoddi3+0x91>
  801d86:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f7                	div    %edi
  801d8f:	89 c5                	mov    %eax,%ebp
  801d91:	89 f0                	mov    %esi,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f5                	div    %ebp
  801d97:	89 c8                	mov    %ecx,%eax
  801d99:	f7 f5                	div    %ebp
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	eb 99                	jmp    801d38 <__umoddi3+0x38>
  801d9f:	90                   	nop
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	83 c4 1c             	add    $0x1c,%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5f                   	pop    %edi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    
  801dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db0:	8b 34 24             	mov    (%esp),%esi
  801db3:	bf 20 00 00 00       	mov    $0x20,%edi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	29 ef                	sub    %ebp,%edi
  801dbc:	d3 e0                	shl    %cl,%eax
  801dbe:	89 f9                	mov    %edi,%ecx
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	d3 ea                	shr    %cl,%edx
  801dc4:	89 e9                	mov    %ebp,%ecx
  801dc6:	09 c2                	or     %eax,%edx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 14 24             	mov    %edx,(%esp)
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	d3 e2                	shl    %cl,%edx
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ddb:	d3 e8                	shr    %cl,%eax
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	d3 e3                	shl    %cl,%ebx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	09 d8                	or     %ebx,%eax
  801ded:	89 d3                	mov    %edx,%ebx
  801def:	89 f2                	mov    %esi,%edx
  801df1:	f7 34 24             	divl   (%esp)
  801df4:	89 d6                	mov    %edx,%esi
  801df6:	d3 e3                	shl    %cl,%ebx
  801df8:	f7 64 24 04          	mull   0x4(%esp)
  801dfc:	39 d6                	cmp    %edx,%esi
  801dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e02:	89 d1                	mov    %edx,%ecx
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	72 08                	jb     801e10 <__umoddi3+0x110>
  801e08:	75 11                	jne    801e1b <__umoddi3+0x11b>
  801e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e0e:	73 0b                	jae    801e1b <__umoddi3+0x11b>
  801e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e14:	1b 14 24             	sbb    (%esp),%edx
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 c3                	mov    %eax,%ebx
  801e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e1f:	29 da                	sub    %ebx,%edx
  801e21:	19 ce                	sbb    %ecx,%esi
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	d3 e0                	shl    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	d3 ea                	shr    %cl,%edx
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	d3 ee                	shr    %cl,%esi
  801e31:	09 d0                	or     %edx,%eax
  801e33:	89 f2                	mov    %esi,%edx
  801e35:	83 c4 1c             	add    $0x1c,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	29 f9                	sub    %edi,%ecx
  801e42:	19 d6                	sbb    %edx,%esi
  801e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e4c:	e9 18 ff ff ff       	jmp    801d69 <__umoddi3+0x69>
