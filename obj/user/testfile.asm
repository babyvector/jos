
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 e9 0c 00 00       	call   800d30 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 6b 13 00 00       	call   8013c4 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 19 13 00 00       	call   801381 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 ab 12 00 00       	call   801324 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 c0 23 80 00       	mov    $0x8023c0,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 cb 23 80 00       	push   $0x8023cb
  8000ad:	6a 20                	push   $0x20
  8000af:	68 e5 23 80 00       	push   $0x8023e5
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 80 25 80 00       	push   $0x802580
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 e5 23 80 00       	push   $0x8023e5
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 f5 23 80 00       	mov    $0x8023f5,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 fe 23 80 00       	push   $0x8023fe
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 e5 23 80 00       	push   $0x8023e5
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 a4 25 80 00       	push   $0x8025a4
  800119:	6a 27                	push   $0x27
  80011b:	68 e5 23 80 00       	push   $0x8023e5
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 16 24 80 00       	push   $0x802416
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 2a 24 80 00       	push   $0x80242a
  800154:	6a 2b                	push   $0x2b
  800156:	68 e5 23 80 00       	push   $0x8023e5
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 89 0b 00 00       	call   800cf7 <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 73 0b 00 00       	call   800cf7 <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 d4 25 80 00       	push   $0x8025d4
  80018f:	6a 2d                	push   $0x2d
  800191:	68 e5 23 80 00       	push   $0x8023e5
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 38 24 80 00       	push   $0x802438
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 b7 0c 00 00       	call   800e75 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 4b 24 80 00       	push   $0x80244b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 e5 23 80 00       	push   $0x8023e5
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 da 0b 00 00       	call   800dda <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 59 24 80 00       	push   $0x802459
  80020f:	6a 34                	push   $0x34
  800211:	68 e5 23 80 00       	push   $0x8023e5
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 77 24 80 00       	push   $0x802477
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 8a 24 80 00       	push   $0x80248a
  800242:	6a 38                	push   $0x38
  800244:	68 e5 23 80 00       	push   $0x8023e5
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 99 24 80 00       	push   $0x802499
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 2e 0f 00 00       	call   8011b8 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 fc 25 80 00       	push   $0x8025fc
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 e5 23 80 00       	push   $0x8023e5
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ad 24 80 00       	push   $0x8024ad
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 c3 24 80 00       	mov    $0x8024c3,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 cd 24 80 00       	push   $0x8024cd
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 e5 23 80 00       	push   $0x8023e5
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 f1 09 00 00       	call   800cf7 <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 d0 09 00 00       	call   800cf7 <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 e6 24 80 00       	push   $0x8024e6
  800334:	6a 4b                	push   $0x4b
  800336:	68 e5 23 80 00       	push   $0x8023e5
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 f5 24 80 00       	push   $0x8024f5
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 08 0b 00 00       	call   800e75 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 34 26 80 00       	push   $0x802634
  800390:	6a 51                	push   $0x51
  800392:	68 e5 23 80 00       	push   $0x8023e5
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 4d 09 00 00       	call   800cf7 <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 54 26 80 00       	push   $0x802654
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 e5 23 80 00       	push   $0x8023e5
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 02 0a 00 00       	call   800dda <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 8c 26 80 00       	push   $0x80268c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 e5 23 80 00       	push   $0x8023e5
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 bc 26 80 00       	push   $0x8026bc
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 c0 23 80 00       	push   $0x8023c0
  80040a:	e8 4e 17 00 00       	call   801b5d <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 d1 23 80 00       	push   $0x8023d1
  800426:	6a 5a                	push   $0x5a
  800428:	68 e5 23 80 00       	push   $0x8023e5
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 09 25 80 00       	push   $0x802509
  80043e:	6a 5c                	push   $0x5c
  800440:	68 e5 23 80 00       	push   $0x8023e5
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 f5 23 80 00       	push   $0x8023f5
  800454:	e8 04 17 00 00       	call   801b5d <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 04 24 80 00       	push   $0x802404
  800466:	6a 5f                	push   $0x5f
  800468:	68 e5 23 80 00       	push   $0x8023e5
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 e0 26 80 00       	push   $0x8026e0
  800498:	6a 62                	push   $0x62
  80049a:	68 e5 23 80 00       	push   $0x8023e5
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 1c 24 80 00       	push   $0x80241c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 24 25 80 00       	push   $0x802524
  8004be:	e8 9a 16 00 00       	call   801b5d <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 29 25 80 00       	push   $0x802529
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 e5 23 80 00       	push   $0x8023e5
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 81 09 00 00       	call   800e75 <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 9c 12 00 00       	call   8017b3 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 38 25 80 00       	push   $0x802538
  800528:	6a 6c                	push   $0x6c
  80052a:	68 e5 23 80 00       	push   $0x8023e5
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 51 10 00 00       	call   80159d <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 24 25 80 00       	push   $0x802524
  800556:	e8 02 16 00 00       	call   801b5d <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 4a 25 80 00       	push   $0x80254a
  80056a:	6a 71                	push   $0x71
  80056c:	68 e5 23 80 00       	push   $0x8023e5
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 d4 11 00 00       	call   80176a <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 58 25 80 00       	push   $0x802558
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 e5 23 80 00       	push   $0x8023e5
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 08 27 80 00       	push   $0x802708
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 e5 23 80 00       	push   $0x8023e5
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 34 27 80 00       	push   $0x802734
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 e5 23 80 00       	push   $0x8023e5
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 8c 0f 00 00       	call   80159d <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 69 25 80 00 	movl   $0x802569,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 bd 0a 00 00       	call   8010f5 <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 4f 0f 00 00       	call   8015c8 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 31 0a 00 00       	call   8010b4 <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800696:	e8 5a 0a 00 00       	call   8010f5 <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 8c 27 80 00       	push   $0x80278c
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 d7 2b 80 00 	movl   $0x802bd7,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 79 09 00 00       	call   801077 <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 54 01 00 00       	call   800898 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 1e 09 00 00       	call   801077 <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 57 19 00 00       	call   802120 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 44 1a 00 00       	call   802250 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 af 27 80 00 	movsbl 0x8027af(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800827:	83 fa 01             	cmp    $0x1,%edx
  80082a:	7e 0e                	jle    80083a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	8b 52 04             	mov    0x4(%edx),%edx
  800838:	eb 22                	jmp    80085c <getuint+0x38>
	else if (lflag)
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 10                	je     80084e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 04             	lea    0x4(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 0e                	jmp    80085c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800864:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	3b 50 04             	cmp    0x4(%eax),%edx
  80086d:	73 0a                	jae    800879 <sprintputch+0x1b>
		*b->buf++ = ch;
  80086f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800872:	89 08                	mov    %ecx,(%eax)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	88 02                	mov    %al,(%edx)
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 05 00 00 00       	call   800898 <vprintfmt>
	va_end(ap);
}
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	83 ec 2c             	sub    $0x2c,%esp
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008aa:	eb 12                	jmp    8008be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 84 d3 03 00 00    	je     800c87 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	50                   	push   %eax
  8008b9:	ff d6                	call   *%esi
  8008bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c5:	83 f8 25             	cmp    $0x25,%eax
  8008c8:	75 e2                	jne    8008ac <vprintfmt+0x14>
  8008ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d5:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8008dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e8:	eb 07                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ed:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	8d 47 01             	lea    0x1(%edi),%eax
  8008f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f7:	0f b6 07             	movzbl (%edi),%eax
  8008fa:	0f b6 c8             	movzbl %al,%ecx
  8008fd:	83 e8 23             	sub    $0x23,%eax
  800900:	3c 55                	cmp    $0x55,%al
  800902:	0f 87 64 03 00 00    	ja     800c6c <vprintfmt+0x3d4>
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800915:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800919:	eb d6                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800926:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800929:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80092d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800930:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800933:	83 fa 09             	cmp    $0x9,%edx
  800936:	77 39                	ja     800971 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800938:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80093b:	eb e9                	jmp    800926 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8d 48 04             	lea    0x4(%eax),%ecx
  800943:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800946:	8b 00                	mov    (%eax),%eax
  800948:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80094e:	eb 27                	jmp    800977 <vprintfmt+0xdf>
  800950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800953:	85 c0                	test   %eax,%eax
  800955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095a:	0f 49 c8             	cmovns %eax,%ecx
  80095d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800963:	eb 8c                	jmp    8008f1 <vprintfmt+0x59>
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800968:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80096f:	eb 80                	jmp    8008f1 <vprintfmt+0x59>
  800971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800974:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800977:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097b:	0f 89 70 ff ff ff    	jns    8008f1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800981:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800984:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800987:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80098e:	e9 5e ff ff ff       	jmp    8008f1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800993:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800999:	e9 53 ff ff ff       	jmp    8008f1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	53                   	push   %ebx
  8009ab:	ff 30                	pushl  (%eax)
  8009ad:	ff d6                	call   *%esi
			break;
  8009af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009b5:	e9 04 ff ff ff       	jmp    8008be <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8d 50 04             	lea    0x4(%eax),%edx
  8009c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c3:	8b 00                	mov    (%eax),%eax
  8009c5:	99                   	cltd   
  8009c6:	31 d0                	xor    %edx,%eax
  8009c8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ca:	83 f8 0f             	cmp    $0xf,%eax
  8009cd:	7f 0b                	jg     8009da <vprintfmt+0x142>
  8009cf:	8b 14 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%edx
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	75 18                	jne    8009f2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009da:	50                   	push   %eax
  8009db:	68 c7 27 80 00       	push   $0x8027c7
  8009e0:	53                   	push   %ebx
  8009e1:	56                   	push   %esi
  8009e2:	e8 94 fe ff ff       	call   80087b <printfmt>
  8009e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009ed:	e9 cc fe ff ff       	jmp    8008be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009f2:	52                   	push   %edx
  8009f3:	68 a5 2b 80 00       	push   $0x802ba5
  8009f8:	53                   	push   %ebx
  8009f9:	56                   	push   %esi
  8009fa:	e8 7c fe ff ff       	call   80087b <printfmt>
  8009ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a05:	e9 b4 fe ff ff       	jmp    8008be <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8d 50 04             	lea    0x4(%eax),%edx
  800a10:	89 55 14             	mov    %edx,0x14(%ebp)
  800a13:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a15:	85 ff                	test   %edi,%edi
  800a17:	b8 c0 27 80 00       	mov    $0x8027c0,%eax
  800a1c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a23:	0f 8e 94 00 00 00    	jle    800abd <vprintfmt+0x225>
  800a29:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a2d:	0f 84 98 00 00 00    	je     800acb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	ff 75 c8             	pushl  -0x38(%ebp)
  800a39:	57                   	push   %edi
  800a3a:	e8 d0 02 00 00       	call   800d0f <strnlen>
  800a3f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a42:	29 c1                	sub    %eax,%ecx
  800a44:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800a47:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a4a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a51:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a54:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a56:	eb 0f                	jmp    800a67 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	53                   	push   %ebx
  800a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	85 ff                	test   %edi,%edi
  800a69:	7f ed                	jg     800a58 <vprintfmt+0x1c0>
  800a6b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a6e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	0f 49 c1             	cmovns %ecx,%eax
  800a7b:	29 c1                	sub    %eax,%ecx
  800a7d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a80:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800a83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a86:	89 cb                	mov    %ecx,%ebx
  800a88:	eb 4d                	jmp    800ad7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a8a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a8e:	74 1b                	je     800aab <vprintfmt+0x213>
  800a90:	0f be c0             	movsbl %al,%eax
  800a93:	83 e8 20             	sub    $0x20,%eax
  800a96:	83 f8 5e             	cmp    $0x5e,%eax
  800a99:	76 10                	jbe    800aab <vprintfmt+0x213>
					putch('?', putdat);
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	6a 3f                	push   $0x3f
  800aa3:	ff 55 08             	call   *0x8(%ebp)
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	eb 0d                	jmp    800ab8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	52                   	push   %edx
  800ab2:	ff 55 08             	call   *0x8(%ebp)
  800ab5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab8:	83 eb 01             	sub    $0x1,%ebx
  800abb:	eb 1a                	jmp    800ad7 <vprintfmt+0x23f>
  800abd:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800ac3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ac9:	eb 0c                	jmp    800ad7 <vprintfmt+0x23f>
  800acb:	89 75 08             	mov    %esi,0x8(%ebp)
  800ace:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800ad1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad7:	83 c7 01             	add    $0x1,%edi
  800ada:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ade:	0f be d0             	movsbl %al,%edx
  800ae1:	85 d2                	test   %edx,%edx
  800ae3:	74 23                	je     800b08 <vprintfmt+0x270>
  800ae5:	85 f6                	test   %esi,%esi
  800ae7:	78 a1                	js     800a8a <vprintfmt+0x1f2>
  800ae9:	83 ee 01             	sub    $0x1,%esi
  800aec:	79 9c                	jns    800a8a <vprintfmt+0x1f2>
  800aee:	89 df                	mov    %ebx,%edi
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af6:	eb 18                	jmp    800b10 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	53                   	push   %ebx
  800afc:	6a 20                	push   $0x20
  800afe:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb 08                	jmp    800b10 <vprintfmt+0x278>
  800b08:	89 df                	mov    %ebx,%edi
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	7f e4                	jg     800af8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b17:	e9 a2 fd ff ff       	jmp    8008be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1c:	83 fa 01             	cmp    $0x1,%edx
  800b1f:	7e 16                	jle    800b37 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b21:	8b 45 14             	mov    0x14(%ebp),%eax
  800b24:	8d 50 08             	lea    0x8(%eax),%edx
  800b27:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2a:	8b 50 04             	mov    0x4(%eax),%edx
  800b2d:	8b 00                	mov    (%eax),%eax
  800b2f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800b32:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800b35:	eb 32                	jmp    800b69 <vprintfmt+0x2d1>
	else if (lflag)
  800b37:	85 d2                	test   %edx,%edx
  800b39:	74 18                	je     800b53 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3e:	8d 50 04             	lea    0x4(%eax),%edx
  800b41:	89 55 14             	mov    %edx,0x14(%ebp)
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800b49:	89 c1                	mov    %eax,%ecx
  800b4b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b4e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800b51:	eb 16                	jmp    800b69 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  800b56:	8d 50 04             	lea    0x4(%eax),%edx
  800b59:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5c:	8b 00                	mov    (%eax),%eax
  800b5e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	c1 f9 1f             	sar    $0x1f,%ecx
  800b66:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b69:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800b6c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b72:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b75:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b7a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800b7e:	0f 89 b0 00 00 00    	jns    800c34 <vprintfmt+0x39c>
				putch('-', putdat);
  800b84:	83 ec 08             	sub    $0x8,%esp
  800b87:	53                   	push   %ebx
  800b88:	6a 2d                	push   $0x2d
  800b8a:	ff d6                	call   *%esi
				num = -(long long) num;
  800b8c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800b8f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b92:	f7 d8                	neg    %eax
  800b94:	83 d2 00             	adc    $0x0,%edx
  800b97:	f7 da                	neg    %edx
  800b99:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b9c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b9f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ba2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba7:	e9 88 00 00 00       	jmp    800c34 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bac:	8d 45 14             	lea    0x14(%ebp),%eax
  800baf:	e8 70 fc ff ff       	call   800824 <getuint>
  800bb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bb7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800bba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800bbf:	eb 73                	jmp    800c34 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800bc1:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc4:	e8 5b fc ff ff       	call   800824 <getuint>
  800bc9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bcc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800bcf:	83 ec 08             	sub    $0x8,%esp
  800bd2:	53                   	push   %ebx
  800bd3:	6a 58                	push   $0x58
  800bd5:	ff d6                	call   *%esi
			putch('X', putdat);
  800bd7:	83 c4 08             	add    $0x8,%esp
  800bda:	53                   	push   %ebx
  800bdb:	6a 58                	push   $0x58
  800bdd:	ff d6                	call   *%esi
			putch('X', putdat);
  800bdf:	83 c4 08             	add    $0x8,%esp
  800be2:	53                   	push   %ebx
  800be3:	6a 58                	push   $0x58
  800be5:	ff d6                	call   *%esi
			goto number;
  800be7:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800bea:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800bef:	eb 43                	jmp    800c34 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800bf1:	83 ec 08             	sub    $0x8,%esp
  800bf4:	53                   	push   %ebx
  800bf5:	6a 30                	push   $0x30
  800bf7:	ff d6                	call   *%esi
			putch('x', putdat);
  800bf9:	83 c4 08             	add    $0x8,%esp
  800bfc:	53                   	push   %ebx
  800bfd:	6a 78                	push   $0x78
  800bff:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c01:	8b 45 14             	mov    0x14(%ebp),%eax
  800c04:	8d 50 04             	lea    0x4(%eax),%edx
  800c07:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800c0a:	8b 00                	mov    (%eax),%eax
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c14:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c17:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c1a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c1f:	eb 13                	jmp    800c34 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c21:	8d 45 14             	lea    0x14(%ebp),%eax
  800c24:	e8 fb fb ff ff       	call   800824 <getuint>
  800c29:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c2c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800c2f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800c3b:	52                   	push   %edx
  800c3c:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3f:	50                   	push   %eax
  800c40:	ff 75 dc             	pushl  -0x24(%ebp)
  800c43:	ff 75 d8             	pushl  -0x28(%ebp)
  800c46:	89 da                	mov    %ebx,%edx
  800c48:	89 f0                	mov    %esi,%eax
  800c4a:	e8 26 fb ff ff       	call   800775 <printnum>
			break;
  800c4f:	83 c4 20             	add    $0x20,%esp
  800c52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c55:	e9 64 fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c5a:	83 ec 08             	sub    $0x8,%esp
  800c5d:	53                   	push   %ebx
  800c5e:	51                   	push   %ecx
  800c5f:	ff d6                	call   *%esi
			break;
  800c61:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c67:	e9 52 fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c6c:	83 ec 08             	sub    $0x8,%esp
  800c6f:	53                   	push   %ebx
  800c70:	6a 25                	push   $0x25
  800c72:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c74:	83 c4 10             	add    $0x10,%esp
  800c77:	eb 03                	jmp    800c7c <vprintfmt+0x3e4>
  800c79:	83 ef 01             	sub    $0x1,%edi
  800c7c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c80:	75 f7                	jne    800c79 <vprintfmt+0x3e1>
  800c82:	e9 37 fc ff ff       	jmp    8008be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 18             	sub    $0x18,%esp
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c9e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	74 26                	je     800cd6 <vsnprintf+0x47>
  800cb0:	85 d2                	test   %edx,%edx
  800cb2:	7e 22                	jle    800cd6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb4:	ff 75 14             	pushl  0x14(%ebp)
  800cb7:	ff 75 10             	pushl  0x10(%ebp)
  800cba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cbd:	50                   	push   %eax
  800cbe:	68 5e 08 80 00       	push   $0x80085e
  800cc3:	e8 d0 fb ff ff       	call   800898 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ccb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd1:	83 c4 10             	add    $0x10,%esp
  800cd4:	eb 05                	jmp    800cdb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ce6:	50                   	push   %eax
  800ce7:	ff 75 10             	pushl  0x10(%ebp)
  800cea:	ff 75 0c             	pushl  0xc(%ebp)
  800ced:	ff 75 08             	pushl  0x8(%ebp)
  800cf0:	e8 9a ff ff ff       	call   800c8f <vsnprintf>
	va_end(ap);

	return rc;
}
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	eb 03                	jmp    800d07 <strlen+0x10>
		n++;
  800d04:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d07:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d0b:	75 f7                	jne    800d04 <strlen+0xd>
		n++;
	return n;
}
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d15:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d18:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1d:	eb 03                	jmp    800d22 <strnlen+0x13>
		n++;
  800d1f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d22:	39 c2                	cmp    %eax,%edx
  800d24:	74 08                	je     800d2e <strnlen+0x1f>
  800d26:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d2a:	75 f3                	jne    800d1f <strnlen+0x10>
  800d2c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	53                   	push   %ebx
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d3a:	89 c2                	mov    %eax,%edx
  800d3c:	83 c2 01             	add    $0x1,%edx
  800d3f:	83 c1 01             	add    $0x1,%ecx
  800d42:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d46:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d49:	84 db                	test   %bl,%bl
  800d4b:	75 ef                	jne    800d3c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d4d:	5b                   	pop    %ebx
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	53                   	push   %ebx
  800d54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d57:	53                   	push   %ebx
  800d58:	e8 9a ff ff ff       	call   800cf7 <strlen>
  800d5d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d60:	ff 75 0c             	pushl  0xc(%ebp)
  800d63:	01 d8                	add    %ebx,%eax
  800d65:	50                   	push   %eax
  800d66:	e8 c5 ff ff ff       	call   800d30 <strcpy>
	return dst;
}
  800d6b:	89 d8                	mov    %ebx,%eax
  800d6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d70:	c9                   	leave  
  800d71:	c3                   	ret    

