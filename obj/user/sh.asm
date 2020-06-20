
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 47 09 00 00       	call   800978 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 20 33 80 00       	push   $0x803320
  800060:	e8 4c 0a 00 00       	call   800ab1 <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 2f 33 80 00       	push   $0x80332f
  800084:	e8 28 0a 00 00       	call   800ab1 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 3d 33 80 00       	push   $0x80333d
  8000b0:	e8 c6 11 00 00       	call   80127b <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 42 33 80 00       	push   $0x803342
  8000dd:	e8 cf 09 00 00       	call   800ab1 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 53 33 80 00       	push   $0x803353
  8000fb:	e8 7b 11 00 00       	call   80127b <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 47 33 80 00       	push   $0x803347
  80012b:	e8 81 09 00 00       	call   800ab1 <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 4f 33 80 00       	push   $0x80334f
  800151:	e8 25 11 00 00       	call   80127b <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 5b 33 80 00       	push   $0x80335b
  800180:	e8 2c 09 00 00       	call   800ab1 <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 8f 00 00 00    	je     8002d0 <runcmd+0xc7>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 fe 01 00 00    	je     80044c <runcmd+0x243>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 e2 01 00 00       	jmp    80043a <runcmd+0x231>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 e8 00 00 00    	je     80034e <runcmd+0x145>
  800266:	e9 cf 01 00 00       	jmp    80043a <runcmd+0x231>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 65 33 80 00       	push   $0x803365
  800278:	e8 34 08 00 00       	call   800ab1 <cprintf>
				exit();
  80027d:	e8 3c 07 00 00       	call   8009be <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  800297:	50                   	push   %eax
  800298:	6a 00                	push   $0x0
  80029a:	e8 ff fe ff ff       	call   80019e <gettoken>
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	83 f8 77             	cmp    $0x77,%eax
  8002a5:	74 15                	je     8002bc <runcmd+0xb3>
				cprintf("syntax error: < not followed by word\n");
  8002a7:	83 ec 0c             	sub    $0xc,%esp
  8002aa:	68 c0 34 80 00       	push   $0x8034c0
  8002af:	e8 fd 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002b4:	e8 05 07 00 00       	call   8009be <exit>
  8002b9:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			panic("< redirection not implemented");
  8002bc:	83 ec 04             	sub    $0x4,%esp
  8002bf:	68 79 33 80 00       	push   $0x803379
  8002c4:	6a 3a                	push   $0x3a
  8002c6:	68 97 33 80 00       	push   $0x803397
  8002cb:	e8 08 07 00 00       	call   8009d8 <_panic>
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	53                   	push   %ebx
  8002d4:	6a 00                	push   $0x0
  8002d6:	e8 c3 fe ff ff       	call   80019e <gettoken>
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	83 f8 77             	cmp    $0x77,%eax
  8002e1:	74 15                	je     8002f8 <runcmd+0xef>
				cprintf("syntax error: > not followed by word\n");
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	68 e8 34 80 00       	push   $0x8034e8
  8002eb:	e8 c1 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002f0:	e8 c9 06 00 00       	call   8009be <exit>
  8002f5:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  8002f8:	83 ec 08             	sub    $0x8,%esp
  8002fb:	68 01 03 00 00       	push   $0x301
  800300:	ff 75 a4             	pushl  -0x5c(%ebp)
  800303:	e8 c0 20 00 00       	call   8023c8 <open>
  800308:	89 c7                	mov    %eax,%edi
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 19                	jns    80032a <runcmd+0x121>
				cprintf("open %s for write: %e", t, fd);
  800311:	83 ec 04             	sub    $0x4,%esp
  800314:	50                   	push   %eax
  800315:	ff 75 a4             	pushl  -0x5c(%ebp)
  800318:	68 a1 33 80 00       	push   $0x8033a1
  80031d:	e8 8f 07 00 00       	call   800ab1 <cprintf>
				exit();
  800322:	e8 97 06 00 00       	call   8009be <exit>
  800327:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  80032a:	83 ff 01             	cmp    $0x1,%edi
  80032d:	0f 84 f7 fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800333:	83 ec 08             	sub    $0x8,%esp
  800336:	6a 01                	push   $0x1
  800338:	57                   	push   %edi
  800339:	e8 1a 1b 00 00       	call   801e58 <dup>
				close(fd);
  80033e:	89 3c 24             	mov    %edi,(%esp)
  800341:	e8 c2 1a 00 00       	call   801e08 <close>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 dc fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800357:	50                   	push   %eax
  800358:	e8 a9 29 00 00       	call   802d06 <pipe>
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	85 c0                	test   %eax,%eax
  800362:	79 16                	jns    80037a <runcmd+0x171>
				cprintf("pipe: %e", r);
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	50                   	push   %eax
  800368:	68 b7 33 80 00       	push   $0x8033b7
  80036d:	e8 3f 07 00 00       	call   800ab1 <cprintf>
				exit();
  800372:	e8 47 06 00 00       	call   8009be <exit>
  800377:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  80037a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800381:	74 1c                	je     80039f <runcmd+0x196>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800383:	83 ec 04             	sub    $0x4,%esp
  800386:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80038c:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800392:	68 c0 33 80 00       	push   $0x8033c0
  800397:	e8 15 07 00 00       	call   800ab1 <cprintf>
  80039c:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  80039f:	e8 7b 15 00 00       	call   80191f <fork>
  8003a4:	89 c7                	mov    %eax,%edi
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	79 16                	jns    8003c0 <runcmd+0x1b7>
				cprintf("fork: %e", r);
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	50                   	push   %eax
  8003ae:	68 cd 33 80 00       	push   $0x8033cd
  8003b3:	e8 f9 06 00 00       	call   800ab1 <cprintf>
				exit();
  8003b8:	e8 01 06 00 00       	call   8009be <exit>
  8003bd:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003c0:	85 ff                	test   %edi,%edi
  8003c2:	75 3c                	jne    800400 <runcmd+0x1f7>
				if (p[0] != 0) {
  8003c4:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	74 1c                	je     8003ea <runcmd+0x1e1>
					dup(p[0], 0);
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	6a 00                	push   $0x0
  8003d3:	50                   	push   %eax
  8003d4:	e8 7f 1a 00 00       	call   801e58 <dup>
					close(p[0]);
  8003d9:	83 c4 04             	add    $0x4,%esp
  8003dc:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003e2:	e8 21 1a 00 00       	call   801e08 <close>
  8003e7:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  8003ea:	83 ec 0c             	sub    $0xc,%esp
  8003ed:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003f3:	e8 10 1a 00 00       	call   801e08 <close>
				goto again;
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	e9 25 fe ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800400:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800406:	83 f8 01             	cmp    $0x1,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[1], 1);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 01                	push   $0x1
  800410:	50                   	push   %eax
  800411:	e8 42 1a 00 00       	call   801e58 <dup>
					close(p[1]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80041f:	e8 e4 19 00 00       	call   801e08 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800430:	e8 d3 19 00 00       	call   801e08 <close>
				goto runit;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	eb 17                	jmp    800451 <runcmd+0x248>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  80043a:	50                   	push   %eax
  80043b:	68 d6 33 80 00       	push   $0x8033d6
  800440:	6a 70                	push   $0x70
  800442:	68 97 33 80 00       	push   $0x803397
  800447:	e8 8c 05 00 00       	call   8009d8 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  80044c:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800451:	85 f6                	test   %esi,%esi
  800453:	75 22                	jne    800477 <runcmd+0x26e>
		if (debug)
  800455:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80045c:	0f 84 96 01 00 00    	je     8005f8 <runcmd+0x3ef>
			cprintf("EMPTY COMMAND\n");
  800462:	83 ec 0c             	sub    $0xc,%esp
  800465:	68 f2 33 80 00       	push   $0x8033f2
  80046a:	e8 42 06 00 00       	call   800ab1 <cprintf>
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	e9 81 01 00 00       	jmp    8005f8 <runcmd+0x3ef>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  800477:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80047a:	80 38 2f             	cmpb   $0x2f,(%eax)
  80047d:	74 23                	je     8004a2 <runcmd+0x299>
		argv0buf[0] = '/';
  80047f:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	50                   	push   %eax
  80048a:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  800490:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	e8 d7 0c 00 00       	call   801173 <strcpy>
		argv[0] = argv0buf;
  80049c:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004a2:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004a9:	00 

	// Print the command.
	if (debug) {
  8004aa:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004b1:	74 49                	je     8004fc <runcmd+0x2f3>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004b3:	a1 24 54 80 00       	mov    0x805424,%eax
  8004b8:	8b 40 48             	mov    0x48(%eax),%eax
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	50                   	push   %eax
  8004bf:	68 01 34 80 00       	push   $0x803401
  8004c4:	e8 e8 05 00 00       	call   800ab1 <cprintf>
  8004c9:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	eb 11                	jmp    8004e2 <runcmd+0x2d9>
			cprintf(" %s", argv[i]);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	50                   	push   %eax
  8004d5:	68 89 34 80 00       	push   $0x803489
  8004da:	e8 d2 05 00 00       	call   800ab1 <cprintf>
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  8004e5:	8b 43 fc             	mov    -0x4(%ebx),%eax
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	75 e5                	jne    8004d1 <runcmd+0x2c8>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  8004ec:	83 ec 0c             	sub    $0xc,%esp
  8004ef:	68 40 33 80 00       	push   $0x803340
  8004f4:	e8 b8 05 00 00       	call   800ab1 <cprintf>
  8004f9:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800502:	50                   	push   %eax
  800503:	ff 75 a8             	pushl  -0x58(%ebp)
  800506:	e8 71 20 00 00       	call   80257c <spawn>
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	0f 89 c3 00 00 00    	jns    8005db <runcmd+0x3d2>
		cprintf("spawn %s: %e\n", argv[0], r);
  800518:	83 ec 04             	sub    $0x4,%esp
  80051b:	50                   	push   %eax
  80051c:	ff 75 a8             	pushl  -0x58(%ebp)
  80051f:	68 0f 34 80 00       	push   $0x80340f
  800524:	e8 88 05 00 00       	call   800ab1 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800529:	e8 05 19 00 00       	call   801e33 <close_all>
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 4c                	jmp    80057f <runcmd+0x376>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800533:	a1 24 54 80 00       	mov    0x805424,%eax
  800538:	8b 40 48             	mov    0x48(%eax),%eax
  80053b:	53                   	push   %ebx
  80053c:	ff 75 a8             	pushl  -0x58(%ebp)
  80053f:	50                   	push   %eax
  800540:	68 1d 34 80 00       	push   $0x80341d
  800545:	e8 67 05 00 00       	call   800ab1 <cprintf>
  80054a:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	53                   	push   %ebx
  800551:	e8 36 29 00 00       	call   802e8c <wait>
		if (debug)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800560:	0f 84 8c 00 00 00    	je     8005f2 <runcmd+0x3e9>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800566:	a1 24 54 80 00       	mov    0x805424,%eax
  80056b:	8b 40 48             	mov    0x48(%eax),%eax
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	50                   	push   %eax
  800572:	68 32 34 80 00       	push   $0x803432
  800577:	e8 35 05 00 00       	call   800ab1 <cprintf>
  80057c:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80057f:	85 ff                	test   %edi,%edi
  800581:	74 51                	je     8005d4 <runcmd+0x3cb>
		if (debug)
  800583:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80058a:	74 1a                	je     8005a6 <runcmd+0x39d>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  80058c:	a1 24 54 80 00       	mov    0x805424,%eax
  800591:	8b 40 48             	mov    0x48(%eax),%eax
  800594:	83 ec 04             	sub    $0x4,%esp
  800597:	57                   	push   %edi
  800598:	50                   	push   %eax
  800599:	68 48 34 80 00       	push   $0x803448
  80059e:	e8 0e 05 00 00       	call   800ab1 <cprintf>
  8005a3:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	57                   	push   %edi
  8005aa:	e8 dd 28 00 00       	call   802e8c <wait>
		if (debug)
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005b9:	74 19                	je     8005d4 <runcmd+0x3cb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005bb:	a1 24 54 80 00       	mov    0x805424,%eax
  8005c0:	8b 40 48             	mov    0x48(%eax),%eax
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	50                   	push   %eax
  8005c7:	68 32 34 80 00       	push   $0x803432
  8005cc:	e8 e0 04 00 00       	call   800ab1 <cprintf>
  8005d1:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  8005d4:	e8 e5 03 00 00       	call   8009be <exit>
  8005d9:	eb 1d                	jmp    8005f8 <runcmd+0x3ef>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  8005db:	e8 53 18 00 00       	call   801e33 <close_all>
	if (r >= 0) {
		if (debug)
  8005e0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005e7:	0f 84 60 ff ff ff    	je     80054d <runcmd+0x344>
  8005ed:	e9 41 ff ff ff       	jmp    800533 <runcmd+0x32a>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	75 b0                	jne    8005a6 <runcmd+0x39d>
  8005f6:	eb dc                	jmp    8005d4 <runcmd+0x3cb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  8005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fb:	5b                   	pop    %ebx
  8005fc:	5e                   	pop    %esi
  8005fd:	5f                   	pop    %edi
  8005fe:	5d                   	pop    %ebp
  8005ff:	c3                   	ret    

00800600 <usage>:
}


void
usage(void)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800606:	68 10 35 80 00       	push   $0x803510
  80060b:	e8 a1 04 00 00       	call   800ab1 <cprintf>
	exit();
  800610:	e8 a9 03 00 00       	call   8009be <exit>
}
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	c9                   	leave  
  800619:	c3                   	ret    

0080061a <umain>:

void
umain(int argc, char **argv)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	57                   	push   %edi
  80061e:	56                   	push   %esi
  80061f:	53                   	push   %ebx
  800620:	83 ec 30             	sub    $0x30,%esp
  800623:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800626:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800629:	50                   	push   %eax
  80062a:	57                   	push   %edi
  80062b:	8d 45 08             	lea    0x8(%ebp),%eax
  80062e:	50                   	push   %eax
  80062f:	e8 e0 14 00 00       	call   801b14 <argstart>
	while ((r = argnext(&args)) >= 0)
  800634:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800637:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80063e:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800643:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800646:	eb 2f                	jmp    800677 <umain+0x5d>
		switch (r) {
  800648:	83 f8 69             	cmp    $0x69,%eax
  80064b:	74 25                	je     800672 <umain+0x58>
  80064d:	83 f8 78             	cmp    $0x78,%eax
  800650:	74 07                	je     800659 <umain+0x3f>
  800652:	83 f8 64             	cmp    $0x64,%eax
  800655:	75 14                	jne    80066b <umain+0x51>
  800657:	eb 09                	jmp    800662 <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800659:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  800660:	eb 15                	jmp    800677 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  800662:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  800669:	eb 0c                	jmp    800677 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  80066b:	e8 90 ff ff ff       	call   800600 <usage>
  800670:	eb 05                	jmp    800677 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800672:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800677:	83 ec 0c             	sub    $0xc,%esp
  80067a:	53                   	push   %ebx
  80067b:	e8 c4 14 00 00       	call   801b44 <argnext>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	79 c1                	jns    800648 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  800687:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80068b:	7e 05                	jle    800692 <umain+0x78>
		usage();
  80068d:	e8 6e ff ff ff       	call   800600 <usage>
	if (argc == 2) {
  800692:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800696:	75 56                	jne    8006ee <umain+0xd4>
		close(0);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	6a 00                	push   $0x0
  80069d:	e8 66 17 00 00       	call   801e08 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006a2:	83 c4 08             	add    $0x8,%esp
  8006a5:	6a 00                	push   $0x0
  8006a7:	ff 77 04             	pushl  0x4(%edi)
  8006aa:	e8 19 1d 00 00       	call   8023c8 <open>
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	79 1b                	jns    8006d1 <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	50                   	push   %eax
  8006ba:	ff 77 04             	pushl  0x4(%edi)
  8006bd:	68 65 34 80 00       	push   $0x803465
  8006c2:	68 20 01 00 00       	push   $0x120
  8006c7:	68 97 33 80 00       	push   $0x803397
  8006cc:	e8 07 03 00 00       	call   8009d8 <_panic>
		assert(r == 0);
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	74 19                	je     8006ee <umain+0xd4>
  8006d5:	68 71 34 80 00       	push   $0x803471
  8006da:	68 78 34 80 00       	push   $0x803478
  8006df:	68 21 01 00 00       	push   $0x121
  8006e4:	68 97 33 80 00       	push   $0x803397
  8006e9:	e8 ea 02 00 00       	call   8009d8 <_panic>
	}
	if (interactive == '?')
  8006ee:	83 fe 3f             	cmp    $0x3f,%esi
  8006f1:	75 0f                	jne    800702 <umain+0xe8>
		interactive = iscons(0);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	6a 00                	push   $0x0
  8006f8:	e8 f5 01 00 00       	call   8008f2 <iscons>
  8006fd:	89 c6                	mov    %eax,%esi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	85 f6                	test   %esi,%esi
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
  800709:	bf 8d 34 80 00       	mov    $0x80348d,%edi
  80070e:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	57                   	push   %edi
  800715:	e8 2d 09 00 00       	call   801047 <readline>
  80071a:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	75 1e                	jne    800741 <umain+0x127>
			if (debug)
  800723:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80072a:	74 10                	je     80073c <umain+0x122>
				cprintf("EXITING\n");
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	68 90 34 80 00       	push   $0x803490
  800734:	e8 78 03 00 00       	call   800ab1 <cprintf>
  800739:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80073c:	e8 7d 02 00 00       	call   8009be <exit>
		}
		if (debug)
  800741:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800748:	74 11                	je     80075b <umain+0x141>
			cprintf("LINE: %s\n", buf);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	68 99 34 80 00       	push   $0x803499
  800753:	e8 59 03 00 00       	call   800ab1 <cprintf>
  800758:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  80075b:	80 3b 23             	cmpb   $0x23,(%ebx)
  80075e:	74 b1                	je     800711 <umain+0xf7>
			continue;
		if (echocmds)
  800760:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800764:	74 11                	je     800777 <umain+0x15d>
			printf("# %s\n", buf);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	68 a3 34 80 00       	push   $0x8034a3
  80076f:	e8 f2 1d 00 00       	call   802566 <printf>
  800774:	83 c4 10             	add    $0x10,%esp
		if (debug)
  800777:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80077e:	74 10                	je     800790 <umain+0x176>
			cprintf("BEFORE FORK\n");
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	68 a9 34 80 00       	push   $0x8034a9
  800788:	e8 24 03 00 00       	call   800ab1 <cprintf>
  80078d:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  800790:	e8 8a 11 00 00       	call   80191f <fork>
  800795:	89 c6                	mov    %eax,%esi
  800797:	85 c0                	test   %eax,%eax
  800799:	79 15                	jns    8007b0 <umain+0x196>
			panic("fork: %e", r);
  80079b:	50                   	push   %eax
  80079c:	68 cd 33 80 00       	push   $0x8033cd
  8007a1:	68 38 01 00 00       	push   $0x138
  8007a6:	68 97 33 80 00       	push   $0x803397
  8007ab:	e8 28 02 00 00       	call   8009d8 <_panic>
		if (debug)
  8007b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b7:	74 11                	je     8007ca <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	50                   	push   %eax
  8007bd:	68 b6 34 80 00       	push   $0x8034b6
  8007c2:	e8 ea 02 00 00       	call   800ab1 <cprintf>
  8007c7:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  8007ca:	85 f6                	test   %esi,%esi
  8007cc:	75 16                	jne    8007e4 <umain+0x1ca>
			runcmd(buf);
  8007ce:	83 ec 0c             	sub    $0xc,%esp
  8007d1:	53                   	push   %ebx
  8007d2:	e8 32 fa ff ff       	call   800209 <runcmd>
			exit();
  8007d7:	e8 e2 01 00 00       	call   8009be <exit>
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	e9 2d ff ff ff       	jmp    800711 <umain+0xf7>
		} else
			wait(r);
  8007e4:	83 ec 0c             	sub    $0xc,%esp
  8007e7:	56                   	push   %esi
  8007e8:	e8 9f 26 00 00       	call   802e8c <wait>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	e9 1c ff ff ff       	jmp    800711 <umain+0xf7>

008007f5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800805:	68 31 35 80 00       	push   $0x803531
  80080a:	ff 75 0c             	pushl  0xc(%ebp)
  80080d:	e8 61 09 00 00       	call   801173 <strcpy>
	return 0;
}
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800825:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80082a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800830:	eb 2d                	jmp    80085f <devcons_write+0x46>
		m = n - tot;
  800832:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800835:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800837:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80083a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80083f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	53                   	push   %ebx
  800846:	03 45 0c             	add    0xc(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	57                   	push   %edi
  80084b:	e8 b5 0a 00 00       	call   801305 <memmove>
		sys_cputs(buf, m);
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	57                   	push   %edi
  800855:	e8 60 0c 00 00       	call   8014ba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80085a:	01 de                	add    %ebx,%esi
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	89 f0                	mov    %esi,%eax
  800861:	3b 75 10             	cmp    0x10(%ebp),%esi
  800864:	72 cc                	jb     800832 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800866:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800869:	5b                   	pop    %ebx
  80086a:	5e                   	pop    %esi
  80086b:	5f                   	pop    %edi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800879:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80087d:	74 2a                	je     8008a9 <devcons_read+0x3b>
  80087f:	eb 05                	jmp    800886 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800881:	e8 d1 0c 00 00       	call   801557 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800886:	e8 4d 0c 00 00       	call   8014d8 <sys_cgetc>
  80088b:	85 c0                	test   %eax,%eax
  80088d:	74 f2                	je     800881 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80088f:	85 c0                	test   %eax,%eax
  800891:	78 16                	js     8008a9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800893:	83 f8 04             	cmp    $0x4,%eax
  800896:	74 0c                	je     8008a4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	88 02                	mov    %al,(%edx)
	return 1;
  80089d:	b8 01 00 00 00       	mov    $0x1,%eax
  8008a2:	eb 05                	jmp    8008a9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008b7:	6a 01                	push   $0x1
  8008b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008bc:	50                   	push   %eax
  8008bd:	e8 f8 0b 00 00       	call   8014ba <sys_cputs>
}
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <getchar>:

int
getchar(void)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8008cd:	6a 01                	push   $0x1
  8008cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008d2:	50                   	push   %eax
  8008d3:	6a 00                	push   $0x0
  8008d5:	e8 6a 16 00 00       	call   801f44 <read>
	if (r < 0)
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 0f                	js     8008f0 <getchar+0x29>
		return r;
	if (r < 1)
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	7e 06                	jle    8008eb <getchar+0x24>
		return -E_EOF;
	return c;
  8008e5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8008e9:	eb 05                	jmp    8008f0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8008eb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008fb:	50                   	push   %eax
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 da 13 00 00       	call   801cde <fd_lookup>
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	85 c0                	test   %eax,%eax
  800909:	78 11                	js     80091c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80090b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800914:	39 10                	cmp    %edx,(%eax)
  800916:	0f 94 c0             	sete   %al
  800919:	0f b6 c0             	movzbl %al,%eax
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <opencons>:

int
opencons(void)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800927:	50                   	push   %eax
  800928:	e8 62 13 00 00       	call   801c8f <fd_alloc>
  80092d:	83 c4 10             	add    $0x10,%esp
		return r;
  800930:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800932:	85 c0                	test   %eax,%eax
  800934:	78 3e                	js     800974 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800936:	83 ec 04             	sub    $0x4,%esp
  800939:	68 07 04 00 00       	push   $0x407
  80093e:	ff 75 f4             	pushl  -0xc(%ebp)
  800941:	6a 00                	push   $0x0
  800943:	e8 2e 0c 00 00       	call   801576 <sys_page_alloc>
  800948:	83 c4 10             	add    $0x10,%esp
		return r;
  80094b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80094d:	85 c0                	test   %eax,%eax
  80094f:	78 23                	js     800974 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800951:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800966:	83 ec 0c             	sub    $0xc,%esp
  800969:	50                   	push   %eax
  80096a:	e8 f9 12 00 00       	call   801c68 <fd2num>
  80096f:	89 c2                	mov    %eax,%edx
  800971:	83 c4 10             	add    $0x10,%esp
}
  800974:	89 d0                	mov    %edx,%eax
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800980:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800983:	e8 b0 0b 00 00       	call   801538 <sys_getenvid>
  800988:	25 ff 03 00 00       	and    $0x3ff,%eax
  80098d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800990:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800995:	a3 24 54 80 00       	mov    %eax,0x805424
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80099a:	85 db                	test   %ebx,%ebx
  80099c:	7e 07                	jle    8009a5 <libmain+0x2d>
		binaryname = argv[0];
  80099e:	8b 06                	mov    (%esi),%eax
  8009a0:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	e8 6b fc ff ff       	call   80061a <umain>

	// exit gracefully
	exit();
  8009af:	e8 0a 00 00 00       	call   8009be <exit>
}
  8009b4:	83 c4 10             	add    $0x10,%esp
  8009b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8009c4:	e8 6a 14 00 00       	call   801e33 <close_all>
	sys_env_destroy(0);
  8009c9:	83 ec 0c             	sub    $0xc,%esp
  8009cc:	6a 00                	push   $0x0
  8009ce:	e8 24 0b 00 00       	call   8014f7 <sys_env_destroy>
}
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8009dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8009e0:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8009e6:	e8 4d 0b 00 00       	call   801538 <sys_getenvid>
  8009eb:	83 ec 0c             	sub    $0xc,%esp
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	ff 75 08             	pushl  0x8(%ebp)
  8009f4:	56                   	push   %esi
  8009f5:	50                   	push   %eax
  8009f6:	68 48 35 80 00       	push   $0x803548
  8009fb:	e8 b1 00 00 00       	call   800ab1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a00:	83 c4 18             	add    $0x18,%esp
  800a03:	53                   	push   %ebx
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	e8 54 00 00 00       	call   800a60 <vcprintf>
	cprintf("\n");
  800a0c:	c7 04 24 40 33 80 00 	movl   $0x803340,(%esp)
  800a13:	e8 99 00 00 00       	call   800ab1 <cprintf>
  800a18:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a1b:	cc                   	int3   
  800a1c:	eb fd                	jmp    800a1b <_panic+0x43>

00800a1e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	83 ec 04             	sub    $0x4,%esp
  800a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a28:	8b 13                	mov    (%ebx),%edx
  800a2a:	8d 42 01             	lea    0x1(%edx),%eax
  800a2d:	89 03                	mov    %eax,(%ebx)
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a36:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a3b:	75 1a                	jne    800a57 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	68 ff 00 00 00       	push   $0xff
  800a45:	8d 43 08             	lea    0x8(%ebx),%eax
  800a48:	50                   	push   %eax
  800a49:	e8 6c 0a 00 00       	call   8014ba <sys_cputs>
		b->idx = 0;
  800a4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a54:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a57:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800a69:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800a70:	00 00 00 
	b.cnt = 0;
  800a73:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800a7a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800a7d:	ff 75 0c             	pushl  0xc(%ebp)
  800a80:	ff 75 08             	pushl  0x8(%ebp)
  800a83:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800a89:	50                   	push   %eax
  800a8a:	68 1e 0a 80 00       	push   $0x800a1e
  800a8f:	e8 54 01 00 00       	call   800be8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800a94:	83 c4 08             	add    $0x8,%esp
  800a97:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800a9d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aa3:	50                   	push   %eax
  800aa4:	e8 11 0a 00 00       	call   8014ba <sys_cputs>

	return b.cnt;
}
  800aa9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800ab7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800aba:	50                   	push   %eax
  800abb:	ff 75 08             	pushl  0x8(%ebp)
  800abe:	e8 9d ff ff ff       	call   800a60 <vcprintf>
	va_end(ap);

	return cnt;
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 1c             	sub    $0x1c,%esp
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ae1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800ae9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800aec:	39 d3                	cmp    %edx,%ebx
  800aee:	72 05                	jb     800af5 <printnum+0x30>
  800af0:	39 45 10             	cmp    %eax,0x10(%ebp)
  800af3:	77 45                	ja     800b3a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	ff 75 18             	pushl  0x18(%ebp)
  800afb:	8b 45 14             	mov    0x14(%ebp),%eax
  800afe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b01:	53                   	push   %ebx
  800b02:	ff 75 10             	pushl  0x10(%ebp)
  800b05:	83 ec 08             	sub    $0x8,%esp
  800b08:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b0b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b0e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b11:	ff 75 d8             	pushl  -0x28(%ebp)
  800b14:	e8 67 25 00 00       	call   803080 <__udivdi3>
  800b19:	83 c4 18             	add    $0x18,%esp
  800b1c:	52                   	push   %edx
  800b1d:	50                   	push   %eax
  800b1e:	89 f2                	mov    %esi,%edx
  800b20:	89 f8                	mov    %edi,%eax
  800b22:	e8 9e ff ff ff       	call   800ac5 <printnum>
  800b27:	83 c4 20             	add    $0x20,%esp
  800b2a:	eb 18                	jmp    800b44 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	56                   	push   %esi
  800b30:	ff 75 18             	pushl  0x18(%ebp)
  800b33:	ff d7                	call   *%edi
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	eb 03                	jmp    800b3d <printnum+0x78>
  800b3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b3d:	83 eb 01             	sub    $0x1,%ebx
  800b40:	85 db                	test   %ebx,%ebx
  800b42:	7f e8                	jg     800b2c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	56                   	push   %esi
  800b48:	83 ec 04             	sub    $0x4,%esp
  800b4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4e:	ff 75 e0             	pushl  -0x20(%ebp)
  800b51:	ff 75 dc             	pushl  -0x24(%ebp)
  800b54:	ff 75 d8             	pushl  -0x28(%ebp)
  800b57:	e8 54 26 00 00       	call   8031b0 <__umoddi3>
  800b5c:	83 c4 14             	add    $0x14,%esp
  800b5f:	0f be 80 6b 35 80 00 	movsbl 0x80356b(%eax),%eax
  800b66:	50                   	push   %eax
  800b67:	ff d7                	call   *%edi
}
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b77:	83 fa 01             	cmp    $0x1,%edx
  800b7a:	7e 0e                	jle    800b8a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b7c:	8b 10                	mov    (%eax),%edx
  800b7e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b81:	89 08                	mov    %ecx,(%eax)
  800b83:	8b 02                	mov    (%edx),%eax
  800b85:	8b 52 04             	mov    0x4(%edx),%edx
  800b88:	eb 22                	jmp    800bac <getuint+0x38>
	else if (lflag)
  800b8a:	85 d2                	test   %edx,%edx
  800b8c:	74 10                	je     800b9e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b8e:	8b 10                	mov    (%eax),%edx
  800b90:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b93:	89 08                	mov    %ecx,(%eax)
  800b95:	8b 02                	mov    (%edx),%eax
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	eb 0e                	jmp    800bac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b9e:	8b 10                	mov    (%eax),%edx
  800ba0:	8d 4a 04             	lea    0x4(%edx),%ecx
  800ba3:	89 08                	mov    %ecx,(%eax)
  800ba5:	8b 02                	mov    (%edx),%eax
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bb4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bb8:	8b 10                	mov    (%eax),%edx
  800bba:	3b 50 04             	cmp    0x4(%eax),%edx
  800bbd:	73 0a                	jae    800bc9 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bbf:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bc2:	89 08                	mov    %ecx,(%eax)
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	88 02                	mov    %al,(%edx)
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800bd1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800bd4:	50                   	push   %eax
  800bd5:	ff 75 10             	pushl  0x10(%ebp)
  800bd8:	ff 75 0c             	pushl  0xc(%ebp)
  800bdb:	ff 75 08             	pushl  0x8(%ebp)
  800bde:	e8 05 00 00 00       	call   800be8 <vprintfmt>
	va_end(ap);
}
  800be3:	83 c4 10             	add    $0x10,%esp
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 2c             	sub    $0x2c,%esp
  800bf1:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf7:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bfa:	eb 12                	jmp    800c0e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	0f 84 d3 03 00 00    	je     800fd7 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800c04:	83 ec 08             	sub    $0x8,%esp
  800c07:	53                   	push   %ebx
  800c08:	50                   	push   %eax
  800c09:	ff d6                	call   *%esi
  800c0b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c0e:	83 c7 01             	add    $0x1,%edi
  800c11:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c15:	83 f8 25             	cmp    $0x25,%eax
  800c18:	75 e2                	jne    800bfc <vprintfmt+0x14>
  800c1a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c1e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c25:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800c2c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	eb 07                	jmp    800c41 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c3d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c41:	8d 47 01             	lea    0x1(%edi),%eax
  800c44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c47:	0f b6 07             	movzbl (%edi),%eax
  800c4a:	0f b6 c8             	movzbl %al,%ecx
  800c4d:	83 e8 23             	sub    $0x23,%eax
  800c50:	3c 55                	cmp    $0x55,%al
  800c52:	0f 87 64 03 00 00    	ja     800fbc <vprintfmt+0x3d4>
  800c58:	0f b6 c0             	movzbl %al,%eax
  800c5b:	ff 24 85 a0 36 80 00 	jmp    *0x8036a0(,%eax,4)
  800c62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c65:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800c69:	eb d6                	jmp    800c41 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c76:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800c79:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800c7d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800c80:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800c83:	83 fa 09             	cmp    $0x9,%edx
  800c86:	77 39                	ja     800cc1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c88:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c8b:	eb e9                	jmp    800c76 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c90:	8d 48 04             	lea    0x4(%eax),%ecx
  800c93:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c96:	8b 00                	mov    (%eax),%eax
  800c98:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c9e:	eb 27                	jmp    800cc7 <vprintfmt+0xdf>
  800ca0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caa:	0f 49 c8             	cmovns %eax,%ecx
  800cad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb3:	eb 8c                	jmp    800c41 <vprintfmt+0x59>
  800cb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cb8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cbf:	eb 80                	jmp    800c41 <vprintfmt+0x59>
  800cc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cc4:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800cc7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ccb:	0f 89 70 ff ff ff    	jns    800c41 <vprintfmt+0x59>
				width = precision, precision = -1;
  800cd1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800cd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800cd7:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800cde:	e9 5e ff ff ff       	jmp    800c41 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800ce3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ce9:	e9 53 ff ff ff       	jmp    800c41 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cee:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf1:	8d 50 04             	lea    0x4(%eax),%edx
  800cf4:	89 55 14             	mov    %edx,0x14(%ebp)
  800cf7:	83 ec 08             	sub    $0x8,%esp
  800cfa:	53                   	push   %ebx
  800cfb:	ff 30                	pushl  (%eax)
  800cfd:	ff d6                	call   *%esi
			break;
  800cff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d05:	e9 04 ff ff ff       	jmp    800c0e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0d:	8d 50 04             	lea    0x4(%eax),%edx
  800d10:	89 55 14             	mov    %edx,0x14(%ebp)
  800d13:	8b 00                	mov    (%eax),%eax
  800d15:	99                   	cltd   
  800d16:	31 d0                	xor    %edx,%eax
  800d18:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d1a:	83 f8 0f             	cmp    $0xf,%eax
  800d1d:	7f 0b                	jg     800d2a <vprintfmt+0x142>
  800d1f:	8b 14 85 00 38 80 00 	mov    0x803800(,%eax,4),%edx
  800d26:	85 d2                	test   %edx,%edx
  800d28:	75 18                	jne    800d42 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d2a:	50                   	push   %eax
  800d2b:	68 83 35 80 00       	push   $0x803583
  800d30:	53                   	push   %ebx
  800d31:	56                   	push   %esi
  800d32:	e8 94 fe ff ff       	call   800bcb <printfmt>
  800d37:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d3d:	e9 cc fe ff ff       	jmp    800c0e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d42:	52                   	push   %edx
  800d43:	68 8a 34 80 00       	push   $0x80348a
  800d48:	53                   	push   %ebx
  800d49:	56                   	push   %esi
  800d4a:	e8 7c fe ff ff       	call   800bcb <printfmt>
  800d4f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d55:	e9 b4 fe ff ff       	jmp    800c0e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5d:	8d 50 04             	lea    0x4(%eax),%edx
  800d60:	89 55 14             	mov    %edx,0x14(%ebp)
  800d63:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800d65:	85 ff                	test   %edi,%edi
  800d67:	b8 7c 35 80 00       	mov    $0x80357c,%eax
  800d6c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800d6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d73:	0f 8e 94 00 00 00    	jle    800e0d <vprintfmt+0x225>
  800d79:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800d7d:	0f 84 98 00 00 00    	je     800e1b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d83:	83 ec 08             	sub    $0x8,%esp
  800d86:	ff 75 c8             	pushl  -0x38(%ebp)
  800d89:	57                   	push   %edi
  800d8a:	e8 c3 03 00 00       	call   801152 <strnlen>
  800d8f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800d92:	29 c1                	sub    %eax,%ecx
  800d94:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800d97:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800d9a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800d9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800da1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800da4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800da6:	eb 0f                	jmp    800db7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	53                   	push   %ebx
  800dac:	ff 75 e0             	pushl  -0x20(%ebp)
  800daf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800db1:	83 ef 01             	sub    $0x1,%edi
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	85 ff                	test   %edi,%edi
  800db9:	7f ed                	jg     800da8 <vprintfmt+0x1c0>
  800dbb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dbe:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800dc1:	85 c9                	test   %ecx,%ecx
  800dc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc8:	0f 49 c1             	cmovns %ecx,%eax
  800dcb:	29 c1                	sub    %eax,%ecx
  800dcd:	89 75 08             	mov    %esi,0x8(%ebp)
  800dd0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800dd3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800dd6:	89 cb                	mov    %ecx,%ebx
  800dd8:	eb 4d                	jmp    800e27 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800dda:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800dde:	74 1b                	je     800dfb <vprintfmt+0x213>
  800de0:	0f be c0             	movsbl %al,%eax
  800de3:	83 e8 20             	sub    $0x20,%eax
  800de6:	83 f8 5e             	cmp    $0x5e,%eax
  800de9:	76 10                	jbe    800dfb <vprintfmt+0x213>
					putch('?', putdat);
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	ff 75 0c             	pushl  0xc(%ebp)
  800df1:	6a 3f                	push   $0x3f
  800df3:	ff 55 08             	call   *0x8(%ebp)
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	eb 0d                	jmp    800e08 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800dfb:	83 ec 08             	sub    $0x8,%esp
  800dfe:	ff 75 0c             	pushl  0xc(%ebp)
  800e01:	52                   	push   %edx
  800e02:	ff 55 08             	call   *0x8(%ebp)
  800e05:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e08:	83 eb 01             	sub    $0x1,%ebx
  800e0b:	eb 1a                	jmp    800e27 <vprintfmt+0x23f>
  800e0d:	89 75 08             	mov    %esi,0x8(%ebp)
  800e10:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800e13:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e16:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e19:	eb 0c                	jmp    800e27 <vprintfmt+0x23f>
  800e1b:	89 75 08             	mov    %esi,0x8(%ebp)
  800e1e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800e21:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e24:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e27:	83 c7 01             	add    $0x1,%edi
  800e2a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e2e:	0f be d0             	movsbl %al,%edx
  800e31:	85 d2                	test   %edx,%edx
  800e33:	74 23                	je     800e58 <vprintfmt+0x270>
  800e35:	85 f6                	test   %esi,%esi
  800e37:	78 a1                	js     800dda <vprintfmt+0x1f2>
  800e39:	83 ee 01             	sub    $0x1,%esi
  800e3c:	79 9c                	jns    800dda <vprintfmt+0x1f2>
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	8b 75 08             	mov    0x8(%ebp),%esi
  800e43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e46:	eb 18                	jmp    800e60 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	53                   	push   %ebx
  800e4c:	6a 20                	push   $0x20
  800e4e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e50:	83 ef 01             	sub    $0x1,%edi
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	eb 08                	jmp    800e60 <vprintfmt+0x278>
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e60:	85 ff                	test   %edi,%edi
  800e62:	7f e4                	jg     800e48 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e67:	e9 a2 fd ff ff       	jmp    800c0e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e6c:	83 fa 01             	cmp    $0x1,%edx
  800e6f:	7e 16                	jle    800e87 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800e71:	8b 45 14             	mov    0x14(%ebp),%eax
  800e74:	8d 50 08             	lea    0x8(%eax),%edx
  800e77:	89 55 14             	mov    %edx,0x14(%ebp)
  800e7a:	8b 50 04             	mov    0x4(%eax),%edx
  800e7d:	8b 00                	mov    (%eax),%eax
  800e7f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800e82:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800e85:	eb 32                	jmp    800eb9 <vprintfmt+0x2d1>
	else if (lflag)
  800e87:	85 d2                	test   %edx,%edx
  800e89:	74 18                	je     800ea3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800e8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e8e:	8d 50 04             	lea    0x4(%eax),%edx
  800e91:	89 55 14             	mov    %edx,0x14(%ebp)
  800e94:	8b 00                	mov    (%eax),%eax
  800e96:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800e99:	89 c1                	mov    %eax,%ecx
  800e9b:	c1 f9 1f             	sar    $0x1f,%ecx
  800e9e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800ea1:	eb 16                	jmp    800eb9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ea3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea6:	8d 50 04             	lea    0x4(%eax),%edx
  800ea9:	89 55 14             	mov    %edx,0x14(%ebp)
  800eac:	8b 00                	mov    (%eax),%eax
  800eae:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	c1 f9 1f             	sar    $0x1f,%ecx
  800eb6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800eb9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800ebc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ebf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ec5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800eca:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ece:	0f 89 b0 00 00 00    	jns    800f84 <vprintfmt+0x39c>
				putch('-', putdat);
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	53                   	push   %ebx
  800ed8:	6a 2d                	push   $0x2d
  800eda:	ff d6                	call   *%esi
				num = -(long long) num;
  800edc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800edf:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ee2:	f7 d8                	neg    %eax
  800ee4:	83 d2 00             	adc    $0x0,%edx
  800ee7:	f7 da                	neg    %edx
  800ee9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800eef:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ef2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef7:	e9 88 00 00 00       	jmp    800f84 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800efc:	8d 45 14             	lea    0x14(%ebp),%eax
  800eff:	e8 70 fc ff ff       	call   800b74 <getuint>
  800f04:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f07:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800f0a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f0f:	eb 73                	jmp    800f84 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800f11:	8d 45 14             	lea    0x14(%ebp),%eax
  800f14:	e8 5b fc ff ff       	call   800b74 <getuint>
  800f19:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f1c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	53                   	push   %ebx
  800f23:	6a 58                	push   $0x58
  800f25:	ff d6                	call   *%esi
			putch('X', putdat);
  800f27:	83 c4 08             	add    $0x8,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	6a 58                	push   $0x58
  800f2d:	ff d6                	call   *%esi
			putch('X', putdat);
  800f2f:	83 c4 08             	add    $0x8,%esp
  800f32:	53                   	push   %ebx
  800f33:	6a 58                	push   $0x58
  800f35:	ff d6                	call   *%esi
			goto number;
  800f37:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800f3a:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800f3f:	eb 43                	jmp    800f84 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	53                   	push   %ebx
  800f45:	6a 30                	push   $0x30
  800f47:	ff d6                	call   *%esi
			putch('x', putdat);
  800f49:	83 c4 08             	add    $0x8,%esp
  800f4c:	53                   	push   %ebx
  800f4d:	6a 78                	push   $0x78
  800f4f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f51:	8b 45 14             	mov    0x14(%ebp),%eax
  800f54:	8d 50 04             	lea    0x4(%eax),%edx
  800f57:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f5a:	8b 00                	mov    (%eax),%eax
  800f5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f61:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f64:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f67:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f6a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f6f:	eb 13                	jmp    800f84 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f71:	8d 45 14             	lea    0x14(%ebp),%eax
  800f74:	e8 fb fb ff ff       	call   800b74 <getuint>
  800f79:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f7c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800f7f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800f8b:	52                   	push   %edx
  800f8c:	ff 75 e0             	pushl  -0x20(%ebp)
  800f8f:	50                   	push   %eax
  800f90:	ff 75 dc             	pushl  -0x24(%ebp)
  800f93:	ff 75 d8             	pushl  -0x28(%ebp)
  800f96:	89 da                	mov    %ebx,%edx
  800f98:	89 f0                	mov    %esi,%eax
  800f9a:	e8 26 fb ff ff       	call   800ac5 <printnum>
			break;
  800f9f:	83 c4 20             	add    $0x20,%esp
  800fa2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fa5:	e9 64 fc ff ff       	jmp    800c0e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800faa:	83 ec 08             	sub    $0x8,%esp
  800fad:	53                   	push   %ebx
  800fae:	51                   	push   %ecx
  800faf:	ff d6                	call   *%esi
			break;
  800fb1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fb7:	e9 52 fc ff ff       	jmp    800c0e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	53                   	push   %ebx
  800fc0:	6a 25                	push   $0x25
  800fc2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	eb 03                	jmp    800fcc <vprintfmt+0x3e4>
  800fc9:	83 ef 01             	sub    $0x1,%edi
  800fcc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fd0:	75 f7                	jne    800fc9 <vprintfmt+0x3e1>
  800fd2:	e9 37 fc ff ff       	jmp    800c0e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fda:	5b                   	pop    %ebx
  800fdb:	5e                   	pop    %esi
  800fdc:	5f                   	pop    %edi
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 18             	sub    $0x18,%esp
  800fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800feb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ff2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ff5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	74 26                	je     801026 <vsnprintf+0x47>
  801000:	85 d2                	test   %edx,%edx
  801002:	7e 22                	jle    801026 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801004:	ff 75 14             	pushl  0x14(%ebp)
  801007:	ff 75 10             	pushl  0x10(%ebp)
  80100a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80100d:	50                   	push   %eax
  80100e:	68 ae 0b 80 00       	push   $0x800bae
  801013:	e8 d0 fb ff ff       	call   800be8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801018:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80101b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80101e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	eb 05                	jmp    80102b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801026:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801033:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801036:	50                   	push   %eax
  801037:	ff 75 10             	pushl  0x10(%ebp)
  80103a:	ff 75 0c             	pushl  0xc(%ebp)
  80103d:	ff 75 08             	pushl  0x8(%ebp)
  801040:	e8 9a ff ff ff       	call   800fdf <vsnprintf>
	va_end(ap);

	return rc;
}
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	57                   	push   %edi
  80104b:	56                   	push   %esi
  80104c:	53                   	push   %ebx
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801053:	85 c0                	test   %eax,%eax
  801055:	74 13                	je     80106a <readline+0x23>
		fprintf(1, "%s", prompt);
  801057:	83 ec 04             	sub    $0x4,%esp
  80105a:	50                   	push   %eax
  80105b:	68 8a 34 80 00       	push   $0x80348a
  801060:	6a 01                	push   $0x1
  801062:	e8 e8 14 00 00       	call   80254f <fprintf>
  801067:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	6a 00                	push   $0x0
  80106f:	e8 7e f8 ff ff       	call   8008f2 <iscons>
  801074:	89 c7                	mov    %eax,%edi
  801076:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  801079:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80107e:	e8 44 f8 ff ff       	call   8008c7 <getchar>
  801083:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801085:	85 c0                	test   %eax,%eax
  801087:	79 29                	jns    8010b2 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801089:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  80108e:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801091:	0f 84 9b 00 00 00    	je     801132 <readline+0xeb>
				cprintf("read error: %e\n", c);
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	53                   	push   %ebx
  80109b:	68 5f 38 80 00       	push   $0x80385f
  8010a0:	e8 0c fa ff ff       	call   800ab1 <cprintf>
  8010a5:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ad:	e9 80 00 00 00       	jmp    801132 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010b2:	83 f8 08             	cmp    $0x8,%eax
  8010b5:	0f 94 c2             	sete   %dl
  8010b8:	83 f8 7f             	cmp    $0x7f,%eax
  8010bb:	0f 94 c0             	sete   %al
  8010be:	08 c2                	or     %al,%dl
  8010c0:	74 1a                	je     8010dc <readline+0x95>
  8010c2:	85 f6                	test   %esi,%esi
  8010c4:	7e 16                	jle    8010dc <readline+0x95>
			if (echoing)
  8010c6:	85 ff                	test   %edi,%edi
  8010c8:	74 0d                	je     8010d7 <readline+0x90>
				cputchar('\b');
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	6a 08                	push   $0x8
  8010cf:	e8 d7 f7 ff ff       	call   8008ab <cputchar>
  8010d4:	83 c4 10             	add    $0x10,%esp
			i--;
  8010d7:	83 ee 01             	sub    $0x1,%esi
  8010da:	eb a2                	jmp    80107e <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010dc:	83 fb 1f             	cmp    $0x1f,%ebx
  8010df:	7e 26                	jle    801107 <readline+0xc0>
  8010e1:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010e7:	7f 1e                	jg     801107 <readline+0xc0>
			if (echoing)
  8010e9:	85 ff                	test   %edi,%edi
  8010eb:	74 0c                	je     8010f9 <readline+0xb2>
				cputchar(c);
  8010ed:	83 ec 0c             	sub    $0xc,%esp
  8010f0:	53                   	push   %ebx
  8010f1:	e8 b5 f7 ff ff       	call   8008ab <cputchar>
  8010f6:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010f9:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8010ff:	8d 76 01             	lea    0x1(%esi),%esi
  801102:	e9 77 ff ff ff       	jmp    80107e <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801107:	83 fb 0a             	cmp    $0xa,%ebx
  80110a:	74 09                	je     801115 <readline+0xce>
  80110c:	83 fb 0d             	cmp    $0xd,%ebx
  80110f:	0f 85 69 ff ff ff    	jne    80107e <readline+0x37>
			if (echoing)
  801115:	85 ff                	test   %edi,%edi
  801117:	74 0d                	je     801126 <readline+0xdf>
				cputchar('\n');
  801119:	83 ec 0c             	sub    $0xc,%esp
  80111c:	6a 0a                	push   $0xa
  80111e:	e8 88 f7 ff ff       	call   8008ab <cputchar>
  801123:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801126:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80112d:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801140:	b8 00 00 00 00       	mov    $0x0,%eax
  801145:	eb 03                	jmp    80114a <strlen+0x10>
		n++;
  801147:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80114a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80114e:	75 f7                	jne    801147 <strlen+0xd>
		n++;
	return n;
}
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801158:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80115b:	ba 00 00 00 00       	mov    $0x0,%edx
  801160:	eb 03                	jmp    801165 <strnlen+0x13>
		n++;
  801162:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801165:	39 c2                	cmp    %eax,%edx
  801167:	74 08                	je     801171 <strnlen+0x1f>
  801169:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80116d:	75 f3                	jne    801162 <strnlen+0x10>
  80116f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	53                   	push   %ebx
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
  80117a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	83 c2 01             	add    $0x1,%edx
  801182:	83 c1 01             	add    $0x1,%ecx
  801185:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801189:	88 5a ff             	mov    %bl,-0x1(%edx)
  80118c:	84 db                	test   %bl,%bl
  80118e:	75 ef                	jne    80117f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801190:	5b                   	pop    %ebx
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	53                   	push   %ebx
  801197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80119a:	53                   	push   %ebx
  80119b:	e8 9a ff ff ff       	call   80113a <strlen>
  8011a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8011a3:	ff 75 0c             	pushl  0xc(%ebp)
  8011a6:	01 d8                	add    %ebx,%eax
  8011a8:	50                   	push   %eax
  8011a9:	e8 c5 ff ff ff       	call   801173 <strcpy>
	return dst;
}
  8011ae:	89 d8                	mov    %ebx,%eax
  8011b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b3:	c9                   	leave  
  8011b4:	c3                   	ret    

