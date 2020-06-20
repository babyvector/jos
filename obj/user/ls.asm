
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 c2 22 80 00       	push   $0x8022c2
  80005f:	e8 ae 19 00 00       	call   801a12 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 28 23 80 00       	mov    $0x802328,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 15 09 00 00       	call   800993 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 28 23 80 00       	mov    $0x802328,%edx
  80008b:	b8 c0 22 80 00       	mov    $0x8022c0,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 cb 22 80 00       	push   $0x8022cb
  80009d:	e8 70 19 00 00       	call   801a12 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 55 27 80 00       	push   $0x802755
  8000b0:	e8 5d 19 00 00       	call   801a12 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 c0 22 80 00       	push   $0x8022c0
  8000cf:	e8 3e 19 00 00       	call   801a12 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 27 23 80 00       	push   $0x802327
  8000df:	e8 2e 19 00 00       	call   801a12 <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 6f 17 00 00       	call   801874 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 d0 22 80 00       	push   $0x8022d0
  800118:	6a 1d                	push   $0x1d
  80011a:	68 dc 22 80 00       	push   $0x8022dc
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 1d 13 00 00       	call   801481 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 e6 22 80 00       	push   $0x8022e6
  800178:	6a 22                	push   $0x22
  80017a:	68 dc 22 80 00       	push   $0x8022dc
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 2c 23 80 00       	push   $0x80232c
  800192:	6a 24                	push   $0x24
  800194:	68 dc 22 80 00       	push   $0x8022dc
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 c6 14 00 00       	call   801686 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 01 23 80 00       	push   $0x802301
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 dc 22 80 00       	push   $0x8022dc
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 0d 23 80 00       	push   $0x80230d
  800225:	e8 e8 17 00 00       	call   801a12 <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 73 0d 00 00       	call   800fc0 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 74 0d 00 00       	call   800ff0 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 28 23 80 00       	push   $0x802328
  800296:	68 c0 22 80 00       	push   $0x8022c0
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 bd 0a 00 00       	call   800d91 <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 ca 0f 00 00       	call   8012df <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 31 0a 00 00       	call   800d50 <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 5a 0a 00 00       	call   800d91 <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 58 23 80 00       	push   $0x802358
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 79 09 00 00       	call   800d13 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 54 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 1e 09 00 00       	call   800d13 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 bb 1b 00 00       	call   802020 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 a8 1c 00 00       	call   802150 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 7b 23 80 00 	movsbl 0x80237b(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 22                	jmp    8004f8 <getuint+0x38>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 10                	je     8004ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	eb 0e                	jmp    8004f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800500:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800504:	8b 10                	mov    (%eax),%edx
  800506:	3b 50 04             	cmp    0x4(%eax),%edx
  800509:	73 0a                	jae    800515 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	88 02                	mov    %al,(%edx)
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 2c             	sub    $0x2c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	eb 12                	jmp    80055a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 d3 03 00 00    	je     800923 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 e2                	jne    800548 <vprintfmt+0x14>
  800566:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800571:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800578:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	eb 07                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800589:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8d 47 01             	lea    0x1(%edi),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	0f b6 07             	movzbl (%edi),%eax
  800596:	0f b6 c8             	movzbl %al,%ecx
  800599:	83 e8 23             	sub    $0x23,%eax
  80059c:	3c 55                	cmp    $0x55,%al
  80059e:	0f 87 64 03 00 00    	ja     800908 <vprintfmt+0x3d4>
  8005a4:	0f b6 c0             	movzbl %al,%eax
  8005a7:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b5:	eb d6                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005cf:	83 fa 09             	cmp    $0x9,%edx
  8005d2:	77 39                	ja     80060d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d7:	eb e9                	jmp    8005c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ea:	eb 27                	jmp    800613 <vprintfmt+0xdf>
  8005ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	0f 49 c8             	cmovns %eax,%ecx
  8005f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ff:	eb 8c                	jmp    80058d <vprintfmt+0x59>
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800604:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060b:	eb 80                	jmp    80058d <vprintfmt+0x59>
  80060d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800610:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800613:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800617:	0f 89 70 ff ff ff    	jns    80058d <vprintfmt+0x59>
				width = precision, precision = -1;
  80061d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800620:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800623:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80062a:	e9 5e ff ff ff       	jmp    80058d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800635:	e9 53 ff ff ff       	jmp    80058d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	ff 30                	pushl  (%eax)
  800649:	ff d6                	call   *%esi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800651:	e9 04 ff ff ff       	jmp    80055a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 0f             	cmp    $0xf,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x142>
  80066b:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 18                	jne    80068e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 93 23 80 00       	push   $0x802393
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 94 fe ff ff       	call   800517 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800689:	e9 cc fe ff ff       	jmp    80055a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 55 27 80 00       	push   $0x802755
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 7c fe ff ff       	call   800517 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	e9 b4 fe ff ff       	jmp    80055a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	b8 8c 23 80 00       	mov    $0x80238c,%eax
  8006b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bf:	0f 8e 94 00 00 00    	jle    800759 <vprintfmt+0x225>
  8006c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c9:	0f 84 98 00 00 00    	je     800767 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 c8             	pushl  -0x38(%ebp)
  8006d5:	57                   	push   %edi
  8006d6:	e8 d0 02 00 00       	call   8009ab <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	eb 0f                	jmp    800703 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 ff                	test   %edi,%edi
  800705:	7f ed                	jg     8006f4 <vprintfmt+0x1c0>
  800707:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	89 cb                	mov    %ecx,%ebx
  800724:	eb 4d                	jmp    800773 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072a:	74 1b                	je     800747 <vprintfmt+0x213>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 10                	jbe    800747 <vprintfmt+0x213>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff 55 08             	call   *0x8(%ebp)
  800751:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	eb 1a                	jmp    800773 <vprintfmt+0x23f>
  800759:	89 75 08             	mov    %esi,0x8(%ebp)
  80075c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800765:	eb 0c                	jmp    800773 <vprintfmt+0x23f>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	83 c7 01             	add    $0x1,%edi
  800776:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077a:	0f be d0             	movsbl %al,%edx
  80077d:	85 d2                	test   %edx,%edx
  80077f:	74 23                	je     8007a4 <vprintfmt+0x270>
  800781:	85 f6                	test   %esi,%esi
  800783:	78 a1                	js     800726 <vprintfmt+0x1f2>
  800785:	83 ee 01             	sub    $0x1,%esi
  800788:	79 9c                	jns    800726 <vprintfmt+0x1f2>
  80078a:	89 df                	mov    %ebx,%edi
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800792:	eb 18                	jmp    8007ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 20                	push   $0x20
  80079a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079c:	83 ef 01             	sub    $0x1,%edi
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 08                	jmp    8007ac <vprintfmt+0x278>
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	85 ff                	test   %edi,%edi
  8007ae:	7f e4                	jg     800794 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b3:	e9 a2 fd ff ff       	jmp    80055a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b8:	83 fa 01             	cmp    $0x1,%edx
  8007bb:	7e 16                	jle    8007d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 08             	lea    0x8(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 50 04             	mov    0x4(%eax),%edx
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007ce:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007d1:	eb 32                	jmp    800805 <vprintfmt+0x2d1>
	else if (lflag)
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 18                	je     8007ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007e5:	89 c1                	mov    %eax,%ecx
  8007e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007ed:	eb 16                	jmp    800805 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800805:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800808:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80080b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800811:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800816:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80081a:	0f 89 b0 00 00 00    	jns    8008d0 <vprintfmt+0x39c>
				putch('-', putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	6a 2d                	push   $0x2d
  800826:	ff d6                	call   *%esi
				num = -(long long) num;
  800828:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80082b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80082e:	f7 d8                	neg    %eax
  800830:	83 d2 00             	adc    $0x0,%edx
  800833:	f7 da                	neg    %edx
  800835:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800838:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80083b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80083e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800843:	e9 88 00 00 00       	jmp    8008d0 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
  80084b:	e8 70 fc ff ff       	call   8004c0 <getuint>
  800850:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800853:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80085b:	eb 73                	jmp    8008d0 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80085d:	8d 45 14             	lea    0x14(%ebp),%eax
  800860:	e8 5b fc ff ff       	call   8004c0 <getuint>
  800865:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800868:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	53                   	push   %ebx
  80086f:	6a 58                	push   $0x58
  800871:	ff d6                	call   *%esi
			putch('X', putdat);
  800873:	83 c4 08             	add    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	6a 58                	push   $0x58
  800879:	ff d6                	call   *%esi
			putch('X', putdat);
  80087b:	83 c4 08             	add    $0x8,%esp
  80087e:	53                   	push   %ebx
  80087f:	6a 58                	push   $0x58
  800881:	ff d6                	call   *%esi
			goto number;
  800883:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800886:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80088b:	eb 43                	jmp    8008d0 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	6a 30                	push   $0x30
  800893:	ff d6                	call   *%esi
			putch('x', putdat);
  800895:	83 c4 08             	add    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	6a 78                	push   $0x78
  80089b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8d 50 04             	lea    0x4(%eax),%edx
  8008a3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008a6:	8b 00                	mov    (%eax),%eax
  8008a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008bb:	eb 13                	jmp    8008d0 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c0:	e8 fb fb ff ff       	call   8004c0 <getuint>
  8008c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d0:	83 ec 0c             	sub    $0xc,%esp
  8008d3:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008d7:	52                   	push   %edx
  8008d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008db:	50                   	push   %eax
  8008dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8008df:	ff 75 d8             	pushl  -0x28(%ebp)
  8008e2:	89 da                	mov    %ebx,%edx
  8008e4:	89 f0                	mov    %esi,%eax
  8008e6:	e8 26 fb ff ff       	call   800411 <printnum>
			break;
  8008eb:	83 c4 20             	add    $0x20,%esp
  8008ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f1:	e9 64 fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	51                   	push   %ecx
  8008fb:	ff d6                	call   *%esi
			break;
  8008fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800903:	e9 52 fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	53                   	push   %ebx
  80090c:	6a 25                	push   $0x25
  80090e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	eb 03                	jmp    800918 <vprintfmt+0x3e4>
  800915:	83 ef 01             	sub    $0x1,%edi
  800918:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80091c:	75 f7                	jne    800915 <vprintfmt+0x3e1>
  80091e:	e9 37 fc ff ff       	jmp    80055a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800923:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	83 ec 18             	sub    $0x18,%esp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800937:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800948:	85 c0                	test   %eax,%eax
  80094a:	74 26                	je     800972 <vsnprintf+0x47>
  80094c:	85 d2                	test   %edx,%edx
  80094e:	7e 22                	jle    800972 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800950:	ff 75 14             	pushl  0x14(%ebp)
  800953:	ff 75 10             	pushl  0x10(%ebp)
  800956:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800959:	50                   	push   %eax
  80095a:	68 fa 04 80 00       	push   $0x8004fa
  80095f:	e8 d0 fb ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800964:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800967:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	eb 05                	jmp    800977 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800972:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800982:	50                   	push   %eax
  800983:	ff 75 10             	pushl  0x10(%ebp)
  800986:	ff 75 0c             	pushl  0xc(%ebp)
  800989:	ff 75 08             	pushl  0x8(%ebp)
  80098c:	e8 9a ff ff ff       	call   80092b <vsnprintf>
	va_end(ap);

	return rc;
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
  80099e:	eb 03                	jmp    8009a3 <strlen+0x10>
		n++;
  8009a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a7:	75 f7                	jne    8009a0 <strlen+0xd>
		n++;
	return n;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b9:	eb 03                	jmp    8009be <strnlen+0x13>
		n++;
  8009bb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009be:	39 c2                	cmp    %eax,%edx
  8009c0:	74 08                	je     8009ca <strnlen+0x1f>
  8009c2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c6:	75 f3                	jne    8009bb <strnlen+0x10>
  8009c8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d6:	89 c2                	mov    %eax,%edx
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	83 c1 01             	add    $0x1,%ecx
  8009de:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e5:	84 db                	test   %bl,%bl
  8009e7:	75 ef                	jne    8009d8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	53                   	push   %ebx
  8009f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f3:	53                   	push   %ebx
  8009f4:	e8 9a ff ff ff       	call   800993 <strlen>
  8009f9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fc:	ff 75 0c             	pushl  0xc(%ebp)
  8009ff:	01 d8                	add    %ebx,%eax
  800a01:	50                   	push   %eax
  800a02:	e8 c5 ff ff ff       	call   8009cc <strcpy>
	return dst;
}
  800a07:	89 d8                	mov    %ebx,%eax
  800a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 75 08             	mov    0x8(%ebp),%esi
  800a16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a19:	89 f3                	mov    %esi,%ebx
  800a1b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1e:	89 f2                	mov    %esi,%edx
  800a20:	eb 0f                	jmp    800a31 <strncpy+0x23>
		*dst++ = *src;
  800a22:	83 c2 01             	add    $0x1,%edx
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2b:	80 39 01             	cmpb   $0x1,(%ecx)
  800a2e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a31:	39 da                	cmp    %ebx,%edx
  800a33:	75 ed                	jne    800a22 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a35:	89 f0                	mov    %esi,%eax
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 75 08             	mov    0x8(%ebp),%esi
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a46:	8b 55 10             	mov    0x10(%ebp),%edx
  800a49:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4b:	85 d2                	test   %edx,%edx
  800a4d:	74 21                	je     800a70 <strlcpy+0x35>
  800a4f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a53:	89 f2                	mov    %esi,%edx
  800a55:	eb 09                	jmp    800a60 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a60:	39 c2                	cmp    %eax,%edx
  800a62:	74 09                	je     800a6d <strlcpy+0x32>
  800a64:	0f b6 19             	movzbl (%ecx),%ebx
  800a67:	84 db                	test   %bl,%bl
  800a69:	75 ec                	jne    800a57 <strlcpy+0x1c>
  800a6b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a70:	29 f0                	sub    %esi,%eax
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7f:	eb 06                	jmp    800a87 <strcmp+0x11>
		p++, q++;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a87:	0f b6 01             	movzbl (%ecx),%eax
  800a8a:	84 c0                	test   %al,%al
  800a8c:	74 04                	je     800a92 <strcmp+0x1c>
  800a8e:	3a 02                	cmp    (%edx),%al
  800a90:	74 ef                	je     800a81 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a92:	0f b6 c0             	movzbl %al,%eax
  800a95:	0f b6 12             	movzbl (%edx),%edx
  800a98:	29 d0                	sub    %edx,%eax
}
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	53                   	push   %ebx
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa6:	89 c3                	mov    %eax,%ebx
  800aa8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aab:	eb 06                	jmp    800ab3 <strncmp+0x17>
		n--, p++, q++;
  800aad:	83 c0 01             	add    $0x1,%eax
  800ab0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab3:	39 d8                	cmp    %ebx,%eax
  800ab5:	74 15                	je     800acc <strncmp+0x30>
  800ab7:	0f b6 08             	movzbl (%eax),%ecx
  800aba:	84 c9                	test   %cl,%cl
  800abc:	74 04                	je     800ac2 <strncmp+0x26>
  800abe:	3a 0a                	cmp    (%edx),%cl
  800ac0:	74 eb                	je     800aad <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac2:	0f b6 00             	movzbl (%eax),%eax
  800ac5:	0f b6 12             	movzbl (%edx),%edx
  800ac8:	29 d0                	sub    %edx,%eax
  800aca:	eb 05                	jmp    800ad1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ade:	eb 07                	jmp    800ae7 <strchr+0x13>
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 0f                	je     800af3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae4:	83 c0 01             	add    $0x1,%eax
  800ae7:	0f b6 10             	movzbl (%eax),%edx
  800aea:	84 d2                	test   %dl,%dl
  800aec:	75 f2                	jne    800ae0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aff:	eb 03                	jmp    800b04 <strfind+0xf>
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b07:	38 ca                	cmp    %cl,%dl
  800b09:	74 04                	je     800b0f <strfind+0x1a>
  800b0b:	84 d2                	test   %dl,%dl
  800b0d:	75 f2                	jne    800b01 <strfind+0xc>
			break;
	return (char *) s;
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1d:	85 c9                	test   %ecx,%ecx
  800b1f:	74 36                	je     800b57 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b27:	75 28                	jne    800b51 <memset+0x40>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 23                	jne    800b51 <memset+0x40>
		c &= 0xFF;
  800b2e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	c1 e3 08             	shl    $0x8,%ebx
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	c1 e6 18             	shl    $0x18,%esi
  800b3c:	89 d0                	mov    %edx,%eax
  800b3e:	c1 e0 10             	shl    $0x10,%eax
  800b41:	09 f0                	or     %esi,%eax
  800b43:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b45:	89 d8                	mov    %ebx,%eax
  800b47:	09 d0                	or     %edx,%eax
  800b49:	c1 e9 02             	shr    $0x2,%ecx
  800b4c:	fc                   	cld    
  800b4d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4f:	eb 06                	jmp    800b57 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b54:	fc                   	cld    
  800b55:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b57:	89 f8                	mov    %edi,%eax
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6c:	39 c6                	cmp    %eax,%esi
  800b6e:	73 35                	jae    800ba5 <memmove+0x47>
  800b70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b73:	39 d0                	cmp    %edx,%eax
  800b75:	73 2e                	jae    800ba5 <memmove+0x47>
		s += n;
		d += n;
  800b77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	09 fe                	or     %edi,%esi
  800b7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b84:	75 13                	jne    800b99 <memmove+0x3b>
  800b86:	f6 c1 03             	test   $0x3,%cl
  800b89:	75 0e                	jne    800b99 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b8b:	83 ef 04             	sub    $0x4,%edi
  800b8e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b91:	c1 e9 02             	shr    $0x2,%ecx
  800b94:	fd                   	std    
  800b95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b97:	eb 09                	jmp    800ba2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b99:	83 ef 01             	sub    $0x1,%edi
  800b9c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9f:	fd                   	std    
  800ba0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba2:	fc                   	cld    
  800ba3:	eb 1d                	jmp    800bc2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba5:	89 f2                	mov    %esi,%edx
  800ba7:	09 c2                	or     %eax,%edx
  800ba9:	f6 c2 03             	test   $0x3,%dl
  800bac:	75 0f                	jne    800bbd <memmove+0x5f>
  800bae:	f6 c1 03             	test   $0x3,%cl
  800bb1:	75 0a                	jne    800bbd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb3:	c1 e9 02             	shr    $0x2,%ecx
  800bb6:	89 c7                	mov    %eax,%edi
  800bb8:	fc                   	cld    
  800bb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbb:	eb 05                	jmp    800bc2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbd:	89 c7                	mov    %eax,%edi
  800bbf:	fc                   	cld    
  800bc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc9:	ff 75 10             	pushl  0x10(%ebp)
  800bcc:	ff 75 0c             	pushl  0xc(%ebp)
  800bcf:	ff 75 08             	pushl  0x8(%ebp)
  800bd2:	e8 87 ff ff ff       	call   800b5e <memmove>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be4:	89 c6                	mov    %eax,%esi
  800be6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be9:	eb 1a                	jmp    800c05 <memcmp+0x2c>
		if (*s1 != *s2)
  800beb:	0f b6 08             	movzbl (%eax),%ecx
  800bee:	0f b6 1a             	movzbl (%edx),%ebx
  800bf1:	38 d9                	cmp    %bl,%cl
  800bf3:	74 0a                	je     800bff <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf5:	0f b6 c1             	movzbl %cl,%eax
  800bf8:	0f b6 db             	movzbl %bl,%ebx
  800bfb:	29 d8                	sub    %ebx,%eax
  800bfd:	eb 0f                	jmp    800c0e <memcmp+0x35>
		s1++, s2++;
  800bff:	83 c0 01             	add    $0x1,%eax
  800c02:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c05:	39 f0                	cmp    %esi,%eax
  800c07:	75 e2                	jne    800beb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c19:	89 c1                	mov    %eax,%ecx
  800c1b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	eb 0a                	jmp    800c2e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	0f b6 10             	movzbl (%eax),%edx
  800c27:	39 da                	cmp    %ebx,%edx
  800c29:	74 07                	je     800c32 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	39 c8                	cmp    %ecx,%eax
  800c30:	72 f2                	jb     800c24 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c32:	5b                   	pop    %ebx
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c41:	eb 03                	jmp    800c46 <strtol+0x11>
		s++;
  800c43:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c46:	0f b6 01             	movzbl (%ecx),%eax
  800c49:	3c 20                	cmp    $0x20,%al
  800c4b:	74 f6                	je     800c43 <strtol+0xe>
  800c4d:	3c 09                	cmp    $0x9,%al
  800c4f:	74 f2                	je     800c43 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c51:	3c 2b                	cmp    $0x2b,%al
  800c53:	75 0a                	jne    800c5f <strtol+0x2a>
		s++;
  800c55:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c58:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5d:	eb 11                	jmp    800c70 <strtol+0x3b>
  800c5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c64:	3c 2d                	cmp    $0x2d,%al
  800c66:	75 08                	jne    800c70 <strtol+0x3b>
		s++, neg = 1;
  800c68:	83 c1 01             	add    $0x1,%ecx
  800c6b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c70:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c76:	75 15                	jne    800c8d <strtol+0x58>
  800c78:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7b:	75 10                	jne    800c8d <strtol+0x58>
  800c7d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c81:	75 7c                	jne    800cff <strtol+0xca>
		s += 2, base = 16;
  800c83:	83 c1 02             	add    $0x2,%ecx
  800c86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8b:	eb 16                	jmp    800ca3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8d:	85 db                	test   %ebx,%ebx
  800c8f:	75 12                	jne    800ca3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c91:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c96:	80 39 30             	cmpb   $0x30,(%ecx)
  800c99:	75 08                	jne    800ca3 <strtol+0x6e>
		s++, base = 8;
  800c9b:	83 c1 01             	add    $0x1,%ecx
  800c9e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cab:	0f b6 11             	movzbl (%ecx),%edx
  800cae:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	80 fb 09             	cmp    $0x9,%bl
  800cb6:	77 08                	ja     800cc0 <strtol+0x8b>
			dig = *s - '0';
  800cb8:	0f be d2             	movsbl %dl,%edx
  800cbb:	83 ea 30             	sub    $0x30,%edx
  800cbe:	eb 22                	jmp    800ce2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 19             	cmp    $0x19,%bl
  800cc8:	77 08                	ja     800cd2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cca:	0f be d2             	movsbl %dl,%edx
  800ccd:	83 ea 57             	sub    $0x57,%edx
  800cd0:	eb 10                	jmp    800ce2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd5:	89 f3                	mov    %esi,%ebx
  800cd7:	80 fb 19             	cmp    $0x19,%bl
  800cda:	77 16                	ja     800cf2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cdc:	0f be d2             	movsbl %dl,%edx
  800cdf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce5:	7d 0b                	jge    800cf2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cee:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf0:	eb b9                	jmp    800cab <strtol+0x76>

	if (endptr)
  800cf2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf6:	74 0d                	je     800d05 <strtol+0xd0>
		*endptr = (char *) s;
  800cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfb:	89 0e                	mov    %ecx,(%esi)
  800cfd:	eb 06                	jmp    800d05 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	74 98                	je     800c9b <strtol+0x66>
  800d03:	eb 9e                	jmp    800ca3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d05:	89 c2                	mov    %eax,%edx
  800d07:	f7 da                	neg    %edx
  800d09:	85 ff                	test   %edi,%edi
  800d0b:	0f 45 c2             	cmovne %edx,%eax
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d19:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 c3                	mov    %eax,%ebx
  800d26:	89 c7                	mov    %eax,%edi
  800d28:	89 c6                	mov    %eax,%esi
  800d2a:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d37:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d41:	89 d1                	mov    %edx,%ecx
  800d43:	89 d3                	mov    %edx,%ebx
  800d45:	89 d7                	mov    %edx,%edi
  800d47:	89 d6                	mov    %edx,%esi
  800d49:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	89 cb                	mov    %ecx,%ebx
  800d68:	89 cf                	mov    %ecx,%edi
  800d6a:	89 ce                	mov    %ecx,%esi
  800d6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 17                	jle    800d89 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	50                   	push   %eax
  800d76:	6a 03                	push   $0x3
  800d78:	68 7f 26 80 00       	push   $0x80267f
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 9c 26 80 00       	push   $0x80269c
  800d84:	e8 9b f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d97:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9c:	b8 02 00 00 00       	mov    $0x2,%eax
  800da1:	89 d1                	mov    %edx,%ecx
  800da3:	89 d3                	mov    %edx,%ebx
  800da5:	89 d7                	mov    %edx,%edi
  800da7:	89 d6                	mov    %edx,%esi
  800da9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_yield>:

void
sys_yield(void)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800db6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc0:	89 d1                	mov    %edx,%ecx
  800dc2:	89 d3                	mov    %edx,%ebx
  800dc4:	89 d7                	mov    %edx,%edi
  800dc6:	89 d6                	mov    %edx,%esi
  800dc8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	57                   	push   %edi
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dd8:	be 00 00 00 00       	mov    $0x0,%esi
  800ddd:	b8 04 00 00 00       	mov    $0x4,%eax
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
  800de8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800deb:	89 f7                	mov    %esi,%edi
  800ded:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 17                	jle    800e0a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 04                	push   $0x4
  800df9:	68 7f 26 80 00       	push   $0x80267f
  800dfe:	6a 23                	push   $0x23
  800e00:	68 9c 26 80 00       	push   $0x80269c
  800e05:	e8 1a f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2c:	8b 75 18             	mov    0x18(%ebp),%esi
  800e2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 17                	jle    800e4c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 05                	push   $0x5
  800e3b:	68 7f 26 80 00       	push   $0x80267f
  800e40:	6a 23                	push   $0x23
  800e42:	68 9c 26 80 00       	push   $0x80269c
  800e47:	e8 d8 f4 ff ff       	call   800324 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e62:	b8 06 00 00 00       	mov    $0x6,%eax
  800e67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	89 df                	mov    %ebx,%edi
  800e6f:	89 de                	mov    %ebx,%esi
  800e71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 17                	jle    800e8e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 06                	push   $0x6
  800e7d:	68 7f 26 80 00       	push   $0x80267f
  800e82:	6a 23                	push   $0x23
  800e84:	68 9c 26 80 00       	push   $0x80269c
  800e89:	e8 96 f4 ff ff       	call   800324 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 df                	mov    %ebx,%edi
  800eb1:	89 de                	mov    %ebx,%esi
  800eb3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	7e 17                	jle    800ed0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	50                   	push   %eax
  800ebd:	6a 08                	push   $0x8
  800ebf:	68 7f 26 80 00       	push   $0x80267f
  800ec4:	6a 23                	push   $0x23
  800ec6:	68 9c 26 80 00       	push   $0x80269c
  800ecb:	e8 54 f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee6:	b8 09 00 00 00       	mov    $0x9,%eax
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 df                	mov    %ebx,%edi
  800ef3:	89 de                	mov    %ebx,%esi
  800ef5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	7e 17                	jle    800f12 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efb:	83 ec 0c             	sub    $0xc,%esp
  800efe:	50                   	push   %eax
  800eff:	6a 09                	push   $0x9
  800f01:	68 7f 26 80 00       	push   $0x80267f
  800f06:	6a 23                	push   $0x23
  800f08:	68 9c 26 80 00       	push   $0x80269c
  800f0d:	e8 12 f4 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	89 df                	mov    %ebx,%edi
  800f35:	89 de                	mov    %ebx,%esi
  800f37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	7e 17                	jle    800f54 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3d:	83 ec 0c             	sub    $0xc,%esp
  800f40:	50                   	push   %eax
  800f41:	6a 0a                	push   $0xa
  800f43:	68 7f 26 80 00       	push   $0x80267f
  800f48:	6a 23                	push   $0x23
  800f4a:	68 9c 26 80 00       	push   $0x80269c
  800f4f:	e8 d0 f3 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	57                   	push   %edi
  800f60:	56                   	push   %esi
  800f61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f62:	be 00 00 00 00       	mov    $0x0,%esi
  800f67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f78:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
  800f85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800f88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	89 cb                	mov    %ecx,%ebx
  800f97:	89 cf                	mov    %ecx,%edi
  800f99:	89 ce                	mov    %ecx,%esi
  800f9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	7e 17                	jle    800fb8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	50                   	push   %eax
  800fa5:	6a 0d                	push   $0xd
  800fa7:	68 7f 26 80 00       	push   $0x80267f
  800fac:	6a 23                	push   $0x23
  800fae:	68 9c 26 80 00       	push   $0x80269c
  800fb3:	e8 6c f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc9:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fcc:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fce:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fd1:	83 3a 01             	cmpl   $0x1,(%edx)
  800fd4:	7e 09                	jle    800fdf <argstart+0x1f>
  800fd6:	ba 28 23 80 00       	mov    $0x802328,%edx
  800fdb:	85 c9                	test   %ecx,%ecx
  800fdd:	75 05                	jne    800fe4 <argstart+0x24>
  800fdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe4:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fe7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <argnext>:

int
argnext(struct Argstate *args)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800ffa:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801001:	8b 43 08             	mov    0x8(%ebx),%eax
  801004:	85 c0                	test   %eax,%eax
  801006:	74 6f                	je     801077 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801008:	80 38 00             	cmpb   $0x0,(%eax)
  80100b:	75 4e                	jne    80105b <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80100d:	8b 0b                	mov    (%ebx),%ecx
  80100f:	83 39 01             	cmpl   $0x1,(%ecx)
  801012:	74 55                	je     801069 <argnext+0x79>
		    || args->argv[1][0] != '-'
  801014:	8b 53 04             	mov    0x4(%ebx),%edx
  801017:	8b 42 04             	mov    0x4(%edx),%eax
  80101a:	80 38 2d             	cmpb   $0x2d,(%eax)
  80101d:	75 4a                	jne    801069 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  80101f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801023:	74 44                	je     801069 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801025:	83 c0 01             	add    $0x1,%eax
  801028:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	8b 01                	mov    (%ecx),%eax
  801030:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801037:	50                   	push   %eax
  801038:	8d 42 08             	lea    0x8(%edx),%eax
  80103b:	50                   	push   %eax
  80103c:	83 c2 04             	add    $0x4,%edx
  80103f:	52                   	push   %edx
  801040:	e8 19 fb ff ff       	call   800b5e <memmove>
		(*args->argc)--;
  801045:	8b 03                	mov    (%ebx),%eax
  801047:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80104a:	8b 43 08             	mov    0x8(%ebx),%eax
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	80 38 2d             	cmpb   $0x2d,(%eax)
  801053:	75 06                	jne    80105b <argnext+0x6b>
  801055:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801059:	74 0e                	je     801069 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80105b:	8b 53 08             	mov    0x8(%ebx),%edx
  80105e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801061:	83 c2 01             	add    $0x1,%edx
  801064:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801067:	eb 13                	jmp    80107c <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801069:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801070:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801075:	eb 05                	jmp    80107c <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801077:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	53                   	push   %ebx
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80108b:	8b 43 08             	mov    0x8(%ebx),%eax
  80108e:	85 c0                	test   %eax,%eax
  801090:	74 58                	je     8010ea <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801092:	80 38 00             	cmpb   $0x0,(%eax)
  801095:	74 0c                	je     8010a3 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801097:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80109a:	c7 43 08 28 23 80 00 	movl   $0x802328,0x8(%ebx)
  8010a1:	eb 42                	jmp    8010e5 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  8010a3:	8b 13                	mov    (%ebx),%edx
  8010a5:	83 3a 01             	cmpl   $0x1,(%edx)
  8010a8:	7e 2d                	jle    8010d7 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  8010aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8010ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8010b0:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	8b 12                	mov    (%edx),%edx
  8010b8:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8010bf:	52                   	push   %edx
  8010c0:	8d 50 08             	lea    0x8(%eax),%edx
  8010c3:	52                   	push   %edx
  8010c4:	83 c0 04             	add    $0x4,%eax
  8010c7:	50                   	push   %eax
  8010c8:	e8 91 fa ff ff       	call   800b5e <memmove>
		(*args->argc)--;
  8010cd:	8b 03                	mov    (%ebx),%eax
  8010cf:	83 28 01             	subl   $0x1,(%eax)
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	eb 0e                	jmp    8010e5 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8010d7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010de:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010e5:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010e8:	eb 05                	jmp    8010ef <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f2:	c9                   	leave  
  8010f3:	c3                   	ret    

008010f4 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	83 ec 08             	sub    $0x8,%esp
  8010fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010fd:	8b 51 0c             	mov    0xc(%ecx),%edx
  801100:	89 d0                	mov    %edx,%eax
  801102:	85 d2                	test   %edx,%edx
  801104:	75 0c                	jne    801112 <argvalue+0x1e>
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	51                   	push   %ecx
  80110a:	e8 72 ff ff ff       	call   801081 <argnextvalue>
  80110f:	83 c4 10             	add    $0x10,%esp
}
  801112:	c9                   	leave  
  801113:	c3                   	ret    