00800d72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
  800d77:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	89 f3                	mov    %esi,%ebx
  800d7f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d82:	89 f2                	mov    %esi,%edx
  800d84:	eb 0f                	jmp    800d95 <strncpy+0x23>
		*dst++ = *src;
  800d86:	83 c2 01             	add    $0x1,%edx
  800d89:	0f b6 01             	movzbl (%ecx),%eax
  800d8c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d8f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d92:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d95:	39 da                	cmp    %ebx,%edx
  800d97:	75 ed                	jne    800d86 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d99:	89 f0                	mov    %esi,%eax
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 75 08             	mov    0x8(%ebp),%esi
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	8b 55 10             	mov    0x10(%ebp),%edx
  800dad:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800daf:	85 d2                	test   %edx,%edx
  800db1:	74 21                	je     800dd4 <strlcpy+0x35>
  800db3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800db7:	89 f2                	mov    %esi,%edx
  800db9:	eb 09                	jmp    800dc4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	83 c1 01             	add    $0x1,%ecx
  800dc1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dc4:	39 c2                	cmp    %eax,%edx
  800dc6:	74 09                	je     800dd1 <strlcpy+0x32>
  800dc8:	0f b6 19             	movzbl (%ecx),%ebx
  800dcb:	84 db                	test   %bl,%bl
  800dcd:	75 ec                	jne    800dbb <strlcpy+0x1c>
  800dcf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800dd1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dd4:	29 f0                	sub    %esi,%eax
}
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de3:	eb 06                	jmp    800deb <strcmp+0x11>
		p++, q++;
  800de5:	83 c1 01             	add    $0x1,%ecx
  800de8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800deb:	0f b6 01             	movzbl (%ecx),%eax
  800dee:	84 c0                	test   %al,%al
  800df0:	74 04                	je     800df6 <strcmp+0x1c>
  800df2:	3a 02                	cmp    (%edx),%al
  800df4:	74 ef                	je     800de5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800df6:	0f b6 c0             	movzbl %al,%eax
  800df9:	0f b6 12             	movzbl (%edx),%edx
  800dfc:	29 d0                	sub    %edx,%eax
}
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	53                   	push   %ebx
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e0f:	eb 06                	jmp    800e17 <strncmp+0x17>
		n--, p++, q++;
  800e11:	83 c0 01             	add    $0x1,%eax
  800e14:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e17:	39 d8                	cmp    %ebx,%eax
  800e19:	74 15                	je     800e30 <strncmp+0x30>
  800e1b:	0f b6 08             	movzbl (%eax),%ecx
  800e1e:	84 c9                	test   %cl,%cl
  800e20:	74 04                	je     800e26 <strncmp+0x26>
  800e22:	3a 0a                	cmp    (%edx),%cl
  800e24:	74 eb                	je     800e11 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e26:	0f b6 00             	movzbl (%eax),%eax
  800e29:	0f b6 12             	movzbl (%edx),%edx
  800e2c:	29 d0                	sub    %edx,%eax
  800e2e:	eb 05                	jmp    800e35 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e35:	5b                   	pop    %ebx
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e42:	eb 07                	jmp    800e4b <strchr+0x13>
		if (*s == c)
  800e44:	38 ca                	cmp    %cl,%dl
  800e46:	74 0f                	je     800e57 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e48:	83 c0 01             	add    $0x1,%eax
  800e4b:	0f b6 10             	movzbl (%eax),%edx
  800e4e:	84 d2                	test   %dl,%dl
  800e50:	75 f2                	jne    800e44 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e63:	eb 03                	jmp    800e68 <strfind+0xf>
  800e65:	83 c0 01             	add    $0x1,%eax
  800e68:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e6b:	38 ca                	cmp    %cl,%dl
  800e6d:	74 04                	je     800e73 <strfind+0x1a>
  800e6f:	84 d2                	test   %dl,%dl
  800e71:	75 f2                	jne    800e65 <strfind+0xc>
			break;
	return (char *) s;
}
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
  800e7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e81:	85 c9                	test   %ecx,%ecx
  800e83:	74 36                	je     800ebb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e85:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e8b:	75 28                	jne    800eb5 <memset+0x40>
  800e8d:	f6 c1 03             	test   $0x3,%cl
  800e90:	75 23                	jne    800eb5 <memset+0x40>
		c &= 0xFF;
  800e92:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e96:	89 d3                	mov    %edx,%ebx
  800e98:	c1 e3 08             	shl    $0x8,%ebx
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	c1 e6 18             	shl    $0x18,%esi
  800ea0:	89 d0                	mov    %edx,%eax
  800ea2:	c1 e0 10             	shl    $0x10,%eax
  800ea5:	09 f0                	or     %esi,%eax
  800ea7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ea9:	89 d8                	mov    %ebx,%eax
  800eab:	09 d0                	or     %edx,%eax
  800ead:	c1 e9 02             	shr    $0x2,%ecx
  800eb0:	fc                   	cld    
  800eb1:	f3 ab                	rep stos %eax,%es:(%edi)
  800eb3:	eb 06                	jmp    800ebb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb8:	fc                   	cld    
  800eb9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ebb:	89 f8                	mov    %edi,%eax
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ecd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ed0:	39 c6                	cmp    %eax,%esi
  800ed2:	73 35                	jae    800f09 <memmove+0x47>
  800ed4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ed7:	39 d0                	cmp    %edx,%eax
  800ed9:	73 2e                	jae    800f09 <memmove+0x47>
		s += n;
		d += n;
  800edb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ede:	89 d6                	mov    %edx,%esi
  800ee0:	09 fe                	or     %edi,%esi
  800ee2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ee8:	75 13                	jne    800efd <memmove+0x3b>
  800eea:	f6 c1 03             	test   $0x3,%cl
  800eed:	75 0e                	jne    800efd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800eef:	83 ef 04             	sub    $0x4,%edi
  800ef2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ef5:	c1 e9 02             	shr    $0x2,%ecx
  800ef8:	fd                   	std    
  800ef9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800efb:	eb 09                	jmp    800f06 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800efd:	83 ef 01             	sub    $0x1,%edi
  800f00:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f03:	fd                   	std    
  800f04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f06:	fc                   	cld    
  800f07:	eb 1d                	jmp    800f26 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f09:	89 f2                	mov    %esi,%edx
  800f0b:	09 c2                	or     %eax,%edx
  800f0d:	f6 c2 03             	test   $0x3,%dl
  800f10:	75 0f                	jne    800f21 <memmove+0x5f>
  800f12:	f6 c1 03             	test   $0x3,%cl
  800f15:	75 0a                	jne    800f21 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f17:	c1 e9 02             	shr    $0x2,%ecx
  800f1a:	89 c7                	mov    %eax,%edi
  800f1c:	fc                   	cld    
  800f1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1f:	eb 05                	jmp    800f26 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f21:	89 c7                	mov    %eax,%edi
  800f23:	fc                   	cld    
  800f24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f2d:	ff 75 10             	pushl  0x10(%ebp)
  800f30:	ff 75 0c             	pushl  0xc(%ebp)
  800f33:	ff 75 08             	pushl  0x8(%ebp)
  800f36:	e8 87 ff ff ff       	call   800ec2 <memmove>
}
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f48:	89 c6                	mov    %eax,%esi
  800f4a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4d:	eb 1a                	jmp    800f69 <memcmp+0x2c>
		if (*s1 != *s2)
  800f4f:	0f b6 08             	movzbl (%eax),%ecx
  800f52:	0f b6 1a             	movzbl (%edx),%ebx
  800f55:	38 d9                	cmp    %bl,%cl
  800f57:	74 0a                	je     800f63 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f59:	0f b6 c1             	movzbl %cl,%eax
  800f5c:	0f b6 db             	movzbl %bl,%ebx
  800f5f:	29 d8                	sub    %ebx,%eax
  800f61:	eb 0f                	jmp    800f72 <memcmp+0x35>
		s1++, s2++;
  800f63:	83 c0 01             	add    $0x1,%eax
  800f66:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f69:	39 f0                	cmp    %esi,%eax
  800f6b:	75 e2                	jne    800f4f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	53                   	push   %ebx
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f7d:	89 c1                	mov    %eax,%ecx
  800f7f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f82:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f86:	eb 0a                	jmp    800f92 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f88:	0f b6 10             	movzbl (%eax),%edx
  800f8b:	39 da                	cmp    %ebx,%edx
  800f8d:	74 07                	je     800f96 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f8f:	83 c0 01             	add    $0x1,%eax
  800f92:	39 c8                	cmp    %ecx,%eax
  800f94:	72 f2                	jb     800f88 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f96:	5b                   	pop    %ebx
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fa5:	eb 03                	jmp    800faa <strtol+0x11>
		s++;
  800fa7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800faa:	0f b6 01             	movzbl (%ecx),%eax
  800fad:	3c 20                	cmp    $0x20,%al
  800faf:	74 f6                	je     800fa7 <strtol+0xe>
  800fb1:	3c 09                	cmp    $0x9,%al
  800fb3:	74 f2                	je     800fa7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fb5:	3c 2b                	cmp    $0x2b,%al
  800fb7:	75 0a                	jne    800fc3 <strtol+0x2a>
		s++;
  800fb9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fbc:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc1:	eb 11                	jmp    800fd4 <strtol+0x3b>
  800fc3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fc8:	3c 2d                	cmp    $0x2d,%al
  800fca:	75 08                	jne    800fd4 <strtol+0x3b>
		s++, neg = 1;
  800fcc:	83 c1 01             	add    $0x1,%ecx
  800fcf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fd4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fda:	75 15                	jne    800ff1 <strtol+0x58>
  800fdc:	80 39 30             	cmpb   $0x30,(%ecx)
  800fdf:	75 10                	jne    800ff1 <strtol+0x58>
  800fe1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fe5:	75 7c                	jne    801063 <strtol+0xca>
		s += 2, base = 16;
  800fe7:	83 c1 02             	add    $0x2,%ecx
  800fea:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fef:	eb 16                	jmp    801007 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ff1:	85 db                	test   %ebx,%ebx
  800ff3:	75 12                	jne    801007 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ff5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ffa:	80 39 30             	cmpb   $0x30,(%ecx)
  800ffd:	75 08                	jne    801007 <strtol+0x6e>
		s++, base = 8;
  800fff:	83 c1 01             	add    $0x1,%ecx
  801002:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801007:	b8 00 00 00 00       	mov    $0x0,%eax
  80100c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80100f:	0f b6 11             	movzbl (%ecx),%edx
  801012:	8d 72 d0             	lea    -0x30(%edx),%esi
  801015:	89 f3                	mov    %esi,%ebx
  801017:	80 fb 09             	cmp    $0x9,%bl
  80101a:	77 08                	ja     801024 <strtol+0x8b>
			dig = *s - '0';
  80101c:	0f be d2             	movsbl %dl,%edx
  80101f:	83 ea 30             	sub    $0x30,%edx
  801022:	eb 22                	jmp    801046 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801024:	8d 72 9f             	lea    -0x61(%edx),%esi
  801027:	89 f3                	mov    %esi,%ebx
  801029:	80 fb 19             	cmp    $0x19,%bl
  80102c:	77 08                	ja     801036 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80102e:	0f be d2             	movsbl %dl,%edx
  801031:	83 ea 57             	sub    $0x57,%edx
  801034:	eb 10                	jmp    801046 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801036:	8d 72 bf             	lea    -0x41(%edx),%esi
  801039:	89 f3                	mov    %esi,%ebx
  80103b:	80 fb 19             	cmp    $0x19,%bl
  80103e:	77 16                	ja     801056 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801040:	0f be d2             	movsbl %dl,%edx
  801043:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801046:	3b 55 10             	cmp    0x10(%ebp),%edx
  801049:	7d 0b                	jge    801056 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80104b:	83 c1 01             	add    $0x1,%ecx
  80104e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801052:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801054:	eb b9                	jmp    80100f <strtol+0x76>

	if (endptr)
  801056:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80105a:	74 0d                	je     801069 <strtol+0xd0>
		*endptr = (char *) s;
  80105c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80105f:	89 0e                	mov    %ecx,(%esi)
  801061:	eb 06                	jmp    801069 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801063:	85 db                	test   %ebx,%ebx
  801065:	74 98                	je     800fff <strtol+0x66>
  801067:	eb 9e                	jmp    801007 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801069:	89 c2                	mov    %eax,%edx
  80106b:	f7 da                	neg    %edx
  80106d:	85 ff                	test   %edi,%edi
  80106f:	0f 45 c2             	cmovne %edx,%eax
}
  801072:	5b                   	pop    %ebx
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	57                   	push   %edi
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801085:	8b 55 08             	mov    0x8(%ebp),%edx
  801088:	89 c3                	mov    %eax,%ebx
  80108a:	89 c7                	mov    %eax,%edi
  80108c:	89 c6                	mov    %eax,%esi
  80108e:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_cgetc>:

int
sys_cgetc(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80109b:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a5:	89 d1                	mov    %edx,%ecx
  8010a7:	89 d3                	mov    %edx,%ebx
  8010a9:	89 d7                	mov    %edx,%edi
  8010ab:	89 d6                	mov    %edx,%esi
  8010ad:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8010bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ca:	89 cb                	mov    %ecx,%ebx
  8010cc:	89 cf                	mov    %ecx,%edi
  8010ce:	89 ce                	mov    %ecx,%esi
  8010d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	7e 17                	jle    8010ed <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	50                   	push   %eax
  8010da:	6a 03                	push   $0x3
  8010dc:	68 bf 2a 80 00       	push   $0x802abf
  8010e1:	6a 23                	push   $0x23
  8010e3:	68 dc 2a 80 00       	push   $0x802adc
  8010e8:	e8 9b f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8010fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801100:	b8 02 00 00 00       	mov    $0x2,%eax
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 d3                	mov    %edx,%ebx
  801109:	89 d7                	mov    %edx,%edi
  80110b:	89 d6                	mov    %edx,%esi
  80110d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_yield>:

void
sys_yield(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80111a:	ba 00 00 00 00       	mov    $0x0,%edx
  80111f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801124:	89 d1                	mov    %edx,%ecx
  801126:	89 d3                	mov    %edx,%ebx
  801128:	89 d7                	mov    %edx,%edi
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80113c:	be 00 00 00 00       	mov    $0x0,%esi
  801141:	b8 04 00 00 00       	mov    $0x4,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114f:	89 f7                	mov    %esi,%edi
  801151:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801153:	85 c0                	test   %eax,%eax
  801155:	7e 17                	jle    80116e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	50                   	push   %eax
  80115b:	6a 04                	push   $0x4
  80115d:	68 bf 2a 80 00       	push   $0x802abf
  801162:	6a 23                	push   $0x23
  801164:	68 dc 2a 80 00       	push   $0x802adc
  801169:	e8 1a f5 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80116e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801171:	5b                   	pop    %ebx
  801172:	5e                   	pop    %esi
  801173:	5f                   	pop    %edi
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	57                   	push   %edi
  80117a:	56                   	push   %esi
  80117b:	53                   	push   %ebx
  80117c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80117f:	b8 05 00 00 00       	mov    $0x5,%eax
  801184:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801187:	8b 55 08             	mov    0x8(%ebp),%edx
  80118a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80118d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801190:	8b 75 18             	mov    0x18(%ebp),%esi
  801193:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801195:	85 c0                	test   %eax,%eax
  801197:	7e 17                	jle    8011b0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	50                   	push   %eax
  80119d:	6a 05                	push   $0x5
  80119f:	68 bf 2a 80 00       	push   $0x802abf
  8011a4:	6a 23                	push   $0x23
  8011a6:	68 dc 2a 80 00       	push   $0x802adc
  8011ab:	e8 d8 f4 ff ff       	call   800688 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	57                   	push   %edi
  8011bc:	56                   	push   %esi
  8011bd:	53                   	push   %ebx
  8011be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8011c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8011cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d1:	89 df                	mov    %ebx,%edi
  8011d3:	89 de                	mov    %ebx,%esi
  8011d5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	7e 17                	jle    8011f2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	50                   	push   %eax
  8011df:	6a 06                	push   $0x6
  8011e1:	68 bf 2a 80 00       	push   $0x802abf
  8011e6:	6a 23                	push   $0x23
  8011e8:	68 dc 2a 80 00       	push   $0x802adc
  8011ed:	e8 96 f4 ff ff       	call   800688 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	57                   	push   %edi
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
  801200:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801203:	bb 00 00 00 00       	mov    $0x0,%ebx
  801208:	b8 08 00 00 00       	mov    $0x8,%eax
  80120d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801210:	8b 55 08             	mov    0x8(%ebp),%edx
  801213:	89 df                	mov    %ebx,%edi
  801215:	89 de                	mov    %ebx,%esi
  801217:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801219:	85 c0                	test   %eax,%eax
  80121b:	7e 17                	jle    801234 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121d:	83 ec 0c             	sub    $0xc,%esp
  801220:	50                   	push   %eax
  801221:	6a 08                	push   $0x8
  801223:	68 bf 2a 80 00       	push   $0x802abf
  801228:	6a 23                	push   $0x23
  80122a:	68 dc 2a 80 00       	push   $0x802adc
  80122f:	e8 54 f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801234:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124a:	b8 09 00 00 00       	mov    $0x9,%eax
  80124f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801252:	8b 55 08             	mov    0x8(%ebp),%edx
  801255:	89 df                	mov    %ebx,%edi
  801257:	89 de                	mov    %ebx,%esi
  801259:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80125b:	85 c0                	test   %eax,%eax
  80125d:	7e 17                	jle    801276 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125f:	83 ec 0c             	sub    $0xc,%esp
  801262:	50                   	push   %eax
  801263:	6a 09                	push   $0x9
  801265:	68 bf 2a 80 00       	push   $0x802abf
  80126a:	6a 23                	push   $0x23
  80126c:	68 dc 2a 80 00       	push   $0x802adc
  801271:	e8 12 f4 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801279:	5b                   	pop    %ebx
  80127a:	5e                   	pop    %esi
  80127b:	5f                   	pop    %edi
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801291:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801294:	8b 55 08             	mov    0x8(%ebp),%edx
  801297:	89 df                	mov    %ebx,%edi
  801299:	89 de                	mov    %ebx,%esi
  80129b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80129d:	85 c0                	test   %eax,%eax
  80129f:	7e 17                	jle    8012b8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	50                   	push   %eax
  8012a5:	6a 0a                	push   $0xa
  8012a7:	68 bf 2a 80 00       	push   $0x802abf
  8012ac:	6a 23                	push   $0x23
  8012ae:	68 dc 2a 80 00       	push   $0x802adc
  8012b3:	e8 d0 f3 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5f                   	pop    %edi
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	57                   	push   %edi
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8012c6:	be 00 00 00 00       	mov    $0x0,%esi
  8012cb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012dc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5f                   	pop    %edi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	57                   	push   %edi
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8012ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f9:	89 cb                	mov    %ecx,%ebx
  8012fb:	89 cf                	mov    %ecx,%edi
  8012fd:	89 ce                	mov    %ecx,%esi
  8012ff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801301:	85 c0                	test   %eax,%eax
  801303:	7e 17                	jle    80131c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801305:	83 ec 0c             	sub    $0xc,%esp
  801308:	50                   	push   %eax
  801309:	6a 0d                	push   $0xd
  80130b:	68 bf 2a 80 00       	push   $0x802abf
  801310:	6a 23                	push   $0x23
  801312:	68 dc 2a 80 00       	push   $0x802adc
  801317:	e8 6c f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80131c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80132c:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  80132f:	83 ec 0c             	sub    $0xc,%esp
  801332:	ff 75 0c             	pushl  0xc(%ebp)
  801335:	e8 a9 ff ff ff       	call   8012e3 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 f6                	test   %esi,%esi
  80133f:	74 1c                	je     80135d <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801341:	a1 04 40 80 00       	mov    0x804004,%eax
  801346:	8b 40 78             	mov    0x78(%eax),%eax
  801349:	89 06                	mov    %eax,(%esi)
  80134b:	eb 10                	jmp    80135d <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  80134d:	83 ec 0c             	sub    $0xc,%esp
  801350:	68 ea 2a 80 00       	push   $0x802aea
  801355:	e8 07 f4 ff ff       	call   800761 <cprintf>
  80135a:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  80135d:	a1 04 40 80 00       	mov    0x804004,%eax
  801362:	8b 50 74             	mov    0x74(%eax),%edx
  801365:	85 d2                	test   %edx,%edx
  801367:	74 e4                	je     80134d <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801369:	85 db                	test   %ebx,%ebx
  80136b:	74 05                	je     801372 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  80136d:	8b 40 74             	mov    0x74(%eax),%eax
  801370:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801372:	a1 04 40 80 00       	mov    0x804004,%eax
  801377:	8b 40 70             	mov    0x70(%eax),%eax

}
  80137a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	57                   	push   %edi
  801385:	56                   	push   %esi
  801386:	53                   	push   %ebx
  801387:	83 ec 0c             	sub    $0xc,%esp
  80138a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801390:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801393:	85 db                	test   %ebx,%ebx
  801395:	75 13                	jne    8013aa <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801397:	6a 00                	push   $0x0
  801399:	68 00 00 c0 ee       	push   $0xeec00000
  80139e:	56                   	push   %esi
  80139f:	57                   	push   %edi
  8013a0:	e8 1b ff ff ff       	call   8012c0 <sys_ipc_try_send>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	eb 0e                	jmp    8013b8 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  8013aa:	ff 75 14             	pushl  0x14(%ebp)
  8013ad:	53                   	push   %ebx
  8013ae:	56                   	push   %esi
  8013af:	57                   	push   %edi
  8013b0:	e8 0b ff ff ff       	call   8012c0 <sys_ipc_try_send>
  8013b5:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	75 d7                	jne    801393 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  8013bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013ca:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013cf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013d2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013d8:	8b 52 50             	mov    0x50(%edx),%edx
  8013db:	39 ca                	cmp    %ecx,%edx
  8013dd:	75 0d                	jne    8013ec <ipc_find_env+0x28>
			return envs[i].env_id;
  8013df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013e7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ea:	eb 0f                	jmp    8013fb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013ec:	83 c0 01             	add    $0x1,%eax
  8013ef:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013f4:	75 d9                	jne    8013cf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801400:	8b 45 08             	mov    0x8(%ebp),%eax
  801403:	05 00 00 00 30       	add    $0x30000000,%eax
  801408:	c1 e8 0c             	shr    $0xc,%eax
}
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	05 00 00 00 30       	add    $0x30000000,%eax
  801418:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80141d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80142f:	89 c2                	mov    %eax,%edx
  801431:	c1 ea 16             	shr    $0x16,%edx
  801434:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143b:	f6 c2 01             	test   $0x1,%dl
  80143e:	74 11                	je     801451 <fd_alloc+0x2d>
  801440:	89 c2                	mov    %eax,%edx
  801442:	c1 ea 0c             	shr    $0xc,%edx
  801445:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144c:	f6 c2 01             	test   $0x1,%dl
  80144f:	75 09                	jne    80145a <fd_alloc+0x36>
			*fd_store = fd;
  801451:	89 01                	mov    %eax,(%ecx)
			return 0;
  801453:	b8 00 00 00 00       	mov    $0x0,%eax
  801458:	eb 17                	jmp    801471 <fd_alloc+0x4d>
  80145a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80145f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801464:	75 c9                	jne    80142f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801466:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80146c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801479:	83 f8 1f             	cmp    $0x1f,%eax
  80147c:	77 36                	ja     8014b4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80147e:	c1 e0 0c             	shl    $0xc,%eax
  801481:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801486:	89 c2                	mov    %eax,%edx
  801488:	c1 ea 16             	shr    $0x16,%edx
  80148b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801492:	f6 c2 01             	test   $0x1,%dl
  801495:	74 24                	je     8014bb <fd_lookup+0x48>
  801497:	89 c2                	mov    %eax,%edx
  801499:	c1 ea 0c             	shr    $0xc,%edx
  80149c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a3:	f6 c2 01             	test   $0x1,%dl
  8014a6:	74 1a                	je     8014c2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ab:	89 02                	mov    %eax,(%edx)
	return 0;
  8014ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b2:	eb 13                	jmp    8014c7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b9:	eb 0c                	jmp    8014c7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c0:	eb 05                	jmp    8014c7 <fd_lookup+0x54>
  8014c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d2:	ba 7c 2b 80 00       	mov    $0x802b7c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014d7:	eb 13                	jmp    8014ec <dev_lookup+0x23>
  8014d9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014dc:	39 08                	cmp    %ecx,(%eax)
  8014de:	75 0c                	jne    8014ec <dev_lookup+0x23>
			*dev = devtab[i];
  8014e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ea:	eb 2e                	jmp    80151a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ec:	8b 02                	mov    (%edx),%eax
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	75 e7                	jne    8014d9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f7:	8b 40 48             	mov    0x48(%eax),%eax
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	51                   	push   %ecx
  8014fe:	50                   	push   %eax
  8014ff:	68 fc 2a 80 00       	push   $0x802afc
  801504:	e8 58 f2 ff ff       	call   800761 <cprintf>
	*dev = 0;
  801509:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80151a:	c9                   	leave  
  80151b:	c3                   	ret    

