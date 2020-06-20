
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 98 11 00 00       	call   8011e5 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 e0 1f 80 00       	push   $0x801fe0
  800060:	6a 0d                	push   $0xd
  800062:	68 fb 1f 80 00       	push   $0x801ffb
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 8c 10 00 00       	call   80110b <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 06 20 80 00       	push   $0x802006
  800098:	6a 0f                	push   $0xf
  80009a:	68 fb 1f 80 00       	push   $0x801ffb
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 1b 	movl   $0x80201b,0x803000
  8000be:	20 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 1f 20 80 00       	push   $0x80201f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 a2 14 00 00       	call   80158f <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 27 20 80 00       	push   $0x802027
  800102:	e8 26 16 00 00       	call   80172d <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 af 0e 00 00       	call   800fcf <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  80013e:	e8 bd 0a 00 00       	call   800c00 <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 76 0e 00 00       	call   800ffa <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 31 0a 00 00       	call   800bbf <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 5a 0a 00 00       	call   800c00 <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 44 20 80 00       	push   $0x802044
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 67 24 80 00 	movl   $0x802467,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 79 09 00 00       	call   800b82 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 54 01 00 00       	call   8003a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 1e 09 00 00       	call   800b82 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 6c 1a 00 00       	call   801d40 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 59 1b 00 00       	call   801e70 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 67 20 80 00 	movsbl 0x802067(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800332:	83 fa 01             	cmp    $0x1,%edx
  800335:	7e 0e                	jle    800345 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	8b 52 04             	mov    0x4(%edx),%edx
  800343:	eb 22                	jmp    800367 <getuint+0x38>
	else if (lflag)
  800345:	85 d2                	test   %edx,%edx
  800347:	74 10                	je     800359 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034e:	89 08                	mov    %ecx,(%eax)
  800350:	8b 02                	mov    (%edx),%eax
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	eb 0e                	jmp    800367 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 0a                	jae    800384 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	88 02                	mov    %al,(%edx)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	50                   	push   %eax
  800390:	ff 75 10             	pushl  0x10(%ebp)
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 05 00 00 00       	call   8003a3 <vprintfmt>
	va_end(ap);
}
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
  8003ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 d3 03 00 00    	je     800792 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	50                   	push   %eax
  8003c4:	ff d6                	call   *%esi
  8003c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	83 c7 01             	add    $0x1,%edi
  8003cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d0:	83 f8 25             	cmp    $0x25,%eax
  8003d3:	75 e2                	jne    8003b7 <vprintfmt+0x14>
  8003d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e0:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	eb 07                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8d 47 01             	lea    0x1(%edi),%eax
  8003ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800402:	0f b6 07             	movzbl (%edi),%eax
  800405:	0f b6 c8             	movzbl %al,%ecx
  800408:	83 e8 23             	sub    $0x23,%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 64 03 00 00    	ja     800777 <vprintfmt+0x3d4>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	ff 24 85 a0 21 80 00 	jmp    *0x8021a0(,%eax,4)
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800424:	eb d6                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800431:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800434:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800438:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043e:	83 fa 09             	cmp    $0x9,%edx
  800441:	77 39                	ja     80047c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb e9                	jmp    800431 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 48 04             	lea    0x4(%eax),%ecx
  80044e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800451:	8b 00                	mov    (%eax),%eax
  800453:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800459:	eb 27                	jmp    800482 <vprintfmt+0xdf>
  80045b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045e:	85 c0                	test   %eax,%eax
  800460:	b9 00 00 00 00       	mov    $0x0,%ecx
  800465:	0f 49 c8             	cmovns %eax,%ecx
  800468:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	eb 8c                	jmp    8003fc <vprintfmt+0x59>
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800473:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047a:	eb 80                	jmp    8003fc <vprintfmt+0x59>
  80047c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047f:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800482:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800486:	0f 89 70 ff ff ff    	jns    8003fc <vprintfmt+0x59>
				width = precision, precision = -1;
  80048c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800499:	e9 5e ff ff ff       	jmp    8003fc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a4:	e9 53 ff ff ff       	jmp    8003fc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	ff 30                	pushl  (%eax)
  8004b8:	ff d6                	call   *%esi
			break;
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c0:	e9 04 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	99                   	cltd   
  8004d1:	31 d0                	xor    %edx,%eax
  8004d3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 0f             	cmp    $0xf,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x142>
  8004da:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	75 18                	jne    8004fd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	50                   	push   %eax
  8004e6:	68 7f 20 80 00       	push   $0x80207f
  8004eb:	53                   	push   %ebx
  8004ec:	56                   	push   %esi
  8004ed:	e8 94 fe ff ff       	call   800386 <printfmt>
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f8:	e9 cc fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fd:	52                   	push   %edx
  8004fe:	68 35 24 80 00       	push   $0x802435
  800503:	53                   	push   %ebx
  800504:	56                   	push   %esi
  800505:	e8 7c fe ff ff       	call   800386 <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800510:	e9 b4 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800520:	85 ff                	test   %edi,%edi
  800522:	b8 78 20 80 00       	mov    $0x802078,%eax
  800527:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 8e 94 00 00 00    	jle    8005c8 <vprintfmt+0x225>
  800534:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800538:	0f 84 98 00 00 00    	je     8005d6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 c8             	pushl  -0x38(%ebp)
  800544:	57                   	push   %edi
  800545:	e8 d0 02 00 00       	call   80081a <strnlen>
  80054a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800555:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	eb 0f                	jmp    800572 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 75 e0             	pushl  -0x20(%ebp)
  80056a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ed                	jg     800563 <vprintfmt+0x1c0>
  800576:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800579:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	b8 00 00 00 00       	mov    $0x0,%eax
  800583:	0f 49 c1             	cmovns %ecx,%eax
  800586:	29 c1                	sub    %eax,%ecx
  800588:	89 75 08             	mov    %esi,0x8(%ebp)
  80058b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80058e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800591:	89 cb                	mov    %ecx,%ebx
  800593:	eb 4d                	jmp    8005e2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	74 1b                	je     8005b6 <vprintfmt+0x213>
  80059b:	0f be c0             	movsbl %al,%eax
  80059e:	83 e8 20             	sub    $0x20,%eax
  8005a1:	83 f8 5e             	cmp    $0x5e,%eax
  8005a4:	76 10                	jbe    8005b6 <vprintfmt+0x213>
					putch('?', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	6a 3f                	push   $0x3f
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	eb 0d                	jmp    8005c3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	ff 75 0c             	pushl  0xc(%ebp)
  8005bc:	52                   	push   %edx
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c3:	83 eb 01             	sub    $0x1,%ebx
  8005c6:	eb 1a                	jmp    8005e2 <vprintfmt+0x23f>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	eb 0c                	jmp    8005e2 <vprintfmt+0x23f>
  8005d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e2:	83 c7 01             	add    $0x1,%edi
  8005e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e9:	0f be d0             	movsbl %al,%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	74 23                	je     800613 <vprintfmt+0x270>
  8005f0:	85 f6                	test   %esi,%esi
  8005f2:	78 a1                	js     800595 <vprintfmt+0x1f2>
  8005f4:	83 ee 01             	sub    $0x1,%esi
  8005f7:	79 9c                	jns    800595 <vprintfmt+0x1f2>
  8005f9:	89 df                	mov    %ebx,%edi
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800601:	eb 18                	jmp    80061b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 20                	push   $0x20
  800609:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 08                	jmp    80061b <vprintfmt+0x278>
  800613:	89 df                	mov    %ebx,%edi
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061b:	85 ff                	test   %edi,%edi
  80061d:	7f e4                	jg     800603 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800622:	e9 a2 fd ff ff       	jmp    8003c9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 fa 01             	cmp    $0x1,%edx
  80062a:	7e 16                	jle    800642 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80063d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800640:	eb 32                	jmp    800674 <vprintfmt+0x2d1>
	else if (lflag)
  800642:	85 d2                	test   %edx,%edx
  800644:	74 18                	je     80065e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800654:	89 c1                	mov    %eax,%ecx
  800656:	c1 f9 1f             	sar    $0x1f,%ecx
  800659:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80066c:	89 c1                	mov    %eax,%ecx
  80066e:	c1 f9 1f             	sar    $0x1f,%ecx
  800671:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800674:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800677:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80067a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800680:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800685:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800689:	0f 89 b0 00 00 00    	jns    80073f <vprintfmt+0x39c>
				putch('-', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 2d                	push   $0x2d
  800695:	ff d6                	call   *%esi
				num = -(long long) num;
  800697:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80069a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80069d:	f7 d8                	neg    %eax
  80069f:	83 d2 00             	adc    $0x0,%edx
  8006a2:	f7 da                	neg    %edx
  8006a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006aa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b2:	e9 88 00 00 00       	jmp    80073f <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ba:	e8 70 fc ff ff       	call   80032f <getuint>
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006ca:	eb 73                	jmp    80073f <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cf:	e8 5b fc ff ff       	call   80032f <getuint>
  8006d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 58                	push   $0x58
  8006e0:	ff d6                	call   *%esi
			putch('X', putdat);
  8006e2:	83 c4 08             	add    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 58                	push   $0x58
  8006e8:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 58                	push   $0x58
  8006f0:	ff d6                	call   *%esi
			goto number;
  8006f2:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8006f5:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006fa:	eb 43                	jmp    80073f <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	6a 30                	push   $0x30
  800702:	ff d6                	call   *%esi
			putch('x', putdat);
  800704:	83 c4 08             	add    $0x8,%esp
  800707:	53                   	push   %ebx
  800708:	6a 78                	push   $0x78
  80070a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8d 50 04             	lea    0x4(%eax),%edx
  800712:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800715:	8b 00                	mov    (%eax),%eax
  800717:	ba 00 00 00 00       	mov    $0x0,%edx
  80071c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800722:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800725:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80072a:	eb 13                	jmp    80073f <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
  80072f:	e8 fb fb ff ff       	call   80032f <getuint>
  800734:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800737:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80073a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073f:	83 ec 0c             	sub    $0xc,%esp
  800742:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800746:	52                   	push   %edx
  800747:	ff 75 e0             	pushl  -0x20(%ebp)
  80074a:	50                   	push   %eax
  80074b:	ff 75 dc             	pushl  -0x24(%ebp)
  80074e:	ff 75 d8             	pushl  -0x28(%ebp)
  800751:	89 da                	mov    %ebx,%edx
  800753:	89 f0                	mov    %esi,%eax
  800755:	e8 26 fb ff ff       	call   800280 <printnum>
			break;
  80075a:	83 c4 20             	add    $0x20,%esp
  80075d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800760:	e9 64 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	51                   	push   %ecx
  80076a:	ff d6                	call   *%esi
			break;
  80076c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800772:	e9 52 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	6a 25                	push   $0x25
  80077d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	eb 03                	jmp    800787 <vprintfmt+0x3e4>
  800784:	83 ef 01             	sub    $0x1,%edi
  800787:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80078b:	75 f7                	jne    800784 <vprintfmt+0x3e1>
  80078d:	e9 37 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800792:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5f                   	pop    %edi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 18             	sub    $0x18,%esp
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	74 26                	je     8007e1 <vsnprintf+0x47>
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	7e 22                	jle    8007e1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bf:	ff 75 14             	pushl  0x14(%ebp)
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	68 69 03 80 00       	push   $0x800369
  8007ce:	e8 d0 fb ff ff       	call   8003a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	eb 05                	jmp    8007e6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f1:	50                   	push   %eax
  8007f2:	ff 75 10             	pushl  0x10(%ebp)
  8007f5:	ff 75 0c             	pushl  0xc(%ebp)
  8007f8:	ff 75 08             	pushl  0x8(%ebp)
  8007fb:	e8 9a ff ff ff       	call   80079a <vsnprintf>
	va_end(ap);

	return rc;
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
  80080d:	eb 03                	jmp    800812 <strlen+0x10>
		n++;
  80080f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800812:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800816:	75 f7                	jne    80080f <strlen+0xd>
		n++;
	return n;
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800820:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800823:	ba 00 00 00 00       	mov    $0x0,%edx
  800828:	eb 03                	jmp    80082d <strnlen+0x13>
		n++;
  80082a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	74 08                	je     800839 <strnlen+0x1f>
  800831:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800835:	75 f3                	jne    80082a <strnlen+0x10>
  800837:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800845:	89 c2                	mov    %eax,%edx
  800847:	83 c2 01             	add    $0x1,%edx
  80084a:	83 c1 01             	add    $0x1,%ecx
  80084d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800851:	88 5a ff             	mov    %bl,-0x1(%edx)
  800854:	84 db                	test   %bl,%bl
  800856:	75 ef                	jne    800847 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800862:	53                   	push   %ebx
  800863:	e8 9a ff ff ff       	call   800802 <strlen>
  800868:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80086b:	ff 75 0c             	pushl  0xc(%ebp)
  80086e:	01 d8                	add    %ebx,%eax
  800870:	50                   	push   %eax
  800871:	e8 c5 ff ff ff       	call   80083b <strcpy>
	return dst;
}
  800876:	89 d8                	mov    %ebx,%eax
  800878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
  800882:	8b 75 08             	mov    0x8(%ebp),%esi
  800885:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800888:	89 f3                	mov    %esi,%ebx
  80088a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088d:	89 f2                	mov    %esi,%edx
  80088f:	eb 0f                	jmp    8008a0 <strncpy+0x23>
		*dst++ = *src;
  800891:	83 c2 01             	add    $0x1,%edx
  800894:	0f b6 01             	movzbl (%ecx),%eax
  800897:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089a:	80 39 01             	cmpb   $0x1,(%ecx)
  80089d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a0:	39 da                	cmp    %ebx,%edx
  8008a2:	75 ed                	jne    800891 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a4:	89 f0                	mov    %esi,%eax
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b5:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ba:	85 d2                	test   %edx,%edx
  8008bc:	74 21                	je     8008df <strlcpy+0x35>
  8008be:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c2:	89 f2                	mov    %esi,%edx
  8008c4:	eb 09                	jmp    8008cf <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c6:	83 c2 01             	add    $0x1,%edx
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cf:	39 c2                	cmp    %eax,%edx
  8008d1:	74 09                	je     8008dc <strlcpy+0x32>
  8008d3:	0f b6 19             	movzbl (%ecx),%ebx
  8008d6:	84 db                	test   %bl,%bl
  8008d8:	75 ec                	jne    8008c6 <strlcpy+0x1c>
  8008da:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008dc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008df:	29 f0                	sub    %esi,%eax
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ee:	eb 06                	jmp    8008f6 <strcmp+0x11>
		p++, q++;
  8008f0:	83 c1 01             	add    $0x1,%ecx
  8008f3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f6:	0f b6 01             	movzbl (%ecx),%eax
  8008f9:	84 c0                	test   %al,%al
  8008fb:	74 04                	je     800901 <strcmp+0x1c>
  8008fd:	3a 02                	cmp    (%edx),%al
  8008ff:	74 ef                	je     8008f0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800901:	0f b6 c0             	movzbl %al,%eax
  800904:	0f b6 12             	movzbl (%edx),%edx
  800907:	29 d0                	sub    %edx,%eax
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
  800915:	89 c3                	mov    %eax,%ebx
  800917:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091a:	eb 06                	jmp    800922 <strncmp+0x17>
		n--, p++, q++;
  80091c:	83 c0 01             	add    $0x1,%eax
  80091f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800922:	39 d8                	cmp    %ebx,%eax
  800924:	74 15                	je     80093b <strncmp+0x30>
  800926:	0f b6 08             	movzbl (%eax),%ecx
  800929:	84 c9                	test   %cl,%cl
  80092b:	74 04                	je     800931 <strncmp+0x26>
  80092d:	3a 0a                	cmp    (%edx),%cl
  80092f:	74 eb                	je     80091c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800931:	0f b6 00             	movzbl (%eax),%eax
  800934:	0f b6 12             	movzbl (%edx),%edx
  800937:	29 d0                	sub    %edx,%eax
  800939:	eb 05                	jmp    800940 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800940:	5b                   	pop    %ebx
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094d:	eb 07                	jmp    800956 <strchr+0x13>
		if (*s == c)
  80094f:	38 ca                	cmp    %cl,%dl
  800951:	74 0f                	je     800962 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	0f b6 10             	movzbl (%eax),%edx
  800959:	84 d2                	test   %dl,%dl
  80095b:	75 f2                	jne    80094f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096e:	eb 03                	jmp    800973 <strfind+0xf>
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800976:	38 ca                	cmp    %cl,%dl
  800978:	74 04                	je     80097e <strfind+0x1a>
  80097a:	84 d2                	test   %dl,%dl
  80097c:	75 f2                	jne    800970 <strfind+0xc>
			break;
	return (char *) s;
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	57                   	push   %edi
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	8b 7d 08             	mov    0x8(%ebp),%edi
  800989:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098c:	85 c9                	test   %ecx,%ecx
  80098e:	74 36                	je     8009c6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800990:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800996:	75 28                	jne    8009c0 <memset+0x40>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 23                	jne    8009c0 <memset+0x40>
		c &= 0xFF;
  80099d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a1:	89 d3                	mov    %edx,%ebx
  8009a3:	c1 e3 08             	shl    $0x8,%ebx
  8009a6:	89 d6                	mov    %edx,%esi
  8009a8:	c1 e6 18             	shl    $0x18,%esi
  8009ab:	89 d0                	mov    %edx,%eax
  8009ad:	c1 e0 10             	shl    $0x10,%eax
  8009b0:	09 f0                	or     %esi,%eax
  8009b2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009b4:	89 d8                	mov    %ebx,%eax
  8009b6:	09 d0                	or     %edx,%eax
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
  8009bb:	fc                   	cld    
  8009bc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009be:	eb 06                	jmp    8009c6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	fc                   	cld    
  8009c4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c6:	89 f8                	mov    %edi,%eax
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5f                   	pop    %edi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	57                   	push   %edi
  8009d1:	56                   	push   %esi
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009db:	39 c6                	cmp    %eax,%esi
  8009dd:	73 35                	jae    800a14 <memmove+0x47>
  8009df:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e2:	39 d0                	cmp    %edx,%eax
  8009e4:	73 2e                	jae    800a14 <memmove+0x47>
		s += n;
		d += n;
  8009e6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e9:	89 d6                	mov    %edx,%esi
  8009eb:	09 fe                	or     %edi,%esi
  8009ed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f3:	75 13                	jne    800a08 <memmove+0x3b>
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 0e                	jne    800a08 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009fa:	83 ef 04             	sub    $0x4,%edi
  8009fd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a00:	c1 e9 02             	shr    $0x2,%ecx
  800a03:	fd                   	std    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb 09                	jmp    800a11 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a08:	83 ef 01             	sub    $0x1,%edi
  800a0b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a0e:	fd                   	std    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a11:	fc                   	cld    
  800a12:	eb 1d                	jmp    800a31 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	89 f2                	mov    %esi,%edx
  800a16:	09 c2                	or     %eax,%edx
  800a18:	f6 c2 03             	test   $0x3,%dl
  800a1b:	75 0f                	jne    800a2c <memmove+0x5f>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 0a                	jne    800a2c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a22:	c1 e9 02             	shr    $0x2,%ecx
  800a25:	89 c7                	mov    %eax,%edi
  800a27:	fc                   	cld    
  800a28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2a:	eb 05                	jmp    800a31 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2c:	89 c7                	mov    %eax,%edi
  800a2e:	fc                   	cld    
  800a2f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a38:	ff 75 10             	pushl  0x10(%ebp)
  800a3b:	ff 75 0c             	pushl  0xc(%ebp)
  800a3e:	ff 75 08             	pushl  0x8(%ebp)
  800a41:	e8 87 ff ff ff       	call   8009cd <memmove>
}
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a53:	89 c6                	mov    %eax,%esi
  800a55:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a58:	eb 1a                	jmp    800a74 <memcmp+0x2c>
		if (*s1 != *s2)
  800a5a:	0f b6 08             	movzbl (%eax),%ecx
  800a5d:	0f b6 1a             	movzbl (%edx),%ebx
  800a60:	38 d9                	cmp    %bl,%cl
  800a62:	74 0a                	je     800a6e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a64:	0f b6 c1             	movzbl %cl,%eax
  800a67:	0f b6 db             	movzbl %bl,%ebx
  800a6a:	29 d8                	sub    %ebx,%eax
  800a6c:	eb 0f                	jmp    800a7d <memcmp+0x35>
		s1++, s2++;
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a74:	39 f0                	cmp    %esi,%eax
  800a76:	75 e2                	jne    800a5a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a88:	89 c1                	mov    %eax,%ecx
  800a8a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a91:	eb 0a                	jmp    800a9d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a93:	0f b6 10             	movzbl (%eax),%edx
  800a96:	39 da                	cmp    %ebx,%edx
  800a98:	74 07                	je     800aa1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	39 c8                	cmp    %ecx,%eax
  800a9f:	72 f2                	jb     800a93 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab0:	eb 03                	jmp    800ab5 <strtol+0x11>
		s++;
  800ab2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab5:	0f b6 01             	movzbl (%ecx),%eax
  800ab8:	3c 20                	cmp    $0x20,%al
  800aba:	74 f6                	je     800ab2 <strtol+0xe>
  800abc:	3c 09                	cmp    $0x9,%al
  800abe:	74 f2                	je     800ab2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac0:	3c 2b                	cmp    $0x2b,%al
  800ac2:	75 0a                	jne    800ace <strtol+0x2a>
		s++;
  800ac4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
  800acc:	eb 11                	jmp    800adf <strtol+0x3b>
  800ace:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad3:	3c 2d                	cmp    $0x2d,%al
  800ad5:	75 08                	jne    800adf <strtol+0x3b>
		s++, neg = 1;
  800ad7:	83 c1 01             	add    $0x1,%ecx
  800ada:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800adf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae5:	75 15                	jne    800afc <strtol+0x58>
  800ae7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aea:	75 10                	jne    800afc <strtol+0x58>
  800aec:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af0:	75 7c                	jne    800b6e <strtol+0xca>
		s += 2, base = 16;
  800af2:	83 c1 02             	add    $0x2,%ecx
  800af5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800afa:	eb 16                	jmp    800b12 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800afc:	85 db                	test   %ebx,%ebx
  800afe:	75 12                	jne    800b12 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b00:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b05:	80 39 30             	cmpb   $0x30,(%ecx)
  800b08:	75 08                	jne    800b12 <strtol+0x6e>
		s++, base = 8;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b1a:	0f b6 11             	movzbl (%ecx),%edx
  800b1d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b20:	89 f3                	mov    %esi,%ebx
  800b22:	80 fb 09             	cmp    $0x9,%bl
  800b25:	77 08                	ja     800b2f <strtol+0x8b>
			dig = *s - '0';
  800b27:	0f be d2             	movsbl %dl,%edx
  800b2a:	83 ea 30             	sub    $0x30,%edx
  800b2d:	eb 22                	jmp    800b51 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b32:	89 f3                	mov    %esi,%ebx
  800b34:	80 fb 19             	cmp    $0x19,%bl
  800b37:	77 08                	ja     800b41 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b39:	0f be d2             	movsbl %dl,%edx
  800b3c:	83 ea 57             	sub    $0x57,%edx
  800b3f:	eb 10                	jmp    800b51 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b41:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b44:	89 f3                	mov    %esi,%ebx
  800b46:	80 fb 19             	cmp    $0x19,%bl
  800b49:	77 16                	ja     800b61 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b4b:	0f be d2             	movsbl %dl,%edx
  800b4e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b51:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b54:	7d 0b                	jge    800b61 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b56:	83 c1 01             	add    $0x1,%ecx
  800b59:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5f:	eb b9                	jmp    800b1a <strtol+0x76>

	if (endptr)
  800b61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b65:	74 0d                	je     800b74 <strtol+0xd0>
		*endptr = (char *) s;
  800b67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6a:	89 0e                	mov    %ecx,(%esi)
  800b6c:	eb 06                	jmp    800b74 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6e:	85 db                	test   %ebx,%ebx
  800b70:	74 98                	je     800b0a <strtol+0x66>
  800b72:	eb 9e                	jmp    800b12 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b74:	89 c2                	mov    %eax,%edx
  800b76:	f7 da                	neg    %edx
  800b78:	85 ff                	test   %edi,%edi
  800b7a:	0f 45 c2             	cmovne %edx,%eax
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b88:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 c3                	mov    %eax,%ebx
  800b95:	89 c7                	mov    %eax,%edi
  800b97:	89 c6                	mov    %eax,%esi
  800b99:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bab:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb0:	89 d1                	mov    %edx,%ecx
  800bb2:	89 d3                	mov    %edx,%ebx
  800bb4:	89 d7                	mov    %edx,%edi
  800bb6:	89 d6                	mov    %edx,%esi
  800bb8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	89 cb                	mov    %ecx,%ebx
  800bd7:	89 cf                	mov    %ecx,%edi
  800bd9:	89 ce                	mov    %ecx,%esi
  800bdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 03                	push   $0x3
  800be7:	68 5f 23 80 00       	push   $0x80235f
  800bec:	6a 23                	push   $0x23
  800bee:	68 7c 23 80 00       	push   $0x80237c
  800bf3:	e8 9b f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c06:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c10:	89 d1                	mov    %edx,%ecx
  800c12:	89 d3                	mov    %edx,%ebx
  800c14:	89 d7                	mov    %edx,%edi
  800c16:	89 d6                	mov    %edx,%esi
  800c18:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_yield>:

void
sys_yield(void)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2f:	89 d1                	mov    %edx,%ecx
  800c31:	89 d3                	mov    %edx,%ebx
  800c33:	89 d7                	mov    %edx,%edi
  800c35:	89 d6                	mov    %edx,%esi
  800c37:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c47:	be 00 00 00 00       	mov    $0x0,%esi
  800c4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5a:	89 f7                	mov    %esi,%edi
  800c5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7e 17                	jle    800c79 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	50                   	push   %eax
  800c66:	6a 04                	push   $0x4
  800c68:	68 5f 23 80 00       	push   $0x80235f
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 7c 23 80 00       	push   $0x80237c
  800c74:	e8 1a f5 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 17                	jle    800cbb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 05                	push   $0x5
  800caa:	68 5f 23 80 00       	push   $0x80235f
  800caf:	6a 23                	push   $0x23
  800cb1:	68 7c 23 80 00       	push   $0x80237c
  800cb6:	e8 d8 f4 ff ff       	call   800193 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 06                	push   $0x6
  800cec:	68 5f 23 80 00       	push   $0x80235f
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 7c 23 80 00       	push   $0x80237c
  800cf8:	e8 96 f4 ff ff       	call   800193 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d13:	b8 08 00 00 00       	mov    $0x8,%eax
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 df                	mov    %ebx,%edi
  800d20:	89 de                	mov    %ebx,%esi
  800d22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 08                	push   $0x8
  800d2e:	68 5f 23 80 00       	push   $0x80235f
  800d33:	6a 23                	push   $0x23
  800d35:	68 7c 23 80 00       	push   $0x80237c
  800d3a:	e8 54 f4 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 17                	jle    800d81 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	50                   	push   %eax
  800d6e:	6a 09                	push   $0x9
  800d70:	68 5f 23 80 00       	push   $0x80235f
  800d75:	6a 23                	push   $0x23
  800d77:	68 7c 23 80 00       	push   $0x80237c
  800d7c:	e8 12 f4 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 17                	jle    800dc3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	50                   	push   %eax
  800db0:	6a 0a                	push   $0xa
  800db2:	68 5f 23 80 00       	push   $0x80235f
  800db7:	6a 23                	push   $0x23
  800db9:	68 7c 23 80 00       	push   $0x80237c
  800dbe:	e8 d0 f3 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dd1:	be 00 00 00 00       	mov    $0x0,%esi
  800dd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800df7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	89 cb                	mov    %ecx,%ebx
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	89 ce                	mov    %ecx,%esi
  800e0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 17                	jle    800e27 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	50                   	push   %eax
  800e14:	6a 0d                	push   $0xd
  800e16:	68 5f 23 80 00       	push   $0x80235f
  800e1b:	6a 23                	push   $0x23
  800e1d:	68 7c 23 80 00       	push   $0x80237c
  800e22:	e8 6c f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e4f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	c1 ea 16             	shr    $0x16,%edx
  800e66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6d:	f6 c2 01             	test   $0x1,%dl
  800e70:	74 11                	je     800e83 <fd_alloc+0x2d>
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	c1 ea 0c             	shr    $0xc,%edx
  800e77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7e:	f6 c2 01             	test   $0x1,%dl
  800e81:	75 09                	jne    800e8c <fd_alloc+0x36>
			*fd_store = fd;
  800e83:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e85:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8a:	eb 17                	jmp    800ea3 <fd_alloc+0x4d>
  800e8c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e91:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e96:	75 c9                	jne    800e61 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e98:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e9e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eab:	83 f8 1f             	cmp    $0x1f,%eax
  800eae:	77 36                	ja     800ee6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb0:	c1 e0 0c             	shl    $0xc,%eax
  800eb3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	c1 ea 16             	shr    $0x16,%edx
  800ebd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec4:	f6 c2 01             	test   $0x1,%dl
  800ec7:	74 24                	je     800eed <fd_lookup+0x48>
  800ec9:	89 c2                	mov    %eax,%edx
  800ecb:	c1 ea 0c             	shr    $0xc,%edx
  800ece:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed5:	f6 c2 01             	test   $0x1,%dl
  800ed8:	74 1a                	je     800ef4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edd:	89 02                	mov    %eax,(%edx)
	return 0;
  800edf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee4:	eb 13                	jmp    800ef9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eeb:	eb 0c                	jmp    800ef9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef2:	eb 05                	jmp    800ef9 <fd_lookup+0x54>
  800ef4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f04:	ba 0c 24 80 00       	mov    $0x80240c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f09:	eb 13                	jmp    800f1e <dev_lookup+0x23>
  800f0b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f0e:	39 08                	cmp    %ecx,(%eax)
  800f10:	75 0c                	jne    800f1e <dev_lookup+0x23>
			*dev = devtab[i];
  800f12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f15:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1c:	eb 2e                	jmp    800f4c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1e:	8b 02                	mov    (%edx),%eax
  800f20:	85 c0                	test   %eax,%eax
  800f22:	75 e7                	jne    800f0b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f24:	a1 20 60 80 00       	mov    0x806020,%eax
  800f29:	8b 40 48             	mov    0x48(%eax),%eax
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	51                   	push   %ecx
  800f30:	50                   	push   %eax
  800f31:	68 8c 23 80 00       	push   $0x80238c
  800f36:	e8 31 f3 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    