00801114 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
  80111a:	05 00 00 00 30       	add    $0x30000000,%eax
  80111f:	c1 e8 0c             	shr    $0xc,%eax
}
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
  80112a:	05 00 00 00 30       	add    $0x30000000,%eax
  80112f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801134:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801141:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801146:	89 c2                	mov    %eax,%edx
  801148:	c1 ea 16             	shr    $0x16,%edx
  80114b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801152:	f6 c2 01             	test   $0x1,%dl
  801155:	74 11                	je     801168 <fd_alloc+0x2d>
  801157:	89 c2                	mov    %eax,%edx
  801159:	c1 ea 0c             	shr    $0xc,%edx
  80115c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801163:	f6 c2 01             	test   $0x1,%dl
  801166:	75 09                	jne    801171 <fd_alloc+0x36>
			*fd_store = fd;
  801168:	89 01                	mov    %eax,(%ecx)
			return 0;
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
  80116f:	eb 17                	jmp    801188 <fd_alloc+0x4d>
  801171:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801176:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117b:	75 c9                	jne    801146 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801183:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801190:	83 f8 1f             	cmp    $0x1f,%eax
  801193:	77 36                	ja     8011cb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801195:	c1 e0 0c             	shl    $0xc,%eax
  801198:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	c1 ea 16             	shr    $0x16,%edx
  8011a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	74 24                	je     8011d2 <fd_lookup+0x48>
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	c1 ea 0c             	shr    $0xc,%edx
  8011b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ba:	f6 c2 01             	test   $0x1,%dl
  8011bd:	74 1a                	je     8011d9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c2:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c9:	eb 13                	jmp    8011de <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d0:	eb 0c                	jmp    8011de <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d7:	eb 05                	jmp    8011de <fd_lookup+0x54>
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e9:	ba 2c 27 80 00       	mov    $0x80272c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ee:	eb 13                	jmp    801203 <dev_lookup+0x23>
  8011f0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011f3:	39 08                	cmp    %ecx,(%eax)
  8011f5:	75 0c                	jne    801203 <dev_lookup+0x23>
			*dev = devtab[i];
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801201:	eb 2e                	jmp    801231 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801203:	8b 02                	mov    (%edx),%eax
  801205:	85 c0                	test   %eax,%eax
  801207:	75 e7                	jne    8011f0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801209:	a1 20 44 80 00       	mov    0x804420,%eax
  80120e:	8b 40 48             	mov    0x48(%eax),%eax
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	51                   	push   %ecx
  801215:	50                   	push   %eax
  801216:	68 ac 26 80 00       	push   $0x8026ac
  80121b:	e8 dd f1 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  801220:	8b 45 0c             	mov    0xc(%ebp),%eax
  801223:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801231:	c9                   	leave  
  801232:	c3                   	ret    