0080151c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	83 ec 10             	sub    $0x10,%esp
  801524:	8b 75 08             	mov    0x8(%ebp),%esi
  801527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80152a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801534:	c1 e8 0c             	shr    $0xc,%eax
  801537:	50                   	push   %eax
  801538:	e8 36 ff ff ff       	call   801473 <fd_lookup>
  80153d:	83 c4 08             	add    $0x8,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 05                	js     801549 <fd_close+0x2d>
	    || fd != fd2)
  801544:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801547:	74 0c                	je     801555 <fd_close+0x39>
		return (must_exist ? r : 0);
  801549:	84 db                	test   %bl,%bl
  80154b:	ba 00 00 00 00       	mov    $0x0,%edx
  801550:	0f 44 c2             	cmove  %edx,%eax
  801553:	eb 41                	jmp    801596 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801555:	83 ec 08             	sub    $0x8,%esp
  801558:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155b:	50                   	push   %eax
  80155c:	ff 36                	pushl  (%esi)
  80155e:	e8 66 ff ff ff       	call   8014c9 <dev_lookup>
  801563:	89 c3                	mov    %eax,%ebx
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 1a                	js     801586 <fd_close+0x6a>
		if (dev->dev_close)
  80156c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801572:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801577:	85 c0                	test   %eax,%eax
  801579:	74 0b                	je     801586 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80157b:	83 ec 0c             	sub    $0xc,%esp
  80157e:	56                   	push   %esi
  80157f:	ff d0                	call   *%eax
  801581:	89 c3                	mov    %eax,%ebx
  801583:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	56                   	push   %esi
  80158a:	6a 00                	push   $0x0
  80158c:	e8 27 fc ff ff       	call   8011b8 <sys_page_unmap>
	return r;
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	89 d8                	mov    %ebx,%eax
}
  801596:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801599:	5b                   	pop    %ebx
  80159a:	5e                   	pop    %esi
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    

