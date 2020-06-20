
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 00 21 80 00       	push   $0x802100
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 57 0d 00 00       	call   800dc3 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 5d 0d 00 00       	call   800df3 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 59 13 00 00       	call   80140b <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 14 21 80 00       	push   $0x802114
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 24 17 00 00       	call   8017fe <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 14 21 80 00       	push   $0x802114
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800118:	e8 77 0a 00 00       	call   800b94 <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 84 0f 00 00       	call   8010e2 <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 eb 09 00 00       	call   800b53 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 79 09 00 00       	call   800b16 <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 54 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 1e 09 00 00       	call   800b16 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800238:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023b:	39 d3                	cmp    %edx,%ebx
  80023d:	72 05                	jb     800244 <printnum+0x30>
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 45                	ja     800289 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	53                   	push   %ebx
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 08 1c 00 00       	call   801e70 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 18                	jmp    800293 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	eb 03                	jmp    80028c <printnum+0x78>
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f e8                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 f5 1c 00 00       	call   801fa0 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 46 21 80 00 	movsbl 0x802146(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	88 02                	mov    %al,(%edx)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
	va_end(ap);
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 2c             	sub    $0x2c,%esp
  800340:	8b 75 08             	mov    0x8(%ebp),%esi
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800346:	8b 7d 10             	mov    0x10(%ebp),%edi
  800349:	eb 12                	jmp    80035d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034b:	85 c0                	test   %eax,%eax
  80034d:	0f 84 d3 03 00 00    	je     800726 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	ff d6                	call   *%esi
  80035a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	83 c7 01             	add    $0x1,%edi
  800360:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 e2                	jne    80034b <vprintfmt+0x14>
  800369:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800374:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80037b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 07                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8d 47 01             	lea    0x1(%edi),%eax
  800393:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800396:	0f b6 07             	movzbl (%edi),%eax
  800399:	0f b6 c8             	movzbl %al,%ecx
  80039c:	83 e8 23             	sub    $0x23,%eax
  80039f:	3c 55                	cmp    $0x55,%al
  8003a1:	0f 87 64 03 00 00    	ja     80070b <vprintfmt+0x3d4>
  8003a7:	0f b6 c0             	movzbl %al,%eax
  8003aa:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b8:	eb d6                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d2:	83 fa 09             	cmp    $0x9,%edx
  8003d5:	77 39                	ja     800410 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003da:	eb e9                	jmp    8003c5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ed:	eb 27                	jmp    800416 <vprintfmt+0xdf>
  8003ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	0f 49 c8             	cmovns %eax,%ecx
  8003fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800402:	eb 8c                	jmp    800390 <vprintfmt+0x59>
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800407:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040e:	eb 80                	jmp    800390 <vprintfmt+0x59>
  800410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800413:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800416:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041a:	0f 89 70 ff ff ff    	jns    800390 <vprintfmt+0x59>
				width = precision, precision = -1;
  800420:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80042d:	e9 5e ff ff ff       	jmp    800390 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800432:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800438:	e9 53 ff ff ff       	jmp    800390 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	53                   	push   %ebx
  80044a:	ff 30                	pushl  (%eax)
  80044c:	ff d6                	call   *%esi
			break;
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800454:	e9 04 ff ff ff       	jmp    80035d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	99                   	cltd   
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 0f             	cmp    $0xf,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x142>
  80046e:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 18                	jne    800491 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 5e 21 80 00       	push   $0x80215e
  80047f:	53                   	push   %ebx
  800480:	56                   	push   %esi
  800481:	e8 94 fe ff ff       	call   80031a <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048c:	e9 cc fe ff ff       	jmp    80035d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800491:	52                   	push   %edx
  800492:	68 11 25 80 00       	push   $0x802511
  800497:	53                   	push   %ebx
  800498:	56                   	push   %esi
  800499:	e8 7c fe ff ff       	call   80031a <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 b4 fe ff ff       	jmp    80035d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	b8 57 21 80 00       	mov    $0x802157,%eax
  8004bb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c2:	0f 8e 94 00 00 00    	jle    80055c <vprintfmt+0x225>
  8004c8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cc:	0f 84 98 00 00 00    	je     80056a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	ff 75 c8             	pushl  -0x38(%ebp)
  8004d8:	57                   	push   %edi
  8004d9:	e8 d0 02 00 00       	call   8007ae <strnlen>
  8004de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e1:	29 c1                	sub    %eax,%ecx
  8004e3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	eb 0f                	jmp    800506 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	83 ef 01             	sub    $0x1,%edi
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	85 ff                	test   %edi,%edi
  800508:	7f ed                	jg     8004f7 <vprintfmt+0x1c0>
  80050a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800510:	85 c9                	test   %ecx,%ecx
  800512:	b8 00 00 00 00       	mov    $0x0,%eax
  800517:	0f 49 c1             	cmovns %ecx,%eax
  80051a:	29 c1                	sub    %eax,%ecx
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	89 cb                	mov    %ecx,%ebx
  800527:	eb 4d                	jmp    800576 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052d:	74 1b                	je     80054a <vprintfmt+0x213>
  80052f:	0f be c0             	movsbl %al,%eax
  800532:	83 e8 20             	sub    $0x20,%eax
  800535:	83 f8 5e             	cmp    $0x5e,%eax
  800538:	76 10                	jbe    80054a <vprintfmt+0x213>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	6a 3f                	push   $0x3f
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb 0d                	jmp    800557 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	ff 75 0c             	pushl  0xc(%ebp)
  800550:	52                   	push   %edx
  800551:	ff 55 08             	call   *0x8(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800557:	83 eb 01             	sub    $0x1,%ebx
  80055a:	eb 1a                	jmp    800576 <vprintfmt+0x23f>
  80055c:	89 75 08             	mov    %esi,0x8(%ebp)
  80055f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800562:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800565:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800568:	eb 0c                	jmp    800576 <vprintfmt+0x23f>
  80056a:	89 75 08             	mov    %esi,0x8(%ebp)
  80056d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800570:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800573:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800576:	83 c7 01             	add    $0x1,%edi
  800579:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057d:	0f be d0             	movsbl %al,%edx
  800580:	85 d2                	test   %edx,%edx
  800582:	74 23                	je     8005a7 <vprintfmt+0x270>
  800584:	85 f6                	test   %esi,%esi
  800586:	78 a1                	js     800529 <vprintfmt+0x1f2>
  800588:	83 ee 01             	sub    $0x1,%esi
  80058b:	79 9c                	jns    800529 <vprintfmt+0x1f2>
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	8b 75 08             	mov    0x8(%ebp),%esi
  800592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800595:	eb 18                	jmp    8005af <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	6a 20                	push   $0x20
  80059d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	83 ef 01             	sub    $0x1,%edi
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb 08                	jmp    8005af <vprintfmt+0x278>
  8005a7:	89 df                	mov    %ebx,%edi
  8005a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005af:	85 ff                	test   %edi,%edi
  8005b1:	7f e4                	jg     800597 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	e9 a2 fd ff ff       	jmp    80035d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 fa 01             	cmp    $0x1,%edx
  8005be:	7e 16                	jle    8005d6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 50 04             	mov    0x4(%eax),%edx
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005d4:	eb 32                	jmp    800608 <vprintfmt+0x2d1>
	else if (lflag)
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	74 18                	je     8005f2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e8:	89 c1                	mov    %eax,%ecx
  8005ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ed:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f0:	eb 16                	jmp    800608 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800600:	89 c1                	mov    %eax,%ecx
  800602:	c1 f9 1f             	sar    $0x1f,%ecx
  800605:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800608:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80060b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800614:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800619:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80061d:	0f 89 b0 00 00 00    	jns    8006d3 <vprintfmt+0x39c>
				putch('-', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 2d                	push   $0x2d
  800629:	ff d6                	call   *%esi
				num = -(long long) num;
  80062b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80062e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800631:	f7 d8                	neg    %eax
  800633:	83 d2 00             	adc    $0x0,%edx
  800636:	f7 da                	neg    %edx
  800638:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800641:	b8 0a 00 00 00       	mov    $0xa,%eax
  800646:	e9 88 00 00 00       	jmp    8006d3 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 70 fc ff ff       	call   8002c3 <getuint>
  800653:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800656:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80065e:	eb 73                	jmp    8006d3 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 5b fc ff ff       	call   8002c3 <getuint>
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	6a 58                	push   $0x58
  800674:	ff d6                	call   *%esi
			putch('X', putdat);
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 58                	push   $0x58
  80067c:	ff d6                	call   *%esi
			putch('X', putdat);
  80067e:	83 c4 08             	add    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 58                	push   $0x58
  800684:	ff d6                	call   *%esi
			goto number;
  800686:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800689:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80068e:	eb 43                	jmp    8006d3 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 30                	push   $0x30
  800696:	ff d6                	call   *%esi
			putch('x', putdat);
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 78                	push   $0x78
  80069e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006be:	eb 13                	jmp    8006d3 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c3:	e8 fb fb ff ff       	call   8002c3 <getuint>
  8006c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d3:	83 ec 0c             	sub    $0xc,%esp
  8006d6:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006da:	52                   	push   %edx
  8006db:	ff 75 e0             	pushl  -0x20(%ebp)
  8006de:	50                   	push   %eax
  8006df:	ff 75 dc             	pushl  -0x24(%ebp)
  8006e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e5:	89 da                	mov    %ebx,%edx
  8006e7:	89 f0                	mov    %esi,%eax
  8006e9:	e8 26 fb ff ff       	call   800214 <printnum>
			break;
  8006ee:	83 c4 20             	add    $0x20,%esp
  8006f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f4:	e9 64 fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	51                   	push   %ecx
  8006fe:	ff d6                	call   *%esi
			break;
  800700:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800706:	e9 52 fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	6a 25                	push   $0x25
  800711:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 03                	jmp    80071b <vprintfmt+0x3e4>
  800718:	83 ef 01             	sub    $0x1,%edi
  80071b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80071f:	75 f7                	jne    800718 <vprintfmt+0x3e1>
  800721:	e9 37 fc ff ff       	jmp    80035d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800726:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800729:	5b                   	pop    %ebx
  80072a:	5e                   	pop    %esi
  80072b:	5f                   	pop    %edi
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	83 ec 18             	sub    $0x18,%esp
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800741:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800744:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074b:	85 c0                	test   %eax,%eax
  80074d:	74 26                	je     800775 <vsnprintf+0x47>
  80074f:	85 d2                	test   %edx,%edx
  800751:	7e 22                	jle    800775 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800753:	ff 75 14             	pushl  0x14(%ebp)
  800756:	ff 75 10             	pushl  0x10(%ebp)
  800759:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075c:	50                   	push   %eax
  80075d:	68 fd 02 80 00       	push   $0x8002fd
  800762:	e8 d0 fb ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800767:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	eb 05                	jmp    80077a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800775:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800782:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800785:	50                   	push   %eax
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	ff 75 08             	pushl  0x8(%ebp)
  80078f:	e8 9a ff ff ff       	call   80072e <vsnprintf>
	va_end(ap);

	return rc;
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	eb 03                	jmp    8007a6 <strlen+0x10>
		n++;
  8007a3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007aa:	75 f7                	jne    8007a3 <strlen+0xd>
		n++;
	return n;
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bc:	eb 03                	jmp    8007c1 <strnlen+0x13>
		n++;
  8007be:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c1:	39 c2                	cmp    %eax,%edx
  8007c3:	74 08                	je     8007cd <strnlen+0x1f>
  8007c5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c9:	75 f3                	jne    8007be <strnlen+0x10>
  8007cb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	83 c2 01             	add    $0x1,%edx
  8007de:	83 c1 01             	add    $0x1,%ecx
  8007e1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e8:	84 db                	test   %bl,%bl
  8007ea:	75 ef                	jne    8007db <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f6:	53                   	push   %ebx
  8007f7:	e8 9a ff ff ff       	call   800796 <strlen>
  8007fc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ff:	ff 75 0c             	pushl  0xc(%ebp)
  800802:	01 d8                	add    %ebx,%eax
  800804:	50                   	push   %eax
  800805:	e8 c5 ff ff ff       	call   8007cf <strcpy>
	return dst;
}
  80080a:	89 d8                	mov    %ebx,%eax
  80080c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080f:	c9                   	leave  
  800810:	c3                   	ret    

00800811 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	56                   	push   %esi
  800815:	53                   	push   %ebx
  800816:	8b 75 08             	mov    0x8(%ebp),%esi
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081c:	89 f3                	mov    %esi,%ebx
  80081e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800821:	89 f2                	mov    %esi,%edx
  800823:	eb 0f                	jmp    800834 <strncpy+0x23>
		*dst++ = *src;
  800825:	83 c2 01             	add    $0x1,%edx
  800828:	0f b6 01             	movzbl (%ecx),%eax
  80082b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082e:	80 39 01             	cmpb   $0x1,(%ecx)
  800831:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800834:	39 da                	cmp    %ebx,%edx
  800836:	75 ed                	jne    800825 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800838:	89 f0                	mov    %esi,%eax
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 75 08             	mov    0x8(%ebp),%esi
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	8b 55 10             	mov    0x10(%ebp),%edx
  80084c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084e:	85 d2                	test   %edx,%edx
  800850:	74 21                	je     800873 <strlcpy+0x35>
  800852:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800856:	89 f2                	mov    %esi,%edx
  800858:	eb 09                	jmp    800863 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085a:	83 c2 01             	add    $0x1,%edx
  80085d:	83 c1 01             	add    $0x1,%ecx
  800860:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800863:	39 c2                	cmp    %eax,%edx
  800865:	74 09                	je     800870 <strlcpy+0x32>
  800867:	0f b6 19             	movzbl (%ecx),%ebx
  80086a:	84 db                	test   %bl,%bl
  80086c:	75 ec                	jne    80085a <strlcpy+0x1c>
  80086e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800870:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800873:	29 f0                	sub    %esi,%eax
}
  800875:	5b                   	pop    %ebx
  800876:	5e                   	pop    %esi
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800882:	eb 06                	jmp    80088a <strcmp+0x11>
		p++, q++;
  800884:	83 c1 01             	add    $0x1,%ecx
  800887:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088a:	0f b6 01             	movzbl (%ecx),%eax
  80088d:	84 c0                	test   %al,%al
  80088f:	74 04                	je     800895 <strcmp+0x1c>
  800891:	3a 02                	cmp    (%edx),%al
  800893:	74 ef                	je     800884 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800895:	0f b6 c0             	movzbl %al,%eax
  800898:	0f b6 12             	movzbl (%edx),%edx
  80089b:	29 d0                	sub    %edx,%eax
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	53                   	push   %ebx
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a9:	89 c3                	mov    %eax,%ebx
  8008ab:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ae:	eb 06                	jmp    8008b6 <strncmp+0x17>
		n--, p++, q++;
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b6:	39 d8                	cmp    %ebx,%eax
  8008b8:	74 15                	je     8008cf <strncmp+0x30>
  8008ba:	0f b6 08             	movzbl (%eax),%ecx
  8008bd:	84 c9                	test   %cl,%cl
  8008bf:	74 04                	je     8008c5 <strncmp+0x26>
  8008c1:	3a 0a                	cmp    (%edx),%cl
  8008c3:	74 eb                	je     8008b0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c5:	0f b6 00             	movzbl (%eax),%eax
  8008c8:	0f b6 12             	movzbl (%edx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
  8008cd:	eb 05                	jmp    8008d4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e1:	eb 07                	jmp    8008ea <strchr+0x13>
		if (*s == c)
  8008e3:	38 ca                	cmp    %cl,%dl
  8008e5:	74 0f                	je     8008f6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e7:	83 c0 01             	add    $0x1,%eax
  8008ea:	0f b6 10             	movzbl (%eax),%edx
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	75 f2                	jne    8008e3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800902:	eb 03                	jmp    800907 <strfind+0xf>
  800904:	83 c0 01             	add    $0x1,%eax
  800907:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090a:	38 ca                	cmp    %cl,%dl
  80090c:	74 04                	je     800912 <strfind+0x1a>
  80090e:	84 d2                	test   %dl,%dl
  800910:	75 f2                	jne    800904 <strfind+0xc>
			break;
	return (char *) s;
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800920:	85 c9                	test   %ecx,%ecx
  800922:	74 36                	je     80095a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800924:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092a:	75 28                	jne    800954 <memset+0x40>
  80092c:	f6 c1 03             	test   $0x3,%cl
  80092f:	75 23                	jne    800954 <memset+0x40>
		c &= 0xFF;
  800931:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800935:	89 d3                	mov    %edx,%ebx
  800937:	c1 e3 08             	shl    $0x8,%ebx
  80093a:	89 d6                	mov    %edx,%esi
  80093c:	c1 e6 18             	shl    $0x18,%esi
  80093f:	89 d0                	mov    %edx,%eax
  800941:	c1 e0 10             	shl    $0x10,%eax
  800944:	09 f0                	or     %esi,%eax
  800946:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800948:	89 d8                	mov    %ebx,%eax
  80094a:	09 d0                	or     %edx,%eax
  80094c:	c1 e9 02             	shr    $0x2,%ecx
  80094f:	fc                   	cld    
  800950:	f3 ab                	rep stos %eax,%es:(%edi)
  800952:	eb 06                	jmp    80095a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800954:	8b 45 0c             	mov    0xc(%ebp),%eax
  800957:	fc                   	cld    
  800958:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095a:	89 f8                	mov    %edi,%eax
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096f:	39 c6                	cmp    %eax,%esi
  800971:	73 35                	jae    8009a8 <memmove+0x47>
  800973:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800976:	39 d0                	cmp    %edx,%eax
  800978:	73 2e                	jae    8009a8 <memmove+0x47>
		s += n;
		d += n;
  80097a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097d:	89 d6                	mov    %edx,%esi
  80097f:	09 fe                	or     %edi,%esi
  800981:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800987:	75 13                	jne    80099c <memmove+0x3b>
  800989:	f6 c1 03             	test   $0x3,%cl
  80098c:	75 0e                	jne    80099c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80098e:	83 ef 04             	sub    $0x4,%edi
  800991:	8d 72 fc             	lea    -0x4(%edx),%esi
  800994:	c1 e9 02             	shr    $0x2,%ecx
  800997:	fd                   	std    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 09                	jmp    8009a5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099c:	83 ef 01             	sub    $0x1,%edi
  80099f:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a2:	fd                   	std    
  8009a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a5:	fc                   	cld    
  8009a6:	eb 1d                	jmp    8009c5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	89 f2                	mov    %esi,%edx
  8009aa:	09 c2                	or     %eax,%edx
  8009ac:	f6 c2 03             	test   $0x3,%dl
  8009af:	75 0f                	jne    8009c0 <memmove+0x5f>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0a                	jne    8009c0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 05                	jmp    8009c5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c0:	89 c7                	mov    %eax,%edi
  8009c2:	fc                   	cld    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cc:	ff 75 10             	pushl  0x10(%ebp)
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	ff 75 08             	pushl  0x8(%ebp)
  8009d5:	e8 87 ff ff ff       	call   800961 <memmove>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e7:	89 c6                	mov    %eax,%esi
  8009e9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ec:	eb 1a                	jmp    800a08 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ee:	0f b6 08             	movzbl (%eax),%ecx
  8009f1:	0f b6 1a             	movzbl (%edx),%ebx
  8009f4:	38 d9                	cmp    %bl,%cl
  8009f6:	74 0a                	je     800a02 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f8:	0f b6 c1             	movzbl %cl,%eax
  8009fb:	0f b6 db             	movzbl %bl,%ebx
  8009fe:	29 d8                	sub    %ebx,%eax
  800a00:	eb 0f                	jmp    800a11 <memcmp+0x35>
		s1++, s2++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a08:	39 f0                	cmp    %esi,%eax
  800a0a:	75 e2                	jne    8009ee <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a1c:	89 c1                	mov    %eax,%ecx
  800a1e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a21:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a25:	eb 0a                	jmp    800a31 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a27:	0f b6 10             	movzbl (%eax),%edx
  800a2a:	39 da                	cmp    %ebx,%edx
  800a2c:	74 07                	je     800a35 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	39 c8                	cmp    %ecx,%eax
  800a33:	72 f2                	jb     800a27 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a35:	5b                   	pop    %ebx
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a44:	eb 03                	jmp    800a49 <strtol+0x11>
		s++;
  800a46:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a49:	0f b6 01             	movzbl (%ecx),%eax
  800a4c:	3c 20                	cmp    $0x20,%al
  800a4e:	74 f6                	je     800a46 <strtol+0xe>
  800a50:	3c 09                	cmp    $0x9,%al
  800a52:	74 f2                	je     800a46 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a54:	3c 2b                	cmp    $0x2b,%al
  800a56:	75 0a                	jne    800a62 <strtol+0x2a>
		s++;
  800a58:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a60:	eb 11                	jmp    800a73 <strtol+0x3b>
  800a62:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a67:	3c 2d                	cmp    $0x2d,%al
  800a69:	75 08                	jne    800a73 <strtol+0x3b>
		s++, neg = 1;
  800a6b:	83 c1 01             	add    $0x1,%ecx
  800a6e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a73:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a79:	75 15                	jne    800a90 <strtol+0x58>
  800a7b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7e:	75 10                	jne    800a90 <strtol+0x58>
  800a80:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a84:	75 7c                	jne    800b02 <strtol+0xca>
		s += 2, base = 16;
  800a86:	83 c1 02             	add    $0x2,%ecx
  800a89:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8e:	eb 16                	jmp    800aa6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	75 12                	jne    800aa6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a94:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a99:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9c:	75 08                	jne    800aa6 <strtol+0x6e>
		s++, base = 8;
  800a9e:	83 c1 01             	add    $0x1,%ecx
  800aa1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aae:	0f b6 11             	movzbl (%ecx),%edx
  800ab1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 09             	cmp    $0x9,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0x8b>
			dig = *s - '0';
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 30             	sub    $0x30,%edx
  800ac1:	eb 22                	jmp    800ae5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 57             	sub    $0x57,%edx
  800ad3:	eb 10                	jmp    800ae5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 19             	cmp    $0x19,%bl
  800add:	77 16                	ja     800af5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae8:	7d 0b                	jge    800af5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aea:	83 c1 01             	add    $0x1,%ecx
  800aed:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af3:	eb b9                	jmp    800aae <strtol+0x76>

	if (endptr)
  800af5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af9:	74 0d                	je     800b08 <strtol+0xd0>
		*endptr = (char *) s;
  800afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afe:	89 0e                	mov    %ecx,(%esi)
  800b00:	eb 06                	jmp    800b08 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b02:	85 db                	test   %ebx,%ebx
  800b04:	74 98                	je     800a9e <strtol+0x66>
  800b06:	eb 9e                	jmp    800aa6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b08:	89 c2                	mov    %eax,%edx
  800b0a:	f7 da                	neg    %edx
  800b0c:	85 ff                	test   %edi,%edi
  800b0e:	0f 45 c2             	cmovne %edx,%eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 c3                	mov    %eax,%ebx
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	89 c6                	mov    %eax,%esi
  800b2d:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b61:	b8 03 00 00 00       	mov    $0x3,%eax
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 cb                	mov    %ecx,%ebx
  800b6b:	89 cf                	mov    %ecx,%edi
  800b6d:	89 ce                	mov    %ecx,%esi
  800b6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b71:	85 c0                	test   %eax,%eax
  800b73:	7e 17                	jle    800b8c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b75:	83 ec 0c             	sub    $0xc,%esp
  800b78:	50                   	push   %eax
  800b79:	6a 03                	push   $0x3
  800b7b:	68 3f 24 80 00       	push   $0x80243f
  800b80:	6a 23                	push   $0x23
  800b82:	68 5c 24 80 00       	push   $0x80245c
  800b87:	e8 7e 11 00 00       	call   801d0a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_yield>:

void
sys_yield(void)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc3:	89 d1                	mov    %edx,%ecx
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	89 d7                	mov    %edx,%edi
  800bc9:	89 d6                	mov    %edx,%esi
  800bcb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bdb:	be 00 00 00 00       	mov    $0x0,%esi
  800be0:	b8 04 00 00 00       	mov    $0x4,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bee:	89 f7                	mov    %esi,%edi
  800bf0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	7e 17                	jle    800c0d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 04                	push   $0x4
  800bfc:	68 3f 24 80 00       	push   $0x80243f
  800c01:	6a 23                	push   $0x23
  800c03:	68 5c 24 80 00       	push   $0x80245c
  800c08:	e8 fd 10 00 00       	call   801d0a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c1e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 05                	push   $0x5
  800c3e:	68 3f 24 80 00       	push   $0x80243f
  800c43:	6a 23                	push   $0x23
  800c45:	68 5c 24 80 00       	push   $0x80245c
  800c4a:	e8 bb 10 00 00       	call   801d0a <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 06                	push   $0x6
  800c80:	68 3f 24 80 00       	push   $0x80243f
  800c85:	6a 23                	push   $0x23
  800c87:	68 5c 24 80 00       	push   $0x80245c
  800c8c:	e8 79 10 00 00       	call   801d0a <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 08                	push   $0x8
  800cc2:	68 3f 24 80 00       	push   $0x80243f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 5c 24 80 00       	push   $0x80245c
  800cce:	e8 37 10 00 00       	call   801d0a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 09                	push   $0x9
  800d04:	68 3f 24 80 00       	push   $0x80243f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 5c 24 80 00       	push   $0x80245c
  800d10:	e8 f5 0f 00 00       	call   801d0a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 0a                	push   $0xa
  800d46:	68 3f 24 80 00       	push   $0x80243f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 5c 24 80 00       	push   $0x80245c
  800d52:	e8 b3 0f 00 00       	call   801d0a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d65:	be 00 00 00 00       	mov    $0x0,%esi
  800d6a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d90:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 cb                	mov    %ecx,%ebx
  800d9a:	89 cf                	mov    %ecx,%edi
  800d9c:	89 ce                	mov    %ecx,%esi
  800d9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 17                	jle    800dbb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	50                   	push   %eax
  800da8:	6a 0d                	push   $0xd
  800daa:	68 3f 24 80 00       	push   $0x80243f
  800daf:	6a 23                	push   $0x23
  800db1:	68 5c 24 80 00       	push   $0x80245c
  800db6:	e8 4f 0f 00 00       	call   801d0a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800dcf:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800dd1:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800dd4:	83 3a 01             	cmpl   $0x1,(%edx)
  800dd7:	7e 09                	jle    800de2 <argstart+0x1f>
  800dd9:	ba 11 21 80 00       	mov    $0x802111,%edx
  800dde:	85 c9                	test   %ecx,%ecx
  800de0:	75 05                	jne    800de7 <argstart+0x24>
  800de2:	ba 00 00 00 00       	mov    $0x0,%edx
  800de7:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800dea:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <argnext>:

int
argnext(struct Argstate *args)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	53                   	push   %ebx
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dfd:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e04:	8b 43 08             	mov    0x8(%ebx),%eax
  800e07:	85 c0                	test   %eax,%eax
  800e09:	74 6f                	je     800e7a <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e0b:	80 38 00             	cmpb   $0x0,(%eax)
  800e0e:	75 4e                	jne    800e5e <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e10:	8b 0b                	mov    (%ebx),%ecx
  800e12:	83 39 01             	cmpl   $0x1,(%ecx)
  800e15:	74 55                	je     800e6c <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e17:	8b 53 04             	mov    0x4(%ebx),%edx
  800e1a:	8b 42 04             	mov    0x4(%edx),%eax
  800e1d:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e20:	75 4a                	jne    800e6c <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e22:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e26:	74 44                	je     800e6c <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e28:	83 c0 01             	add    $0x1,%eax
  800e2b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	8b 01                	mov    (%ecx),%eax
  800e33:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e3a:	50                   	push   %eax
  800e3b:	8d 42 08             	lea    0x8(%edx),%eax
  800e3e:	50                   	push   %eax
  800e3f:	83 c2 04             	add    $0x4,%edx
  800e42:	52                   	push   %edx
  800e43:	e8 19 fb ff ff       	call   800961 <memmove>
		(*args->argc)--;
  800e48:	8b 03                	mov    (%ebx),%eax
  800e4a:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e4d:	8b 43 08             	mov    0x8(%ebx),%eax
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e56:	75 06                	jne    800e5e <argnext+0x6b>
  800e58:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e5c:	74 0e                	je     800e6c <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e5e:	8b 53 08             	mov    0x8(%ebx),%edx
  800e61:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e64:	83 c2 01             	add    $0x1,%edx
  800e67:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e6a:	eb 13                	jmp    800e7f <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e6c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e78:	eb 05                	jmp    800e7f <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	53                   	push   %ebx
  800e88:	83 ec 04             	sub    $0x4,%esp
  800e8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e8e:	8b 43 08             	mov    0x8(%ebx),%eax
  800e91:	85 c0                	test   %eax,%eax
  800e93:	74 58                	je     800eed <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e95:	80 38 00             	cmpb   $0x0,(%eax)
  800e98:	74 0c                	je     800ea6 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e9a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e9d:	c7 43 08 11 21 80 00 	movl   $0x802111,0x8(%ebx)
  800ea4:	eb 42                	jmp    800ee8 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800ea6:	8b 13                	mov    (%ebx),%edx
  800ea8:	83 3a 01             	cmpl   $0x1,(%edx)
  800eab:	7e 2d                	jle    800eda <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800ead:	8b 43 04             	mov    0x4(%ebx),%eax
  800eb0:	8b 48 04             	mov    0x4(%eax),%ecx
  800eb3:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800eb6:	83 ec 04             	sub    $0x4,%esp
  800eb9:	8b 12                	mov    (%edx),%edx
  800ebb:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800ec2:	52                   	push   %edx
  800ec3:	8d 50 08             	lea    0x8(%eax),%edx
  800ec6:	52                   	push   %edx
  800ec7:	83 c0 04             	add    $0x4,%eax
  800eca:	50                   	push   %eax
  800ecb:	e8 91 fa ff ff       	call   800961 <memmove>
		(*args->argc)--;
  800ed0:	8b 03                	mov    (%ebx),%eax
  800ed2:	83 28 01             	subl   $0x1,(%eax)
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	eb 0e                	jmp    800ee8 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800eda:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800ee1:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800ee8:	8b 43 0c             	mov    0xc(%ebx),%eax
  800eeb:	eb 05                	jmp    800ef2 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ef2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 08             	sub    $0x8,%esp
  800efd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f00:	8b 51 0c             	mov    0xc(%ecx),%edx
  800f03:	89 d0                	mov    %edx,%eax
  800f05:	85 d2                	test   %edx,%edx
  800f07:	75 0c                	jne    800f15 <argvalue+0x1e>
  800f09:	83 ec 0c             	sub    $0xc,%esp
  800f0c:	51                   	push   %ecx
  800f0d:	e8 72 ff ff ff       	call   800e84 <argnextvalue>
  800f12:	83 c4 10             	add    $0x10,%esp
}
  800f15:	c9                   	leave  
  800f16:	c3                   	ret    

00800f17 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1d:	05 00 00 00 30       	add    $0x30000000,%eax
  800f22:	c1 e8 0c             	shr    $0xc,%eax
}
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2d:	05 00 00 00 30       	add    $0x30000000,%eax
  800f32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f37:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f44:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f49:	89 c2                	mov    %eax,%edx
  800f4b:	c1 ea 16             	shr    $0x16,%edx
  800f4e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f55:	f6 c2 01             	test   $0x1,%dl
  800f58:	74 11                	je     800f6b <fd_alloc+0x2d>
  800f5a:	89 c2                	mov    %eax,%edx
  800f5c:	c1 ea 0c             	shr    $0xc,%edx
  800f5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f66:	f6 c2 01             	test   $0x1,%dl
  800f69:	75 09                	jne    800f74 <fd_alloc+0x36>
			*fd_store = fd;
  800f6b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f72:	eb 17                	jmp    800f8b <fd_alloc+0x4d>
  800f74:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f79:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f7e:	75 c9                	jne    800f49 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f80:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f86:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f93:	83 f8 1f             	cmp    $0x1f,%eax
  800f96:	77 36                	ja     800fce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f98:	c1 e0 0c             	shl    $0xc,%eax
  800f9b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa0:	89 c2                	mov    %eax,%edx
  800fa2:	c1 ea 16             	shr    $0x16,%edx
  800fa5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fac:	f6 c2 01             	test   $0x1,%dl
  800faf:	74 24                	je     800fd5 <fd_lookup+0x48>
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	c1 ea 0c             	shr    $0xc,%edx
  800fb6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbd:	f6 c2 01             	test   $0x1,%dl
  800fc0:	74 1a                	je     800fdc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc5:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcc:	eb 13                	jmp    800fe1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd3:	eb 0c                	jmp    800fe1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fda:	eb 05                	jmp    800fe1 <fd_lookup+0x54>
  800fdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 08             	sub    $0x8,%esp
  800fe9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fec:	ba e8 24 80 00       	mov    $0x8024e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff1:	eb 13                	jmp    801006 <dev_lookup+0x23>
  800ff3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ff6:	39 08                	cmp    %ecx,(%eax)
  800ff8:	75 0c                	jne    801006 <dev_lookup+0x23>
			*dev = devtab[i];
  800ffa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fff:	b8 00 00 00 00       	mov    $0x0,%eax
  801004:	eb 2e                	jmp    801034 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801006:	8b 02                	mov    (%edx),%eax
  801008:	85 c0                	test   %eax,%eax
  80100a:	75 e7                	jne    800ff3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80100c:	a1 04 40 80 00       	mov    0x804004,%eax
  801011:	8b 40 48             	mov    0x48(%eax),%eax
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	51                   	push   %ecx
  801018:	50                   	push   %eax
  801019:	68 6c 24 80 00       	push   $0x80246c
  80101e:	e8 dd f1 ff ff       	call   800200 <cprintf>
	*dev = 0;
  801023:	8b 45 0c             	mov    0xc(%ebp),%eax
  801026:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	83 ec 10             	sub    $0x10,%esp
  80103e:	8b 75 08             	mov    0x8(%ebp),%esi
  801041:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801044:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801047:	50                   	push   %eax
  801048:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80104e:	c1 e8 0c             	shr    $0xc,%eax
  801051:	50                   	push   %eax
  801052:	e8 36 ff ff ff       	call   800f8d <fd_lookup>
  801057:	83 c4 08             	add    $0x8,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 05                	js     801063 <fd_close+0x2d>
	    || fd != fd2)
  80105e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801061:	74 0c                	je     80106f <fd_close+0x39>
		return (must_exist ? r : 0);
  801063:	84 db                	test   %bl,%bl
  801065:	ba 00 00 00 00       	mov    $0x0,%edx
  80106a:	0f 44 c2             	cmove  %edx,%eax
  80106d:	eb 41                	jmp    8010b0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	ff 36                	pushl  (%esi)
  801078:	e8 66 ff ff ff       	call   800fe3 <dev_lookup>
  80107d:	89 c3                	mov    %eax,%ebx
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 1a                	js     8010a0 <fd_close+0x6a>
		if (dev->dev_close)
  801086:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801089:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801091:	85 c0                	test   %eax,%eax
  801093:	74 0b                	je     8010a0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	56                   	push   %esi
  801099:	ff d0                	call   *%eax
  80109b:	89 c3                	mov    %eax,%ebx
  80109d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	56                   	push   %esi
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 ac fb ff ff       	call   800c57 <sys_page_unmap>
	return r;
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	89 d8                	mov    %ebx,%eax
}
  8010b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	e8 c4 fe ff ff       	call   800f8d <fd_lookup>
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 10                	js     8010e0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010d0:	83 ec 08             	sub    $0x8,%esp
  8010d3:	6a 01                	push   $0x1
  8010d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d8:	e8 59 ff ff ff       	call   801036 <fd_close>
  8010dd:	83 c4 10             	add    $0x10,%esp
}
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <close_all>:

void
close_all(void)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ee:	83 ec 0c             	sub    $0xc,%esp
  8010f1:	53                   	push   %ebx
  8010f2:	e8 c0 ff ff ff       	call   8010b7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010f7:	83 c3 01             	add    $0x1,%ebx
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	83 fb 20             	cmp    $0x20,%ebx
  801100:	75 ec                	jne    8010ee <close_all+0xc>
		close(i);
}
  801102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 2c             	sub    $0x2c,%esp
  801110:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801113:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	ff 75 08             	pushl  0x8(%ebp)
  80111a:	e8 6e fe ff ff       	call   800f8d <fd_lookup>
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	0f 88 c1 00 00 00    	js     8011eb <dup+0xe4>
		return r;
	close(newfdnum);
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	56                   	push   %esi
  80112e:	e8 84 ff ff ff       	call   8010b7 <close>

	newfd = INDEX2FD(newfdnum);
  801133:	89 f3                	mov    %esi,%ebx
  801135:	c1 e3 0c             	shl    $0xc,%ebx
  801138:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80113e:	83 c4 04             	add    $0x4,%esp
  801141:	ff 75 e4             	pushl  -0x1c(%ebp)
  801144:	e8 de fd ff ff       	call   800f27 <fd2data>
  801149:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80114b:	89 1c 24             	mov    %ebx,(%esp)
  80114e:	e8 d4 fd ff ff       	call   800f27 <fd2data>
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801159:	89 f8                	mov    %edi,%eax
  80115b:	c1 e8 16             	shr    $0x16,%eax
  80115e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801165:	a8 01                	test   $0x1,%al
  801167:	74 37                	je     8011a0 <dup+0x99>
  801169:	89 f8                	mov    %edi,%eax
  80116b:	c1 e8 0c             	shr    $0xc,%eax
  80116e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801175:	f6 c2 01             	test   $0x1,%dl
  801178:	74 26                	je     8011a0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	25 07 0e 00 00       	and    $0xe07,%eax
  801189:	50                   	push   %eax
  80118a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80118d:	6a 00                	push   $0x0
  80118f:	57                   	push   %edi
  801190:	6a 00                	push   $0x0
  801192:	e8 7e fa ff ff       	call   800c15 <sys_page_map>
  801197:	89 c7                	mov    %eax,%edi
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 2e                	js     8011ce <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011a3:	89 d0                	mov    %edx,%eax
  8011a5:	c1 e8 0c             	shr    $0xc,%eax
  8011a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b7:	50                   	push   %eax
  8011b8:	53                   	push   %ebx
  8011b9:	6a 00                	push   $0x0
  8011bb:	52                   	push   %edx
  8011bc:	6a 00                	push   $0x0
  8011be:	e8 52 fa ff ff       	call   800c15 <sys_page_map>
  8011c3:	89 c7                	mov    %eax,%edi
  8011c5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011c8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ca:	85 ff                	test   %edi,%edi
  8011cc:	79 1d                	jns    8011eb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	53                   	push   %ebx
  8011d2:	6a 00                	push   $0x0
  8011d4:	e8 7e fa ff ff       	call   800c57 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d9:	83 c4 08             	add    $0x8,%esp
  8011dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011df:	6a 00                	push   $0x0
  8011e1:	e8 71 fa ff ff       	call   800c57 <sys_page_unmap>
	return r;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	89 f8                	mov    %edi,%eax
}
  8011eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 14             	sub    $0x14,%esp
  8011fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801200:	50                   	push   %eax
  801201:	53                   	push   %ebx
  801202:	e8 86 fd ff ff       	call   800f8d <fd_lookup>
  801207:	83 c4 08             	add    $0x8,%esp
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	85 c0                	test   %eax,%eax
  80120e:	78 6d                	js     80127d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121a:	ff 30                	pushl  (%eax)
  80121c:	e8 c2 fd ff ff       	call   800fe3 <dev_lookup>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 4c                	js     801274 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801228:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80122b:	8b 42 08             	mov    0x8(%edx),%eax
  80122e:	83 e0 03             	and    $0x3,%eax
  801231:	83 f8 01             	cmp    $0x1,%eax
  801234:	75 21                	jne    801257 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801236:	a1 04 40 80 00       	mov    0x804004,%eax
  80123b:	8b 40 48             	mov    0x48(%eax),%eax
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	53                   	push   %ebx
  801242:	50                   	push   %eax
  801243:	68 ad 24 80 00       	push   $0x8024ad
  801248:	e8 b3 ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801255:	eb 26                	jmp    80127d <read+0x8a>
	}
	if (!dev->dev_read)
  801257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125a:	8b 40 08             	mov    0x8(%eax),%eax
  80125d:	85 c0                	test   %eax,%eax
  80125f:	74 17                	je     801278 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	ff 75 10             	pushl  0x10(%ebp)
  801267:	ff 75 0c             	pushl  0xc(%ebp)
  80126a:	52                   	push   %edx
  80126b:	ff d0                	call   *%eax
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	eb 09                	jmp    80127d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801274:	89 c2                	mov    %eax,%edx
  801276:	eb 05                	jmp    80127d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801278:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80127d:	89 d0                	mov    %edx,%eax
  80127f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801282:	c9                   	leave  
  801283:	c3                   	ret    

