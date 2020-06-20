
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 f1 23 80 00       	push   $0x8023f1
  800049:	68 c0 23 80 00       	push   $0x8023c0
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 d0 23 80 00       	push   $0x8023d0
  80005c:	68 d4 23 80 00       	push   $0x8023d4
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 e4 23 80 00       	push   $0x8023e4
  800077:	e8 54 06 00 00       	call   8006d0 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 e8 23 80 00       	push   $0x8023e8
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 f2 23 80 00       	push   $0x8023f2
  8000a6:	68 d4 23 80 00       	push   $0x8023d4
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 e4 23 80 00       	push   $0x8023e4
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 e8 23 80 00       	push   $0x8023e8
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 f6 23 80 00       	push   $0x8023f6
  8000ed:	68 d4 23 80 00       	push   $0x8023d4
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 e4 23 80 00       	push   $0x8023e4
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 e8 23 80 00       	push   $0x8023e8
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 fa 23 80 00       	push   $0x8023fa
  800134:	68 d4 23 80 00       	push   $0x8023d4
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 e4 23 80 00       	push   $0x8023e4
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 e8 23 80 00       	push   $0x8023e8
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 fe 23 80 00       	push   $0x8023fe
  80017b:	68 d4 23 80 00       	push   $0x8023d4
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 e4 23 80 00       	push   $0x8023e4
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 e8 23 80 00       	push   $0x8023e8
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 02 24 80 00       	push   $0x802402
  8001c2:	68 d4 23 80 00       	push   $0x8023d4
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 e4 23 80 00       	push   $0x8023e4
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 e8 23 80 00       	push   $0x8023e8
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 06 24 80 00       	push   $0x802406
  800209:	68 d4 23 80 00       	push   $0x8023d4
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 e4 23 80 00       	push   $0x8023e4
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 e8 23 80 00       	push   $0x8023e8
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 0a 24 80 00       	push   $0x80240a
  800250:	68 d4 23 80 00       	push   $0x8023d4
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 e4 23 80 00       	push   $0x8023e4
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 e8 23 80 00       	push   $0x8023e8
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 0e 24 80 00       	push   $0x80240e
  800297:	68 d4 23 80 00       	push   $0x8023d4
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 e4 23 80 00       	push   $0x8023e4
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 15 24 80 00       	push   $0x802415
  8002c4:	68 d4 23 80 00       	push   $0x8023d4
  8002c9:	e8 02 04 00 00       	call   8006d0 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 e8 23 80 00       	push   $0x8023e8
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 15 24 80 00       	push   $0x802415
  8002f3:	68 d4 23 80 00       	push   $0x8023d4
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 e4 23 80 00       	push   $0x8023e4
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 19 24 80 00       	push   $0x802419
  800322:	e8 a9 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 e8 23 80 00       	push   $0x8023e8
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 19 24 80 00       	push   $0x802419
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 e4 23 80 00       	push   $0x8023e4
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 e8 23 80 00       	push   $0x8023e8
  80036c:	e8 5f 03 00 00       	call   8006d0 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 e4 23 80 00       	push   $0x8023e4
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 19 24 80 00       	push   $0x802419
  80038e:	e8 3d 03 00 00       	call   8006d0 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 80 24 80 00       	push   $0x802480
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 27 24 80 00       	push   $0x802427
  8003c6:	e8 2c 02 00 00       	call   8005f7 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 3f 24 80 00       	push   $0x80243f
  80043b:	68 4d 24 80 00       	push   $0x80244d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 38 24 80 00       	mov    $0x802438,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 3d 0c 00 00       	call   8010a2 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 54 24 80 00       	push   $0x802454
  800472:	6a 5c                	push   $0x5c
  800474:	68 27 24 80 00       	push   $0x802427
  800479:	e8 79 01 00 00       	call   8005f7 <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 03 0e 00 00       	call   801293 <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 b4 24 80 00       	push   $0x8024b4
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 67 24 80 00       	push   $0x802467
  800579:	68 78 24 80 00       	push   $0x802478
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 38 24 80 00       	mov    $0x802438,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a2:	e8 bd 0a 00 00       	call   801064 <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 b0 40 80 00       	mov    %eax,0x8040b0
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e3:	e8 ff 0e 00 00       	call   8014e7 <close_all>
	sys_env_destroy(0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 31 0a 00 00       	call   801023 <sys_env_destroy>
}
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800605:	e8 5a 0a 00 00       	call   801064 <sys_getenvid>
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	56                   	push   %esi
  800614:	50                   	push   %eax
  800615:	68 e0 24 80 00       	push   $0x8024e0
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  800632:	e8 99 00 00 00       	call   8006d0 <cprintf>
  800637:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063a:	cc                   	int3   
  80063b:	eb fd                	jmp    80063a <_panic+0x43>