0080159d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	ff 75 08             	pushl  0x8(%ebp)
  8015aa:	e8 c4 fe ff ff       	call   801473 <fd_lookup>
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 10                	js     8015c6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	6a 01                	push   $0x1
  8015bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015be:	e8 59 ff ff ff       	call   80151c <fd_close>
  8015c3:	83 c4 10             	add    $0x10,%esp
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <close_all>:

void
close_all(void)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	53                   	push   %ebx
  8015d8:	e8 c0 ff ff ff       	call   80159d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015dd:	83 c3 01             	add    $0x1,%ebx
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	83 fb 20             	cmp    $0x20,%ebx
  8015e6:	75 ec                	jne    8015d4 <close_all+0xc>
		close(i);
}
  8015e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015eb:	c9                   	leave  
  8015ec:	c3                   	ret    

008015ed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	57                   	push   %edi
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 2c             	sub    $0x2c,%esp
  8015f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	ff 75 08             	pushl  0x8(%ebp)
  801600:	e8 6e fe ff ff       	call   801473 <fd_lookup>
  801605:	83 c4 08             	add    $0x8,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	0f 88 c1 00 00 00    	js     8016d1 <dup+0xe4>
		return r;
	close(newfdnum);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	56                   	push   %esi
  801614:	e8 84 ff ff ff       	call   80159d <close>

	newfd = INDEX2FD(newfdnum);
  801619:	89 f3                	mov    %esi,%ebx
  80161b:	c1 e3 0c             	shl    $0xc,%ebx
  80161e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801624:	83 c4 04             	add    $0x4,%esp
  801627:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162a:	e8 de fd ff ff       	call   80140d <fd2data>
  80162f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801631:	89 1c 24             	mov    %ebx,(%esp)
  801634:	e8 d4 fd ff ff       	call   80140d <fd2data>
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80163f:	89 f8                	mov    %edi,%eax
  801641:	c1 e8 16             	shr    $0x16,%eax
  801644:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80164b:	a8 01                	test   $0x1,%al
  80164d:	74 37                	je     801686 <dup+0x99>
  80164f:	89 f8                	mov    %edi,%eax
  801651:	c1 e8 0c             	shr    $0xc,%eax
  801654:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80165b:	f6 c2 01             	test   $0x1,%dl
  80165e:	74 26                	je     801686 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801660:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801667:	83 ec 0c             	sub    $0xc,%esp
  80166a:	25 07 0e 00 00       	and    $0xe07,%eax
  80166f:	50                   	push   %eax
  801670:	ff 75 d4             	pushl  -0x2c(%ebp)
  801673:	6a 00                	push   $0x0
  801675:	57                   	push   %edi
  801676:	6a 00                	push   $0x0
  801678:	e8 f9 fa ff ff       	call   801176 <sys_page_map>
  80167d:	89 c7                	mov    %eax,%edi
  80167f:	83 c4 20             	add    $0x20,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	78 2e                	js     8016b4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801686:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801689:	89 d0                	mov    %edx,%eax
  80168b:	c1 e8 0c             	shr    $0xc,%eax
  80168e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	25 07 0e 00 00       	and    $0xe07,%eax
  80169d:	50                   	push   %eax
  80169e:	53                   	push   %ebx
  80169f:	6a 00                	push   $0x0
  8016a1:	52                   	push   %edx
  8016a2:	6a 00                	push   $0x0
  8016a4:	e8 cd fa ff ff       	call   801176 <sys_page_map>
  8016a9:	89 c7                	mov    %eax,%edi
  8016ab:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016ae:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b0:	85 ff                	test   %edi,%edi
  8016b2:	79 1d                	jns    8016d1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	53                   	push   %ebx
  8016b8:	6a 00                	push   $0x0
  8016ba:	e8 f9 fa ff ff       	call   8011b8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016bf:	83 c4 08             	add    $0x8,%esp
  8016c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016c5:	6a 00                	push   $0x0
  8016c7:	e8 ec fa ff ff       	call   8011b8 <sys_page_unmap>
	return r;
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	89 f8                	mov    %edi,%eax
}
  8016d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d4:	5b                   	pop    %ebx
  8016d5:	5e                   	pop    %esi
  8016d6:	5f                   	pop    %edi
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 14             	sub    $0x14,%esp
  8016e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	53                   	push   %ebx
  8016e8:	e8 86 fd ff ff       	call   801473 <fd_lookup>
  8016ed:	83 c4 08             	add    $0x8,%esp
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 6d                	js     801763 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f6:	83 ec 08             	sub    $0x8,%esp
  8016f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801700:	ff 30                	pushl  (%eax)
  801702:	e8 c2 fd ff ff       	call   8014c9 <dev_lookup>
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 4c                	js     80175a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80170e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801711:	8b 42 08             	mov    0x8(%edx),%eax
  801714:	83 e0 03             	and    $0x3,%eax
  801717:	83 f8 01             	cmp    $0x1,%eax
  80171a:	75 21                	jne    80173d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80171c:	a1 04 40 80 00       	mov    0x804004,%eax
  801721:	8b 40 48             	mov    0x48(%eax),%eax
  801724:	83 ec 04             	sub    $0x4,%esp
  801727:	53                   	push   %ebx
  801728:	50                   	push   %eax
  801729:	68 40 2b 80 00       	push   $0x802b40
  80172e:	e8 2e f0 ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80173b:	eb 26                	jmp    801763 <read+0x8a>
	}
	if (!dev->dev_read)
  80173d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801740:	8b 40 08             	mov    0x8(%eax),%eax
  801743:	85 c0                	test   %eax,%eax
  801745:	74 17                	je     80175e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	ff 75 10             	pushl  0x10(%ebp)
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	52                   	push   %edx
  801751:	ff d0                	call   *%eax
  801753:	89 c2                	mov    %eax,%edx
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	eb 09                	jmp    801763 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	eb 05                	jmp    801763 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80175e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801763:	89 d0                	mov    %edx,%eax
  801765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	57                   	push   %edi
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	83 ec 0c             	sub    $0xc,%esp
  801773:	8b 7d 08             	mov    0x8(%ebp),%edi
  801776:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801779:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177e:	eb 21                	jmp    8017a1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	89 f0                	mov    %esi,%eax
  801785:	29 d8                	sub    %ebx,%eax
  801787:	50                   	push   %eax
  801788:	89 d8                	mov    %ebx,%eax
  80178a:	03 45 0c             	add    0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	57                   	push   %edi
  80178f:	e8 45 ff ff ff       	call   8016d9 <read>
		if (m < 0)
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	85 c0                	test   %eax,%eax
  801799:	78 10                	js     8017ab <readn+0x41>
			return m;
		if (m == 0)
  80179b:	85 c0                	test   %eax,%eax
  80179d:	74 0a                	je     8017a9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80179f:	01 c3                	add    %eax,%ebx
  8017a1:	39 f3                	cmp    %esi,%ebx
  8017a3:	72 db                	jb     801780 <readn+0x16>
  8017a5:	89 d8                	mov    %ebx,%eax
  8017a7:	eb 02                	jmp    8017ab <readn+0x41>
  8017a9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5f                   	pop    %edi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 14             	sub    $0x14,%esp
  8017ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c0:	50                   	push   %eax
  8017c1:	53                   	push   %ebx
  8017c2:	e8 ac fc ff ff       	call   801473 <fd_lookup>
  8017c7:	83 c4 08             	add    $0x8,%esp
  8017ca:	89 c2                	mov    %eax,%edx
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 68                	js     801838 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017da:	ff 30                	pushl  (%eax)
  8017dc:	e8 e8 fc ff ff       	call   8014c9 <dev_lookup>
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 47                	js     80182f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ef:	75 21                	jne    801812 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f6:	8b 40 48             	mov    0x48(%eax),%eax
  8017f9:	83 ec 04             	sub    $0x4,%esp
  8017fc:	53                   	push   %ebx
  8017fd:	50                   	push   %eax
  8017fe:	68 5c 2b 80 00       	push   $0x802b5c
  801803:	e8 59 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801810:	eb 26                	jmp    801838 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801812:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801815:	8b 52 0c             	mov    0xc(%edx),%edx
  801818:	85 d2                	test   %edx,%edx
  80181a:	74 17                	je     801833 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80181c:	83 ec 04             	sub    $0x4,%esp
  80181f:	ff 75 10             	pushl  0x10(%ebp)
  801822:	ff 75 0c             	pushl  0xc(%ebp)
  801825:	50                   	push   %eax
  801826:	ff d2                	call   *%edx
  801828:	89 c2                	mov    %eax,%edx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	eb 09                	jmp    801838 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	89 c2                	mov    %eax,%edx
  801831:	eb 05                	jmp    801838 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801838:	89 d0                	mov    %edx,%eax
  80183a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <seek>:

int
seek(int fdnum, off_t offset)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801845:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801848:	50                   	push   %eax
  801849:	ff 75 08             	pushl  0x8(%ebp)
  80184c:	e8 22 fc ff ff       	call   801473 <fd_lookup>
  801851:	83 c4 08             	add    $0x8,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	78 0e                	js     801866 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801858:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80185b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	53                   	push   %ebx
  80186c:	83 ec 14             	sub    $0x14,%esp
  80186f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801872:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801875:	50                   	push   %eax
  801876:	53                   	push   %ebx
  801877:	e8 f7 fb ff ff       	call   801473 <fd_lookup>
  80187c:	83 c4 08             	add    $0x8,%esp
  80187f:	89 c2                	mov    %eax,%edx
  801881:	85 c0                	test   %eax,%eax
  801883:	78 65                	js     8018ea <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188b:	50                   	push   %eax
  80188c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188f:	ff 30                	pushl  (%eax)
  801891:	e8 33 fc ff ff       	call   8014c9 <dev_lookup>
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 44                	js     8018e1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a4:	75 21                	jne    8018c7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018a6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018ab:	8b 40 48             	mov    0x48(%eax),%eax
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	53                   	push   %ebx
  8018b2:	50                   	push   %eax
  8018b3:	68 1c 2b 80 00       	push   $0x802b1c
  8018b8:	e8 a4 ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018c5:	eb 23                	jmp    8018ea <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ca:	8b 52 18             	mov    0x18(%edx),%edx
  8018cd:	85 d2                	test   %edx,%edx
  8018cf:	74 14                	je     8018e5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	ff 75 0c             	pushl  0xc(%ebp)
  8018d7:	50                   	push   %eax
  8018d8:	ff d2                	call   *%edx
  8018da:	89 c2                	mov    %eax,%edx
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	eb 09                	jmp    8018ea <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e1:	89 c2                	mov    %eax,%edx
  8018e3:	eb 05                	jmp    8018ea <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018ea:	89 d0                	mov    %edx,%eax
  8018ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 14             	sub    $0x14,%esp
  8018f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fe:	50                   	push   %eax
  8018ff:	ff 75 08             	pushl  0x8(%ebp)
  801902:	e8 6c fb ff ff       	call   801473 <fd_lookup>
  801907:	83 c4 08             	add    $0x8,%esp
  80190a:	89 c2                	mov    %eax,%edx
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 58                	js     801968 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801916:	50                   	push   %eax
  801917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191a:	ff 30                	pushl  (%eax)
  80191c:	e8 a8 fb ff ff       	call   8014c9 <dev_lookup>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	78 37                	js     80195f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80192f:	74 32                	je     801963 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801931:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801934:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80193b:	00 00 00 
	stat->st_isdir = 0;
  80193e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801945:	00 00 00 
	stat->st_dev = dev;
  801948:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	53                   	push   %ebx
  801952:	ff 75 f0             	pushl  -0x10(%ebp)
  801955:	ff 50 14             	call   *0x14(%eax)
  801958:	89 c2                	mov    %eax,%edx
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	eb 09                	jmp    801968 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195f:	89 c2                	mov    %eax,%edx
  801961:	eb 05                	jmp    801968 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801963:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801968:	89 d0                	mov    %edx,%eax
  80196a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196d:	c9                   	leave  
  80196e:	c3                   	ret    

0080196f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	6a 00                	push   $0x0
  801979:	ff 75 08             	pushl  0x8(%ebp)
  80197c:	e8 dc 01 00 00       	call   801b5d <open>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	78 1b                	js     8019a5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80198a:	83 ec 08             	sub    $0x8,%esp
  80198d:	ff 75 0c             	pushl  0xc(%ebp)
  801990:	50                   	push   %eax
  801991:	e8 5b ff ff ff       	call   8018f1 <fstat>
  801996:	89 c6                	mov    %eax,%esi
	close(fd);
  801998:	89 1c 24             	mov    %ebx,(%esp)
  80199b:	e8 fd fb ff ff       	call   80159d <close>
	return r;
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	89 f0                	mov    %esi,%eax
}
  8019a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5d                   	pop    %ebp
  8019ab:	c3                   	ret    

008019ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	89 c6                	mov    %eax,%esi
  8019b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019bc:	75 12                	jne    8019d0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	6a 01                	push   $0x1
  8019c3:	e8 fc f9 ff ff       	call   8013c4 <ipc_find_env>
  8019c8:	a3 00 40 80 00       	mov    %eax,0x804000
  8019cd:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019d0:	6a 07                	push   $0x7
  8019d2:	68 00 50 80 00       	push   $0x805000
  8019d7:	56                   	push   %esi
  8019d8:	ff 35 00 40 80 00    	pushl  0x804000
  8019de:	e8 9e f9 ff ff       	call   801381 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8019e3:	83 c4 0c             	add    $0xc,%esp
  8019e6:	6a 00                	push   $0x0
  8019e8:	53                   	push   %ebx
  8019e9:	6a 00                	push   $0x0
  8019eb:	e8 34 f9 ff ff       	call   801324 <ipc_recv>
}
  8019f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f3:	5b                   	pop    %ebx
  8019f4:	5e                   	pop    %esi
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801a00:	8b 40 0c             	mov    0xc(%eax),%eax
  801a03:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a10:	ba 00 00 00 00       	mov    $0x0,%edx
  801a15:	b8 02 00 00 00       	mov    $0x2,%eax
  801a1a:	e8 8d ff ff ff       	call   8019ac <fsipc>
}
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a27:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
  801a37:	b8 06 00 00 00       	mov    $0x6,%eax
  801a3c:	e8 6b ff ff ff       	call   8019ac <fsipc>
}
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	53                   	push   %ebx
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a50:	8b 40 0c             	mov    0xc(%eax),%eax
  801a53:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a58:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5d:	b8 05 00 00 00       	mov    $0x5,%eax
  801a62:	e8 45 ff ff ff       	call   8019ac <fsipc>
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 2c                	js     801a97 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	68 00 50 80 00       	push   $0x805000
  801a73:	53                   	push   %ebx
  801a74:	e8 b7 f2 ff ff       	call   800d30 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a79:	a1 80 50 80 00       	mov    0x805080,%eax
  801a7e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a84:	a1 84 50 80 00       	mov    0x805084,%eax
  801a89:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aa5:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa8:	8b 52 0c             	mov    0xc(%edx),%edx
  801aab:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801ab1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ab6:	50                   	push   %eax
  801ab7:	ff 75 0c             	pushl  0xc(%ebp)
  801aba:	68 08 50 80 00       	push   $0x805008
  801abf:	e8 fe f3 ff ff       	call   800ec2 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	b8 04 00 00 00       	mov    $0x4,%eax
  801ace:	e8 d9 fe ff ff       	call   8019ac <fsipc>
	//panic("devfile_write not implemented");
}
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    

00801ad5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	56                   	push   %esi
  801ad9:	53                   	push   %ebx
  801ada:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801add:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ae8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aee:	ba 00 00 00 00       	mov    $0x0,%edx
  801af3:	b8 03 00 00 00       	mov    $0x3,%eax
  801af8:	e8 af fe ff ff       	call   8019ac <fsipc>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 51                	js     801b54 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801b03:	39 c6                	cmp    %eax,%esi
  801b05:	73 19                	jae    801b20 <devfile_read+0x4b>
  801b07:	68 8c 2b 80 00       	push   $0x802b8c
  801b0c:	68 93 2b 80 00       	push   $0x802b93
  801b11:	68 80 00 00 00       	push   $0x80
  801b16:	68 a8 2b 80 00       	push   $0x802ba8
  801b1b:	e8 68 eb ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801b20:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b25:	7e 19                	jle    801b40 <devfile_read+0x6b>
  801b27:	68 b3 2b 80 00       	push   $0x802bb3
  801b2c:	68 93 2b 80 00       	push   $0x802b93
  801b31:	68 81 00 00 00       	push   $0x81
  801b36:	68 a8 2b 80 00       	push   $0x802ba8
  801b3b:	e8 48 eb ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b40:	83 ec 04             	sub    $0x4,%esp
  801b43:	50                   	push   %eax
  801b44:	68 00 50 80 00       	push   $0x805000
  801b49:	ff 75 0c             	pushl  0xc(%ebp)
  801b4c:	e8 71 f3 ff ff       	call   800ec2 <memmove>
	return r;
  801b51:	83 c4 10             	add    $0x10,%esp
}
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	53                   	push   %ebx
  801b61:	83 ec 20             	sub    $0x20,%esp
  801b64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b67:	53                   	push   %ebx
  801b68:	e8 8a f1 ff ff       	call   800cf7 <strlen>
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b75:	7f 67                	jg     801bde <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7d:	50                   	push   %eax
  801b7e:	e8 a1 f8 ff ff       	call   801424 <fd_alloc>
  801b83:	83 c4 10             	add    $0x10,%esp
		return r;
  801b86:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 57                	js     801be3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	53                   	push   %ebx
  801b90:	68 00 50 80 00       	push   $0x805000
  801b95:	e8 96 f1 ff ff       	call   800d30 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9d:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ba2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ba5:	b8 01 00 00 00       	mov    $0x1,%eax
  801baa:	e8 fd fd ff ff       	call   8019ac <fsipc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	79 14                	jns    801bcc <open+0x6f>
		
		fd_close(fd, 0);
  801bb8:	83 ec 08             	sub    $0x8,%esp
  801bbb:	6a 00                	push   $0x0
  801bbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc0:	e8 57 f9 ff ff       	call   80151c <fd_close>
		return r;
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	89 da                	mov    %ebx,%edx
  801bca:	eb 17                	jmp    801be3 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd2:	e8 26 f8 ff ff       	call   8013fd <fd2num>
  801bd7:	89 c2                	mov    %eax,%edx
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	eb 05                	jmp    801be3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bde:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801be3:	89 d0                	mov    %edx,%eax
  801be5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf5:	b8 08 00 00 00       	mov    $0x8,%eax
  801bfa:	e8 ad fd ff ff       	call   8019ac <fsipc>
}
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    

