
obj/user/sendpage:     file format elf32-i386


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
  800039:	e8 c7 0d 00 00       	call   800e05 <fork>
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
  800057:	e8 d7 0d 00 00       	call   800e33 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 80 11 80 00       	push   $0x801180
  80006c:	e8 13 02 00 00       	call   800284 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 20 80 00    	pushl  0x802004
  80007a:	e8 9b 07 00 00       	call   80081a <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 20 80 00    	pushl  0x802004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 90 08 00 00       	call   800923 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 94 11 80 00       	push   $0x801194
  8000a2:	e8 dd 01 00 00       	call   800284 <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 20 80 00    	pushl  0x802000
  8000b3:	e8 62 07 00 00       	call   80081a <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 20 80 00    	pushl  0x802000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 7e 09 00 00       	call   800a4d <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 6a 0d 00 00       	call   800e4a <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 56 0b 00 00       	call   800c56 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 20 80 00    	pushl  0x802004
  800109:	e8 0c 07 00 00       	call   80081a <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 20 80 00    	pushl  0x802004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 28 09 00 00       	call   800a4d <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 14 0d 00 00       	call   800e4a <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 ea 0c 00 00       	call   800e33 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 80 11 80 00       	push   $0x801180
  800159:	e8 26 01 00 00       	call   800284 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 20 80 00    	pushl  0x802000
  800167:	e8 ae 06 00 00       	call   80081a <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 20 80 00    	pushl  0x802000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 a3 07 00 00       	call   800923 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 b4 11 80 00       	push   $0x8011b4
  80018f:	e8 f0 00 00 00       	call   800284 <cprintf>
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
  8001a4:	e8 6f 0a 00 00       	call   800c18 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 20 80 00       	mov    %eax,0x802008

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
  8001e2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001e5:	6a 00                	push   $0x0
  8001e7:	e8 eb 09 00 00       	call   800bd7 <sys_env_destroy>
}
  8001ec:	83 c4 10             	add    $0x10,%esp
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 04             	sub    $0x4,%esp
  8001f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fb:	8b 13                	mov    (%ebx),%edx
  8001fd:	8d 42 01             	lea    0x1(%edx),%eax
  800200:	89 03                	mov    %eax,(%ebx)
  800202:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800205:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800209:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020e:	75 1a                	jne    80022a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	68 ff 00 00 00       	push   $0xff
  800218:	8d 43 08             	lea    0x8(%ebx),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 79 09 00 00       	call   800b9a <sys_cputs>
		b->idx = 0;
  800221:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800227:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	68 f1 01 80 00       	push   $0x8001f1
  800262:	e8 54 01 00 00       	call   8003bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	83 c4 08             	add    $0x8,%esp
  80026a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	e8 1e 09 00 00       	call   800b9a <sys_cputs>

	return b.cnt;
}
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 9d ff ff ff       	call   800233 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 1c             	sub    $0x1c,%esp
  8002a1:	89 c7                	mov    %eax,%edi
  8002a3:	89 d6                	mov    %edx,%esi
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002bc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002bf:	39 d3                	cmp    %edx,%ebx
  8002c1:	72 05                	jb     8002c8 <printnum+0x30>
  8002c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002c6:	77 45                	ja     80030d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	ff 75 18             	pushl  0x18(%ebp)
  8002ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002d4:	53                   	push   %ebx
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002de:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e7:	e8 f4 0b 00 00       	call   800ee0 <__udivdi3>
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	52                   	push   %edx
  8002f0:	50                   	push   %eax
  8002f1:	89 f2                	mov    %esi,%edx
  8002f3:	89 f8                	mov    %edi,%eax
  8002f5:	e8 9e ff ff ff       	call   800298 <printnum>
  8002fa:	83 c4 20             	add    $0x20,%esp
  8002fd:	eb 18                	jmp    800317 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	ff d7                	call   *%edi
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	eb 03                	jmp    800310 <printnum+0x78>
  80030d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800310:	83 eb 01             	sub    $0x1,%ebx
  800313:	85 db                	test   %ebx,%ebx
  800315:	7f e8                	jg     8002ff <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800317:	83 ec 08             	sub    $0x8,%esp
  80031a:	56                   	push   %esi
  80031b:	83 ec 04             	sub    $0x4,%esp
  80031e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800321:	ff 75 e0             	pushl  -0x20(%ebp)
  800324:	ff 75 dc             	pushl  -0x24(%ebp)
  800327:	ff 75 d8             	pushl  -0x28(%ebp)
  80032a:	e8 e1 0c 00 00       	call   801010 <__umoddi3>
  80032f:	83 c4 14             	add    $0x14,%esp
  800332:	0f be 80 2c 12 80 00 	movsbl 0x80122c(%eax),%eax
  800339:	50                   	push   %eax
  80033a:	ff d7                	call   *%edi
}
  80033c:	83 c4 10             	add    $0x10,%esp
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034a:	83 fa 01             	cmp    $0x1,%edx
  80034d:	7e 0e                	jle    80035d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 08             	lea    0x8(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	8b 52 04             	mov    0x4(%edx),%edx
  80035b:	eb 22                	jmp    80037f <getuint+0x38>
	else if (lflag)
  80035d:	85 d2                	test   %edx,%edx
  80035f:	74 10                	je     800371 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800361:	8b 10                	mov    (%eax),%edx
  800363:	8d 4a 04             	lea    0x4(%edx),%ecx
  800366:	89 08                	mov    %ecx,(%eax)
  800368:	8b 02                	mov    (%edx),%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	eb 0e                	jmp    80037f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800371:	8b 10                	mov    (%eax),%edx
  800373:	8d 4a 04             	lea    0x4(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 02                	mov    (%edx),%eax
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800387:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	3b 50 04             	cmp    0x4(%eax),%edx
  800390:	73 0a                	jae    80039c <sprintputch+0x1b>
		*b->buf++ = ch;
  800392:	8d 4a 01             	lea    0x1(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	88 02                	mov    %al,(%edx)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	50                   	push   %eax
  8003a8:	ff 75 10             	pushl  0x10(%ebp)
  8003ab:	ff 75 0c             	pushl  0xc(%ebp)
  8003ae:	ff 75 08             	pushl  0x8(%ebp)
  8003b1:	e8 05 00 00 00       	call   8003bb <vprintfmt>
	va_end(ap);
}
  8003b6:	83 c4 10             	add    $0x10,%esp
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	57                   	push   %edi
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 2c             	sub    $0x2c,%esp
  8003c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cd:	eb 12                	jmp    8003e1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	0f 84 d3 03 00 00    	je     8007aa <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	53                   	push   %ebx
  8003db:	50                   	push   %eax
  8003dc:	ff d6                	call   *%esi
  8003de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	83 c7 01             	add    $0x1,%edi
  8003e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003e8:	83 f8 25             	cmp    $0x25,%eax
  8003eb:	75 e2                	jne    8003cf <vprintfmt+0x14>
  8003ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800406:	ba 00 00 00 00       	mov    $0x0,%edx
  80040b:	eb 07                	jmp    800414 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800410:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8d 47 01             	lea    0x1(%edi),%eax
  800417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041a:	0f b6 07             	movzbl (%edi),%eax
  80041d:	0f b6 c8             	movzbl %al,%ecx
  800420:	83 e8 23             	sub    $0x23,%eax
  800423:	3c 55                	cmp    $0x55,%al
  800425:	0f 87 64 03 00 00    	ja     80078f <vprintfmt+0x3d4>
  80042b:	0f b6 c0             	movzbl %al,%eax
  80042e:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800438:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80043c:	eb d6                	jmp    800414 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800449:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800450:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800453:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800456:	83 fa 09             	cmp    $0x9,%edx
  800459:	77 39                	ja     800494 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb e9                	jmp    800449 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 48 04             	lea    0x4(%eax),%ecx
  800466:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800469:	8b 00                	mov    (%eax),%eax
  80046b:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800471:	eb 27                	jmp    80049a <vprintfmt+0xdf>
  800473:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047d:	0f 49 c8             	cmovns %eax,%ecx
  800480:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800486:	eb 8c                	jmp    800414 <vprintfmt+0x59>
  800488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800492:	eb 80                	jmp    800414 <vprintfmt+0x59>
  800494:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800497:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80049a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049e:	0f 89 70 ff ff ff    	jns    800414 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004aa:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004b1:	e9 5e ff ff ff       	jmp    800414 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bc:	e9 53 ff ff ff       	jmp    800414 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	53                   	push   %ebx
  8004ce:	ff 30                	pushl  (%eax)
  8004d0:	ff d6                	call   *%esi
			break;
  8004d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d8:	e9 04 ff ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	8b 00                	mov    (%eax),%eax
  8004e8:	99                   	cltd   
  8004e9:	31 d0                	xor    %edx,%eax
  8004eb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ed:	83 f8 08             	cmp    $0x8,%eax
  8004f0:	7f 0b                	jg     8004fd <vprintfmt+0x142>
  8004f2:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  8004f9:	85 d2                	test   %edx,%edx
  8004fb:	75 18                	jne    800515 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004fd:	50                   	push   %eax
  8004fe:	68 44 12 80 00       	push   $0x801244
  800503:	53                   	push   %ebx
  800504:	56                   	push   %esi
  800505:	e8 94 fe ff ff       	call   80039e <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800510:	e9 cc fe ff ff       	jmp    8003e1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800515:	52                   	push   %edx
  800516:	68 4d 12 80 00       	push   $0x80124d
  80051b:	53                   	push   %ebx
  80051c:	56                   	push   %esi
  80051d:	e8 7c fe ff ff       	call   80039e <printfmt>
  800522:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800528:	e9 b4 fe ff ff       	jmp    8003e1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800538:	85 ff                	test   %edi,%edi
  80053a:	b8 3d 12 80 00       	mov    $0x80123d,%eax
  80053f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800542:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800546:	0f 8e 94 00 00 00    	jle    8005e0 <vprintfmt+0x225>
  80054c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800550:	0f 84 98 00 00 00    	je     8005ee <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	ff 75 c8             	pushl  -0x38(%ebp)
  80055c:	57                   	push   %edi
  80055d:	e8 d0 02 00 00       	call   800832 <strnlen>
  800562:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800565:	29 c1                	sub    %eax,%ecx
  800567:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80056a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800571:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800574:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800577:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800579:	eb 0f                	jmp    80058a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	ff 75 e0             	pushl  -0x20(%ebp)
  800582:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	83 ef 01             	sub    $0x1,%edi
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	85 ff                	test   %edi,%edi
  80058c:	7f ed                	jg     80057b <vprintfmt+0x1c0>
  80058e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800591:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800594:	85 c9                	test   %ecx,%ecx
  800596:	b8 00 00 00 00       	mov    $0x0,%eax
  80059b:	0f 49 c1             	cmovns %ecx,%eax
  80059e:	29 c1                	sub    %eax,%ecx
  8005a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a9:	89 cb                	mov    %ecx,%ebx
  8005ab:	eb 4d                	jmp    8005fa <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b1:	74 1b                	je     8005ce <vprintfmt+0x213>
  8005b3:	0f be c0             	movsbl %al,%eax
  8005b6:	83 e8 20             	sub    $0x20,%eax
  8005b9:	83 f8 5e             	cmp    $0x5e,%eax
  8005bc:	76 10                	jbe    8005ce <vprintfmt+0x213>
					putch('?', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	ff 75 0c             	pushl  0xc(%ebp)
  8005c4:	6a 3f                	push   $0x3f
  8005c6:	ff 55 08             	call   *0x8(%ebp)
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	eb 0d                	jmp    8005db <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	ff 75 0c             	pushl  0xc(%ebp)
  8005d4:	52                   	push   %edx
  8005d5:	ff 55 08             	call   *0x8(%ebp)
  8005d8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005db:	83 eb 01             	sub    $0x1,%ebx
  8005de:	eb 1a                	jmp    8005fa <vprintfmt+0x23f>
  8005e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ec:	eb 0c                	jmp    8005fa <vprintfmt+0x23f>
  8005ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f1:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005fa:	83 c7 01             	add    $0x1,%edi
  8005fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800601:	0f be d0             	movsbl %al,%edx
  800604:	85 d2                	test   %edx,%edx
  800606:	74 23                	je     80062b <vprintfmt+0x270>
  800608:	85 f6                	test   %esi,%esi
  80060a:	78 a1                	js     8005ad <vprintfmt+0x1f2>
  80060c:	83 ee 01             	sub    $0x1,%esi
  80060f:	79 9c                	jns    8005ad <vprintfmt+0x1f2>
  800611:	89 df                	mov    %ebx,%edi
  800613:	8b 75 08             	mov    0x8(%ebp),%esi
  800616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800619:	eb 18                	jmp    800633 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	6a 20                	push   $0x20
  800621:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800623:	83 ef 01             	sub    $0x1,%edi
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 08                	jmp    800633 <vprintfmt+0x278>
  80062b:	89 df                	mov    %ebx,%edi
  80062d:	8b 75 08             	mov    0x8(%ebp),%esi
  800630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800633:	85 ff                	test   %edi,%edi
  800635:	7f e4                	jg     80061b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063a:	e9 a2 fd ff ff       	jmp    8003e1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063f:	83 fa 01             	cmp    $0x1,%edx
  800642:	7e 16                	jle    80065a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 08             	lea    0x8(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 50 04             	mov    0x4(%eax),%edx
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800655:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800658:	eb 32                	jmp    80068c <vprintfmt+0x2d1>
	else if (lflag)
  80065a:	85 d2                	test   %edx,%edx
  80065c:	74 18                	je     800676 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80066c:	89 c1                	mov    %eax,%ecx
  80066e:	c1 f9 1f             	sar    $0x1f,%ecx
  800671:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800674:	eb 16                	jmp    80068c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 50 04             	lea    0x4(%eax),%edx
  80067c:	89 55 14             	mov    %edx,0x14(%ebp)
  80067f:	8b 00                	mov    (%eax),%eax
  800681:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800684:	89 c1                	mov    %eax,%ecx
  800686:	c1 f9 1f             	sar    $0x1f,%ecx
  800689:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80068f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800692:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800695:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800698:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006a1:	0f 89 b0 00 00 00    	jns    800757 <vprintfmt+0x39c>
				putch('-', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 2d                	push   $0x2d
  8006ad:	ff d6                	call   *%esi
				num = -(long long) num;
  8006af:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006b2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006b5:	f7 d8                	neg    %eax
  8006b7:	83 d2 00             	adc    $0x0,%edx
  8006ba:	f7 da                	neg    %edx
  8006bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	e9 88 00 00 00       	jmp    800757 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d2:	e8 70 fc ff ff       	call   800347 <getuint>
  8006d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006da:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e2:	eb 73                	jmp    800757 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e7:	e8 5b fc ff ff       	call   800347 <getuint>
  8006ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 58                	push   $0x58
  8006f8:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fa:	83 c4 08             	add    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 58                	push   $0x58
  800700:	ff d6                	call   *%esi
			putch('X', putdat);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 58                	push   $0x58
  800708:	ff d6                	call   *%esi
			goto number;
  80070a:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80070d:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800712:	eb 43                	jmp    800757 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 30                	push   $0x30
  80071a:	ff d6                	call   *%esi
			putch('x', putdat);
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 78                	push   $0x78
  800722:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	ba 00 00 00 00       	mov    $0x0,%edx
  800734:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800737:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800742:	eb 13                	jmp    800757 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
  800747:	e8 fb fb ff ff       	call   800347 <getuint>
  80074c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800752:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800757:	83 ec 0c             	sub    $0xc,%esp
  80075a:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80075e:	52                   	push   %edx
  80075f:	ff 75 e0             	pushl  -0x20(%ebp)
  800762:	50                   	push   %eax
  800763:	ff 75 dc             	pushl  -0x24(%ebp)
  800766:	ff 75 d8             	pushl  -0x28(%ebp)
  800769:	89 da                	mov    %ebx,%edx
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	e8 26 fb ff ff       	call   800298 <printnum>
			break;
  800772:	83 c4 20             	add    $0x20,%esp
  800775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800778:	e9 64 fc ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	51                   	push   %ecx
  800782:	ff d6                	call   *%esi
			break;
  800784:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078a:	e9 52 fc ff ff       	jmp    8003e1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	53                   	push   %ebx
  800793:	6a 25                	push   $0x25
  800795:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	eb 03                	jmp    80079f <vprintfmt+0x3e4>
  80079c:	83 ef 01             	sub    $0x1,%edi
  80079f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a3:	75 f7                	jne    80079c <vprintfmt+0x3e1>
  8007a5:	e9 37 fc ff ff       	jmp    8003e1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 18             	sub    $0x18,%esp
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	74 26                	je     8007f9 <vsnprintf+0x47>
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	7e 22                	jle    8007f9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d7:	ff 75 14             	pushl  0x14(%ebp)
  8007da:	ff 75 10             	pushl  0x10(%ebp)
  8007dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e0:	50                   	push   %eax
  8007e1:	68 81 03 80 00       	push   $0x800381
  8007e6:	e8 d0 fb ff ff       	call   8003bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	eb 05                	jmp    8007fe <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800809:	50                   	push   %eax
  80080a:	ff 75 10             	pushl  0x10(%ebp)
  80080d:	ff 75 0c             	pushl  0xc(%ebp)
  800810:	ff 75 08             	pushl  0x8(%ebp)
  800813:	e8 9a ff ff ff       	call   8007b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	eb 03                	jmp    80082a <strlen+0x10>
		n++;
  800827:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80082a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082e:	75 f7                	jne    800827 <strlen+0xd>
		n++;
	return n;
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	ba 00 00 00 00       	mov    $0x0,%edx
  800840:	eb 03                	jmp    800845 <strnlen+0x13>
		n++;
  800842:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	39 c2                	cmp    %eax,%edx
  800847:	74 08                	je     800851 <strnlen+0x1f>
  800849:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80084d:	75 f3                	jne    800842 <strnlen+0x10>
  80084f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	83 c2 01             	add    $0x1,%edx
  800862:	83 c1 01             	add    $0x1,%ecx
  800865:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800869:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086c:	84 db                	test   %bl,%bl
  80086e:	75 ef                	jne    80085f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087a:	53                   	push   %ebx
  80087b:	e8 9a ff ff ff       	call   80081a <strlen>
  800880:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800883:	ff 75 0c             	pushl  0xc(%ebp)
  800886:	01 d8                	add    %ebx,%eax
  800888:	50                   	push   %eax
  800889:	e8 c5 ff ff ff       	call   800853 <strcpy>
	return dst;
}
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	8b 75 08             	mov    0x8(%ebp),%esi
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a0:	89 f3                	mov    %esi,%ebx
  8008a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	89 f2                	mov    %esi,%edx
  8008a7:	eb 0f                	jmp    8008b8 <strncpy+0x23>
		*dst++ = *src;
  8008a9:	83 c2 01             	add    $0x1,%edx
  8008ac:	0f b6 01             	movzbl (%ecx),%eax
  8008af:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b8:	39 da                	cmp    %ebx,%edx
  8008ba:	75 ed                	jne    8008a9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	74 21                	je     8008f7 <strlcpy+0x35>
  8008d6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008da:	89 f2                	mov    %esi,%edx
  8008dc:	eb 09                	jmp    8008e7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008de:	83 c2 01             	add    $0x1,%edx
  8008e1:	83 c1 01             	add    $0x1,%ecx
  8008e4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	74 09                	je     8008f4 <strlcpy+0x32>
  8008eb:	0f b6 19             	movzbl (%ecx),%ebx
  8008ee:	84 db                	test   %bl,%bl
  8008f0:	75 ec                	jne    8008de <strlcpy+0x1c>
  8008f2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008f4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f7:	29 f0                	sub    %esi,%eax
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800906:	eb 06                	jmp    80090e <strcmp+0x11>
		p++, q++;
  800908:	83 c1 01             	add    $0x1,%ecx
  80090b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	84 c0                	test   %al,%al
  800913:	74 04                	je     800919 <strcmp+0x1c>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	74 ef                	je     800908 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800919:	0f b6 c0             	movzbl %al,%eax
  80091c:	0f b6 12             	movzbl (%edx),%edx
  80091f:	29 d0                	sub    %edx,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	89 c3                	mov    %eax,%ebx
  80092f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800932:	eb 06                	jmp    80093a <strncmp+0x17>
		n--, p++, q++;
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093a:	39 d8                	cmp    %ebx,%eax
  80093c:	74 15                	je     800953 <strncmp+0x30>
  80093e:	0f b6 08             	movzbl (%eax),%ecx
  800941:	84 c9                	test   %cl,%cl
  800943:	74 04                	je     800949 <strncmp+0x26>
  800945:	3a 0a                	cmp    (%edx),%cl
  800947:	74 eb                	je     800934 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800949:	0f b6 00             	movzbl (%eax),%eax
  80094c:	0f b6 12             	movzbl (%edx),%edx
  80094f:	29 d0                	sub    %edx,%eax
  800951:	eb 05                	jmp    800958 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800958:	5b                   	pop    %ebx
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800965:	eb 07                	jmp    80096e <strchr+0x13>
		if (*s == c)
  800967:	38 ca                	cmp    %cl,%dl
  800969:	74 0f                	je     80097a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
  800971:	84 d2                	test   %dl,%dl
  800973:	75 f2                	jne    800967 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800986:	eb 03                	jmp    80098b <strfind+0xf>
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098e:	38 ca                	cmp    %cl,%dl
  800990:	74 04                	je     800996 <strfind+0x1a>
  800992:	84 d2                	test   %dl,%dl
  800994:	75 f2                	jne    800988 <strfind+0xc>
			break;
	return (char *) s;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a4:	85 c9                	test   %ecx,%ecx
  8009a6:	74 36                	je     8009de <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ae:	75 28                	jne    8009d8 <memset+0x40>
  8009b0:	f6 c1 03             	test   $0x3,%cl
  8009b3:	75 23                	jne    8009d8 <memset+0x40>
		c &= 0xFF;
  8009b5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b9:	89 d3                	mov    %edx,%ebx
  8009bb:	c1 e3 08             	shl    $0x8,%ebx
  8009be:	89 d6                	mov    %edx,%esi
  8009c0:	c1 e6 18             	shl    $0x18,%esi
  8009c3:	89 d0                	mov    %edx,%eax
  8009c5:	c1 e0 10             	shl    $0x10,%eax
  8009c8:	09 f0                	or     %esi,%eax
  8009ca:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009cc:	89 d8                	mov    %ebx,%eax
  8009ce:	09 d0                	or     %edx,%eax
  8009d0:	c1 e9 02             	shr    $0x2,%ecx
  8009d3:	fc                   	cld    
  8009d4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d6:	eb 06                	jmp    8009de <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009db:	fc                   	cld    
  8009dc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009de:	89 f8                	mov    %edi,%eax
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	57                   	push   %edi
  8009e9:	56                   	push   %esi
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f3:	39 c6                	cmp    %eax,%esi
  8009f5:	73 35                	jae    800a2c <memmove+0x47>
  8009f7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fa:	39 d0                	cmp    %edx,%eax
  8009fc:	73 2e                	jae    800a2c <memmove+0x47>
		s += n;
		d += n;
  8009fe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a01:	89 d6                	mov    %edx,%esi
  800a03:	09 fe                	or     %edi,%esi
  800a05:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0b:	75 13                	jne    800a20 <memmove+0x3b>
  800a0d:	f6 c1 03             	test   $0x3,%cl
  800a10:	75 0e                	jne    800a20 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a12:	83 ef 04             	sub    $0x4,%edi
  800a15:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a18:	c1 e9 02             	shr    $0x2,%ecx
  800a1b:	fd                   	std    
  800a1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1e:	eb 09                	jmp    800a29 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a20:	83 ef 01             	sub    $0x1,%edi
  800a23:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a26:	fd                   	std    
  800a27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a29:	fc                   	cld    
  800a2a:	eb 1d                	jmp    800a49 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2c:	89 f2                	mov    %esi,%edx
  800a2e:	09 c2                	or     %eax,%edx
  800a30:	f6 c2 03             	test   $0x3,%dl
  800a33:	75 0f                	jne    800a44 <memmove+0x5f>
  800a35:	f6 c1 03             	test   $0x3,%cl
  800a38:	75 0a                	jne    800a44 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a3a:	c1 e9 02             	shr    $0x2,%ecx
  800a3d:	89 c7                	mov    %eax,%edi
  800a3f:	fc                   	cld    
  800a40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a42:	eb 05                	jmp    800a49 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a44:	89 c7                	mov    %eax,%edi
  800a46:	fc                   	cld    
  800a47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a50:	ff 75 10             	pushl  0x10(%ebp)
  800a53:	ff 75 0c             	pushl  0xc(%ebp)
  800a56:	ff 75 08             	pushl  0x8(%ebp)
  800a59:	e8 87 ff ff ff       	call   8009e5 <memmove>
}
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6b:	89 c6                	mov    %eax,%esi
  800a6d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a70:	eb 1a                	jmp    800a8c <memcmp+0x2c>
		if (*s1 != *s2)
  800a72:	0f b6 08             	movzbl (%eax),%ecx
  800a75:	0f b6 1a             	movzbl (%edx),%ebx
  800a78:	38 d9                	cmp    %bl,%cl
  800a7a:	74 0a                	je     800a86 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a7c:	0f b6 c1             	movzbl %cl,%eax
  800a7f:	0f b6 db             	movzbl %bl,%ebx
  800a82:	29 d8                	sub    %ebx,%eax
  800a84:	eb 0f                	jmp    800a95 <memcmp+0x35>
		s1++, s2++;
  800a86:	83 c0 01             	add    $0x1,%eax
  800a89:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8c:	39 f0                	cmp    %esi,%eax
  800a8e:	75 e2                	jne    800a72 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	53                   	push   %ebx
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa0:	89 c1                	mov    %eax,%ecx
  800aa2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa9:	eb 0a                	jmp    800ab5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aab:	0f b6 10             	movzbl (%eax),%edx
  800aae:	39 da                	cmp    %ebx,%edx
  800ab0:	74 07                	je     800ab9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab2:	83 c0 01             	add    $0x1,%eax
  800ab5:	39 c8                	cmp    %ecx,%eax
  800ab7:	72 f2                	jb     800aab <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac8:	eb 03                	jmp    800acd <strtol+0x11>
		s++;
  800aca:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acd:	0f b6 01             	movzbl (%ecx),%eax
  800ad0:	3c 20                	cmp    $0x20,%al
  800ad2:	74 f6                	je     800aca <strtol+0xe>
  800ad4:	3c 09                	cmp    $0x9,%al
  800ad6:	74 f2                	je     800aca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad8:	3c 2b                	cmp    $0x2b,%al
  800ada:	75 0a                	jne    800ae6 <strtol+0x2a>
		s++;
  800adc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800adf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae4:	eb 11                	jmp    800af7 <strtol+0x3b>
  800ae6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aeb:	3c 2d                	cmp    $0x2d,%al
  800aed:	75 08                	jne    800af7 <strtol+0x3b>
		s++, neg = 1;
  800aef:	83 c1 01             	add    $0x1,%ecx
  800af2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afd:	75 15                	jne    800b14 <strtol+0x58>
  800aff:	80 39 30             	cmpb   $0x30,(%ecx)
  800b02:	75 10                	jne    800b14 <strtol+0x58>
  800b04:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b08:	75 7c                	jne    800b86 <strtol+0xca>
		s += 2, base = 16;
  800b0a:	83 c1 02             	add    $0x2,%ecx
  800b0d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b12:	eb 16                	jmp    800b2a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b14:	85 db                	test   %ebx,%ebx
  800b16:	75 12                	jne    800b2a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b18:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b20:	75 08                	jne    800b2a <strtol+0x6e>
		s++, base = 8;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b32:	0f b6 11             	movzbl (%ecx),%edx
  800b35:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b38:	89 f3                	mov    %esi,%ebx
  800b3a:	80 fb 09             	cmp    $0x9,%bl
  800b3d:	77 08                	ja     800b47 <strtol+0x8b>
			dig = *s - '0';
  800b3f:	0f be d2             	movsbl %dl,%edx
  800b42:	83 ea 30             	sub    $0x30,%edx
  800b45:	eb 22                	jmp    800b69 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b47:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b4a:	89 f3                	mov    %esi,%ebx
  800b4c:	80 fb 19             	cmp    $0x19,%bl
  800b4f:	77 08                	ja     800b59 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b51:	0f be d2             	movsbl %dl,%edx
  800b54:	83 ea 57             	sub    $0x57,%edx
  800b57:	eb 10                	jmp    800b69 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b59:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5c:	89 f3                	mov    %esi,%ebx
  800b5e:	80 fb 19             	cmp    $0x19,%bl
  800b61:	77 16                	ja     800b79 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b63:	0f be d2             	movsbl %dl,%edx
  800b66:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b69:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6c:	7d 0b                	jge    800b79 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b6e:	83 c1 01             	add    $0x1,%ecx
  800b71:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b75:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b77:	eb b9                	jmp    800b32 <strtol+0x76>

	if (endptr)
  800b79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7d:	74 0d                	je     800b8c <strtol+0xd0>
		*endptr = (char *) s;
  800b7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b82:	89 0e                	mov    %ecx,(%esi)
  800b84:	eb 06                	jmp    800b8c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b86:	85 db                	test   %ebx,%ebx
  800b88:	74 98                	je     800b22 <strtol+0x66>
  800b8a:	eb 9e                	jmp    800b2a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b8c:	89 c2                	mov    %eax,%edx
  800b8e:	f7 da                	neg    %edx
  800b90:	85 ff                	test   %edi,%edi
  800b92:	0f 45 c2             	cmovne %edx,%eax
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 c3                	mov    %eax,%ebx
  800bad:	89 c7                	mov    %eax,%edi
  800baf:	89 c6                	mov    %eax,%esi
  800bb1:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	89 d6                	mov    %edx,%esi
  800bd0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800be0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	89 cb                	mov    %ecx,%ebx
  800bef:	89 cf                	mov    %ecx,%edi
  800bf1:	89 ce                	mov    %ecx,%esi
  800bf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	7e 17                	jle    800c10 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 03                	push   $0x3
  800bff:	68 84 14 80 00       	push   $0x801484
  800c04:	6a 23                	push   $0x23
  800c06:	68 a1 14 80 00       	push   $0x8014a1
  800c0b:	e8 8a 02 00 00       	call   800e9a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c23:	b8 02 00 00 00       	mov    $0x2,%eax
  800c28:	89 d1                	mov    %edx,%ecx
  800c2a:	89 d3                	mov    %edx,%ebx
  800c2c:	89 d7                	mov    %edx,%edi
  800c2e:	89 d6                	mov    %edx,%esi
  800c30:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_yield>:

void
sys_yield(void)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c47:	89 d1                	mov    %edx,%ecx
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	89 d7                	mov    %edx,%edi
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c5f:	be 00 00 00 00       	mov    $0x0,%esi
  800c64:	b8 04 00 00 00       	mov    $0x4,%eax
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c72:	89 f7                	mov    %esi,%edi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 04                	push   $0x4
  800c80:	68 84 14 80 00       	push   $0x801484
  800c85:	6a 23                	push   $0x23
  800c87:	68 a1 14 80 00       	push   $0x8014a1
  800c8c:	e8 09 02 00 00       	call   800e9a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800ca2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 05                	push   $0x5
  800cc2:	68 84 14 80 00       	push   $0x801484
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 a1 14 80 00       	push   $0x8014a1
  800cce:	e8 c7 01 00 00       	call   800e9a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800ce9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 06                	push   $0x6
  800d04:	68 84 14 80 00       	push   $0x801484
  800d09:	6a 23                	push   $0x23
  800d0b:	68 a1 14 80 00       	push   $0x8014a1
  800d10:	e8 85 01 00 00       	call   800e9a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d2b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 08                	push   $0x8
  800d46:	68 84 14 80 00       	push   $0x801484
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 a1 14 80 00       	push   $0x8014a1
  800d52:	e8 43 01 00 00       	call   800e9a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 09                	push   $0x9
  800d88:	68 84 14 80 00       	push   $0x801484
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 a1 14 80 00       	push   $0x8014a1
  800d94:	e8 01 01 00 00       	call   800e9a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 0c                	push   $0xc
  800dec:	68 84 14 80 00       	push   $0x801484
  800df1:	6a 23                	push   $0x23
  800df3:	68 a1 14 80 00       	push   $0x8014a1
  800df8:	e8 9d 00 00 00       	call   800e9a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800e0b:	68 bb 14 80 00       	push   $0x8014bb
  800e10:	6a 51                	push   $0x51
  800e12:	68 af 14 80 00       	push   $0x8014af
  800e17:	e8 7e 00 00 00       	call   800e9a <_panic>

00800e1c <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e22:	68 ba 14 80 00       	push   $0x8014ba
  800e27:	6a 58                	push   $0x58
  800e29:	68 af 14 80 00       	push   $0x8014af
  800e2e:	e8 67 00 00 00       	call   800e9a <_panic>

00800e33 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800e39:	68 d0 14 80 00       	push   $0x8014d0
  800e3e:	6a 1a                	push   $0x1a
  800e40:	68 e9 14 80 00       	push   $0x8014e9
  800e45:	e8 50 00 00 00       	call   800e9a <_panic>

00800e4a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800e50:	68 f3 14 80 00       	push   $0x8014f3
  800e55:	6a 2a                	push   $0x2a
  800e57:	68 e9 14 80 00       	push   $0x8014e9
  800e5c:	e8 39 00 00 00       	call   800e9a <_panic>

00800e61 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e6c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e6f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e75:	8b 52 50             	mov    0x50(%edx),%edx
  800e78:	39 ca                	cmp    %ecx,%edx
  800e7a:	75 0d                	jne    800e89 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e7c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e7f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e84:	8b 40 48             	mov    0x48(%eax),%eax
  800e87:	eb 0f                	jmp    800e98 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e89:	83 c0 01             	add    $0x1,%eax
  800e8c:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e91:	75 d9                	jne    800e6c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e9f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ea2:	8b 35 08 20 80 00    	mov    0x802008,%esi
  800ea8:	e8 6b fd ff ff       	call   800c18 <sys_getenvid>
  800ead:	83 ec 0c             	sub    $0xc,%esp
  800eb0:	ff 75 0c             	pushl  0xc(%ebp)
  800eb3:	ff 75 08             	pushl  0x8(%ebp)
  800eb6:	56                   	push   %esi
  800eb7:	50                   	push   %eax
  800eb8:	68 0c 15 80 00       	push   $0x80150c
  800ebd:	e8 c2 f3 ff ff       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ec2:	83 c4 18             	add    $0x18,%esp
  800ec5:	53                   	push   %ebx
  800ec6:	ff 75 10             	pushl  0x10(%ebp)
  800ec9:	e8 65 f3 ff ff       	call   800233 <vcprintf>
	cprintf("\n");
  800ece:	c7 04 24 92 11 80 00 	movl   $0x801192,(%esp)
  800ed5:	e8 aa f3 ff ff       	call   800284 <cprintf>
  800eda:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800edd:	cc                   	int3   
  800ede:	eb fd                	jmp    800edd <_panic+0x43>

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