0080063d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	53                   	push   %ebx
  800641:	83 ec 04             	sub    $0x4,%esp
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800647:	8b 13                	mov    (%ebx),%edx
  800649:	8d 42 01             	lea    0x1(%edx),%eax
  80064c:	89 03                	mov    %eax,(%ebx)
  80064e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800651:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800655:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065a:	75 1a                	jne    800676 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	68 ff 00 00 00       	push   $0xff
  800664:	8d 43 08             	lea    0x8(%ebx),%eax
  800667:	50                   	push   %eax
  800668:	e8 79 09 00 00       	call   800fe6 <sys_cputs>
		b->idx = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800676:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800688:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068f:	00 00 00 
	b.cnt = 0;
  800692:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800699:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 3d 06 80 00       	push   $0x80063d
  8006ae:	e8 54 01 00 00       	call   800807 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 1e 09 00 00       	call   800fe6 <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9d ff ff ff       	call   80067f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 1c             	sub    $0x1c,%esp
  8006ed:	89 c7                	mov    %eax,%edi
  8006ef:	89 d6                	mov    %edx,%esi
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800708:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070b:	39 d3                	cmp    %edx,%ebx
  80070d:	72 05                	jb     800714 <printnum+0x30>
  80070f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800712:	77 45                	ja     800759 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	ff 75 18             	pushl  0x18(%ebp)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	ff 75 dc             	pushl  -0x24(%ebp)
  800730:	ff 75 d8             	pushl  -0x28(%ebp)
  800733:	e8 e8 19 00 00       	call   802120 <__udivdi3>
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	89 f2                	mov    %esi,%edx
  80073f:	89 f8                	mov    %edi,%eax
  800741:	e8 9e ff ff ff       	call   8006e4 <printnum>
  800746:	83 c4 20             	add    $0x20,%esp
  800749:	eb 18                	jmp    800763 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	ff 75 18             	pushl  0x18(%ebp)
  800752:	ff d7                	call   *%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <printnum+0x78>
  800759:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	85 db                	test   %ebx,%ebx
  800761:	7f e8                	jg     80074b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	ff 75 dc             	pushl  -0x24(%ebp)
  800773:	ff 75 d8             	pushl  -0x28(%ebp)
  800776:	e8 d5 1a 00 00       	call   802250 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 03 25 80 00 	movsbl 0x802503(%eax),%eax
  800785:	50                   	push   %eax
  800786:	ff d7                	call   *%edi
}
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800796:	83 fa 01             	cmp    $0x1,%edx
  800799:	7e 0e                	jle    8007a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007a0:	89 08                	mov    %ecx,(%eax)
  8007a2:	8b 02                	mov    (%edx),%eax
  8007a4:	8b 52 04             	mov    0x4(%edx),%edx
  8007a7:	eb 22                	jmp    8007cb <getuint+0x38>
	else if (lflag)
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 10                	je     8007bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b2:	89 08                	mov    %ecx,(%eax)
  8007b4:	8b 02                	mov    (%edx),%eax
  8007b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bb:	eb 0e                	jmp    8007cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007c2:	89 08                	mov    %ecx,(%eax)
  8007c4:	8b 02                	mov    (%edx),%eax
  8007c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8007dc:	73 0a                	jae    8007e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e1:	89 08                	mov    %ecx,(%eax)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	88 02                	mov    %al,(%edx)
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f3:	50                   	push   %eax
  8007f4:	ff 75 10             	pushl  0x10(%ebp)
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	ff 75 08             	pushl  0x8(%ebp)
  8007fd:	e8 05 00 00 00       	call   800807 <vprintfmt>
	va_end(ap);
}
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	57                   	push   %edi
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	83 ec 2c             	sub    $0x2c,%esp
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800816:	8b 7d 10             	mov    0x10(%ebp),%edi
  800819:	eb 12                	jmp    80082d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80081b:	85 c0                	test   %eax,%eax
  80081d:	0f 84 d3 03 00 00    	je     800bf6 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	ff d6                	call   *%esi
  80082a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082d:	83 c7 01             	add    $0x1,%edi
  800830:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800834:	83 f8 25             	cmp    $0x25,%eax
  800837:	75 e2                	jne    80081b <vprintfmt+0x14>
  800839:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80083d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800844:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80084b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800852:	ba 00 00 00 00       	mov    $0x0,%edx
  800857:	eb 07                	jmp    800860 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800859:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80085c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8d 47 01             	lea    0x1(%edi),%eax
  800863:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800866:	0f b6 07             	movzbl (%edi),%eax
  800869:	0f b6 c8             	movzbl %al,%ecx
  80086c:	83 e8 23             	sub    $0x23,%eax
  80086f:	3c 55                	cmp    $0x55,%al
  800871:	0f 87 64 03 00 00    	ja     800bdb <vprintfmt+0x3d4>
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800884:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800888:	eb d6                	jmp    800860 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800895:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800898:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80089c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80089f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8008a2:	83 fa 09             	cmp    $0x9,%edx
  8008a5:	77 39                	ja     8008e0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008aa:	eb e9                	jmp    800895 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8d 48 04             	lea    0x4(%eax),%ecx
  8008b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b5:	8b 00                	mov    (%eax),%eax
  8008b7:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008bd:	eb 27                	jmp    8008e6 <vprintfmt+0xdf>
  8008bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c9:	0f 49 c8             	cmovns %eax,%ecx
  8008cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d2:	eb 8c                	jmp    800860 <vprintfmt+0x59>
  8008d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008de:	eb 80                	jmp    800860 <vprintfmt+0x59>
  8008e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008e3:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8008e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ea:	0f 89 70 ff ff ff    	jns    800860 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008f0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8008f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f6:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8008fd:	e9 5e ff ff ff       	jmp    800860 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800902:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800905:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800908:	e9 53 ff ff ff       	jmp    800860 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8d 50 04             	lea    0x4(%eax),%edx
  800913:	89 55 14             	mov    %edx,0x14(%ebp)
  800916:	83 ec 08             	sub    $0x8,%esp
  800919:	53                   	push   %ebx
  80091a:	ff 30                	pushl  (%eax)
  80091c:	ff d6                	call   *%esi
			break;
  80091e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800921:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800924:	e9 04 ff ff ff       	jmp    80082d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8d 50 04             	lea    0x4(%eax),%edx
  80092f:	89 55 14             	mov    %edx,0x14(%ebp)
  800932:	8b 00                	mov    (%eax),%eax
  800934:	99                   	cltd   
  800935:	31 d0                	xor    %edx,%eax
  800937:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800939:	83 f8 0f             	cmp    $0xf,%eax
  80093c:	7f 0b                	jg     800949 <vprintfmt+0x142>
  80093e:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  800945:	85 d2                	test   %edx,%edx
  800947:	75 18                	jne    800961 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800949:	50                   	push   %eax
  80094a:	68 1b 25 80 00       	push   $0x80251b
  80094f:	53                   	push   %ebx
  800950:	56                   	push   %esi
  800951:	e8 94 fe ff ff       	call   8007ea <printfmt>
  800956:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800959:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80095c:	e9 cc fe ff ff       	jmp    80082d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800961:	52                   	push   %edx
  800962:	68 11 29 80 00       	push   $0x802911
  800967:	53                   	push   %ebx
  800968:	56                   	push   %esi
  800969:	e8 7c fe ff ff       	call   8007ea <printfmt>
  80096e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800971:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800974:	e9 b4 fe ff ff       	jmp    80082d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800979:	8b 45 14             	mov    0x14(%ebp),%eax
  80097c:	8d 50 04             	lea    0x4(%eax),%edx
  80097f:	89 55 14             	mov    %edx,0x14(%ebp)
  800982:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800984:	85 ff                	test   %edi,%edi
  800986:	b8 14 25 80 00       	mov    $0x802514,%eax
  80098b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80098e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800992:	0f 8e 94 00 00 00    	jle    800a2c <vprintfmt+0x225>
  800998:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80099c:	0f 84 98 00 00 00    	je     800a3a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	ff 75 c8             	pushl  -0x38(%ebp)
  8009a8:	57                   	push   %edi
  8009a9:	e8 d0 02 00 00       	call   800c7e <strnlen>
  8009ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009b1:	29 c1                	sub    %eax,%ecx
  8009b3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8009b6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c5:	eb 0f                	jmp    8009d6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009c7:	83 ec 08             	sub    $0x8,%esp
  8009ca:	53                   	push   %ebx
  8009cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ce:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d0:	83 ef 01             	sub    $0x1,%edi
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	85 ff                	test   %edi,%edi
  8009d8:	7f ed                	jg     8009c7 <vprintfmt+0x1c0>
  8009da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009dd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	0f 49 c1             	cmovns %ecx,%eax
  8009ea:	29 c1                	sub    %eax,%ecx
  8009ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ef:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8009f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f5:	89 cb                	mov    %ecx,%ebx
  8009f7:	eb 4d                	jmp    800a46 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fd:	74 1b                	je     800a1a <vprintfmt+0x213>
  8009ff:	0f be c0             	movsbl %al,%eax
  800a02:	83 e8 20             	sub    $0x20,%eax
  800a05:	83 f8 5e             	cmp    $0x5e,%eax
  800a08:	76 10                	jbe    800a1a <vprintfmt+0x213>
					putch('?', putdat);
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	6a 3f                	push   $0x3f
  800a12:	ff 55 08             	call   *0x8(%ebp)
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	eb 0d                	jmp    800a27 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a1a:	83 ec 08             	sub    $0x8,%esp
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	52                   	push   %edx
  800a21:	ff 55 08             	call   *0x8(%ebp)
  800a24:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a27:	83 eb 01             	sub    $0x1,%ebx
  800a2a:	eb 1a                	jmp    800a46 <vprintfmt+0x23f>
  800a2c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a2f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800a32:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a35:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a38:	eb 0c                	jmp    800a46 <vprintfmt+0x23f>
  800a3a:	89 75 08             	mov    %esi,0x8(%ebp)
  800a3d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800a40:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a43:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a46:	83 c7 01             	add    $0x1,%edi
  800a49:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a4d:	0f be d0             	movsbl %al,%edx
  800a50:	85 d2                	test   %edx,%edx
  800a52:	74 23                	je     800a77 <vprintfmt+0x270>
  800a54:	85 f6                	test   %esi,%esi
  800a56:	78 a1                	js     8009f9 <vprintfmt+0x1f2>
  800a58:	83 ee 01             	sub    $0x1,%esi
  800a5b:	79 9c                	jns    8009f9 <vprintfmt+0x1f2>
  800a5d:	89 df                	mov    %ebx,%edi
  800a5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a65:	eb 18                	jmp    800a7f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a67:	83 ec 08             	sub    $0x8,%esp
  800a6a:	53                   	push   %ebx
  800a6b:	6a 20                	push   $0x20
  800a6d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	83 c4 10             	add    $0x10,%esp
  800a75:	eb 08                	jmp    800a7f <vprintfmt+0x278>
  800a77:	89 df                	mov    %ebx,%edi
  800a79:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7f:	85 ff                	test   %edi,%edi
  800a81:	7f e4                	jg     800a67 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a86:	e9 a2 fd ff ff       	jmp    80082d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a8b:	83 fa 01             	cmp    $0x1,%edx
  800a8e:	7e 16                	jle    800aa6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a90:	8b 45 14             	mov    0x14(%ebp),%eax
  800a93:	8d 50 08             	lea    0x8(%eax),%edx
  800a96:	89 55 14             	mov    %edx,0x14(%ebp)
  800a99:	8b 50 04             	mov    0x4(%eax),%edx
  800a9c:	8b 00                	mov    (%eax),%eax
  800a9e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800aa1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800aa4:	eb 32                	jmp    800ad8 <vprintfmt+0x2d1>
	else if (lflag)
  800aa6:	85 d2                	test   %edx,%edx
  800aa8:	74 18                	je     800ac2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aaa:	8b 45 14             	mov    0x14(%ebp),%eax
  800aad:	8d 50 04             	lea    0x4(%eax),%edx
  800ab0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab3:	8b 00                	mov    (%eax),%eax
  800ab5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800ab8:	89 c1                	mov    %eax,%ecx
  800aba:	c1 f9 1f             	sar    $0x1f,%ecx
  800abd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800ac0:	eb 16                	jmp    800ad8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ac2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac5:	8d 50 04             	lea    0x4(%eax),%edx
  800ac8:	89 55 14             	mov    %edx,0x14(%ebp)
  800acb:	8b 00                	mov    (%eax),%eax
  800acd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800ad0:	89 c1                	mov    %eax,%ecx
  800ad2:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800adb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ade:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ae4:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800aed:	0f 89 b0 00 00 00    	jns    800ba3 <vprintfmt+0x39c>
				putch('-', putdat);
  800af3:	83 ec 08             	sub    $0x8,%esp
  800af6:	53                   	push   %ebx
  800af7:	6a 2d                	push   $0x2d
  800af9:	ff d6                	call   *%esi
				num = -(long long) num;
  800afb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800afe:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b01:	f7 d8                	neg    %eax
  800b03:	83 d2 00             	adc    $0x0,%edx
  800b06:	f7 da                	neg    %edx
  800b08:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b0b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b0e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b16:	e9 88 00 00 00       	jmp    800ba3 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1e:	e8 70 fc ff ff       	call   800793 <getuint>
  800b23:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b26:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b29:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b2e:	eb 73                	jmp    800ba3 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800b30:	8d 45 14             	lea    0x14(%ebp),%eax
  800b33:	e8 5b fc ff ff       	call   800793 <getuint>
  800b38:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b3b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	53                   	push   %ebx
  800b42:	6a 58                	push   $0x58
  800b44:	ff d6                	call   *%esi
			putch('X', putdat);
  800b46:	83 c4 08             	add    $0x8,%esp
  800b49:	53                   	push   %ebx
  800b4a:	6a 58                	push   $0x58
  800b4c:	ff d6                	call   *%esi
			putch('X', putdat);
  800b4e:	83 c4 08             	add    $0x8,%esp
  800b51:	53                   	push   %ebx
  800b52:	6a 58                	push   $0x58
  800b54:	ff d6                	call   *%esi
			goto number;
  800b56:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800b59:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800b5e:	eb 43                	jmp    800ba3 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b60:	83 ec 08             	sub    $0x8,%esp
  800b63:	53                   	push   %ebx
  800b64:	6a 30                	push   $0x30
  800b66:	ff d6                	call   *%esi
			putch('x', putdat);
  800b68:	83 c4 08             	add    $0x8,%esp
  800b6b:	53                   	push   %ebx
  800b6c:	6a 78                	push   $0x78
  800b6e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b70:	8b 45 14             	mov    0x14(%ebp),%eax
  800b73:	8d 50 04             	lea    0x4(%eax),%edx
  800b76:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b79:	8b 00                	mov    (%eax),%eax
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b83:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b86:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b89:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b8e:	eb 13                	jmp    800ba3 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b90:	8d 45 14             	lea    0x14(%ebp),%eax
  800b93:	e8 fb fb ff ff       	call   800793 <getuint>
  800b98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b9b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800b9e:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800baa:	52                   	push   %edx
  800bab:	ff 75 e0             	pushl  -0x20(%ebp)
  800bae:	50                   	push   %eax
  800baf:	ff 75 dc             	pushl  -0x24(%ebp)
  800bb2:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb5:	89 da                	mov    %ebx,%edx
  800bb7:	89 f0                	mov    %esi,%eax
  800bb9:	e8 26 fb ff ff       	call   8006e4 <printnum>
			break;
  800bbe:	83 c4 20             	add    $0x20,%esp
  800bc1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bc4:	e9 64 fc ff ff       	jmp    80082d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bc9:	83 ec 08             	sub    $0x8,%esp
  800bcc:	53                   	push   %ebx
  800bcd:	51                   	push   %ecx
  800bce:	ff d6                	call   *%esi
			break;
  800bd0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bd3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bd6:	e9 52 fc ff ff       	jmp    80082d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bdb:	83 ec 08             	sub    $0x8,%esp
  800bde:	53                   	push   %ebx
  800bdf:	6a 25                	push   $0x25
  800be1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800be3:	83 c4 10             	add    $0x10,%esp
  800be6:	eb 03                	jmp    800beb <vprintfmt+0x3e4>
  800be8:	83 ef 01             	sub    $0x1,%edi
  800beb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800bef:	75 f7                	jne    800be8 <vprintfmt+0x3e1>
  800bf1:	e9 37 fc ff ff       	jmp    80082d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 18             	sub    $0x18,%esp
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c0d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c11:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	74 26                	je     800c45 <vsnprintf+0x47>
  800c1f:	85 d2                	test   %edx,%edx
  800c21:	7e 22                	jle    800c45 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c23:	ff 75 14             	pushl  0x14(%ebp)
  800c26:	ff 75 10             	pushl  0x10(%ebp)
  800c29:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c2c:	50                   	push   %eax
  800c2d:	68 cd 07 80 00       	push   $0x8007cd
  800c32:	e8 d0 fb ff ff       	call   800807 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c37:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c3a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c40:	83 c4 10             	add    $0x10,%esp
  800c43:	eb 05                	jmp    800c4a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c52:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c55:	50                   	push   %eax
  800c56:	ff 75 10             	pushl  0x10(%ebp)
  800c59:	ff 75 0c             	pushl  0xc(%ebp)
  800c5c:	ff 75 08             	pushl  0x8(%ebp)
  800c5f:	e8 9a ff ff ff       	call   800bfe <vsnprintf>
	va_end(ap);

	return rc;
}
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c71:	eb 03                	jmp    800c76 <strlen+0x10>
		n++;
  800c73:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c76:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c7a:	75 f7                	jne    800c73 <strlen+0xd>
		n++;
	return n;
}
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c84:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c87:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8c:	eb 03                	jmp    800c91 <strnlen+0x13>
		n++;
  800c8e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c91:	39 c2                	cmp    %eax,%edx
  800c93:	74 08                	je     800c9d <strnlen+0x1f>
  800c95:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c99:	75 f3                	jne    800c8e <strnlen+0x10>
  800c9b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	53                   	push   %ebx
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	83 c2 01             	add    $0x1,%edx
  800cae:	83 c1 01             	add    $0x1,%ecx
  800cb1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cb5:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cb8:	84 db                	test   %bl,%bl
  800cba:	75 ef                	jne    800cab <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	53                   	push   %ebx
  800cc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cc6:	53                   	push   %ebx
  800cc7:	e8 9a ff ff ff       	call   800c66 <strlen>
  800ccc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ccf:	ff 75 0c             	pushl  0xc(%ebp)
  800cd2:	01 d8                	add    %ebx,%eax
  800cd4:	50                   	push   %eax
  800cd5:	e8 c5 ff ff ff       	call   800c9f <strcpy>
	return dst;
}
  800cda:	89 d8                	mov    %ebx,%eax
  800cdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cdf:	c9                   	leave  
  800ce0:	c3                   	ret    