00801284 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	57                   	push   %edi
  801288:	56                   	push   %esi
  801289:	53                   	push   %ebx
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801290:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801293:	bb 00 00 00 00       	mov    $0x0,%ebx
  801298:	eb 21                	jmp    8012bb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	89 f0                	mov    %esi,%eax
  80129f:	29 d8                	sub    %ebx,%eax
  8012a1:	50                   	push   %eax
  8012a2:	89 d8                	mov    %ebx,%eax
  8012a4:	03 45 0c             	add    0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	57                   	push   %edi
  8012a9:	e8 45 ff ff ff       	call   8011f3 <read>
		if (m < 0)
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 10                	js     8012c5 <readn+0x41>
			return m;
		if (m == 0)
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	74 0a                	je     8012c3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b9:	01 c3                	add    %eax,%ebx
  8012bb:	39 f3                	cmp    %esi,%ebx
  8012bd:	72 db                	jb     80129a <readn+0x16>
  8012bf:	89 d8                	mov    %ebx,%eax
  8012c1:	eb 02                	jmp    8012c5 <readn+0x41>
  8012c3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 14             	sub    $0x14,%esp
  8012d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	53                   	push   %ebx
  8012dc:	e8 ac fc ff ff       	call   800f8d <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	89 c2                	mov    %eax,%edx
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 68                	js     801352 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ea:	83 ec 08             	sub    $0x8,%esp
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	ff 30                	pushl  (%eax)
  8012f6:	e8 e8 fc ff ff       	call   800fe3 <dev_lookup>
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 47                	js     801349 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801309:	75 21                	jne    80132c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80130b:	a1 04 40 80 00       	mov    0x804004,%eax
  801310:	8b 40 48             	mov    0x48(%eax),%eax
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	53                   	push   %ebx
  801317:	50                   	push   %eax
  801318:	68 c9 24 80 00       	push   $0x8024c9
  80131d:	e8 de ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132a:	eb 26                	jmp    801352 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80132c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132f:	8b 52 0c             	mov    0xc(%edx),%edx
  801332:	85 d2                	test   %edx,%edx
  801334:	74 17                	je     80134d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801336:	83 ec 04             	sub    $0x4,%esp
  801339:	ff 75 10             	pushl  0x10(%ebp)
  80133c:	ff 75 0c             	pushl  0xc(%ebp)
  80133f:	50                   	push   %eax
  801340:	ff d2                	call   *%edx
  801342:	89 c2                	mov    %eax,%edx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	eb 09                	jmp    801352 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	89 c2                	mov    %eax,%edx
  80134b:	eb 05                	jmp    801352 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80134d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801352:	89 d0                	mov    %edx,%eax
  801354:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <seek>:

int
seek(int fdnum, off_t offset)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801362:	50                   	push   %eax
  801363:	ff 75 08             	pushl  0x8(%ebp)
  801366:	e8 22 fc ff ff       	call   800f8d <fd_lookup>
  80136b:	83 c4 08             	add    $0x8,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 0e                	js     801380 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801372:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801375:	8b 55 0c             	mov    0xc(%ebp),%edx
  801378:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 14             	sub    $0x14,%esp
  801389:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	53                   	push   %ebx
  801391:	e8 f7 fb ff ff       	call   800f8d <fd_lookup>
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	89 c2                	mov    %eax,%edx
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 65                	js     801404 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	ff 30                	pushl  (%eax)
  8013ab:	e8 33 fc ff ff       	call   800fe3 <dev_lookup>
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 44                	js     8013fb <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ba:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013be:	75 21                	jne    8013e1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c5:	8b 40 48             	mov    0x48(%eax),%eax
  8013c8:	83 ec 04             	sub    $0x4,%esp
  8013cb:	53                   	push   %ebx
  8013cc:	50                   	push   %eax
  8013cd:	68 8c 24 80 00       	push   $0x80248c
  8013d2:	e8 29 ee ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013df:	eb 23                	jmp    801404 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e4:	8b 52 18             	mov    0x18(%edx),%edx
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	74 14                	je     8013ff <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	ff 75 0c             	pushl  0xc(%ebp)
  8013f1:	50                   	push   %eax
  8013f2:	ff d2                	call   *%edx
  8013f4:	89 c2                	mov    %eax,%edx
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	eb 09                	jmp    801404 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fb:	89 c2                	mov    %eax,%edx
  8013fd:	eb 05                	jmp    801404 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801404:	89 d0                	mov    %edx,%eax
  801406:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 14             	sub    $0x14,%esp
  801412:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801415:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	ff 75 08             	pushl  0x8(%ebp)
  80141c:	e8 6c fb ff ff       	call   800f8d <fd_lookup>
  801421:	83 c4 08             	add    $0x8,%esp
  801424:	89 c2                	mov    %eax,%edx
  801426:	85 c0                	test   %eax,%eax
  801428:	78 58                	js     801482 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801430:	50                   	push   %eax
  801431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801434:	ff 30                	pushl  (%eax)
  801436:	e8 a8 fb ff ff       	call   800fe3 <dev_lookup>
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 37                	js     801479 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801442:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801445:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801449:	74 32                	je     80147d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80144b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80144e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801455:	00 00 00 
	stat->st_isdir = 0;
  801458:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80145f:	00 00 00 
	stat->st_dev = dev;
  801462:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	53                   	push   %ebx
  80146c:	ff 75 f0             	pushl  -0x10(%ebp)
  80146f:	ff 50 14             	call   *0x14(%eax)
  801472:	89 c2                	mov    %eax,%edx
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	eb 09                	jmp    801482 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801479:	89 c2                	mov    %eax,%edx
  80147b:	eb 05                	jmp    801482 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80147d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801482:	89 d0                	mov    %edx,%eax
  801484:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	6a 00                	push   $0x0
  801493:	ff 75 08             	pushl  0x8(%ebp)
  801496:	e8 dc 01 00 00       	call   801677 <open>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 1b                	js     8014bf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	ff 75 0c             	pushl  0xc(%ebp)
  8014aa:	50                   	push   %eax
  8014ab:	e8 5b ff ff ff       	call   80140b <fstat>
  8014b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b2:	89 1c 24             	mov    %ebx,(%esp)
  8014b5:	e8 fd fb ff ff       	call   8010b7 <close>
	return r;
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	89 f0                	mov    %esi,%eax
}
  8014bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c2:	5b                   	pop    %ebx
  8014c3:	5e                   	pop    %esi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
  8014cb:	89 c6                	mov    %eax,%esi
  8014cd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014cf:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014d6:	75 12                	jne    8014ea <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	6a 01                	push   $0x1
  8014dd:	e8 0e 09 00 00       	call   801df0 <ipc_find_env>
  8014e2:	a3 00 40 80 00       	mov    %eax,0x804000
  8014e7:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014ea:	6a 07                	push   $0x7
  8014ec:	68 00 50 80 00       	push   $0x805000
  8014f1:	56                   	push   %esi
  8014f2:	ff 35 00 40 80 00    	pushl  0x804000
  8014f8:	e8 b0 08 00 00       	call   801dad <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8014fd:	83 c4 0c             	add    $0xc,%esp
  801500:	6a 00                	push   $0x0
  801502:	53                   	push   %ebx
  801503:	6a 00                	push   $0x0
  801505:	e8 46 08 00 00       	call   801d50 <ipc_recv>
}
  80150a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150d:	5b                   	pop    %ebx
  80150e:	5e                   	pop    %esi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801517:	8b 45 08             	mov    0x8(%ebp),%eax
  80151a:	8b 40 0c             	mov    0xc(%eax),%eax
  80151d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801522:	8b 45 0c             	mov    0xc(%ebp),%eax
  801525:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80152a:	ba 00 00 00 00       	mov    $0x0,%edx
  80152f:	b8 02 00 00 00       	mov    $0x2,%eax
  801534:	e8 8d ff ff ff       	call   8014c6 <fsipc>
}
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801541:	8b 45 08             	mov    0x8(%ebp),%eax
  801544:	8b 40 0c             	mov    0xc(%eax),%eax
  801547:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80154c:	ba 00 00 00 00       	mov    $0x0,%edx
  801551:	b8 06 00 00 00       	mov    $0x6,%eax
  801556:	e8 6b ff ff ff       	call   8014c6 <fsipc>
}
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	53                   	push   %ebx
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801567:	8b 45 08             	mov    0x8(%ebp),%eax
  80156a:	8b 40 0c             	mov    0xc(%eax),%eax
  80156d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 05 00 00 00       	mov    $0x5,%eax
  80157c:	e8 45 ff ff ff       	call   8014c6 <fsipc>
  801581:	85 c0                	test   %eax,%eax
  801583:	78 2c                	js     8015b1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	68 00 50 80 00       	push   $0x805000
  80158d:	53                   	push   %ebx
  80158e:	e8 3c f2 ff ff       	call   8007cf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801593:	a1 80 50 80 00       	mov    0x805080,%eax
  801598:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80159e:	a1 84 50 80 00       	mov    0x805084,%eax
  8015a3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015cb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015d0:	50                   	push   %eax
  8015d1:	ff 75 0c             	pushl  0xc(%ebp)
  8015d4:	68 08 50 80 00       	push   $0x805008
  8015d9:	e8 83 f3 ff ff       	call   800961 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8015de:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e3:	b8 04 00 00 00       	mov    $0x4,%eax
  8015e8:	e8 d9 fe ff ff       	call   8014c6 <fsipc>
	//panic("devfile_write not implemented");
}
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801602:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801608:	ba 00 00 00 00       	mov    $0x0,%edx
  80160d:	b8 03 00 00 00       	mov    $0x3,%eax
  801612:	e8 af fe ff ff       	call   8014c6 <fsipc>
  801617:	89 c3                	mov    %eax,%ebx
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 51                	js     80166e <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80161d:	39 c6                	cmp    %eax,%esi
  80161f:	73 19                	jae    80163a <devfile_read+0x4b>
  801621:	68 f8 24 80 00       	push   $0x8024f8
  801626:	68 ff 24 80 00       	push   $0x8024ff
  80162b:	68 80 00 00 00       	push   $0x80
  801630:	68 14 25 80 00       	push   $0x802514
  801635:	e8 d0 06 00 00       	call   801d0a <_panic>
	assert(r <= PGSIZE);
  80163a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80163f:	7e 19                	jle    80165a <devfile_read+0x6b>
  801641:	68 1f 25 80 00       	push   $0x80251f
  801646:	68 ff 24 80 00       	push   $0x8024ff
  80164b:	68 81 00 00 00       	push   $0x81
  801650:	68 14 25 80 00       	push   $0x802514
  801655:	e8 b0 06 00 00       	call   801d0a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80165a:	83 ec 04             	sub    $0x4,%esp
  80165d:	50                   	push   %eax
  80165e:	68 00 50 80 00       	push   $0x805000
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	e8 f6 f2 ff ff       	call   800961 <memmove>
	return r;
  80166b:	83 c4 10             	add    $0x10,%esp
}
  80166e:	89 d8                	mov    %ebx,%eax
  801670:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801673:	5b                   	pop    %ebx
  801674:	5e                   	pop    %esi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 20             	sub    $0x20,%esp
  80167e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801681:	53                   	push   %ebx
  801682:	e8 0f f1 ff ff       	call   800796 <strlen>
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80168f:	7f 67                	jg     8016f8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801691:	83 ec 0c             	sub    $0xc,%esp
  801694:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	e8 a1 f8 ff ff       	call   800f3e <fd_alloc>
  80169d:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 57                	js     8016fd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	53                   	push   %ebx
  8016aa:	68 00 50 80 00       	push   $0x805000
  8016af:	e8 1b f1 ff ff       	call   8007cf <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b7:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c4:	e8 fd fd ff ff       	call   8014c6 <fsipc>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	79 14                	jns    8016e6 <open+0x6f>
		
		fd_close(fd, 0);
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	6a 00                	push   $0x0
  8016d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8016da:	e8 57 f9 ff ff       	call   801036 <fd_close>
		return r;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	89 da                	mov    %ebx,%edx
  8016e4:	eb 17                	jmp    8016fd <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8016e6:	83 ec 0c             	sub    $0xc,%esp
  8016e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ec:	e8 26 f8 ff ff       	call   800f17 <fd2num>
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	eb 05                	jmp    8016fd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016f8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8016fd:	89 d0                	mov    %edx,%eax
  8016ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80170a:	ba 00 00 00 00       	mov    $0x0,%edx
  80170f:	b8 08 00 00 00       	mov    $0x8,%eax
  801714:	e8 ad fd ff ff       	call   8014c6 <fsipc>
}
  801719:	c9                   	leave  
  80171a:	c3                   	ret    

