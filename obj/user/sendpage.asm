
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 c9 0f 00 00       	call   801007 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 a0 11 00 00       	call   8011fc <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 60 23 80 00       	push   $0x802360
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 a3 07 00 00       	call   800822 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 98 08 00 00       	call   80092b <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 74 23 80 00       	push   $0x802374
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 6a 07 00 00       	call   800822 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 86 09 00 00       	call   800a55 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 79 11 00 00       	call   801259 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 5e 0b 00 00       	call   800c5e <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 14 07 00 00       	call   800822 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 30 09 00 00       	call   800a55 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 23 11 00 00       	call   801259 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 b3 10 00 00       	call   8011fc <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 60 23 80 00       	push   $0x802360
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 b6 06 00 00       	call   800822 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 ab 07 00 00       	call   80092b <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 94 23 80 00       	push   $0x802394
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 77 0a 00 00       	call   800c20 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 b6 12 00 00       	call   8014a0 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 eb 09 00 00       	call   800bdf <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 79 09 00 00       	call   800ba2 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 54 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 1e 09 00 00       	call   800ba2 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 dc 1d 00 00       	call   8020d0 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 c9 1e 00 00       	call   802200 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 0c 24 80 00 	movsbl 0x80240c(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	e8 05 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
  8003cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 d3 03 00 00    	je     8007b2 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d6                	call   *%esi
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	83 c7 01             	add    $0x1,%edi
  8003ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f0:	83 f8 25             	cmp    $0x25,%eax
  8003f3:	75 e2                	jne    8003d7 <vprintfmt+0x14>
  8003f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800400:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	eb 07                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8d 47 01             	lea    0x1(%edi),%eax
  80041f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800422:	0f b6 07             	movzbl (%edi),%eax
  800425:	0f b6 c8             	movzbl %al,%ecx
  800428:	83 e8 23             	sub    $0x23,%eax
  80042b:	3c 55                	cmp    $0x55,%al
  80042d:	0f 87 64 03 00 00    	ja     800797 <vprintfmt+0x3d4>
  800433:	0f b6 c0             	movzbl %al,%eax
  800436:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800444:	eb d6                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800451:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800454:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800458:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80045e:	83 fa 09             	cmp    $0x9,%edx
  800461:	77 39                	ja     80049c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb e9                	jmp    800451 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 48 04             	lea    0x4(%eax),%ecx
  80046e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800479:	eb 27                	jmp    8004a2 <vprintfmt+0xdf>
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	85 c0                	test   %eax,%eax
  800480:	b9 00 00 00 00       	mov    $0x0,%ecx
  800485:	0f 49 c8             	cmovns %eax,%ecx
  800488:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048e:	eb 8c                	jmp    80041c <vprintfmt+0x59>
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800493:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049a:	eb 80                	jmp    80041c <vprintfmt+0x59>
  80049c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049f:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	0f 89 70 ff ff ff    	jns    80041c <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ac:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004b9:	e9 5e ff ff ff       	jmp    80041c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c4:	e9 53 ff ff ff       	jmp    80041c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	ff 30                	pushl  (%eax)
  8004d8:	ff d6                	call   *%esi
			break;
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e0:	e9 04 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	99                   	cltd   
  8004f1:	31 d0                	xor    %edx,%eax
  8004f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f5:	83 f8 0f             	cmp    $0xf,%eax
  8004f8:	7f 0b                	jg     800505 <vprintfmt+0x142>
  8004fa:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 24 24 80 00       	push   $0x802424
  80050b:	53                   	push   %ebx
  80050c:	56                   	push   %esi
  80050d:	e8 94 fe ff ff       	call   8003a6 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800518:	e9 cc fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051d:	52                   	push   %edx
  80051e:	68 59 29 80 00       	push   $0x802959
  800523:	53                   	push   %ebx
  800524:	56                   	push   %esi
  800525:	e8 7c fe ff ff       	call   8003a6 <printfmt>
  80052a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800530:	e9 b4 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800540:	85 ff                	test   %edi,%edi
  800542:	b8 1d 24 80 00       	mov    $0x80241d,%eax
  800547:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054e:	0f 8e 94 00 00 00    	jle    8005e8 <vprintfmt+0x225>
  800554:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800558:	0f 84 98 00 00 00    	je     8005f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 c8             	pushl  -0x38(%ebp)
  800564:	57                   	push   %edi
  800565:	e8 d0 02 00 00       	call   80083a <strnlen>
  80056a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056d:	29 c1                	sub    %eax,%ecx
  80056f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800575:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800579:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	eb 0f                	jmp    800592 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	ff 75 e0             	pushl  -0x20(%ebp)
  80058a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	85 ff                	test   %edi,%edi
  800594:	7f ed                	jg     800583 <vprintfmt+0x1c0>
  800596:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800599:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80059c:	85 c9                	test   %ecx,%ecx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c1             	cmovns %ecx,%eax
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ab:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b1:	89 cb                	mov    %ecx,%ebx
  8005b3:	eb 4d                	jmp    800602 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b9:	74 1b                	je     8005d6 <vprintfmt+0x213>
  8005bb:	0f be c0             	movsbl %al,%eax
  8005be:	83 e8 20             	sub    $0x20,%eax
  8005c1:	83 f8 5e             	cmp    $0x5e,%eax
  8005c4:	76 10                	jbe    8005d6 <vprintfmt+0x213>
					putch('?', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	6a 3f                	push   $0x3f
  8005ce:	ff 55 08             	call   *0x8(%ebp)
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	eb 0d                	jmp    8005e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 0c             	pushl  0xc(%ebp)
  8005dc:	52                   	push   %edx
  8005dd:	ff 55 08             	call   *0x8(%ebp)
  8005e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e3:	83 eb 01             	sub    $0x1,%ebx
  8005e6:	eb 1a                	jmp    800602 <vprintfmt+0x23f>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 0c                	jmp    800602 <vprintfmt+0x23f>
  8005f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800602:	83 c7 01             	add    $0x1,%edi
  800605:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800609:	0f be d0             	movsbl %al,%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 23                	je     800633 <vprintfmt+0x270>
  800610:	85 f6                	test   %esi,%esi
  800612:	78 a1                	js     8005b5 <vprintfmt+0x1f2>
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	79 9c                	jns    8005b5 <vprintfmt+0x1f2>
  800619:	89 df                	mov    %ebx,%edi
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800621:	eb 18                	jmp    80063b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 20                	push   $0x20
  800629:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 ef 01             	sub    $0x1,%edi
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 08                	jmp    80063b <vprintfmt+0x278>
  800633:	89 df                	mov    %ebx,%edi
  800635:	8b 75 08             	mov    0x8(%ebp),%esi
  800638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063b:	85 ff                	test   %edi,%edi
  80063d:	7f e4                	jg     800623 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 a2 fd ff ff       	jmp    8003e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800647:	83 fa 01             	cmp    $0x1,%edx
  80064a:	7e 16                	jle    800662 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 08             	lea    0x8(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80065d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800660:	eb 32                	jmp    800694 <vprintfmt+0x2d1>
	else if (lflag)
  800662:	85 d2                	test   %edx,%edx
  800664:	74 18                	je     80067e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800674:	89 c1                	mov    %eax,%ecx
  800676:	c1 f9 1f             	sar    $0x1f,%ecx
  800679:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80067c:	eb 16                	jmp    800694 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80068c:	89 c1                	mov    %eax,%ecx
  80068e:	c1 f9 1f             	sar    $0x1f,%ecx
  800691:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800694:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800697:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80069a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006a9:	0f 89 b0 00 00 00    	jns    80075f <vprintfmt+0x39c>
				putch('-', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 2d                	push   $0x2d
  8006b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006ba:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006bd:	f7 d8                	neg    %eax
  8006bf:	83 d2 00             	adc    $0x0,%edx
  8006c2:	f7 da                	neg    %edx
  8006c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ca:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d2:	e9 88 00 00 00       	jmp    80075f <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 70 fc ff ff       	call   80034f <getuint>
  8006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006e5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006ea:	eb 73                	jmp    80075f <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 5b fc ff ff       	call   80034f <getuint>
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 58                	push   $0x58
  800700:	ff d6                	call   *%esi
			putch('X', putdat);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 58                	push   $0x58
  800708:	ff d6                	call   *%esi
			putch('X', putdat);
  80070a:	83 c4 08             	add    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 58                	push   $0x58
  800710:	ff d6                	call   *%esi
			goto number;
  800712:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800715:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80071a:	eb 43                	jmp    80075f <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 30                	push   $0x30
  800722:	ff d6                	call   *%esi
			putch('x', putdat);
  800724:	83 c4 08             	add    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 78                	push   $0x78
  80072a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
  80073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800742:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800745:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80074a:	eb 13                	jmp    80075f <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	e8 fb fb ff ff       	call   80034f <getuint>
  800754:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800757:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075f:	83 ec 0c             	sub    $0xc,%esp
  800762:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800766:	52                   	push   %edx
  800767:	ff 75 e0             	pushl  -0x20(%ebp)
  80076a:	50                   	push   %eax
  80076b:	ff 75 dc             	pushl  -0x24(%ebp)
  80076e:	ff 75 d8             	pushl  -0x28(%ebp)
  800771:	89 da                	mov    %ebx,%edx
  800773:	89 f0                	mov    %esi,%eax
  800775:	e8 26 fb ff ff       	call   8002a0 <printnum>
			break;
  80077a:	83 c4 20             	add    $0x20,%esp
  80077d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800780:	e9 64 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	51                   	push   %ecx
  80078a:	ff d6                	call   *%esi
			break;
  80078c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800792:	e9 52 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 25                	push   $0x25
  80079d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 03                	jmp    8007a7 <vprintfmt+0x3e4>
  8007a4:	83 ef 01             	sub    $0x1,%edi
  8007a7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007ab:	75 f7                	jne    8007a4 <vprintfmt+0x3e1>
  8007ad:	e9 37 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	5f                   	pop    %edi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 18             	sub    $0x18,%esp
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	74 26                	je     800801 <vsnprintf+0x47>
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	7e 22                	jle    800801 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007df:	ff 75 14             	pushl  0x14(%ebp)
  8007e2:	ff 75 10             	pushl  0x10(%ebp)
  8007e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e8:	50                   	push   %eax
  8007e9:	68 89 03 80 00       	push   $0x800389
  8007ee:	e8 d0 fb ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	eb 05                	jmp    800806 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800801:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800811:	50                   	push   %eax
  800812:	ff 75 10             	pushl  0x10(%ebp)
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	ff 75 08             	pushl  0x8(%ebp)
  80081b:	e8 9a ff ff ff       	call   8007ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
  80082d:	eb 03                	jmp    800832 <strlen+0x10>
		n++;
  80082f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800832:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800836:	75 f7                	jne    80082f <strlen+0xd>
		n++;
	return n;
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800843:	ba 00 00 00 00       	mov    $0x0,%edx
  800848:	eb 03                	jmp    80084d <strnlen+0x13>
		n++;
  80084a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084d:	39 c2                	cmp    %eax,%edx
  80084f:	74 08                	je     800859 <strnlen+0x1f>
  800851:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800855:	75 f3                	jne    80084a <strnlen+0x10>
  800857:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800865:	89 c2                	mov    %eax,%edx
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800871:	88 5a ff             	mov    %bl,-0x1(%edx)
  800874:	84 db                	test   %bl,%bl
  800876:	75 ef                	jne    800867 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800882:	53                   	push   %ebx
  800883:	e8 9a ff ff ff       	call   800822 <strlen>
  800888:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80088b:	ff 75 0c             	pushl  0xc(%ebp)
  80088e:	01 d8                	add    %ebx,%eax
  800890:	50                   	push   %eax
  800891:	e8 c5 ff ff ff       	call   80085b <strcpy>
	return dst;
}
  800896:	89 d8                	mov    %ebx,%eax
  800898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	56                   	push   %esi
  8008a1:	53                   	push   %ebx
  8008a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a8:	89 f3                	mov    %esi,%ebx
  8008aa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ad:	89 f2                	mov    %esi,%edx
  8008af:	eb 0f                	jmp    8008c0 <strncpy+0x23>
		*dst++ = *src;
  8008b1:	83 c2 01             	add    $0x1,%edx
  8008b4:	0f b6 01             	movzbl (%ecx),%eax
  8008b7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ba:	80 39 01             	cmpb   $0x1,(%ecx)
  8008bd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c0:	39 da                	cmp    %ebx,%edx
  8008c2:	75 ed                	jne    8008b1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c4:	89 f0                	mov    %esi,%eax
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	56                   	push   %esi
  8008ce:	53                   	push   %ebx
  8008cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d5:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008da:	85 d2                	test   %edx,%edx
  8008dc:	74 21                	je     8008ff <strlcpy+0x35>
  8008de:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	eb 09                	jmp    8008ef <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ef:	39 c2                	cmp    %eax,%edx
  8008f1:	74 09                	je     8008fc <strlcpy+0x32>
  8008f3:	0f b6 19             	movzbl (%ecx),%ebx
  8008f6:	84 db                	test   %bl,%bl
  8008f8:	75 ec                	jne    8008e6 <strlcpy+0x1c>
  8008fa:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ff:	29 f0                	sub    %esi,%eax
}
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090e:	eb 06                	jmp    800916 <strcmp+0x11>
		p++, q++;
  800910:	83 c1 01             	add    $0x1,%ecx
  800913:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800916:	0f b6 01             	movzbl (%ecx),%eax
  800919:	84 c0                	test   %al,%al
  80091b:	74 04                	je     800921 <strcmp+0x1c>
  80091d:	3a 02                	cmp    (%edx),%al
  80091f:	74 ef                	je     800910 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800921:	0f b6 c0             	movzbl %al,%eax
  800924:	0f b6 12             	movzbl (%edx),%edx
  800927:	29 d0                	sub    %edx,%eax
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  800935:	89 c3                	mov    %eax,%ebx
  800937:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80093a:	eb 06                	jmp    800942 <strncmp+0x17>
		n--, p++, q++;
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800942:	39 d8                	cmp    %ebx,%eax
  800944:	74 15                	je     80095b <strncmp+0x30>
  800946:	0f b6 08             	movzbl (%eax),%ecx
  800949:	84 c9                	test   %cl,%cl
  80094b:	74 04                	je     800951 <strncmp+0x26>
  80094d:	3a 0a                	cmp    (%edx),%cl
  80094f:	74 eb                	je     80093c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 00             	movzbl (%eax),%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
  800959:	eb 05                	jmp    800960 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800960:	5b                   	pop    %ebx
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096d:	eb 07                	jmp    800976 <strchr+0x13>
		if (*s == c)
  80096f:	38 ca                	cmp    %cl,%dl
  800971:	74 0f                	je     800982 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	0f b6 10             	movzbl (%eax),%edx
  800979:	84 d2                	test   %dl,%dl
  80097b:	75 f2                	jne    80096f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098e:	eb 03                	jmp    800993 <strfind+0xf>
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800996:	38 ca                	cmp    %cl,%dl
  800998:	74 04                	je     80099e <strfind+0x1a>
  80099a:	84 d2                	test   %dl,%dl
  80099c:	75 f2                	jne    800990 <strfind+0xc>
			break;
	return (char *) s;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ac:	85 c9                	test   %ecx,%ecx
  8009ae:	74 36                	je     8009e6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b6:	75 28                	jne    8009e0 <memset+0x40>
  8009b8:	f6 c1 03             	test   $0x3,%cl
  8009bb:	75 23                	jne    8009e0 <memset+0x40>
		c &= 0xFF;
  8009bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 08             	shl    $0x8,%ebx
  8009c6:	89 d6                	mov    %edx,%esi
  8009c8:	c1 e6 18             	shl    $0x18,%esi
  8009cb:	89 d0                	mov    %edx,%eax
  8009cd:	c1 e0 10             	shl    $0x10,%eax
  8009d0:	09 f0                	or     %esi,%eax
  8009d2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009d4:	89 d8                	mov    %ebx,%eax
  8009d6:	09 d0                	or     %edx,%eax
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
  8009db:	fc                   	cld    
  8009dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009de:	eb 06                	jmp    8009e6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e3:	fc                   	cld    
  8009e4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e6:	89 f8                	mov    %edi,%eax
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	57                   	push   %edi
  8009f1:	56                   	push   %esi
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fb:	39 c6                	cmp    %eax,%esi
  8009fd:	73 35                	jae    800a34 <memmove+0x47>
  8009ff:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	73 2e                	jae    800a34 <memmove+0x47>
		s += n;
		d += n;
  800a06:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a09:	89 d6                	mov    %edx,%esi
  800a0b:	09 fe                	or     %edi,%esi
  800a0d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a13:	75 13                	jne    800a28 <memmove+0x3b>
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 0e                	jne    800a28 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a1a:	83 ef 04             	sub    $0x4,%edi
  800a1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a20:	c1 e9 02             	shr    $0x2,%ecx
  800a23:	fd                   	std    
  800a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a26:	eb 09                	jmp    800a31 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a28:	83 ef 01             	sub    $0x1,%edi
  800a2b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a2e:	fd                   	std    
  800a2f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a31:	fc                   	cld    
  800a32:	eb 1d                	jmp    800a51 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	89 f2                	mov    %esi,%edx
  800a36:	09 c2                	or     %eax,%edx
  800a38:	f6 c2 03             	test   $0x3,%dl
  800a3b:	75 0f                	jne    800a4c <memmove+0x5f>
  800a3d:	f6 c1 03             	test   $0x3,%cl
  800a40:	75 0a                	jne    800a4c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a42:	c1 e9 02             	shr    $0x2,%ecx
  800a45:	89 c7                	mov    %eax,%edi
  800a47:	fc                   	cld    
  800a48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4a:	eb 05                	jmp    800a51 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4c:	89 c7                	mov    %eax,%edi
  800a4e:	fc                   	cld    
  800a4f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a58:	ff 75 10             	pushl  0x10(%ebp)
  800a5b:	ff 75 0c             	pushl  0xc(%ebp)
  800a5e:	ff 75 08             	pushl  0x8(%ebp)
  800a61:	e8 87 ff ff ff       	call   8009ed <memmove>
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a73:	89 c6                	mov    %eax,%esi
  800a75:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a78:	eb 1a                	jmp    800a94 <memcmp+0x2c>
		if (*s1 != *s2)
  800a7a:	0f b6 08             	movzbl (%eax),%ecx
  800a7d:	0f b6 1a             	movzbl (%edx),%ebx
  800a80:	38 d9                	cmp    %bl,%cl
  800a82:	74 0a                	je     800a8e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a84:	0f b6 c1             	movzbl %cl,%eax
  800a87:	0f b6 db             	movzbl %bl,%ebx
  800a8a:	29 d8                	sub    %ebx,%eax
  800a8c:	eb 0f                	jmp    800a9d <memcmp+0x35>
		s1++, s2++;
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a94:	39 f0                	cmp    %esi,%eax
  800a96:	75 e2                	jne    800a7a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	53                   	push   %ebx
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa8:	89 c1                	mov    %eax,%ecx
  800aaa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aad:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab1:	eb 0a                	jmp    800abd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab3:	0f b6 10             	movzbl (%eax),%edx
  800ab6:	39 da                	cmp    %ebx,%edx
  800ab8:	74 07                	je     800ac1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	39 c8                	cmp    %ecx,%eax
  800abf:	72 f2                	jb     800ab3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad0:	eb 03                	jmp    800ad5 <strtol+0x11>
		s++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad5:	0f b6 01             	movzbl (%ecx),%eax
  800ad8:	3c 20                	cmp    $0x20,%al
  800ada:	74 f6                	je     800ad2 <strtol+0xe>
  800adc:	3c 09                	cmp    $0x9,%al
  800ade:	74 f2                	je     800ad2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae0:	3c 2b                	cmp    $0x2b,%al
  800ae2:	75 0a                	jne    800aee <strtol+0x2a>
		s++;
  800ae4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aec:	eb 11                	jmp    800aff <strtol+0x3b>
  800aee:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af3:	3c 2d                	cmp    $0x2d,%al
  800af5:	75 08                	jne    800aff <strtol+0x3b>
		s++, neg = 1;
  800af7:	83 c1 01             	add    $0x1,%ecx
  800afa:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b05:	75 15                	jne    800b1c <strtol+0x58>
  800b07:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0a:	75 10                	jne    800b1c <strtol+0x58>
  800b0c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b10:	75 7c                	jne    800b8e <strtol+0xca>
		s += 2, base = 16;
  800b12:	83 c1 02             	add    $0x2,%ecx
  800b15:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1a:	eb 16                	jmp    800b32 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b1c:	85 db                	test   %ebx,%ebx
  800b1e:	75 12                	jne    800b32 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b20:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b25:	80 39 30             	cmpb   $0x30,(%ecx)
  800b28:	75 08                	jne    800b32 <strtol+0x6e>
		s++, base = 8;
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3a:	0f b6 11             	movzbl (%ecx),%edx
  800b3d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b40:	89 f3                	mov    %esi,%ebx
  800b42:	80 fb 09             	cmp    $0x9,%bl
  800b45:	77 08                	ja     800b4f <strtol+0x8b>
			dig = *s - '0';
  800b47:	0f be d2             	movsbl %dl,%edx
  800b4a:	83 ea 30             	sub    $0x30,%edx
  800b4d:	eb 22                	jmp    800b71 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b4f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b52:	89 f3                	mov    %esi,%ebx
  800b54:	80 fb 19             	cmp    $0x19,%bl
  800b57:	77 08                	ja     800b61 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b59:	0f be d2             	movsbl %dl,%edx
  800b5c:	83 ea 57             	sub    $0x57,%edx
  800b5f:	eb 10                	jmp    800b71 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b61:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b64:	89 f3                	mov    %esi,%ebx
  800b66:	80 fb 19             	cmp    $0x19,%bl
  800b69:	77 16                	ja     800b81 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b6b:	0f be d2             	movsbl %dl,%edx
  800b6e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b71:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b74:	7d 0b                	jge    800b81 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b76:	83 c1 01             	add    $0x1,%ecx
  800b79:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b7f:	eb b9                	jmp    800b3a <strtol+0x76>

	if (endptr)
  800b81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b85:	74 0d                	je     800b94 <strtol+0xd0>
		*endptr = (char *) s;
  800b87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8a:	89 0e                	mov    %ecx,(%esi)
  800b8c:	eb 06                	jmp    800b94 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8e:	85 db                	test   %ebx,%ebx
  800b90:	74 98                	je     800b2a <strtol+0x66>
  800b92:	eb 9e                	jmp    800b32 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b94:	89 c2                	mov    %eax,%edx
  800b96:	f7 da                	neg    %edx
  800b98:	85 ff                	test   %edi,%edi
  800b9a:	0f 45 c2             	cmovne %edx,%eax
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 c3                	mov    %eax,%ebx
  800bb5:	89 c7                	mov    %eax,%edi
  800bb7:	89 c6                	mov    %eax,%esi
  800bb9:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd0:	89 d1                	mov    %edx,%ecx
  800bd2:	89 d3                	mov    %edx,%ebx
  800bd4:	89 d7                	mov    %edx,%edi
  800bd6:	89 d6                	mov    %edx,%esi
  800bd8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800be8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bed:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 cb                	mov    %ecx,%ebx
  800bf7:	89 cf                	mov    %ecx,%edi
  800bf9:	89 ce                	mov    %ecx,%esi
  800bfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 03                	push   $0x3
  800c07:	68 ff 26 80 00       	push   $0x8026ff
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 1c 27 80 00       	push   $0x80271c
  800c13:	e8 a0 13 00 00       	call   801fb8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c26:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c30:	89 d1                	mov    %edx,%ecx
  800c32:	89 d3                	mov    %edx,%ebx
  800c34:	89 d7                	mov    %edx,%edi
  800c36:	89 d6                	mov    %edx,%esi
  800c38:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_yield>:

void
sys_yield(void)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c45:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4f:	89 d1                	mov    %edx,%ecx
  800c51:	89 d3                	mov    %edx,%ebx
  800c53:	89 d7                	mov    %edx,%edi
  800c55:	89 d6                	mov    %edx,%esi
  800c57:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c67:	be 00 00 00 00       	mov    $0x0,%esi
  800c6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7a:	89 f7                	mov    %esi,%edi
  800c7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 04                	push   $0x4
  800c88:	68 ff 26 80 00       	push   $0x8026ff
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 1c 27 80 00       	push   $0x80271c
  800c94:	e8 1f 13 00 00       	call   801fb8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800caa:	b8 05 00 00 00       	mov    $0x5,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 17                	jle    800cdb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	50                   	push   %eax
  800cc8:	6a 05                	push   $0x5
  800cca:	68 ff 26 80 00       	push   $0x8026ff
  800ccf:	6a 23                	push   $0x23
  800cd1:	68 1c 27 80 00       	push   $0x80271c
  800cd6:	e8 dd 12 00 00       	call   801fb8 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	89 df                	mov    %ebx,%edi
  800cfe:	89 de                	mov    %ebx,%esi
  800d00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7e 17                	jle    800d1d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 06                	push   $0x6
  800d0c:	68 ff 26 80 00       	push   $0x8026ff
  800d11:	6a 23                	push   $0x23
  800d13:	68 1c 27 80 00       	push   $0x80271c
  800d18:	e8 9b 12 00 00       	call   801fb8 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 08 00 00 00       	mov    $0x8,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 08                	push   $0x8
  800d4e:	68 ff 26 80 00       	push   $0x8026ff
  800d53:	6a 23                	push   $0x23
  800d55:	68 1c 27 80 00       	push   $0x80271c
  800d5a:	e8 59 12 00 00       	call   801fb8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 09                	push   $0x9
  800d90:	68 ff 26 80 00       	push   $0x8026ff
  800d95:	6a 23                	push   $0x23
  800d97:	68 1c 27 80 00       	push   $0x80271c
  800d9c:	e8 17 12 00 00       	call   801fb8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800db7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 17                	jle    800de3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 0a                	push   $0xa
  800dd2:	68 ff 26 80 00       	push   $0x8026ff
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 1c 27 80 00       	push   $0x80271c
  800dde:	e8 d5 11 00 00       	call   801fb8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800df1:	be 00 00 00 00       	mov    $0x0,%esi
  800df6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e07:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	89 cb                	mov    %ecx,%ebx
  800e26:	89 cf                	mov    %ecx,%edi
  800e28:	89 ce                	mov    %ecx,%esi
  800e2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 17                	jle    800e47 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	83 ec 0c             	sub    $0xc,%esp
  800e33:	50                   	push   %eax
  800e34:	6a 0d                	push   $0xd
  800e36:	68 ff 26 80 00       	push   $0x8026ff
  800e3b:	6a 23                	push   $0x23
  800e3d:	68 1c 27 80 00       	push   $0x80271c
  800e42:	e8 71 11 00 00       	call   801fb8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e57:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800e59:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e5d:	74 11                	je     800e70 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800e5f:	89 d8                	mov    %ebx,%eax
  800e61:	c1 e8 0c             	shr    $0xc,%eax
  800e64:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800e6b:	f6 c4 08             	test   $0x8,%ah
  800e6e:	75 14                	jne    800e84 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	68 2a 27 80 00       	push   $0x80272a
  800e78:	6a 21                	push   $0x21
  800e7a:	68 40 27 80 00       	push   $0x802740
  800e7f:	e8 34 11 00 00       	call   801fb8 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800e84:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800e8a:	e8 91 fd ff ff       	call   800c20 <sys_getenvid>
  800e8f:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	6a 07                	push   $0x7
  800e96:	68 00 f0 7f 00       	push   $0x7ff000
  800e9b:	50                   	push   %eax
  800e9c:	e8 bd fd ff ff       	call   800c5e <sys_page_alloc>
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	79 14                	jns    800ebc <pgfault+0x6d>
		panic("sys_page_alloc");
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	68 4b 27 80 00       	push   $0x80274b
  800eb0:	6a 30                	push   $0x30
  800eb2:	68 40 27 80 00       	push   $0x802740
  800eb7:	e8 fc 10 00 00       	call   801fb8 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	68 00 10 00 00       	push   $0x1000
  800ec4:	53                   	push   %ebx
  800ec5:	68 00 f0 7f 00       	push   $0x7ff000
  800eca:	e8 86 fb ff ff       	call   800a55 <memcpy>
	retv = sys_page_unmap(envid, addr);
  800ecf:	83 c4 08             	add    $0x8,%esp
  800ed2:	53                   	push   %ebx
  800ed3:	56                   	push   %esi
  800ed4:	e8 0a fe ff ff       	call   800ce3 <sys_page_unmap>
	if(retv < 0){
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	79 12                	jns    800ef2 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800ee0:	50                   	push   %eax
  800ee1:	68 38 28 80 00       	push   $0x802838
  800ee6:	6a 35                	push   $0x35
  800ee8:	68 40 27 80 00       	push   $0x802740
  800eed:	e8 c6 10 00 00       	call   801fb8 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800ef2:	83 ec 0c             	sub    $0xc,%esp
  800ef5:	6a 07                	push   $0x7
  800ef7:	53                   	push   %ebx
  800ef8:	56                   	push   %esi
  800ef9:	68 00 f0 7f 00       	push   $0x7ff000
  800efe:	56                   	push   %esi
  800eff:	e8 9d fd ff ff       	call   800ca1 <sys_page_map>
	if(retv < 0){
  800f04:	83 c4 20             	add    $0x20,%esp
  800f07:	85 c0                	test   %eax,%eax
  800f09:	79 14                	jns    800f1f <pgfault+0xd0>
		panic("sys_page_map");
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	68 5a 27 80 00       	push   $0x80275a
  800f13:	6a 39                	push   $0x39
  800f15:	68 40 27 80 00       	push   $0x802740
  800f1a:	e8 99 10 00 00       	call   801fb8 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	68 00 f0 7f 00       	push   $0x7ff000
  800f27:	56                   	push   %esi
  800f28:	e8 b6 fd ff ff       	call   800ce3 <sys_page_unmap>
	if(retv < 0){
  800f2d:	83 c4 10             	add    $0x10,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	79 14                	jns    800f48 <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	68 67 27 80 00       	push   $0x802767
  800f3c:	6a 3d                	push   $0x3d
  800f3e:	68 40 27 80 00       	push   $0x802740
  800f43:	e8 70 10 00 00       	call   801fb8 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800f48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800f57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f5a:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800f5d:	83 ec 08             	sub    $0x8,%esp
  800f60:	53                   	push   %ebx
  800f61:	68 84 27 80 00       	push   $0x802784
  800f66:	e8 21 f3 ff ff       	call   80028c <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f6b:	83 c4 0c             	add    $0xc,%esp
  800f6e:	6a 07                	push   $0x7
  800f70:	53                   	push   %ebx
  800f71:	56                   	push   %esi
  800f72:	e8 e7 fc ff ff       	call   800c5e <sys_page_alloc>
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	79 15                	jns    800f93 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800f7e:	50                   	push   %eax
  800f7f:	68 97 27 80 00       	push   $0x802797
  800f84:	68 90 00 00 00       	push   $0x90
  800f89:	68 40 27 80 00       	push   $0x802740
  800f8e:	e8 25 10 00 00       	call   801fb8 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800f93:	83 ec 0c             	sub    $0xc,%esp
  800f96:	68 aa 27 80 00       	push   $0x8027aa
  800f9b:	e8 ec f2 ff ff       	call   80028c <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fa0:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fa7:	68 00 00 40 00       	push   $0x400000
  800fac:	6a 00                	push   $0x0
  800fae:	53                   	push   %ebx
  800faf:	56                   	push   %esi
  800fb0:	e8 ec fc ff ff       	call   800ca1 <sys_page_map>
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 15                	jns    800fd1 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  800fbc:	50                   	push   %eax
  800fbd:	68 b2 27 80 00       	push   $0x8027b2
  800fc2:	68 94 00 00 00       	push   $0x94
  800fc7:	68 40 27 80 00       	push   $0x802740
  800fcc:	e8 e7 0f 00 00       	call   801fb8 <_panic>
        cprintf("af_p_m.");
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	68 c3 27 80 00       	push   $0x8027c3
  800fd9:	e8 ae f2 ff ff       	call   80028c <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  800fde:	83 c4 0c             	add    $0xc,%esp
  800fe1:	68 00 10 00 00       	push   $0x1000
  800fe6:	53                   	push   %ebx
  800fe7:	68 00 00 40 00       	push   $0x400000
  800fec:	e8 fc f9 ff ff       	call   8009ed <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  800ff1:	c7 04 24 cb 27 80 00 	movl   $0x8027cb,(%esp)
  800ff8:	e8 8f f2 ff ff       	call   80028c <cprintf>
}
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  801010:	68 4f 0e 80 00       	push   $0x800e4f
  801015:	e8 e4 0f 00 00       	call   801ffe <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80101a:	b8 07 00 00 00       	mov    $0x7,%eax
  80101f:	cd 30                	int    $0x30
  801021:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801024:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	85 c0                	test   %eax,%eax
  80102c:	79 17                	jns    801045 <fork+0x3e>
		panic("sys_exofork failed.");
  80102e:	83 ec 04             	sub    $0x4,%esp
  801031:	68 d9 27 80 00       	push   $0x8027d9
  801036:	68 b7 00 00 00       	push   $0xb7
  80103b:	68 40 27 80 00       	push   $0x802740
  801040:	e8 73 0f 00 00       	call   801fb8 <_panic>
  801045:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  80104a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80104e:	75 21                	jne    801071 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801050:	e8 cb fb ff ff       	call   800c20 <sys_getenvid>
  801055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80105a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80105d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801062:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  801067:	b8 00 00 00 00       	mov    $0x0,%eax
  80106c:	e9 69 01 00 00       	jmp    8011da <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801071:	89 d8                	mov    %ebx,%eax
  801073:	c1 e8 16             	shr    $0x16,%eax
  801076:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  80107d:	a8 01                	test   $0x1,%al
  80107f:	0f 84 d6 00 00 00    	je     80115b <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  801085:	89 de                	mov    %ebx,%esi
  801087:	c1 ee 0c             	shr    $0xc,%esi
  80108a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801091:	a8 01                	test   $0x1,%al
  801093:	0f 84 c2 00 00 00    	je     80115b <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  801099:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  8010a0:	89 f7                	mov    %esi,%edi
  8010a2:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  8010a5:	e8 76 fb ff ff       	call   800c20 <sys_getenvid>
  8010aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  8010ad:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b4:	f6 c4 04             	test   $0x4,%ah
  8010b7:	74 1c                	je     8010d5 <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	68 07 0e 00 00       	push   $0xe07
  8010c1:	57                   	push   %edi
  8010c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8010c5:	57                   	push   %edi
  8010c6:	6a 00                	push   $0x0
  8010c8:	e8 d4 fb ff ff       	call   800ca1 <sys_page_map>
  8010cd:	83 c4 20             	add    $0x20,%esp
  8010d0:	e9 86 00 00 00       	jmp    80115b <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  8010d5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010dc:	a8 02                	test   $0x2,%al
  8010de:	75 0c                	jne    8010ec <fork+0xe5>
  8010e0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e7:	f6 c4 08             	test   $0x8,%ah
  8010ea:	74 5b                	je     801147 <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	68 05 08 00 00       	push   $0x805
  8010f4:	57                   	push   %edi
  8010f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f8:	57                   	push   %edi
  8010f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fc:	e8 a0 fb ff ff       	call   800ca1 <sys_page_map>
  801101:	83 c4 20             	add    $0x20,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	79 12                	jns    80111a <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  801108:	50                   	push   %eax
  801109:	68 5c 28 80 00       	push   $0x80285c
  80110e:	6a 5f                	push   $0x5f
  801110:	68 40 27 80 00       	push   $0x802740
  801115:	e8 9e 0e 00 00       	call   801fb8 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	68 05 08 00 00       	push   $0x805
  801122:	57                   	push   %edi
  801123:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801126:	50                   	push   %eax
  801127:	57                   	push   %edi
  801128:	50                   	push   %eax
  801129:	e8 73 fb ff ff       	call   800ca1 <sys_page_map>
  80112e:	83 c4 20             	add    $0x20,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	79 26                	jns    80115b <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  801135:	50                   	push   %eax
  801136:	68 80 28 80 00       	push   $0x802880
  80113b:	6a 64                	push   $0x64
  80113d:	68 40 27 80 00       	push   $0x802740
  801142:	e8 71 0e 00 00       	call   801fb8 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801147:	83 ec 0c             	sub    $0xc,%esp
  80114a:	6a 05                	push   $0x5
  80114c:	57                   	push   %edi
  80114d:	ff 75 e0             	pushl  -0x20(%ebp)
  801150:	57                   	push   %edi
  801151:	6a 00                	push   $0x0
  801153:	e8 49 fb ff ff       	call   800ca1 <sys_page_map>
  801158:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80115b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801161:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801167:	0f 85 04 ff ff ff    	jne    801071 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	6a 07                	push   $0x7
  801172:	68 00 f0 bf ee       	push   $0xeebff000
  801177:	ff 75 dc             	pushl  -0x24(%ebp)
  80117a:	e8 df fa ff ff       	call   800c5e <sys_page_alloc>
	if(retv < 0){
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	79 17                	jns    80119d <fork+0x196>
		panic("sys_page_alloc failed.\n");
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	68 ed 27 80 00       	push   $0x8027ed
  80118e:	68 cc 00 00 00       	push   $0xcc
  801193:	68 40 27 80 00       	push   $0x802740
  801198:	e8 1b 0e 00 00       	call   801fb8 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	68 63 20 80 00       	push   $0x802063
  8011a5:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8011a8:	57                   	push   %edi
  8011a9:	e8 fb fb ff ff       	call   800da9 <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  8011ae:	83 c4 08             	add    $0x8,%esp
  8011b1:	6a 02                	push   $0x2
  8011b3:	57                   	push   %edi
  8011b4:	e8 6c fb ff ff       	call   800d25 <sys_env_set_status>
	if(retv < 0){
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	79 17                	jns    8011d7 <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	68 05 28 80 00       	push   $0x802805
  8011c8:	68 dd 00 00 00       	push   $0xdd
  8011cd:	68 40 27 80 00       	push   $0x802740
  8011d2:	e8 e1 0d 00 00       	call   801fb8 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  8011d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  8011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <sfork>:

// Challenge!
int
sfork(void)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011e8:	68 21 28 80 00       	push   $0x802821
  8011ed:	68 e8 00 00 00       	push   $0xe8
  8011f2:	68 40 27 80 00       	push   $0x802740
  8011f7:	e8 bc 0d 00 00       	call   801fb8 <_panic>

008011fc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801204:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	ff 75 0c             	pushl  0xc(%ebp)
  80120d:	e8 fc fb ff ff       	call   800e0e <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 f6                	test   %esi,%esi
  801217:	74 1c                	je     801235 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801219:	a1 04 40 80 00       	mov    0x804004,%eax
  80121e:	8b 40 78             	mov    0x78(%eax),%eax
  801221:	89 06                	mov    %eax,(%esi)
  801223:	eb 10                	jmp    801235 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801225:	83 ec 0c             	sub    $0xc,%esp
  801228:	68 a2 28 80 00       	push   $0x8028a2
  80122d:	e8 5a f0 ff ff       	call   80028c <cprintf>
  801232:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801235:	a1 04 40 80 00       	mov    0x804004,%eax
  80123a:	8b 50 74             	mov    0x74(%eax),%edx
  80123d:	85 d2                	test   %edx,%edx
  80123f:	74 e4                	je     801225 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801241:	85 db                	test   %ebx,%ebx
  801243:	74 05                	je     80124a <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801245:	8b 40 74             	mov    0x74(%eax),%eax
  801248:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80124a:	a1 04 40 80 00       	mov    0x804004,%eax
  80124f:	8b 40 70             	mov    0x70(%eax),%eax

}
  801252:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	57                   	push   %edi
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	83 ec 0c             	sub    $0xc,%esp
  801262:	8b 7d 08             	mov    0x8(%ebp),%edi
  801265:	8b 75 0c             	mov    0xc(%ebp),%esi
  801268:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  80126b:	85 db                	test   %ebx,%ebx
  80126d:	75 13                	jne    801282 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  80126f:	6a 00                	push   $0x0
  801271:	68 00 00 c0 ee       	push   $0xeec00000
  801276:	56                   	push   %esi
  801277:	57                   	push   %edi
  801278:	e8 6e fb ff ff       	call   800deb <sys_ipc_try_send>
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	eb 0e                	jmp    801290 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801282:	ff 75 14             	pushl  0x14(%ebp)
  801285:	53                   	push   %ebx
  801286:	56                   	push   %esi
  801287:	57                   	push   %edi
  801288:	e8 5e fb ff ff       	call   800deb <sys_ipc_try_send>
  80128d:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801290:	85 c0                	test   %eax,%eax
  801292:	75 d7                	jne    80126b <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5f                   	pop    %edi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012a7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012aa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012b0:	8b 52 50             	mov    0x50(%edx),%edx
  8012b3:	39 ca                	cmp    %ecx,%edx
  8012b5:	75 0d                	jne    8012c4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8012b7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	eb 0f                	jmp    8012d3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012c4:	83 c0 01             	add    $0x1,%eax
  8012c7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012cc:	75 d9                	jne    8012a7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012db:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e0:	c1 e8 0c             	shr    $0xc,%eax
}
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012eb:	05 00 00 00 30       	add    $0x30000000,%eax
  8012f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801302:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801307:	89 c2                	mov    %eax,%edx
  801309:	c1 ea 16             	shr    $0x16,%edx
  80130c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801313:	f6 c2 01             	test   $0x1,%dl
  801316:	74 11                	je     801329 <fd_alloc+0x2d>
  801318:	89 c2                	mov    %eax,%edx
  80131a:	c1 ea 0c             	shr    $0xc,%edx
  80131d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801324:	f6 c2 01             	test   $0x1,%dl
  801327:	75 09                	jne    801332 <fd_alloc+0x36>
			*fd_store = fd;
  801329:	89 01                	mov    %eax,(%ecx)
			return 0;
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
  801330:	eb 17                	jmp    801349 <fd_alloc+0x4d>
  801332:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801337:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80133c:	75 c9                	jne    801307 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80133e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801344:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801351:	83 f8 1f             	cmp    $0x1f,%eax
  801354:	77 36                	ja     80138c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801356:	c1 e0 0c             	shl    $0xc,%eax
  801359:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80135e:	89 c2                	mov    %eax,%edx
  801360:	c1 ea 16             	shr    $0x16,%edx
  801363:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80136a:	f6 c2 01             	test   $0x1,%dl
  80136d:	74 24                	je     801393 <fd_lookup+0x48>
  80136f:	89 c2                	mov    %eax,%edx
  801371:	c1 ea 0c             	shr    $0xc,%edx
  801374:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137b:	f6 c2 01             	test   $0x1,%dl
  80137e:	74 1a                	je     80139a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801380:	8b 55 0c             	mov    0xc(%ebp),%edx
  801383:	89 02                	mov    %eax,(%edx)
	return 0;
  801385:	b8 00 00 00 00       	mov    $0x0,%eax
  80138a:	eb 13                	jmp    80139f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801391:	eb 0c                	jmp    80139f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801398:	eb 05                	jmp    80139f <fd_lookup+0x54>
  80139a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013aa:	ba 30 29 80 00       	mov    $0x802930,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013af:	eb 13                	jmp    8013c4 <dev_lookup+0x23>
  8013b1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013b4:	39 08                	cmp    %ecx,(%eax)
  8013b6:	75 0c                	jne    8013c4 <dev_lookup+0x23>
			*dev = devtab[i];
  8013b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c2:	eb 2e                	jmp    8013f2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013c4:	8b 02                	mov    (%edx),%eax
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	75 e7                	jne    8013b1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8013cf:	8b 40 48             	mov    0x48(%eax),%eax
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	51                   	push   %ecx
  8013d6:	50                   	push   %eax
  8013d7:	68 b4 28 80 00       	push   $0x8028b4
  8013dc:	e8 ab ee ff ff       	call   80028c <cprintf>
	*dev = 0;
  8013e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
  8013f9:	83 ec 10             	sub    $0x10,%esp
  8013fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80140c:	c1 e8 0c             	shr    $0xc,%eax
  80140f:	50                   	push   %eax
  801410:	e8 36 ff ff ff       	call   80134b <fd_lookup>
  801415:	83 c4 08             	add    $0x8,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 05                	js     801421 <fd_close+0x2d>
	    || fd != fd2)
  80141c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80141f:	74 0c                	je     80142d <fd_close+0x39>
		return (must_exist ? r : 0);
  801421:	84 db                	test   %bl,%bl
  801423:	ba 00 00 00 00       	mov    $0x0,%edx
  801428:	0f 44 c2             	cmove  %edx,%eax
  80142b:	eb 41                	jmp    80146e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	ff 36                	pushl  (%esi)
  801436:	e8 66 ff ff ff       	call   8013a1 <dev_lookup>
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 1a                	js     80145e <fd_close+0x6a>
		if (dev->dev_close)
  801444:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801447:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80144a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80144f:	85 c0                	test   %eax,%eax
  801451:	74 0b                	je     80145e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	56                   	push   %esi
  801457:	ff d0                	call   *%eax
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	56                   	push   %esi
  801462:	6a 00                	push   $0x0
  801464:	e8 7a f8 ff ff       	call   800ce3 <sys_page_unmap>
	return r;
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	89 d8                	mov    %ebx,%eax
}
  80146e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801471:	5b                   	pop    %ebx
  801472:	5e                   	pop    %esi
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	ff 75 08             	pushl  0x8(%ebp)
  801482:	e8 c4 fe ff ff       	call   80134b <fd_lookup>
  801487:	83 c4 08             	add    $0x8,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 10                	js     80149e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	6a 01                	push   $0x1
  801493:	ff 75 f4             	pushl  -0xc(%ebp)
  801496:	e8 59 ff ff ff       	call   8013f4 <fd_close>
  80149b:	83 c4 10             	add    $0x10,%esp
}
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <close_all>:

void
close_all(void)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	53                   	push   %ebx
  8014b0:	e8 c0 ff ff ff       	call   801475 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b5:	83 c3 01             	add    $0x1,%ebx
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	83 fb 20             	cmp    $0x20,%ebx
  8014be:	75 ec                	jne    8014ac <close_all+0xc>
		close(i);
}
  8014c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	57                   	push   %edi
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 2c             	sub    $0x2c,%esp
  8014ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	ff 75 08             	pushl  0x8(%ebp)
  8014d8:	e8 6e fe ff ff       	call   80134b <fd_lookup>
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	0f 88 c1 00 00 00    	js     8015a9 <dup+0xe4>
		return r;
	close(newfdnum);
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	56                   	push   %esi
  8014ec:	e8 84 ff ff ff       	call   801475 <close>

	newfd = INDEX2FD(newfdnum);
  8014f1:	89 f3                	mov    %esi,%ebx
  8014f3:	c1 e3 0c             	shl    $0xc,%ebx
  8014f6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014fc:	83 c4 04             	add    $0x4,%esp
  8014ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801502:	e8 de fd ff ff       	call   8012e5 <fd2data>
  801507:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801509:	89 1c 24             	mov    %ebx,(%esp)
  80150c:	e8 d4 fd ff ff       	call   8012e5 <fd2data>
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801517:	89 f8                	mov    %edi,%eax
  801519:	c1 e8 16             	shr    $0x16,%eax
  80151c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801523:	a8 01                	test   $0x1,%al
  801525:	74 37                	je     80155e <dup+0x99>
  801527:	89 f8                	mov    %edi,%eax
  801529:	c1 e8 0c             	shr    $0xc,%eax
  80152c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801533:	f6 c2 01             	test   $0x1,%dl
  801536:	74 26                	je     80155e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801538:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153f:	83 ec 0c             	sub    $0xc,%esp
  801542:	25 07 0e 00 00       	and    $0xe07,%eax
  801547:	50                   	push   %eax
  801548:	ff 75 d4             	pushl  -0x2c(%ebp)
  80154b:	6a 00                	push   $0x0
  80154d:	57                   	push   %edi
  80154e:	6a 00                	push   $0x0
  801550:	e8 4c f7 ff ff       	call   800ca1 <sys_page_map>
  801555:	89 c7                	mov    %eax,%edi
  801557:	83 c4 20             	add    $0x20,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 2e                	js     80158c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80155e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801561:	89 d0                	mov    %edx,%eax
  801563:	c1 e8 0c             	shr    $0xc,%eax
  801566:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	25 07 0e 00 00       	and    $0xe07,%eax
  801575:	50                   	push   %eax
  801576:	53                   	push   %ebx
  801577:	6a 00                	push   $0x0
  801579:	52                   	push   %edx
  80157a:	6a 00                	push   $0x0
  80157c:	e8 20 f7 ff ff       	call   800ca1 <sys_page_map>
  801581:	89 c7                	mov    %eax,%edi
  801583:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801586:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801588:	85 ff                	test   %edi,%edi
  80158a:	79 1d                	jns    8015a9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	53                   	push   %ebx
  801590:	6a 00                	push   $0x0
  801592:	e8 4c f7 ff ff       	call   800ce3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80159d:	6a 00                	push   $0x0
  80159f:	e8 3f f7 ff ff       	call   800ce3 <sys_page_unmap>
	return r;
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	89 f8                	mov    %edi,%eax
}
  8015a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5f                   	pop    %edi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 14             	sub    $0x14,%esp
  8015b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015be:	50                   	push   %eax
  8015bf:	53                   	push   %ebx
  8015c0:	e8 86 fd ff ff       	call   80134b <fd_lookup>
  8015c5:	83 c4 08             	add    $0x8,%esp
  8015c8:	89 c2                	mov    %eax,%edx
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 6d                	js     80163b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ce:	83 ec 08             	sub    $0x8,%esp
  8015d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d4:	50                   	push   %eax
  8015d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d8:	ff 30                	pushl  (%eax)
  8015da:	e8 c2 fd ff ff       	call   8013a1 <dev_lookup>
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 4c                	js     801632 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e9:	8b 42 08             	mov    0x8(%edx),%eax
  8015ec:	83 e0 03             	and    $0x3,%eax
  8015ef:	83 f8 01             	cmp    $0x1,%eax
  8015f2:	75 21                	jne    801615 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8015f9:	8b 40 48             	mov    0x48(%eax),%eax
  8015fc:	83 ec 04             	sub    $0x4,%esp
  8015ff:	53                   	push   %ebx
  801600:	50                   	push   %eax
  801601:	68 f5 28 80 00       	push   $0x8028f5
  801606:	e8 81 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801613:	eb 26                	jmp    80163b <read+0x8a>
	}
	if (!dev->dev_read)
  801615:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801618:	8b 40 08             	mov    0x8(%eax),%eax
  80161b:	85 c0                	test   %eax,%eax
  80161d:	74 17                	je     801636 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	ff 75 10             	pushl  0x10(%ebp)
  801625:	ff 75 0c             	pushl  0xc(%ebp)
  801628:	52                   	push   %edx
  801629:	ff d0                	call   *%eax
  80162b:	89 c2                	mov    %eax,%edx
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	eb 09                	jmp    80163b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801632:	89 c2                	mov    %eax,%edx
  801634:	eb 05                	jmp    80163b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801636:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80163b:	89 d0                	mov    %edx,%eax
  80163d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801640:	c9                   	leave  
  801641:	c3                   	ret    