00800ce1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	89 f3                	mov    %esi,%ebx
  800cee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf1:	89 f2                	mov    %esi,%edx
  800cf3:	eb 0f                	jmp    800d04 <strncpy+0x23>
		*dst++ = *src;
  800cf5:	83 c2 01             	add    $0x1,%edx
  800cf8:	0f b6 01             	movzbl (%ecx),%eax
  800cfb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cfe:	80 39 01             	cmpb   $0x1,(%ecx)
  800d01:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d04:	39 da                	cmp    %ebx,%edx
  800d06:	75 ed                	jne    800cf5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d08:	89 f0                	mov    %esi,%eax
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	8b 75 08             	mov    0x8(%ebp),%esi
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 10             	mov    0x10(%ebp),%edx
  800d1c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d1e:	85 d2                	test   %edx,%edx
  800d20:	74 21                	je     800d43 <strlcpy+0x35>
  800d22:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d26:	89 f2                	mov    %esi,%edx
  800d28:	eb 09                	jmp    800d33 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d2a:	83 c2 01             	add    $0x1,%edx
  800d2d:	83 c1 01             	add    $0x1,%ecx
  800d30:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d33:	39 c2                	cmp    %eax,%edx
  800d35:	74 09                	je     800d40 <strlcpy+0x32>
  800d37:	0f b6 19             	movzbl (%ecx),%ebx
  800d3a:	84 db                	test   %bl,%bl
  800d3c:	75 ec                	jne    800d2a <strlcpy+0x1c>
  800d3e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d40:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d43:	29 f0                	sub    %esi,%eax
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d52:	eb 06                	jmp    800d5a <strcmp+0x11>
		p++, q++;
  800d54:	83 c1 01             	add    $0x1,%ecx
  800d57:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d5a:	0f b6 01             	movzbl (%ecx),%eax
  800d5d:	84 c0                	test   %al,%al
  800d5f:	74 04                	je     800d65 <strcmp+0x1c>
  800d61:	3a 02                	cmp    (%edx),%al
  800d63:	74 ef                	je     800d54 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d65:	0f b6 c0             	movzbl %al,%eax
  800d68:	0f b6 12             	movzbl (%edx),%edx
  800d6b:	29 d0                	sub    %edx,%eax
}
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	53                   	push   %ebx
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d79:	89 c3                	mov    %eax,%ebx
  800d7b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d7e:	eb 06                	jmp    800d86 <strncmp+0x17>
		n--, p++, q++;
  800d80:	83 c0 01             	add    $0x1,%eax
  800d83:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d86:	39 d8                	cmp    %ebx,%eax
  800d88:	74 15                	je     800d9f <strncmp+0x30>
  800d8a:	0f b6 08             	movzbl (%eax),%ecx
  800d8d:	84 c9                	test   %cl,%cl
  800d8f:	74 04                	je     800d95 <strncmp+0x26>
  800d91:	3a 0a                	cmp    (%edx),%cl
  800d93:	74 eb                	je     800d80 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d95:	0f b6 00             	movzbl (%eax),%eax
  800d98:	0f b6 12             	movzbl (%edx),%edx
  800d9b:	29 d0                	sub    %edx,%eax
  800d9d:	eb 05                	jmp    800da4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d9f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800db1:	eb 07                	jmp    800dba <strchr+0x13>
		if (*s == c)
  800db3:	38 ca                	cmp    %cl,%dl
  800db5:	74 0f                	je     800dc6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800db7:	83 c0 01             	add    $0x1,%eax
  800dba:	0f b6 10             	movzbl (%eax),%edx
  800dbd:	84 d2                	test   %dl,%dl
  800dbf:	75 f2                	jne    800db3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dd2:	eb 03                	jmp    800dd7 <strfind+0xf>
  800dd4:	83 c0 01             	add    $0x1,%eax
  800dd7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800dda:	38 ca                	cmp    %cl,%dl
  800ddc:	74 04                	je     800de2 <strfind+0x1a>
  800dde:	84 d2                	test   %dl,%dl
  800de0:	75 f2                	jne    800dd4 <strfind+0xc>
			break;
	return (char *) s;
}
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ded:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800df0:	85 c9                	test   %ecx,%ecx
  800df2:	74 36                	je     800e2a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800df4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dfa:	75 28                	jne    800e24 <memset+0x40>
  800dfc:	f6 c1 03             	test   $0x3,%cl
  800dff:	75 23                	jne    800e24 <memset+0x40>
		c &= 0xFF;
  800e01:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e05:	89 d3                	mov    %edx,%ebx
  800e07:	c1 e3 08             	shl    $0x8,%ebx
  800e0a:	89 d6                	mov    %edx,%esi
  800e0c:	c1 e6 18             	shl    $0x18,%esi
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	c1 e0 10             	shl    $0x10,%eax
  800e14:	09 f0                	or     %esi,%eax
  800e16:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	09 d0                	or     %edx,%eax
  800e1c:	c1 e9 02             	shr    $0x2,%ecx
  800e1f:	fc                   	cld    
  800e20:	f3 ab                	rep stos %eax,%es:(%edi)
  800e22:	eb 06                	jmp    800e2a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e27:	fc                   	cld    
  800e28:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e2a:	89 f8                	mov    %edi,%eax
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e3f:	39 c6                	cmp    %eax,%esi
  800e41:	73 35                	jae    800e78 <memmove+0x47>
  800e43:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e46:	39 d0                	cmp    %edx,%eax
  800e48:	73 2e                	jae    800e78 <memmove+0x47>
		s += n;
		d += n;
  800e4a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e4d:	89 d6                	mov    %edx,%esi
  800e4f:	09 fe                	or     %edi,%esi
  800e51:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e57:	75 13                	jne    800e6c <memmove+0x3b>
  800e59:	f6 c1 03             	test   $0x3,%cl
  800e5c:	75 0e                	jne    800e6c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e5e:	83 ef 04             	sub    $0x4,%edi
  800e61:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e64:	c1 e9 02             	shr    $0x2,%ecx
  800e67:	fd                   	std    
  800e68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e6a:	eb 09                	jmp    800e75 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e6c:	83 ef 01             	sub    $0x1,%edi
  800e6f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e72:	fd                   	std    
  800e73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e75:	fc                   	cld    
  800e76:	eb 1d                	jmp    800e95 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e78:	89 f2                	mov    %esi,%edx
  800e7a:	09 c2                	or     %eax,%edx
  800e7c:	f6 c2 03             	test   $0x3,%dl
  800e7f:	75 0f                	jne    800e90 <memmove+0x5f>
  800e81:	f6 c1 03             	test   $0x3,%cl
  800e84:	75 0a                	jne    800e90 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e86:	c1 e9 02             	shr    $0x2,%ecx
  800e89:	89 c7                	mov    %eax,%edi
  800e8b:	fc                   	cld    
  800e8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e8e:	eb 05                	jmp    800e95 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e90:	89 c7                	mov    %eax,%edi
  800e92:	fc                   	cld    
  800e93:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e9c:	ff 75 10             	pushl  0x10(%ebp)
  800e9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ea2:	ff 75 08             	pushl  0x8(%ebp)
  800ea5:	e8 87 ff ff ff       	call   800e31 <memmove>
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb7:	89 c6                	mov    %eax,%esi
  800eb9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ebc:	eb 1a                	jmp    800ed8 <memcmp+0x2c>
		if (*s1 != *s2)
  800ebe:	0f b6 08             	movzbl (%eax),%ecx
  800ec1:	0f b6 1a             	movzbl (%edx),%ebx
  800ec4:	38 d9                	cmp    %bl,%cl
  800ec6:	74 0a                	je     800ed2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ec8:	0f b6 c1             	movzbl %cl,%eax
  800ecb:	0f b6 db             	movzbl %bl,%ebx
  800ece:	29 d8                	sub    %ebx,%eax
  800ed0:	eb 0f                	jmp    800ee1 <memcmp+0x35>
		s1++, s2++;
  800ed2:	83 c0 01             	add    $0x1,%eax
  800ed5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ed8:	39 f0                	cmp    %esi,%eax
  800eda:	75 e2                	jne    800ebe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	53                   	push   %ebx
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800eec:	89 c1                	mov    %eax,%ecx
  800eee:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ef1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ef5:	eb 0a                	jmp    800f01 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ef7:	0f b6 10             	movzbl (%eax),%edx
  800efa:	39 da                	cmp    %ebx,%edx
  800efc:	74 07                	je     800f05 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800efe:	83 c0 01             	add    $0x1,%eax
  800f01:	39 c8                	cmp    %ecx,%eax
  800f03:	72 f2                	jb     800ef7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f05:	5b                   	pop    %ebx
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f14:	eb 03                	jmp    800f19 <strtol+0x11>
		s++;
  800f16:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f19:	0f b6 01             	movzbl (%ecx),%eax
  800f1c:	3c 20                	cmp    $0x20,%al
  800f1e:	74 f6                	je     800f16 <strtol+0xe>
  800f20:	3c 09                	cmp    $0x9,%al
  800f22:	74 f2                	je     800f16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f24:	3c 2b                	cmp    $0x2b,%al
  800f26:	75 0a                	jne    800f32 <strtol+0x2a>
		s++;
  800f28:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f30:	eb 11                	jmp    800f43 <strtol+0x3b>
  800f32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f37:	3c 2d                	cmp    $0x2d,%al
  800f39:	75 08                	jne    800f43 <strtol+0x3b>
		s++, neg = 1;
  800f3b:	83 c1 01             	add    $0x1,%ecx
  800f3e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f43:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f49:	75 15                	jne    800f60 <strtol+0x58>
  800f4b:	80 39 30             	cmpb   $0x30,(%ecx)
  800f4e:	75 10                	jne    800f60 <strtol+0x58>
  800f50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f54:	75 7c                	jne    800fd2 <strtol+0xca>
		s += 2, base = 16;
  800f56:	83 c1 02             	add    $0x2,%ecx
  800f59:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f5e:	eb 16                	jmp    800f76 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f60:	85 db                	test   %ebx,%ebx
  800f62:	75 12                	jne    800f76 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f64:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f69:	80 39 30             	cmpb   $0x30,(%ecx)
  800f6c:	75 08                	jne    800f76 <strtol+0x6e>
		s++, base = 8;
  800f6e:	83 c1 01             	add    $0x1,%ecx
  800f71:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f7e:	0f b6 11             	movzbl (%ecx),%edx
  800f81:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f84:	89 f3                	mov    %esi,%ebx
  800f86:	80 fb 09             	cmp    $0x9,%bl
  800f89:	77 08                	ja     800f93 <strtol+0x8b>
			dig = *s - '0';
  800f8b:	0f be d2             	movsbl %dl,%edx
  800f8e:	83 ea 30             	sub    $0x30,%edx
  800f91:	eb 22                	jmp    800fb5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f93:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f96:	89 f3                	mov    %esi,%ebx
  800f98:	80 fb 19             	cmp    $0x19,%bl
  800f9b:	77 08                	ja     800fa5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f9d:	0f be d2             	movsbl %dl,%edx
  800fa0:	83 ea 57             	sub    $0x57,%edx
  800fa3:	eb 10                	jmp    800fb5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fa5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fa8:	89 f3                	mov    %esi,%ebx
  800faa:	80 fb 19             	cmp    $0x19,%bl
  800fad:	77 16                	ja     800fc5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800faf:	0f be d2             	movsbl %dl,%edx
  800fb2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fb5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fb8:	7d 0b                	jge    800fc5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fba:	83 c1 01             	add    $0x1,%ecx
  800fbd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fc1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800fc3:	eb b9                	jmp    800f7e <strtol+0x76>

	if (endptr)
  800fc5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fc9:	74 0d                	je     800fd8 <strtol+0xd0>
		*endptr = (char *) s;
  800fcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fce:	89 0e                	mov    %ecx,(%esi)
  800fd0:	eb 06                	jmp    800fd8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fd2:	85 db                	test   %ebx,%ebx
  800fd4:	74 98                	je     800f6e <strtol+0x66>
  800fd6:	eb 9e                	jmp    800f76 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fd8:	89 c2                	mov    %eax,%edx
  800fda:	f7 da                	neg    %edx
  800fdc:	85 ff                	test   %edi,%edi
  800fde:	0f 45 c2             	cmovne %edx,%eax
}
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800fec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff7:	89 c3                	mov    %eax,%ebx
  800ff9:	89 c7                	mov    %eax,%edi
  800ffb:	89 c6                	mov    %eax,%esi
  800ffd:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <sys_cgetc>:

int
sys_cgetc(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80100a:	ba 00 00 00 00       	mov    $0x0,%edx
  80100f:	b8 01 00 00 00       	mov    $0x1,%eax
  801014:	89 d1                	mov    %edx,%ecx
  801016:	89 d3                	mov    %edx,%ebx
  801018:	89 d7                	mov    %edx,%edi
  80101a:	89 d6                	mov    %edx,%esi
  80101c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80101e:	5b                   	pop    %ebx
  80101f:	5e                   	pop    %esi
  801020:	5f                   	pop    %edi
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	57                   	push   %edi
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
  801029:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80102c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801031:	b8 03 00 00 00       	mov    $0x3,%eax
  801036:	8b 55 08             	mov    0x8(%ebp),%edx
  801039:	89 cb                	mov    %ecx,%ebx
  80103b:	89 cf                	mov    %ecx,%edi
  80103d:	89 ce                	mov    %ecx,%esi
  80103f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801041:	85 c0                	test   %eax,%eax
  801043:	7e 17                	jle    80105c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	50                   	push   %eax
  801049:	6a 03                	push   $0x3
  80104b:	68 ff 27 80 00       	push   $0x8027ff
  801050:	6a 23                	push   $0x23
  801052:	68 1c 28 80 00       	push   $0x80281c
  801057:	e8 9b f5 ff ff       	call   8005f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80105c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5f                   	pop    %edi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	57                   	push   %edi
  801068:	56                   	push   %esi
  801069:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80106a:	ba 00 00 00 00       	mov    $0x0,%edx
  80106f:	b8 02 00 00 00       	mov    $0x2,%eax
  801074:	89 d1                	mov    %edx,%ecx
  801076:	89 d3                	mov    %edx,%ebx
  801078:	89 d7                	mov    %edx,%edi
  80107a:	89 d6                	mov    %edx,%esi
  80107c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <sys_yield>:

void
sys_yield(void)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801089:	ba 00 00 00 00       	mov    $0x0,%edx
  80108e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801093:	89 d1                	mov    %edx,%ecx
  801095:	89 d3                	mov    %edx,%ebx
  801097:	89 d7                	mov    %edx,%edi
  801099:	89 d6                	mov    %edx,%esi
  80109b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5f                   	pop    %edi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8010ab:	be 00 00 00 00       	mov    $0x0,%esi
  8010b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010be:	89 f7                	mov    %esi,%edi
  8010c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	7e 17                	jle    8010dd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	50                   	push   %eax
  8010ca:	6a 04                	push   $0x4
  8010cc:	68 ff 27 80 00       	push   $0x8027ff
  8010d1:	6a 23                	push   $0x23
  8010d3:	68 1c 28 80 00       	push   $0x80281c
  8010d8:	e8 1a f5 ff ff       	call   8005f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8010ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8010f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ff:	8b 75 18             	mov    0x18(%ebp),%esi
  801102:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801104:	85 c0                	test   %eax,%eax
  801106:	7e 17                	jle    80111f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	50                   	push   %eax
  80110c:	6a 05                	push   $0x5
  80110e:	68 ff 27 80 00       	push   $0x8027ff
  801113:	6a 23                	push   $0x23
  801115:	68 1c 28 80 00       	push   $0x80281c
  80111a:	e8 d8 f4 ff ff       	call   8005f7 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80111f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801122:	5b                   	pop    %ebx
  801123:	5e                   	pop    %esi
  801124:	5f                   	pop    %edi
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	57                   	push   %edi
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801130:	bb 00 00 00 00       	mov    $0x0,%ebx
  801135:	b8 06 00 00 00       	mov    $0x6,%eax
  80113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx
  801140:	89 df                	mov    %ebx,%edi
  801142:	89 de                	mov    %ebx,%esi
  801144:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801146:	85 c0                	test   %eax,%eax
  801148:	7e 17                	jle    801161 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	50                   	push   %eax
  80114e:	6a 06                	push   $0x6
  801150:	68 ff 27 80 00       	push   $0x8027ff
  801155:	6a 23                	push   $0x23
  801157:	68 1c 28 80 00       	push   $0x80281c
  80115c:	e8 96 f4 ff ff       	call   8005f7 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801172:	bb 00 00 00 00       	mov    $0x0,%ebx
  801177:	b8 08 00 00 00       	mov    $0x8,%eax
  80117c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117f:	8b 55 08             	mov    0x8(%ebp),%edx
  801182:	89 df                	mov    %ebx,%edi
  801184:	89 de                	mov    %ebx,%esi
  801186:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801188:	85 c0                	test   %eax,%eax
  80118a:	7e 17                	jle    8011a3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	50                   	push   %eax
  801190:	6a 08                	push   $0x8
  801192:	68 ff 27 80 00       	push   $0x8027ff
  801197:	6a 23                	push   $0x23
  801199:	68 1c 28 80 00       	push   $0x80281c
  80119e:	e8 54 f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	57                   	push   %edi
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8011b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8011be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c4:	89 df                	mov    %ebx,%edi
  8011c6:	89 de                	mov    %ebx,%esi
  8011c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	7e 17                	jle    8011e5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	50                   	push   %eax
  8011d2:	6a 09                	push   $0x9
  8011d4:	68 ff 27 80 00       	push   $0x8027ff
  8011d9:	6a 23                	push   $0x23
  8011db:	68 1c 28 80 00       	push   $0x80281c
  8011e0:	e8 12 f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8011f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 08             	mov    0x8(%ebp),%edx
  801206:	89 df                	mov    %ebx,%edi
  801208:	89 de                	mov    %ebx,%esi
  80120a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	7e 17                	jle    801227 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801210:	83 ec 0c             	sub    $0xc,%esp
  801213:	50                   	push   %eax
  801214:	6a 0a                	push   $0xa
  801216:	68 ff 27 80 00       	push   $0x8027ff
  80121b:	6a 23                	push   $0x23
  80121d:	68 1c 28 80 00       	push   $0x80281c
  801222:	e8 d0 f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122a:	5b                   	pop    %ebx
  80122b:	5e                   	pop    %esi
  80122c:	5f                   	pop    %edi
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	57                   	push   %edi
  801233:	56                   	push   %esi
  801234:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801235:	be 00 00 00 00       	mov    $0x0,%esi
  80123a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80123f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801242:	8b 55 08             	mov    0x8(%ebp),%edx
  801245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801248:	8b 7d 14             	mov    0x14(%ebp),%edi
  80124b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80125b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801260:	b8 0d 00 00 00       	mov    $0xd,%eax
  801265:	8b 55 08             	mov    0x8(%ebp),%edx
  801268:	89 cb                	mov    %ecx,%ebx
  80126a:	89 cf                	mov    %ecx,%edi
  80126c:	89 ce                	mov    %ecx,%esi
  80126e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  801270:	85 c0                	test   %eax,%eax
  801272:	7e 17                	jle    80128b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801274:	83 ec 0c             	sub    $0xc,%esp
  801277:	50                   	push   %eax
  801278:	6a 0d                	push   $0xd
  80127a:	68 ff 27 80 00       	push   $0x8027ff
  80127f:	6a 23                	push   $0x23
  801281:	68 1c 28 80 00       	push   $0x80281c
  801286:	e8 6c f3 ff ff       	call   8005f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80128b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128e:	5b                   	pop    %ebx
  80128f:	5e                   	pop    %esi
  801290:	5f                   	pop    %edi
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801299:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012a0:	75 4c                	jne    8012ee <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  8012a2:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8012a7:	8b 40 48             	mov    0x48(%eax),%eax
  8012aa:	83 ec 04             	sub    $0x4,%esp
  8012ad:	6a 07                	push   $0x7
  8012af:	68 00 f0 bf ee       	push   $0xeebff000
  8012b4:	50                   	push   %eax
  8012b5:	e8 e8 fd ff ff       	call   8010a2 <sys_page_alloc>
		if(retv != 0){
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	74 14                	je     8012d5 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	68 2c 28 80 00       	push   $0x80282c
  8012c9:	6a 27                	push   $0x27
  8012cb:	68 58 28 80 00       	push   $0x802858
  8012d0:	e8 22 f3 ff ff       	call   8005f7 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8012d5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8012da:	8b 40 48             	mov    0x48(%eax),%eax
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	68 f8 12 80 00       	push   $0x8012f8
  8012e5:	50                   	push   %eax
  8012e6:	e8 02 ff ff ff       	call   8011ed <sys_env_set_pgfault_upcall>
  8012eb:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f1:	a3 b4 40 80 00       	mov    %eax,0x8040b4

}
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012f9:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8012fe:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  801300:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  801303:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  801307:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  80130c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  801310:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  801312:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  801315:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  801316:	83 c4 04             	add    $0x4,%esp
	popfl
  801319:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80131a:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80131b:	c3                   	ret    

0080131c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131f:	8b 45 08             	mov    0x8(%ebp),%eax
  801322:	05 00 00 00 30       	add    $0x30000000,%eax
  801327:	c1 e8 0c             	shr    $0xc,%eax
}
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80132f:	8b 45 08             	mov    0x8(%ebp),%eax
  801332:	05 00 00 00 30       	add    $0x30000000,%eax
  801337:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80133c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801349:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80134e:	89 c2                	mov    %eax,%edx
  801350:	c1 ea 16             	shr    $0x16,%edx
  801353:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135a:	f6 c2 01             	test   $0x1,%dl
  80135d:	74 11                	je     801370 <fd_alloc+0x2d>
  80135f:	89 c2                	mov    %eax,%edx
  801361:	c1 ea 0c             	shr    $0xc,%edx
  801364:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136b:	f6 c2 01             	test   $0x1,%dl
  80136e:	75 09                	jne    801379 <fd_alloc+0x36>
			*fd_store = fd;
  801370:	89 01                	mov    %eax,(%ecx)
			return 0;
  801372:	b8 00 00 00 00       	mov    $0x0,%eax
  801377:	eb 17                	jmp    801390 <fd_alloc+0x4d>
  801379:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80137e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801383:	75 c9                	jne    80134e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801385:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80138b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801398:	83 f8 1f             	cmp    $0x1f,%eax
  80139b:	77 36                	ja     8013d3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139d:	c1 e0 0c             	shl    $0xc,%eax
  8013a0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 16             	shr    $0x16,%edx
  8013aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	74 24                	je     8013da <fd_lookup+0x48>
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	c1 ea 0c             	shr    $0xc,%edx
  8013bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c2:	f6 c2 01             	test   $0x1,%dl
  8013c5:	74 1a                	je     8013e1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ca:	89 02                	mov    %eax,(%edx)
	return 0;
  8013cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d1:	eb 13                	jmp    8013e6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d8:	eb 0c                	jmp    8013e6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013df:	eb 05                	jmp    8013e6 <fd_lookup+0x54>
  8013e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f1:	ba e8 28 80 00       	mov    $0x8028e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f6:	eb 13                	jmp    80140b <dev_lookup+0x23>
  8013f8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013fb:	39 08                	cmp    %ecx,(%eax)
  8013fd:	75 0c                	jne    80140b <dev_lookup+0x23>
			*dev = devtab[i];
  8013ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801402:	89 01                	mov    %eax,(%ecx)
			return 0;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	eb 2e                	jmp    801439 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80140b:	8b 02                	mov    (%edx),%eax
  80140d:	85 c0                	test   %eax,%eax
  80140f:	75 e7                	jne    8013f8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801411:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801416:	8b 40 48             	mov    0x48(%eax),%eax
  801419:	83 ec 04             	sub    $0x4,%esp
  80141c:	51                   	push   %ecx
  80141d:	50                   	push   %eax
  80141e:	68 68 28 80 00       	push   $0x802868
  801423:	e8 a8 f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  801428:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	56                   	push   %esi
  80143f:	53                   	push   %ebx
  801440:	83 ec 10             	sub    $0x10,%esp
  801443:	8b 75 08             	mov    0x8(%ebp),%esi
  801446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801453:	c1 e8 0c             	shr    $0xc,%eax
  801456:	50                   	push   %eax
  801457:	e8 36 ff ff ff       	call   801392 <fd_lookup>
  80145c:	83 c4 08             	add    $0x8,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 05                	js     801468 <fd_close+0x2d>
	    || fd != fd2)
  801463:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801466:	74 0c                	je     801474 <fd_close+0x39>
		return (must_exist ? r : 0);
  801468:	84 db                	test   %bl,%bl
  80146a:	ba 00 00 00 00       	mov    $0x0,%edx
  80146f:	0f 44 c2             	cmove  %edx,%eax
  801472:	eb 41                	jmp    8014b5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 36                	pushl  (%esi)
  80147d:	e8 66 ff ff ff       	call   8013e8 <dev_lookup>
  801482:	89 c3                	mov    %eax,%ebx
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 1a                	js     8014a5 <fd_close+0x6a>
		if (dev->dev_close)
  80148b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801491:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801496:	85 c0                	test   %eax,%eax
  801498:	74 0b                	je     8014a5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80149a:	83 ec 0c             	sub    $0xc,%esp
  80149d:	56                   	push   %esi
  80149e:	ff d0                	call   *%eax
  8014a0:	89 c3                	mov    %eax,%ebx
  8014a2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	56                   	push   %esi
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 77 fc ff ff       	call   801127 <sys_page_unmap>
	return r;
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	89 d8                	mov    %ebx,%eax
}
  8014b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 08             	pushl  0x8(%ebp)
  8014c9:	e8 c4 fe ff ff       	call   801392 <fd_lookup>
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 10                	js     8014e5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	6a 01                	push   $0x1
  8014da:	ff 75 f4             	pushl  -0xc(%ebp)
  8014dd:	e8 59 ff ff ff       	call   80143b <fd_close>
  8014e2:	83 c4 10             	add    $0x10,%esp
}
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <close_all>:

void
close_all(void)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	53                   	push   %ebx
  8014f7:	e8 c0 ff ff ff       	call   8014bc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014fc:	83 c3 01             	add    $0x1,%ebx
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	83 fb 20             	cmp    $0x20,%ebx
  801505:	75 ec                	jne    8014f3 <close_all+0xc>
		close(i);
}
  801507:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	57                   	push   %edi
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	83 ec 2c             	sub    $0x2c,%esp
  801515:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801518:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	ff 75 08             	pushl  0x8(%ebp)
  80151f:	e8 6e fe ff ff       	call   801392 <fd_lookup>
  801524:	83 c4 08             	add    $0x8,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	0f 88 c1 00 00 00    	js     8015f0 <dup+0xe4>
		return r;
	close(newfdnum);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	56                   	push   %esi
  801533:	e8 84 ff ff ff       	call   8014bc <close>

	newfd = INDEX2FD(newfdnum);
  801538:	89 f3                	mov    %esi,%ebx
  80153a:	c1 e3 0c             	shl    $0xc,%ebx
  80153d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801543:	83 c4 04             	add    $0x4,%esp
  801546:	ff 75 e4             	pushl  -0x1c(%ebp)
  801549:	e8 de fd ff ff       	call   80132c <fd2data>
  80154e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801550:	89 1c 24             	mov    %ebx,(%esp)
  801553:	e8 d4 fd ff ff       	call   80132c <fd2data>
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155e:	89 f8                	mov    %edi,%eax
  801560:	c1 e8 16             	shr    $0x16,%eax
  801563:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80156a:	a8 01                	test   $0x1,%al
  80156c:	74 37                	je     8015a5 <dup+0x99>
  80156e:	89 f8                	mov    %edi,%eax
  801570:	c1 e8 0c             	shr    $0xc,%eax
  801573:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80157a:	f6 c2 01             	test   $0x1,%dl
  80157d:	74 26                	je     8015a5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80157f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	25 07 0e 00 00       	and    $0xe07,%eax
  80158e:	50                   	push   %eax
  80158f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801592:	6a 00                	push   $0x0
  801594:	57                   	push   %edi
  801595:	6a 00                	push   $0x0
  801597:	e8 49 fb ff ff       	call   8010e5 <sys_page_map>
  80159c:	89 c7                	mov    %eax,%edi
  80159e:	83 c4 20             	add    $0x20,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 2e                	js     8015d3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a8:	89 d0                	mov    %edx,%eax
  8015aa:	c1 e8 0c             	shr    $0xc,%eax
  8015ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8015bc:	50                   	push   %eax
  8015bd:	53                   	push   %ebx
  8015be:	6a 00                	push   $0x0
  8015c0:	52                   	push   %edx
  8015c1:	6a 00                	push   $0x0
  8015c3:	e8 1d fb ff ff       	call   8010e5 <sys_page_map>
  8015c8:	89 c7                	mov    %eax,%edi
  8015ca:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015cd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015cf:	85 ff                	test   %edi,%edi
  8015d1:	79 1d                	jns    8015f0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	53                   	push   %ebx
  8015d7:	6a 00                	push   $0x0
  8015d9:	e8 49 fb ff ff       	call   801127 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015de:	83 c4 08             	add    $0x8,%esp
  8015e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e4:	6a 00                	push   $0x0
  8015e6:	e8 3c fb ff ff       	call   801127 <sys_page_unmap>
	return r;
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	89 f8                	mov    %edi,%eax
}
  8015f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f3:	5b                   	pop    %ebx
  8015f4:	5e                   	pop    %esi
  8015f5:	5f                   	pop    %edi
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 14             	sub    $0x14,%esp
  8015ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801602:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	53                   	push   %ebx
  801607:	e8 86 fd ff ff       	call   801392 <fd_lookup>
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	89 c2                	mov    %eax,%edx
  801611:	85 c0                	test   %eax,%eax
  801613:	78 6d                	js     801682 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	ff 30                	pushl  (%eax)
  801621:	e8 c2 fd ff ff       	call   8013e8 <dev_lookup>
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 4c                	js     801679 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80162d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801630:	8b 42 08             	mov    0x8(%edx),%eax
  801633:	83 e0 03             	and    $0x3,%eax
  801636:	83 f8 01             	cmp    $0x1,%eax
  801639:	75 21                	jne    80165c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80163b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801640:	8b 40 48             	mov    0x48(%eax),%eax
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	53                   	push   %ebx
  801647:	50                   	push   %eax
  801648:	68 ac 28 80 00       	push   $0x8028ac
  80164d:	e8 7e f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165a:	eb 26                	jmp    801682 <read+0x8a>
	}
	if (!dev->dev_read)
  80165c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165f:	8b 40 08             	mov    0x8(%eax),%eax
  801662:	85 c0                	test   %eax,%eax
  801664:	74 17                	je     80167d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801666:	83 ec 04             	sub    $0x4,%esp
  801669:	ff 75 10             	pushl  0x10(%ebp)
  80166c:	ff 75 0c             	pushl  0xc(%ebp)
  80166f:	52                   	push   %edx
  801670:	ff d0                	call   *%eax
  801672:	89 c2                	mov    %eax,%edx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	eb 09                	jmp    801682 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801679:	89 c2                	mov    %eax,%edx
  80167b:	eb 05                	jmp    801682 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80167d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801682:	89 d0                	mov    %edx,%eax
  801684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	57                   	push   %edi
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	8b 7d 08             	mov    0x8(%ebp),%edi
  801695:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169d:	eb 21                	jmp    8016c0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	89 f0                	mov    %esi,%eax
  8016a4:	29 d8                	sub    %ebx,%eax
  8016a6:	50                   	push   %eax
  8016a7:	89 d8                	mov    %ebx,%eax
  8016a9:	03 45 0c             	add    0xc(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	57                   	push   %edi
  8016ae:	e8 45 ff ff ff       	call   8015f8 <read>
		if (m < 0)
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 10                	js     8016ca <readn+0x41>
			return m;
		if (m == 0)
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	74 0a                	je     8016c8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016be:	01 c3                	add    %eax,%ebx
  8016c0:	39 f3                	cmp    %esi,%ebx
  8016c2:	72 db                	jb     80169f <readn+0x16>
  8016c4:	89 d8                	mov    %ebx,%eax
  8016c6:	eb 02                	jmp    8016ca <readn+0x41>
  8016c8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	53                   	push   %ebx
  8016d6:	83 ec 14             	sub    $0x14,%esp
  8016d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	53                   	push   %ebx
  8016e1:	e8 ac fc ff ff       	call   801392 <fd_lookup>
  8016e6:	83 c4 08             	add    $0x8,%esp
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 68                	js     801757 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	ff 30                	pushl  (%eax)
  8016fb:	e8 e8 fc ff ff       	call   8013e8 <dev_lookup>
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	78 47                	js     80174e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801707:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170e:	75 21                	jne    801731 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801710:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801715:	8b 40 48             	mov    0x48(%eax),%eax
  801718:	83 ec 04             	sub    $0x4,%esp
  80171b:	53                   	push   %ebx
  80171c:	50                   	push   %eax
  80171d:	68 c8 28 80 00       	push   $0x8028c8
  801722:	e8 a9 ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172f:	eb 26                	jmp    801757 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801731:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801734:	8b 52 0c             	mov    0xc(%edx),%edx
  801737:	85 d2                	test   %edx,%edx
  801739:	74 17                	je     801752 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80173b:	83 ec 04             	sub    $0x4,%esp
  80173e:	ff 75 10             	pushl  0x10(%ebp)
  801741:	ff 75 0c             	pushl  0xc(%ebp)
  801744:	50                   	push   %eax
  801745:	ff d2                	call   *%edx
  801747:	89 c2                	mov    %eax,%edx
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	eb 09                	jmp    801757 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174e:	89 c2                	mov    %eax,%edx
  801750:	eb 05                	jmp    801757 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801752:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801757:	89 d0                	mov    %edx,%eax
  801759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <seek>:

int
seek(int fdnum, off_t offset)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801764:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801767:	50                   	push   %eax
  801768:	ff 75 08             	pushl  0x8(%ebp)
  80176b:	e8 22 fc ff ff       	call   801392 <fd_lookup>
  801770:	83 c4 08             	add    $0x8,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 0e                	js     801785 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801777:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80177a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80177d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 14             	sub    $0x14,%esp
  80178e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801791:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801794:	50                   	push   %eax
  801795:	53                   	push   %ebx
  801796:	e8 f7 fb ff ff       	call   801392 <fd_lookup>
  80179b:	83 c4 08             	add    $0x8,%esp
  80179e:	89 c2                	mov    %eax,%edx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 65                	js     801809 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a4:	83 ec 08             	sub    $0x8,%esp
  8017a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ae:	ff 30                	pushl  (%eax)
  8017b0:	e8 33 fc ff ff       	call   8013e8 <dev_lookup>
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	78 44                	js     801800 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c3:	75 21                	jne    8017e6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017ca:	8b 40 48             	mov    0x48(%eax),%eax
  8017cd:	83 ec 04             	sub    $0x4,%esp
  8017d0:	53                   	push   %ebx
  8017d1:	50                   	push   %eax
  8017d2:	68 88 28 80 00       	push   $0x802888
  8017d7:	e8 f4 ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e4:	eb 23                	jmp    801809 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e9:	8b 52 18             	mov    0x18(%edx),%edx
  8017ec:	85 d2                	test   %edx,%edx
  8017ee:	74 14                	je     801804 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	ff 75 0c             	pushl  0xc(%ebp)
  8017f6:	50                   	push   %eax
  8017f7:	ff d2                	call   *%edx
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	eb 09                	jmp    801809 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801800:	89 c2                	mov    %eax,%edx
  801802:	eb 05                	jmp    801809 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801804:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801809:	89 d0                	mov    %edx,%eax
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	53                   	push   %ebx
  801814:	83 ec 14             	sub    $0x14,%esp
  801817:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	ff 75 08             	pushl  0x8(%ebp)
  801821:	e8 6c fb ff ff       	call   801392 <fd_lookup>
  801826:	83 c4 08             	add    $0x8,%esp
  801829:	89 c2                	mov    %eax,%edx
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 58                	js     801887 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801835:	50                   	push   %eax
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	ff 30                	pushl  (%eax)
  80183b:	e8 a8 fb ff ff       	call   8013e8 <dev_lookup>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 37                	js     80187e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184e:	74 32                	je     801882 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801850:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801853:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80185a:	00 00 00 
	stat->st_isdir = 0;
  80185d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801864:	00 00 00 
	stat->st_dev = dev;
  801867:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	53                   	push   %ebx
  801871:	ff 75 f0             	pushl  -0x10(%ebp)
  801874:	ff 50 14             	call   *0x14(%eax)
  801877:	89 c2                	mov    %eax,%edx
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	eb 09                	jmp    801887 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187e:	89 c2                	mov    %eax,%edx
  801880:	eb 05                	jmp    801887 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801882:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801887:	89 d0                	mov    %edx,%eax
  801889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	6a 00                	push   $0x0
  801898:	ff 75 08             	pushl  0x8(%ebp)
  80189b:	e8 dc 01 00 00       	call   801a7c <open>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 1b                	js     8018c4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	ff 75 0c             	pushl  0xc(%ebp)
  8018af:	50                   	push   %eax
  8018b0:	e8 5b ff ff ff       	call   801810 <fstat>
  8018b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b7:	89 1c 24             	mov    %ebx,(%esp)
  8018ba:	e8 fd fb ff ff       	call   8014bc <close>
	return r;
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	89 f0                	mov    %esi,%eax
}
  8018c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	89 c6                	mov    %eax,%esi
  8018d2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d4:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018db:	75 12                	jne    8018ef <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	6a 01                	push   $0x1
  8018e2:	e8 b8 07 00 00       	call   80209f <ipc_find_env>
  8018e7:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018ec:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ef:	6a 07                	push   $0x7
  8018f1:	68 00 50 80 00       	push   $0x805000
  8018f6:	56                   	push   %esi
  8018f7:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018fd:	e8 5a 07 00 00       	call   80205c <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801902:	83 c4 0c             	add    $0xc,%esp
  801905:	6a 00                	push   $0x0
  801907:	53                   	push   %ebx
  801908:	6a 00                	push   $0x0
  80190a:	e8 f0 06 00 00       	call   801fff <ipc_recv>
}
  80190f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    