0080171b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80171b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80171f:	7e 37                	jle    801758 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	53                   	push   %ebx
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80172a:	ff 70 04             	pushl  0x4(%eax)
  80172d:	8d 40 10             	lea    0x10(%eax),%eax
  801730:	50                   	push   %eax
  801731:	ff 33                	pushl  (%ebx)
  801733:	e8 95 fb ff ff       	call   8012cd <write>
		if (result > 0)
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	7e 03                	jle    801742 <writebuf+0x27>
			b->result += result;
  80173f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801742:	3b 43 04             	cmp    0x4(%ebx),%eax
  801745:	74 0d                	je     801754 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801747:	85 c0                	test   %eax,%eax
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	0f 4f c2             	cmovg  %edx,%eax
  801751:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801757:	c9                   	leave  
  801758:	f3 c3                	repz ret 

0080175a <putch>:

static void
putch(int ch, void *thunk)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 04             	sub    $0x4,%esp
  801761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801764:	8b 53 04             	mov    0x4(%ebx),%edx
  801767:	8d 42 01             	lea    0x1(%edx),%eax
  80176a:	89 43 04             	mov    %eax,0x4(%ebx)
  80176d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801770:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801774:	3d 00 01 00 00       	cmp    $0x100,%eax
  801779:	75 0e                	jne    801789 <putch+0x2f>
		writebuf(b);
  80177b:	89 d8                	mov    %ebx,%eax
  80177d:	e8 99 ff ff ff       	call   80171b <writebuf>
		b->idx = 0;
  801782:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801789:	83 c4 04             	add    $0x4,%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801798:	8b 45 08             	mov    0x8(%ebp),%eax
  80179b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017a1:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017a8:	00 00 00 
	b.result = 0;
  8017ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017b2:	00 00 00 
	b.error = 1;
  8017b5:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017bc:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017bf:	ff 75 10             	pushl  0x10(%ebp)
  8017c2:	ff 75 0c             	pushl  0xc(%ebp)
  8017c5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017cb:	50                   	push   %eax
  8017cc:	68 5a 17 80 00       	push   $0x80175a
  8017d1:	e8 61 eb ff ff       	call   800337 <vprintfmt>
	if (b.idx > 0)
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017e0:	7e 0b                	jle    8017ed <vfprintf+0x5e>
		writebuf(&b);
  8017e2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017e8:	e8 2e ff ff ff       	call   80171b <writebuf>

	return (b.result ? b.result : b.error);
  8017ed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801804:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801807:	50                   	push   %eax
  801808:	ff 75 0c             	pushl  0xc(%ebp)
  80180b:	ff 75 08             	pushl  0x8(%ebp)
  80180e:	e8 7c ff ff ff       	call   80178f <vfprintf>
	va_end(ap);

	return cnt;
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <printf>:

int
printf(const char *fmt, ...)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80181b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80181e:	50                   	push   %eax
  80181f:	ff 75 08             	pushl  0x8(%ebp)
  801822:	6a 01                	push   $0x1
  801824:	e8 66 ff ff ff       	call   80178f <vfprintf>
	va_end(ap);

	return cnt;
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
  801830:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	ff 75 08             	pushl  0x8(%ebp)
  801839:	e8 e9 f6 ff ff       	call   800f27 <fd2data>
  80183e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801840:	83 c4 08             	add    $0x8,%esp
  801843:	68 2b 25 80 00       	push   $0x80252b
  801848:	53                   	push   %ebx
  801849:	e8 81 ef ff ff       	call   8007cf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80184e:	8b 46 04             	mov    0x4(%esi),%eax
  801851:	2b 06                	sub    (%esi),%eax
  801853:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801859:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801860:	00 00 00 
	stat->st_dev = &devpipe;
  801863:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186a:	30 80 00 
	return 0;
}
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
  801872:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801883:	53                   	push   %ebx
  801884:	6a 00                	push   $0x0
  801886:	e8 cc f3 ff ff       	call   800c57 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80188b:	89 1c 24             	mov    %ebx,(%esp)
  80188e:	e8 94 f6 ff ff       	call   800f27 <fd2data>
  801893:	83 c4 08             	add    $0x8,%esp
  801896:	50                   	push   %eax
  801897:	6a 00                	push   $0x0
  801899:	e8 b9 f3 ff ff       	call   800c57 <sys_page_unmap>
}
  80189e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	57                   	push   %edi
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 1c             	sub    $0x1c,%esp
  8018ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018af:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018b6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8018bf:	e8 65 05 00 00       	call   801e29 <pageref>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	89 3c 24             	mov    %edi,(%esp)
  8018c9:	e8 5b 05 00 00       	call   801e29 <pageref>
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	39 c3                	cmp    %eax,%ebx
  8018d3:	0f 94 c1             	sete   %cl
  8018d6:	0f b6 c9             	movzbl %cl,%ecx
  8018d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018dc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018e2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018e5:	39 ce                	cmp    %ecx,%esi
  8018e7:	74 1b                	je     801904 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018e9:	39 c3                	cmp    %eax,%ebx
  8018eb:	75 c4                	jne    8018b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018ed:	8b 42 58             	mov    0x58(%edx),%eax
  8018f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f3:	50                   	push   %eax
  8018f4:	56                   	push   %esi
  8018f5:	68 32 25 80 00       	push   $0x802532
  8018fa:	e8 01 e9 ff ff       	call   800200 <cprintf>
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	eb ad                	jmp    8018b1 <_pipeisclosed+0xe>
	}
}
  801904:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801907:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5f                   	pop    %edi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	57                   	push   %edi
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	83 ec 28             	sub    $0x28,%esp
  801918:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80191b:	56                   	push   %esi
  80191c:	e8 06 f6 ff ff       	call   800f27 <fd2data>
  801921:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	bf 00 00 00 00       	mov    $0x0,%edi
  80192b:	eb 4b                	jmp    801978 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80192d:	89 da                	mov    %ebx,%edx
  80192f:	89 f0                	mov    %esi,%eax
  801931:	e8 6d ff ff ff       	call   8018a3 <_pipeisclosed>
  801936:	85 c0                	test   %eax,%eax
  801938:	75 48                	jne    801982 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193a:	e8 74 f2 ff ff       	call   800bb3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80193f:	8b 43 04             	mov    0x4(%ebx),%eax
  801942:	8b 0b                	mov    (%ebx),%ecx
  801944:	8d 51 20             	lea    0x20(%ecx),%edx
  801947:	39 d0                	cmp    %edx,%eax
  801949:	73 e2                	jae    80192d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80194b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801952:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801955:	89 c2                	mov    %eax,%edx
  801957:	c1 fa 1f             	sar    $0x1f,%edx
  80195a:	89 d1                	mov    %edx,%ecx
  80195c:	c1 e9 1b             	shr    $0x1b,%ecx
  80195f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801962:	83 e2 1f             	and    $0x1f,%edx
  801965:	29 ca                	sub    %ecx,%edx
  801967:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80196b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80196f:	83 c0 01             	add    $0x1,%eax
  801972:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801975:	83 c7 01             	add    $0x1,%edi
  801978:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80197b:	75 c2                	jne    80193f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80197d:	8b 45 10             	mov    0x10(%ebp),%eax
  801980:	eb 05                	jmp    801987 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801982:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801987:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5e                   	pop    %esi
  80198c:	5f                   	pop    %edi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	57                   	push   %edi
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 18             	sub    $0x18,%esp
  801998:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80199b:	57                   	push   %edi
  80199c:	e8 86 f5 ff ff       	call   800f27 <fd2data>
  8019a1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ab:	eb 3d                	jmp    8019ea <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ad:	85 db                	test   %ebx,%ebx
  8019af:	74 04                	je     8019b5 <devpipe_read+0x26>
				return i;
  8019b1:	89 d8                	mov    %ebx,%eax
  8019b3:	eb 44                	jmp    8019f9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019b5:	89 f2                	mov    %esi,%edx
  8019b7:	89 f8                	mov    %edi,%eax
  8019b9:	e8 e5 fe ff ff       	call   8018a3 <_pipeisclosed>
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	75 32                	jne    8019f4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c2:	e8 ec f1 ff ff       	call   800bb3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019c7:	8b 06                	mov    (%esi),%eax
  8019c9:	3b 46 04             	cmp    0x4(%esi),%eax
  8019cc:	74 df                	je     8019ad <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019ce:	99                   	cltd   
  8019cf:	c1 ea 1b             	shr    $0x1b,%edx
  8019d2:	01 d0                	add    %edx,%eax
  8019d4:	83 e0 1f             	and    $0x1f,%eax
  8019d7:	29 d0                	sub    %edx,%eax
  8019d9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019e4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e7:	83 c3 01             	add    $0x1,%ebx
  8019ea:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019ed:	75 d8                	jne    8019c7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f2:	eb 05                	jmp    8019f9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fc:	5b                   	pop    %ebx
  8019fd:	5e                   	pop    %esi
  8019fe:	5f                   	pop    %edi
  8019ff:	5d                   	pop    %ebp
  801a00:	c3                   	ret    