008011b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	56                   	push   %esi
  8011b9:	53                   	push   %ebx
  8011ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8011bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c0:	89 f3                	mov    %esi,%ebx
  8011c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011c5:	89 f2                	mov    %esi,%edx
  8011c7:	eb 0f                	jmp    8011d8 <strncpy+0x23>
		*dst++ = *src;
  8011c9:	83 c2 01             	add    $0x1,%edx
  8011cc:	0f b6 01             	movzbl (%ecx),%eax
  8011cf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011d2:	80 39 01             	cmpb   $0x1,(%ecx)
  8011d5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011d8:	39 da                	cmp    %ebx,%edx
  8011da:	75 ed                	jne    8011c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011dc:	89 f0                	mov    %esi,%eax
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8011f0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011f2:	85 d2                	test   %edx,%edx
  8011f4:	74 21                	je     801217 <strlcpy+0x35>
  8011f6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011fa:	89 f2                	mov    %esi,%edx
  8011fc:	eb 09                	jmp    801207 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011fe:	83 c2 01             	add    $0x1,%edx
  801201:	83 c1 01             	add    $0x1,%ecx
  801204:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801207:	39 c2                	cmp    %eax,%edx
  801209:	74 09                	je     801214 <strlcpy+0x32>
  80120b:	0f b6 19             	movzbl (%ecx),%ebx
  80120e:	84 db                	test   %bl,%bl
  801210:	75 ec                	jne    8011fe <strlcpy+0x1c>
  801212:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801214:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801217:	29 f0                	sub    %esi,%eax
}
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801223:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801226:	eb 06                	jmp    80122e <strcmp+0x11>
		p++, q++;
  801228:	83 c1 01             	add    $0x1,%ecx
  80122b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80122e:	0f b6 01             	movzbl (%ecx),%eax
  801231:	84 c0                	test   %al,%al
  801233:	74 04                	je     801239 <strcmp+0x1c>
  801235:	3a 02                	cmp    (%edx),%al
  801237:	74 ef                	je     801228 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801239:	0f b6 c0             	movzbl %al,%eax
  80123c:	0f b6 12             	movzbl (%edx),%edx
  80123f:	29 d0                	sub    %edx,%eax
}
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	8b 45 08             	mov    0x8(%ebp),%eax
  80124a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124d:	89 c3                	mov    %eax,%ebx
  80124f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801252:	eb 06                	jmp    80125a <strncmp+0x17>
		n--, p++, q++;
  801254:	83 c0 01             	add    $0x1,%eax
  801257:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80125a:	39 d8                	cmp    %ebx,%eax
  80125c:	74 15                	je     801273 <strncmp+0x30>
  80125e:	0f b6 08             	movzbl (%eax),%ecx
  801261:	84 c9                	test   %cl,%cl
  801263:	74 04                	je     801269 <strncmp+0x26>
  801265:	3a 0a                	cmp    (%edx),%cl
  801267:	74 eb                	je     801254 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801269:	0f b6 00             	movzbl (%eax),%eax
  80126c:	0f b6 12             	movzbl (%edx),%edx
  80126f:	29 d0                	sub    %edx,%eax
  801271:	eb 05                	jmp    801278 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801278:	5b                   	pop    %ebx
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801285:	eb 07                	jmp    80128e <strchr+0x13>
		if (*s == c)
  801287:	38 ca                	cmp    %cl,%dl
  801289:	74 0f                	je     80129a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80128b:	83 c0 01             	add    $0x1,%eax
  80128e:	0f b6 10             	movzbl (%eax),%edx
  801291:	84 d2                	test   %dl,%dl
  801293:	75 f2                	jne    801287 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801295:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012a6:	eb 03                	jmp    8012ab <strfind+0xf>
  8012a8:	83 c0 01             	add    $0x1,%eax
  8012ab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012ae:	38 ca                	cmp    %cl,%dl
  8012b0:	74 04                	je     8012b6 <strfind+0x1a>
  8012b2:	84 d2                	test   %dl,%dl
  8012b4:	75 f2                	jne    8012a8 <strfind+0xc>
			break;
	return (char *) s;
}
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	57                   	push   %edi
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012c4:	85 c9                	test   %ecx,%ecx
  8012c6:	74 36                	je     8012fe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012ce:	75 28                	jne    8012f8 <memset+0x40>
  8012d0:	f6 c1 03             	test   $0x3,%cl
  8012d3:	75 23                	jne    8012f8 <memset+0x40>
		c &= 0xFF;
  8012d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012d9:	89 d3                	mov    %edx,%ebx
  8012db:	c1 e3 08             	shl    $0x8,%ebx
  8012de:	89 d6                	mov    %edx,%esi
  8012e0:	c1 e6 18             	shl    $0x18,%esi
  8012e3:	89 d0                	mov    %edx,%eax
  8012e5:	c1 e0 10             	shl    $0x10,%eax
  8012e8:	09 f0                	or     %esi,%eax
  8012ea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012ec:	89 d8                	mov    %ebx,%eax
  8012ee:	09 d0                	or     %edx,%eax
  8012f0:	c1 e9 02             	shr    $0x2,%ecx
  8012f3:	fc                   	cld    
  8012f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8012f6:	eb 06                	jmp    8012fe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fb:	fc                   	cld    
  8012fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012fe:	89 f8                	mov    %edi,%eax
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	57                   	push   %edi
  801309:	56                   	push   %esi
  80130a:	8b 45 08             	mov    0x8(%ebp),%eax
  80130d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801310:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801313:	39 c6                	cmp    %eax,%esi
  801315:	73 35                	jae    80134c <memmove+0x47>
  801317:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80131a:	39 d0                	cmp    %edx,%eax
  80131c:	73 2e                	jae    80134c <memmove+0x47>
		s += n;
		d += n;
  80131e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801321:	89 d6                	mov    %edx,%esi
  801323:	09 fe                	or     %edi,%esi
  801325:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80132b:	75 13                	jne    801340 <memmove+0x3b>
  80132d:	f6 c1 03             	test   $0x3,%cl
  801330:	75 0e                	jne    801340 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801332:	83 ef 04             	sub    $0x4,%edi
  801335:	8d 72 fc             	lea    -0x4(%edx),%esi
  801338:	c1 e9 02             	shr    $0x2,%ecx
  80133b:	fd                   	std    
  80133c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80133e:	eb 09                	jmp    801349 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801340:	83 ef 01             	sub    $0x1,%edi
  801343:	8d 72 ff             	lea    -0x1(%edx),%esi
  801346:	fd                   	std    
  801347:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801349:	fc                   	cld    
  80134a:	eb 1d                	jmp    801369 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80134c:	89 f2                	mov    %esi,%edx
  80134e:	09 c2                	or     %eax,%edx
  801350:	f6 c2 03             	test   $0x3,%dl
  801353:	75 0f                	jne    801364 <memmove+0x5f>
  801355:	f6 c1 03             	test   $0x3,%cl
  801358:	75 0a                	jne    801364 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80135a:	c1 e9 02             	shr    $0x2,%ecx
  80135d:	89 c7                	mov    %eax,%edi
  80135f:	fc                   	cld    
  801360:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801362:	eb 05                	jmp    801369 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801364:	89 c7                	mov    %eax,%edi
  801366:	fc                   	cld    
  801367:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801369:	5e                   	pop    %esi
  80136a:	5f                   	pop    %edi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    

0080136d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801370:	ff 75 10             	pushl  0x10(%ebp)
  801373:	ff 75 0c             	pushl  0xc(%ebp)
  801376:	ff 75 08             	pushl  0x8(%ebp)
  801379:	e8 87 ff ff ff       	call   801305 <memmove>
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	8b 45 08             	mov    0x8(%ebp),%eax
  801388:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138b:	89 c6                	mov    %eax,%esi
  80138d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801390:	eb 1a                	jmp    8013ac <memcmp+0x2c>
		if (*s1 != *s2)
  801392:	0f b6 08             	movzbl (%eax),%ecx
  801395:	0f b6 1a             	movzbl (%edx),%ebx
  801398:	38 d9                	cmp    %bl,%cl
  80139a:	74 0a                	je     8013a6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80139c:	0f b6 c1             	movzbl %cl,%eax
  80139f:	0f b6 db             	movzbl %bl,%ebx
  8013a2:	29 d8                	sub    %ebx,%eax
  8013a4:	eb 0f                	jmp    8013b5 <memcmp+0x35>
		s1++, s2++;
  8013a6:	83 c0 01             	add    $0x1,%eax
  8013a9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013ac:	39 f0                	cmp    %esi,%eax
  8013ae:	75 e2                	jne    801392 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b5:	5b                   	pop    %ebx
  8013b6:	5e                   	pop    %esi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	53                   	push   %ebx
  8013bd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013c0:	89 c1                	mov    %eax,%ecx
  8013c2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013c5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013c9:	eb 0a                	jmp    8013d5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013cb:	0f b6 10             	movzbl (%eax),%edx
  8013ce:	39 da                	cmp    %ebx,%edx
  8013d0:	74 07                	je     8013d9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013d2:	83 c0 01             	add    $0x1,%eax
  8013d5:	39 c8                	cmp    %ecx,%eax
  8013d7:	72 f2                	jb     8013cb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013d9:	5b                   	pop    %ebx
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	57                   	push   %edi
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013e8:	eb 03                	jmp    8013ed <strtol+0x11>
		s++;
  8013ea:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013ed:	0f b6 01             	movzbl (%ecx),%eax
  8013f0:	3c 20                	cmp    $0x20,%al
  8013f2:	74 f6                	je     8013ea <strtol+0xe>
  8013f4:	3c 09                	cmp    $0x9,%al
  8013f6:	74 f2                	je     8013ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013f8:	3c 2b                	cmp    $0x2b,%al
  8013fa:	75 0a                	jne    801406 <strtol+0x2a>
		s++;
  8013fc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801404:	eb 11                	jmp    801417 <strtol+0x3b>
  801406:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80140b:	3c 2d                	cmp    $0x2d,%al
  80140d:	75 08                	jne    801417 <strtol+0x3b>
		s++, neg = 1;
  80140f:	83 c1 01             	add    $0x1,%ecx
  801412:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801417:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80141d:	75 15                	jne    801434 <strtol+0x58>
  80141f:	80 39 30             	cmpb   $0x30,(%ecx)
  801422:	75 10                	jne    801434 <strtol+0x58>
  801424:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801428:	75 7c                	jne    8014a6 <strtol+0xca>
		s += 2, base = 16;
  80142a:	83 c1 02             	add    $0x2,%ecx
  80142d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801432:	eb 16                	jmp    80144a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801434:	85 db                	test   %ebx,%ebx
  801436:	75 12                	jne    80144a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801438:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80143d:	80 39 30             	cmpb   $0x30,(%ecx)
  801440:	75 08                	jne    80144a <strtol+0x6e>
		s++, base = 8;
  801442:	83 c1 01             	add    $0x1,%ecx
  801445:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80144a:	b8 00 00 00 00       	mov    $0x0,%eax
  80144f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801452:	0f b6 11             	movzbl (%ecx),%edx
  801455:	8d 72 d0             	lea    -0x30(%edx),%esi
  801458:	89 f3                	mov    %esi,%ebx
  80145a:	80 fb 09             	cmp    $0x9,%bl
  80145d:	77 08                	ja     801467 <strtol+0x8b>
			dig = *s - '0';
  80145f:	0f be d2             	movsbl %dl,%edx
  801462:	83 ea 30             	sub    $0x30,%edx
  801465:	eb 22                	jmp    801489 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801467:	8d 72 9f             	lea    -0x61(%edx),%esi
  80146a:	89 f3                	mov    %esi,%ebx
  80146c:	80 fb 19             	cmp    $0x19,%bl
  80146f:	77 08                	ja     801479 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801471:	0f be d2             	movsbl %dl,%edx
  801474:	83 ea 57             	sub    $0x57,%edx
  801477:	eb 10                	jmp    801489 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801479:	8d 72 bf             	lea    -0x41(%edx),%esi
  80147c:	89 f3                	mov    %esi,%ebx
  80147e:	80 fb 19             	cmp    $0x19,%bl
  801481:	77 16                	ja     801499 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801483:	0f be d2             	movsbl %dl,%edx
  801486:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801489:	3b 55 10             	cmp    0x10(%ebp),%edx
  80148c:	7d 0b                	jge    801499 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80148e:	83 c1 01             	add    $0x1,%ecx
  801491:	0f af 45 10          	imul   0x10(%ebp),%eax
  801495:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801497:	eb b9                	jmp    801452 <strtol+0x76>

	if (endptr)
  801499:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80149d:	74 0d                	je     8014ac <strtol+0xd0>
		*endptr = (char *) s;
  80149f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014a2:	89 0e                	mov    %ecx,(%esi)
  8014a4:	eb 06                	jmp    8014ac <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014a6:	85 db                	test   %ebx,%ebx
  8014a8:	74 98                	je     801442 <strtol+0x66>
  8014aa:	eb 9e                	jmp    80144a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	f7 da                	neg    %edx
  8014b0:	85 ff                	test   %edi,%edi
  8014b2:	0f 45 c2             	cmovne %edx,%eax
}
  8014b5:	5b                   	pop    %ebx
  8014b6:	5e                   	pop    %esi
  8014b7:	5f                   	pop    %edi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    

008014ba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	57                   	push   %edi
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8014c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	89 c7                	mov    %eax,%edi
  8014cf:	89 c6                	mov    %eax,%esi
  8014d1:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014d3:	5b                   	pop    %ebx
  8014d4:	5e                   	pop    %esi
  8014d5:	5f                   	pop    %edi
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	57                   	push   %edi
  8014dc:	56                   	push   %esi
  8014dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8014de:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e8:	89 d1                	mov    %edx,%ecx
  8014ea:	89 d3                	mov    %edx,%ebx
  8014ec:	89 d7                	mov    %edx,%edi
  8014ee:	89 d6                	mov    %edx,%esi
  8014f0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014f2:	5b                   	pop    %ebx
  8014f3:	5e                   	pop    %esi
  8014f4:	5f                   	pop    %edi
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	57                   	push   %edi
  8014fb:	56                   	push   %esi
  8014fc:	53                   	push   %ebx
  8014fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801500:	b9 00 00 00 00       	mov    $0x0,%ecx
  801505:	b8 03 00 00 00       	mov    $0x3,%eax
  80150a:	8b 55 08             	mov    0x8(%ebp),%edx
  80150d:	89 cb                	mov    %ecx,%ebx
  80150f:	89 cf                	mov    %ecx,%edi
  801511:	89 ce                	mov    %ecx,%esi
  801513:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801515:	85 c0                	test   %eax,%eax
  801517:	7e 17                	jle    801530 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801519:	83 ec 0c             	sub    $0xc,%esp
  80151c:	50                   	push   %eax
  80151d:	6a 03                	push   $0x3
  80151f:	68 6f 38 80 00       	push   $0x80386f
  801524:	6a 23                	push   $0x23
  801526:	68 8c 38 80 00       	push   $0x80388c
  80152b:	e8 a8 f4 ff ff       	call   8009d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801530:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801533:	5b                   	pop    %ebx
  801534:	5e                   	pop    %esi
  801535:	5f                   	pop    %edi
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    

00801538 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	57                   	push   %edi
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80153e:	ba 00 00 00 00       	mov    $0x0,%edx
  801543:	b8 02 00 00 00       	mov    $0x2,%eax
  801548:	89 d1                	mov    %edx,%ecx
  80154a:	89 d3                	mov    %edx,%ebx
  80154c:	89 d7                	mov    %edx,%edi
  80154e:	89 d6                	mov    %edx,%esi
  801550:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <sys_yield>:

void
sys_yield(void)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	57                   	push   %edi
  80155b:	56                   	push   %esi
  80155c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80155d:	ba 00 00 00 00       	mov    $0x0,%edx
  801562:	b8 0b 00 00 00       	mov    $0xb,%eax
  801567:	89 d1                	mov    %edx,%ecx
  801569:	89 d3                	mov    %edx,%ebx
  80156b:	89 d7                	mov    %edx,%edi
  80156d:	89 d6                	mov    %edx,%esi
  80156f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5f                   	pop    %edi
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    

00801576 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	57                   	push   %edi
  80157a:	56                   	push   %esi
  80157b:	53                   	push   %ebx
  80157c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80157f:	be 00 00 00 00       	mov    $0x0,%esi
  801584:	b8 04 00 00 00       	mov    $0x4,%eax
  801589:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80158c:	8b 55 08             	mov    0x8(%ebp),%edx
  80158f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801592:	89 f7                	mov    %esi,%edi
  801594:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801596:	85 c0                	test   %eax,%eax
  801598:	7e 17                	jle    8015b1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80159a:	83 ec 0c             	sub    $0xc,%esp
  80159d:	50                   	push   %eax
  80159e:	6a 04                	push   $0x4
  8015a0:	68 6f 38 80 00       	push   $0x80386f
  8015a5:	6a 23                	push   $0x23
  8015a7:	68 8c 38 80 00       	push   $0x80388c
  8015ac:	e8 27 f4 ff ff       	call   8009d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	5f                   	pop    %edi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	57                   	push   %edi
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8015c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8015cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8015d6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	7e 17                	jle    8015f3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015dc:	83 ec 0c             	sub    $0xc,%esp
  8015df:	50                   	push   %eax
  8015e0:	6a 05                	push   $0x5
  8015e2:	68 6f 38 80 00       	push   $0x80386f
  8015e7:	6a 23                	push   $0x23
  8015e9:	68 8c 38 80 00       	push   $0x80388c
  8015ee:	e8 e5 f3 ff ff       	call   8009d8 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f6:	5b                   	pop    %ebx
  8015f7:	5e                   	pop    %esi
  8015f8:	5f                   	pop    %edi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    

008015fb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	57                   	push   %edi
  8015ff:	56                   	push   %esi
  801600:	53                   	push   %ebx
  801601:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801604:	bb 00 00 00 00       	mov    $0x0,%ebx
  801609:	b8 06 00 00 00       	mov    $0x6,%eax
  80160e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801611:	8b 55 08             	mov    0x8(%ebp),%edx
  801614:	89 df                	mov    %ebx,%edi
  801616:	89 de                	mov    %ebx,%esi
  801618:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80161a:	85 c0                	test   %eax,%eax
  80161c:	7e 17                	jle    801635 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	50                   	push   %eax
  801622:	6a 06                	push   $0x6
  801624:	68 6f 38 80 00       	push   $0x80386f
  801629:	6a 23                	push   $0x23
  80162b:	68 8c 38 80 00       	push   $0x80388c
  801630:	e8 a3 f3 ff ff       	call   8009d8 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801638:	5b                   	pop    %ebx
  801639:	5e                   	pop    %esi
  80163a:	5f                   	pop    %edi
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    

0080163d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	57                   	push   %edi
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801646:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164b:	b8 08 00 00 00       	mov    $0x8,%eax
  801650:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801653:	8b 55 08             	mov    0x8(%ebp),%edx
  801656:	89 df                	mov    %ebx,%edi
  801658:	89 de                	mov    %ebx,%esi
  80165a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80165c:	85 c0                	test   %eax,%eax
  80165e:	7e 17                	jle    801677 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801660:	83 ec 0c             	sub    $0xc,%esp
  801663:	50                   	push   %eax
  801664:	6a 08                	push   $0x8
  801666:	68 6f 38 80 00       	push   $0x80386f
  80166b:	6a 23                	push   $0x23
  80166d:	68 8c 38 80 00       	push   $0x80388c
  801672:	e8 61 f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801677:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167a:	5b                   	pop    %ebx
  80167b:	5e                   	pop    %esi
  80167c:	5f                   	pop    %edi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	57                   	push   %edi
  801683:	56                   	push   %esi
  801684:	53                   	push   %ebx
  801685:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801688:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168d:	b8 09 00 00 00       	mov    $0x9,%eax
  801692:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801695:	8b 55 08             	mov    0x8(%ebp),%edx
  801698:	89 df                	mov    %ebx,%edi
  80169a:	89 de                	mov    %ebx,%esi
  80169c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	7e 17                	jle    8016b9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016a2:	83 ec 0c             	sub    $0xc,%esp
  8016a5:	50                   	push   %eax
  8016a6:	6a 09                	push   $0x9
  8016a8:	68 6f 38 80 00       	push   $0x80386f
  8016ad:	6a 23                	push   $0x23
  8016af:	68 8c 38 80 00       	push   $0x80388c
  8016b4:	e8 1f f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5e                   	pop    %esi
  8016be:	5f                   	pop    %edi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8016ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8016da:	89 df                	mov    %ebx,%edi
  8016dc:	89 de                	mov    %ebx,%esi
  8016de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	7e 17                	jle    8016fb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	50                   	push   %eax
  8016e8:	6a 0a                	push   $0xa
  8016ea:	68 6f 38 80 00       	push   $0x80386f
  8016ef:	6a 23                	push   $0x23
  8016f1:	68 8c 38 80 00       	push   $0x80388c
  8016f6:	e8 dd f2 ff ff       	call   8009d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fe:	5b                   	pop    %ebx
  8016ff:	5e                   	pop    %esi
  801700:	5f                   	pop    %edi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	57                   	push   %edi
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801709:	be 00 00 00 00       	mov    $0x0,%esi
  80170e:	b8 0c 00 00 00       	mov    $0xc,%eax
  801713:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801716:	8b 55 08             	mov    0x8(%ebp),%edx
  801719:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80171c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80171f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	5f                   	pop    %edi
  801724:	5d                   	pop    %ebp
  801725:	c3                   	ret    

00801726 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	57                   	push   %edi
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80172f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801734:	b8 0d 00 00 00       	mov    $0xd,%eax
  801739:	8b 55 08             	mov    0x8(%ebp),%edx
  80173c:	89 cb                	mov    %ecx,%ebx
  80173e:	89 cf                	mov    %ecx,%edi
  801740:	89 ce                	mov    %ecx,%esi
  801742:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801744:	85 c0                	test   %eax,%eax
  801746:	7e 17                	jle    80175f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801748:	83 ec 0c             	sub    $0xc,%esp
  80174b:	50                   	push   %eax
  80174c:	6a 0d                	push   $0xd
  80174e:	68 6f 38 80 00       	push   $0x80386f
  801753:	6a 23                	push   $0x23
  801755:	68 8c 38 80 00       	push   $0x80388c
  80175a:	e8 79 f2 ff ff       	call   8009d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80175f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5f                   	pop    %edi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	56                   	push   %esi
  80176b:	53                   	push   %ebx
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80176f:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  801771:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801775:	74 11                	je     801788 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  801777:	89 d8                	mov    %ebx,%eax
  801779:	c1 e8 0c             	shr    $0xc,%eax
  80177c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  801783:	f6 c4 08             	test   $0x8,%ah
  801786:	75 14                	jne    80179c <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	68 9a 38 80 00       	push   $0x80389a
  801790:	6a 21                	push   $0x21
  801792:	68 b0 38 80 00       	push   $0x8038b0
  801797:	e8 3c f2 ff ff       	call   8009d8 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  80179c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  8017a2:	e8 91 fd ff ff       	call   801538 <sys_getenvid>
  8017a7:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  8017a9:	83 ec 04             	sub    $0x4,%esp
  8017ac:	6a 07                	push   $0x7
  8017ae:	68 00 f0 7f 00       	push   $0x7ff000
  8017b3:	50                   	push   %eax
  8017b4:	e8 bd fd ff ff       	call   801576 <sys_page_alloc>
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	79 14                	jns    8017d4 <pgfault+0x6d>
		panic("sys_page_alloc");
  8017c0:	83 ec 04             	sub    $0x4,%esp
  8017c3:	68 bb 38 80 00       	push   $0x8038bb
  8017c8:	6a 30                	push   $0x30
  8017ca:	68 b0 38 80 00       	push   $0x8038b0
  8017cf:	e8 04 f2 ff ff       	call   8009d8 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	68 00 10 00 00       	push   $0x1000
  8017dc:	53                   	push   %ebx
  8017dd:	68 00 f0 7f 00       	push   $0x7ff000
  8017e2:	e8 86 fb ff ff       	call   80136d <memcpy>
	retv = sys_page_unmap(envid, addr);
  8017e7:	83 c4 08             	add    $0x8,%esp
  8017ea:	53                   	push   %ebx
  8017eb:	56                   	push   %esi
  8017ec:	e8 0a fe ff ff       	call   8015fb <sys_page_unmap>
	if(retv < 0){
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	79 12                	jns    80180a <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  8017f8:	50                   	push   %eax
  8017f9:	68 a8 39 80 00       	push   $0x8039a8
  8017fe:	6a 35                	push   $0x35
  801800:	68 b0 38 80 00       	push   $0x8038b0
  801805:	e8 ce f1 ff ff       	call   8009d8 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	6a 07                	push   $0x7
  80180f:	53                   	push   %ebx
  801810:	56                   	push   %esi
  801811:	68 00 f0 7f 00       	push   $0x7ff000
  801816:	56                   	push   %esi
  801817:	e8 9d fd ff ff       	call   8015b9 <sys_page_map>
	if(retv < 0){
  80181c:	83 c4 20             	add    $0x20,%esp
  80181f:	85 c0                	test   %eax,%eax
  801821:	79 14                	jns    801837 <pgfault+0xd0>
		panic("sys_page_map");
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	68 ca 38 80 00       	push   $0x8038ca
  80182b:	6a 39                	push   $0x39
  80182d:	68 b0 38 80 00       	push   $0x8038b0
  801832:	e8 a1 f1 ff ff       	call   8009d8 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	68 00 f0 7f 00       	push   $0x7ff000
  80183f:	56                   	push   %esi
  801840:	e8 b6 fd ff ff       	call   8015fb <sys_page_unmap>
	if(retv < 0){
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	79 14                	jns    801860 <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  80184c:	83 ec 04             	sub    $0x4,%esp
  80184f:	68 d7 38 80 00       	push   $0x8038d7
  801854:	6a 3d                	push   $0x3d
  801856:	68 b0 38 80 00       	push   $0x8038b0
  80185b:	e8 78 f1 ff ff       	call   8009d8 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  801860:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  80186f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801872:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	53                   	push   %ebx
  801879:	68 f4 38 80 00       	push   $0x8038f4
  80187e:	e8 2e f2 ff ff       	call   800ab1 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801883:	83 c4 0c             	add    $0xc,%esp
  801886:	6a 07                	push   $0x7
  801888:	53                   	push   %ebx
  801889:	56                   	push   %esi
  80188a:	e8 e7 fc ff ff       	call   801576 <sys_page_alloc>
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	79 15                	jns    8018ab <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  801896:	50                   	push   %eax
  801897:	68 07 39 80 00       	push   $0x803907
  80189c:	68 90 00 00 00       	push   $0x90
  8018a1:	68 b0 38 80 00       	push   $0x8038b0
  8018a6:	e8 2d f1 ff ff       	call   8009d8 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	68 1a 39 80 00       	push   $0x80391a
  8018b3:	e8 f9 f1 ff ff       	call   800ab1 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018b8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018bf:	68 00 00 40 00       	push   $0x400000
  8018c4:	6a 00                	push   $0x0
  8018c6:	53                   	push   %ebx
  8018c7:	56                   	push   %esi
  8018c8:	e8 ec fc ff ff       	call   8015b9 <sys_page_map>
  8018cd:	83 c4 20             	add    $0x20,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	79 15                	jns    8018e9 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  8018d4:	50                   	push   %eax
  8018d5:	68 22 39 80 00       	push   $0x803922
  8018da:	68 94 00 00 00       	push   $0x94
  8018df:	68 b0 38 80 00       	push   $0x8038b0
  8018e4:	e8 ef f0 ff ff       	call   8009d8 <_panic>
        cprintf("af_p_m.");
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	68 33 39 80 00       	push   $0x803933
  8018f1:	e8 bb f1 ff ff       	call   800ab1 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  8018f6:	83 c4 0c             	add    $0xc,%esp
  8018f9:	68 00 10 00 00       	push   $0x1000
  8018fe:	53                   	push   %ebx
  8018ff:	68 00 00 40 00       	push   $0x400000
  801904:	e8 fc f9 ff ff       	call   801305 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  801909:	c7 04 24 3b 39 80 00 	movl   $0x80393b,(%esp)
  801910:	e8 9c f1 ff ff       	call   800ab1 <cprintf>
}
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	57                   	push   %edi
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  801928:	68 67 17 80 00       	push   $0x801767
  80192d:	e8 a9 15 00 00       	call   802edb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801932:	b8 07 00 00 00       	mov    $0x7,%eax
  801937:	cd 30                	int    $0x30
  801939:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80193c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	85 c0                	test   %eax,%eax
  801944:	79 17                	jns    80195d <fork+0x3e>
		panic("sys_exofork failed.");
  801946:	83 ec 04             	sub    $0x4,%esp
  801949:	68 49 39 80 00       	push   $0x803949
  80194e:	68 b7 00 00 00       	push   $0xb7
  801953:	68 b0 38 80 00       	push   $0x8038b0
  801958:	e8 7b f0 ff ff       	call   8009d8 <_panic>
  80195d:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  801962:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801966:	75 21                	jne    801989 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801968:	e8 cb fb ff ff       	call   801538 <sys_getenvid>
  80196d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801972:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801975:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80197a:	a3 24 54 80 00       	mov    %eax,0x805424
//		cprintf("we are the child.\n");
		return 0;
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
  801984:	e9 69 01 00 00       	jmp    801af2 <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  801989:	89 d8                	mov    %ebx,%eax
  80198b:	c1 e8 16             	shr    $0x16,%eax
  80198e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  801995:	a8 01                	test   $0x1,%al
  801997:	0f 84 d6 00 00 00    	je     801a73 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  80199d:	89 de                	mov    %ebx,%esi
  80199f:	c1 ee 0c             	shr    $0xc,%esi
  8019a2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8019a9:	a8 01                	test   $0x1,%al
  8019ab:	0f 84 c2 00 00 00    	je     801a73 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  8019b1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  8019b8:	89 f7                	mov    %esi,%edi
  8019ba:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  8019bd:	e8 76 fb ff ff       	call   801538 <sys_getenvid>
  8019c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  8019c5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019cc:	f6 c4 04             	test   $0x4,%ah
  8019cf:	74 1c                	je     8019ed <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  8019d1:	83 ec 0c             	sub    $0xc,%esp
  8019d4:	68 07 0e 00 00       	push   $0xe07
  8019d9:	57                   	push   %edi
  8019da:	ff 75 e0             	pushl  -0x20(%ebp)
  8019dd:	57                   	push   %edi
  8019de:	6a 00                	push   $0x0
  8019e0:	e8 d4 fb ff ff       	call   8015b9 <sys_page_map>
  8019e5:	83 c4 20             	add    $0x20,%esp
  8019e8:	e9 86 00 00 00       	jmp    801a73 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  8019ed:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019f4:	a8 02                	test   $0x2,%al
  8019f6:	75 0c                	jne    801a04 <fork+0xe5>
  8019f8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019ff:	f6 c4 08             	test   $0x8,%ah
  801a02:	74 5b                	je     801a5f <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  801a04:	83 ec 0c             	sub    $0xc,%esp
  801a07:	68 05 08 00 00       	push   $0x805
  801a0c:	57                   	push   %edi
  801a0d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a10:	57                   	push   %edi
  801a11:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a14:	e8 a0 fb ff ff       	call   8015b9 <sys_page_map>
  801a19:	83 c4 20             	add    $0x20,%esp
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	79 12                	jns    801a32 <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  801a20:	50                   	push   %eax
  801a21:	68 cc 39 80 00       	push   $0x8039cc
  801a26:	6a 5f                	push   $0x5f
  801a28:	68 b0 38 80 00       	push   $0x8038b0
  801a2d:	e8 a6 ef ff ff       	call   8009d8 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	68 05 08 00 00       	push   $0x805
  801a3a:	57                   	push   %edi
  801a3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a3e:	50                   	push   %eax
  801a3f:	57                   	push   %edi
  801a40:	50                   	push   %eax
  801a41:	e8 73 fb ff ff       	call   8015b9 <sys_page_map>
  801a46:	83 c4 20             	add    $0x20,%esp
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	79 26                	jns    801a73 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  801a4d:	50                   	push   %eax
  801a4e:	68 f0 39 80 00       	push   $0x8039f0
  801a53:	6a 64                	push   $0x64
  801a55:	68 b0 38 80 00       	push   $0x8038b0
  801a5a:	e8 79 ef ff ff       	call   8009d8 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	6a 05                	push   $0x5
  801a64:	57                   	push   %edi
  801a65:	ff 75 e0             	pushl  -0x20(%ebp)
  801a68:	57                   	push   %edi
  801a69:	6a 00                	push   $0x0
  801a6b:	e8 49 fb ff ff       	call   8015b9 <sys_page_map>
  801a70:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801a73:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a79:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a7f:	0f 85 04 ff ff ff    	jne    801989 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	6a 07                	push   $0x7
  801a8a:	68 00 f0 bf ee       	push   $0xeebff000
  801a8f:	ff 75 dc             	pushl  -0x24(%ebp)
  801a92:	e8 df fa ff ff       	call   801576 <sys_page_alloc>
	if(retv < 0){
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	79 17                	jns    801ab5 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  801a9e:	83 ec 04             	sub    $0x4,%esp
  801aa1:	68 5d 39 80 00       	push   $0x80395d
  801aa6:	68 cc 00 00 00       	push   $0xcc
  801aab:	68 b0 38 80 00       	push   $0x8038b0
  801ab0:	e8 23 ef ff ff       	call   8009d8 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	68 40 2f 80 00       	push   $0x802f40
  801abd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801ac0:	57                   	push   %edi
  801ac1:	e8 fb fb ff ff       	call   8016c1 <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  801ac6:	83 c4 08             	add    $0x8,%esp
  801ac9:	6a 02                	push   $0x2
  801acb:	57                   	push   %edi
  801acc:	e8 6c fb ff ff       	call   80163d <sys_env_set_status>
	if(retv < 0){
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	79 17                	jns    801aef <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  801ad8:	83 ec 04             	sub    $0x4,%esp
  801adb:	68 75 39 80 00       	push   $0x803975
  801ae0:	68 dd 00 00 00       	push   $0xdd
  801ae5:	68 b0 38 80 00       	push   $0x8038b0
  801aea:	e8 e9 ee ff ff       	call   8009d8 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  801aef:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  801af2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5f                   	pop    %edi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <sfork>:

// Challenge!
int
sfork(void)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801b00:	68 91 39 80 00       	push   $0x803991
  801b05:	68 e8 00 00 00       	push   $0xe8
  801b0a:	68 b0 38 80 00       	push   $0x8038b0
  801b0f:	e8 c4 ee ff ff       	call   8009d8 <_panic>

00801b14 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	8b 55 08             	mov    0x8(%ebp),%edx
  801b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b20:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b22:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b25:	83 3a 01             	cmpl   $0x1,(%edx)
  801b28:	7e 09                	jle    801b33 <argstart+0x1f>
  801b2a:	ba 41 33 80 00       	mov    $0x803341,%edx
  801b2f:	85 c9                	test   %ecx,%ecx
  801b31:	75 05                	jne    801b38 <argstart+0x24>
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
  801b38:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b3b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <argnext>:

int
argnext(struct Argstate *args)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	53                   	push   %ebx
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b4e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b55:	8b 43 08             	mov    0x8(%ebx),%eax
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	74 6f                	je     801bcb <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801b5c:	80 38 00             	cmpb   $0x0,(%eax)
  801b5f:	75 4e                	jne    801baf <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b61:	8b 0b                	mov    (%ebx),%ecx
  801b63:	83 39 01             	cmpl   $0x1,(%ecx)
  801b66:	74 55                	je     801bbd <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b68:	8b 53 04             	mov    0x4(%ebx),%edx
  801b6b:	8b 42 04             	mov    0x4(%edx),%eax
  801b6e:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b71:	75 4a                	jne    801bbd <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b73:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b77:	74 44                	je     801bbd <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b79:	83 c0 01             	add    $0x1,%eax
  801b7c:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b7f:	83 ec 04             	sub    $0x4,%esp
  801b82:	8b 01                	mov    (%ecx),%eax
  801b84:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b8b:	50                   	push   %eax
  801b8c:	8d 42 08             	lea    0x8(%edx),%eax
  801b8f:	50                   	push   %eax
  801b90:	83 c2 04             	add    $0x4,%edx
  801b93:	52                   	push   %edx
  801b94:	e8 6c f7 ff ff       	call   801305 <memmove>
		(*args->argc)--;
  801b99:	8b 03                	mov    (%ebx),%eax
  801b9b:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b9e:	8b 43 08             	mov    0x8(%ebx),%eax
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ba7:	75 06                	jne    801baf <argnext+0x6b>
  801ba9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801bad:	74 0e                	je     801bbd <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801baf:	8b 53 08             	mov    0x8(%ebx),%edx
  801bb2:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801bb5:	83 c2 01             	add    $0x1,%edx
  801bb8:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801bbb:	eb 13                	jmp    801bd0 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801bbd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bc9:	eb 05                	jmp    801bd0 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801bcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801bd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801bdf:	8b 43 08             	mov    0x8(%ebx),%eax
  801be2:	85 c0                	test   %eax,%eax
  801be4:	74 58                	je     801c3e <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801be6:	80 38 00             	cmpb   $0x0,(%eax)
  801be9:	74 0c                	je     801bf7 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801beb:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801bee:	c7 43 08 41 33 80 00 	movl   $0x803341,0x8(%ebx)
  801bf5:	eb 42                	jmp    801c39 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801bf7:	8b 13                	mov    (%ebx),%edx
  801bf9:	83 3a 01             	cmpl   $0x1,(%edx)
  801bfc:	7e 2d                	jle    801c2b <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801bfe:	8b 43 04             	mov    0x4(%ebx),%eax
  801c01:	8b 48 04             	mov    0x4(%eax),%ecx
  801c04:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c07:	83 ec 04             	sub    $0x4,%esp
  801c0a:	8b 12                	mov    (%edx),%edx
  801c0c:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801c13:	52                   	push   %edx
  801c14:	8d 50 08             	lea    0x8(%eax),%edx
  801c17:	52                   	push   %edx
  801c18:	83 c0 04             	add    $0x4,%eax
  801c1b:	50                   	push   %eax
  801c1c:	e8 e4 f6 ff ff       	call   801305 <memmove>
		(*args->argc)--;
  801c21:	8b 03                	mov    (%ebx),%eax
  801c23:	83 28 01             	subl   $0x1,(%eax)
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	eb 0e                	jmp    801c39 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801c2b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801c32:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801c39:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c3c:	eb 05                	jmp    801c43 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801c43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 08             	sub    $0x8,%esp
  801c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c51:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c54:	89 d0                	mov    %edx,%eax
  801c56:	85 d2                	test   %edx,%edx
  801c58:	75 0c                	jne    801c66 <argvalue+0x1e>
  801c5a:	83 ec 0c             	sub    $0xc,%esp
  801c5d:	51                   	push   %ecx
  801c5e:	e8 72 ff ff ff       	call   801bd5 <argnextvalue>
  801c63:	83 c4 10             	add    $0x10,%esp
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6e:	05 00 00 00 30       	add    $0x30000000,%eax
  801c73:	c1 e8 0c             	shr    $0xc,%eax
}
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    

00801c78 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7e:	05 00 00 00 30       	add    $0x30000000,%eax
  801c83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c88:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c95:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c9a:	89 c2                	mov    %eax,%edx
  801c9c:	c1 ea 16             	shr    $0x16,%edx
  801c9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ca6:	f6 c2 01             	test   $0x1,%dl
  801ca9:	74 11                	je     801cbc <fd_alloc+0x2d>
  801cab:	89 c2                	mov    %eax,%edx
  801cad:	c1 ea 0c             	shr    $0xc,%edx
  801cb0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cb7:	f6 c2 01             	test   $0x1,%dl
  801cba:	75 09                	jne    801cc5 <fd_alloc+0x36>
			*fd_store = fd;
  801cbc:	89 01                	mov    %eax,(%ecx)
			return 0;
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc3:	eb 17                	jmp    801cdc <fd_alloc+0x4d>
  801cc5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801cca:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801ccf:	75 c9                	jne    801c9a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801cd1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801cd7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ce4:	83 f8 1f             	cmp    $0x1f,%eax
  801ce7:	77 36                	ja     801d1f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ce9:	c1 e0 0c             	shl    $0xc,%eax
  801cec:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801cf1:	89 c2                	mov    %eax,%edx
  801cf3:	c1 ea 16             	shr    $0x16,%edx
  801cf6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cfd:	f6 c2 01             	test   $0x1,%dl
  801d00:	74 24                	je     801d26 <fd_lookup+0x48>
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	c1 ea 0c             	shr    $0xc,%edx
  801d07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d0e:	f6 c2 01             	test   $0x1,%dl
  801d11:	74 1a                	je     801d2d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d13:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d16:	89 02                	mov    %eax,(%edx)
	return 0;
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1d:	eb 13                	jmp    801d32 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d24:	eb 0c                	jmp    801d32 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d2b:	eb 05                	jmp    801d32 <fd_lookup+0x54>
  801d2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    

00801d34 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 08             	sub    $0x8,%esp
  801d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3d:	ba 90 3a 80 00       	mov    $0x803a90,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801d42:	eb 13                	jmp    801d57 <dev_lookup+0x23>
  801d44:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801d47:	39 08                	cmp    %ecx,(%eax)
  801d49:	75 0c                	jne    801d57 <dev_lookup+0x23>
			*dev = devtab[i];
  801d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
  801d55:	eb 2e                	jmp    801d85 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d57:	8b 02                	mov    (%edx),%eax
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	75 e7                	jne    801d44 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d5d:	a1 24 54 80 00       	mov    0x805424,%eax
  801d62:	8b 40 48             	mov    0x48(%eax),%eax
  801d65:	83 ec 04             	sub    $0x4,%esp
  801d68:	51                   	push   %ecx
  801d69:	50                   	push   %eax
  801d6a:	68 14 3a 80 00       	push   $0x803a14
  801d6f:	e8 3d ed ff ff       	call   800ab1 <cprintf>
	*dev = 0;
  801d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	56                   	push   %esi
  801d8b:	53                   	push   %ebx
  801d8c:	83 ec 10             	sub    $0x10,%esp
  801d8f:	8b 75 08             	mov    0x8(%ebp),%esi
  801d92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d98:	50                   	push   %eax
  801d99:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d9f:	c1 e8 0c             	shr    $0xc,%eax
  801da2:	50                   	push   %eax
  801da3:	e8 36 ff ff ff       	call   801cde <fd_lookup>
  801da8:	83 c4 08             	add    $0x8,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 05                	js     801db4 <fd_close+0x2d>
	    || fd != fd2)
  801daf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801db2:	74 0c                	je     801dc0 <fd_close+0x39>
		return (must_exist ? r : 0);
  801db4:	84 db                	test   %bl,%bl
  801db6:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbb:	0f 44 c2             	cmove  %edx,%eax
  801dbe:	eb 41                	jmp    801e01 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc6:	50                   	push   %eax
  801dc7:	ff 36                	pushl  (%esi)
  801dc9:	e8 66 ff ff ff       	call   801d34 <dev_lookup>
  801dce:	89 c3                	mov    %eax,%ebx
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	78 1a                	js     801df1 <fd_close+0x6a>
		if (dev->dev_close)
  801dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dda:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801de2:	85 c0                	test   %eax,%eax
  801de4:	74 0b                	je     801df1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801de6:	83 ec 0c             	sub    $0xc,%esp
  801de9:	56                   	push   %esi
  801dea:	ff d0                	call   *%eax
  801dec:	89 c3                	mov    %eax,%ebx
  801dee:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	56                   	push   %esi
  801df5:	6a 00                	push   $0x0
  801df7:	e8 ff f7 ff ff       	call   8015fb <sys_page_unmap>
	return r;
  801dfc:	83 c4 10             	add    $0x10,%esp
  801dff:	89 d8                	mov    %ebx,%eax
}
  801e01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    

00801e08 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e11:	50                   	push   %eax
  801e12:	ff 75 08             	pushl  0x8(%ebp)
  801e15:	e8 c4 fe ff ff       	call   801cde <fd_lookup>
  801e1a:	83 c4 08             	add    $0x8,%esp
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	78 10                	js     801e31 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801e21:	83 ec 08             	sub    $0x8,%esp
  801e24:	6a 01                	push   $0x1
  801e26:	ff 75 f4             	pushl  -0xc(%ebp)
  801e29:	e8 59 ff ff ff       	call   801d87 <fd_close>
  801e2e:	83 c4 10             	add    $0x10,%esp
}
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <close_all>:

void
close_all(void)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	53                   	push   %ebx
  801e37:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e3a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e3f:	83 ec 0c             	sub    $0xc,%esp
  801e42:	53                   	push   %ebx
  801e43:	e8 c0 ff ff ff       	call   801e08 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e48:	83 c3 01             	add    $0x1,%ebx
  801e4b:	83 c4 10             	add    $0x10,%esp
  801e4e:	83 fb 20             	cmp    $0x20,%ebx
  801e51:	75 ec                	jne    801e3f <close_all+0xc>
		close(i);
}
  801e53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	57                   	push   %edi
  801e5c:	56                   	push   %esi
  801e5d:	53                   	push   %ebx
  801e5e:	83 ec 2c             	sub    $0x2c,%esp
  801e61:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e64:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e67:	50                   	push   %eax
  801e68:	ff 75 08             	pushl  0x8(%ebp)
  801e6b:	e8 6e fe ff ff       	call   801cde <fd_lookup>
  801e70:	83 c4 08             	add    $0x8,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	0f 88 c1 00 00 00    	js     801f3c <dup+0xe4>
		return r;
	close(newfdnum);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	56                   	push   %esi
  801e7f:	e8 84 ff ff ff       	call   801e08 <close>

	newfd = INDEX2FD(newfdnum);
  801e84:	89 f3                	mov    %esi,%ebx
  801e86:	c1 e3 0c             	shl    $0xc,%ebx
  801e89:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e8f:	83 c4 04             	add    $0x4,%esp
  801e92:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e95:	e8 de fd ff ff       	call   801c78 <fd2data>
  801e9a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e9c:	89 1c 24             	mov    %ebx,(%esp)
  801e9f:	e8 d4 fd ff ff       	call   801c78 <fd2data>
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801eaa:	89 f8                	mov    %edi,%eax
  801eac:	c1 e8 16             	shr    $0x16,%eax
  801eaf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801eb6:	a8 01                	test   $0x1,%al
  801eb8:	74 37                	je     801ef1 <dup+0x99>
  801eba:	89 f8                	mov    %edi,%eax
  801ebc:	c1 e8 0c             	shr    $0xc,%eax
  801ebf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ec6:	f6 c2 01             	test   $0x1,%dl
  801ec9:	74 26                	je     801ef1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ecb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ed2:	83 ec 0c             	sub    $0xc,%esp
  801ed5:	25 07 0e 00 00       	and    $0xe07,%eax
  801eda:	50                   	push   %eax
  801edb:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ede:	6a 00                	push   $0x0
  801ee0:	57                   	push   %edi
  801ee1:	6a 00                	push   $0x0
  801ee3:	e8 d1 f6 ff ff       	call   8015b9 <sys_page_map>
  801ee8:	89 c7                	mov    %eax,%edi
  801eea:	83 c4 20             	add    $0x20,%esp
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 2e                	js     801f1f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ef1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	c1 e8 0c             	shr    $0xc,%eax
  801ef9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f00:	83 ec 0c             	sub    $0xc,%esp
  801f03:	25 07 0e 00 00       	and    $0xe07,%eax
  801f08:	50                   	push   %eax
  801f09:	53                   	push   %ebx
  801f0a:	6a 00                	push   $0x0
  801f0c:	52                   	push   %edx
  801f0d:	6a 00                	push   $0x0
  801f0f:	e8 a5 f6 ff ff       	call   8015b9 <sys_page_map>
  801f14:	89 c7                	mov    %eax,%edi
  801f16:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801f19:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f1b:	85 ff                	test   %edi,%edi
  801f1d:	79 1d                	jns    801f3c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f1f:	83 ec 08             	sub    $0x8,%esp
  801f22:	53                   	push   %ebx
  801f23:	6a 00                	push   $0x0
  801f25:	e8 d1 f6 ff ff       	call   8015fb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f2a:	83 c4 08             	add    $0x8,%esp
  801f2d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801f30:	6a 00                	push   $0x0
  801f32:	e8 c4 f6 ff ff       	call   8015fb <sys_page_unmap>
	return r;
  801f37:	83 c4 10             	add    $0x10,%esp
  801f3a:	89 f8                	mov    %edi,%eax
}
  801f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	53                   	push   %ebx
  801f48:	83 ec 14             	sub    $0x14,%esp
  801f4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	53                   	push   %ebx
  801f53:	e8 86 fd ff ff       	call   801cde <fd_lookup>
  801f58:	83 c4 08             	add    $0x8,%esp
  801f5b:	89 c2                	mov    %eax,%edx
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 6d                	js     801fce <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f61:	83 ec 08             	sub    $0x8,%esp
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f6b:	ff 30                	pushl  (%eax)
  801f6d:	e8 c2 fd ff ff       	call   801d34 <dev_lookup>
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 4c                	js     801fc5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f79:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f7c:	8b 42 08             	mov    0x8(%edx),%eax
  801f7f:	83 e0 03             	and    $0x3,%eax
  801f82:	83 f8 01             	cmp    $0x1,%eax
  801f85:	75 21                	jne    801fa8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f87:	a1 24 54 80 00       	mov    0x805424,%eax
  801f8c:	8b 40 48             	mov    0x48(%eax),%eax
  801f8f:	83 ec 04             	sub    $0x4,%esp
  801f92:	53                   	push   %ebx
  801f93:	50                   	push   %eax
  801f94:	68 55 3a 80 00       	push   $0x803a55
  801f99:	e8 13 eb ff ff       	call   800ab1 <cprintf>
		return -E_INVAL;
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fa6:	eb 26                	jmp    801fce <read+0x8a>
	}
	if (!dev->dev_read)
  801fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fab:	8b 40 08             	mov    0x8(%eax),%eax
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	74 17                	je     801fc9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801fb2:	83 ec 04             	sub    $0x4,%esp
  801fb5:	ff 75 10             	pushl  0x10(%ebp)
  801fb8:	ff 75 0c             	pushl  0xc(%ebp)
  801fbb:	52                   	push   %edx
  801fbc:	ff d0                	call   *%eax
  801fbe:	89 c2                	mov    %eax,%edx
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	eb 09                	jmp    801fce <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fc5:	89 c2                	mov    %eax,%edx
  801fc7:	eb 05                	jmp    801fce <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801fc9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801fce:	89 d0                	mov    %edx,%eax
  801fd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	57                   	push   %edi
  801fd9:	56                   	push   %esi
  801fda:	53                   	push   %ebx
  801fdb:	83 ec 0c             	sub    $0xc,%esp
  801fde:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fe4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fe9:	eb 21                	jmp    80200c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801feb:	83 ec 04             	sub    $0x4,%esp
  801fee:	89 f0                	mov    %esi,%eax
  801ff0:	29 d8                	sub    %ebx,%eax
  801ff2:	50                   	push   %eax
  801ff3:	89 d8                	mov    %ebx,%eax
  801ff5:	03 45 0c             	add    0xc(%ebp),%eax
  801ff8:	50                   	push   %eax
  801ff9:	57                   	push   %edi
  801ffa:	e8 45 ff ff ff       	call   801f44 <read>
		if (m < 0)
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	85 c0                	test   %eax,%eax
  802004:	78 10                	js     802016 <readn+0x41>
			return m;
		if (m == 0)
  802006:	85 c0                	test   %eax,%eax
  802008:	74 0a                	je     802014 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80200a:	01 c3                	add    %eax,%ebx
  80200c:	39 f3                	cmp    %esi,%ebx
  80200e:	72 db                	jb     801feb <readn+0x16>
  802010:	89 d8                	mov    %ebx,%eax
  802012:	eb 02                	jmp    802016 <readn+0x41>
  802014:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802016:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802019:	5b                   	pop    %ebx
  80201a:	5e                   	pop    %esi
  80201b:	5f                   	pop    %edi
  80201c:	5d                   	pop    %ebp
  80201d:	c3                   	ret    

0080201e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	53                   	push   %ebx
  802022:	83 ec 14             	sub    $0x14,%esp
  802025:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802028:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80202b:	50                   	push   %eax
  80202c:	53                   	push   %ebx
  80202d:	e8 ac fc ff ff       	call   801cde <fd_lookup>
  802032:	83 c4 08             	add    $0x8,%esp
  802035:	89 c2                	mov    %eax,%edx
  802037:	85 c0                	test   %eax,%eax
  802039:	78 68                	js     8020a3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80203b:	83 ec 08             	sub    $0x8,%esp
  80203e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802041:	50                   	push   %eax
  802042:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802045:	ff 30                	pushl  (%eax)
  802047:	e8 e8 fc ff ff       	call   801d34 <dev_lookup>
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	85 c0                	test   %eax,%eax
  802051:	78 47                	js     80209a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802053:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802056:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80205a:	75 21                	jne    80207d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80205c:	a1 24 54 80 00       	mov    0x805424,%eax
  802061:	8b 40 48             	mov    0x48(%eax),%eax
  802064:	83 ec 04             	sub    $0x4,%esp
  802067:	53                   	push   %ebx
  802068:	50                   	push   %eax
  802069:	68 71 3a 80 00       	push   $0x803a71
  80206e:	e8 3e ea ff ff       	call   800ab1 <cprintf>
		return -E_INVAL;
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80207b:	eb 26                	jmp    8020a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80207d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802080:	8b 52 0c             	mov    0xc(%edx),%edx
  802083:	85 d2                	test   %edx,%edx
  802085:	74 17                	je     80209e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802087:	83 ec 04             	sub    $0x4,%esp
  80208a:	ff 75 10             	pushl  0x10(%ebp)
  80208d:	ff 75 0c             	pushl  0xc(%ebp)
  802090:	50                   	push   %eax
  802091:	ff d2                	call   *%edx
  802093:	89 c2                	mov    %eax,%edx
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	eb 09                	jmp    8020a3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80209a:	89 c2                	mov    %eax,%edx
  80209c:	eb 05                	jmp    8020a3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80209e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8020a3:	89 d0                	mov    %edx,%eax
  8020a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8020b3:	50                   	push   %eax
  8020b4:	ff 75 08             	pushl  0x8(%ebp)
  8020b7:	e8 22 fc ff ff       	call   801cde <fd_lookup>
  8020bc:	83 c4 08             	add    $0x8,%esp
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	78 0e                	js     8020d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8020c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d1:	c9                   	leave  
  8020d2:	c3                   	ret    

008020d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	53                   	push   %ebx
  8020d7:	83 ec 14             	sub    $0x14,%esp
  8020da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020e0:	50                   	push   %eax
  8020e1:	53                   	push   %ebx
  8020e2:	e8 f7 fb ff ff       	call   801cde <fd_lookup>
  8020e7:	83 c4 08             	add    $0x8,%esp
  8020ea:	89 c2                	mov    %eax,%edx
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	78 65                	js     802155 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020f0:	83 ec 08             	sub    $0x8,%esp
  8020f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f6:	50                   	push   %eax
  8020f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020fa:	ff 30                	pushl  (%eax)
  8020fc:	e8 33 fc ff ff       	call   801d34 <dev_lookup>
  802101:	83 c4 10             	add    $0x10,%esp
  802104:	85 c0                	test   %eax,%eax
  802106:	78 44                	js     80214c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802108:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80210b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80210f:	75 21                	jne    802132 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802111:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802116:	8b 40 48             	mov    0x48(%eax),%eax
  802119:	83 ec 04             	sub    $0x4,%esp
  80211c:	53                   	push   %ebx
  80211d:	50                   	push   %eax
  80211e:	68 34 3a 80 00       	push   $0x803a34
  802123:	e8 89 e9 ff ff       	call   800ab1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802130:	eb 23                	jmp    802155 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802132:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802135:	8b 52 18             	mov    0x18(%edx),%edx
  802138:	85 d2                	test   %edx,%edx
  80213a:	74 14                	je     802150 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80213c:	83 ec 08             	sub    $0x8,%esp
  80213f:	ff 75 0c             	pushl  0xc(%ebp)
  802142:	50                   	push   %eax
  802143:	ff d2                	call   *%edx
  802145:	89 c2                	mov    %eax,%edx
  802147:	83 c4 10             	add    $0x10,%esp
  80214a:	eb 09                	jmp    802155 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80214c:	89 c2                	mov    %eax,%edx
  80214e:	eb 05                	jmp    802155 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802150:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802155:	89 d0                	mov    %edx,%eax
  802157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80215a:	c9                   	leave  
  80215b:	c3                   	ret    

0080215c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	53                   	push   %ebx
  802160:	83 ec 14             	sub    $0x14,%esp
  802163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802166:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802169:	50                   	push   %eax
  80216a:	ff 75 08             	pushl  0x8(%ebp)
  80216d:	e8 6c fb ff ff       	call   801cde <fd_lookup>
  802172:	83 c4 08             	add    $0x8,%esp
  802175:	89 c2                	mov    %eax,%edx
  802177:	85 c0                	test   %eax,%eax
  802179:	78 58                	js     8021d3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80217b:	83 ec 08             	sub    $0x8,%esp
  80217e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802181:	50                   	push   %eax
  802182:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802185:	ff 30                	pushl  (%eax)
  802187:	e8 a8 fb ff ff       	call   801d34 <dev_lookup>
  80218c:	83 c4 10             	add    $0x10,%esp
  80218f:	85 c0                	test   %eax,%eax
  802191:	78 37                	js     8021ca <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802196:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80219a:	74 32                	je     8021ce <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80219c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80219f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021a6:	00 00 00 
	stat->st_isdir = 0;
  8021a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021b0:	00 00 00 
	stat->st_dev = dev;
  8021b3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021b9:	83 ec 08             	sub    $0x8,%esp
  8021bc:	53                   	push   %ebx
  8021bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8021c0:	ff 50 14             	call   *0x14(%eax)
  8021c3:	89 c2                	mov    %eax,%edx
  8021c5:	83 c4 10             	add    $0x10,%esp
  8021c8:	eb 09                	jmp    8021d3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021ca:	89 c2                	mov    %eax,%edx
  8021cc:	eb 05                	jmp    8021d3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8021ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8021d3:	89 d0                	mov    %edx,%eax
  8021d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d8:	c9                   	leave  
  8021d9:	c3                   	ret    

008021da <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8021da:	55                   	push   %ebp
  8021db:	89 e5                	mov    %esp,%ebp
  8021dd:	56                   	push   %esi
  8021de:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8021df:	83 ec 08             	sub    $0x8,%esp
  8021e2:	6a 00                	push   $0x0
  8021e4:	ff 75 08             	pushl  0x8(%ebp)
  8021e7:	e8 dc 01 00 00       	call   8023c8 <open>
  8021ec:	89 c3                	mov    %eax,%ebx
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	85 c0                	test   %eax,%eax
  8021f3:	78 1b                	js     802210 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021f5:	83 ec 08             	sub    $0x8,%esp
  8021f8:	ff 75 0c             	pushl  0xc(%ebp)
  8021fb:	50                   	push   %eax
  8021fc:	e8 5b ff ff ff       	call   80215c <fstat>
  802201:	89 c6                	mov    %eax,%esi
	close(fd);
  802203:	89 1c 24             	mov    %ebx,(%esp)
  802206:	e8 fd fb ff ff       	call   801e08 <close>
	return r;
  80220b:	83 c4 10             	add    $0x10,%esp
  80220e:	89 f0                	mov    %esi,%eax
}
  802210:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    