00801916 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 40 0c             	mov    0xc(%eax),%eax
  801922:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192f:	ba 00 00 00 00       	mov    $0x0,%edx
  801934:	b8 02 00 00 00       	mov    $0x2,%eax
  801939:	e8 8d ff ff ff       	call   8018cb <fsipc>
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	8b 40 0c             	mov    0xc(%eax),%eax
  80194c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801951:	ba 00 00 00 00       	mov    $0x0,%edx
  801956:	b8 06 00 00 00       	mov    $0x6,%eax
  80195b:	e8 6b ff ff ff       	call   8018cb <fsipc>
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	83 ec 04             	sub    $0x4,%esp
  801969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	8b 40 0c             	mov    0xc(%eax),%eax
  801972:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 05 00 00 00       	mov    $0x5,%eax
  801981:	e8 45 ff ff ff       	call   8018cb <fsipc>
  801986:	85 c0                	test   %eax,%eax
  801988:	78 2c                	js     8019b6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198a:	83 ec 08             	sub    $0x8,%esp
  80198d:	68 00 50 80 00       	push   $0x805000
  801992:	53                   	push   %ebx
  801993:	e8 07 f3 ff ff       	call   800c9f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801998:	a1 80 50 80 00       	mov    0x805080,%eax
  80199d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a3:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8019ca:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019d0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019d5:	50                   	push   %eax
  8019d6:	ff 75 0c             	pushl  0xc(%ebp)
  8019d9:	68 08 50 80 00       	push   $0x805008
  8019de:	e8 4e f4 ff ff       	call   800e31 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8019e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ed:	e8 d9 fe ff ff       	call   8018cb <fsipc>
	//panic("devfile_write not implemented");
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801a02:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a07:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a12:	b8 03 00 00 00       	mov    $0x3,%eax
  801a17:	e8 af fe ff ff       	call   8018cb <fsipc>
  801a1c:	89 c3                	mov    %eax,%ebx
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 51                	js     801a73 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801a22:	39 c6                	cmp    %eax,%esi
  801a24:	73 19                	jae    801a3f <devfile_read+0x4b>
  801a26:	68 f8 28 80 00       	push   $0x8028f8
  801a2b:	68 ff 28 80 00       	push   $0x8028ff
  801a30:	68 80 00 00 00       	push   $0x80
  801a35:	68 14 29 80 00       	push   $0x802914
  801a3a:	e8 b8 eb ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE);
  801a3f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a44:	7e 19                	jle    801a5f <devfile_read+0x6b>
  801a46:	68 1f 29 80 00       	push   $0x80291f
  801a4b:	68 ff 28 80 00       	push   $0x8028ff
  801a50:	68 81 00 00 00       	push   $0x81
  801a55:	68 14 29 80 00       	push   $0x802914
  801a5a:	e8 98 eb ff ff       	call   8005f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a5f:	83 ec 04             	sub    $0x4,%esp
  801a62:	50                   	push   %eax
  801a63:	68 00 50 80 00       	push   $0x805000
  801a68:	ff 75 0c             	pushl  0xc(%ebp)
  801a6b:	e8 c1 f3 ff ff       	call   800e31 <memmove>
	return r;
  801a70:	83 c4 10             	add    $0x10,%esp
}
  801a73:	89 d8                	mov    %ebx,%eax
  801a75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a78:	5b                   	pop    %ebx
  801a79:	5e                   	pop    %esi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 20             	sub    $0x20,%esp
  801a83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a86:	53                   	push   %ebx
  801a87:	e8 da f1 ff ff       	call   800c66 <strlen>
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a94:	7f 67                	jg     801afd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9c:	50                   	push   %eax
  801a9d:	e8 a1 f8 ff ff       	call   801343 <fd_alloc>
  801aa2:	83 c4 10             	add    $0x10,%esp
		return r;
  801aa5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 57                	js     801b02 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	53                   	push   %ebx
  801aaf:	68 00 50 80 00       	push   $0x805000
  801ab4:	e8 e6 f1 ff ff       	call   800c9f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abc:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac9:	e8 fd fd ff ff       	call   8018cb <fsipc>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	79 14                	jns    801aeb <open+0x6f>
		
		fd_close(fd, 0);
  801ad7:	83 ec 08             	sub    $0x8,%esp
  801ada:	6a 00                	push   $0x0
  801adc:	ff 75 f4             	pushl  -0xc(%ebp)
  801adf:	e8 57 f9 ff ff       	call   80143b <fd_close>
		return r;
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	89 da                	mov    %ebx,%edx
  801ae9:	eb 17                	jmp    801b02 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	ff 75 f4             	pushl  -0xc(%ebp)
  801af1:	e8 26 f8 ff ff       	call   80131c <fd2num>
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	eb 05                	jmp    801b02 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801afd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801b02:	89 d0                	mov    %edx,%eax
  801b04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b14:	b8 08 00 00 00       	mov    $0x8,%eax
  801b19:	e8 ad fd ff ff       	call   8018cb <fsipc>
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	56                   	push   %esi
  801b24:	53                   	push   %ebx
  801b25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	ff 75 08             	pushl  0x8(%ebp)
  801b2e:	e8 f9 f7 ff ff       	call   80132c <fd2data>
  801b33:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b35:	83 c4 08             	add    $0x8,%esp
  801b38:	68 2b 29 80 00       	push   $0x80292b
  801b3d:	53                   	push   %ebx
  801b3e:	e8 5c f1 ff ff       	call   800c9f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b43:	8b 46 04             	mov    0x4(%esi),%eax
  801b46:	2b 06                	sub    (%esi),%eax
  801b48:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b4e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b55:	00 00 00 
	stat->st_dev = &devpipe;
  801b58:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b5f:	30 80 00 
	return 0;
}
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
  801b67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b78:	53                   	push   %ebx
  801b79:	6a 00                	push   $0x0
  801b7b:	e8 a7 f5 ff ff       	call   801127 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b80:	89 1c 24             	mov    %ebx,(%esp)
  801b83:	e8 a4 f7 ff ff       	call   80132c <fd2data>
  801b88:	83 c4 08             	add    $0x8,%esp
  801b8b:	50                   	push   %eax
  801b8c:	6a 00                	push   $0x0
  801b8e:	e8 94 f5 ff ff       	call   801127 <sys_page_unmap>
}
  801b93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	57                   	push   %edi
  801b9c:	56                   	push   %esi
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 1c             	sub    $0x1c,%esp
  801ba1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ba6:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801bab:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bae:	83 ec 0c             	sub    $0xc,%esp
  801bb1:	ff 75 e0             	pushl  -0x20(%ebp)
  801bb4:	e8 1f 05 00 00       	call   8020d8 <pageref>
  801bb9:	89 c3                	mov    %eax,%ebx
  801bbb:	89 3c 24             	mov    %edi,(%esp)
  801bbe:	e8 15 05 00 00       	call   8020d8 <pageref>
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	39 c3                	cmp    %eax,%ebx
  801bc8:	0f 94 c1             	sete   %cl
  801bcb:	0f b6 c9             	movzbl %cl,%ecx
  801bce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bd1:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801bd7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bda:	39 ce                	cmp    %ecx,%esi
  801bdc:	74 1b                	je     801bf9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bde:	39 c3                	cmp    %eax,%ebx
  801be0:	75 c4                	jne    801ba6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801be2:	8b 42 58             	mov    0x58(%edx),%eax
  801be5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be8:	50                   	push   %eax
  801be9:	56                   	push   %esi
  801bea:	68 32 29 80 00       	push   $0x802932
  801bef:	e8 dc ea ff ff       	call   8006d0 <cprintf>
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	eb ad                	jmp    801ba6 <_pipeisclosed+0xe>
	}
}
  801bf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5f                   	pop    %edi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	57                   	push   %edi
  801c08:	56                   	push   %esi
  801c09:	53                   	push   %ebx
  801c0a:	83 ec 28             	sub    $0x28,%esp
  801c0d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c10:	56                   	push   %esi
  801c11:	e8 16 f7 ff ff       	call   80132c <fd2data>
  801c16:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	bf 00 00 00 00       	mov    $0x0,%edi
  801c20:	eb 4b                	jmp    801c6d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c22:	89 da                	mov    %ebx,%edx
  801c24:	89 f0                	mov    %esi,%eax
  801c26:	e8 6d ff ff ff       	call   801b98 <_pipeisclosed>
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	75 48                	jne    801c77 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c2f:	e8 4f f4 ff ff       	call   801083 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c34:	8b 43 04             	mov    0x4(%ebx),%eax
  801c37:	8b 0b                	mov    (%ebx),%ecx
  801c39:	8d 51 20             	lea    0x20(%ecx),%edx
  801c3c:	39 d0                	cmp    %edx,%eax
  801c3e:	73 e2                	jae    801c22 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c43:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c47:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	c1 fa 1f             	sar    $0x1f,%edx
  801c4f:	89 d1                	mov    %edx,%ecx
  801c51:	c1 e9 1b             	shr    $0x1b,%ecx
  801c54:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c57:	83 e2 1f             	and    $0x1f,%edx
  801c5a:	29 ca                	sub    %ecx,%edx
  801c5c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c60:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c64:	83 c0 01             	add    $0x1,%eax
  801c67:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6a:	83 c7 01             	add    $0x1,%edi
  801c6d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c70:	75 c2                	jne    801c34 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c72:	8b 45 10             	mov    0x10(%ebp),%eax
  801c75:	eb 05                	jmp    801c7c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c77:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    