00801233 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	83 ec 10             	sub    $0x10,%esp
  80123b:	8b 75 08             	mov    0x8(%ebp),%esi
  80123e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801241:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80124b:	c1 e8 0c             	shr    $0xc,%eax
  80124e:	50                   	push   %eax
  80124f:	e8 36 ff ff ff       	call   80118a <fd_lookup>
  801254:	83 c4 08             	add    $0x8,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	78 05                	js     801260 <fd_close+0x2d>
	    || fd != fd2)
  80125b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80125e:	74 0c                	je     80126c <fd_close+0x39>
		return (must_exist ? r : 0);
  801260:	84 db                	test   %bl,%bl
  801262:	ba 00 00 00 00       	mov    $0x0,%edx
  801267:	0f 44 c2             	cmove  %edx,%eax
  80126a:	eb 41                	jmp    8012ad <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	ff 36                	pushl  (%esi)
  801275:	e8 66 ff ff ff       	call   8011e0 <dev_lookup>
  80127a:	89 c3                	mov    %eax,%ebx
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 1a                	js     80129d <fd_close+0x6a>
		if (dev->dev_close)
  801283:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801286:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801289:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80128e:	85 c0                	test   %eax,%eax
  801290:	74 0b                	je     80129d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801292:	83 ec 0c             	sub    $0xc,%esp
  801295:	56                   	push   %esi
  801296:	ff d0                	call   *%eax
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	56                   	push   %esi
  8012a1:	6a 00                	push   $0x0
  8012a3:	e8 ac fb ff ff       	call   800e54 <sys_page_unmap>
	return r;
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	89 d8                	mov    %ebx,%eax
}
  8012ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	ff 75 08             	pushl  0x8(%ebp)
  8012c1:	e8 c4 fe ff ff       	call   80118a <fd_lookup>
  8012c6:	83 c4 08             	add    $0x8,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	78 10                	js     8012dd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	6a 01                	push   $0x1
  8012d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d5:	e8 59 ff ff ff       	call   801233 <fd_close>
  8012da:	83 c4 10             	add    $0x10,%esp
}
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <close_all>:

void
close_all(void)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	53                   	push   %ebx
  8012e3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012eb:	83 ec 0c             	sub    $0xc,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	e8 c0 ff ff ff       	call   8012b4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f4:	83 c3 01             	add    $0x1,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	83 fb 20             	cmp    $0x20,%ebx
  8012fd:	75 ec                	jne    8012eb <close_all+0xc>
		close(i);
}
  8012ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801302:	c9                   	leave  
  801303:	c3                   	ret    

00801304 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	57                   	push   %edi
  801308:	56                   	push   %esi
  801309:	53                   	push   %ebx
  80130a:	83 ec 2c             	sub    $0x2c,%esp
  80130d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801310:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	ff 75 08             	pushl  0x8(%ebp)
  801317:	e8 6e fe ff ff       	call   80118a <fd_lookup>
  80131c:	83 c4 08             	add    $0x8,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	0f 88 c1 00 00 00    	js     8013e8 <dup+0xe4>
		return r;
	close(newfdnum);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	56                   	push   %esi
  80132b:	e8 84 ff ff ff       	call   8012b4 <close>

	newfd = INDEX2FD(newfdnum);
  801330:	89 f3                	mov    %esi,%ebx
  801332:	c1 e3 0c             	shl    $0xc,%ebx
  801335:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80133b:	83 c4 04             	add    $0x4,%esp
  80133e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801341:	e8 de fd ff ff       	call   801124 <fd2data>
  801346:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801348:	89 1c 24             	mov    %ebx,(%esp)
  80134b:	e8 d4 fd ff ff       	call   801124 <fd2data>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801356:	89 f8                	mov    %edi,%eax
  801358:	c1 e8 16             	shr    $0x16,%eax
  80135b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801362:	a8 01                	test   $0x1,%al
  801364:	74 37                	je     80139d <dup+0x99>
  801366:	89 f8                	mov    %edi,%eax
  801368:	c1 e8 0c             	shr    $0xc,%eax
  80136b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801372:	f6 c2 01             	test   $0x1,%dl
  801375:	74 26                	je     80139d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801377:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137e:	83 ec 0c             	sub    $0xc,%esp
  801381:	25 07 0e 00 00       	and    $0xe07,%eax
  801386:	50                   	push   %eax
  801387:	ff 75 d4             	pushl  -0x2c(%ebp)
  80138a:	6a 00                	push   $0x0
  80138c:	57                   	push   %edi
  80138d:	6a 00                	push   $0x0
  80138f:	e8 7e fa ff ff       	call   800e12 <sys_page_map>
  801394:	89 c7                	mov    %eax,%edi
  801396:	83 c4 20             	add    $0x20,%esp
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 2e                	js     8013cb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a0:	89 d0                	mov    %edx,%eax
  8013a2:	c1 e8 0c             	shr    $0xc,%eax
  8013a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b4:	50                   	push   %eax
  8013b5:	53                   	push   %ebx
  8013b6:	6a 00                	push   $0x0
  8013b8:	52                   	push   %edx
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 52 fa ff ff       	call   800e12 <sys_page_map>
  8013c0:	89 c7                	mov    %eax,%edi
  8013c2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013c5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c7:	85 ff                	test   %edi,%edi
  8013c9:	79 1d                	jns    8013e8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	53                   	push   %ebx
  8013cf:	6a 00                	push   $0x0
  8013d1:	e8 7e fa ff ff       	call   800e54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013d6:	83 c4 08             	add    $0x8,%esp
  8013d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 71 fa ff ff       	call   800e54 <sys_page_unmap>
	return r;
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	89 f8                	mov    %edi,%eax
}
  8013e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013eb:	5b                   	pop    %ebx
  8013ec:	5e                   	pop    %esi
  8013ed:	5f                   	pop    %edi
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 14             	sub    $0x14,%esp
  8013f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	53                   	push   %ebx
  8013ff:	e8 86 fd ff ff       	call   80118a <fd_lookup>
  801404:	83 c4 08             	add    $0x8,%esp
  801407:	89 c2                	mov    %eax,%edx
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 6d                	js     80147a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801417:	ff 30                	pushl  (%eax)
  801419:	e8 c2 fd ff ff       	call   8011e0 <dev_lookup>
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 4c                	js     801471 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801425:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801428:	8b 42 08             	mov    0x8(%edx),%eax
  80142b:	83 e0 03             	and    $0x3,%eax
  80142e:	83 f8 01             	cmp    $0x1,%eax
  801431:	75 21                	jne    801454 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801433:	a1 20 44 80 00       	mov    0x804420,%eax
  801438:	8b 40 48             	mov    0x48(%eax),%eax
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	53                   	push   %ebx
  80143f:	50                   	push   %eax
  801440:	68 f0 26 80 00       	push   $0x8026f0
  801445:	e8 b3 ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801452:	eb 26                	jmp    80147a <read+0x8a>
	}
	if (!dev->dev_read)
  801454:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801457:	8b 40 08             	mov    0x8(%eax),%eax
  80145a:	85 c0                	test   %eax,%eax
  80145c:	74 17                	je     801475 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80145e:	83 ec 04             	sub    $0x4,%esp
  801461:	ff 75 10             	pushl  0x10(%ebp)
  801464:	ff 75 0c             	pushl  0xc(%ebp)
  801467:	52                   	push   %edx
  801468:	ff d0                	call   *%eax
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	eb 09                	jmp    80147a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801471:	89 c2                	mov    %eax,%edx
  801473:	eb 05                	jmp    80147a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801475:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80147a:	89 d0                	mov    %edx,%eax
  80147c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	57                   	push   %edi
  801485:	56                   	push   %esi
  801486:	53                   	push   %ebx
  801487:	83 ec 0c             	sub    $0xc,%esp
  80148a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80148d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801490:	bb 00 00 00 00       	mov    $0x0,%ebx
  801495:	eb 21                	jmp    8014b8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	89 f0                	mov    %esi,%eax
  80149c:	29 d8                	sub    %ebx,%eax
  80149e:	50                   	push   %eax
  80149f:	89 d8                	mov    %ebx,%eax
  8014a1:	03 45 0c             	add    0xc(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	57                   	push   %edi
  8014a6:	e8 45 ff ff ff       	call   8013f0 <read>
		if (m < 0)
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 10                	js     8014c2 <readn+0x41>
			return m;
		if (m == 0)
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	74 0a                	je     8014c0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b6:	01 c3                	add    %eax,%ebx
  8014b8:	39 f3                	cmp    %esi,%ebx
  8014ba:	72 db                	jb     801497 <readn+0x16>
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	eb 02                	jmp    8014c2 <readn+0x41>
  8014c0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c5:	5b                   	pop    %ebx
  8014c6:	5e                   	pop    %esi
  8014c7:	5f                   	pop    %edi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 14             	sub    $0x14,%esp
  8014d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	53                   	push   %ebx
  8014d9:	e8 ac fc ff ff       	call   80118a <fd_lookup>
  8014de:	83 c4 08             	add    $0x8,%esp
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 68                	js     80154f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f1:	ff 30                	pushl  (%eax)
  8014f3:	e8 e8 fc ff ff       	call   8011e0 <dev_lookup>
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 47                	js     801546 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801506:	75 21                	jne    801529 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801508:	a1 20 44 80 00       	mov    0x804420,%eax
  80150d:	8b 40 48             	mov    0x48(%eax),%eax
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	53                   	push   %ebx
  801514:	50                   	push   %eax
  801515:	68 0c 27 80 00       	push   $0x80270c
  80151a:	e8 de ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801527:	eb 26                	jmp    80154f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801529:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152c:	8b 52 0c             	mov    0xc(%edx),%edx
  80152f:	85 d2                	test   %edx,%edx
  801531:	74 17                	je     80154a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	ff 75 10             	pushl  0x10(%ebp)
  801539:	ff 75 0c             	pushl  0xc(%ebp)
  80153c:	50                   	push   %eax
  80153d:	ff d2                	call   *%edx
  80153f:	89 c2                	mov    %eax,%edx
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	eb 09                	jmp    80154f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801546:	89 c2                	mov    %eax,%edx
  801548:	eb 05                	jmp    80154f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80154a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80154f:	89 d0                	mov    %edx,%eax
  801551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <seek>:

int
seek(int fdnum, off_t offset)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	ff 75 08             	pushl  0x8(%ebp)
  801563:	e8 22 fc ff ff       	call   80118a <fd_lookup>
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 0e                	js     80157d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80156f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801572:	8b 55 0c             	mov    0xc(%ebp),%edx
  801575:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801578:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	53                   	push   %ebx
  801583:	83 ec 14             	sub    $0x14,%esp
  801586:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801589:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158c:	50                   	push   %eax
  80158d:	53                   	push   %ebx
  80158e:	e8 f7 fb ff ff       	call   80118a <fd_lookup>
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	89 c2                	mov    %eax,%edx
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 65                	js     801601 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a6:	ff 30                	pushl  (%eax)
  8015a8:	e8 33 fc ff ff       	call   8011e0 <dev_lookup>
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 44                	js     8015f8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015bb:	75 21                	jne    8015de <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015bd:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c2:	8b 40 48             	mov    0x48(%eax),%eax
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	50                   	push   %eax
  8015ca:	68 cc 26 80 00       	push   $0x8026cc
  8015cf:	e8 29 ee ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015dc:	eb 23                	jmp    801601 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e1:	8b 52 18             	mov    0x18(%edx),%edx
  8015e4:	85 d2                	test   %edx,%edx
  8015e6:	74 14                	je     8015fc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ee:	50                   	push   %eax
  8015ef:	ff d2                	call   *%edx
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	eb 09                	jmp    801601 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	eb 05                	jmp    801601 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801601:	89 d0                	mov    %edx,%eax
  801603:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	53                   	push   %ebx
  80160c:	83 ec 14             	sub    $0x14,%esp
  80160f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801612:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	ff 75 08             	pushl  0x8(%ebp)
  801619:	e8 6c fb ff ff       	call   80118a <fd_lookup>
  80161e:	83 c4 08             	add    $0x8,%esp
  801621:	89 c2                	mov    %eax,%edx
  801623:	85 c0                	test   %eax,%eax
  801625:	78 58                	js     80167f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801631:	ff 30                	pushl  (%eax)
  801633:	e8 a8 fb ff ff       	call   8011e0 <dev_lookup>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 37                	js     801676 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80163f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801642:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801646:	74 32                	je     80167a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801648:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80164b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801652:	00 00 00 
	stat->st_isdir = 0;
  801655:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165c:	00 00 00 
	stat->st_dev = dev;
  80165f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	53                   	push   %ebx
  801669:	ff 75 f0             	pushl  -0x10(%ebp)
  80166c:	ff 50 14             	call   *0x14(%eax)
  80166f:	89 c2                	mov    %eax,%edx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	eb 09                	jmp    80167f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801676:	89 c2                	mov    %eax,%edx
  801678:	eb 05                	jmp    80167f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80167a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80167f:	89 d0                	mov    %edx,%eax
  801681:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	6a 00                	push   $0x0
  801690:	ff 75 08             	pushl  0x8(%ebp)
  801693:	e8 dc 01 00 00       	call   801874 <open>
  801698:	89 c3                	mov    %eax,%ebx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 1b                	js     8016bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	ff 75 0c             	pushl  0xc(%ebp)
  8016a7:	50                   	push   %eax
  8016a8:	e8 5b ff ff ff       	call   801608 <fstat>
  8016ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8016af:	89 1c 24             	mov    %ebx,(%esp)
  8016b2:	e8 fd fb ff ff       	call   8012b4 <close>
	return r;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	89 f0                	mov    %esi,%eax
}
  8016bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	89 c6                	mov    %eax,%esi
  8016ca:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d3:	75 12                	jne    8016e7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d5:	83 ec 0c             	sub    $0xc,%esp
  8016d8:	6a 01                	push   $0x1
  8016da:	e8 c8 08 00 00       	call   801fa7 <ipc_find_env>
  8016df:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e4:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016e7:	6a 07                	push   $0x7
  8016e9:	68 00 50 80 00       	push   $0x805000
  8016ee:	56                   	push   %esi
  8016ef:	ff 35 00 40 80 00    	pushl  0x804000
  8016f5:	e8 6a 08 00 00       	call   801f64 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8016fa:	83 c4 0c             	add    $0xc,%esp
  8016fd:	6a 00                	push   $0x0
  8016ff:	53                   	push   %ebx
  801700:	6a 00                	push   $0x0
  801702:	e8 00 08 00 00       	call   801f07 <ipc_recv>
}
  801707:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	8b 40 0c             	mov    0xc(%eax),%eax
  80171a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80171f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801722:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801727:	ba 00 00 00 00       	mov    $0x0,%edx
  80172c:	b8 02 00 00 00       	mov    $0x2,%eax
  801731:	e8 8d ff ff ff       	call   8016c3 <fsipc>
}
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 06 00 00 00       	mov    $0x6,%eax
  801753:	e8 6b ff ff ff       	call   8016c3 <fsipc>
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 04             	sub    $0x4,%esp
  801761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801764:	8b 45 08             	mov    0x8(%ebp),%eax
  801767:	8b 40 0c             	mov    0xc(%eax),%eax
  80176a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	b8 05 00 00 00       	mov    $0x5,%eax
  801779:	e8 45 ff ff ff       	call   8016c3 <fsipc>
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 2c                	js     8017ae <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801782:	83 ec 08             	sub    $0x8,%esp
  801785:	68 00 50 80 00       	push   $0x805000
  80178a:	53                   	push   %ebx
  80178b:	e8 3c f2 ff ff       	call   8009cc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801790:	a1 80 50 80 00       	mov    0x805080,%eax
  801795:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179b:	a1 84 50 80 00       	mov    0x805084,%eax
  8017a0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 0c             	sub    $0xc,%esp
  8017b9:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017c8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017cd:	50                   	push   %eax
  8017ce:	ff 75 0c             	pushl  0xc(%ebp)
  8017d1:	68 08 50 80 00       	push   $0x805008
  8017d6:	e8 83 f3 ff ff       	call   800b5e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e5:	e8 d9 fe ff ff       	call   8016c3 <fsipc>
	//panic("devfile_write not implemented");
}
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ff:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801805:	ba 00 00 00 00       	mov    $0x0,%edx
  80180a:	b8 03 00 00 00       	mov    $0x3,%eax
  80180f:	e8 af fe ff ff       	call   8016c3 <fsipc>
  801814:	89 c3                	mov    %eax,%ebx
  801816:	85 c0                	test   %eax,%eax
  801818:	78 51                	js     80186b <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80181a:	39 c6                	cmp    %eax,%esi
  80181c:	73 19                	jae    801837 <devfile_read+0x4b>
  80181e:	68 3c 27 80 00       	push   $0x80273c
  801823:	68 43 27 80 00       	push   $0x802743
  801828:	68 80 00 00 00       	push   $0x80
  80182d:	68 58 27 80 00       	push   $0x802758
  801832:	e8 ed ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801837:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80183c:	7e 19                	jle    801857 <devfile_read+0x6b>
  80183e:	68 63 27 80 00       	push   $0x802763
  801843:	68 43 27 80 00       	push   $0x802743
  801848:	68 81 00 00 00       	push   $0x81
  80184d:	68 58 27 80 00       	push   $0x802758
  801852:	e8 cd ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801857:	83 ec 04             	sub    $0x4,%esp
  80185a:	50                   	push   %eax
  80185b:	68 00 50 80 00       	push   $0x805000
  801860:	ff 75 0c             	pushl  0xc(%ebp)
  801863:	e8 f6 f2 ff ff       	call   800b5e <memmove>
	return r;
  801868:	83 c4 10             	add    $0x10,%esp
}
  80186b:	89 d8                	mov    %ebx,%eax
  80186d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801870:	5b                   	pop    %ebx
  801871:	5e                   	pop    %esi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    