00801642 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	57                   	push   %edi
  801646:	56                   	push   %esi
  801647:	53                   	push   %ebx
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80164e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801651:	bb 00 00 00 00       	mov    $0x0,%ebx
  801656:	eb 21                	jmp    801679 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	89 f0                	mov    %esi,%eax
  80165d:	29 d8                	sub    %ebx,%eax
  80165f:	50                   	push   %eax
  801660:	89 d8                	mov    %ebx,%eax
  801662:	03 45 0c             	add    0xc(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	57                   	push   %edi
  801667:	e8 45 ff ff ff       	call   8015b1 <read>
		if (m < 0)
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 10                	js     801683 <readn+0x41>
			return m;
		if (m == 0)
  801673:	85 c0                	test   %eax,%eax
  801675:	74 0a                	je     801681 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801677:	01 c3                	add    %eax,%ebx
  801679:	39 f3                	cmp    %esi,%ebx
  80167b:	72 db                	jb     801658 <readn+0x16>
  80167d:	89 d8                	mov    %ebx,%eax
  80167f:	eb 02                	jmp    801683 <readn+0x41>
  801681:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801686:	5b                   	pop    %ebx
  801687:	5e                   	pop    %esi
  801688:	5f                   	pop    %edi
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 14             	sub    $0x14,%esp
  801692:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801695:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	53                   	push   %ebx
  80169a:	e8 ac fc ff ff       	call   80134b <fd_lookup>
  80169f:	83 c4 08             	add    $0x8,%esp
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 68                	js     801710 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b2:	ff 30                	pushl  (%eax)
  8016b4:	e8 e8 fc ff ff       	call   8013a1 <dev_lookup>
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 47                	js     801707 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c7:	75 21                	jne    8016ea <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ce:	8b 40 48             	mov    0x48(%eax),%eax
  8016d1:	83 ec 04             	sub    $0x4,%esp
  8016d4:	53                   	push   %ebx
  8016d5:	50                   	push   %eax
  8016d6:	68 11 29 80 00       	push   $0x802911
  8016db:	e8 ac eb ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e8:	eb 26                	jmp    801710 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f0:	85 d2                	test   %edx,%edx
  8016f2:	74 17                	je     80170b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f4:	83 ec 04             	sub    $0x4,%esp
  8016f7:	ff 75 10             	pushl  0x10(%ebp)
  8016fa:	ff 75 0c             	pushl  0xc(%ebp)
  8016fd:	50                   	push   %eax
  8016fe:	ff d2                	call   *%edx
  801700:	89 c2                	mov    %eax,%edx
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	eb 09                	jmp    801710 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801707:	89 c2                	mov    %eax,%edx
  801709:	eb 05                	jmp    801710 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80170b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801710:	89 d0                	mov    %edx,%eax
  801712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <seek>:

int
seek(int fdnum, off_t offset)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	ff 75 08             	pushl  0x8(%ebp)
  801724:	e8 22 fc ff ff       	call   80134b <fd_lookup>
  801729:	83 c4 08             	add    $0x8,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	78 0e                	js     80173e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801730:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801733:	8b 55 0c             	mov    0xc(%ebp),%edx
  801736:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801739:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	83 ec 14             	sub    $0x14,%esp
  801747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174d:	50                   	push   %eax
  80174e:	53                   	push   %ebx
  80174f:	e8 f7 fb ff ff       	call   80134b <fd_lookup>
  801754:	83 c4 08             	add    $0x8,%esp
  801757:	89 c2                	mov    %eax,%edx
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 65                	js     8017c2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801767:	ff 30                	pushl  (%eax)
  801769:	e8 33 fc ff ff       	call   8013a1 <dev_lookup>
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	78 44                	js     8017b9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801775:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801778:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177c:	75 21                	jne    80179f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80177e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801783:	8b 40 48             	mov    0x48(%eax),%eax
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	53                   	push   %ebx
  80178a:	50                   	push   %eax
  80178b:	68 d4 28 80 00       	push   $0x8028d4
  801790:	e8 f7 ea ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80179d:	eb 23                	jmp    8017c2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80179f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a2:	8b 52 18             	mov    0x18(%edx),%edx
  8017a5:	85 d2                	test   %edx,%edx
  8017a7:	74 14                	je     8017bd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	ff 75 0c             	pushl  0xc(%ebp)
  8017af:	50                   	push   %eax
  8017b0:	ff d2                	call   *%edx
  8017b2:	89 c2                	mov    %eax,%edx
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	eb 09                	jmp    8017c2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b9:	89 c2                	mov    %eax,%edx
  8017bb:	eb 05                	jmp    8017c2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c2:	89 d0                	mov    %edx,%eax
  8017c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 14             	sub    $0x14,%esp
  8017d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	ff 75 08             	pushl  0x8(%ebp)
  8017da:	e8 6c fb ff ff       	call   80134b <fd_lookup>
  8017df:	83 c4 08             	add    $0x8,%esp
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 58                	js     801840 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ee:	50                   	push   %eax
  8017ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f2:	ff 30                	pushl  (%eax)
  8017f4:	e8 a8 fb ff ff       	call   8013a1 <dev_lookup>
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	78 37                	js     801837 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801800:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801803:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801807:	74 32                	je     80183b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801809:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80180c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801813:	00 00 00 
	stat->st_isdir = 0;
  801816:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80181d:	00 00 00 
	stat->st_dev = dev;
  801820:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	53                   	push   %ebx
  80182a:	ff 75 f0             	pushl  -0x10(%ebp)
  80182d:	ff 50 14             	call   *0x14(%eax)
  801830:	89 c2                	mov    %eax,%edx
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	eb 09                	jmp    801840 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801837:	89 c2                	mov    %eax,%edx
  801839:	eb 05                	jmp    801840 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80183b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801840:	89 d0                	mov    %edx,%eax
  801842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	6a 00                	push   $0x0
  801851:	ff 75 08             	pushl  0x8(%ebp)
  801854:	e8 dc 01 00 00       	call   801a35 <open>
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 1b                	js     80187d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	50                   	push   %eax
  801869:	e8 5b ff ff ff       	call   8017c9 <fstat>
  80186e:	89 c6                	mov    %eax,%esi
	close(fd);
  801870:	89 1c 24             	mov    %ebx,(%esp)
  801873:	e8 fd fb ff ff       	call   801475 <close>
	return r;
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	89 f0                	mov    %esi,%eax
}
  80187d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	56                   	push   %esi
  801888:	53                   	push   %ebx
  801889:	89 c6                	mov    %eax,%esi
  80188b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80188d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801894:	75 12                	jne    8018a8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	6a 01                	push   $0x1
  80189b:	e8 fc f9 ff ff       	call   80129c <ipc_find_env>
  8018a0:	a3 00 40 80 00       	mov    %eax,0x804000
  8018a5:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a8:	6a 07                	push   $0x7
  8018aa:	68 00 50 80 00       	push   $0x805000
  8018af:	56                   	push   %esi
  8018b0:	ff 35 00 40 80 00    	pushl  0x804000
  8018b6:	e8 9e f9 ff ff       	call   801259 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8018bb:	83 c4 0c             	add    $0xc,%esp
  8018be:	6a 00                	push   $0x0
  8018c0:	53                   	push   %ebx
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 34 f9 ff ff       	call   8011fc <ipc_recv>
}
  8018c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ed:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f2:	e8 8d ff ff ff       	call   801884 <fsipc>
}
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	8b 40 0c             	mov    0xc(%eax),%eax
  801905:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80190a:	ba 00 00 00 00       	mov    $0x0,%edx
  80190f:	b8 06 00 00 00       	mov    $0x6,%eax
  801914:	e8 6b ff ff ff       	call   801884 <fsipc>
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	53                   	push   %ebx
  80191f:	83 ec 04             	sub    $0x4,%esp
  801922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	8b 40 0c             	mov    0xc(%eax),%eax
  80192b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801930:	ba 00 00 00 00       	mov    $0x0,%edx
  801935:	b8 05 00 00 00       	mov    $0x5,%eax
  80193a:	e8 45 ff ff ff       	call   801884 <fsipc>
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 2c                	js     80196f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	68 00 50 80 00       	push   $0x805000
  80194b:	53                   	push   %ebx
  80194c:	e8 0a ef ff ff       	call   80085b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801951:	a1 80 50 80 00       	mov    0x805080,%eax
  801956:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80195c:	a1 84 50 80 00       	mov    0x805084,%eax
  801961:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80197d:	8b 55 08             	mov    0x8(%ebp),%edx
  801980:	8b 52 0c             	mov    0xc(%edx),%edx
  801983:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801989:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80198e:	50                   	push   %eax
  80198f:	ff 75 0c             	pushl  0xc(%ebp)
  801992:	68 08 50 80 00       	push   $0x805008
  801997:	e8 51 f0 ff ff       	call   8009ed <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80199c:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8019a6:	e8 d9 fe ff ff       	call   801884 <fsipc>
	//panic("devfile_write not implemented");
}
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	56                   	push   %esi
  8019b1:	53                   	push   %ebx
  8019b2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019c0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cb:	b8 03 00 00 00       	mov    $0x3,%eax
  8019d0:	e8 af fe ff ff       	call   801884 <fsipc>
  8019d5:	89 c3                	mov    %eax,%ebx
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 51                	js     801a2c <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8019db:	39 c6                	cmp    %eax,%esi
  8019dd:	73 19                	jae    8019f8 <devfile_read+0x4b>
  8019df:	68 40 29 80 00       	push   $0x802940
  8019e4:	68 47 29 80 00       	push   $0x802947
  8019e9:	68 80 00 00 00       	push   $0x80
  8019ee:	68 5c 29 80 00       	push   $0x80295c
  8019f3:	e8 c0 05 00 00       	call   801fb8 <_panic>
	assert(r <= PGSIZE);
  8019f8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019fd:	7e 19                	jle    801a18 <devfile_read+0x6b>
  8019ff:	68 67 29 80 00       	push   $0x802967
  801a04:	68 47 29 80 00       	push   $0x802947
  801a09:	68 81 00 00 00       	push   $0x81
  801a0e:	68 5c 29 80 00       	push   $0x80295c
  801a13:	e8 a0 05 00 00       	call   801fb8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	50                   	push   %eax
  801a1c:	68 00 50 80 00       	push   $0x805000
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	e8 c4 ef ff ff       	call   8009ed <memmove>
	return r;
  801a29:	83 c4 10             	add    $0x10,%esp
}
  801a2c:	89 d8                	mov    %ebx,%eax
  801a2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 20             	sub    $0x20,%esp
  801a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a3f:	53                   	push   %ebx
  801a40:	e8 dd ed ff ff       	call   800822 <strlen>
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a4d:	7f 67                	jg     801ab6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a55:	50                   	push   %eax
  801a56:	e8 a1 f8 ff ff       	call   8012fc <fd_alloc>
  801a5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a5e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 57                	js     801abb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a64:	83 ec 08             	sub    $0x8,%esp
  801a67:	53                   	push   %ebx
  801a68:	68 00 50 80 00       	push   $0x805000
  801a6d:	e8 e9 ed ff ff       	call   80085b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a75:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a82:	e8 fd fd ff ff       	call   801884 <fsipc>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	79 14                	jns    801aa4 <open+0x6f>
		
		fd_close(fd, 0);
  801a90:	83 ec 08             	sub    $0x8,%esp
  801a93:	6a 00                	push   $0x0
  801a95:	ff 75 f4             	pushl  -0xc(%ebp)
  801a98:	e8 57 f9 ff ff       	call   8013f4 <fd_close>
		return r;
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	89 da                	mov    %ebx,%edx
  801aa2:	eb 17                	jmp    801abb <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	ff 75 f4             	pushl  -0xc(%ebp)
  801aaa:	e8 26 f8 ff ff       	call   8012d5 <fd2num>
  801aaf:	89 c2                	mov    %eax,%edx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	eb 05                	jmp    801abb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ab6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801abb:	89 d0                	mov    %edx,%eax
  801abd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  801acd:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad2:	e8 ad fd ff ff       	call   801884 <fsipc>
}
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	ff 75 08             	pushl  0x8(%ebp)
  801ae7:	e8 f9 f7 ff ff       	call   8012e5 <fd2data>
  801aec:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aee:	83 c4 08             	add    $0x8,%esp
  801af1:	68 73 29 80 00       	push   $0x802973
  801af6:	53                   	push   %ebx
  801af7:	e8 5f ed ff ff       	call   80085b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801afc:	8b 46 04             	mov    0x4(%esi),%eax
  801aff:	2b 06                	sub    (%esi),%eax
  801b01:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b07:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b0e:	00 00 00 
	stat->st_dev = &devpipe;
  801b11:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801b18:	30 80 00 
	return 0;
}
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b31:	53                   	push   %ebx
  801b32:	6a 00                	push   $0x0
  801b34:	e8 aa f1 ff ff       	call   800ce3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b39:	89 1c 24             	mov    %ebx,(%esp)
  801b3c:	e8 a4 f7 ff ff       	call   8012e5 <fd2data>
  801b41:	83 c4 08             	add    $0x8,%esp
  801b44:	50                   	push   %eax
  801b45:	6a 00                	push   $0x0
  801b47:	e8 97 f1 ff ff       	call   800ce3 <sys_page_unmap>
}
  801b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	57                   	push   %edi
  801b55:	56                   	push   %esi
  801b56:	53                   	push   %ebx
  801b57:	83 ec 1c             	sub    $0x1c,%esp
  801b5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b5d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b64:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 75 e0             	pushl  -0x20(%ebp)
  801b6d:	e8 15 05 00 00       	call   802087 <pageref>
  801b72:	89 c3                	mov    %eax,%ebx
  801b74:	89 3c 24             	mov    %edi,(%esp)
  801b77:	e8 0b 05 00 00       	call   802087 <pageref>
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	39 c3                	cmp    %eax,%ebx
  801b81:	0f 94 c1             	sete   %cl
  801b84:	0f b6 c9             	movzbl %cl,%ecx
  801b87:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b8a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b90:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b93:	39 ce                	cmp    %ecx,%esi
  801b95:	74 1b                	je     801bb2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b97:	39 c3                	cmp    %eax,%ebx
  801b99:	75 c4                	jne    801b5f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b9b:	8b 42 58             	mov    0x58(%edx),%eax
  801b9e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba1:	50                   	push   %eax
  801ba2:	56                   	push   %esi
  801ba3:	68 7a 29 80 00       	push   $0x80297a
  801ba8:	e8 df e6 ff ff       	call   80028c <cprintf>
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	eb ad                	jmp    801b5f <_pipeisclosed+0xe>
	}
}
  801bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb8:	5b                   	pop    %ebx
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	57                   	push   %edi
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 28             	sub    $0x28,%esp
  801bc6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bc9:	56                   	push   %esi
  801bca:	e8 16 f7 ff ff       	call   8012e5 <fd2data>
  801bcf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	bf 00 00 00 00       	mov    $0x0,%edi
  801bd9:	eb 4b                	jmp    801c26 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bdb:	89 da                	mov    %ebx,%edx
  801bdd:	89 f0                	mov    %esi,%eax
  801bdf:	e8 6d ff ff ff       	call   801b51 <_pipeisclosed>
  801be4:	85 c0                	test   %eax,%eax
  801be6:	75 48                	jne    801c30 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801be8:	e8 52 f0 ff ff       	call   800c3f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bed:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf0:	8b 0b                	mov    (%ebx),%ecx
  801bf2:	8d 51 20             	lea    0x20(%ecx),%edx
  801bf5:	39 d0                	cmp    %edx,%eax
  801bf7:	73 e2                	jae    801bdb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c00:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	c1 fa 1f             	sar    $0x1f,%edx
  801c08:	89 d1                	mov    %edx,%ecx
  801c0a:	c1 e9 1b             	shr    $0x1b,%ecx
  801c0d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c10:	83 e2 1f             	and    $0x1f,%edx
  801c13:	29 ca                	sub    %ecx,%edx
  801c15:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c19:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c1d:	83 c0 01             	add    $0x1,%eax
  801c20:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c23:	83 c7 01             	add    $0x1,%edi
  801c26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c29:	75 c2                	jne    801bed <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2e:	eb 05                	jmp    801c35 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5f                   	pop    %edi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	57                   	push   %edi
  801c41:	56                   	push   %esi
  801c42:	53                   	push   %ebx
  801c43:	83 ec 18             	sub    $0x18,%esp
  801c46:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c49:	57                   	push   %edi
  801c4a:	e8 96 f6 ff ff       	call   8012e5 <fd2data>
  801c4f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c59:	eb 3d                	jmp    801c98 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c5b:	85 db                	test   %ebx,%ebx
  801c5d:	74 04                	je     801c63 <devpipe_read+0x26>
				return i;
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	eb 44                	jmp    801ca7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c63:	89 f2                	mov    %esi,%edx
  801c65:	89 f8                	mov    %edi,%eax
  801c67:	e8 e5 fe ff ff       	call   801b51 <_pipeisclosed>
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	75 32                	jne    801ca2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c70:	e8 ca ef ff ff       	call   800c3f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c75:	8b 06                	mov    (%esi),%eax
  801c77:	3b 46 04             	cmp    0x4(%esi),%eax
  801c7a:	74 df                	je     801c5b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7c:	99                   	cltd   
  801c7d:	c1 ea 1b             	shr    $0x1b,%edx
  801c80:	01 d0                	add    %edx,%eax
  801c82:	83 e0 1f             	and    $0x1f,%eax
  801c85:	29 d0                	sub    %edx,%eax
  801c87:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c92:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c95:	83 c3 01             	add    $0x1,%ebx
  801c98:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c9b:	75 d8                	jne    801c75 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca0:	eb 05                	jmp    801ca7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cba:	50                   	push   %eax
  801cbb:	e8 3c f6 ff ff       	call   8012fc <fd_alloc>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	0f 88 2c 01 00 00    	js     801df9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	68 07 04 00 00       	push   $0x407
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 7f ef ff ff       	call   800c5e <sys_page_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	0f 88 0d 01 00 00    	js     801df9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cec:	83 ec 0c             	sub    $0xc,%esp
  801cef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf2:	50                   	push   %eax
  801cf3:	e8 04 f6 ff ff       	call   8012fc <fd_alloc>
  801cf8:	89 c3                	mov    %eax,%ebx
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	0f 88 e2 00 00 00    	js     801de7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	68 07 04 00 00       	push   $0x407
  801d0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d10:	6a 00                	push   $0x0
  801d12:	e8 47 ef ff ff       	call   800c5e <sys_page_alloc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	0f 88 c3 00 00 00    	js     801de7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2a:	e8 b6 f5 ff ff       	call   8012e5 <fd2data>
  801d2f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d31:	83 c4 0c             	add    $0xc,%esp
  801d34:	68 07 04 00 00       	push   $0x407
  801d39:	50                   	push   %eax
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 1d ef ff ff       	call   800c5e <sys_page_alloc>
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	85 c0                	test   %eax,%eax
  801d48:	0f 88 89 00 00 00    	js     801dd7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4e:	83 ec 0c             	sub    $0xc,%esp
  801d51:	ff 75 f0             	pushl  -0x10(%ebp)
  801d54:	e8 8c f5 ff ff       	call   8012e5 <fd2data>
  801d59:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d60:	50                   	push   %eax
  801d61:	6a 00                	push   $0x0
  801d63:	56                   	push   %esi
  801d64:	6a 00                	push   $0x0
  801d66:	e8 36 ef ff ff       	call   800ca1 <sys_page_map>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	83 c4 20             	add    $0x20,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 55                	js     801dc9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d74:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d82:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d89:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d92:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d97:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	e8 2c f5 ff ff       	call   8012d5 <fd2num>
  801da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dac:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dae:	83 c4 04             	add    $0x4,%esp
  801db1:	ff 75 f0             	pushl  -0x10(%ebp)
  801db4:	e8 1c f5 ff ff       	call   8012d5 <fd2num>
  801db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc7:	eb 30                	jmp    801df9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	56                   	push   %esi
  801dcd:	6a 00                	push   $0x0
  801dcf:	e8 0f ef ff ff       	call   800ce3 <sys_page_unmap>
  801dd4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dd7:	83 ec 08             	sub    $0x8,%esp
  801dda:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 ff ee ff ff       	call   800ce3 <sys_page_unmap>
  801de4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801de7:	83 ec 08             	sub    $0x8,%esp
  801dea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ded:	6a 00                	push   $0x0
  801def:	e8 ef ee ff ff       	call   800ce3 <sys_page_unmap>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801df9:	89 d0                	mov    %edx,%eax
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	ff 75 08             	pushl  0x8(%ebp)
  801e0f:	e8 37 f5 ff ff       	call   80134b <fd_lookup>
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	85 c0                	test   %eax,%eax
  801e19:	78 18                	js     801e33 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e1b:	83 ec 0c             	sub    $0xc,%esp
  801e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e21:	e8 bf f4 ff ff       	call   8012e5 <fd2data>
	return _pipeisclosed(fd, p);
  801e26:	89 c2                	mov    %eax,%edx
  801e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2b:	e8 21 fd ff ff       	call   801b51 <_pipeisclosed>
  801e30:	83 c4 10             	add    $0x10,%esp
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e45:	68 92 29 80 00       	push   $0x802992
  801e4a:	ff 75 0c             	pushl  0xc(%ebp)
  801e4d:	e8 09 ea ff ff       	call   80085b <strcpy>
	return 0;
}
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	57                   	push   %edi
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e65:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e6a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e70:	eb 2d                	jmp    801e9f <devcons_write+0x46>
		m = n - tot;
  801e72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e75:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e77:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e7a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e7f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e82:	83 ec 04             	sub    $0x4,%esp
  801e85:	53                   	push   %ebx
  801e86:	03 45 0c             	add    0xc(%ebp),%eax
  801e89:	50                   	push   %eax
  801e8a:	57                   	push   %edi
  801e8b:	e8 5d eb ff ff       	call   8009ed <memmove>
		sys_cputs(buf, m);
  801e90:	83 c4 08             	add    $0x8,%esp
  801e93:	53                   	push   %ebx
  801e94:	57                   	push   %edi
  801e95:	e8 08 ed ff ff       	call   800ba2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9a:	01 de                	add    %ebx,%esi
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	89 f0                	mov    %esi,%eax
  801ea1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea4:	72 cc                	jb     801e72 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5f                   	pop    %edi
  801eac:	5d                   	pop    %ebp
  801ead:	c3                   	ret    