00800f4e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 10             	sub    $0x10,%esp
  800f56:	8b 75 08             	mov    0x8(%ebp),%esi
  800f59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f66:	c1 e8 0c             	shr    $0xc,%eax
  800f69:	50                   	push   %eax
  800f6a:	e8 36 ff ff ff       	call   800ea5 <fd_lookup>
  800f6f:	83 c4 08             	add    $0x8,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	78 05                	js     800f7b <fd_close+0x2d>
	    || fd != fd2)
  800f76:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f79:	74 0c                	je     800f87 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7b:	84 db                	test   %bl,%bl
  800f7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f82:	0f 44 c2             	cmove  %edx,%eax
  800f85:	eb 41                	jmp    800fc8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8d:	50                   	push   %eax
  800f8e:	ff 36                	pushl  (%esi)
  800f90:	e8 66 ff ff ff       	call   800efb <dev_lookup>
  800f95:	89 c3                	mov    %eax,%ebx
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 1a                	js     800fb8 <fd_close+0x6a>
		if (dev->dev_close)
  800f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	74 0b                	je     800fb8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	56                   	push   %esi
  800fb1:	ff d0                	call   *%eax
  800fb3:	89 c3                	mov    %eax,%ebx
  800fb5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	56                   	push   %esi
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 00 fd ff ff       	call   800cc3 <sys_page_unmap>
	return r;
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	89 d8                	mov    %ebx,%eax
}
  800fc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	ff 75 08             	pushl  0x8(%ebp)
  800fdc:	e8 c4 fe ff ff       	call   800ea5 <fd_lookup>
  800fe1:	83 c4 08             	add    $0x8,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 10                	js     800ff8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	6a 01                	push   $0x1
  800fed:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff0:	e8 59 ff ff ff       	call   800f4e <fd_close>
  800ff5:	83 c4 10             	add    $0x10,%esp
}
  800ff8:	c9                   	leave  
  800ff9:	c3                   	ret    