00801874 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	53                   	push   %ebx
  801878:	83 ec 20             	sub    $0x20,%esp
  80187b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80187e:	53                   	push   %ebx
  80187f:	e8 0f f1 ff ff       	call   800993 <strlen>
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80188c:	7f 67                	jg     8018f5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801894:	50                   	push   %eax
  801895:	e8 a1 f8 ff ff       	call   80113b <fd_alloc>
  80189a:	83 c4 10             	add    $0x10,%esp
		return r;
  80189d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 57                	js     8018fa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	53                   	push   %ebx
  8018a7:	68 00 50 80 00       	push   $0x805000
  8018ac:	e8 1b f1 ff ff       	call   8009cc <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b4:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c1:	e8 fd fd ff ff       	call   8016c3 <fsipc>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	79 14                	jns    8018e3 <open+0x6f>
		
		fd_close(fd, 0);
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	6a 00                	push   $0x0
  8018d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d7:	e8 57 f9 ff ff       	call   801233 <fd_close>
		return r;
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	89 da                	mov    %ebx,%edx
  8018e1:	eb 17                	jmp    8018fa <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e9:	e8 26 f8 ff ff       	call   801114 <fd2num>
  8018ee:	89 c2                	mov    %eax,%edx
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	eb 05                	jmp    8018fa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8018fa:	89 d0                	mov    %edx,%eax
  8018fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    