00801a01 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	56                   	push   %esi
  801a05:	53                   	push   %ebx
  801a06:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0c:	50                   	push   %eax
  801a0d:	e8 2c f5 ff ff       	call   800f3e <fd_alloc>
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	85 c0                	test   %eax,%eax
  801a19:	0f 88 2c 01 00 00    	js     801b4b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a1f:	83 ec 04             	sub    $0x4,%esp
  801a22:	68 07 04 00 00       	push   $0x407
  801a27:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 a1 f1 ff ff       	call   800bd2 <sys_page_alloc>
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	89 c2                	mov    %eax,%edx
  801a36:	85 c0                	test   %eax,%eax
  801a38:	0f 88 0d 01 00 00    	js     801b4b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	e8 f4 f4 ff ff       	call   800f3e <fd_alloc>
  801a4a:	89 c3                	mov    %eax,%ebx
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	0f 88 e2 00 00 00    	js     801b39 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a57:	83 ec 04             	sub    $0x4,%esp
  801a5a:	68 07 04 00 00       	push   $0x407
  801a5f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a62:	6a 00                	push   $0x0
  801a64:	e8 69 f1 ff ff       	call   800bd2 <sys_page_alloc>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	0f 88 c3 00 00 00    	js     801b39 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7c:	e8 a6 f4 ff ff       	call   800f27 <fd2data>
  801a81:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a83:	83 c4 0c             	add    $0xc,%esp
  801a86:	68 07 04 00 00       	push   $0x407
  801a8b:	50                   	push   %eax
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 3f f1 ff ff       	call   800bd2 <sys_page_alloc>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	0f 88 89 00 00 00    	js     801b29 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa6:	e8 7c f4 ff ff       	call   800f27 <fd2data>
  801aab:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab2:	50                   	push   %eax
  801ab3:	6a 00                	push   $0x0
  801ab5:	56                   	push   %esi
  801ab6:	6a 00                	push   $0x0
  801ab8:	e8 58 f1 ff ff       	call   800c15 <sys_page_map>
  801abd:	89 c3                	mov    %eax,%ebx
  801abf:	83 c4 20             	add    $0x20,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 55                	js     801b1b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ac6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801adb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	ff 75 f4             	pushl  -0xc(%ebp)
  801af6:	e8 1c f4 ff ff       	call   800f17 <fd2num>
  801afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afe:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b00:	83 c4 04             	add    $0x4,%esp
  801b03:	ff 75 f0             	pushl  -0x10(%ebp)
  801b06:	e8 0c f4 ff ff       	call   800f17 <fd2num>
  801b0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b0e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	ba 00 00 00 00       	mov    $0x0,%edx
  801b19:	eb 30                	jmp    801b4b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	56                   	push   %esi
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 31 f1 ff ff       	call   800c57 <sys_page_unmap>
  801b26:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b29:	83 ec 08             	sub    $0x8,%esp
  801b2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b2f:	6a 00                	push   $0x0
  801b31:	e8 21 f1 ff ff       	call   800c57 <sys_page_unmap>
  801b36:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b39:	83 ec 08             	sub    $0x8,%esp
  801b3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3f:	6a 00                	push   $0x0
  801b41:	e8 11 f1 ff ff       	call   800c57 <sys_page_unmap>
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b4b:	89 d0                	mov    %edx,%eax
  801b4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5d:	50                   	push   %eax
  801b5e:	ff 75 08             	pushl  0x8(%ebp)
  801b61:	e8 27 f4 ff ff       	call   800f8d <fd_lookup>
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 18                	js     801b85 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b6d:	83 ec 0c             	sub    $0xc,%esp
  801b70:	ff 75 f4             	pushl  -0xc(%ebp)
  801b73:	e8 af f3 ff ff       	call   800f27 <fd2data>
	return _pipeisclosed(fd, p);
  801b78:	89 c2                	mov    %eax,%edx
  801b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7d:	e8 21 fd ff ff       	call   8018a3 <_pipeisclosed>
  801b82:	83 c4 10             	add    $0x10,%esp
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b97:	68 4a 25 80 00       	push   $0x80254a
  801b9c:	ff 75 0c             	pushl  0xc(%ebp)
  801b9f:	e8 2b ec ff ff       	call   8007cf <strcpy>
	return 0;
}
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bbc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc2:	eb 2d                	jmp    801bf1 <devcons_write+0x46>
		m = n - tot;
  801bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bc7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bc9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bcc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bd1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd4:	83 ec 04             	sub    $0x4,%esp
  801bd7:	53                   	push   %ebx
  801bd8:	03 45 0c             	add    0xc(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	57                   	push   %edi
  801bdd:	e8 7f ed ff ff       	call   800961 <memmove>
		sys_cputs(buf, m);
  801be2:	83 c4 08             	add    $0x8,%esp
  801be5:	53                   	push   %ebx
  801be6:	57                   	push   %edi
  801be7:	e8 2a ef ff ff       	call   800b16 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bec:	01 de                	add    %ebx,%esi
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	89 f0                	mov    %esi,%eax
  801bf3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf6:	72 cc                	jb     801bc4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5f                   	pop    %edi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	83 ec 08             	sub    $0x8,%esp
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c0f:	74 2a                	je     801c3b <devcons_read+0x3b>
  801c11:	eb 05                	jmp    801c18 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c13:	e8 9b ef ff ff       	call   800bb3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c18:	e8 17 ef ff ff       	call   800b34 <sys_cgetc>
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	74 f2                	je     801c13 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 16                	js     801c3b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c25:	83 f8 04             	cmp    $0x4,%eax
  801c28:	74 0c                	je     801c36 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2d:	88 02                	mov    %al,(%edx)
	return 1;
  801c2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c34:	eb 05                	jmp    801c3b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c36:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c3b:	c9                   	leave  
  801c3c:	c3                   	ret    

00801c3d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c49:	6a 01                	push   $0x1
  801c4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c4e:	50                   	push   %eax
  801c4f:	e8 c2 ee ff ff       	call   800b16 <sys_cputs>
}
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <getchar>:

int
getchar(void)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c5f:	6a 01                	push   $0x1
  801c61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c64:	50                   	push   %eax
  801c65:	6a 00                	push   $0x0
  801c67:	e8 87 f5 ff ff       	call   8011f3 <read>
	if (r < 0)
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 0f                	js     801c82 <getchar+0x29>
		return r;
	if (r < 1)
  801c73:	85 c0                	test   %eax,%eax
  801c75:	7e 06                	jle    801c7d <getchar+0x24>
		return -E_EOF;
	return c;
  801c77:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c7b:	eb 05                	jmp    801c82 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c7d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	ff 75 08             	pushl  0x8(%ebp)
  801c91:	e8 f7 f2 ff ff       	call   800f8d <fd_lookup>
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	78 11                	js     801cae <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca6:	39 10                	cmp    %edx,(%eax)
  801ca8:	0f 94 c0             	sete   %al
  801cab:	0f b6 c0             	movzbl %al,%eax
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <opencons>:

int
opencons(void)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb9:	50                   	push   %eax
  801cba:	e8 7f f2 ff ff       	call   800f3e <fd_alloc>
  801cbf:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 3e                	js     801d06 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc8:	83 ec 04             	sub    $0x4,%esp
  801ccb:	68 07 04 00 00       	push   $0x407
  801cd0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd3:	6a 00                	push   $0x0
  801cd5:	e8 f8 ee ff ff       	call   800bd2 <sys_page_alloc>
  801cda:	83 c4 10             	add    $0x10,%esp
		return r;
  801cdd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	78 23                	js     801d06 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	50                   	push   %eax
  801cfc:	e8 16 f2 ff ff       	call   800f17 <fd2num>
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	83 c4 10             	add    $0x10,%esp
}
  801d06:	89 d0                	mov    %edx,%eax
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d0f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d12:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d18:	e8 77 ee ff ff       	call   800b94 <sys_getenvid>
  801d1d:	83 ec 0c             	sub    $0xc,%esp
  801d20:	ff 75 0c             	pushl  0xc(%ebp)
  801d23:	ff 75 08             	pushl  0x8(%ebp)
  801d26:	56                   	push   %esi
  801d27:	50                   	push   %eax
  801d28:	68 58 25 80 00       	push   $0x802558
  801d2d:	e8 ce e4 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d32:	83 c4 18             	add    $0x18,%esp
  801d35:	53                   	push   %ebx
  801d36:	ff 75 10             	pushl  0x10(%ebp)
  801d39:	e8 71 e4 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  801d3e:	c7 04 24 10 21 80 00 	movl   $0x802110,(%esp)
  801d45:	e8 b6 e4 ff ff       	call   800200 <cprintf>
  801d4a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d4d:	cc                   	int3   
  801d4e:	eb fd                	jmp    801d4d <_panic+0x43>

00801d50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
  801d55:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d58:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	ff 75 0c             	pushl  0xc(%ebp)
  801d61:	e8 1c f0 ff ff       	call   800d82 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	85 f6                	test   %esi,%esi
  801d6b:	74 1c                	je     801d89 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801d6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801d72:	8b 40 78             	mov    0x78(%eax),%eax
  801d75:	89 06                	mov    %eax,(%esi)
  801d77:	eb 10                	jmp    801d89 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	68 7c 25 80 00       	push   $0x80257c
  801d81:	e8 7a e4 ff ff       	call   800200 <cprintf>
  801d86:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801d89:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8e:	8b 50 74             	mov    0x74(%eax),%edx
  801d91:	85 d2                	test   %edx,%edx
  801d93:	74 e4                	je     801d79 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801d95:	85 db                	test   %ebx,%ebx
  801d97:	74 05                	je     801d9e <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801d99:	8b 40 74             	mov    0x74(%eax),%eax
  801d9c:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801d9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801da3:	8b 40 70             	mov    0x70(%eax),%eax

}
  801da6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da9:	5b                   	pop    %ebx
  801daa:	5e                   	pop    %esi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	57                   	push   %edi
  801db1:	56                   	push   %esi
  801db2:	53                   	push   %ebx
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801db9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801dbf:	85 db                	test   %ebx,%ebx
  801dc1:	75 13                	jne    801dd6 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801dc3:	6a 00                	push   $0x0
  801dc5:	68 00 00 c0 ee       	push   $0xeec00000
  801dca:	56                   	push   %esi
  801dcb:	57                   	push   %edi
  801dcc:	e8 8e ef ff ff       	call   800d5f <sys_ipc_try_send>
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	eb 0e                	jmp    801de4 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801dd6:	ff 75 14             	pushl  0x14(%ebp)
  801dd9:	53                   	push   %ebx
  801dda:	56                   	push   %esi
  801ddb:	57                   	push   %edi
  801ddc:	e8 7e ef ff ff       	call   800d5f <sys_ipc_try_send>
  801de1:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801de4:	85 c0                	test   %eax,%eax
  801de6:	75 d7                	jne    801dbf <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801deb:	5b                   	pop    %ebx
  801dec:	5e                   	pop    %esi
  801ded:	5f                   	pop    %edi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dfb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801dfe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e04:	8b 52 50             	mov    0x50(%edx),%edx
  801e07:	39 ca                	cmp    %ecx,%edx
  801e09:	75 0d                	jne    801e18 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e0b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e0e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e13:	8b 40 48             	mov    0x48(%eax),%eax
  801e16:	eb 0f                	jmp    801e27 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e18:	83 c0 01             	add    $0x1,%eax
  801e1b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e20:	75 d9                	jne    801dfb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e2f:	89 d0                	mov    %edx,%eax
  801e31:	c1 e8 16             	shr    $0x16,%eax
  801e34:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e3b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e40:	f6 c1 01             	test   $0x1,%cl
  801e43:	74 1d                	je     801e62 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e45:	c1 ea 0c             	shr    $0xc,%edx
  801e48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e4f:	f6 c2 01             	test   $0x1,%dl
  801e52:	74 0e                	je     801e62 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e54:	c1 ea 0c             	shr    $0xc,%edx
  801e57:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e5e:	ef 
  801e5f:	0f b7 c0             	movzwl %ax,%eax
}
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    
  801e64:	66 90                	xchg   %ax,%ax
  801e66:	66 90                	xchg   %ax,%ax
  801e68:	66 90                	xchg   %ax,%ax
  801e6a:	66 90                	xchg   %ax,%ax
  801e6c:	66 90                	xchg   %ax,%ax
  801e6e:	66 90                	xchg   %ax,%ax