00801c01 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	56                   	push   %esi
  801c05:	53                   	push   %ebx
  801c06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c09:	83 ec 0c             	sub    $0xc,%esp
  801c0c:	ff 75 08             	pushl  0x8(%ebp)
  801c0f:	e8 f9 f7 ff ff       	call   80140d <fd2data>
  801c14:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c16:	83 c4 08             	add    $0x8,%esp
  801c19:	68 bf 2b 80 00       	push   $0x802bbf
  801c1e:	53                   	push   %ebx
  801c1f:	e8 0c f1 ff ff       	call   800d30 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c24:	8b 46 04             	mov    0x4(%esi),%eax
  801c27:	2b 06                	sub    (%esi),%eax
  801c29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c2f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c36:	00 00 00 
	stat->st_dev = &devpipe;
  801c39:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c40:	30 80 00 
	return 0;
}
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
  801c48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	53                   	push   %ebx
  801c53:	83 ec 0c             	sub    $0xc,%esp
  801c56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c59:	53                   	push   %ebx
  801c5a:	6a 00                	push   $0x0
  801c5c:	e8 57 f5 ff ff       	call   8011b8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c61:	89 1c 24             	mov    %ebx,(%esp)
  801c64:	e8 a4 f7 ff ff       	call   80140d <fd2data>
  801c69:	83 c4 08             	add    $0x8,%esp
  801c6c:	50                   	push   %eax
  801c6d:	6a 00                	push   $0x0
  801c6f:	e8 44 f5 ff ff       	call   8011b8 <sys_page_unmap>
}
  801c74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	57                   	push   %edi
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	83 ec 1c             	sub    $0x1c,%esp
  801c82:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c85:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c87:	a1 04 40 80 00       	mov    0x804004,%eax
  801c8c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	ff 75 e0             	pushl  -0x20(%ebp)
  801c95:	e8 46 04 00 00       	call   8020e0 <pageref>
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	89 3c 24             	mov    %edi,(%esp)
  801c9f:	e8 3c 04 00 00       	call   8020e0 <pageref>
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	39 c3                	cmp    %eax,%ebx
  801ca9:	0f 94 c1             	sete   %cl
  801cac:	0f b6 c9             	movzbl %cl,%ecx
  801caf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cb2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cb8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cbb:	39 ce                	cmp    %ecx,%esi
  801cbd:	74 1b                	je     801cda <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cbf:	39 c3                	cmp    %eax,%ebx
  801cc1:	75 c4                	jne    801c87 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cc3:	8b 42 58             	mov    0x58(%edx),%eax
  801cc6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cc9:	50                   	push   %eax
  801cca:	56                   	push   %esi
  801ccb:	68 c6 2b 80 00       	push   $0x802bc6
  801cd0:	e8 8c ea ff ff       	call   800761 <cprintf>
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	eb ad                	jmp    801c87 <_pipeisclosed+0xe>
	}
}
  801cda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	57                   	push   %edi
  801ce9:	56                   	push   %esi
  801cea:	53                   	push   %ebx
  801ceb:	83 ec 28             	sub    $0x28,%esp
  801cee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cf1:	56                   	push   %esi
  801cf2:	e8 16 f7 ff ff       	call   80140d <fd2data>
  801cf7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	bf 00 00 00 00       	mov    $0x0,%edi
  801d01:	eb 4b                	jmp    801d4e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d03:	89 da                	mov    %ebx,%edx
  801d05:	89 f0                	mov    %esi,%eax
  801d07:	e8 6d ff ff ff       	call   801c79 <_pipeisclosed>
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	75 48                	jne    801d58 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d10:	e8 ff f3 ff ff       	call   801114 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d15:	8b 43 04             	mov    0x4(%ebx),%eax
  801d18:	8b 0b                	mov    (%ebx),%ecx
  801d1a:	8d 51 20             	lea    0x20(%ecx),%edx
  801d1d:	39 d0                	cmp    %edx,%eax
  801d1f:	73 e2                	jae    801d03 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d24:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d28:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d2b:	89 c2                	mov    %eax,%edx
  801d2d:	c1 fa 1f             	sar    $0x1f,%edx
  801d30:	89 d1                	mov    %edx,%ecx
  801d32:	c1 e9 1b             	shr    $0x1b,%ecx
  801d35:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d38:	83 e2 1f             	and    $0x1f,%edx
  801d3b:	29 ca                	sub    %ecx,%edx
  801d3d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d41:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d45:	83 c0 01             	add    $0x1,%eax
  801d48:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d4b:	83 c7 01             	add    $0x1,%edi
  801d4e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d51:	75 c2                	jne    801d15 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d53:	8b 45 10             	mov    0x10(%ebp),%eax
  801d56:	eb 05                	jmp    801d5d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d58:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d60:	5b                   	pop    %ebx
  801d61:	5e                   	pop    %esi
  801d62:	5f                   	pop    %edi
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    

00801d65 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	57                   	push   %edi
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	83 ec 18             	sub    $0x18,%esp
  801d6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d71:	57                   	push   %edi
  801d72:	e8 96 f6 ff ff       	call   80140d <fd2data>
  801d77:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d81:	eb 3d                	jmp    801dc0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d83:	85 db                	test   %ebx,%ebx
  801d85:	74 04                	je     801d8b <devpipe_read+0x26>
				return i;
  801d87:	89 d8                	mov    %ebx,%eax
  801d89:	eb 44                	jmp    801dcf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d8b:	89 f2                	mov    %esi,%edx
  801d8d:	89 f8                	mov    %edi,%eax
  801d8f:	e8 e5 fe ff ff       	call   801c79 <_pipeisclosed>
  801d94:	85 c0                	test   %eax,%eax
  801d96:	75 32                	jne    801dca <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d98:	e8 77 f3 ff ff       	call   801114 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d9d:	8b 06                	mov    (%esi),%eax
  801d9f:	3b 46 04             	cmp    0x4(%esi),%eax
  801da2:	74 df                	je     801d83 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da4:	99                   	cltd   
  801da5:	c1 ea 1b             	shr    $0x1b,%edx
  801da8:	01 d0                	add    %edx,%eax
  801daa:	83 e0 1f             	and    $0x1f,%eax
  801dad:	29 d0                	sub    %edx,%eax
  801daf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dba:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbd:	83 c3 01             	add    $0x1,%ebx
  801dc0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dc3:	75 d8                	jne    801d9d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc8:	eb 05                	jmp    801dcf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dca:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5f                   	pop    %edi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    

00801dd7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	56                   	push   %esi
  801ddb:	53                   	push   %ebx
  801ddc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ddf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de2:	50                   	push   %eax
  801de3:	e8 3c f6 ff ff       	call   801424 <fd_alloc>
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	89 c2                	mov    %eax,%edx
  801ded:	85 c0                	test   %eax,%eax
  801def:	0f 88 2c 01 00 00    	js     801f21 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	68 07 04 00 00       	push   $0x407
  801dfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801e00:	6a 00                	push   $0x0
  801e02:	e8 2c f3 ff ff       	call   801133 <sys_page_alloc>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	89 c2                	mov    %eax,%edx
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	0f 88 0d 01 00 00    	js     801f21 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e14:	83 ec 0c             	sub    $0xc,%esp
  801e17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e1a:	50                   	push   %eax
  801e1b:	e8 04 f6 ff ff       	call   801424 <fd_alloc>
  801e20:	89 c3                	mov    %eax,%ebx
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	85 c0                	test   %eax,%eax
  801e27:	0f 88 e2 00 00 00    	js     801f0f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2d:	83 ec 04             	sub    $0x4,%esp
  801e30:	68 07 04 00 00       	push   $0x407
  801e35:	ff 75 f0             	pushl  -0x10(%ebp)
  801e38:	6a 00                	push   $0x0
  801e3a:	e8 f4 f2 ff ff       	call   801133 <sys_page_alloc>
  801e3f:	89 c3                	mov    %eax,%ebx
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	85 c0                	test   %eax,%eax
  801e46:	0f 88 c3 00 00 00    	js     801f0f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e4c:	83 ec 0c             	sub    $0xc,%esp
  801e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e52:	e8 b6 f5 ff ff       	call   80140d <fd2data>
  801e57:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e59:	83 c4 0c             	add    $0xc,%esp
  801e5c:	68 07 04 00 00       	push   $0x407
  801e61:	50                   	push   %eax
  801e62:	6a 00                	push   $0x0
  801e64:	e8 ca f2 ff ff       	call   801133 <sys_page_alloc>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	0f 88 89 00 00 00    	js     801eff <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e76:	83 ec 0c             	sub    $0xc,%esp
  801e79:	ff 75 f0             	pushl  -0x10(%ebp)
  801e7c:	e8 8c f5 ff ff       	call   80140d <fd2data>
  801e81:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e88:	50                   	push   %eax
  801e89:	6a 00                	push   $0x0
  801e8b:	56                   	push   %esi
  801e8c:	6a 00                	push   $0x0
  801e8e:	e8 e3 f2 ff ff       	call   801176 <sys_page_map>
  801e93:	89 c3                	mov    %eax,%ebx
  801e95:	83 c4 20             	add    $0x20,%esp
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	78 55                	js     801ef1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e9c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eaa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eb1:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eba:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ebf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecc:	e8 2c f5 ff ff       	call   8013fd <fd2num>
  801ed1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ed6:	83 c4 04             	add    $0x4,%esp
  801ed9:	ff 75 f0             	pushl  -0x10(%ebp)
  801edc:	e8 1c f5 ff ff       	call   8013fd <fd2num>
  801ee1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	ba 00 00 00 00       	mov    $0x0,%edx
  801eef:	eb 30                	jmp    801f21 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ef1:	83 ec 08             	sub    $0x8,%esp
  801ef4:	56                   	push   %esi
  801ef5:	6a 00                	push   $0x0
  801ef7:	e8 bc f2 ff ff       	call   8011b8 <sys_page_unmap>
  801efc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801eff:	83 ec 08             	sub    $0x8,%esp
  801f02:	ff 75 f0             	pushl  -0x10(%ebp)
  801f05:	6a 00                	push   $0x0
  801f07:	e8 ac f2 ff ff       	call   8011b8 <sys_page_unmap>
  801f0c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f0f:	83 ec 08             	sub    $0x8,%esp
  801f12:	ff 75 f4             	pushl  -0xc(%ebp)
  801f15:	6a 00                	push   $0x0
  801f17:	e8 9c f2 ff ff       	call   8011b8 <sys_page_unmap>
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f21:	89 d0                	mov    %edx,%eax
  801f23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f26:	5b                   	pop    %ebx
  801f27:	5e                   	pop    %esi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f33:	50                   	push   %eax
  801f34:	ff 75 08             	pushl  0x8(%ebp)
  801f37:	e8 37 f5 ff ff       	call   801473 <fd_lookup>
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	78 18                	js     801f5b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	ff 75 f4             	pushl  -0xc(%ebp)
  801f49:	e8 bf f4 ff ff       	call   80140d <fd2data>
	return _pipeisclosed(fd, p);
  801f4e:	89 c2                	mov    %eax,%edx
  801f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f53:	e8 21 fd ff ff       	call   801c79 <_pipeisclosed>
  801f58:	83 c4 10             	add    $0x10,%esp
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    

00801f67 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f6d:	68 de 2b 80 00       	push   $0x802bde
  801f72:	ff 75 0c             	pushl  0xc(%ebp)
  801f75:	e8 b6 ed ff ff       	call   800d30 <strcpy>
	return 0;
}
  801f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	57                   	push   %edi
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f8d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f92:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f98:	eb 2d                	jmp    801fc7 <devcons_write+0x46>
		m = n - tot;
  801f9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f9d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f9f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fa2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fa7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801faa:	83 ec 04             	sub    $0x4,%esp
  801fad:	53                   	push   %ebx
  801fae:	03 45 0c             	add    0xc(%ebp),%eax
  801fb1:	50                   	push   %eax
  801fb2:	57                   	push   %edi
  801fb3:	e8 0a ef ff ff       	call   800ec2 <memmove>
		sys_cputs(buf, m);
  801fb8:	83 c4 08             	add    $0x8,%esp
  801fbb:	53                   	push   %ebx
  801fbc:	57                   	push   %edi
  801fbd:	e8 b5 f0 ff ff       	call   801077 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc2:	01 de                	add    %ebx,%esi
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	89 f0                	mov    %esi,%eax
  801fc9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fcc:	72 cc                	jb     801f9a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd1:	5b                   	pop    %ebx
  801fd2:	5e                   	pop    %esi
  801fd3:	5f                   	pop    %edi
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    