00800ffa <close_all>:

void
close_all(void)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801001:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	53                   	push   %ebx
  80100a:	e8 c0 ff ff ff       	call   800fcf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80100f:	83 c3 01             	add    $0x1,%ebx
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	83 fb 20             	cmp    $0x20,%ebx
  801018:	75 ec                	jne    801006 <close_all+0xc>
		close(i);
}
  80101a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 2c             	sub    $0x2c,%esp
  801028:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80102e:	50                   	push   %eax
  80102f:	ff 75 08             	pushl  0x8(%ebp)
  801032:	e8 6e fe ff ff       	call   800ea5 <fd_lookup>
  801037:	83 c4 08             	add    $0x8,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	0f 88 c1 00 00 00    	js     801103 <dup+0xe4>
		return r;
	close(newfdnum);
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	56                   	push   %esi
  801046:	e8 84 ff ff ff       	call   800fcf <close>

	newfd = INDEX2FD(newfdnum);
  80104b:	89 f3                	mov    %esi,%ebx
  80104d:	c1 e3 0c             	shl    $0xc,%ebx
  801050:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801056:	83 c4 04             	add    $0x4,%esp
  801059:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105c:	e8 de fd ff ff       	call   800e3f <fd2data>
  801061:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801063:	89 1c 24             	mov    %ebx,(%esp)
  801066:	e8 d4 fd ff ff       	call   800e3f <fd2data>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801071:	89 f8                	mov    %edi,%eax
  801073:	c1 e8 16             	shr    $0x16,%eax
  801076:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107d:	a8 01                	test   $0x1,%al
  80107f:	74 37                	je     8010b8 <dup+0x99>
  801081:	89 f8                	mov    %edi,%eax
  801083:	c1 e8 0c             	shr    $0xc,%eax
  801086:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108d:	f6 c2 01             	test   $0x1,%dl
  801090:	74 26                	je     8010b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801092:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a1:	50                   	push   %eax
  8010a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a5:	6a 00                	push   $0x0
  8010a7:	57                   	push   %edi
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 d2 fb ff ff       	call   800c81 <sys_page_map>
  8010af:	89 c7                	mov    %eax,%edi
  8010b1:	83 c4 20             	add    $0x20,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 2e                	js     8010e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	c1 e8 0c             	shr    $0xc,%eax
  8010c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cf:	50                   	push   %eax
  8010d0:	53                   	push   %ebx
  8010d1:	6a 00                	push   $0x0
  8010d3:	52                   	push   %edx
  8010d4:	6a 00                	push   $0x0
  8010d6:	e8 a6 fb ff ff       	call   800c81 <sys_page_map>
  8010db:	89 c7                	mov    %eax,%edi
  8010dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e2:	85 ff                	test   %edi,%edi
  8010e4:	79 1d                	jns    801103 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e6:	83 ec 08             	sub    $0x8,%esp
  8010e9:	53                   	push   %ebx
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 d2 fb ff ff       	call   800cc3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f1:	83 c4 08             	add    $0x8,%esp
  8010f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f7:	6a 00                	push   $0x0
  8010f9:	e8 c5 fb ff ff       	call   800cc3 <sys_page_unmap>
	return r;
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	89 f8                	mov    %edi,%eax
}
  801103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801106:	5b                   	pop    %ebx
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	53                   	push   %ebx
  80110f:	83 ec 14             	sub    $0x14,%esp
  801112:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801115:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	53                   	push   %ebx
  80111a:	e8 86 fd ff ff       	call   800ea5 <fd_lookup>
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	89 c2                	mov    %eax,%edx
  801124:	85 c0                	test   %eax,%eax
  801126:	78 6d                	js     801195 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112e:	50                   	push   %eax
  80112f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801132:	ff 30                	pushl  (%eax)
  801134:	e8 c2 fd ff ff       	call   800efb <dev_lookup>
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	78 4c                	js     80118c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801140:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801143:	8b 42 08             	mov    0x8(%edx),%eax
  801146:	83 e0 03             	and    $0x3,%eax
  801149:	83 f8 01             	cmp    $0x1,%eax
  80114c:	75 21                	jne    80116f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80114e:	a1 20 60 80 00       	mov    0x806020,%eax
  801153:	8b 40 48             	mov    0x48(%eax),%eax
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	53                   	push   %ebx
  80115a:	50                   	push   %eax
  80115b:	68 d0 23 80 00       	push   $0x8023d0
  801160:	e8 07 f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116d:	eb 26                	jmp    801195 <read+0x8a>
	}
	if (!dev->dev_read)
  80116f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801172:	8b 40 08             	mov    0x8(%eax),%eax
  801175:	85 c0                	test   %eax,%eax
  801177:	74 17                	je     801190 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	ff 75 10             	pushl  0x10(%ebp)
  80117f:	ff 75 0c             	pushl  0xc(%ebp)
  801182:	52                   	push   %edx
  801183:	ff d0                	call   *%eax
  801185:	89 c2                	mov    %eax,%edx
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	eb 09                	jmp    801195 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	eb 05                	jmp    801195 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801190:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801195:	89 d0                	mov    %edx,%eax
  801197:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119a:	c9                   	leave  
  80119b:	c3                   	ret    

0080119c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	57                   	push   %edi
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b0:	eb 21                	jmp    8011d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b2:	83 ec 04             	sub    $0x4,%esp
  8011b5:	89 f0                	mov    %esi,%eax
  8011b7:	29 d8                	sub    %ebx,%eax
  8011b9:	50                   	push   %eax
  8011ba:	89 d8                	mov    %ebx,%eax
  8011bc:	03 45 0c             	add    0xc(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	57                   	push   %edi
  8011c1:	e8 45 ff ff ff       	call   80110b <read>
		if (m < 0)
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 10                	js     8011dd <readn+0x41>
			return m;
		if (m == 0)
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	74 0a                	je     8011db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d1:	01 c3                	add    %eax,%ebx
  8011d3:	39 f3                	cmp    %esi,%ebx
  8011d5:	72 db                	jb     8011b2 <readn+0x16>
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	eb 02                	jmp    8011dd <readn+0x41>
  8011db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 14             	sub    $0x14,%esp
  8011ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	53                   	push   %ebx
  8011f4:	e8 ac fc ff ff       	call   800ea5 <fd_lookup>
  8011f9:	83 c4 08             	add    $0x8,%esp
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 68                	js     80126a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801208:	50                   	push   %eax
  801209:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120c:	ff 30                	pushl  (%eax)
  80120e:	e8 e8 fc ff ff       	call   800efb <dev_lookup>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	78 47                	js     801261 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801221:	75 21                	jne    801244 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801223:	a1 20 60 80 00       	mov    0x806020,%eax
  801228:	8b 40 48             	mov    0x48(%eax),%eax
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	53                   	push   %ebx
  80122f:	50                   	push   %eax
  801230:	68 ec 23 80 00       	push   $0x8023ec
  801235:	e8 32 f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801242:	eb 26                	jmp    80126a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801244:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801247:	8b 52 0c             	mov    0xc(%edx),%edx
  80124a:	85 d2                	test   %edx,%edx
  80124c:	74 17                	je     801265 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80124e:	83 ec 04             	sub    $0x4,%esp
  801251:	ff 75 10             	pushl  0x10(%ebp)
  801254:	ff 75 0c             	pushl  0xc(%ebp)
  801257:	50                   	push   %eax
  801258:	ff d2                	call   *%edx
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	eb 09                	jmp    80126a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801261:	89 c2                	mov    %eax,%edx
  801263:	eb 05                	jmp    80126a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801265:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126a:	89 d0                	mov    %edx,%eax
  80126c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126f:	c9                   	leave  
  801270:	c3                   	ret    

00801271 <seek>:

int
seek(int fdnum, off_t offset)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801277:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127a:	50                   	push   %eax
  80127b:	ff 75 08             	pushl  0x8(%ebp)
  80127e:	e8 22 fc ff ff       	call   800ea5 <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 0e                	js     801298 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801290:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	53                   	push   %ebx
  80129e:	83 ec 14             	sub    $0x14,%esp
  8012a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	53                   	push   %ebx
  8012a9:	e8 f7 fb ff ff       	call   800ea5 <fd_lookup>
  8012ae:	83 c4 08             	add    $0x8,%esp
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 65                	js     80131c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c1:	ff 30                	pushl  (%eax)
  8012c3:	e8 33 fc ff ff       	call   800efb <dev_lookup>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 44                	js     801313 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d6:	75 21                	jne    8012f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d8:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012dd:	8b 40 48             	mov    0x48(%eax),%eax
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	53                   	push   %ebx
  8012e4:	50                   	push   %eax
  8012e5:	68 ac 23 80 00       	push   $0x8023ac
  8012ea:	e8 7d ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f7:	eb 23                	jmp    80131c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fc:	8b 52 18             	mov    0x18(%edx),%edx
  8012ff:	85 d2                	test   %edx,%edx
  801301:	74 14                	je     801317 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	ff 75 0c             	pushl  0xc(%ebp)
  801309:	50                   	push   %eax
  80130a:	ff d2                	call   *%edx
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	eb 09                	jmp    80131c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801313:	89 c2                	mov    %eax,%edx
  801315:	eb 05                	jmp    80131c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801317:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131c:	89 d0                	mov    %edx,%eax
  80131e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	53                   	push   %ebx
  801327:	83 ec 14             	sub    $0x14,%esp
  80132a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 75 08             	pushl  0x8(%ebp)
  801334:	e8 6c fb ff ff       	call   800ea5 <fd_lookup>
  801339:	83 c4 08             	add    $0x8,%esp
  80133c:	89 c2                	mov    %eax,%edx
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 58                	js     80139a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	ff 30                	pushl  (%eax)
  80134e:	e8 a8 fb ff ff       	call   800efb <dev_lookup>
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 37                	js     801391 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801361:	74 32                	je     801395 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801363:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801366:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136d:	00 00 00 
	stat->st_isdir = 0;
  801370:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801377:	00 00 00 
	stat->st_dev = dev;
  80137a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	53                   	push   %ebx
  801384:	ff 75 f0             	pushl  -0x10(%ebp)
  801387:	ff 50 14             	call   *0x14(%eax)
  80138a:	89 c2                	mov    %eax,%edx
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	eb 09                	jmp    80139a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801391:	89 c2                	mov    %eax,%edx
  801393:	eb 05                	jmp    80139a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801395:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139a:	89 d0                	mov    %edx,%eax
  80139c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	56                   	push   %esi
  8013a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	6a 00                	push   $0x0
  8013ab:	ff 75 08             	pushl  0x8(%ebp)
  8013ae:	e8 dc 01 00 00       	call   80158f <open>
  8013b3:	89 c3                	mov    %eax,%ebx
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 1b                	js     8013d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	ff 75 0c             	pushl  0xc(%ebp)
  8013c2:	50                   	push   %eax
  8013c3:	e8 5b ff ff ff       	call   801323 <fstat>
  8013c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ca:	89 1c 24             	mov    %ebx,(%esp)
  8013cd:	e8 fd fb ff ff       	call   800fcf <close>
	return r;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	89 f0                	mov    %esi,%eax
}
  8013d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	89 c6                	mov    %eax,%esi
  8013e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ee:	75 12                	jne    801402 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	6a 01                	push   $0x1
  8013f5:	e8 c8 08 00 00       	call   801cc2 <ipc_find_env>
  8013fa:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ff:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801402:	6a 07                	push   $0x7
  801404:	68 00 70 80 00       	push   $0x807000
  801409:	56                   	push   %esi
  80140a:	ff 35 00 40 80 00    	pushl  0x804000
  801410:	e8 6a 08 00 00       	call   801c7f <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801415:	83 c4 0c             	add    $0xc,%esp
  801418:	6a 00                	push   $0x0
  80141a:	53                   	push   %ebx
  80141b:	6a 00                	push   $0x0
  80141d:	e8 00 08 00 00       	call   801c22 <ipc_recv>
}
  801422:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801425:	5b                   	pop    %ebx
  801426:	5e                   	pop    %esi
  801427:	5d                   	pop    %ebp
  801428:	c3                   	ret    