00801901 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801907:	ba 00 00 00 00       	mov    $0x0,%edx
  80190c:	b8 08 00 00 00       	mov    $0x8,%eax
  801911:	e8 ad fd ff ff       	call   8016c3 <fsipc>
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801918:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80191c:	7e 37                	jle    801955 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801927:	ff 70 04             	pushl  0x4(%eax)
  80192a:	8d 40 10             	lea    0x10(%eax),%eax
  80192d:	50                   	push   %eax
  80192e:	ff 33                	pushl  (%ebx)
  801930:	e8 95 fb ff ff       	call   8014ca <write>
		if (result > 0)
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 c0                	test   %eax,%eax
  80193a:	7e 03                	jle    80193f <writebuf+0x27>
			b->result += result;
  80193c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80193f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801942:	74 0d                	je     801951 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801944:	85 c0                	test   %eax,%eax
  801946:	ba 00 00 00 00       	mov    $0x0,%edx
  80194b:	0f 4f c2             	cmovg  %edx,%eax
  80194e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801954:	c9                   	leave  
  801955:	f3 c3                	repz ret 

00801957 <putch>:

static void
putch(int ch, void *thunk)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	53                   	push   %ebx
  80195b:	83 ec 04             	sub    $0x4,%esp
  80195e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801961:	8b 53 04             	mov    0x4(%ebx),%edx
  801964:	8d 42 01             	lea    0x1(%edx),%eax
  801967:	89 43 04             	mov    %eax,0x4(%ebx)
  80196a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196d:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801971:	3d 00 01 00 00       	cmp    $0x100,%eax
  801976:	75 0e                	jne    801986 <putch+0x2f>
		writebuf(b);
  801978:	89 d8                	mov    %ebx,%eax
  80197a:	e8 99 ff ff ff       	call   801918 <writebuf>
		b->idx = 0;
  80197f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801986:	83 c4 04             	add    $0x4,%esp
  801989:	5b                   	pop    %ebx
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801995:	8b 45 08             	mov    0x8(%ebp),%eax
  801998:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80199e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019a5:	00 00 00 
	b.result = 0;
  8019a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019af:	00 00 00 
	b.error = 1;
  8019b2:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019b9:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019bc:	ff 75 10             	pushl  0x10(%ebp)
  8019bf:	ff 75 0c             	pushl  0xc(%ebp)
  8019c2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	68 57 19 80 00       	push   $0x801957
  8019ce:	e8 61 eb ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019dd:	7e 0b                	jle    8019ea <vfprintf+0x5e>
		writebuf(&b);
  8019df:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019e5:	e8 2e ff ff ff       	call   801918 <writebuf>

	return (b.result ? b.result : b.error);
  8019ea:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019f9:	c9                   	leave  
  8019fa:	c3                   	ret    

008019fb <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a01:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a04:	50                   	push   %eax
  801a05:	ff 75 0c             	pushl  0xc(%ebp)
  801a08:	ff 75 08             	pushl  0x8(%ebp)
  801a0b:	e8 7c ff ff ff       	call   80198c <vfprintf>
	va_end(ap);

	return cnt;
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <printf>:

int
printf(const char *fmt, ...)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a18:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a1b:	50                   	push   %eax
  801a1c:	ff 75 08             	pushl  0x8(%ebp)
  801a1f:	6a 01                	push   $0x1
  801a21:	e8 66 ff ff ff       	call   80198c <vfprintf>
	va_end(ap);

	return cnt;
}
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	ff 75 08             	pushl  0x8(%ebp)
  801a36:	e8 e9 f6 ff ff       	call   801124 <fd2data>
  801a3b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a3d:	83 c4 08             	add    $0x8,%esp
  801a40:	68 6f 27 80 00       	push   $0x80276f
  801a45:	53                   	push   %ebx
  801a46:	e8 81 ef ff ff       	call   8009cc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a4b:	8b 46 04             	mov    0x4(%esi),%eax
  801a4e:	2b 06                	sub    (%esi),%eax
  801a50:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a56:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a5d:	00 00 00 
	stat->st_dev = &devpipe;
  801a60:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a67:	30 80 00 
	return 0;
}
  801a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a80:	53                   	push   %ebx
  801a81:	6a 00                	push   $0x0
  801a83:	e8 cc f3 ff ff       	call   800e54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a88:	89 1c 24             	mov    %ebx,(%esp)
  801a8b:	e8 94 f6 ff ff       	call   801124 <fd2data>
  801a90:	83 c4 08             	add    $0x8,%esp
  801a93:	50                   	push   %eax
  801a94:	6a 00                	push   $0x0
  801a96:	e8 b9 f3 ff ff       	call   800e54 <sys_page_unmap>
}
  801a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	83 ec 1c             	sub    $0x1c,%esp
  801aa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aac:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aae:	a1 20 44 80 00       	mov    0x804420,%eax
  801ab3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ab6:	83 ec 0c             	sub    $0xc,%esp
  801ab9:	ff 75 e0             	pushl  -0x20(%ebp)
  801abc:	e8 1f 05 00 00       	call   801fe0 <pageref>
  801ac1:	89 c3                	mov    %eax,%ebx
  801ac3:	89 3c 24             	mov    %edi,(%esp)
  801ac6:	e8 15 05 00 00       	call   801fe0 <pageref>
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	39 c3                	cmp    %eax,%ebx
  801ad0:	0f 94 c1             	sete   %cl
  801ad3:	0f b6 c9             	movzbl %cl,%ecx
  801ad6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ad9:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801adf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae2:	39 ce                	cmp    %ecx,%esi
  801ae4:	74 1b                	je     801b01 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ae6:	39 c3                	cmp    %eax,%ebx
  801ae8:	75 c4                	jne    801aae <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aea:	8b 42 58             	mov    0x58(%edx),%eax
  801aed:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af0:	50                   	push   %eax
  801af1:	56                   	push   %esi
  801af2:	68 76 27 80 00       	push   $0x802776
  801af7:	e8 01 e9 ff ff       	call   8003fd <cprintf>
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	eb ad                	jmp    801aae <_pipeisclosed+0xe>
	}
}
  801b01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b07:	5b                   	pop    %ebx
  801b08:	5e                   	pop    %esi
  801b09:	5f                   	pop    %edi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	57                   	push   %edi
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	83 ec 28             	sub    $0x28,%esp
  801b15:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b18:	56                   	push   %esi
  801b19:	e8 06 f6 ff ff       	call   801124 <fd2data>
  801b1e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	bf 00 00 00 00       	mov    $0x0,%edi
  801b28:	eb 4b                	jmp    801b75 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b2a:	89 da                	mov    %ebx,%edx
  801b2c:	89 f0                	mov    %esi,%eax
  801b2e:	e8 6d ff ff ff       	call   801aa0 <_pipeisclosed>
  801b33:	85 c0                	test   %eax,%eax
  801b35:	75 48                	jne    801b7f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b37:	e8 74 f2 ff ff       	call   800db0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3f:	8b 0b                	mov    (%ebx),%ecx
  801b41:	8d 51 20             	lea    0x20(%ecx),%edx
  801b44:	39 d0                	cmp    %edx,%eax
  801b46:	73 e2                	jae    801b2a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b4f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b52:	89 c2                	mov    %eax,%edx
  801b54:	c1 fa 1f             	sar    $0x1f,%edx
  801b57:	89 d1                	mov    %edx,%ecx
  801b59:	c1 e9 1b             	shr    $0x1b,%ecx
  801b5c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b5f:	83 e2 1f             	and    $0x1f,%edx
  801b62:	29 ca                	sub    %ecx,%edx
  801b64:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b68:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b6c:	83 c0 01             	add    $0x1,%eax
  801b6f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b72:	83 c7 01             	add    $0x1,%edi
  801b75:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b78:	75 c2                	jne    801b3c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b7a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7d:	eb 05                	jmp    801b84 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5f                   	pop    %edi
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	57                   	push   %edi
  801b90:	56                   	push   %esi
  801b91:	53                   	push   %ebx
  801b92:	83 ec 18             	sub    $0x18,%esp
  801b95:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b98:	57                   	push   %edi
  801b99:	e8 86 f5 ff ff       	call   801124 <fd2data>
  801b9e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba8:	eb 3d                	jmp    801be7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801baa:	85 db                	test   %ebx,%ebx
  801bac:	74 04                	je     801bb2 <devpipe_read+0x26>
				return i;
  801bae:	89 d8                	mov    %ebx,%eax
  801bb0:	eb 44                	jmp    801bf6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb2:	89 f2                	mov    %esi,%edx
  801bb4:	89 f8                	mov    %edi,%eax
  801bb6:	e8 e5 fe ff ff       	call   801aa0 <_pipeisclosed>
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	75 32                	jne    801bf1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bbf:	e8 ec f1 ff ff       	call   800db0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc4:	8b 06                	mov    (%esi),%eax
  801bc6:	3b 46 04             	cmp    0x4(%esi),%eax
  801bc9:	74 df                	je     801baa <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bcb:	99                   	cltd   
  801bcc:	c1 ea 1b             	shr    $0x1b,%edx
  801bcf:	01 d0                	add    %edx,%eax
  801bd1:	83 e0 1f             	and    $0x1f,%eax
  801bd4:	29 d0                	sub    %edx,%eax
  801bd6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bde:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801be1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be4:	83 c3 01             	add    $0x1,%ebx
  801be7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bea:	75 d8                	jne    801bc4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bec:	8b 45 10             	mov    0x10(%ebp),%eax
  801bef:	eb 05                	jmp    801bf6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf9:	5b                   	pop    %ebx
  801bfa:	5e                   	pop    %esi
  801bfb:	5f                   	pop    %edi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	56                   	push   %esi
  801c02:	53                   	push   %ebx
  801c03:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c09:	50                   	push   %eax
  801c0a:	e8 2c f5 ff ff       	call   80113b <fd_alloc>
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	89 c2                	mov    %eax,%edx
  801c14:	85 c0                	test   %eax,%eax
  801c16:	0f 88 2c 01 00 00    	js     801d48 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1c:	83 ec 04             	sub    $0x4,%esp
  801c1f:	68 07 04 00 00       	push   $0x407
  801c24:	ff 75 f4             	pushl  -0xc(%ebp)
  801c27:	6a 00                	push   $0x0
  801c29:	e8 a1 f1 ff ff       	call   800dcf <sys_page_alloc>
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	89 c2                	mov    %eax,%edx
  801c33:	85 c0                	test   %eax,%eax
  801c35:	0f 88 0d 01 00 00    	js     801d48 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c3b:	83 ec 0c             	sub    $0xc,%esp
  801c3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c41:	50                   	push   %eax
  801c42:	e8 f4 f4 ff ff       	call   80113b <fd_alloc>
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 e2 00 00 00    	js     801d36 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	68 07 04 00 00       	push   $0x407
  801c5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 69 f1 ff ff       	call   800dcf <sys_page_alloc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	0f 88 c3 00 00 00    	js     801d36 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	ff 75 f4             	pushl  -0xc(%ebp)
  801c79:	e8 a6 f4 ff ff       	call   801124 <fd2data>
  801c7e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c80:	83 c4 0c             	add    $0xc,%esp
  801c83:	68 07 04 00 00       	push   $0x407
  801c88:	50                   	push   %eax
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 3f f1 ff ff       	call   800dcf <sys_page_alloc>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	0f 88 89 00 00 00    	js     801d26 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca3:	e8 7c f4 ff ff       	call   801124 <fd2data>
  801ca8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801caf:	50                   	push   %eax
  801cb0:	6a 00                	push   $0x0
  801cb2:	56                   	push   %esi
  801cb3:	6a 00                	push   $0x0
  801cb5:	e8 58 f1 ff ff       	call   800e12 <sys_page_map>
  801cba:	89 c3                	mov    %eax,%ebx
  801cbc:	83 c4 20             	add    $0x20,%esp
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 55                	js     801d18 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cc3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cd8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ced:	83 ec 0c             	sub    $0xc,%esp
  801cf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf3:	e8 1c f4 ff ff       	call   801114 <fd2num>
  801cf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cfd:	83 c4 04             	add    $0x4,%esp
  801d00:	ff 75 f0             	pushl  -0x10(%ebp)
  801d03:	e8 0c f4 ff ff       	call   801114 <fd2num>
  801d08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d0b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	ba 00 00 00 00       	mov    $0x0,%edx
  801d16:	eb 30                	jmp    801d48 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d18:	83 ec 08             	sub    $0x8,%esp
  801d1b:	56                   	push   %esi
  801d1c:	6a 00                	push   $0x0
  801d1e:	e8 31 f1 ff ff       	call   800e54 <sys_page_unmap>
  801d23:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 21 f1 ff ff       	call   800e54 <sys_page_unmap>
  801d33:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d36:	83 ec 08             	sub    $0x8,%esp
  801d39:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3c:	6a 00                	push   $0x0
  801d3e:	e8 11 f1 ff ff       	call   800e54 <sys_page_unmap>
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d48:	89 d0                	mov    %edx,%eax
  801d4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5a:	50                   	push   %eax
  801d5b:	ff 75 08             	pushl  0x8(%ebp)
  801d5e:	e8 27 f4 ff ff       	call   80118a <fd_lookup>
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	85 c0                	test   %eax,%eax
  801d68:	78 18                	js     801d82 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d6a:	83 ec 0c             	sub    $0xc,%esp
  801d6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d70:	e8 af f3 ff ff       	call   801124 <fd2data>
	return _pipeisclosed(fd, p);
  801d75:	89 c2                	mov    %eax,%edx
  801d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7a:	e8 21 fd ff ff       	call   801aa0 <_pipeisclosed>
  801d7f:	83 c4 10             	add    $0x10,%esp
}
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    