00802217 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	89 c6                	mov    %eax,%esi
  80221e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802220:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802227:	75 12                	jne    80223b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802229:	83 ec 0c             	sub    $0xc,%esp
  80222c:	6a 01                	push   $0x1
  80222e:	e8 d1 0d 00 00       	call   803004 <ipc_find_env>
  802233:	a3 20 54 80 00       	mov    %eax,0x805420
  802238:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80223b:	6a 07                	push   $0x7
  80223d:	68 00 60 80 00       	push   $0x806000
  802242:	56                   	push   %esi
  802243:	ff 35 20 54 80 00    	pushl  0x805420
  802249:	e8 73 0d 00 00       	call   802fc1 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  80224e:	83 c4 0c             	add    $0xc,%esp
  802251:	6a 00                	push   $0x0
  802253:	53                   	push   %ebx
  802254:	6a 00                	push   $0x0
  802256:	e8 09 0d 00 00       	call   802f64 <ipc_recv>
}
  80225b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    

00802262 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802268:	8b 45 08             	mov    0x8(%ebp),%eax
  80226b:	8b 40 0c             	mov    0xc(%eax),%eax
  80226e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802273:	8b 45 0c             	mov    0xc(%ebp),%eax
  802276:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80227b:	ba 00 00 00 00       	mov    $0x0,%edx
  802280:	b8 02 00 00 00       	mov    $0x2,%eax
  802285:	e8 8d ff ff ff       	call   802217 <fsipc>
}
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    

0080228c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802292:	8b 45 08             	mov    0x8(%ebp),%eax
  802295:	8b 40 0c             	mov    0xc(%eax),%eax
  802298:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80229d:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8022a7:	e8 6b ff ff ff       	call   802217 <fsipc>
}
  8022ac:	c9                   	leave  
  8022ad:	c3                   	ret    

008022ae <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	53                   	push   %ebx
  8022b2:	83 ec 04             	sub    $0x4,%esp
  8022b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8022be:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8022cd:	e8 45 ff ff ff       	call   802217 <fsipc>
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	78 2c                	js     802302 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022d6:	83 ec 08             	sub    $0x8,%esp
  8022d9:	68 00 60 80 00       	push   $0x806000
  8022de:	53                   	push   %ebx
  8022df:	e8 8f ee ff ff       	call   801173 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8022e4:	a1 80 60 80 00       	mov    0x806080,%eax
  8022e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022ef:	a1 84 60 80 00       	mov    0x806084,%eax
  8022f4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022fa:	83 c4 10             	add    $0x10,%esp
  8022fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 0c             	sub    $0xc,%esp
  80230d:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802310:	8b 55 08             	mov    0x8(%ebp),%edx
  802313:	8b 52 0c             	mov    0xc(%edx),%edx
  802316:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  80231c:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802321:	50                   	push   %eax
  802322:	ff 75 0c             	pushl  0xc(%ebp)
  802325:	68 08 60 80 00       	push   $0x806008
  80232a:	e8 d6 ef ff ff       	call   801305 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80232f:	ba 00 00 00 00       	mov    $0x0,%edx
  802334:	b8 04 00 00 00       	mov    $0x4,%eax
  802339:	e8 d9 fe ff ff       	call   802217 <fsipc>
	//panic("devfile_write not implemented");
}
  80233e:	c9                   	leave  
  80233f:	c3                   	ret    

00802340 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	56                   	push   %esi
  802344:	53                   	push   %ebx
  802345:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802348:	8b 45 08             	mov    0x8(%ebp),%eax
  80234b:	8b 40 0c             	mov    0xc(%eax),%eax
  80234e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802353:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802359:	ba 00 00 00 00       	mov    $0x0,%edx
  80235e:	b8 03 00 00 00       	mov    $0x3,%eax
  802363:	e8 af fe ff ff       	call   802217 <fsipc>
  802368:	89 c3                	mov    %eax,%ebx
  80236a:	85 c0                	test   %eax,%eax
  80236c:	78 51                	js     8023bf <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80236e:	39 c6                	cmp    %eax,%esi
  802370:	73 19                	jae    80238b <devfile_read+0x4b>
  802372:	68 a0 3a 80 00       	push   $0x803aa0
  802377:	68 78 34 80 00       	push   $0x803478
  80237c:	68 80 00 00 00       	push   $0x80
  802381:	68 a7 3a 80 00       	push   $0x803aa7
  802386:	e8 4d e6 ff ff       	call   8009d8 <_panic>
	assert(r <= PGSIZE);
  80238b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802390:	7e 19                	jle    8023ab <devfile_read+0x6b>
  802392:	68 b2 3a 80 00       	push   $0x803ab2
  802397:	68 78 34 80 00       	push   $0x803478
  80239c:	68 81 00 00 00       	push   $0x81
  8023a1:	68 a7 3a 80 00       	push   $0x803aa7
  8023a6:	e8 2d e6 ff ff       	call   8009d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8023ab:	83 ec 04             	sub    $0x4,%esp
  8023ae:	50                   	push   %eax
  8023af:	68 00 60 80 00       	push   $0x806000
  8023b4:	ff 75 0c             	pushl  0xc(%ebp)
  8023b7:	e8 49 ef ff ff       	call   801305 <memmove>
	return r;
  8023bc:	83 c4 10             	add    $0x10,%esp
}
  8023bf:	89 d8                	mov    %ebx,%eax
  8023c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    

008023c8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	53                   	push   %ebx
  8023cc:	83 ec 20             	sub    $0x20,%esp
  8023cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8023d2:	53                   	push   %ebx
  8023d3:	e8 62 ed ff ff       	call   80113a <strlen>
  8023d8:	83 c4 10             	add    $0x10,%esp
  8023db:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023e0:	7f 67                	jg     802449 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023e2:	83 ec 0c             	sub    $0xc,%esp
  8023e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e8:	50                   	push   %eax
  8023e9:	e8 a1 f8 ff ff       	call   801c8f <fd_alloc>
  8023ee:	83 c4 10             	add    $0x10,%esp
		return r;
  8023f1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	78 57                	js     80244e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8023f7:	83 ec 08             	sub    $0x8,%esp
  8023fa:	53                   	push   %ebx
  8023fb:	68 00 60 80 00       	push   $0x806000
  802400:	e8 6e ed ff ff       	call   801173 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802405:	8b 45 0c             	mov    0xc(%ebp),%eax
  802408:	a3 00 64 80 00       	mov    %eax,0x806400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80240d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802410:	b8 01 00 00 00       	mov    $0x1,%eax
  802415:	e8 fd fd ff ff       	call   802217 <fsipc>
  80241a:	89 c3                	mov    %eax,%ebx
  80241c:	83 c4 10             	add    $0x10,%esp
  80241f:	85 c0                	test   %eax,%eax
  802421:	79 14                	jns    802437 <open+0x6f>
		
		fd_close(fd, 0);
  802423:	83 ec 08             	sub    $0x8,%esp
  802426:	6a 00                	push   $0x0
  802428:	ff 75 f4             	pushl  -0xc(%ebp)
  80242b:	e8 57 f9 ff ff       	call   801d87 <fd_close>
		return r;
  802430:	83 c4 10             	add    $0x10,%esp
  802433:	89 da                	mov    %ebx,%edx
  802435:	eb 17                	jmp    80244e <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  802437:	83 ec 0c             	sub    $0xc,%esp
  80243a:	ff 75 f4             	pushl  -0xc(%ebp)
  80243d:	e8 26 f8 ff ff       	call   801c68 <fd2num>
  802442:	89 c2                	mov    %eax,%edx
  802444:	83 c4 10             	add    $0x10,%esp
  802447:	eb 05                	jmp    80244e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802449:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  80244e:	89 d0                	mov    %edx,%eax
  802450:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802453:	c9                   	leave  
  802454:	c3                   	ret    

00802455 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80245b:	ba 00 00 00 00       	mov    $0x0,%edx
  802460:	b8 08 00 00 00       	mov    $0x8,%eax
  802465:	e8 ad fd ff ff       	call   802217 <fsipc>
}
  80246a:	c9                   	leave  
  80246b:	c3                   	ret    

0080246c <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80246c:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802470:	7e 37                	jle    8024a9 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802472:	55                   	push   %ebp
  802473:	89 e5                	mov    %esp,%ebp
  802475:	53                   	push   %ebx
  802476:	83 ec 08             	sub    $0x8,%esp
  802479:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80247b:	ff 70 04             	pushl  0x4(%eax)
  80247e:	8d 40 10             	lea    0x10(%eax),%eax
  802481:	50                   	push   %eax
  802482:	ff 33                	pushl  (%ebx)
  802484:	e8 95 fb ff ff       	call   80201e <write>
		if (result > 0)
  802489:	83 c4 10             	add    $0x10,%esp
  80248c:	85 c0                	test   %eax,%eax
  80248e:	7e 03                	jle    802493 <writebuf+0x27>
			b->result += result;
  802490:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802493:	3b 43 04             	cmp    0x4(%ebx),%eax
  802496:	74 0d                	je     8024a5 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802498:	85 c0                	test   %eax,%eax
  80249a:	ba 00 00 00 00       	mov    $0x0,%edx
  80249f:	0f 4f c2             	cmovg  %edx,%eax
  8024a2:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8024a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024a8:	c9                   	leave  
  8024a9:	f3 c3                	repz ret 

008024ab <putch>:

static void
putch(int ch, void *thunk)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	53                   	push   %ebx
  8024af:	83 ec 04             	sub    $0x4,%esp
  8024b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8024b5:	8b 53 04             	mov    0x4(%ebx),%edx
  8024b8:	8d 42 01             	lea    0x1(%edx),%eax
  8024bb:	89 43 04             	mov    %eax,0x4(%ebx)
  8024be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024c1:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8024c5:	3d 00 01 00 00       	cmp    $0x100,%eax
  8024ca:	75 0e                	jne    8024da <putch+0x2f>
		writebuf(b);
  8024cc:	89 d8                	mov    %ebx,%eax
  8024ce:	e8 99 ff ff ff       	call   80246c <writebuf>
		b->idx = 0;
  8024d3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8024da:	83 c4 04             	add    $0x4,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    

008024e0 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8024e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ec:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8024f2:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8024f9:	00 00 00 
	b.result = 0;
  8024fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802503:	00 00 00 
	b.error = 1;
  802506:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80250d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802510:	ff 75 10             	pushl  0x10(%ebp)
  802513:	ff 75 0c             	pushl  0xc(%ebp)
  802516:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80251c:	50                   	push   %eax
  80251d:	68 ab 24 80 00       	push   $0x8024ab
  802522:	e8 c1 e6 ff ff       	call   800be8 <vprintfmt>
	if (b.idx > 0)
  802527:	83 c4 10             	add    $0x10,%esp
  80252a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802531:	7e 0b                	jle    80253e <vfprintf+0x5e>
		writebuf(&b);
  802533:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802539:	e8 2e ff ff ff       	call   80246c <writebuf>

	return (b.result ? b.result : b.error);
  80253e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802544:	85 c0                	test   %eax,%eax
  802546:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80254d:	c9                   	leave  
  80254e:	c3                   	ret    

0080254f <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80254f:	55                   	push   %ebp
  802550:	89 e5                	mov    %esp,%ebp
  802552:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802555:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802558:	50                   	push   %eax
  802559:	ff 75 0c             	pushl  0xc(%ebp)
  80255c:	ff 75 08             	pushl  0x8(%ebp)
  80255f:	e8 7c ff ff ff       	call   8024e0 <vfprintf>
	va_end(ap);

	return cnt;
}
  802564:	c9                   	leave  
  802565:	c3                   	ret    

00802566 <printf>:

int
printf(const char *fmt, ...)
{
  802566:	55                   	push   %ebp
  802567:	89 e5                	mov    %esp,%ebp
  802569:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80256c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80256f:	50                   	push   %eax
  802570:	ff 75 08             	pushl  0x8(%ebp)
  802573:	6a 01                	push   $0x1
  802575:	e8 66 ff ff ff       	call   8024e0 <vfprintf>
	va_end(ap);

	return cnt;
}
  80257a:	c9                   	leave  
  80257b:	c3                   	ret    

0080257c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80257c:	55                   	push   %ebp
  80257d:	89 e5                	mov    %esp,%ebp
  80257f:	57                   	push   %edi
  802580:	56                   	push   %esi
  802581:	53                   	push   %ebx
  802582:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802588:	6a 00                	push   $0x0
  80258a:	ff 75 08             	pushl  0x8(%ebp)
  80258d:	e8 36 fe ff ff       	call   8023c8 <open>
  802592:	89 c7                	mov    %eax,%edi
  802594:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80259a:	83 c4 10             	add    $0x10,%esp
  80259d:	85 c0                	test   %eax,%eax
  80259f:	0f 88 ae 04 00 00    	js     802a53 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8025a5:	83 ec 04             	sub    $0x4,%esp
  8025a8:	68 00 02 00 00       	push   $0x200
  8025ad:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8025b3:	50                   	push   %eax
  8025b4:	57                   	push   %edi
  8025b5:	e8 1b fa ff ff       	call   801fd5 <readn>
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	3d 00 02 00 00       	cmp    $0x200,%eax
  8025c2:	75 0c                	jne    8025d0 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8025c4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8025cb:	45 4c 46 
  8025ce:	74 33                	je     802603 <spawn+0x87>
		close(fd);
  8025d0:	83 ec 0c             	sub    $0xc,%esp
  8025d3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8025d9:	e8 2a f8 ff ff       	call   801e08 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8025de:	83 c4 0c             	add    $0xc,%esp
  8025e1:	68 7f 45 4c 46       	push   $0x464c457f
  8025e6:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8025ec:	68 be 3a 80 00       	push   $0x803abe
  8025f1:	e8 bb e4 ff ff       	call   800ab1 <cprintf>
		return -E_NOT_EXEC;
  8025f6:	83 c4 10             	add    $0x10,%esp
  8025f9:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8025fe:	e9 b0 04 00 00       	jmp    802ab3 <spawn+0x537>
  802603:	b8 07 00 00 00       	mov    $0x7,%eax
  802608:	cd 30                	int    $0x30
  80260a:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802610:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802616:	85 c0                	test   %eax,%eax
  802618:	0f 88 3d 04 00 00    	js     802a5b <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80261e:	89 c6                	mov    %eax,%esi
  802620:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802626:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802629:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80262f:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802635:	b9 11 00 00 00       	mov    $0x11,%ecx
  80263a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80263c:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802642:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802648:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80264d:	be 00 00 00 00       	mov    $0x0,%esi
  802652:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802655:	eb 13                	jmp    80266a <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802657:	83 ec 0c             	sub    $0xc,%esp
  80265a:	50                   	push   %eax
  80265b:	e8 da ea ff ff       	call   80113a <strlen>
  802660:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802664:	83 c3 01             	add    $0x1,%ebx
  802667:	83 c4 10             	add    $0x10,%esp
  80266a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802671:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802674:	85 c0                	test   %eax,%eax
  802676:	75 df                	jne    802657 <spawn+0xdb>
  802678:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80267e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802684:	bf 00 10 40 00       	mov    $0x401000,%edi
  802689:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80268b:	89 fa                	mov    %edi,%edx
  80268d:	83 e2 fc             	and    $0xfffffffc,%edx
  802690:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802697:	29 c2                	sub    %eax,%edx
  802699:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80269f:	8d 42 f8             	lea    -0x8(%edx),%eax
  8026a2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8026a7:	0f 86 be 03 00 00    	jbe    802a6b <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026ad:	83 ec 04             	sub    $0x4,%esp
  8026b0:	6a 07                	push   $0x7
  8026b2:	68 00 00 40 00       	push   $0x400000
  8026b7:	6a 00                	push   $0x0
  8026b9:	e8 b8 ee ff ff       	call   801576 <sys_page_alloc>
  8026be:	83 c4 10             	add    $0x10,%esp
  8026c1:	85 c0                	test   %eax,%eax
  8026c3:	0f 88 a9 03 00 00    	js     802a72 <spawn+0x4f6>
  8026c9:	be 00 00 00 00       	mov    $0x0,%esi
  8026ce:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8026d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8026d7:	eb 30                	jmp    802709 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8026d9:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8026df:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8026e5:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8026e8:	83 ec 08             	sub    $0x8,%esp
  8026eb:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026ee:	57                   	push   %edi
  8026ef:	e8 7f ea ff ff       	call   801173 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026f4:	83 c4 04             	add    $0x4,%esp
  8026f7:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026fa:	e8 3b ea ff ff       	call   80113a <strlen>
  8026ff:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802703:	83 c6 01             	add    $0x1,%esi
  802706:	83 c4 10             	add    $0x10,%esp
  802709:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80270f:	7f c8                	jg     8026d9 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802711:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802717:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80271d:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802724:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80272a:	74 19                	je     802745 <spawn+0x1c9>
  80272c:	68 34 3b 80 00       	push   $0x803b34
  802731:	68 78 34 80 00       	push   $0x803478
  802736:	68 f2 00 00 00       	push   $0xf2
  80273b:	68 d8 3a 80 00       	push   $0x803ad8
  802740:	e8 93 e2 ff ff       	call   8009d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802745:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80274b:	89 f8                	mov    %edi,%eax
  80274d:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802752:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802755:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80275b:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80275e:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802764:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80276a:	83 ec 0c             	sub    $0xc,%esp
  80276d:	6a 07                	push   $0x7
  80276f:	68 00 d0 bf ee       	push   $0xeebfd000
  802774:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80277a:	68 00 00 40 00       	push   $0x400000
  80277f:	6a 00                	push   $0x0
  802781:	e8 33 ee ff ff       	call   8015b9 <sys_page_map>
  802786:	89 c3                	mov    %eax,%ebx
  802788:	83 c4 20             	add    $0x20,%esp
  80278b:	85 c0                	test   %eax,%eax
  80278d:	0f 88 0e 03 00 00    	js     802aa1 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802793:	83 ec 08             	sub    $0x8,%esp
  802796:	68 00 00 40 00       	push   $0x400000
  80279b:	6a 00                	push   $0x0
  80279d:	e8 59 ee ff ff       	call   8015fb <sys_page_unmap>
  8027a2:	89 c3                	mov    %eax,%ebx
  8027a4:	83 c4 10             	add    $0x10,%esp
  8027a7:	85 c0                	test   %eax,%eax
  8027a9:	0f 88 f2 02 00 00    	js     802aa1 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8027af:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8027b5:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8027bc:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027c2:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8027c9:	00 00 00 
  8027cc:	e9 88 01 00 00       	jmp    802959 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8027d1:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8027d7:	83 38 01             	cmpl   $0x1,(%eax)
  8027da:	0f 85 6b 01 00 00    	jne    80294b <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8027e0:	89 c7                	mov    %eax,%edi
  8027e2:	8b 40 18             	mov    0x18(%eax),%eax
  8027e5:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8027eb:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8027ee:	83 f8 01             	cmp    $0x1,%eax
  8027f1:	19 c0                	sbb    %eax,%eax
  8027f3:	83 e0 fe             	and    $0xfffffffe,%eax
  8027f6:	83 c0 07             	add    $0x7,%eax
  8027f9:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027ff:	89 f8                	mov    %edi,%eax
  802801:	8b 7f 04             	mov    0x4(%edi),%edi
  802804:	89 f9                	mov    %edi,%ecx
  802806:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80280c:	8b 78 10             	mov    0x10(%eax),%edi
  80280f:	8b 50 14             	mov    0x14(%eax),%edx
  802812:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802818:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80281b:	89 f0                	mov    %esi,%eax
  80281d:	25 ff 0f 00 00       	and    $0xfff,%eax
  802822:	74 14                	je     802838 <spawn+0x2bc>
		va -= i;
  802824:	29 c6                	sub    %eax,%esi
		memsz += i;
  802826:	01 c2                	add    %eax,%edx
  802828:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80282e:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802830:	29 c1                	sub    %eax,%ecx
  802832:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802838:	bb 00 00 00 00       	mov    $0x0,%ebx
  80283d:	e9 f7 00 00 00       	jmp    802939 <spawn+0x3bd>
		if (i >= filesz) {
  802842:	39 df                	cmp    %ebx,%edi
  802844:	77 27                	ja     80286d <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802846:	83 ec 04             	sub    $0x4,%esp
  802849:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80284f:	56                   	push   %esi
  802850:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802856:	e8 1b ed ff ff       	call   801576 <sys_page_alloc>
  80285b:	83 c4 10             	add    $0x10,%esp
  80285e:	85 c0                	test   %eax,%eax
  802860:	0f 89 c7 00 00 00    	jns    80292d <spawn+0x3b1>
  802866:	89 c3                	mov    %eax,%ebx
  802868:	e9 13 02 00 00       	jmp    802a80 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80286d:	83 ec 04             	sub    $0x4,%esp
  802870:	6a 07                	push   $0x7
  802872:	68 00 00 40 00       	push   $0x400000
  802877:	6a 00                	push   $0x0
  802879:	e8 f8 ec ff ff       	call   801576 <sys_page_alloc>
  80287e:	83 c4 10             	add    $0x10,%esp
  802881:	85 c0                	test   %eax,%eax
  802883:	0f 88 ed 01 00 00    	js     802a76 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802889:	83 ec 08             	sub    $0x8,%esp
  80288c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802892:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802898:	50                   	push   %eax
  802899:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80289f:	e8 06 f8 ff ff       	call   8020aa <seek>
  8028a4:	83 c4 10             	add    $0x10,%esp
  8028a7:	85 c0                	test   %eax,%eax
  8028a9:	0f 88 cb 01 00 00    	js     802a7a <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8028af:	83 ec 04             	sub    $0x4,%esp
  8028b2:	89 f8                	mov    %edi,%eax
  8028b4:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8028ba:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8028bf:	ba 00 10 00 00       	mov    $0x1000,%edx
  8028c4:	0f 47 c2             	cmova  %edx,%eax
  8028c7:	50                   	push   %eax
  8028c8:	68 00 00 40 00       	push   $0x400000
  8028cd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028d3:	e8 fd f6 ff ff       	call   801fd5 <readn>
  8028d8:	83 c4 10             	add    $0x10,%esp
  8028db:	85 c0                	test   %eax,%eax
  8028dd:	0f 88 9b 01 00 00    	js     802a7e <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8028e3:	83 ec 0c             	sub    $0xc,%esp
  8028e6:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028ec:	56                   	push   %esi
  8028ed:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8028f3:	68 00 00 40 00       	push   $0x400000
  8028f8:	6a 00                	push   $0x0
  8028fa:	e8 ba ec ff ff       	call   8015b9 <sys_page_map>
  8028ff:	83 c4 20             	add    $0x20,%esp
  802902:	85 c0                	test   %eax,%eax
  802904:	79 15                	jns    80291b <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802906:	50                   	push   %eax
  802907:	68 e4 3a 80 00       	push   $0x803ae4
  80290c:	68 25 01 00 00       	push   $0x125
  802911:	68 d8 3a 80 00       	push   $0x803ad8
  802916:	e8 bd e0 ff ff       	call   8009d8 <_panic>
			sys_page_unmap(0, UTEMP);
  80291b:	83 ec 08             	sub    $0x8,%esp
  80291e:	68 00 00 40 00       	push   $0x400000
  802923:	6a 00                	push   $0x0
  802925:	e8 d1 ec ff ff       	call   8015fb <sys_page_unmap>
  80292a:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80292d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802933:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802939:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80293f:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802945:	0f 87 f7 fe ff ff    	ja     802842 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80294b:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802952:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802959:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802960:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802966:	0f 8c 65 fe ff ff    	jl     8027d1 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80296c:	83 ec 0c             	sub    $0xc,%esp
  80296f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802975:	e8 8e f4 ff ff       	call   801e08 <close>
  80297a:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  80297d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802982:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  802988:	89 d8                	mov    %ebx,%eax
  80298a:	c1 e8 16             	shr    $0x16,%eax
  80298d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802994:	a8 01                	test   $0x1,%al
  802996:	74 46                	je     8029de <spawn+0x462>
  802998:	89 d8                	mov    %ebx,%eax
  80299a:	c1 e8 0c             	shr    $0xc,%eax
  80299d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029a4:	f6 c2 01             	test   $0x1,%dl
  8029a7:	74 35                	je     8029de <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8029a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  8029b0:	f6 c2 04             	test   $0x4,%dl
  8029b3:	74 29                	je     8029de <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8029b5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029bc:	f6 c6 04             	test   $0x4,%dh
  8029bf:	74 1d                	je     8029de <spawn+0x462>
            sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  8029c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029c8:	83 ec 0c             	sub    $0xc,%esp
  8029cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8029d0:	50                   	push   %eax
  8029d1:	53                   	push   %ebx
  8029d2:	56                   	push   %esi
  8029d3:	53                   	push   %ebx
  8029d4:	6a 00                	push   $0x0
  8029d6:	e8 de eb ff ff       	call   8015b9 <sys_page_map>
  8029db:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8029de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8029e4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8029ea:	75 9c                	jne    802988 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8029ec:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8029f3:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8029f6:	83 ec 08             	sub    $0x8,%esp
  8029f9:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8029ff:	50                   	push   %eax
  802a00:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a06:	e8 74 ec ff ff       	call   80167f <sys_env_set_trapframe>
  802a0b:	83 c4 10             	add    $0x10,%esp
  802a0e:	85 c0                	test   %eax,%eax
  802a10:	79 15                	jns    802a27 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  802a12:	50                   	push   %eax
  802a13:	68 01 3b 80 00       	push   $0x803b01
  802a18:	68 86 00 00 00       	push   $0x86
  802a1d:	68 d8 3a 80 00       	push   $0x803ad8
  802a22:	e8 b1 df ff ff       	call   8009d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802a27:	83 ec 08             	sub    $0x8,%esp
  802a2a:	6a 02                	push   $0x2
  802a2c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a32:	e8 06 ec ff ff       	call   80163d <sys_env_set_status>
  802a37:	83 c4 10             	add    $0x10,%esp
  802a3a:	85 c0                	test   %eax,%eax
  802a3c:	79 25                	jns    802a63 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  802a3e:	50                   	push   %eax
  802a3f:	68 1b 3b 80 00       	push   $0x803b1b
  802a44:	68 89 00 00 00       	push   $0x89
  802a49:	68 d8 3a 80 00       	push   $0x803ad8
  802a4e:	e8 85 df ff ff       	call   8009d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802a53:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802a59:	eb 58                	jmp    802ab3 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802a5b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a61:	eb 50                	jmp    802ab3 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802a63:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a69:	eb 48                	jmp    802ab3 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a6b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802a70:	eb 41                	jmp    802ab3 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a72:	89 c3                	mov    %eax,%ebx
  802a74:	eb 3d                	jmp    802ab3 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a76:	89 c3                	mov    %eax,%ebx
  802a78:	eb 06                	jmp    802a80 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a7a:	89 c3                	mov    %eax,%ebx
  802a7c:	eb 02                	jmp    802a80 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a7e:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a80:	83 ec 0c             	sub    $0xc,%esp
  802a83:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a89:	e8 69 ea ff ff       	call   8014f7 <sys_env_destroy>
	close(fd);
  802a8e:	83 c4 04             	add    $0x4,%esp
  802a91:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a97:	e8 6c f3 ff ff       	call   801e08 <close>
	return r;
  802a9c:	83 c4 10             	add    $0x10,%esp
  802a9f:	eb 12                	jmp    802ab3 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802aa1:	83 ec 08             	sub    $0x8,%esp
  802aa4:	68 00 00 40 00       	push   $0x400000
  802aa9:	6a 00                	push   $0x0
  802aab:	e8 4b eb ff ff       	call   8015fb <sys_page_unmap>
  802ab0:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802ab3:	89 d8                	mov    %ebx,%eax
  802ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ab8:	5b                   	pop    %ebx
  802ab9:	5e                   	pop    %esi
  802aba:	5f                   	pop    %edi
  802abb:	5d                   	pop    %ebp
  802abc:	c3                   	ret    

00802abd <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802abd:	55                   	push   %ebp
  802abe:	89 e5                	mov    %esp,%ebp
  802ac0:	56                   	push   %esi
  802ac1:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ac2:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802ac5:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802aca:	eb 03                	jmp    802acf <spawnl+0x12>
		argc++;
  802acc:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802acf:	83 c2 04             	add    $0x4,%edx
  802ad2:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802ad6:	75 f4                	jne    802acc <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802ad8:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802adf:	83 e2 f0             	and    $0xfffffff0,%edx
  802ae2:	29 d4                	sub    %edx,%esp
  802ae4:	8d 54 24 03          	lea    0x3(%esp),%edx
  802ae8:	c1 ea 02             	shr    $0x2,%edx
  802aeb:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802af2:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802af7:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802afe:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802b05:	00 
  802b06:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b08:	b8 00 00 00 00       	mov    $0x0,%eax
  802b0d:	eb 0a                	jmp    802b19 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802b0f:	83 c0 01             	add    $0x1,%eax
  802b12:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802b16:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b19:	39 d0                	cmp    %edx,%eax
  802b1b:	75 f2                	jne    802b0f <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802b1d:	83 ec 08             	sub    $0x8,%esp
  802b20:	56                   	push   %esi
  802b21:	ff 75 08             	pushl  0x8(%ebp)
  802b24:	e8 53 fa ff ff       	call   80257c <spawn>
}
  802b29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b2c:	5b                   	pop    %ebx
  802b2d:	5e                   	pop    %esi
  802b2e:	5d                   	pop    %ebp
  802b2f:	c3                   	ret    