00801429 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	8b 40 0c             	mov    0xc(%eax),%eax
  801435:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80143a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143d:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801442:	ba 00 00 00 00       	mov    $0x0,%edx
  801447:	b8 02 00 00 00       	mov    $0x2,%eax
  80144c:	e8 8d ff ff ff       	call   8013de <fsipc>
}
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	8b 40 0c             	mov    0xc(%eax),%eax
  80145f:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 06 00 00 00       	mov    $0x6,%eax
  80146e:	e8 6b ff ff ff       	call   8013de <fsipc>
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	53                   	push   %ebx
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	8b 40 0c             	mov    0xc(%eax),%eax
  801485:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148a:	ba 00 00 00 00       	mov    $0x0,%edx
  80148f:	b8 05 00 00 00       	mov    $0x5,%eax
  801494:	e8 45 ff ff ff       	call   8013de <fsipc>
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 2c                	js     8014c9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	68 00 70 80 00       	push   $0x807000
  8014a5:	53                   	push   %ebx
  8014a6:	e8 90 f3 ff ff       	call   80083b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ab:	a1 80 70 80 00       	mov    0x807080,%eax
  8014b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b6:	a1 84 70 80 00       	mov    0x807084,%eax
  8014bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	83 ec 0c             	sub    $0xc,%esp
  8014d4:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014da:	8b 52 0c             	mov    0xc(%edx),%edx
  8014dd:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  8014e3:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014e8:	50                   	push   %eax
  8014e9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ec:	68 08 70 80 00       	push   $0x807008
  8014f1:	e8 d7 f4 ff ff       	call   8009cd <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801500:	e8 d9 fe ff ff       	call   8013de <fsipc>
	//panic("devfile_write not implemented");
}
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	56                   	push   %esi
  80150b:	53                   	push   %ebx
  80150c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80150f:	8b 45 08             	mov    0x8(%ebp),%eax
  801512:	8b 40 0c             	mov    0xc(%eax),%eax
  801515:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80151a:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	b8 03 00 00 00       	mov    $0x3,%eax
  80152a:	e8 af fe ff ff       	call   8013de <fsipc>
  80152f:	89 c3                	mov    %eax,%ebx
  801531:	85 c0                	test   %eax,%eax
  801533:	78 51                	js     801586 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801535:	39 c6                	cmp    %eax,%esi
  801537:	73 19                	jae    801552 <devfile_read+0x4b>
  801539:	68 1c 24 80 00       	push   $0x80241c
  80153e:	68 23 24 80 00       	push   $0x802423
  801543:	68 80 00 00 00       	push   $0x80
  801548:	68 38 24 80 00       	push   $0x802438
  80154d:	e8 41 ec ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  801552:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801557:	7e 19                	jle    801572 <devfile_read+0x6b>
  801559:	68 43 24 80 00       	push   $0x802443
  80155e:	68 23 24 80 00       	push   $0x802423
  801563:	68 81 00 00 00       	push   $0x81
  801568:	68 38 24 80 00       	push   $0x802438
  80156d:	e8 21 ec ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801572:	83 ec 04             	sub    $0x4,%esp
  801575:	50                   	push   %eax
  801576:	68 00 70 80 00       	push   $0x807000
  80157b:	ff 75 0c             	pushl  0xc(%ebp)
  80157e:	e8 4a f4 ff ff       	call   8009cd <memmove>
	return r;
  801583:	83 c4 10             	add    $0x10,%esp
}
  801586:	89 d8                	mov    %ebx,%eax
  801588:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 20             	sub    $0x20,%esp
  801596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801599:	53                   	push   %ebx
  80159a:	e8 63 f2 ff ff       	call   800802 <strlen>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a7:	7f 67                	jg     801610 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	e8 a1 f8 ff ff       	call   800e56 <fd_alloc>
  8015b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 57                	js     801615 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	68 00 70 80 00       	push   $0x807000
  8015c7:	e8 6f f2 ff ff       	call   80083b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cf:	a3 00 74 80 00       	mov    %eax,0x807400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015dc:	e8 fd fd ff ff       	call   8013de <fsipc>
  8015e1:	89 c3                	mov    %eax,%ebx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	79 14                	jns    8015fe <open+0x6f>
		
		fd_close(fd, 0);
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	6a 00                	push   $0x0
  8015ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f2:	e8 57 f9 ff ff       	call   800f4e <fd_close>
		return r;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 da                	mov    %ebx,%edx
  8015fc:	eb 17                	jmp    801615 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 26 f8 ff ff       	call   800e2f <fd2num>
  801609:	89 c2                	mov    %eax,%edx
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 05                	jmp    801615 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801610:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801615:	89 d0                	mov    %edx,%eax
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801622:	ba 00 00 00 00       	mov    $0x0,%edx
  801627:	b8 08 00 00 00       	mov    $0x8,%eax
  80162c:	e8 ad fd ff ff       	call   8013de <fsipc>
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801633:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801637:	7e 37                	jle    801670 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	53                   	push   %ebx
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801642:	ff 70 04             	pushl  0x4(%eax)
  801645:	8d 40 10             	lea    0x10(%eax),%eax
  801648:	50                   	push   %eax
  801649:	ff 33                	pushl  (%ebx)
  80164b:	e8 95 fb ff ff       	call   8011e5 <write>
		if (result > 0)
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	7e 03                	jle    80165a <writebuf+0x27>
			b->result += result;
  801657:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80165a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80165d:	74 0d                	je     80166c <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80165f:	85 c0                	test   %eax,%eax
  801661:	ba 00 00 00 00       	mov    $0x0,%edx
  801666:	0f 4f c2             	cmovg  %edx,%eax
  801669:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	f3 c3                	repz ret 

00801672 <putch>:

static void
putch(int ch, void *thunk)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	53                   	push   %ebx
  801676:	83 ec 04             	sub    $0x4,%esp
  801679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80167c:	8b 53 04             	mov    0x4(%ebx),%edx
  80167f:	8d 42 01             	lea    0x1(%edx),%eax
  801682:	89 43 04             	mov    %eax,0x4(%ebx)
  801685:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801688:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80168c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801691:	75 0e                	jne    8016a1 <putch+0x2f>
		writebuf(b);
  801693:	89 d8                	mov    %ebx,%eax
  801695:	e8 99 ff ff ff       	call   801633 <writebuf>
		b->idx = 0;
  80169a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016a1:	83 c4 04             	add    $0x4,%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016b9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016c0:	00 00 00 
	b.result = 0;
  8016c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016ca:	00 00 00 
	b.error = 1;
  8016cd:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016d4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016d7:	ff 75 10             	pushl  0x10(%ebp)
  8016da:	ff 75 0c             	pushl  0xc(%ebp)
  8016dd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016e3:	50                   	push   %eax
  8016e4:	68 72 16 80 00       	push   $0x801672
  8016e9:	e8 b5 ec ff ff       	call   8003a3 <vprintfmt>
	if (b.idx > 0)
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016f8:	7e 0b                	jle    801705 <vfprintf+0x5e>
		writebuf(&b);
  8016fa:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801700:	e8 2e ff ff ff       	call   801633 <writebuf>

	return (b.result ? b.result : b.error);
  801705:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80170b:	85 c0                	test   %eax,%eax
  80170d:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80171c:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80171f:	50                   	push   %eax
  801720:	ff 75 0c             	pushl  0xc(%ebp)
  801723:	ff 75 08             	pushl  0x8(%ebp)
  801726:	e8 7c ff ff ff       	call   8016a7 <vfprintf>
	va_end(ap);

	return cnt;
}
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <printf>:

int
printf(const char *fmt, ...)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801733:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801736:	50                   	push   %eax
  801737:	ff 75 08             	pushl  0x8(%ebp)
  80173a:	6a 01                	push   $0x1
  80173c:	e8 66 ff ff ff       	call   8016a7 <vfprintf>
	va_end(ap);

	return cnt;
}
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
  801748:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80174b:	83 ec 0c             	sub    $0xc,%esp
  80174e:	ff 75 08             	pushl  0x8(%ebp)
  801751:	e8 e9 f6 ff ff       	call   800e3f <fd2data>
  801756:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801758:	83 c4 08             	add    $0x8,%esp
  80175b:	68 4f 24 80 00       	push   $0x80244f
  801760:	53                   	push   %ebx
  801761:	e8 d5 f0 ff ff       	call   80083b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801766:	8b 46 04             	mov    0x4(%esi),%eax
  801769:	2b 06                	sub    (%esi),%eax
  80176b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801771:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801778:	00 00 00 
	stat->st_dev = &devpipe;
  80177b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801782:	30 80 00 
	return 0;
}
  801785:	b8 00 00 00 00       	mov    $0x0,%eax
  80178a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	53                   	push   %ebx
  801795:	83 ec 0c             	sub    $0xc,%esp
  801798:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80179b:	53                   	push   %ebx
  80179c:	6a 00                	push   $0x0
  80179e:	e8 20 f5 ff ff       	call   800cc3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017a3:	89 1c 24             	mov    %ebx,(%esp)
  8017a6:	e8 94 f6 ff ff       	call   800e3f <fd2data>
  8017ab:	83 c4 08             	add    $0x8,%esp
  8017ae:	50                   	push   %eax
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 0d f5 ff ff       	call   800cc3 <sys_page_unmap>
}
  8017b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b9:	c9                   	leave  
  8017ba:	c3                   	ret    

008017bb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	57                   	push   %edi
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 1c             	sub    $0x1c,%esp
  8017c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017c7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017c9:	a1 20 60 80 00       	mov    0x806020,%eax
  8017ce:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8017d7:	e8 1f 05 00 00       	call   801cfb <pageref>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	89 3c 24             	mov    %edi,(%esp)
  8017e1:	e8 15 05 00 00       	call   801cfb <pageref>
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	39 c3                	cmp    %eax,%ebx
  8017eb:	0f 94 c1             	sete   %cl
  8017ee:	0f b6 c9             	movzbl %cl,%ecx
  8017f1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017f4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8017fa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017fd:	39 ce                	cmp    %ecx,%esi
  8017ff:	74 1b                	je     80181c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801801:	39 c3                	cmp    %eax,%ebx
  801803:	75 c4                	jne    8017c9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801805:	8b 42 58             	mov    0x58(%edx),%eax
  801808:	ff 75 e4             	pushl  -0x1c(%ebp)
  80180b:	50                   	push   %eax
  80180c:	56                   	push   %esi
  80180d:	68 56 24 80 00       	push   $0x802456
  801812:	e8 55 ea ff ff       	call   80026c <cprintf>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	eb ad                	jmp    8017c9 <_pipeisclosed+0xe>
	}
}
  80181c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80181f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5f                   	pop    %edi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	57                   	push   %edi
  80182b:	56                   	push   %esi
  80182c:	53                   	push   %ebx
  80182d:	83 ec 28             	sub    $0x28,%esp
  801830:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801833:	56                   	push   %esi
  801834:	e8 06 f6 ff ff       	call   800e3f <fd2data>
  801839:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	bf 00 00 00 00       	mov    $0x0,%edi
  801843:	eb 4b                	jmp    801890 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801845:	89 da                	mov    %ebx,%edx
  801847:	89 f0                	mov    %esi,%eax
  801849:	e8 6d ff ff ff       	call   8017bb <_pipeisclosed>
  80184e:	85 c0                	test   %eax,%eax
  801850:	75 48                	jne    80189a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801852:	e8 c8 f3 ff ff       	call   800c1f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801857:	8b 43 04             	mov    0x4(%ebx),%eax
  80185a:	8b 0b                	mov    (%ebx),%ecx
  80185c:	8d 51 20             	lea    0x20(%ecx),%edx
  80185f:	39 d0                	cmp    %edx,%eax
  801861:	73 e2                	jae    801845 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801866:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80186a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80186d:	89 c2                	mov    %eax,%edx
  80186f:	c1 fa 1f             	sar    $0x1f,%edx
  801872:	89 d1                	mov    %edx,%ecx
  801874:	c1 e9 1b             	shr    $0x1b,%ecx
  801877:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80187a:	83 e2 1f             	and    $0x1f,%edx
  80187d:	29 ca                	sub    %ecx,%edx
  80187f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801883:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801887:	83 c0 01             	add    $0x1,%eax
  80188a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80188d:	83 c7 01             	add    $0x1,%edi
  801890:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801893:	75 c2                	jne    801857 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801895:	8b 45 10             	mov    0x10(%ebp),%eax
  801898:	eb 05                	jmp    80189f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80189a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80189f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a2:	5b                   	pop    %ebx
  8018a3:	5e                   	pop    %esi
  8018a4:	5f                   	pop    %edi
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	57                   	push   %edi
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 18             	sub    $0x18,%esp
  8018b0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018b3:	57                   	push   %edi
  8018b4:	e8 86 f5 ff ff       	call   800e3f <fd2data>
  8018b9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018c3:	eb 3d                	jmp    801902 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018c5:	85 db                	test   %ebx,%ebx
  8018c7:	74 04                	je     8018cd <devpipe_read+0x26>
				return i;
  8018c9:	89 d8                	mov    %ebx,%eax
  8018cb:	eb 44                	jmp    801911 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018cd:	89 f2                	mov    %esi,%edx
  8018cf:	89 f8                	mov    %edi,%eax
  8018d1:	e8 e5 fe ff ff       	call   8017bb <_pipeisclosed>
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	75 32                	jne    80190c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018da:	e8 40 f3 ff ff       	call   800c1f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018df:	8b 06                	mov    (%esi),%eax
  8018e1:	3b 46 04             	cmp    0x4(%esi),%eax
  8018e4:	74 df                	je     8018c5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018e6:	99                   	cltd   
  8018e7:	c1 ea 1b             	shr    $0x1b,%edx
  8018ea:	01 d0                	add    %edx,%eax
  8018ec:	83 e0 1f             	and    $0x1f,%eax
  8018ef:	29 d0                	sub    %edx,%eax
  8018f1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018fc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ff:	83 c3 01             	add    $0x1,%ebx
  801902:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801905:	75 d8                	jne    8018df <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801907:	8b 45 10             	mov    0x10(%ebp),%eax
  80190a:	eb 05                	jmp    801911 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80190c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801911:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5f                   	pop    %edi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801921:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801924:	50                   	push   %eax
  801925:	e8 2c f5 ff ff       	call   800e56 <fd_alloc>
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	85 c0                	test   %eax,%eax
  801931:	0f 88 2c 01 00 00    	js     801a63 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801937:	83 ec 04             	sub    $0x4,%esp
  80193a:	68 07 04 00 00       	push   $0x407
  80193f:	ff 75 f4             	pushl  -0xc(%ebp)
  801942:	6a 00                	push   $0x0
  801944:	e8 f5 f2 ff ff       	call   800c3e <sys_page_alloc>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	89 c2                	mov    %eax,%edx
  80194e:	85 c0                	test   %eax,%eax
  801950:	0f 88 0d 01 00 00    	js     801a63 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801956:	83 ec 0c             	sub    $0xc,%esp
  801959:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195c:	50                   	push   %eax
  80195d:	e8 f4 f4 ff ff       	call   800e56 <fd_alloc>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	0f 88 e2 00 00 00    	js     801a51 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80196f:	83 ec 04             	sub    $0x4,%esp
  801972:	68 07 04 00 00       	push   $0x407
  801977:	ff 75 f0             	pushl  -0x10(%ebp)
  80197a:	6a 00                	push   $0x0
  80197c:	e8 bd f2 ff ff       	call   800c3e <sys_page_alloc>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	0f 88 c3 00 00 00    	js     801a51 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	ff 75 f4             	pushl  -0xc(%ebp)
  801994:	e8 a6 f4 ff ff       	call   800e3f <fd2data>
  801999:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199b:	83 c4 0c             	add    $0xc,%esp
  80199e:	68 07 04 00 00       	push   $0x407
  8019a3:	50                   	push   %eax
  8019a4:	6a 00                	push   $0x0
  8019a6:	e8 93 f2 ff ff       	call   800c3e <sys_page_alloc>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	0f 88 89 00 00 00    	js     801a41 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b8:	83 ec 0c             	sub    $0xc,%esp
  8019bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8019be:	e8 7c f4 ff ff       	call   800e3f <fd2data>
  8019c3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019ca:	50                   	push   %eax
  8019cb:	6a 00                	push   $0x0
  8019cd:	56                   	push   %esi
  8019ce:	6a 00                	push   $0x0
  8019d0:	e8 ac f2 ff ff       	call   800c81 <sys_page_map>
  8019d5:	89 c3                	mov    %eax,%ebx
  8019d7:	83 c4 20             	add    $0x20,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 55                	js     801a33 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019de:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019f3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019fc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a01:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0e:	e8 1c f4 ff ff       	call   800e2f <fd2num>
  801a13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a16:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a18:	83 c4 04             	add    $0x4,%esp
  801a1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a1e:	e8 0c f4 ff ff       	call   800e2f <fd2num>
  801a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a26:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a31:	eb 30                	jmp    801a63 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a33:	83 ec 08             	sub    $0x8,%esp
  801a36:	56                   	push   %esi
  801a37:	6a 00                	push   $0x0
  801a39:	e8 85 f2 ff ff       	call   800cc3 <sys_page_unmap>
  801a3e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a41:	83 ec 08             	sub    $0x8,%esp
  801a44:	ff 75 f0             	pushl  -0x10(%ebp)
  801a47:	6a 00                	push   $0x0
  801a49:	e8 75 f2 ff ff       	call   800cc3 <sys_page_unmap>
  801a4e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	ff 75 f4             	pushl  -0xc(%ebp)
  801a57:	6a 00                	push   $0x0
  801a59:	e8 65 f2 ff ff       	call   800cc3 <sys_page_unmap>
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a63:	89 d0                	mov    %edx,%eax
  801a65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a75:	50                   	push   %eax
  801a76:	ff 75 08             	pushl  0x8(%ebp)
  801a79:	e8 27 f4 ff ff       	call   800ea5 <fd_lookup>
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 18                	js     801a9d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8b:	e8 af f3 ff ff       	call   800e3f <fd2data>
	return _pipeisclosed(fd, p);
  801a90:	89 c2                	mov    %eax,%edx
  801a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a95:	e8 21 fd ff ff       	call   8017bb <_pipeisclosed>
  801a9a:	83 c4 10             	add    $0x10,%esp
}
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801aaf:	68 6e 24 80 00       	push   $0x80246e
  801ab4:	ff 75 0c             	pushl  0xc(%ebp)
  801ab7:	e8 7f ed ff ff       	call   80083b <strcpy>
	return 0;
}
  801abc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	57                   	push   %edi
  801ac7:	56                   	push   %esi
  801ac8:	53                   	push   %ebx
  801ac9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801acf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ad4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ada:	eb 2d                	jmp    801b09 <devcons_write+0x46>
		m = n - tot;
  801adc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801adf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ae1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ae4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ae9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801aec:	83 ec 04             	sub    $0x4,%esp
  801aef:	53                   	push   %ebx
  801af0:	03 45 0c             	add    0xc(%ebp),%eax
  801af3:	50                   	push   %eax
  801af4:	57                   	push   %edi
  801af5:	e8 d3 ee ff ff       	call   8009cd <memmove>
		sys_cputs(buf, m);
  801afa:	83 c4 08             	add    $0x8,%esp
  801afd:	53                   	push   %ebx
  801afe:	57                   	push   %edi
  801aff:	e8 7e f0 ff ff       	call   800b82 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b04:	01 de                	add    %ebx,%esi
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	89 f0                	mov    %esi,%eax
  801b0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b0e:	72 cc                	jb     801adc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b27:	74 2a                	je     801b53 <devcons_read+0x3b>
  801b29:	eb 05                	jmp    801b30 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b2b:	e8 ef f0 ff ff       	call   800c1f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b30:	e8 6b f0 ff ff       	call   800ba0 <sys_cgetc>
  801b35:	85 c0                	test   %eax,%eax
  801b37:	74 f2                	je     801b2b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 16                	js     801b53 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b3d:	83 f8 04             	cmp    $0x4,%eax
  801b40:	74 0c                	je     801b4e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b45:	88 02                	mov    %al,(%edx)
	return 1;
  801b47:	b8 01 00 00 00       	mov    $0x1,%eax
  801b4c:	eb 05                	jmp    801b53 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b4e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b61:	6a 01                	push   $0x1
  801b63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b66:	50                   	push   %eax
  801b67:	e8 16 f0 ff ff       	call   800b82 <sys_cputs>
}
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    