00801fd6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	83 ec 08             	sub    $0x8,%esp
  801fdc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fe1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe5:	74 2a                	je     802011 <devcons_read+0x3b>
  801fe7:	eb 05                	jmp    801fee <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fe9:	e8 26 f1 ff ff       	call   801114 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fee:	e8 a2 f0 ff ff       	call   801095 <sys_cgetc>
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	74 f2                	je     801fe9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	78 16                	js     802011 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ffb:	83 f8 04             	cmp    $0x4,%eax
  801ffe:	74 0c                	je     80200c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802000:	8b 55 0c             	mov    0xc(%ebp),%edx
  802003:	88 02                	mov    %al,(%edx)
	return 1;
  802005:	b8 01 00 00 00       	mov    $0x1,%eax
  80200a:	eb 05                	jmp    802011 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80200c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802011:	c9                   	leave  
  802012:	c3                   	ret    

00802013 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80201f:	6a 01                	push   $0x1
  802021:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802024:	50                   	push   %eax
  802025:	e8 4d f0 ff ff       	call   801077 <sys_cputs>
}
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    

0080202f <getchar>:

int
getchar(void)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802035:	6a 01                	push   $0x1
  802037:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80203a:	50                   	push   %eax
  80203b:	6a 00                	push   $0x0
  80203d:	e8 97 f6 ff ff       	call   8016d9 <read>
	if (r < 0)
  802042:	83 c4 10             	add    $0x10,%esp
  802045:	85 c0                	test   %eax,%eax
  802047:	78 0f                	js     802058 <getchar+0x29>
		return r;
	if (r < 1)
  802049:	85 c0                	test   %eax,%eax
  80204b:	7e 06                	jle    802053 <getchar+0x24>
		return -E_EOF;
	return c;
  80204d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802051:	eb 05                	jmp    802058 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802053:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802058:	c9                   	leave  
  802059:	c3                   	ret    

0080205a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802060:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802063:	50                   	push   %eax
  802064:	ff 75 08             	pushl  0x8(%ebp)
  802067:	e8 07 f4 ff ff       	call   801473 <fd_lookup>
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	85 c0                	test   %eax,%eax
  802071:	78 11                	js     802084 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802073:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802076:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80207c:	39 10                	cmp    %edx,(%eax)
  80207e:	0f 94 c0             	sete   %al
  802081:	0f b6 c0             	movzbl %al,%eax
}
  802084:	c9                   	leave  
  802085:	c3                   	ret    

00802086 <opencons>:

int
opencons(void)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80208c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208f:	50                   	push   %eax
  802090:	e8 8f f3 ff ff       	call   801424 <fd_alloc>
  802095:	83 c4 10             	add    $0x10,%esp
		return r;
  802098:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 3e                	js     8020dc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80209e:	83 ec 04             	sub    $0x4,%esp
  8020a1:	68 07 04 00 00       	push   $0x407
  8020a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a9:	6a 00                	push   $0x0
  8020ab:	e8 83 f0 ff ff       	call   801133 <sys_page_alloc>
  8020b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8020b3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b5:	85 c0                	test   %eax,%eax
  8020b7:	78 23                	js     8020dc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020b9:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020ce:	83 ec 0c             	sub    $0xc,%esp
  8020d1:	50                   	push   %eax
  8020d2:	e8 26 f3 ff ff       	call   8013fd <fd2num>
  8020d7:	89 c2                	mov    %eax,%edx
  8020d9:	83 c4 10             	add    $0x10,%esp
}
  8020dc:	89 d0                	mov    %edx,%eax
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	c1 e8 16             	shr    $0x16,%eax
  8020eb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f7:	f6 c1 01             	test   $0x1,%cl
  8020fa:	74 1d                	je     802119 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020fc:	c1 ea 0c             	shr    $0xc,%edx
  8020ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802106:	f6 c2 01             	test   $0x1,%dl
  802109:	74 0e                	je     802119 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80210b:	c1 ea 0c             	shr    $0xc,%edx
  80210e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802115:	ef 
  802116:	0f b7 c0             	movzwl %ax,%eax
}
  802119:	5d                   	pop    %ebp
  80211a:	c3                   	ret    
  80211b:	66 90                	xchg   %ax,%ax
  80211d:	66 90                	xchg   %ax,%ax
  80211f:	90                   	nop

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80212b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80212f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 f6                	test   %esi,%esi
  802139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213d:	89 ca                	mov    %ecx,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	75 3d                	jne    802180 <__udivdi3+0x60>
  802143:	39 cf                	cmp    %ecx,%edi
  802145:	0f 87 c5 00 00 00    	ja     802210 <__udivdi3+0xf0>
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 fd                	mov    %edi,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f7                	div    %edi
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 c8                	mov    %ecx,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c1                	mov    %eax,%ecx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	89 cf                	mov    %ecx,%edi
  802168:	f7 f5                	div    %ebp
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 ce                	cmp    %ecx,%esi
  802182:	77 74                	ja     8021f8 <__udivdi3+0xd8>
  802184:	0f bd fe             	bsr    %esi,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0x108>
  802190:	bb 20 00 00 00       	mov    $0x20,%ebx
  802195:	89 f9                	mov    %edi,%ecx
  802197:	89 c5                	mov    %eax,%ebp
  802199:	29 fb                	sub    %edi,%ebx
  80219b:	d3 e6                	shl    %cl,%esi
  80219d:	89 d9                	mov    %ebx,%ecx
  80219f:	d3 ed                	shr    %cl,%ebp
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	09 ee                	or     %ebp,%esi
  8021a7:	89 d9                	mov    %ebx,%ecx
  8021a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ad:	89 d5                	mov    %edx,%ebp
  8021af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b3:	d3 ed                	shr    %cl,%ebp
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e2                	shl    %cl,%edx
  8021b9:	89 d9                	mov    %ebx,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 c2                	or     %eax,%edx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	89 ea                	mov    %ebp,%edx
  8021c3:	f7 f6                	div    %esi
  8021c5:	89 d5                	mov    %edx,%ebp
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	72 10                	jb     8021e1 <__udivdi3+0xc1>
  8021d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e6                	shl    %cl,%esi
  8021d9:	39 c6                	cmp    %eax,%esi
  8021db:	73 07                	jae    8021e4 <__udivdi3+0xc4>
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	75 03                	jne    8021e4 <__udivdi3+0xc4>
  8021e1:	83 eb 01             	sub    $0x1,%ebx
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 d8                	mov    %ebx,%eax
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	31 db                	xor    %ebx,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	f7 f7                	div    %edi
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 c3                	mov    %eax,%ebx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	39 ce                	cmp    %ecx,%esi
  80222a:	72 0c                	jb     802238 <__udivdi3+0x118>
  80222c:	31 db                	xor    %ebx,%ebx
  80222e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802232:	0f 87 34 ff ff ff    	ja     80216c <__udivdi3+0x4c>
  802238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80223d:	e9 2a ff ff ff       	jmp    80216c <__udivdi3+0x4c>
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 d2                	test   %edx,%edx
  802269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f3                	mov    %esi,%ebx
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	75 1c                	jne    802298 <__umoddi3+0x48>
  80227c:	39 f7                	cmp    %esi,%edi
  80227e:	76 50                	jbe    8022d0 <__umoddi3+0x80>
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	f7 f7                	div    %edi
  802286:	89 d0                	mov    %edx,%eax
  802288:	31 d2                	xor    %edx,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	77 52                	ja     8022f0 <__umoddi3+0xa0>
  80229e:	0f bd ea             	bsr    %edx,%ebp
  8022a1:	83 f5 1f             	xor    $0x1f,%ebp
  8022a4:	75 5a                	jne    802300 <__umoddi3+0xb0>
  8022a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022aa:	0f 82 e0 00 00 00    	jb     802390 <__umoddi3+0x140>
  8022b0:	39 0c 24             	cmp    %ecx,(%esp)
  8022b3:	0f 86 d7 00 00 00    	jbe    802390 <__umoddi3+0x140>
  8022b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	85 ff                	test   %edi,%edi
  8022d2:	89 fd                	mov    %edi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x91>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f7                	div    %edi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f5                	div    %ebp
  8022e7:	89 c8                	mov    %ecx,%eax
  8022e9:	f7 f5                	div    %ebp
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	eb 99                	jmp    802288 <__umoddi3+0x38>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 1c             	add    $0x1c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	8b 34 24             	mov    (%esp),%esi
  802303:	bf 20 00 00 00       	mov    $0x20,%edi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	29 ef                	sub    %ebp,%edi
  80230c:	d3 e0                	shl    %cl,%eax
  80230e:	89 f9                	mov    %edi,%ecx
  802310:	89 f2                	mov    %esi,%edx
  802312:	d3 ea                	shr    %cl,%edx
  802314:	89 e9                	mov    %ebp,%ecx
  802316:	09 c2                	or     %eax,%edx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 14 24             	mov    %edx,(%esp)
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 f9                	mov    %edi,%ecx
  802323:	89 54 24 04          	mov    %edx,0x4(%esp)
  802327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	89 c6                	mov    %eax,%esi
  802331:	d3 e3                	shl    %cl,%ebx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 d0                	mov    %edx,%eax
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	09 d8                	or     %ebx,%eax
  80233d:	89 d3                	mov    %edx,%ebx
  80233f:	89 f2                	mov    %esi,%edx
  802341:	f7 34 24             	divl   (%esp)
  802344:	89 d6                	mov    %edx,%esi
  802346:	d3 e3                	shl    %cl,%ebx
  802348:	f7 64 24 04          	mull   0x4(%esp)
  80234c:	39 d6                	cmp    %edx,%esi
  80234e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802352:	89 d1                	mov    %edx,%ecx
  802354:	89 c3                	mov    %eax,%ebx
  802356:	72 08                	jb     802360 <__umoddi3+0x110>
  802358:	75 11                	jne    80236b <__umoddi3+0x11b>
  80235a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80235e:	73 0b                	jae    80236b <__umoddi3+0x11b>
  802360:	2b 44 24 04          	sub    0x4(%esp),%eax
  802364:	1b 14 24             	sbb    (%esp),%edx
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80236f:	29 da                	sub    %ebx,%edx
  802371:	19 ce                	sbb    %ecx,%esi
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e0                	shl    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	d3 ee                	shr    %cl,%esi
  802381:	09 d0                	or     %edx,%eax
  802383:	89 f2                	mov    %esi,%edx
  802385:	83 c4 1c             	add    $0x1c,%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	29 f9                	sub    %edi,%ecx
  802392:	19 d6                	sbb    %edx,%esi
  802394:	89 74 24 04          	mov    %esi,0x4(%esp)
  802398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80239c:	e9 18 ff ff ff       	jmp    8022b9 <__umoddi3+0x69>