00801d84 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d94:	68 8e 27 80 00       	push   $0x80278e
  801d99:	ff 75 0c             	pushl  0xc(%ebp)
  801d9c:	e8 2b ec ff ff       	call   8009cc <strcpy>
	return 0;
}
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	57                   	push   %edi
  801dac:	56                   	push   %esi
  801dad:	53                   	push   %ebx
  801dae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbf:	eb 2d                	jmp    801dee <devcons_write+0x46>
		m = n - tot;
  801dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dc6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dce:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd1:	83 ec 04             	sub    $0x4,%esp
  801dd4:	53                   	push   %ebx
  801dd5:	03 45 0c             	add    0xc(%ebp),%eax
  801dd8:	50                   	push   %eax
  801dd9:	57                   	push   %edi
  801dda:	e8 7f ed ff ff       	call   800b5e <memmove>
		sys_cputs(buf, m);
  801ddf:	83 c4 08             	add    $0x8,%esp
  801de2:	53                   	push   %ebx
  801de3:	57                   	push   %edi
  801de4:	e8 2a ef ff ff       	call   800d13 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de9:	01 de                	add    %ebx,%esi
  801deb:	83 c4 10             	add    $0x10,%esp
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df3:	72 cc                	jb     801dc1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	83 ec 08             	sub    $0x8,%esp
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e0c:	74 2a                	je     801e38 <devcons_read+0x3b>
  801e0e:	eb 05                	jmp    801e15 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e10:	e8 9b ef ff ff       	call   800db0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e15:	e8 17 ef ff ff       	call   800d31 <sys_cgetc>
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	74 f2                	je     801e10 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	78 16                	js     801e38 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e22:	83 f8 04             	cmp    $0x4,%eax
  801e25:	74 0c                	je     801e33 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2a:	88 02                	mov    %al,(%edx)
	return 1;
  801e2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e31:	eb 05                	jmp    801e38 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e33:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e40:	8b 45 08             	mov    0x8(%ebp),%eax
  801e43:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e46:	6a 01                	push   $0x1
  801e48:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e4b:	50                   	push   %eax
  801e4c:	e8 c2 ee ff ff       	call   800d13 <sys_cputs>
}
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <getchar>:

int
getchar(void)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e5c:	6a 01                	push   $0x1
  801e5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e61:	50                   	push   %eax
  801e62:	6a 00                	push   $0x0
  801e64:	e8 87 f5 ff ff       	call   8013f0 <read>
	if (r < 0)
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 0f                	js     801e7f <getchar+0x29>
		return r;
	if (r < 1)
  801e70:	85 c0                	test   %eax,%eax
  801e72:	7e 06                	jle    801e7a <getchar+0x24>
		return -E_EOF;
	return c;
  801e74:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e78:	eb 05                	jmp    801e7f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e7a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8a:	50                   	push   %eax
  801e8b:	ff 75 08             	pushl  0x8(%ebp)
  801e8e:	e8 f7 f2 ff ff       	call   80118a <fd_lookup>
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	85 c0                	test   %eax,%eax
  801e98:	78 11                	js     801eab <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea3:	39 10                	cmp    %edx,(%eax)
  801ea5:	0f 94 c0             	sete   %al
  801ea8:	0f b6 c0             	movzbl %al,%eax
}
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <opencons>:

int
opencons(void)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb6:	50                   	push   %eax
  801eb7:	e8 7f f2 ff ff       	call   80113b <fd_alloc>
  801ebc:	83 c4 10             	add    $0x10,%esp
		return r;
  801ebf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 3e                	js     801f03 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec5:	83 ec 04             	sub    $0x4,%esp
  801ec8:	68 07 04 00 00       	push   $0x407
  801ecd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed0:	6a 00                	push   $0x0
  801ed2:	e8 f8 ee ff ff       	call   800dcf <sys_page_alloc>
  801ed7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eda:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801edc:	85 c0                	test   %eax,%eax
  801ede:	78 23                	js     801f03 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ee0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef5:	83 ec 0c             	sub    $0xc,%esp
  801ef8:	50                   	push   %eax
  801ef9:	e8 16 f2 ff ff       	call   801114 <fd2num>
  801efe:	89 c2                	mov    %eax,%edx
  801f00:	83 c4 10             	add    $0x10,%esp
}
  801f03:	89 d0                	mov    %edx,%eax
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	56                   	push   %esi
  801f0b:	53                   	push   %ebx
  801f0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f0f:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	ff 75 0c             	pushl  0xc(%ebp)
  801f18:	e8 62 f0 ff ff       	call   800f7f <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	85 f6                	test   %esi,%esi
  801f22:	74 1c                	je     801f40 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801f24:	a1 20 44 80 00       	mov    0x804420,%eax
  801f29:	8b 40 78             	mov    0x78(%eax),%eax
  801f2c:	89 06                	mov    %eax,(%esi)
  801f2e:	eb 10                	jmp    801f40 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	68 9a 27 80 00       	push   $0x80279a
  801f38:	e8 c0 e4 ff ff       	call   8003fd <cprintf>
  801f3d:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801f40:	a1 20 44 80 00       	mov    0x804420,%eax
  801f45:	8b 50 74             	mov    0x74(%eax),%edx
  801f48:	85 d2                	test   %edx,%edx
  801f4a:	74 e4                	je     801f30 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801f4c:	85 db                	test   %ebx,%ebx
  801f4e:	74 05                	je     801f55 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801f50:	8b 40 74             	mov    0x74(%eax),%eax
  801f53:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f55:	a1 20 44 80 00       	mov    0x804420,%eax
  801f5a:	8b 40 70             	mov    0x70(%eax),%eax

}
  801f5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5e                   	pop    %esi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    