00801c84 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	57                   	push   %edi
  801c88:	56                   	push   %esi
  801c89:	53                   	push   %ebx
  801c8a:	83 ec 18             	sub    $0x18,%esp
  801c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c90:	57                   	push   %edi
  801c91:	e8 96 f6 ff ff       	call   80132c <fd2data>
  801c96:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ca0:	eb 3d                	jmp    801cdf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ca2:	85 db                	test   %ebx,%ebx
  801ca4:	74 04                	je     801caa <devpipe_read+0x26>
				return i;
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	eb 44                	jmp    801cee <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801caa:	89 f2                	mov    %esi,%edx
  801cac:	89 f8                	mov    %edi,%eax
  801cae:	e8 e5 fe ff ff       	call   801b98 <_pipeisclosed>
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	75 32                	jne    801ce9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cb7:	e8 c7 f3 ff ff       	call   801083 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cbc:	8b 06                	mov    (%esi),%eax
  801cbe:	3b 46 04             	cmp    0x4(%esi),%eax
  801cc1:	74 df                	je     801ca2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cc3:	99                   	cltd   
  801cc4:	c1 ea 1b             	shr    $0x1b,%edx
  801cc7:	01 d0                	add    %edx,%eax
  801cc9:	83 e0 1f             	and    $0x1f,%eax
  801ccc:	29 d0                	sub    %edx,%eax
  801cce:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cd9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdc:	83 c3 01             	add    $0x1,%ebx
  801cdf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ce2:	75 d8                	jne    801cbc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ce4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce7:	eb 05                	jmp    801cee <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ce9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    