00802b30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b30:	55                   	push   %ebp
  802b31:	89 e5                	mov    %esp,%ebp
  802b33:	56                   	push   %esi
  802b34:	53                   	push   %ebx
  802b35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b38:	83 ec 0c             	sub    $0xc,%esp
  802b3b:	ff 75 08             	pushl  0x8(%ebp)
  802b3e:	e8 35 f1 ff ff       	call   801c78 <fd2data>
  802b43:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b45:	83 c4 08             	add    $0x8,%esp
  802b48:	68 5a 3b 80 00       	push   $0x803b5a
  802b4d:	53                   	push   %ebx
  802b4e:	e8 20 e6 ff ff       	call   801173 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b53:	8b 46 04             	mov    0x4(%esi),%eax
  802b56:	2b 06                	sub    (%esi),%eax
  802b58:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b5e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b65:	00 00 00 
	stat->st_dev = &devpipe;
  802b68:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b6f:	40 80 00 
	return 0;
}
  802b72:	b8 00 00 00 00       	mov    $0x0,%eax
  802b77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b7a:	5b                   	pop    %ebx
  802b7b:	5e                   	pop    %esi
  802b7c:	5d                   	pop    %ebp
  802b7d:	c3                   	ret    

00802b7e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b7e:	55                   	push   %ebp
  802b7f:	89 e5                	mov    %esp,%ebp
  802b81:	53                   	push   %ebx
  802b82:	83 ec 0c             	sub    $0xc,%esp
  802b85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b88:	53                   	push   %ebx
  802b89:	6a 00                	push   $0x0
  802b8b:	e8 6b ea ff ff       	call   8015fb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b90:	89 1c 24             	mov    %ebx,(%esp)
  802b93:	e8 e0 f0 ff ff       	call   801c78 <fd2data>
  802b98:	83 c4 08             	add    $0x8,%esp
  802b9b:	50                   	push   %eax
  802b9c:	6a 00                	push   $0x0
  802b9e:	e8 58 ea ff ff       	call   8015fb <sys_page_unmap>
}
  802ba3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ba6:	c9                   	leave  
  802ba7:	c3                   	ret    

00802ba8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802ba8:	55                   	push   %ebp
  802ba9:	89 e5                	mov    %esp,%ebp
  802bab:	57                   	push   %edi
  802bac:	56                   	push   %esi
  802bad:	53                   	push   %ebx
  802bae:	83 ec 1c             	sub    $0x1c,%esp
  802bb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802bb4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802bb6:	a1 24 54 80 00       	mov    0x805424,%eax
  802bbb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802bbe:	83 ec 0c             	sub    $0xc,%esp
  802bc1:	ff 75 e0             	pushl  -0x20(%ebp)
  802bc4:	e8 74 04 00 00       	call   80303d <pageref>
  802bc9:	89 c3                	mov    %eax,%ebx
  802bcb:	89 3c 24             	mov    %edi,(%esp)
  802bce:	e8 6a 04 00 00       	call   80303d <pageref>
  802bd3:	83 c4 10             	add    $0x10,%esp
  802bd6:	39 c3                	cmp    %eax,%ebx
  802bd8:	0f 94 c1             	sete   %cl
  802bdb:	0f b6 c9             	movzbl %cl,%ecx
  802bde:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802be1:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802be7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802bea:	39 ce                	cmp    %ecx,%esi
  802bec:	74 1b                	je     802c09 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802bee:	39 c3                	cmp    %eax,%ebx
  802bf0:	75 c4                	jne    802bb6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802bf2:	8b 42 58             	mov    0x58(%edx),%eax
  802bf5:	ff 75 e4             	pushl  -0x1c(%ebp)
  802bf8:	50                   	push   %eax
  802bf9:	56                   	push   %esi
  802bfa:	68 61 3b 80 00       	push   $0x803b61
  802bff:	e8 ad de ff ff       	call   800ab1 <cprintf>
  802c04:	83 c4 10             	add    $0x10,%esp
  802c07:	eb ad                	jmp    802bb6 <_pipeisclosed+0xe>
	}
}
  802c09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c0f:	5b                   	pop    %ebx
  802c10:	5e                   	pop    %esi
  802c11:	5f                   	pop    %edi
  802c12:	5d                   	pop    %ebp
  802c13:	c3                   	ret    

00802c14 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802c14:	55                   	push   %ebp
  802c15:	89 e5                	mov    %esp,%ebp
  802c17:	57                   	push   %edi
  802c18:	56                   	push   %esi
  802c19:	53                   	push   %ebx
  802c1a:	83 ec 28             	sub    $0x28,%esp
  802c1d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802c20:	56                   	push   %esi
  802c21:	e8 52 f0 ff ff       	call   801c78 <fd2data>
  802c26:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c28:	83 c4 10             	add    $0x10,%esp
  802c2b:	bf 00 00 00 00       	mov    $0x0,%edi
  802c30:	eb 4b                	jmp    802c7d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c32:	89 da                	mov    %ebx,%edx
  802c34:	89 f0                	mov    %esi,%eax
  802c36:	e8 6d ff ff ff       	call   802ba8 <_pipeisclosed>
  802c3b:	85 c0                	test   %eax,%eax
  802c3d:	75 48                	jne    802c87 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c3f:	e8 13 e9 ff ff       	call   801557 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c44:	8b 43 04             	mov    0x4(%ebx),%eax
  802c47:	8b 0b                	mov    (%ebx),%ecx
  802c49:	8d 51 20             	lea    0x20(%ecx),%edx
  802c4c:	39 d0                	cmp    %edx,%eax
  802c4e:	73 e2                	jae    802c32 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c53:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c57:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c5a:	89 c2                	mov    %eax,%edx
  802c5c:	c1 fa 1f             	sar    $0x1f,%edx
  802c5f:	89 d1                	mov    %edx,%ecx
  802c61:	c1 e9 1b             	shr    $0x1b,%ecx
  802c64:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802c67:	83 e2 1f             	and    $0x1f,%edx
  802c6a:	29 ca                	sub    %ecx,%edx
  802c6c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802c70:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c74:	83 c0 01             	add    $0x1,%eax
  802c77:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c7a:	83 c7 01             	add    $0x1,%edi
  802c7d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c80:	75 c2                	jne    802c44 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c82:	8b 45 10             	mov    0x10(%ebp),%eax
  802c85:	eb 05                	jmp    802c8c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c87:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c8f:	5b                   	pop    %ebx
  802c90:	5e                   	pop    %esi
  802c91:	5f                   	pop    %edi
  802c92:	5d                   	pop    %ebp
  802c93:	c3                   	ret    

00802c94 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c94:	55                   	push   %ebp
  802c95:	89 e5                	mov    %esp,%ebp
  802c97:	57                   	push   %edi
  802c98:	56                   	push   %esi
  802c99:	53                   	push   %ebx
  802c9a:	83 ec 18             	sub    $0x18,%esp
  802c9d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802ca0:	57                   	push   %edi
  802ca1:	e8 d2 ef ff ff       	call   801c78 <fd2data>
  802ca6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ca8:	83 c4 10             	add    $0x10,%esp
  802cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  802cb0:	eb 3d                	jmp    802cef <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802cb2:	85 db                	test   %ebx,%ebx
  802cb4:	74 04                	je     802cba <devpipe_read+0x26>
				return i;
  802cb6:	89 d8                	mov    %ebx,%eax
  802cb8:	eb 44                	jmp    802cfe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802cba:	89 f2                	mov    %esi,%edx
  802cbc:	89 f8                	mov    %edi,%eax
  802cbe:	e8 e5 fe ff ff       	call   802ba8 <_pipeisclosed>
  802cc3:	85 c0                	test   %eax,%eax
  802cc5:	75 32                	jne    802cf9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802cc7:	e8 8b e8 ff ff       	call   801557 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802ccc:	8b 06                	mov    (%esi),%eax
  802cce:	3b 46 04             	cmp    0x4(%esi),%eax
  802cd1:	74 df                	je     802cb2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802cd3:	99                   	cltd   
  802cd4:	c1 ea 1b             	shr    $0x1b,%edx
  802cd7:	01 d0                	add    %edx,%eax
  802cd9:	83 e0 1f             	and    $0x1f,%eax
  802cdc:	29 d0                	sub    %edx,%eax
  802cde:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ce6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802ce9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cec:	83 c3 01             	add    $0x1,%ebx
  802cef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802cf2:	75 d8                	jne    802ccc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cf4:	8b 45 10             	mov    0x10(%ebp),%eax
  802cf7:	eb 05                	jmp    802cfe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cf9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d01:	5b                   	pop    %ebx
  802d02:	5e                   	pop    %esi
  802d03:	5f                   	pop    %edi
  802d04:	5d                   	pop    %ebp
  802d05:	c3                   	ret    

00802d06 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802d06:	55                   	push   %ebp
  802d07:	89 e5                	mov    %esp,%ebp
  802d09:	56                   	push   %esi
  802d0a:	53                   	push   %ebx
  802d0b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802d0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d11:	50                   	push   %eax
  802d12:	e8 78 ef ff ff       	call   801c8f <fd_alloc>
  802d17:	83 c4 10             	add    $0x10,%esp
  802d1a:	89 c2                	mov    %eax,%edx
  802d1c:	85 c0                	test   %eax,%eax
  802d1e:	0f 88 2c 01 00 00    	js     802e50 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d24:	83 ec 04             	sub    $0x4,%esp
  802d27:	68 07 04 00 00       	push   $0x407
  802d2c:	ff 75 f4             	pushl  -0xc(%ebp)
  802d2f:	6a 00                	push   $0x0
  802d31:	e8 40 e8 ff ff       	call   801576 <sys_page_alloc>
  802d36:	83 c4 10             	add    $0x10,%esp
  802d39:	89 c2                	mov    %eax,%edx
  802d3b:	85 c0                	test   %eax,%eax
  802d3d:	0f 88 0d 01 00 00    	js     802e50 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d43:	83 ec 0c             	sub    $0xc,%esp
  802d46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d49:	50                   	push   %eax
  802d4a:	e8 40 ef ff ff       	call   801c8f <fd_alloc>
  802d4f:	89 c3                	mov    %eax,%ebx
  802d51:	83 c4 10             	add    $0x10,%esp
  802d54:	85 c0                	test   %eax,%eax
  802d56:	0f 88 e2 00 00 00    	js     802e3e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d5c:	83 ec 04             	sub    $0x4,%esp
  802d5f:	68 07 04 00 00       	push   $0x407
  802d64:	ff 75 f0             	pushl  -0x10(%ebp)
  802d67:	6a 00                	push   $0x0
  802d69:	e8 08 e8 ff ff       	call   801576 <sys_page_alloc>
  802d6e:	89 c3                	mov    %eax,%ebx
  802d70:	83 c4 10             	add    $0x10,%esp
  802d73:	85 c0                	test   %eax,%eax
  802d75:	0f 88 c3 00 00 00    	js     802e3e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d7b:	83 ec 0c             	sub    $0xc,%esp
  802d7e:	ff 75 f4             	pushl  -0xc(%ebp)
  802d81:	e8 f2 ee ff ff       	call   801c78 <fd2data>
  802d86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d88:	83 c4 0c             	add    $0xc,%esp
  802d8b:	68 07 04 00 00       	push   $0x407
  802d90:	50                   	push   %eax
  802d91:	6a 00                	push   $0x0
  802d93:	e8 de e7 ff ff       	call   801576 <sys_page_alloc>
  802d98:	89 c3                	mov    %eax,%ebx
  802d9a:	83 c4 10             	add    $0x10,%esp
  802d9d:	85 c0                	test   %eax,%eax
  802d9f:	0f 88 89 00 00 00    	js     802e2e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802da5:	83 ec 0c             	sub    $0xc,%esp
  802da8:	ff 75 f0             	pushl  -0x10(%ebp)
  802dab:	e8 c8 ee ff ff       	call   801c78 <fd2data>
  802db0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802db7:	50                   	push   %eax
  802db8:	6a 00                	push   $0x0
  802dba:	56                   	push   %esi
  802dbb:	6a 00                	push   $0x0
  802dbd:	e8 f7 e7 ff ff       	call   8015b9 <sys_page_map>
  802dc2:	89 c3                	mov    %eax,%ebx
  802dc4:	83 c4 20             	add    $0x20,%esp
  802dc7:	85 c0                	test   %eax,%eax
  802dc9:	78 55                	js     802e20 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802dcb:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dd4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dd9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802de0:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802de6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802de9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802df5:	83 ec 0c             	sub    $0xc,%esp
  802df8:	ff 75 f4             	pushl  -0xc(%ebp)
  802dfb:	e8 68 ee ff ff       	call   801c68 <fd2num>
  802e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e03:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802e05:	83 c4 04             	add    $0x4,%esp
  802e08:	ff 75 f0             	pushl  -0x10(%ebp)
  802e0b:	e8 58 ee ff ff       	call   801c68 <fd2num>
  802e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e13:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802e16:	83 c4 10             	add    $0x10,%esp
  802e19:	ba 00 00 00 00       	mov    $0x0,%edx
  802e1e:	eb 30                	jmp    802e50 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802e20:	83 ec 08             	sub    $0x8,%esp
  802e23:	56                   	push   %esi
  802e24:	6a 00                	push   $0x0
  802e26:	e8 d0 e7 ff ff       	call   8015fb <sys_page_unmap>
  802e2b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802e2e:	83 ec 08             	sub    $0x8,%esp
  802e31:	ff 75 f0             	pushl  -0x10(%ebp)
  802e34:	6a 00                	push   $0x0
  802e36:	e8 c0 e7 ff ff       	call   8015fb <sys_page_unmap>
  802e3b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802e3e:	83 ec 08             	sub    $0x8,%esp
  802e41:	ff 75 f4             	pushl  -0xc(%ebp)
  802e44:	6a 00                	push   $0x0
  802e46:	e8 b0 e7 ff ff       	call   8015fb <sys_page_unmap>
  802e4b:	83 c4 10             	add    $0x10,%esp
  802e4e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802e50:	89 d0                	mov    %edx,%eax
  802e52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e55:	5b                   	pop    %ebx
  802e56:	5e                   	pop    %esi
  802e57:	5d                   	pop    %ebp
  802e58:	c3                   	ret    

00802e59 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e59:	55                   	push   %ebp
  802e5a:	89 e5                	mov    %esp,%ebp
  802e5c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e62:	50                   	push   %eax
  802e63:	ff 75 08             	pushl  0x8(%ebp)
  802e66:	e8 73 ee ff ff       	call   801cde <fd_lookup>
  802e6b:	83 c4 10             	add    $0x10,%esp
  802e6e:	85 c0                	test   %eax,%eax
  802e70:	78 18                	js     802e8a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e72:	83 ec 0c             	sub    $0xc,%esp
  802e75:	ff 75 f4             	pushl  -0xc(%ebp)
  802e78:	e8 fb ed ff ff       	call   801c78 <fd2data>
	return _pipeisclosed(fd, p);
  802e7d:	89 c2                	mov    %eax,%edx
  802e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e82:	e8 21 fd ff ff       	call   802ba8 <_pipeisclosed>
  802e87:	83 c4 10             	add    $0x10,%esp
}
  802e8a:	c9                   	leave  
  802e8b:	c3                   	ret    