00801e70 <__udivdi3>:
  801e70:	55                   	push   %ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	83 ec 1c             	sub    $0x1c,%esp
  801e77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e87:	85 f6                	test   %esi,%esi
  801e89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e8d:	89 ca                	mov    %ecx,%edx
  801e8f:	89 f8                	mov    %edi,%eax
  801e91:	75 3d                	jne    801ed0 <__udivdi3+0x60>
  801e93:	39 cf                	cmp    %ecx,%edi
  801e95:	0f 87 c5 00 00 00    	ja     801f60 <__udivdi3+0xf0>
  801e9b:	85 ff                	test   %edi,%edi
  801e9d:	89 fd                	mov    %edi,%ebp
  801e9f:	75 0b                	jne    801eac <__udivdi3+0x3c>
  801ea1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea6:	31 d2                	xor    %edx,%edx
  801ea8:	f7 f7                	div    %edi
  801eaa:	89 c5                	mov    %eax,%ebp
  801eac:	89 c8                	mov    %ecx,%eax
  801eae:	31 d2                	xor    %edx,%edx
  801eb0:	f7 f5                	div    %ebp
  801eb2:	89 c1                	mov    %eax,%ecx
  801eb4:	89 d8                	mov    %ebx,%eax
  801eb6:	89 cf                	mov    %ecx,%edi
  801eb8:	f7 f5                	div    %ebp
  801eba:	89 c3                	mov    %eax,%ebx
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
  801ed0:	39 ce                	cmp    %ecx,%esi
  801ed2:	77 74                	ja     801f48 <__udivdi3+0xd8>
  801ed4:	0f bd fe             	bsr    %esi,%edi
  801ed7:	83 f7 1f             	xor    $0x1f,%edi
  801eda:	0f 84 98 00 00 00    	je     801f78 <__udivdi3+0x108>
  801ee0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ee5:	89 f9                	mov    %edi,%ecx
  801ee7:	89 c5                	mov    %eax,%ebp
  801ee9:	29 fb                	sub    %edi,%ebx
  801eeb:	d3 e6                	shl    %cl,%esi
  801eed:	89 d9                	mov    %ebx,%ecx
  801eef:	d3 ed                	shr    %cl,%ebp
  801ef1:	89 f9                	mov    %edi,%ecx
  801ef3:	d3 e0                	shl    %cl,%eax
  801ef5:	09 ee                	or     %ebp,%esi
  801ef7:	89 d9                	mov    %ebx,%ecx
  801ef9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801efd:	89 d5                	mov    %edx,%ebp
  801eff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f03:	d3 ed                	shr    %cl,%ebp
  801f05:	89 f9                	mov    %edi,%ecx
  801f07:	d3 e2                	shl    %cl,%edx
  801f09:	89 d9                	mov    %ebx,%ecx
  801f0b:	d3 e8                	shr    %cl,%eax
  801f0d:	09 c2                	or     %eax,%edx
  801f0f:	89 d0                	mov    %edx,%eax
  801f11:	89 ea                	mov    %ebp,%edx
  801f13:	f7 f6                	div    %esi
  801f15:	89 d5                	mov    %edx,%ebp
  801f17:	89 c3                	mov    %eax,%ebx
  801f19:	f7 64 24 0c          	mull   0xc(%esp)
  801f1d:	39 d5                	cmp    %edx,%ebp
  801f1f:	72 10                	jb     801f31 <__udivdi3+0xc1>
  801f21:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f25:	89 f9                	mov    %edi,%ecx
  801f27:	d3 e6                	shl    %cl,%esi
  801f29:	39 c6                	cmp    %eax,%esi
  801f2b:	73 07                	jae    801f34 <__udivdi3+0xc4>
  801f2d:	39 d5                	cmp    %edx,%ebp
  801f2f:	75 03                	jne    801f34 <__udivdi3+0xc4>
  801f31:	83 eb 01             	sub    $0x1,%ebx
  801f34:	31 ff                	xor    %edi,%edi
  801f36:	89 d8                	mov    %ebx,%eax
  801f38:	89 fa                	mov    %edi,%edx
  801f3a:	83 c4 1c             	add    $0x1c,%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5f                   	pop    %edi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    
  801f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f48:	31 ff                	xor    %edi,%edi
  801f4a:	31 db                	xor    %ebx,%ebx
  801f4c:	89 d8                	mov    %ebx,%eax
  801f4e:	89 fa                	mov    %edi,%edx
  801f50:	83 c4 1c             	add    $0x1c,%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    
  801f58:	90                   	nop
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	89 d8                	mov    %ebx,%eax
  801f62:	f7 f7                	div    %edi
  801f64:	31 ff                	xor    %edi,%edi
  801f66:	89 c3                	mov    %eax,%ebx
  801f68:	89 d8                	mov    %ebx,%eax
  801f6a:	89 fa                	mov    %edi,%edx
  801f6c:	83 c4 1c             	add    $0x1c,%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    
  801f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f78:	39 ce                	cmp    %ecx,%esi
  801f7a:	72 0c                	jb     801f88 <__udivdi3+0x118>
  801f7c:	31 db                	xor    %ebx,%ebx
  801f7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f82:	0f 87 34 ff ff ff    	ja     801ebc <__udivdi3+0x4c>
  801f88:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f8d:	e9 2a ff ff ff       	jmp    801ebc <__udivdi3+0x4c>
  801f92:	66 90                	xchg   %ax,%ax
  801f94:	66 90                	xchg   %ax,%ax
  801f96:	66 90                	xchg   %ax,%ax
  801f98:	66 90                	xchg   %ax,%ax
  801f9a:	66 90                	xchg   %ax,%ax
  801f9c:	66 90                	xchg   %ax,%ax
  801f9e:	66 90                	xchg   %ax,%ax

00801fa0 <__umoddi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801faf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb7:	85 d2                	test   %edx,%edx
  801fb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fc1:	89 f3                	mov    %esi,%ebx
  801fc3:	89 3c 24             	mov    %edi,(%esp)
  801fc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fca:	75 1c                	jne    801fe8 <__umoddi3+0x48>
  801fcc:	39 f7                	cmp    %esi,%edi
  801fce:	76 50                	jbe    802020 <__umoddi3+0x80>
  801fd0:	89 c8                	mov    %ecx,%eax
  801fd2:	89 f2                	mov    %esi,%edx
  801fd4:	f7 f7                	div    %edi
  801fd6:	89 d0                	mov    %edx,%eax
  801fd8:	31 d2                	xor    %edx,%edx
  801fda:	83 c4 1c             	add    $0x1c,%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    
  801fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fe8:	39 f2                	cmp    %esi,%edx
  801fea:	89 d0                	mov    %edx,%eax
  801fec:	77 52                	ja     802040 <__umoddi3+0xa0>
  801fee:	0f bd ea             	bsr    %edx,%ebp
  801ff1:	83 f5 1f             	xor    $0x1f,%ebp
  801ff4:	75 5a                	jne    802050 <__umoddi3+0xb0>
  801ff6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801ffa:	0f 82 e0 00 00 00    	jb     8020e0 <__umoddi3+0x140>
  802000:	39 0c 24             	cmp    %ecx,(%esp)
  802003:	0f 86 d7 00 00 00    	jbe    8020e0 <__umoddi3+0x140>
  802009:	8b 44 24 08          	mov    0x8(%esp),%eax
  80200d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802011:	83 c4 1c             	add    $0x1c,%esp
  802014:	5b                   	pop    %ebx
  802015:	5e                   	pop    %esi
  802016:	5f                   	pop    %edi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	85 ff                	test   %edi,%edi
  802022:	89 fd                	mov    %edi,%ebp
  802024:	75 0b                	jne    802031 <__umoddi3+0x91>
  802026:	b8 01 00 00 00       	mov    $0x1,%eax
  80202b:	31 d2                	xor    %edx,%edx
  80202d:	f7 f7                	div    %edi
  80202f:	89 c5                	mov    %eax,%ebp
  802031:	89 f0                	mov    %esi,%eax
  802033:	31 d2                	xor    %edx,%edx
  802035:	f7 f5                	div    %ebp
  802037:	89 c8                	mov    %ecx,%eax
  802039:	f7 f5                	div    %ebp
  80203b:	89 d0                	mov    %edx,%eax
  80203d:	eb 99                	jmp    801fd8 <__umoddi3+0x38>
  80203f:	90                   	nop
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 f2                	mov    %esi,%edx
  802044:	83 c4 1c             	add    $0x1c,%esp
  802047:	5b                   	pop    %ebx
  802048:	5e                   	pop    %esi
  802049:	5f                   	pop    %edi
  80204a:	5d                   	pop    %ebp
  80204b:	c3                   	ret    
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	8b 34 24             	mov    (%esp),%esi
  802053:	bf 20 00 00 00       	mov    $0x20,%edi
  802058:	89 e9                	mov    %ebp,%ecx
  80205a:	29 ef                	sub    %ebp,%edi
  80205c:	d3 e0                	shl    %cl,%eax
  80205e:	89 f9                	mov    %edi,%ecx
  802060:	89 f2                	mov    %esi,%edx
  802062:	d3 ea                	shr    %cl,%edx
  802064:	89 e9                	mov    %ebp,%ecx
  802066:	09 c2                	or     %eax,%edx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 14 24             	mov    %edx,(%esp)
  80206d:	89 f2                	mov    %esi,%edx
  80206f:	d3 e2                	shl    %cl,%edx
  802071:	89 f9                	mov    %edi,%ecx
  802073:	89 54 24 04          	mov    %edx,0x4(%esp)
  802077:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	89 e9                	mov    %ebp,%ecx
  80207f:	89 c6                	mov    %eax,%esi
  802081:	d3 e3                	shl    %cl,%ebx
  802083:	89 f9                	mov    %edi,%ecx
  802085:	89 d0                	mov    %edx,%eax
  802087:	d3 e8                	shr    %cl,%eax
  802089:	89 e9                	mov    %ebp,%ecx
  80208b:	09 d8                	or     %ebx,%eax
  80208d:	89 d3                	mov    %edx,%ebx
  80208f:	89 f2                	mov    %esi,%edx
  802091:	f7 34 24             	divl   (%esp)
  802094:	89 d6                	mov    %edx,%esi
  802096:	d3 e3                	shl    %cl,%ebx
  802098:	f7 64 24 04          	mull   0x4(%esp)
  80209c:	39 d6                	cmp    %edx,%esi
  80209e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020a2:	89 d1                	mov    %edx,%ecx
  8020a4:	89 c3                	mov    %eax,%ebx
  8020a6:	72 08                	jb     8020b0 <__umoddi3+0x110>
  8020a8:	75 11                	jne    8020bb <__umoddi3+0x11b>
  8020aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8020ae:	73 0b                	jae    8020bb <__umoddi3+0x11b>
  8020b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8020b4:	1b 14 24             	sbb    (%esp),%edx
  8020b7:	89 d1                	mov    %edx,%ecx
  8020b9:	89 c3                	mov    %eax,%ebx
  8020bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8020bf:	29 da                	sub    %ebx,%edx
  8020c1:	19 ce                	sbb    %ecx,%esi
  8020c3:	89 f9                	mov    %edi,%ecx
  8020c5:	89 f0                	mov    %esi,%eax
  8020c7:	d3 e0                	shl    %cl,%eax
  8020c9:	89 e9                	mov    %ebp,%ecx
  8020cb:	d3 ea                	shr    %cl,%edx
  8020cd:	89 e9                	mov    %ebp,%ecx
  8020cf:	d3 ee                	shr    %cl,%esi
  8020d1:	09 d0                	or     %edx,%eax
  8020d3:	89 f2                	mov    %esi,%edx
  8020d5:	83 c4 1c             	add    $0x1c,%esp
  8020d8:	5b                   	pop    %ebx
  8020d9:	5e                   	pop    %esi
  8020da:	5f                   	pop    %edi
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    
  8020dd:	8d 76 00             	lea    0x0(%esi),%esi
  8020e0:	29 f9                	sub    %edi,%ecx
  8020e2:	19 d6                	sbb    %edx,%esi
  8020e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020ec:	e9 18 ff ff ff       	jmp    802009 <__umoddi3+0x69>