00801cf6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	56                   	push   %esi
  801cfa:	53                   	push   %ebx
  801cfb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d01:	50                   	push   %eax
  801d02:	e8 3c f6 ff ff       	call   801343 <fd_alloc>
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	89 c2                	mov    %eax,%edx
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	0f 88 2c 01 00 00    	js     801e40 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d14:	83 ec 04             	sub    $0x4,%esp
  801d17:	68 07 04 00 00       	push   $0x407
  801d1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1f:	6a 00                	push   $0x0
  801d21:	e8 7c f3 ff ff       	call   8010a2 <sys_page_alloc>
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	89 c2                	mov    %eax,%edx
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	0f 88 0d 01 00 00    	js     801e40 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d33:	83 ec 0c             	sub    $0xc,%esp
  801d36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d39:	50                   	push   %eax
  801d3a:	e8 04 f6 ff ff       	call   801343 <fd_alloc>
  801d3f:	89 c3                	mov    %eax,%ebx
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	85 c0                	test   %eax,%eax
  801d46:	0f 88 e2 00 00 00    	js     801e2e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4c:	83 ec 04             	sub    $0x4,%esp
  801d4f:	68 07 04 00 00       	push   $0x407
  801d54:	ff 75 f0             	pushl  -0x10(%ebp)
  801d57:	6a 00                	push   $0x0
  801d59:	e8 44 f3 ff ff       	call   8010a2 <sys_page_alloc>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	0f 88 c3 00 00 00    	js     801e2e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d6b:	83 ec 0c             	sub    $0xc,%esp
  801d6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d71:	e8 b6 f5 ff ff       	call   80132c <fd2data>
  801d76:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d78:	83 c4 0c             	add    $0xc,%esp
  801d7b:	68 07 04 00 00       	push   $0x407
  801d80:	50                   	push   %eax
  801d81:	6a 00                	push   $0x0
  801d83:	e8 1a f3 ff ff       	call   8010a2 <sys_page_alloc>
  801d88:	89 c3                	mov    %eax,%ebx
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	0f 88 89 00 00 00    	js     801e1e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d95:	83 ec 0c             	sub    $0xc,%esp
  801d98:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9b:	e8 8c f5 ff ff       	call   80132c <fd2data>
  801da0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801da7:	50                   	push   %eax
  801da8:	6a 00                	push   $0x0
  801daa:	56                   	push   %esi
  801dab:	6a 00                	push   $0x0
  801dad:	e8 33 f3 ff ff       	call   8010e5 <sys_page_map>
  801db2:	89 c3                	mov    %eax,%ebx
  801db4:	83 c4 20             	add    $0x20,%esp
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 55                	js     801e10 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dbb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dd0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dde:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 f4             	pushl  -0xc(%ebp)
  801deb:	e8 2c f5 ff ff       	call   80131c <fd2num>
  801df0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801df3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801df5:	83 c4 04             	add    $0x4,%esp
  801df8:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfb:	e8 1c f5 ff ff       	call   80131c <fd2num>
  801e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e03:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	ba 00 00 00 00       	mov    $0x0,%edx
  801e0e:	eb 30                	jmp    801e40 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e10:	83 ec 08             	sub    $0x8,%esp
  801e13:	56                   	push   %esi
  801e14:	6a 00                	push   $0x0
  801e16:	e8 0c f3 ff ff       	call   801127 <sys_page_unmap>
  801e1b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e1e:	83 ec 08             	sub    $0x8,%esp
  801e21:	ff 75 f0             	pushl  -0x10(%ebp)
  801e24:	6a 00                	push   $0x0
  801e26:	e8 fc f2 ff ff       	call   801127 <sys_page_unmap>
  801e2b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e2e:	83 ec 08             	sub    $0x8,%esp
  801e31:	ff 75 f4             	pushl  -0xc(%ebp)
  801e34:	6a 00                	push   $0x0
  801e36:	e8 ec f2 ff ff       	call   801127 <sys_page_unmap>
  801e3b:	83 c4 10             	add    $0x10,%esp
  801e3e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e40:	89 d0                	mov    %edx,%eax
  801e42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e52:	50                   	push   %eax
  801e53:	ff 75 08             	pushl  0x8(%ebp)
  801e56:	e8 37 f5 ff ff       	call   801392 <fd_lookup>
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	78 18                	js     801e7a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e62:	83 ec 0c             	sub    $0xc,%esp
  801e65:	ff 75 f4             	pushl  -0xc(%ebp)
  801e68:	e8 bf f4 ff ff       	call   80132c <fd2data>
	return _pipeisclosed(fd, p);
  801e6d:	89 c2                	mov    %eax,%edx
  801e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e72:	e8 21 fd ff ff       	call   801b98 <_pipeisclosed>
  801e77:	83 c4 10             	add    $0x10,%esp
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e8c:	68 4a 29 80 00       	push   $0x80294a
  801e91:	ff 75 0c             	pushl  0xc(%ebp)
  801e94:	e8 06 ee ff ff       	call   800c9f <strcpy>
	return 0;
}
  801e99:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	57                   	push   %edi
  801ea4:	56                   	push   %esi
  801ea5:	53                   	push   %ebx
  801ea6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eac:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eb1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb7:	eb 2d                	jmp    801ee6 <devcons_write+0x46>
		m = n - tot;
  801eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ebc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ebe:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ec1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ec6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec9:	83 ec 04             	sub    $0x4,%esp
  801ecc:	53                   	push   %ebx
  801ecd:	03 45 0c             	add    0xc(%ebp),%eax
  801ed0:	50                   	push   %eax
  801ed1:	57                   	push   %edi
  801ed2:	e8 5a ef ff ff       	call   800e31 <memmove>
		sys_cputs(buf, m);
  801ed7:	83 c4 08             	add    $0x8,%esp
  801eda:	53                   	push   %ebx
  801edb:	57                   	push   %edi
  801edc:	e8 05 f1 ff ff       	call   800fe6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ee1:	01 de                	add    %ebx,%esi
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	89 f0                	mov    %esi,%eax
  801ee8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eeb:	72 cc                	jb     801eb9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5e                   	pop    %esi
  801ef2:	5f                   	pop    %edi
  801ef3:	5d                   	pop    %ebp
  801ef4:	c3                   	ret    

00801ef5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 08             	sub    $0x8,%esp
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f04:	74 2a                	je     801f30 <devcons_read+0x3b>
  801f06:	eb 05                	jmp    801f0d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f08:	e8 76 f1 ff ff       	call   801083 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f0d:	e8 f2 f0 ff ff       	call   801004 <sys_cgetc>
  801f12:	85 c0                	test   %eax,%eax
  801f14:	74 f2                	je     801f08 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f16:	85 c0                	test   %eax,%eax
  801f18:	78 16                	js     801f30 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f1a:	83 f8 04             	cmp    $0x4,%eax
  801f1d:	74 0c                	je     801f2b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f22:	88 02                	mov    %al,(%edx)
	return 1;
  801f24:	b8 01 00 00 00       	mov    $0x1,%eax
  801f29:	eb 05                	jmp    801f30 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f38:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f3e:	6a 01                	push   $0x1
  801f40:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f43:	50                   	push   %eax
  801f44:	e8 9d f0 ff ff       	call   800fe6 <sys_cputs>
}
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    

00801f4e <getchar>:

int
getchar(void)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f54:	6a 01                	push   $0x1
  801f56:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f59:	50                   	push   %eax
  801f5a:	6a 00                	push   $0x0
  801f5c:	e8 97 f6 ff ff       	call   8015f8 <read>
	if (r < 0)
  801f61:	83 c4 10             	add    $0x10,%esp
  801f64:	85 c0                	test   %eax,%eax
  801f66:	78 0f                	js     801f77 <getchar+0x29>
		return r;
	if (r < 1)
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	7e 06                	jle    801f72 <getchar+0x24>
		return -E_EOF;
	return c;
  801f6c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f70:	eb 05                	jmp    801f77 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f72:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f77:	c9                   	leave  
  801f78:	c3                   	ret    

00801f79 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f82:	50                   	push   %eax
  801f83:	ff 75 08             	pushl  0x8(%ebp)
  801f86:	e8 07 f4 ff ff       	call   801392 <fd_lookup>
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 11                	js     801fa3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f9b:	39 10                	cmp    %edx,(%eax)
  801f9d:	0f 94 c0             	sete   %al
  801fa0:	0f b6 c0             	movzbl %al,%eax
}
  801fa3:	c9                   	leave  
  801fa4:	c3                   	ret    

00801fa5 <opencons>:

int
opencons(void)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fae:	50                   	push   %eax
  801faf:	e8 8f f3 ff ff       	call   801343 <fd_alloc>
  801fb4:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 3e                	js     801ffb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fbd:	83 ec 04             	sub    $0x4,%esp
  801fc0:	68 07 04 00 00       	push   $0x407
  801fc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc8:	6a 00                	push   $0x0
  801fca:	e8 d3 f0 ff ff       	call   8010a2 <sys_page_alloc>
  801fcf:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd4:	85 c0                	test   %eax,%eax
  801fd6:	78 23                	js     801ffb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fed:	83 ec 0c             	sub    $0xc,%esp
  801ff0:	50                   	push   %eax
  801ff1:	e8 26 f3 ff ff       	call   80131c <fd2num>
  801ff6:	89 c2                	mov    %eax,%edx
  801ff8:	83 c4 10             	add    $0x10,%esp
}
  801ffb:	89 d0                	mov    %edx,%eax
  801ffd:	c9                   	leave  
  801ffe:	c3                   	ret    

00801fff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802007:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  80200a:	83 ec 0c             	sub    $0xc,%esp
  80200d:	ff 75 0c             	pushl  0xc(%ebp)
  802010:	e8 3d f2 ff ff       	call   801252 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 f6                	test   %esi,%esi
  80201a:	74 1c                	je     802038 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  80201c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802021:	8b 40 78             	mov    0x78(%eax),%eax
  802024:	89 06                	mov    %eax,(%esi)
  802026:	eb 10                	jmp    802038 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802028:	83 ec 0c             	sub    $0xc,%esp
  80202b:	68 56 29 80 00       	push   $0x802956
  802030:	e8 9b e6 ff ff       	call   8006d0 <cprintf>
  802035:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802038:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80203d:	8b 50 74             	mov    0x74(%eax),%edx
  802040:	85 d2                	test   %edx,%edx
  802042:	74 e4                	je     802028 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  802044:	85 db                	test   %ebx,%ebx
  802046:	74 05                	je     80204d <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802048:	8b 40 74             	mov    0x74(%eax),%eax
  80204b:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80204d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802052:	8b 40 70             	mov    0x70(%eax),%eax

}
  802055:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802058:	5b                   	pop    %ebx
  802059:	5e                   	pop    %esi
  80205a:	5d                   	pop    %ebp
  80205b:	c3                   	ret    

0080205c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	57                   	push   %edi
  802060:	56                   	push   %esi
  802061:	53                   	push   %ebx
  802062:	83 ec 0c             	sub    $0xc,%esp
  802065:	8b 7d 08             	mov    0x8(%ebp),%edi
  802068:	8b 75 0c             	mov    0xc(%ebp),%esi
  80206b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  80206e:	85 db                	test   %ebx,%ebx
  802070:	75 13                	jne    802085 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  802072:	6a 00                	push   $0x0
  802074:	68 00 00 c0 ee       	push   $0xeec00000
  802079:	56                   	push   %esi
  80207a:	57                   	push   %edi
  80207b:	e8 af f1 ff ff       	call   80122f <sys_ipc_try_send>
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	eb 0e                	jmp    802093 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  802085:	ff 75 14             	pushl  0x14(%ebp)
  802088:	53                   	push   %ebx
  802089:	56                   	push   %esi
  80208a:	57                   	push   %edi
  80208b:	e8 9f f1 ff ff       	call   80122f <sys_ipc_try_send>
  802090:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  802093:	85 c0                	test   %eax,%eax
  802095:	75 d7                	jne    80206e <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  802097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209a:	5b                   	pop    %ebx
  80209b:	5e                   	pop    %esi
  80209c:	5f                   	pop    %edi
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    

0080209f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020aa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020ad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020b3:	8b 52 50             	mov    0x50(%edx),%edx
  8020b6:	39 ca                	cmp    %ecx,%edx
  8020b8:	75 0d                	jne    8020c7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c2:	8b 40 48             	mov    0x48(%eax),%eax
  8020c5:	eb 0f                	jmp    8020d6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020c7:	83 c0 01             	add    $0x1,%eax
  8020ca:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020cf:	75 d9                	jne    8020aa <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    

008020d8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020de:	89 d0                	mov    %edx,%eax
  8020e0:	c1 e8 16             	shr    $0x16,%eax
  8020e3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ea:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ef:	f6 c1 01             	test   $0x1,%cl
  8020f2:	74 1d                	je     802111 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020f4:	c1 ea 0c             	shr    $0xc,%edx
  8020f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020fe:	f6 c2 01             	test   $0x1,%dl
  802101:	74 0e                	je     802111 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802103:	c1 ea 0c             	shr    $0xc,%edx
  802106:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80210d:	ef 
  80210e:	0f b7 c0             	movzwl %ax,%eax
}
  802111:	5d                   	pop    %ebp
  802112:	c3                   	ret    
  802113:	66 90                	xchg   %ax,%ax
  802115:	66 90                	xchg   %ax,%ax
  802117:	66 90                	xchg   %ax,%ax
  802119:	66 90                	xchg   %ax,%ax
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