00802e8c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e8c:	55                   	push   %ebp
  802e8d:	89 e5                	mov    %esp,%ebp
  802e8f:	56                   	push   %esi
  802e90:	53                   	push   %ebx
  802e91:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e94:	85 f6                	test   %esi,%esi
  802e96:	75 16                	jne    802eae <wait+0x22>
  802e98:	68 79 3b 80 00       	push   $0x803b79
  802e9d:	68 78 34 80 00       	push   $0x803478
  802ea2:	6a 09                	push   $0x9
  802ea4:	68 84 3b 80 00       	push   $0x803b84
  802ea9:	e8 2a db ff ff       	call   8009d8 <_panic>
	e = &envs[ENVX(envid)];
  802eae:	89 f3                	mov    %esi,%ebx
  802eb0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802eb6:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802eb9:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802ebf:	eb 05                	jmp    802ec6 <wait+0x3a>
		sys_yield();
  802ec1:	e8 91 e6 ff ff       	call   801557 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ec6:	8b 43 48             	mov    0x48(%ebx),%eax
  802ec9:	39 c6                	cmp    %eax,%esi
  802ecb:	75 07                	jne    802ed4 <wait+0x48>
  802ecd:	8b 43 54             	mov    0x54(%ebx),%eax
  802ed0:	85 c0                	test   %eax,%eax
  802ed2:	75 ed                	jne    802ec1 <wait+0x35>
		sys_yield();
}
  802ed4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ed7:	5b                   	pop    %ebx
  802ed8:	5e                   	pop    %esi
  802ed9:	5d                   	pop    %ebp
  802eda:	c3                   	ret    

00802edb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802edb:	55                   	push   %ebp
  802edc:	89 e5                	mov    %esp,%ebp
  802ede:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  802ee1:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802ee8:	75 4c                	jne    802f36 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  802eea:	a1 24 54 80 00       	mov    0x805424,%eax
  802eef:	8b 40 48             	mov    0x48(%eax),%eax
  802ef2:	83 ec 04             	sub    $0x4,%esp
  802ef5:	6a 07                	push   $0x7
  802ef7:	68 00 f0 bf ee       	push   $0xeebff000
  802efc:	50                   	push   %eax
  802efd:	e8 74 e6 ff ff       	call   801576 <sys_page_alloc>
		if(retv != 0){
  802f02:	83 c4 10             	add    $0x10,%esp
  802f05:	85 c0                	test   %eax,%eax
  802f07:	74 14                	je     802f1d <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  802f09:	83 ec 04             	sub    $0x4,%esp
  802f0c:	68 90 3b 80 00       	push   $0x803b90
  802f11:	6a 27                	push   $0x27
  802f13:	68 bc 3b 80 00       	push   $0x803bbc
  802f18:	e8 bb da ff ff       	call   8009d8 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802f1d:	a1 24 54 80 00       	mov    0x805424,%eax
  802f22:	8b 40 48             	mov    0x48(%eax),%eax
  802f25:	83 ec 08             	sub    $0x8,%esp
  802f28:	68 40 2f 80 00       	push   $0x802f40
  802f2d:	50                   	push   %eax
  802f2e:	e8 8e e7 ff ff       	call   8016c1 <sys_env_set_pgfault_upcall>
  802f33:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f36:	8b 45 08             	mov    0x8(%ebp),%eax
  802f39:	a3 00 70 80 00       	mov    %eax,0x807000

}
  802f3e:	c9                   	leave  
  802f3f:	c3                   	ret    

00802f40 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f40:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f41:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f46:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  802f48:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  802f4b:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  802f4f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  802f54:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  802f58:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  802f5a:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  802f5d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  802f5e:	83 c4 04             	add    $0x4,%esp
	popfl
  802f61:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802f62:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f63:	c3                   	ret    

00802f64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f64:	55                   	push   %ebp
  802f65:	89 e5                	mov    %esp,%ebp
  802f67:	56                   	push   %esi
  802f68:	53                   	push   %ebx
  802f69:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802f6c:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  802f6f:	83 ec 0c             	sub    $0xc,%esp
  802f72:	ff 75 0c             	pushl  0xc(%ebp)
  802f75:	e8 ac e7 ff ff       	call   801726 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  802f7a:	83 c4 10             	add    $0x10,%esp
  802f7d:	85 f6                	test   %esi,%esi
  802f7f:	74 1c                	je     802f9d <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  802f81:	a1 24 54 80 00       	mov    0x805424,%eax
  802f86:	8b 40 78             	mov    0x78(%eax),%eax
  802f89:	89 06                	mov    %eax,(%esi)
  802f8b:	eb 10                	jmp    802f9d <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802f8d:	83 ec 0c             	sub    $0xc,%esp
  802f90:	68 ca 3b 80 00       	push   $0x803bca
  802f95:	e8 17 db ff ff       	call   800ab1 <cprintf>
  802f9a:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802f9d:	a1 24 54 80 00       	mov    0x805424,%eax
  802fa2:	8b 50 74             	mov    0x74(%eax),%edx
  802fa5:	85 d2                	test   %edx,%edx
  802fa7:	74 e4                	je     802f8d <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  802fa9:	85 db                	test   %ebx,%ebx
  802fab:	74 05                	je     802fb2 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802fad:	8b 40 74             	mov    0x74(%eax),%eax
  802fb0:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802fb2:	a1 24 54 80 00       	mov    0x805424,%eax
  802fb7:	8b 40 70             	mov    0x70(%eax),%eax

}
  802fba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fbd:	5b                   	pop    %ebx
  802fbe:	5e                   	pop    %esi
  802fbf:	5d                   	pop    %ebp
  802fc0:	c3                   	ret    

00802fc1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fc1:	55                   	push   %ebp
  802fc2:	89 e5                	mov    %esp,%ebp
  802fc4:	57                   	push   %edi
  802fc5:	56                   	push   %esi
  802fc6:	53                   	push   %ebx
  802fc7:	83 ec 0c             	sub    $0xc,%esp
  802fca:	8b 7d 08             	mov    0x8(%ebp),%edi
  802fcd:	8b 75 0c             	mov    0xc(%ebp),%esi
  802fd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  802fd3:	85 db                	test   %ebx,%ebx
  802fd5:	75 13                	jne    802fea <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  802fd7:	6a 00                	push   $0x0
  802fd9:	68 00 00 c0 ee       	push   $0xeec00000
  802fde:	56                   	push   %esi
  802fdf:	57                   	push   %edi
  802fe0:	e8 1e e7 ff ff       	call   801703 <sys_ipc_try_send>
  802fe5:	83 c4 10             	add    $0x10,%esp
  802fe8:	eb 0e                	jmp    802ff8 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  802fea:	ff 75 14             	pushl  0x14(%ebp)
  802fed:	53                   	push   %ebx
  802fee:	56                   	push   %esi
  802fef:	57                   	push   %edi
  802ff0:	e8 0e e7 ff ff       	call   801703 <sys_ipc_try_send>
  802ff5:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  802ff8:	85 c0                	test   %eax,%eax
  802ffa:	75 d7                	jne    802fd3 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  802ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fff:	5b                   	pop    %ebx
  803000:	5e                   	pop    %esi
  803001:	5f                   	pop    %edi
  803002:	5d                   	pop    %ebp
  803003:	c3                   	ret    

00803004 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803004:	55                   	push   %ebp
  803005:	89 e5                	mov    %esp,%ebp
  803007:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80300a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80300f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  803012:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803018:	8b 52 50             	mov    0x50(%edx),%edx
  80301b:	39 ca                	cmp    %ecx,%edx
  80301d:	75 0d                	jne    80302c <ipc_find_env+0x28>
			return envs[i].env_id;
  80301f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  803022:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803027:	8b 40 48             	mov    0x48(%eax),%eax
  80302a:	eb 0f                	jmp    80303b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80302c:	83 c0 01             	add    $0x1,%eax
  80302f:	3d 00 04 00 00       	cmp    $0x400,%eax
  803034:	75 d9                	jne    80300f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803036:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80303b:	5d                   	pop    %ebp
  80303c:	c3                   	ret    

0080303d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80303d:	55                   	push   %ebp
  80303e:	89 e5                	mov    %esp,%ebp
  803040:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803043:	89 d0                	mov    %edx,%eax
  803045:	c1 e8 16             	shr    $0x16,%eax
  803048:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80304f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803054:	f6 c1 01             	test   $0x1,%cl
  803057:	74 1d                	je     803076 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803059:	c1 ea 0c             	shr    $0xc,%edx
  80305c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803063:	f6 c2 01             	test   $0x1,%dl
  803066:	74 0e                	je     803076 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803068:	c1 ea 0c             	shr    $0xc,%edx
  80306b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803072:	ef 
  803073:	0f b7 c0             	movzwl %ax,%eax
}
  803076:	5d                   	pop    %ebp
  803077:	c3                   	ret    
  803078:	66 90                	xchg   %ax,%ax
  80307a:	66 90                	xchg   %ax,%ax
  80307c:	66 90                	xchg   %ax,%ax
  80307e:	66 90                	xchg   %ax,%ax

00803080 <__udivdi3>:
  803080:	55                   	push   %ebp
  803081:	57                   	push   %edi
  803082:	56                   	push   %esi
  803083:	53                   	push   %ebx
  803084:	83 ec 1c             	sub    $0x1c,%esp
  803087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80308b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80308f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803097:	85 f6                	test   %esi,%esi
  803099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80309d:	89 ca                	mov    %ecx,%edx
  80309f:	89 f8                	mov    %edi,%eax
  8030a1:	75 3d                	jne    8030e0 <__udivdi3+0x60>
  8030a3:	39 cf                	cmp    %ecx,%edi
  8030a5:	0f 87 c5 00 00 00    	ja     803170 <__udivdi3+0xf0>
  8030ab:	85 ff                	test   %edi,%edi
  8030ad:	89 fd                	mov    %edi,%ebp
  8030af:	75 0b                	jne    8030bc <__udivdi3+0x3c>
  8030b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8030b6:	31 d2                	xor    %edx,%edx
  8030b8:	f7 f7                	div    %edi
  8030ba:	89 c5                	mov    %eax,%ebp
  8030bc:	89 c8                	mov    %ecx,%eax
  8030be:	31 d2                	xor    %edx,%edx
  8030c0:	f7 f5                	div    %ebp
  8030c2:	89 c1                	mov    %eax,%ecx
  8030c4:	89 d8                	mov    %ebx,%eax
  8030c6:	89 cf                	mov    %ecx,%edi
  8030c8:	f7 f5                	div    %ebp
  8030ca:	89 c3                	mov    %eax,%ebx
  8030cc:	89 d8                	mov    %ebx,%eax
  8030ce:	89 fa                	mov    %edi,%edx
  8030d0:	83 c4 1c             	add    $0x1c,%esp
  8030d3:	5b                   	pop    %ebx
  8030d4:	5e                   	pop    %esi
  8030d5:	5f                   	pop    %edi
  8030d6:	5d                   	pop    %ebp
  8030d7:	c3                   	ret    
  8030d8:	90                   	nop
  8030d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030e0:	39 ce                	cmp    %ecx,%esi
  8030e2:	77 74                	ja     803158 <__udivdi3+0xd8>
  8030e4:	0f bd fe             	bsr    %esi,%edi
  8030e7:	83 f7 1f             	xor    $0x1f,%edi
  8030ea:	0f 84 98 00 00 00    	je     803188 <__udivdi3+0x108>
  8030f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8030f5:	89 f9                	mov    %edi,%ecx
  8030f7:	89 c5                	mov    %eax,%ebp
  8030f9:	29 fb                	sub    %edi,%ebx
  8030fb:	d3 e6                	shl    %cl,%esi
  8030fd:	89 d9                	mov    %ebx,%ecx
  8030ff:	d3 ed                	shr    %cl,%ebp
  803101:	89 f9                	mov    %edi,%ecx
  803103:	d3 e0                	shl    %cl,%eax
  803105:	09 ee                	or     %ebp,%esi
  803107:	89 d9                	mov    %ebx,%ecx
  803109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80310d:	89 d5                	mov    %edx,%ebp
  80310f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803113:	d3 ed                	shr    %cl,%ebp
  803115:	89 f9                	mov    %edi,%ecx
  803117:	d3 e2                	shl    %cl,%edx
  803119:	89 d9                	mov    %ebx,%ecx
  80311b:	d3 e8                	shr    %cl,%eax
  80311d:	09 c2                	or     %eax,%edx
  80311f:	89 d0                	mov    %edx,%eax
  803121:	89 ea                	mov    %ebp,%edx
  803123:	f7 f6                	div    %esi
  803125:	89 d5                	mov    %edx,%ebp
  803127:	89 c3                	mov    %eax,%ebx
  803129:	f7 64 24 0c          	mull   0xc(%esp)
  80312d:	39 d5                	cmp    %edx,%ebp
  80312f:	72 10                	jb     803141 <__udivdi3+0xc1>
  803131:	8b 74 24 08          	mov    0x8(%esp),%esi
  803135:	89 f9                	mov    %edi,%ecx
  803137:	d3 e6                	shl    %cl,%esi
  803139:	39 c6                	cmp    %eax,%esi
  80313b:	73 07                	jae    803144 <__udivdi3+0xc4>
  80313d:	39 d5                	cmp    %edx,%ebp
  80313f:	75 03                	jne    803144 <__udivdi3+0xc4>
  803141:	83 eb 01             	sub    $0x1,%ebx
  803144:	31 ff                	xor    %edi,%edi
  803146:	89 d8                	mov    %ebx,%eax
  803148:	89 fa                	mov    %edi,%edx
  80314a:	83 c4 1c             	add    $0x1c,%esp
  80314d:	5b                   	pop    %ebx
  80314e:	5e                   	pop    %esi
  80314f:	5f                   	pop    %edi
  803150:	5d                   	pop    %ebp
  803151:	c3                   	ret    
  803152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803158:	31 ff                	xor    %edi,%edi
  80315a:	31 db                	xor    %ebx,%ebx
  80315c:	89 d8                	mov    %ebx,%eax
  80315e:	89 fa                	mov    %edi,%edx
  803160:	83 c4 1c             	add    $0x1c,%esp
  803163:	5b                   	pop    %ebx
  803164:	5e                   	pop    %esi
  803165:	5f                   	pop    %edi
  803166:	5d                   	pop    %ebp
  803167:	c3                   	ret    
  803168:	90                   	nop
  803169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803170:	89 d8                	mov    %ebx,%eax
  803172:	f7 f7                	div    %edi
  803174:	31 ff                	xor    %edi,%edi
  803176:	89 c3                	mov    %eax,%ebx
  803178:	89 d8                	mov    %ebx,%eax
  80317a:	89 fa                	mov    %edi,%edx
  80317c:	83 c4 1c             	add    $0x1c,%esp
  80317f:	5b                   	pop    %ebx
  803180:	5e                   	pop    %esi
  803181:	5f                   	pop    %edi
  803182:	5d                   	pop    %ebp
  803183:	c3                   	ret    
  803184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803188:	39 ce                	cmp    %ecx,%esi
  80318a:	72 0c                	jb     803198 <__udivdi3+0x118>
  80318c:	31 db                	xor    %ebx,%ebx
  80318e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803192:	0f 87 34 ff ff ff    	ja     8030cc <__udivdi3+0x4c>
  803198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80319d:	e9 2a ff ff ff       	jmp    8030cc <__udivdi3+0x4c>
  8031a2:	66 90                	xchg   %ax,%ax
  8031a4:	66 90                	xchg   %ax,%ax
  8031a6:	66 90                	xchg   %ax,%ax
  8031a8:	66 90                	xchg   %ax,%ax
  8031aa:	66 90                	xchg   %ax,%ax
  8031ac:	66 90                	xchg   %ax,%ax
  8031ae:	66 90                	xchg   %ax,%ax

008031b0 <__umoddi3>:
  8031b0:	55                   	push   %ebp
  8031b1:	57                   	push   %edi
  8031b2:	56                   	push   %esi
  8031b3:	53                   	push   %ebx
  8031b4:	83 ec 1c             	sub    $0x1c,%esp
  8031b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8031bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8031bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8031c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8031c7:	85 d2                	test   %edx,%edx
  8031c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8031cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8031d1:	89 f3                	mov    %esi,%ebx
  8031d3:	89 3c 24             	mov    %edi,(%esp)
  8031d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031da:	75 1c                	jne    8031f8 <__umoddi3+0x48>
  8031dc:	39 f7                	cmp    %esi,%edi
  8031de:	76 50                	jbe    803230 <__umoddi3+0x80>
  8031e0:	89 c8                	mov    %ecx,%eax
  8031e2:	89 f2                	mov    %esi,%edx
  8031e4:	f7 f7                	div    %edi
  8031e6:	89 d0                	mov    %edx,%eax
  8031e8:	31 d2                	xor    %edx,%edx
  8031ea:	83 c4 1c             	add    $0x1c,%esp
  8031ed:	5b                   	pop    %ebx
  8031ee:	5e                   	pop    %esi
  8031ef:	5f                   	pop    %edi
  8031f0:	5d                   	pop    %ebp
  8031f1:	c3                   	ret    
  8031f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031f8:	39 f2                	cmp    %esi,%edx
  8031fa:	89 d0                	mov    %edx,%eax
  8031fc:	77 52                	ja     803250 <__umoddi3+0xa0>
  8031fe:	0f bd ea             	bsr    %edx,%ebp
  803201:	83 f5 1f             	xor    $0x1f,%ebp
  803204:	75 5a                	jne    803260 <__umoddi3+0xb0>
  803206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80320a:	0f 82 e0 00 00 00    	jb     8032f0 <__umoddi3+0x140>
  803210:	39 0c 24             	cmp    %ecx,(%esp)
  803213:	0f 86 d7 00 00 00    	jbe    8032f0 <__umoddi3+0x140>
  803219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80321d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803221:	83 c4 1c             	add    $0x1c,%esp
  803224:	5b                   	pop    %ebx
  803225:	5e                   	pop    %esi
  803226:	5f                   	pop    %edi
  803227:	5d                   	pop    %ebp
  803228:	c3                   	ret    
  803229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803230:	85 ff                	test   %edi,%edi
  803232:	89 fd                	mov    %edi,%ebp
  803234:	75 0b                	jne    803241 <__umoddi3+0x91>
  803236:	b8 01 00 00 00       	mov    $0x1,%eax
  80323b:	31 d2                	xor    %edx,%edx
  80323d:	f7 f7                	div    %edi
  80323f:	89 c5                	mov    %eax,%ebp
  803241:	89 f0                	mov    %esi,%eax
  803243:	31 d2                	xor    %edx,%edx
  803245:	f7 f5                	div    %ebp
  803247:	89 c8                	mov    %ecx,%eax
  803249:	f7 f5                	div    %ebp
  80324b:	89 d0                	mov    %edx,%eax
  80324d:	eb 99                	jmp    8031e8 <__umoddi3+0x38>
  80324f:	90                   	nop
  803250:	89 c8                	mov    %ecx,%eax
  803252:	89 f2                	mov    %esi,%edx
  803254:	83 c4 1c             	add    $0x1c,%esp
  803257:	5b                   	pop    %ebx
  803258:	5e                   	pop    %esi
  803259:	5f                   	pop    %edi
  80325a:	5d                   	pop    %ebp
  80325b:	c3                   	ret    
  80325c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803260:	8b 34 24             	mov    (%esp),%esi
  803263:	bf 20 00 00 00       	mov    $0x20,%edi
  803268:	89 e9                	mov    %ebp,%ecx
  80326a:	29 ef                	sub    %ebp,%edi
  80326c:	d3 e0                	shl    %cl,%eax
  80326e:	89 f9                	mov    %edi,%ecx
  803270:	89 f2                	mov    %esi,%edx
  803272:	d3 ea                	shr    %cl,%edx
  803274:	89 e9                	mov    %ebp,%ecx
  803276:	09 c2                	or     %eax,%edx
  803278:	89 d8                	mov    %ebx,%eax
  80327a:	89 14 24             	mov    %edx,(%esp)
  80327d:	89 f2                	mov    %esi,%edx
  80327f:	d3 e2                	shl    %cl,%edx
  803281:	89 f9                	mov    %edi,%ecx
  803283:	89 54 24 04          	mov    %edx,0x4(%esp)
  803287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80328b:	d3 e8                	shr    %cl,%eax
  80328d:	89 e9                	mov    %ebp,%ecx
  80328f:	89 c6                	mov    %eax,%esi
  803291:	d3 e3                	shl    %cl,%ebx
  803293:	89 f9                	mov    %edi,%ecx
  803295:	89 d0                	mov    %edx,%eax
  803297:	d3 e8                	shr    %cl,%eax
  803299:	89 e9                	mov    %ebp,%ecx
  80329b:	09 d8                	or     %ebx,%eax
  80329d:	89 d3                	mov    %edx,%ebx
  80329f:	89 f2                	mov    %esi,%edx
  8032a1:	f7 34 24             	divl   (%esp)
  8032a4:	89 d6                	mov    %edx,%esi
  8032a6:	d3 e3                	shl    %cl,%ebx
  8032a8:	f7 64 24 04          	mull   0x4(%esp)
  8032ac:	39 d6                	cmp    %edx,%esi
  8032ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032b2:	89 d1                	mov    %edx,%ecx
  8032b4:	89 c3                	mov    %eax,%ebx
  8032b6:	72 08                	jb     8032c0 <__umoddi3+0x110>
  8032b8:	75 11                	jne    8032cb <__umoddi3+0x11b>
  8032ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8032be:	73 0b                	jae    8032cb <__umoddi3+0x11b>
  8032c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8032c4:	1b 14 24             	sbb    (%esp),%edx
  8032c7:	89 d1                	mov    %edx,%ecx
  8032c9:	89 c3                	mov    %eax,%ebx
  8032cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8032cf:	29 da                	sub    %ebx,%edx
  8032d1:	19 ce                	sbb    %ecx,%esi
  8032d3:	89 f9                	mov    %edi,%ecx
  8032d5:	89 f0                	mov    %esi,%eax
  8032d7:	d3 e0                	shl    %cl,%eax
  8032d9:	89 e9                	mov    %ebp,%ecx
  8032db:	d3 ea                	shr    %cl,%edx
  8032dd:	89 e9                	mov    %ebp,%ecx
  8032df:	d3 ee                	shr    %cl,%esi
  8032e1:	09 d0                	or     %edx,%eax
  8032e3:	89 f2                	mov    %esi,%edx
  8032e5:	83 c4 1c             	add    $0x1c,%esp
  8032e8:	5b                   	pop    %ebx
  8032e9:	5e                   	pop    %esi
  8032ea:	5f                   	pop    %edi
  8032eb:	5d                   	pop    %ebp
  8032ec:	c3                   	ret    
  8032ed:	8d 76 00             	lea    0x0(%esi),%esi
  8032f0:	29 f9                	sub    %edi,%ecx
  8032f2:	19 d6                	sbb    %edx,%esi
  8032f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8032fc:	e9 18 ff ff ff       	jmp    803219 <__umoddi3+0x69>