00801eae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 08             	sub    $0x8,%esp
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebd:	74 2a                	je     801ee9 <devcons_read+0x3b>
  801ebf:	eb 05                	jmp    801ec6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec1:	e8 79 ed ff ff       	call   800c3f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec6:	e8 f5 ec ff ff       	call   800bc0 <sys_cgetc>
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	74 f2                	je     801ec1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 16                	js     801ee9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ed3:	83 f8 04             	cmp    $0x4,%eax
  801ed6:	74 0c                	je     801ee4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edb:	88 02                	mov    %al,(%edx)
	return 1;
  801edd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee2:	eb 05                	jmp    801ee9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ef7:	6a 01                	push   $0x1
  801ef9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801efc:	50                   	push   %eax
  801efd:	e8 a0 ec ff ff       	call   800ba2 <sys_cputs>
}
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <getchar>:

int
getchar(void)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f0d:	6a 01                	push   $0x1
  801f0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f12:	50                   	push   %eax
  801f13:	6a 00                	push   $0x0
  801f15:	e8 97 f6 ff ff       	call   8015b1 <read>
	if (r < 0)
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	78 0f                	js     801f30 <getchar+0x29>
		return r;
	if (r < 1)
  801f21:	85 c0                	test   %eax,%eax
  801f23:	7e 06                	jle    801f2b <getchar+0x24>
		return -E_EOF;
	return c;
  801f25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f29:	eb 05                	jmp    801f30 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f2b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3b:	50                   	push   %eax
  801f3c:	ff 75 08             	pushl  0x8(%ebp)
  801f3f:	e8 07 f4 ff ff       	call   80134b <fd_lookup>
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	85 c0                	test   %eax,%eax
  801f49:	78 11                	js     801f5c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4e:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f54:	39 10                	cmp    %edx,(%eax)
  801f56:	0f 94 c0             	sete   %al
  801f59:	0f b6 c0             	movzbl %al,%eax
}
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <opencons>:

int
opencons(void)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	e8 8f f3 ff ff       	call   8012fc <fd_alloc>
  801f6d:	83 c4 10             	add    $0x10,%esp
		return r;
  801f70:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 3e                	js     801fb4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	68 07 04 00 00       	push   $0x407
  801f7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f81:	6a 00                	push   $0x0
  801f83:	e8 d6 ec ff ff       	call   800c5e <sys_page_alloc>
  801f88:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 23                	js     801fb4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f91:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa6:	83 ec 0c             	sub    $0xc,%esp
  801fa9:	50                   	push   %eax
  801faa:	e8 26 f3 ff ff       	call   8012d5 <fd2num>
  801faf:	89 c2                	mov    %eax,%edx
  801fb1:	83 c4 10             	add    $0x10,%esp
}
  801fb4:	89 d0                	mov    %edx,%eax
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fbd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fc0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801fc6:	e8 55 ec ff ff       	call   800c20 <sys_getenvid>
  801fcb:	83 ec 0c             	sub    $0xc,%esp
  801fce:	ff 75 0c             	pushl  0xc(%ebp)
  801fd1:	ff 75 08             	pushl  0x8(%ebp)
  801fd4:	56                   	push   %esi
  801fd5:	50                   	push   %eax
  801fd6:	68 a0 29 80 00       	push   $0x8029a0
  801fdb:	e8 ac e2 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fe0:	83 c4 18             	add    $0x18,%esp
  801fe3:	53                   	push   %ebx
  801fe4:	ff 75 10             	pushl  0x10(%ebp)
  801fe7:	e8 4f e2 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801fec:	c7 04 24 03 28 80 00 	movl   $0x802803,(%esp)
  801ff3:	e8 94 e2 ff ff       	call   80028c <cprintf>
  801ff8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ffb:	cc                   	int3   
  801ffc:	eb fd                	jmp    801ffb <_panic+0x43>