00801f64 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	57                   	push   %edi
  801f68:	56                   	push   %esi
  801f69:	53                   	push   %ebx
  801f6a:	83 ec 0c             	sub    $0xc,%esp
  801f6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f70:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801f76:	85 db                	test   %ebx,%ebx
  801f78:	75 13                	jne    801f8d <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801f7a:	6a 00                	push   $0x0
  801f7c:	68 00 00 c0 ee       	push   $0xeec00000
  801f81:	56                   	push   %esi
  801f82:	57                   	push   %edi
  801f83:	e8 d4 ef ff ff       	call   800f5c <sys_ipc_try_send>
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	eb 0e                	jmp    801f9b <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801f8d:	ff 75 14             	pushl  0x14(%ebp)
  801f90:	53                   	push   %ebx
  801f91:	56                   	push   %esi
  801f92:	57                   	push   %edi
  801f93:	e8 c4 ef ff ff       	call   800f5c <sys_ipc_try_send>
  801f98:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	75 d7                	jne    801f76 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801f9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa2:	5b                   	pop    %ebx
  801fa3:	5e                   	pop    %esi
  801fa4:	5f                   	pop    %edi
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    

00801fa7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fb5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fbb:	8b 52 50             	mov    0x50(%edx),%edx
  801fbe:	39 ca                	cmp    %ecx,%edx
  801fc0:	75 0d                	jne    801fcf <ipc_find_env+0x28>
			return envs[i].env_id;
  801fc2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fca:	8b 40 48             	mov    0x48(%eax),%eax
  801fcd:	eb 0f                	jmp    801fde <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fcf:	83 c0 01             	add    $0x1,%eax
  801fd2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fd7:	75 d9                	jne    801fb2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

00801fe0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe6:	89 d0                	mov    %edx,%eax
  801fe8:	c1 e8 16             	shr    $0x16,%eax
  801feb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff7:	f6 c1 01             	test   $0x1,%cl
  801ffa:	74 1d                	je     802019 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ffc:	c1 ea 0c             	shr    $0xc,%edx
  801fff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802006:	f6 c2 01             	test   $0x1,%dl
  802009:	74 0e                	je     802019 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80200b:	c1 ea 0c             	shr    $0xc,%edx
  80200e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802015:	ef 
  802016:	0f b7 c0             	movzwl %ax,%eax
}
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    
  80201b:	66 90                	xchg   %ax,%ax
  80201d:	66 90                	xchg   %ax,%ax
  80201f:	90                   	nop

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 1c             	sub    $0x1c,%esp
  802027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80202b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80202f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802037:	85 f6                	test   %esi,%esi
  802039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203d:	89 ca                	mov    %ecx,%edx
  80203f:	89 f8                	mov    %edi,%eax
  802041:	75 3d                	jne    802080 <__udivdi3+0x60>
  802043:	39 cf                	cmp    %ecx,%edi
  802045:	0f 87 c5 00 00 00    	ja     802110 <__udivdi3+0xf0>
  80204b:	85 ff                	test   %edi,%edi
  80204d:	89 fd                	mov    %edi,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f7                	div    %edi
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 c8                	mov    %ecx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c1                	mov    %eax,%ecx
  802064:	89 d8                	mov    %ebx,%eax
  802066:	89 cf                	mov    %ecx,%edi
  802068:	f7 f5                	div    %ebp
  80206a:	89 c3                	mov    %eax,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	39 ce                	cmp    %ecx,%esi
  802082:	77 74                	ja     8020f8 <__udivdi3+0xd8>
  802084:	0f bd fe             	bsr    %esi,%edi
  802087:	83 f7 1f             	xor    $0x1f,%edi
  80208a:	0f 84 98 00 00 00    	je     802128 <__udivdi3+0x108>
  802090:	bb 20 00 00 00       	mov    $0x20,%ebx
  802095:	89 f9                	mov    %edi,%ecx
  802097:	89 c5                	mov    %eax,%ebp
  802099:	29 fb                	sub    %edi,%ebx
  80209b:	d3 e6                	shl    %cl,%esi
  80209d:	89 d9                	mov    %ebx,%ecx
  80209f:	d3 ed                	shr    %cl,%ebp
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	09 ee                	or     %ebp,%esi
  8020a7:	89 d9                	mov    %ebx,%ecx
  8020a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ad:	89 d5                	mov    %edx,%ebp
  8020af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020b3:	d3 ed                	shr    %cl,%ebp
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e2                	shl    %cl,%edx
  8020b9:	89 d9                	mov    %ebx,%ecx
  8020bb:	d3 e8                	shr    %cl,%eax
  8020bd:	09 c2                	or     %eax,%edx
  8020bf:	89 d0                	mov    %edx,%eax
  8020c1:	89 ea                	mov    %ebp,%edx
  8020c3:	f7 f6                	div    %esi
  8020c5:	89 d5                	mov    %edx,%ebp
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	f7 64 24 0c          	mull   0xc(%esp)
  8020cd:	39 d5                	cmp    %edx,%ebp
  8020cf:	72 10                	jb     8020e1 <__udivdi3+0xc1>
  8020d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e6                	shl    %cl,%esi
  8020d9:	39 c6                	cmp    %eax,%esi
  8020db:	73 07                	jae    8020e4 <__udivdi3+0xc4>
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	75 03                	jne    8020e4 <__udivdi3+0xc4>
  8020e1:	83 eb 01             	sub    $0x1,%ebx
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 d8                	mov    %ebx,%eax
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	31 db                	xor    %ebx,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	f7 f7                	div    %edi
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 c3                	mov    %eax,%ebx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 fa                	mov    %edi,%edx
  80211c:	83 c4 1c             	add    $0x1c,%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	39 ce                	cmp    %ecx,%esi
  80212a:	72 0c                	jb     802138 <__udivdi3+0x118>
  80212c:	31 db                	xor    %ebx,%ebx
  80212e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802132:	0f 87 34 ff ff ff    	ja     80206c <__udivdi3+0x4c>
  802138:	bb 01 00 00 00       	mov    $0x1,%ebx
  80213d:	e9 2a ff ff ff       	jmp    80206c <__udivdi3+0x4c>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 d2                	test   %edx,%edx
  802169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f3                	mov    %esi,%ebx
  802173:	89 3c 24             	mov    %edi,(%esp)
  802176:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217a:	75 1c                	jne    802198 <__umoddi3+0x48>
  80217c:	39 f7                	cmp    %esi,%edi
  80217e:	76 50                	jbe    8021d0 <__umoddi3+0x80>
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	f7 f7                	div    %edi
  802186:	89 d0                	mov    %edx,%eax
  802188:	31 d2                	xor    %edx,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	89 d0                	mov    %edx,%eax
  80219c:	77 52                	ja     8021f0 <__umoddi3+0xa0>
  80219e:	0f bd ea             	bsr    %edx,%ebp
  8021a1:	83 f5 1f             	xor    $0x1f,%ebp
  8021a4:	75 5a                	jne    802200 <__umoddi3+0xb0>
  8021a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021aa:	0f 82 e0 00 00 00    	jb     802290 <__umoddi3+0x140>
  8021b0:	39 0c 24             	cmp    %ecx,(%esp)
  8021b3:	0f 86 d7 00 00 00    	jbe    802290 <__umoddi3+0x140>
  8021b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021c1:	83 c4 1c             	add    $0x1c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	89 fd                	mov    %edi,%ebp
  8021d4:	75 0b                	jne    8021e1 <__umoddi3+0x91>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f7                	div    %edi
  8021df:	89 c5                	mov    %eax,%ebp
  8021e1:	89 f0                	mov    %esi,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f5                	div    %ebp
  8021e7:	89 c8                	mov    %ecx,%eax
  8021e9:	f7 f5                	div    %ebp
  8021eb:	89 d0                	mov    %edx,%eax
  8021ed:	eb 99                	jmp    802188 <__umoddi3+0x38>
  8021ef:	90                   	nop
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	8b 34 24             	mov    (%esp),%esi
  802203:	bf 20 00 00 00       	mov    $0x20,%edi
  802208:	89 e9                	mov    %ebp,%ecx
  80220a:	29 ef                	sub    %ebp,%edi
  80220c:	d3 e0                	shl    %cl,%eax
  80220e:	89 f9                	mov    %edi,%ecx
  802210:	89 f2                	mov    %esi,%edx
  802212:	d3 ea                	shr    %cl,%edx
  802214:	89 e9                	mov    %ebp,%ecx
  802216:	09 c2                	or     %eax,%edx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 14 24             	mov    %edx,(%esp)
  80221d:	89 f2                	mov    %esi,%edx
  80221f:	d3 e2                	shl    %cl,%edx
  802221:	89 f9                	mov    %edi,%ecx
  802223:	89 54 24 04          	mov    %edx,0x4(%esp)
  802227:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	89 c6                	mov    %eax,%esi
  802231:	d3 e3                	shl    %cl,%ebx
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 d0                	mov    %edx,%eax
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	09 d8                	or     %ebx,%eax
  80223d:	89 d3                	mov    %edx,%ebx
  80223f:	89 f2                	mov    %esi,%edx
  802241:	f7 34 24             	divl   (%esp)
  802244:	89 d6                	mov    %edx,%esi
  802246:	d3 e3                	shl    %cl,%ebx
  802248:	f7 64 24 04          	mull   0x4(%esp)
  80224c:	39 d6                	cmp    %edx,%esi
  80224e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802252:	89 d1                	mov    %edx,%ecx
  802254:	89 c3                	mov    %eax,%ebx
  802256:	72 08                	jb     802260 <__umoddi3+0x110>
  802258:	75 11                	jne    80226b <__umoddi3+0x11b>
  80225a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80225e:	73 0b                	jae    80226b <__umoddi3+0x11b>
  802260:	2b 44 24 04          	sub    0x4(%esp),%eax
  802264:	1b 14 24             	sbb    (%esp),%edx
  802267:	89 d1                	mov    %edx,%ecx
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80226f:	29 da                	sub    %ebx,%edx
  802271:	19 ce                	sbb    %ecx,%esi
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 f0                	mov    %esi,%eax
  802277:	d3 e0                	shl    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	d3 ea                	shr    %cl,%edx
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	d3 ee                	shr    %cl,%esi
  802281:	09 d0                	or     %edx,%eax
  802283:	89 f2                	mov    %esi,%edx
  802285:	83 c4 1c             	add    $0x1c,%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	29 f9                	sub    %edi,%ecx
  802292:	19 d6                	sbb    %edx,%esi
  802294:	89 74 24 04          	mov    %esi,0x4(%esp)
  802298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80229c:	e9 18 ff ff ff       	jmp    8021b9 <__umoddi3+0x69>