00801b71 <getchar>:

int
getchar(void)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b77:	6a 01                	push   $0x1
  801b79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b7c:	50                   	push   %eax
  801b7d:	6a 00                	push   $0x0
  801b7f:	e8 87 f5 ff ff       	call   80110b <read>
	if (r < 0)
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	85 c0                	test   %eax,%eax
  801b89:	78 0f                	js     801b9a <getchar+0x29>
		return r;
	if (r < 1)
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	7e 06                	jle    801b95 <getchar+0x24>
		return -E_EOF;
	return c;
  801b8f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b93:	eb 05                	jmp    801b9a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b95:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b9a:	c9                   	leave  
  801b9b:	c3                   	ret    

00801b9c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	ff 75 08             	pushl  0x8(%ebp)
  801ba9:	e8 f7 f2 ff ff       	call   800ea5 <fd_lookup>
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 11                	js     801bc6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bbe:	39 10                	cmp    %edx,(%eax)
  801bc0:	0f 94 c0             	sete   %al
  801bc3:	0f b6 c0             	movzbl %al,%eax
}
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <opencons>:

int
opencons(void)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd1:	50                   	push   %eax
  801bd2:	e8 7f f2 ff ff       	call   800e56 <fd_alloc>
  801bd7:	83 c4 10             	add    $0x10,%esp
		return r;
  801bda:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	78 3e                	js     801c1e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801be0:	83 ec 04             	sub    $0x4,%esp
  801be3:	68 07 04 00 00       	push   $0x407
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	6a 00                	push   $0x0
  801bed:	e8 4c f0 ff ff       	call   800c3e <sys_page_alloc>
  801bf2:	83 c4 10             	add    $0x10,%esp
		return r;
  801bf5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 23                	js     801c1e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bfb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c04:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c09:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	50                   	push   %eax
  801c14:	e8 16 f2 ff ff       	call   800e2f <fd2num>
  801c19:	89 c2                	mov    %eax,%edx
  801c1b:	83 c4 10             	add    $0x10,%esp
}
  801c1e:	89 d0                	mov    %edx,%eax
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	56                   	push   %esi
  801c26:	53                   	push   %ebx
  801c27:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c2a:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801c2d:	83 ec 0c             	sub    $0xc,%esp
  801c30:	ff 75 0c             	pushl  0xc(%ebp)
  801c33:	e8 b6 f1 ff ff       	call   800dee <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 f6                	test   %esi,%esi
  801c3d:	74 1c                	je     801c5b <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801c3f:	a1 20 60 80 00       	mov    0x806020,%eax
  801c44:	8b 40 78             	mov    0x78(%eax),%eax
  801c47:	89 06                	mov    %eax,(%esi)
  801c49:	eb 10                	jmp    801c5b <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	68 7a 24 80 00       	push   $0x80247a
  801c53:	e8 14 e6 ff ff       	call   80026c <cprintf>
  801c58:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801c5b:	a1 20 60 80 00       	mov    0x806020,%eax
  801c60:	8b 50 74             	mov    0x74(%eax),%edx
  801c63:	85 d2                	test   %edx,%edx
  801c65:	74 e4                	je     801c4b <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801c67:	85 db                	test   %ebx,%ebx
  801c69:	74 05                	je     801c70 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801c6b:	8b 40 74             	mov    0x74(%eax),%eax
  801c6e:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c70:	a1 20 60 80 00       	mov    0x806020,%eax
  801c75:	8b 40 70             	mov    0x70(%eax),%eax

}
  801c78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7b:	5b                   	pop    %ebx
  801c7c:	5e                   	pop    %esi
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	57                   	push   %edi
  801c83:	56                   	push   %esi
  801c84:	53                   	push   %ebx
  801c85:	83 ec 0c             	sub    $0xc,%esp
  801c88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801c91:	85 db                	test   %ebx,%ebx
  801c93:	75 13                	jne    801ca8 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801c95:	6a 00                	push   $0x0
  801c97:	68 00 00 c0 ee       	push   $0xeec00000
  801c9c:	56                   	push   %esi
  801c9d:	57                   	push   %edi
  801c9e:	e8 28 f1 ff ff       	call   800dcb <sys_ipc_try_send>
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	eb 0e                	jmp    801cb6 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801ca8:	ff 75 14             	pushl  0x14(%ebp)
  801cab:	53                   	push   %ebx
  801cac:	56                   	push   %esi
  801cad:	57                   	push   %edi
  801cae:	e8 18 f1 ff ff       	call   800dcb <sys_ipc_try_send>
  801cb3:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	75 d7                	jne    801c91 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cc8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ccd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cd0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cd6:	8b 52 50             	mov    0x50(%edx),%edx
  801cd9:	39 ca                	cmp    %ecx,%edx
  801cdb:	75 0d                	jne    801cea <ipc_find_env+0x28>
			return envs[i].env_id;
  801cdd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ce0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ce5:	8b 40 48             	mov    0x48(%eax),%eax
  801ce8:	eb 0f                	jmp    801cf9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cea:	83 c0 01             	add    $0x1,%eax
  801ced:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cf2:	75 d9                	jne    801ccd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d01:	89 d0                	mov    %edx,%eax
  801d03:	c1 e8 16             	shr    $0x16,%eax
  801d06:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d0d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d12:	f6 c1 01             	test   $0x1,%cl
  801d15:	74 1d                	je     801d34 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d17:	c1 ea 0c             	shr    $0xc,%edx
  801d1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d21:	f6 c2 01             	test   $0x1,%dl
  801d24:	74 0e                	je     801d34 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d26:	c1 ea 0c             	shr    $0xc,%edx
  801d29:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d30:	ef 
  801d31:	0f b7 c0             	movzwl %ax,%eax
}
  801d34:	5d                   	pop    %ebp
  801d35:	c3                   	ret    
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__udivdi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	85 f6                	test   %esi,%esi
  801d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d5d:	89 ca                	mov    %ecx,%edx
  801d5f:	89 f8                	mov    %edi,%eax
  801d61:	75 3d                	jne    801da0 <__udivdi3+0x60>
  801d63:	39 cf                	cmp    %ecx,%edi
  801d65:	0f 87 c5 00 00 00    	ja     801e30 <__udivdi3+0xf0>
  801d6b:	85 ff                	test   %edi,%edi
  801d6d:	89 fd                	mov    %edi,%ebp
  801d6f:	75 0b                	jne    801d7c <__udivdi3+0x3c>
  801d71:	b8 01 00 00 00       	mov    $0x1,%eax
  801d76:	31 d2                	xor    %edx,%edx
  801d78:	f7 f7                	div    %edi
  801d7a:	89 c5                	mov    %eax,%ebp
  801d7c:	89 c8                	mov    %ecx,%eax
  801d7e:	31 d2                	xor    %edx,%edx
  801d80:	f7 f5                	div    %ebp
  801d82:	89 c1                	mov    %eax,%ecx
  801d84:	89 d8                	mov    %ebx,%eax
  801d86:	89 cf                	mov    %ecx,%edi
  801d88:	f7 f5                	div    %ebp
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	89 d8                	mov    %ebx,%eax
  801d8e:	89 fa                	mov    %edi,%edx
  801d90:	83 c4 1c             	add    $0x1c,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
  801d98:	90                   	nop
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	39 ce                	cmp    %ecx,%esi
  801da2:	77 74                	ja     801e18 <__udivdi3+0xd8>
  801da4:	0f bd fe             	bsr    %esi,%edi
  801da7:	83 f7 1f             	xor    $0x1f,%edi
  801daa:	0f 84 98 00 00 00    	je     801e48 <__udivdi3+0x108>
  801db0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801db5:	89 f9                	mov    %edi,%ecx
  801db7:	89 c5                	mov    %eax,%ebp
  801db9:	29 fb                	sub    %edi,%ebx
  801dbb:	d3 e6                	shl    %cl,%esi
  801dbd:	89 d9                	mov    %ebx,%ecx
  801dbf:	d3 ed                	shr    %cl,%ebp
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	d3 e0                	shl    %cl,%eax
  801dc5:	09 ee                	or     %ebp,%esi
  801dc7:	89 d9                	mov    %ebx,%ecx
  801dc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dcd:	89 d5                	mov    %edx,%ebp
  801dcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dd3:	d3 ed                	shr    %cl,%ebp
  801dd5:	89 f9                	mov    %edi,%ecx
  801dd7:	d3 e2                	shl    %cl,%edx
  801dd9:	89 d9                	mov    %ebx,%ecx
  801ddb:	d3 e8                	shr    %cl,%eax
  801ddd:	09 c2                	or     %eax,%edx
  801ddf:	89 d0                	mov    %edx,%eax
  801de1:	89 ea                	mov    %ebp,%edx
  801de3:	f7 f6                	div    %esi
  801de5:	89 d5                	mov    %edx,%ebp
  801de7:	89 c3                	mov    %eax,%ebx
  801de9:	f7 64 24 0c          	mull   0xc(%esp)
  801ded:	39 d5                	cmp    %edx,%ebp
  801def:	72 10                	jb     801e01 <__udivdi3+0xc1>
  801df1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801df5:	89 f9                	mov    %edi,%ecx
  801df7:	d3 e6                	shl    %cl,%esi
  801df9:	39 c6                	cmp    %eax,%esi
  801dfb:	73 07                	jae    801e04 <__udivdi3+0xc4>
  801dfd:	39 d5                	cmp    %edx,%ebp
  801dff:	75 03                	jne    801e04 <__udivdi3+0xc4>
  801e01:	83 eb 01             	sub    $0x1,%ebx
  801e04:	31 ff                	xor    %edi,%edi
  801e06:	89 d8                	mov    %ebx,%eax
  801e08:	89 fa                	mov    %edi,%edx
  801e0a:	83 c4 1c             	add    $0x1c,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5f                   	pop    %edi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    
  801e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e18:	31 ff                	xor    %edi,%edi
  801e1a:	31 db                	xor    %ebx,%ebx
  801e1c:	89 d8                	mov    %ebx,%eax
  801e1e:	89 fa                	mov    %edi,%edx
  801e20:	83 c4 1c             	add    $0x1c,%esp
  801e23:	5b                   	pop    %ebx
  801e24:	5e                   	pop    %esi
  801e25:	5f                   	pop    %edi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    
  801e28:	90                   	nop
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	89 d8                	mov    %ebx,%eax
  801e32:	f7 f7                	div    %edi
  801e34:	31 ff                	xor    %edi,%edi
  801e36:	89 c3                	mov    %eax,%ebx
  801e38:	89 d8                	mov    %ebx,%eax
  801e3a:	89 fa                	mov    %edi,%edx
  801e3c:	83 c4 1c             	add    $0x1c,%esp
  801e3f:	5b                   	pop    %ebx
  801e40:	5e                   	pop    %esi
  801e41:	5f                   	pop    %edi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    
  801e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e48:	39 ce                	cmp    %ecx,%esi
  801e4a:	72 0c                	jb     801e58 <__udivdi3+0x118>
  801e4c:	31 db                	xor    %ebx,%ebx
  801e4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e52:	0f 87 34 ff ff ff    	ja     801d8c <__udivdi3+0x4c>
  801e58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e5d:	e9 2a ff ff ff       	jmp    801d8c <__udivdi3+0x4c>
  801e62:	66 90                	xchg   %ax,%ax
  801e64:	66 90                	xchg   %ax,%ax
  801e66:	66 90                	xchg   %ax,%ax
  801e68:	66 90                	xchg   %ax,%ax
  801e6a:	66 90                	xchg   %ax,%ax
  801e6c:	66 90                	xchg   %ax,%ax
  801e6e:	66 90                	xchg   %ax,%ax