00801ffe <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  802004:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80200b:	75 4c                	jne    802059 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  80200d:	a1 04 40 80 00       	mov    0x804004,%eax
  802012:	8b 40 48             	mov    0x48(%eax),%eax
  802015:	83 ec 04             	sub    $0x4,%esp
  802018:	6a 07                	push   $0x7
  80201a:	68 00 f0 bf ee       	push   $0xeebff000
  80201f:	50                   	push   %eax
  802020:	e8 39 ec ff ff       	call   800c5e <sys_page_alloc>
		if(retv != 0){
  802025:	83 c4 10             	add    $0x10,%esp
  802028:	85 c0                	test   %eax,%eax
  80202a:	74 14                	je     802040 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  80202c:	83 ec 04             	sub    $0x4,%esp
  80202f:	68 c4 29 80 00       	push   $0x8029c4
  802034:	6a 27                	push   $0x27
  802036:	68 f0 29 80 00       	push   $0x8029f0
  80203b:	e8 78 ff ff ff       	call   801fb8 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802040:	a1 04 40 80 00       	mov    0x804004,%eax
  802045:	8b 40 48             	mov    0x48(%eax),%eax
  802048:	83 ec 08             	sub    $0x8,%esp
  80204b:	68 63 20 80 00       	push   $0x802063
  802050:	50                   	push   %eax
  802051:	e8 53 ed ff ff       	call   800da9 <sys_env_set_pgfault_upcall>
  802056:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802059:	8b 45 08             	mov    0x8(%ebp),%eax
  80205c:	a3 00 60 80 00       	mov    %eax,0x806000

}
  802061:	c9                   	leave  
  802062:	c3                   	ret    