00801e70 <__umoddi3>:
  801e70:	55                   	push   %ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	83 ec 1c             	sub    $0x1c,%esp
  801e77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e87:	85 d2                	test   %edx,%edx
  801e89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e91:	89 f3                	mov    %esi,%ebx
  801e93:	89 3c 24             	mov    %edi,(%esp)
  801e96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e9a:	75 1c                	jne    801eb8 <__umoddi3+0x48>
  801e9c:	39 f7                	cmp    %esi,%edi
  801e9e:	76 50                	jbe    801ef0 <__umoddi3+0x80>
  801ea0:	89 c8                	mov    %ecx,%eax
  801ea2:	89 f2                	mov    %esi,%edx
  801ea4:	f7 f7                	div    %edi
  801ea6:	89 d0                	mov    %edx,%eax
  801ea8:	31 d2                	xor    %edx,%edx
  801eaa:	83 c4 1c             	add    $0x1c,%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5f                   	pop    %edi
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    
  801eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801eb8:	39 f2                	cmp    %esi,%edx
  801eba:	89 d0                	mov    %edx,%eax
  801ebc:	77 52                	ja     801f10 <__umoddi3+0xa0>
  801ebe:	0f bd ea             	bsr    %edx,%ebp
  801ec1:	83 f5 1f             	xor    $0x1f,%ebp
  801ec4:	75 5a                	jne    801f20 <__umoddi3+0xb0>
  801ec6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eca:	0f 82 e0 00 00 00    	jb     801fb0 <__umoddi3+0x140>
  801ed0:	39 0c 24             	cmp    %ecx,(%esp)
  801ed3:	0f 86 d7 00 00 00    	jbe    801fb0 <__umoddi3+0x140>
  801ed9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801edd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ee1:	83 c4 1c             	add    $0x1c,%esp
  801ee4:	5b                   	pop    %ebx
  801ee5:	5e                   	pop    %esi
  801ee6:	5f                   	pop    %edi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    
  801ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	85 ff                	test   %edi,%edi
  801ef2:	89 fd                	mov    %edi,%ebp
  801ef4:	75 0b                	jne    801f01 <__umoddi3+0x91>
  801ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  801efb:	31 d2                	xor    %edx,%edx
  801efd:	f7 f7                	div    %edi
  801eff:	89 c5                	mov    %eax,%ebp
  801f01:	89 f0                	mov    %esi,%eax
  801f03:	31 d2                	xor    %edx,%edx
  801f05:	f7 f5                	div    %ebp
  801f07:	89 c8                	mov    %ecx,%eax
  801f09:	f7 f5                	div    %ebp
  801f0b:	89 d0                	mov    %edx,%eax
  801f0d:	eb 99                	jmp    801ea8 <__umoddi3+0x38>
  801f0f:	90                   	nop
  801f10:	89 c8                	mov    %ecx,%eax
  801f12:	89 f2                	mov    %esi,%edx
  801f14:	83 c4 1c             	add    $0x1c,%esp
  801f17:	5b                   	pop    %ebx
  801f18:	5e                   	pop    %esi
  801f19:	5f                   	pop    %edi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    
  801f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f20:	8b 34 24             	mov    (%esp),%esi
  801f23:	bf 20 00 00 00       	mov    $0x20,%edi
  801f28:	89 e9                	mov    %ebp,%ecx
  801f2a:	29 ef                	sub    %ebp,%edi
  801f2c:	d3 e0                	shl    %cl,%eax
  801f2e:	89 f9                	mov    %edi,%ecx
  801f30:	89 f2                	mov    %esi,%edx
  801f32:	d3 ea                	shr    %cl,%edx
  801f34:	89 e9                	mov    %ebp,%ecx
  801f36:	09 c2                	or     %eax,%edx
  801f38:	89 d8                	mov    %ebx,%eax
  801f3a:	89 14 24             	mov    %edx,(%esp)
  801f3d:	89 f2                	mov    %esi,%edx
  801f3f:	d3 e2                	shl    %cl,%edx
  801f41:	89 f9                	mov    %edi,%ecx
  801f43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f4b:	d3 e8                	shr    %cl,%eax
  801f4d:	89 e9                	mov    %ebp,%ecx
  801f4f:	89 c6                	mov    %eax,%esi
  801f51:	d3 e3                	shl    %cl,%ebx
  801f53:	89 f9                	mov    %edi,%ecx
  801f55:	89 d0                	mov    %edx,%eax
  801f57:	d3 e8                	shr    %cl,%eax
  801f59:	89 e9                	mov    %ebp,%ecx
  801f5b:	09 d8                	or     %ebx,%eax
  801f5d:	89 d3                	mov    %edx,%ebx
  801f5f:	89 f2                	mov    %esi,%edx
  801f61:	f7 34 24             	divl   (%esp)
  801f64:	89 d6                	mov    %edx,%esi
  801f66:	d3 e3                	shl    %cl,%ebx
  801f68:	f7 64 24 04          	mull   0x4(%esp)
  801f6c:	39 d6                	cmp    %edx,%esi
  801f6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f72:	89 d1                	mov    %edx,%ecx
  801f74:	89 c3                	mov    %eax,%ebx
  801f76:	72 08                	jb     801f80 <__umoddi3+0x110>
  801f78:	75 11                	jne    801f8b <__umoddi3+0x11b>
  801f7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f7e:	73 0b                	jae    801f8b <__umoddi3+0x11b>
  801f80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f84:	1b 14 24             	sbb    (%esp),%edx
  801f87:	89 d1                	mov    %edx,%ecx
  801f89:	89 c3                	mov    %eax,%ebx
  801f8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f8f:	29 da                	sub    %ebx,%edx
  801f91:	19 ce                	sbb    %ecx,%esi
  801f93:	89 f9                	mov    %edi,%ecx
  801f95:	89 f0                	mov    %esi,%eax
  801f97:	d3 e0                	shl    %cl,%eax
  801f99:	89 e9                	mov    %ebp,%ecx
  801f9b:	d3 ea                	shr    %cl,%edx
  801f9d:	89 e9                	mov    %ebp,%ecx
  801f9f:	d3 ee                	shr    %cl,%esi
  801fa1:	09 d0                	or     %edx,%eax
  801fa3:	89 f2                	mov    %esi,%edx
  801fa5:	83 c4 1c             	add    $0x1c,%esp
  801fa8:	5b                   	pop    %ebx
  801fa9:	5e                   	pop    %esi
  801faa:	5f                   	pop    %edi
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    
  801fad:	8d 76 00             	lea    0x0(%esi),%esi
  801fb0:	29 f9                	sub    %edi,%ecx
  801fb2:	19 d6                	sbb    %edx,%esi
  801fb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fbc:	e9 18 ff ff ff       	jmp    801ed9 <__umoddi3+0x69>