00802063 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802063:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802064:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802069:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  80206b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  80206e:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  802072:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  802077:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  80207b:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  80207d:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  802080:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  802081:	83 c4 04             	add    $0x4,%esp
	popfl
  802084:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802085:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802086:	c3                   	ret    

00802087 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208d:	89 d0                	mov    %edx,%eax
  80208f:	c1 e8 16             	shr    $0x16,%eax
  802092:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802099:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209e:	f6 c1 01             	test   $0x1,%cl
  8020a1:	74 1d                	je     8020c0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020a3:	c1 ea 0c             	shr    $0xc,%edx
  8020a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ad:	f6 c2 01             	test   $0x1,%dl
  8020b0:	74 0e                	je     8020c0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b2:	c1 ea 0c             	shr    $0xc,%edx
  8020b5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020bc:	ef 
  8020bd:	0f b7 c0             	movzwl %ax,%eax
}
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	89 ca                	mov    %ecx,%edx
  8020ef:	89 f8                	mov    %edi,%eax
  8020f1:	75 3d                	jne    802130 <__udivdi3+0x60>
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	0f 87 c5 00 00 00    	ja     8021c0 <__udivdi3+0xf0>
  8020fb:	85 ff                	test   %edi,%edi
  8020fd:	89 fd                	mov    %edi,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f7                	div    %edi
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 c8                	mov    %ecx,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c1                	mov    %eax,%ecx
  802114:	89 d8                	mov    %ebx,%eax
  802116:	89 cf                	mov    %ecx,%edi
  802118:	f7 f5                	div    %ebp
  80211a:	89 c3                	mov    %eax,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	39 ce                	cmp    %ecx,%esi
  802132:	77 74                	ja     8021a8 <__udivdi3+0xd8>
  802134:	0f bd fe             	bsr    %esi,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0x108>
  802140:	bb 20 00 00 00       	mov    $0x20,%ebx
  802145:	89 f9                	mov    %edi,%ecx
  802147:	89 c5                	mov    %eax,%ebp
  802149:	29 fb                	sub    %edi,%ebx
  80214b:	d3 e6                	shl    %cl,%esi
  80214d:	89 d9                	mov    %ebx,%ecx
  80214f:	d3 ed                	shr    %cl,%ebp
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e0                	shl    %cl,%eax
  802155:	09 ee                	or     %ebp,%esi
  802157:	89 d9                	mov    %ebx,%ecx
  802159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215d:	89 d5                	mov    %edx,%ebp
  80215f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802163:	d3 ed                	shr    %cl,%ebp
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e2                	shl    %cl,%edx
  802169:	89 d9                	mov    %ebx,%ecx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	09 c2                	or     %eax,%edx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	89 ea                	mov    %ebp,%edx
  802173:	f7 f6                	div    %esi
  802175:	89 d5                	mov    %edx,%ebp
  802177:	89 c3                	mov    %eax,%ebx
  802179:	f7 64 24 0c          	mull   0xc(%esp)
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	72 10                	jb     802191 <__udivdi3+0xc1>
  802181:	8b 74 24 08          	mov    0x8(%esp),%esi
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e6                	shl    %cl,%esi
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	73 07                	jae    802194 <__udivdi3+0xc4>
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	75 03                	jne    802194 <__udivdi3+0xc4>
  802191:	83 eb 01             	sub    $0x1,%ebx
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 d8                	mov    %ebx,%eax
  802198:	89 fa                	mov    %edi,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	31 db                	xor    %ebx,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	f7 f7                	div    %edi
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 1c             	add    $0x1c,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	39 ce                	cmp    %ecx,%esi
  8021da:	72 0c                	jb     8021e8 <__udivdi3+0x118>
  8021dc:	31 db                	xor    %ebx,%ebx
  8021de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021e2:	0f 87 34 ff ff ff    	ja     80211c <__udivdi3+0x4c>
  8021e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ed:	e9 2a ff ff ff       	jmp    80211c <__udivdi3+0x4c>
  8021f2:	66 90                	xchg   %ax,%ax
  8021f4:	66 90                	xchg   %ax,%ax
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 d2                	test   %edx,%edx
  802219:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f3                	mov    %esi,%ebx
  802223:	89 3c 24             	mov    %edi,(%esp)
  802226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222a:	75 1c                	jne    802248 <__umoddi3+0x48>
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	76 50                	jbe    802280 <__umoddi3+0x80>
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	f7 f7                	div    %edi
  802236:	89 d0                	mov    %edx,%eax
  802238:	31 d2                	xor    %edx,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	77 52                	ja     8022a0 <__umoddi3+0xa0>
  80224e:	0f bd ea             	bsr    %edx,%ebp
  802251:	83 f5 1f             	xor    $0x1f,%ebp
  802254:	75 5a                	jne    8022b0 <__umoddi3+0xb0>
  802256:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	39 0c 24             	cmp    %ecx,(%esp)
  802263:	0f 86 d7 00 00 00    	jbe    802340 <__umoddi3+0x140>
  802269:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	85 ff                	test   %edi,%edi
  802282:	89 fd                	mov    %edi,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 f0                	mov    %esi,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 c8                	mov    %ecx,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	eb 99                	jmp    802238 <__umoddi3+0x38>
  80229f:	90                   	nop
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	8b 34 24             	mov    (%esp),%esi
  8022b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	29 ef                	sub    %ebp,%edi
  8022bc:	d3 e0                	shl    %cl,%eax
  8022be:	89 f9                	mov    %edi,%ecx
  8022c0:	89 f2                	mov    %esi,%edx
  8022c2:	d3 ea                	shr    %cl,%edx
  8022c4:	89 e9                	mov    %ebp,%ecx
  8022c6:	09 c2                	or     %eax,%edx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	d3 e3                	shl    %cl,%ebx
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 d0                	mov    %edx,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	09 d8                	or     %ebx,%eax
  8022ed:	89 d3                	mov    %edx,%ebx
  8022ef:	89 f2                	mov    %esi,%edx
  8022f1:	f7 34 24             	divl   (%esp)
  8022f4:	89 d6                	mov    %edx,%esi
  8022f6:	d3 e3                	shl    %cl,%ebx
  8022f8:	f7 64 24 04          	mull   0x4(%esp)
  8022fc:	39 d6                	cmp    %edx,%esi
  8022fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802302:	89 d1                	mov    %edx,%ecx
  802304:	89 c3                	mov    %eax,%ebx
  802306:	72 08                	jb     802310 <__umoddi3+0x110>
  802308:	75 11                	jne    80231b <__umoddi3+0x11b>
  80230a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80230e:	73 0b                	jae    80231b <__umoddi3+0x11b>
  802310:	2b 44 24 04          	sub    0x4(%esp),%eax
  802314:	1b 14 24             	sbb    (%esp),%edx
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 c3                	mov    %eax,%ebx
  80231b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80231f:	29 da                	sub    %ebx,%edx
  802321:	19 ce                	sbb    %ecx,%esi
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 f0                	mov    %esi,%eax
  802327:	d3 e0                	shl    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	d3 ea                	shr    %cl,%edx
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	d3 ee                	shr    %cl,%esi
  802331:	09 d0                	or     %edx,%eax
  802333:	89 f2                	mov    %esi,%edx
  802335:	83 c4 1c             	add    $0x1c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 f9                	sub    %edi,%ecx
  802342:	19 d6                	sbb    %edx,%esi
  802344:	89 74 24 04          	mov    %esi,0x4(%esp)
  802348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80234c:	e9 18 ff ff ff       	jmp    802269 <__umoddi3+0x69>
