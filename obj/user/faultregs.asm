
obj/user/faultregs:     file format elf32-i386


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
  800044:	68 85 1a 80 00       	push   $0x801a85
  800049:	68 e0 15 80 00       	push   $0x8015e0
  80004e:	e8 75 06 00 00       	call   8006c8 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 f0 15 80 00       	push   $0x8015f0
  80005c:	68 f4 15 80 00       	push   $0x8015f4
  800061:	e8 62 06 00 00       	call   8006c8 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 04 16 80 00       	push   $0x801604
  800077:	e8 4c 06 00 00       	call   8006c8 <cprintf>
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
  800089:	68 08 16 80 00       	push   $0x801608
  80008e:	e8 35 06 00 00       	call   8006c8 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 12 16 80 00       	push   $0x801612
  8000a6:	68 f4 15 80 00       	push   $0x8015f4
  8000ab:	e8 18 06 00 00       	call   8006c8 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 04 16 80 00       	push   $0x801604
  8000c3:	e8 00 06 00 00       	call   8006c8 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 08 16 80 00       	push   $0x801608
  8000d5:	e8 ee 05 00 00       	call   8006c8 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 16 16 80 00       	push   $0x801616
  8000ed:	68 f4 15 80 00       	push   $0x8015f4
  8000f2:	e8 d1 05 00 00       	call   8006c8 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 04 16 80 00       	push   $0x801604
  80010a:	e8 b9 05 00 00       	call   8006c8 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 08 16 80 00       	push   $0x801608
  80011c:	e8 a7 05 00 00       	call   8006c8 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 1a 16 80 00       	push   $0x80161a
  800134:	68 f4 15 80 00       	push   $0x8015f4
  800139:	e8 8a 05 00 00       	call   8006c8 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 04 16 80 00       	push   $0x801604
  800151:	e8 72 05 00 00       	call   8006c8 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 08 16 80 00       	push   $0x801608
  800163:	e8 60 05 00 00       	call   8006c8 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 1e 16 80 00       	push   $0x80161e
  80017b:	68 f4 15 80 00       	push   $0x8015f4
  800180:	e8 43 05 00 00       	call   8006c8 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 04 16 80 00       	push   $0x801604
  800198:	e8 2b 05 00 00       	call   8006c8 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 08 16 80 00       	push   $0x801608
  8001aa:	e8 19 05 00 00       	call   8006c8 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 22 16 80 00       	push   $0x801622
  8001c2:	68 f4 15 80 00       	push   $0x8015f4
  8001c7:	e8 fc 04 00 00       	call   8006c8 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 04 16 80 00       	push   $0x801604
  8001df:	e8 e4 04 00 00       	call   8006c8 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 08 16 80 00       	push   $0x801608
  8001f1:	e8 d2 04 00 00       	call   8006c8 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 26 16 80 00       	push   $0x801626
  800209:	68 f4 15 80 00       	push   $0x8015f4
  80020e:	e8 b5 04 00 00       	call   8006c8 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 04 16 80 00       	push   $0x801604
  800226:	e8 9d 04 00 00       	call   8006c8 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 08 16 80 00       	push   $0x801608
  800238:	e8 8b 04 00 00       	call   8006c8 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 2a 16 80 00       	push   $0x80162a
  800250:	68 f4 15 80 00       	push   $0x8015f4
  800255:	e8 6e 04 00 00       	call   8006c8 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 04 16 80 00       	push   $0x801604
  80026d:	e8 56 04 00 00       	call   8006c8 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 08 16 80 00       	push   $0x801608
  80027f:	e8 44 04 00 00       	call   8006c8 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 2e 16 80 00       	push   $0x80162e
  800297:	68 f4 15 80 00       	push   $0x8015f4
  80029c:	e8 27 04 00 00       	call   8006c8 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 04 16 80 00       	push   $0x801604
  8002b4:	e8 0f 04 00 00       	call   8006c8 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 35 16 80 00       	push   $0x801635
  8002c4:	68 f4 15 80 00       	push   $0x8015f4
  8002c9:	e8 fa 03 00 00       	call   8006c8 <cprintf>
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
  8002de:	68 08 16 80 00       	push   $0x801608
  8002e3:	e8 e0 03 00 00       	call   8006c8 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 35 16 80 00       	push   $0x801635
  8002f3:	68 f4 15 80 00       	push   $0x8015f4
  8002f8:	e8 cb 03 00 00       	call   8006c8 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 04 16 80 00       	push   $0x801604
  800312:	e8 b1 03 00 00       	call   8006c8 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 39 16 80 00       	push   $0x801639
  800322:	e8 a1 03 00 00       	call   8006c8 <cprintf>
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
  800333:	68 08 16 80 00       	push   $0x801608
  800338:	e8 8b 03 00 00       	call   8006c8 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 39 16 80 00       	push   $0x801639
  800348:	e8 7b 03 00 00       	call   8006c8 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 04 16 80 00       	push   $0x801604
  80035a:	e8 69 03 00 00       	call   8006c8 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 08 16 80 00       	push   $0x801608
  80036c:	e8 57 03 00 00       	call   8006c8 <cprintf>
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
  800379:	68 04 16 80 00       	push   $0x801604
  80037e:	e8 45 03 00 00       	call   8006c8 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 39 16 80 00       	push   $0x801639
  80038e:	e8 35 03 00 00       	call   8006c8 <cprintf>
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
  8003ba:	68 a0 16 80 00       	push   $0x8016a0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 47 16 80 00       	push   $0x801647
  8003c6:	e8 24 02 00 00       	call   8005ef <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 74 20 80 00    	mov    %edx,0x802074
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 78 20 80 00    	mov    %edx,0x802078
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 5f 16 80 00       	push   $0x80165f
  80043b:	68 6d 16 80 00       	push   $0x80166d
  800440:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800445:	ba 58 16 80 00       	mov    $0x801658,%edx
  80044a:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 35 0c 00 00       	call   80109a <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 74 16 80 00       	push   $0x801674
  800472:	6a 5c                	push   $0x5c
  800474:	68 47 16 80 00       	push   $0x801647
  800479:	e8 71 01 00 00       	call   8005ef <_panic>
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
  80048b:	e8 b9 0d 00 00       	call   801249 <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004b1:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004b7:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004bd:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004c3:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004c9:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004cf:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004d4:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004ea:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004f0:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004f6:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004fc:	89 15 34 20 80 00    	mov    %edx,0x802034
  800502:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800508:	a3 3c 20 80 00       	mov    %eax,0x80203c
  80050d:	89 25 48 20 80 00    	mov    %esp,0x802048
  800513:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800519:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  80051f:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  800525:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  80052b:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800531:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800537:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  80053c:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 44 20 80 00       	mov    %eax,0x802044
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
  80055a:	68 d4 16 80 00       	push   $0x8016d4
  80055f:	e8 64 01 00 00       	call   8006c8 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  80056c:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 87 16 80 00       	push   $0x801687
  800579:	68 98 16 80 00       	push   $0x801698
  80057e:	b9 20 20 80 00       	mov    $0x802020,%ecx
  800583:	ba 58 16 80 00       	mov    $0x801658,%edx
  800588:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
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
  8005a2:	e8 b5 0a 00 00       	call   80105c <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8005e0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005e3:	6a 00                	push   $0x0
  8005e5:	e8 31 0a 00 00       	call   80101b <sys_env_destroy>
}
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	c9                   	leave  
  8005ee:	c3                   	ret    

008005ef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  8005f2:	56                   	push   %esi
  8005f3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8005fd:	e8 5a 0a 00 00       	call   80105c <sys_getenvid>
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	ff 75 0c             	pushl  0xc(%ebp)
  800608:	ff 75 08             	pushl  0x8(%ebp)
  80060b:	56                   	push   %esi
  80060c:	50                   	push   %eax
  80060d:	68 00 17 80 00       	push   $0x801700
  800612:	e8 b1 00 00 00       	call   8006c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800617:	83 c4 18             	add    $0x18,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 75 10             	pushl  0x10(%ebp)
  80061e:	e8 54 00 00 00       	call   800677 <vcprintf>
	cprintf("\n");
  800623:	c7 04 24 84 1a 80 00 	movl   $0x801a84,(%esp)
  80062a:	e8 99 00 00 00       	call   8006c8 <cprintf>
  80062f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800632:	cc                   	int3   
  800633:	eb fd                	jmp    800632 <_panic+0x43>

00800635 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	53                   	push   %ebx
  800639:	83 ec 04             	sub    $0x4,%esp
  80063c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063f:	8b 13                	mov    (%ebx),%edx
  800641:	8d 42 01             	lea    0x1(%edx),%eax
  800644:	89 03                	mov    %eax,(%ebx)
  800646:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800649:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800652:	75 1a                	jne    80066e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	68 ff 00 00 00       	push   $0xff
  80065c:	8d 43 08             	lea    0x8(%ebx),%eax
  80065f:	50                   	push   %eax
  800660:	e8 79 09 00 00       	call   800fde <sys_cputs>
		b->idx = 0;
  800665:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80066e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800675:	c9                   	leave  
  800676:	c3                   	ret    

00800677 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800680:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800687:	00 00 00 
	b.cnt = 0;
  80068a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800691:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800694:	ff 75 0c             	pushl  0xc(%ebp)
  800697:	ff 75 08             	pushl  0x8(%ebp)
  80069a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a0:	50                   	push   %eax
  8006a1:	68 35 06 80 00       	push   $0x800635
  8006a6:	e8 54 01 00 00       	call   8007ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	e8 1e 09 00 00       	call   800fde <sys_cputs>

	return b.cnt;
}
  8006c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d1:	50                   	push   %eax
  8006d2:	ff 75 08             	pushl  0x8(%ebp)
  8006d5:	e8 9d ff ff ff       	call   800677 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	57                   	push   %edi
  8006e0:	56                   	push   %esi
  8006e1:	53                   	push   %ebx
  8006e2:	83 ec 1c             	sub    $0x1c,%esp
  8006e5:	89 c7                	mov    %eax,%edi
  8006e7:	89 d6                	mov    %edx,%esi
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800700:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800703:	39 d3                	cmp    %edx,%ebx
  800705:	72 05                	jb     80070c <printnum+0x30>
  800707:	39 45 10             	cmp    %eax,0x10(%ebp)
  80070a:	77 45                	ja     800751 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	ff 75 18             	pushl  0x18(%ebp)
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800718:	53                   	push   %ebx
  800719:	ff 75 10             	pushl  0x10(%ebp)
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800722:	ff 75 e0             	pushl  -0x20(%ebp)
  800725:	ff 75 dc             	pushl  -0x24(%ebp)
  800728:	ff 75 d8             	pushl  -0x28(%ebp)
  80072b:	e8 10 0c 00 00       	call   801340 <__udivdi3>
  800730:	83 c4 18             	add    $0x18,%esp
  800733:	52                   	push   %edx
  800734:	50                   	push   %eax
  800735:	89 f2                	mov    %esi,%edx
  800737:	89 f8                	mov    %edi,%eax
  800739:	e8 9e ff ff ff       	call   8006dc <printnum>
  80073e:	83 c4 20             	add    $0x20,%esp
  800741:	eb 18                	jmp    80075b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	56                   	push   %esi
  800747:	ff 75 18             	pushl  0x18(%ebp)
  80074a:	ff d7                	call   *%edi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 03                	jmp    800754 <printnum+0x78>
  800751:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	85 db                	test   %ebx,%ebx
  800759:	7f e8                	jg     800743 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	56                   	push   %esi
  80075f:	83 ec 04             	sub    $0x4,%esp
  800762:	ff 75 e4             	pushl  -0x1c(%ebp)
  800765:	ff 75 e0             	pushl  -0x20(%ebp)
  800768:	ff 75 dc             	pushl  -0x24(%ebp)
  80076b:	ff 75 d8             	pushl  -0x28(%ebp)
  80076e:	e8 fd 0c 00 00       	call   801470 <__umoddi3>
  800773:	83 c4 14             	add    $0x14,%esp
  800776:	0f be 80 23 17 80 00 	movsbl 0x801723(%eax),%eax
  80077d:	50                   	push   %eax
  80077e:	ff d7                	call   *%edi
}
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5f                   	pop    %edi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078e:	83 fa 01             	cmp    $0x1,%edx
  800791:	7e 0e                	jle    8007a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800793:	8b 10                	mov    (%eax),%edx
  800795:	8d 4a 08             	lea    0x8(%edx),%ecx
  800798:	89 08                	mov    %ecx,(%eax)
  80079a:	8b 02                	mov    (%edx),%eax
  80079c:	8b 52 04             	mov    0x4(%edx),%edx
  80079f:	eb 22                	jmp    8007c3 <getuint+0x38>
	else if (lflag)
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	74 10                	je     8007b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a5:	8b 10                	mov    (%eax),%edx
  8007a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007aa:	89 08                	mov    %ecx,(%eax)
  8007ac:	8b 02                	mov    (%edx),%eax
  8007ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b3:	eb 0e                	jmp    8007c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ba:	89 08                	mov    %ecx,(%eax)
  8007bc:	8b 02                	mov    (%edx),%eax
  8007be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007cb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d4:	73 0a                	jae    8007e0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d9:	89 08                	mov    %ecx,(%eax)
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	88 02                	mov    %al,(%edx)
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007eb:	50                   	push   %eax
  8007ec:	ff 75 10             	pushl  0x10(%ebp)
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	ff 75 08             	pushl  0x8(%ebp)
  8007f5:	e8 05 00 00 00       	call   8007ff <vprintfmt>
	va_end(ap);
}
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	57                   	push   %edi
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	83 ec 2c             	sub    $0x2c,%esp
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800811:	eb 12                	jmp    800825 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800813:	85 c0                	test   %eax,%eax
  800815:	0f 84 d3 03 00 00    	je     800bee <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	53                   	push   %ebx
  80081f:	50                   	push   %eax
  800820:	ff d6                	call   *%esi
  800822:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800825:	83 c7 01             	add    $0x1,%edi
  800828:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80082c:	83 f8 25             	cmp    $0x25,%eax
  80082f:	75 e2                	jne    800813 <vprintfmt+0x14>
  800831:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800835:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80083c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800843:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80084a:	ba 00 00 00 00       	mov    $0x0,%edx
  80084f:	eb 07                	jmp    800858 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800854:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800858:	8d 47 01             	lea    0x1(%edi),%eax
  80085b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085e:	0f b6 07             	movzbl (%edi),%eax
  800861:	0f b6 c8             	movzbl %al,%ecx
  800864:	83 e8 23             	sub    $0x23,%eax
  800867:	3c 55                	cmp    $0x55,%al
  800869:	0f 87 64 03 00 00    	ja     800bd3 <vprintfmt+0x3d4>
  80086f:	0f b6 c0             	movzbl %al,%eax
  800872:	ff 24 85 e0 17 80 00 	jmp    *0x8017e0(,%eax,4)
  800879:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80087c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800880:	eb d6                	jmp    800858 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800882:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800890:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800894:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800897:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80089a:	83 fa 09             	cmp    $0x9,%edx
  80089d:	77 39                	ja     8008d8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80089f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a2:	eb e9                	jmp    80088d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8008aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008ad:	8b 00                	mov    (%eax),%eax
  8008af:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b5:	eb 27                	jmp    8008de <vprintfmt+0xdf>
  8008b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c1:	0f 49 c8             	cmovns %eax,%ecx
  8008c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ca:	eb 8c                	jmp    800858 <vprintfmt+0x59>
  8008cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008cf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d6:	eb 80                	jmp    800858 <vprintfmt+0x59>
  8008d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008db:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8008de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e2:	0f 89 70 ff ff ff    	jns    800858 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8008eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ee:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8008f5:	e9 5e ff ff ff       	jmp    800858 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008fa:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800900:	e9 53 ff ff ff       	jmp    800858 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8d 50 04             	lea    0x4(%eax),%edx
  80090b:	89 55 14             	mov    %edx,0x14(%ebp)
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	53                   	push   %ebx
  800912:	ff 30                	pushl  (%eax)
  800914:	ff d6                	call   *%esi
			break;
  800916:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800919:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80091c:	e9 04 ff ff ff       	jmp    800825 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800921:	8b 45 14             	mov    0x14(%ebp),%eax
  800924:	8d 50 04             	lea    0x4(%eax),%edx
  800927:	89 55 14             	mov    %edx,0x14(%ebp)
  80092a:	8b 00                	mov    (%eax),%eax
  80092c:	99                   	cltd   
  80092d:	31 d0                	xor    %edx,%eax
  80092f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800931:	83 f8 08             	cmp    $0x8,%eax
  800934:	7f 0b                	jg     800941 <vprintfmt+0x142>
  800936:	8b 14 85 40 19 80 00 	mov    0x801940(,%eax,4),%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	75 18                	jne    800959 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800941:	50                   	push   %eax
  800942:	68 3b 17 80 00       	push   $0x80173b
  800947:	53                   	push   %ebx
  800948:	56                   	push   %esi
  800949:	e8 94 fe ff ff       	call   8007e2 <printfmt>
  80094e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800951:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800954:	e9 cc fe ff ff       	jmp    800825 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800959:	52                   	push   %edx
  80095a:	68 44 17 80 00       	push   $0x801744
  80095f:	53                   	push   %ebx
  800960:	56                   	push   %esi
  800961:	e8 7c fe ff ff       	call   8007e2 <printfmt>
  800966:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800969:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096c:	e9 b4 fe ff ff       	jmp    800825 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 50 04             	lea    0x4(%eax),%edx
  800977:	89 55 14             	mov    %edx,0x14(%ebp)
  80097a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80097c:	85 ff                	test   %edi,%edi
  80097e:	b8 34 17 80 00       	mov    $0x801734,%eax
  800983:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800986:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098a:	0f 8e 94 00 00 00    	jle    800a24 <vprintfmt+0x225>
  800990:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800994:	0f 84 98 00 00 00    	je     800a32 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099a:	83 ec 08             	sub    $0x8,%esp
  80099d:	ff 75 c8             	pushl  -0x38(%ebp)
  8009a0:	57                   	push   %edi
  8009a1:	e8 d0 02 00 00       	call   800c76 <strnlen>
  8009a6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009a9:	29 c1                	sub    %eax,%ecx
  8009ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8009ae:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009bb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bd:	eb 0f                	jmp    8009ce <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	53                   	push   %ebx
  8009c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c8:	83 ef 01             	sub    $0x1,%edi
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	85 ff                	test   %edi,%edi
  8009d0:	7f ed                	jg     8009bf <vprintfmt+0x1c0>
  8009d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009d8:	85 c9                	test   %ecx,%ecx
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
  8009df:	0f 49 c1             	cmovns %ecx,%eax
  8009e2:	29 c1                	sub    %eax,%ecx
  8009e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e7:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8009ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ed:	89 cb                	mov    %ecx,%ebx
  8009ef:	eb 4d                	jmp    800a3e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f5:	74 1b                	je     800a12 <vprintfmt+0x213>
  8009f7:	0f be c0             	movsbl %al,%eax
  8009fa:	83 e8 20             	sub    $0x20,%eax
  8009fd:	83 f8 5e             	cmp    $0x5e,%eax
  800a00:	76 10                	jbe    800a12 <vprintfmt+0x213>
					putch('?', putdat);
  800a02:	83 ec 08             	sub    $0x8,%esp
  800a05:	ff 75 0c             	pushl  0xc(%ebp)
  800a08:	6a 3f                	push   $0x3f
  800a0a:	ff 55 08             	call   *0x8(%ebp)
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	eb 0d                	jmp    800a1f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a12:	83 ec 08             	sub    $0x8,%esp
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	52                   	push   %edx
  800a19:	ff 55 08             	call   *0x8(%ebp)
  800a1c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1f:	83 eb 01             	sub    $0x1,%ebx
  800a22:	eb 1a                	jmp    800a3e <vprintfmt+0x23f>
  800a24:	89 75 08             	mov    %esi,0x8(%ebp)
  800a27:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800a2a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a2d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a30:	eb 0c                	jmp    800a3e <vprintfmt+0x23f>
  800a32:	89 75 08             	mov    %esi,0x8(%ebp)
  800a35:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800a38:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3e:	83 c7 01             	add    $0x1,%edi
  800a41:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a45:	0f be d0             	movsbl %al,%edx
  800a48:	85 d2                	test   %edx,%edx
  800a4a:	74 23                	je     800a6f <vprintfmt+0x270>
  800a4c:	85 f6                	test   %esi,%esi
  800a4e:	78 a1                	js     8009f1 <vprintfmt+0x1f2>
  800a50:	83 ee 01             	sub    $0x1,%esi
  800a53:	79 9c                	jns    8009f1 <vprintfmt+0x1f2>
  800a55:	89 df                	mov    %ebx,%edi
  800a57:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5d:	eb 18                	jmp    800a77 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	53                   	push   %ebx
  800a63:	6a 20                	push   $0x20
  800a65:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a67:	83 ef 01             	sub    $0x1,%edi
  800a6a:	83 c4 10             	add    $0x10,%esp
  800a6d:	eb 08                	jmp    800a77 <vprintfmt+0x278>
  800a6f:	89 df                	mov    %ebx,%edi
  800a71:	8b 75 08             	mov    0x8(%ebp),%esi
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a77:	85 ff                	test   %edi,%edi
  800a79:	7f e4                	jg     800a5f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7e:	e9 a2 fd ff ff       	jmp    800825 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a83:	83 fa 01             	cmp    $0x1,%edx
  800a86:	7e 16                	jle    800a9e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a88:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8b:	8d 50 08             	lea    0x8(%eax),%edx
  800a8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a91:	8b 50 04             	mov    0x4(%eax),%edx
  800a94:	8b 00                	mov    (%eax),%eax
  800a96:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800a99:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800a9c:	eb 32                	jmp    800ad0 <vprintfmt+0x2d1>
	else if (lflag)
  800a9e:	85 d2                	test   %edx,%edx
  800aa0:	74 18                	je     800aba <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8d 50 04             	lea    0x4(%eax),%edx
  800aa8:	89 55 14             	mov    %edx,0x14(%ebp)
  800aab:	8b 00                	mov    (%eax),%eax
  800aad:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800ab0:	89 c1                	mov    %eax,%ecx
  800ab2:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800ab8:	eb 16                	jmp    800ad0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800aba:	8b 45 14             	mov    0x14(%ebp),%eax
  800abd:	8d 50 04             	lea    0x4(%eax),%edx
  800ac0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac3:	8b 00                	mov    (%eax),%eax
  800ac5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800ac8:	89 c1                	mov    %eax,%ecx
  800aca:	c1 f9 1f             	sar    $0x1f,%ecx
  800acd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800ad3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ad6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ad9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800adc:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ae5:	0f 89 b0 00 00 00    	jns    800b9b <vprintfmt+0x39c>
				putch('-', putdat);
  800aeb:	83 ec 08             	sub    $0x8,%esp
  800aee:	53                   	push   %ebx
  800aef:	6a 2d                	push   $0x2d
  800af1:	ff d6                	call   *%esi
				num = -(long long) num;
  800af3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800af6:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800af9:	f7 d8                	neg    %eax
  800afb:	83 d2 00             	adc    $0x0,%edx
  800afe:	f7 da                	neg    %edx
  800b00:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b03:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b06:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0e:	e9 88 00 00 00       	jmp    800b9b <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b13:	8d 45 14             	lea    0x14(%ebp),%eax
  800b16:	e8 70 fc ff ff       	call   80078b <getuint>
  800b1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b21:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b26:	eb 73                	jmp    800b9b <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800b28:	8d 45 14             	lea    0x14(%ebp),%eax
  800b2b:	e8 5b fc ff ff       	call   80078b <getuint>
  800b30:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b33:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	53                   	push   %ebx
  800b3a:	6a 58                	push   $0x58
  800b3c:	ff d6                	call   *%esi
			putch('X', putdat);
  800b3e:	83 c4 08             	add    $0x8,%esp
  800b41:	53                   	push   %ebx
  800b42:	6a 58                	push   $0x58
  800b44:	ff d6                	call   *%esi
			putch('X', putdat);
  800b46:	83 c4 08             	add    $0x8,%esp
  800b49:	53                   	push   %ebx
  800b4a:	6a 58                	push   $0x58
  800b4c:	ff d6                	call   *%esi
			goto number;
  800b4e:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800b51:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800b56:	eb 43                	jmp    800b9b <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	53                   	push   %ebx
  800b5c:	6a 30                	push   $0x30
  800b5e:	ff d6                	call   *%esi
			putch('x', putdat);
  800b60:	83 c4 08             	add    $0x8,%esp
  800b63:	53                   	push   %ebx
  800b64:	6a 78                	push   $0x78
  800b66:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b68:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6b:	8d 50 04             	lea    0x4(%eax),%edx
  800b6e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b71:	8b 00                	mov    (%eax),%eax
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b7b:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b7e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b81:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b86:	eb 13                	jmp    800b9b <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b88:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8b:	e8 fb fb ff ff       	call   80078b <getuint>
  800b90:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b93:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800b96:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800ba2:	52                   	push   %edx
  800ba3:	ff 75 e0             	pushl  -0x20(%ebp)
  800ba6:	50                   	push   %eax
  800ba7:	ff 75 dc             	pushl  -0x24(%ebp)
  800baa:	ff 75 d8             	pushl  -0x28(%ebp)
  800bad:	89 da                	mov    %ebx,%edx
  800baf:	89 f0                	mov    %esi,%eax
  800bb1:	e8 26 fb ff ff       	call   8006dc <printnum>
			break;
  800bb6:	83 c4 20             	add    $0x20,%esp
  800bb9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bbc:	e9 64 fc ff ff       	jmp    800825 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bc1:	83 ec 08             	sub    $0x8,%esp
  800bc4:	53                   	push   %ebx
  800bc5:	51                   	push   %ecx
  800bc6:	ff d6                	call   *%esi
			break;
  800bc8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bcb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bce:	e9 52 fc ff ff       	jmp    800825 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bd3:	83 ec 08             	sub    $0x8,%esp
  800bd6:	53                   	push   %ebx
  800bd7:	6a 25                	push   $0x25
  800bd9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bdb:	83 c4 10             	add    $0x10,%esp
  800bde:	eb 03                	jmp    800be3 <vprintfmt+0x3e4>
  800be0:	83 ef 01             	sub    $0x1,%edi
  800be3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800be7:	75 f7                	jne    800be0 <vprintfmt+0x3e1>
  800be9:	e9 37 fc ff ff       	jmp    800825 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	83 ec 18             	sub    $0x18,%esp
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c05:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c09:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	74 26                	je     800c3d <vsnprintf+0x47>
  800c17:	85 d2                	test   %edx,%edx
  800c19:	7e 22                	jle    800c3d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c1b:	ff 75 14             	pushl  0x14(%ebp)
  800c1e:	ff 75 10             	pushl  0x10(%ebp)
  800c21:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c24:	50                   	push   %eax
  800c25:	68 c5 07 80 00       	push   $0x8007c5
  800c2a:	e8 d0 fb ff ff       	call   8007ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c32:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	eb 05                	jmp    800c42 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c4a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c4d:	50                   	push   %eax
  800c4e:	ff 75 10             	pushl  0x10(%ebp)
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	ff 75 08             	pushl  0x8(%ebp)
  800c57:	e8 9a ff ff ff       	call   800bf6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
  800c69:	eb 03                	jmp    800c6e <strlen+0x10>
		n++;
  800c6b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c6e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c72:	75 f7                	jne    800c6b <strlen+0xd>
		n++;
	return n;
}
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c84:	eb 03                	jmp    800c89 <strnlen+0x13>
		n++;
  800c86:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c89:	39 c2                	cmp    %eax,%edx
  800c8b:	74 08                	je     800c95 <strnlen+0x1f>
  800c8d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c91:	75 f3                	jne    800c86 <strnlen+0x10>
  800c93:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	53                   	push   %ebx
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ca1:	89 c2                	mov    %eax,%edx
  800ca3:	83 c2 01             	add    $0x1,%edx
  800ca6:	83 c1 01             	add    $0x1,%ecx
  800ca9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cad:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cb0:	84 db                	test   %bl,%bl
  800cb2:	75 ef                	jne    800ca3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	53                   	push   %ebx
  800cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cbe:	53                   	push   %ebx
  800cbf:	e8 9a ff ff ff       	call   800c5e <strlen>
  800cc4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800cc7:	ff 75 0c             	pushl  0xc(%ebp)
  800cca:	01 d8                	add    %ebx,%eax
  800ccc:	50                   	push   %eax
  800ccd:	e8 c5 ff ff ff       	call   800c97 <strcpy>
	return dst;
}
  800cd2:	89 d8                	mov    %ebx,%eax
  800cd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	89 f3                	mov    %esi,%ebx
  800ce6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce9:	89 f2                	mov    %esi,%edx
  800ceb:	eb 0f                	jmp    800cfc <strncpy+0x23>
		*dst++ = *src;
  800ced:	83 c2 01             	add    $0x1,%edx
  800cf0:	0f b6 01             	movzbl (%ecx),%eax
  800cf3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cf6:	80 39 01             	cmpb   $0x1,(%ecx)
  800cf9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cfc:	39 da                	cmp    %ebx,%edx
  800cfe:	75 ed                	jne    800ced <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d00:	89 f0                	mov    %esi,%eax
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 10             	mov    0x10(%ebp),%edx
  800d14:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d16:	85 d2                	test   %edx,%edx
  800d18:	74 21                	je     800d3b <strlcpy+0x35>
  800d1a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d1e:	89 f2                	mov    %esi,%edx
  800d20:	eb 09                	jmp    800d2b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d22:	83 c2 01             	add    $0x1,%edx
  800d25:	83 c1 01             	add    $0x1,%ecx
  800d28:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d2b:	39 c2                	cmp    %eax,%edx
  800d2d:	74 09                	je     800d38 <strlcpy+0x32>
  800d2f:	0f b6 19             	movzbl (%ecx),%ebx
  800d32:	84 db                	test   %bl,%bl
  800d34:	75 ec                	jne    800d22 <strlcpy+0x1c>
  800d36:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d38:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d3b:	29 f0                	sub    %esi,%eax
}
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d47:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d4a:	eb 06                	jmp    800d52 <strcmp+0x11>
		p++, q++;
  800d4c:	83 c1 01             	add    $0x1,%ecx
  800d4f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d52:	0f b6 01             	movzbl (%ecx),%eax
  800d55:	84 c0                	test   %al,%al
  800d57:	74 04                	je     800d5d <strcmp+0x1c>
  800d59:	3a 02                	cmp    (%edx),%al
  800d5b:	74 ef                	je     800d4c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d5d:	0f b6 c0             	movzbl %al,%eax
  800d60:	0f b6 12             	movzbl (%edx),%edx
  800d63:	29 d0                	sub    %edx,%eax
}
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	53                   	push   %ebx
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d76:	eb 06                	jmp    800d7e <strncmp+0x17>
		n--, p++, q++;
  800d78:	83 c0 01             	add    $0x1,%eax
  800d7b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d7e:	39 d8                	cmp    %ebx,%eax
  800d80:	74 15                	je     800d97 <strncmp+0x30>
  800d82:	0f b6 08             	movzbl (%eax),%ecx
  800d85:	84 c9                	test   %cl,%cl
  800d87:	74 04                	je     800d8d <strncmp+0x26>
  800d89:	3a 0a                	cmp    (%edx),%cl
  800d8b:	74 eb                	je     800d78 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d8d:	0f b6 00             	movzbl (%eax),%eax
  800d90:	0f b6 12             	movzbl (%edx),%edx
  800d93:	29 d0                	sub    %edx,%eax
  800d95:	eb 05                	jmp    800d9c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d97:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800da9:	eb 07                	jmp    800db2 <strchr+0x13>
		if (*s == c)
  800dab:	38 ca                	cmp    %cl,%dl
  800dad:	74 0f                	je     800dbe <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800daf:	83 c0 01             	add    $0x1,%eax
  800db2:	0f b6 10             	movzbl (%eax),%edx
  800db5:	84 d2                	test   %dl,%dl
  800db7:	75 f2                	jne    800dab <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dca:	eb 03                	jmp    800dcf <strfind+0xf>
  800dcc:	83 c0 01             	add    $0x1,%eax
  800dcf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800dd2:	38 ca                	cmp    %cl,%dl
  800dd4:	74 04                	je     800dda <strfind+0x1a>
  800dd6:	84 d2                	test   %dl,%dl
  800dd8:	75 f2                	jne    800dcc <strfind+0xc>
			break;
	return (char *) s;
}
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800de5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800de8:	85 c9                	test   %ecx,%ecx
  800dea:	74 36                	je     800e22 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800df2:	75 28                	jne    800e1c <memset+0x40>
  800df4:	f6 c1 03             	test   $0x3,%cl
  800df7:	75 23                	jne    800e1c <memset+0x40>
		c &= 0xFF;
  800df9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	c1 e3 08             	shl    $0x8,%ebx
  800e02:	89 d6                	mov    %edx,%esi
  800e04:	c1 e6 18             	shl    $0x18,%esi
  800e07:	89 d0                	mov    %edx,%eax
  800e09:	c1 e0 10             	shl    $0x10,%eax
  800e0c:	09 f0                	or     %esi,%eax
  800e0e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	09 d0                	or     %edx,%eax
  800e14:	c1 e9 02             	shr    $0x2,%ecx
  800e17:	fc                   	cld    
  800e18:	f3 ab                	rep stos %eax,%es:(%edi)
  800e1a:	eb 06                	jmp    800e22 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1f:	fc                   	cld    
  800e20:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e22:	89 f8                	mov    %edi,%eax
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e37:	39 c6                	cmp    %eax,%esi
  800e39:	73 35                	jae    800e70 <memmove+0x47>
  800e3b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e3e:	39 d0                	cmp    %edx,%eax
  800e40:	73 2e                	jae    800e70 <memmove+0x47>
		s += n;
		d += n;
  800e42:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e45:	89 d6                	mov    %edx,%esi
  800e47:	09 fe                	or     %edi,%esi
  800e49:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e4f:	75 13                	jne    800e64 <memmove+0x3b>
  800e51:	f6 c1 03             	test   $0x3,%cl
  800e54:	75 0e                	jne    800e64 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e56:	83 ef 04             	sub    $0x4,%edi
  800e59:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e5c:	c1 e9 02             	shr    $0x2,%ecx
  800e5f:	fd                   	std    
  800e60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e62:	eb 09                	jmp    800e6d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e64:	83 ef 01             	sub    $0x1,%edi
  800e67:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e6a:	fd                   	std    
  800e6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e6d:	fc                   	cld    
  800e6e:	eb 1d                	jmp    800e8d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e70:	89 f2                	mov    %esi,%edx
  800e72:	09 c2                	or     %eax,%edx
  800e74:	f6 c2 03             	test   $0x3,%dl
  800e77:	75 0f                	jne    800e88 <memmove+0x5f>
  800e79:	f6 c1 03             	test   $0x3,%cl
  800e7c:	75 0a                	jne    800e88 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e7e:	c1 e9 02             	shr    $0x2,%ecx
  800e81:	89 c7                	mov    %eax,%edi
  800e83:	fc                   	cld    
  800e84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e86:	eb 05                	jmp    800e8d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e88:	89 c7                	mov    %eax,%edi
  800e8a:	fc                   	cld    
  800e8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e94:	ff 75 10             	pushl  0x10(%ebp)
  800e97:	ff 75 0c             	pushl  0xc(%ebp)
  800e9a:	ff 75 08             	pushl  0x8(%ebp)
  800e9d:	e8 87 ff ff ff       	call   800e29 <memmove>
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eaf:	89 c6                	mov    %eax,%esi
  800eb1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eb4:	eb 1a                	jmp    800ed0 <memcmp+0x2c>
		if (*s1 != *s2)
  800eb6:	0f b6 08             	movzbl (%eax),%ecx
  800eb9:	0f b6 1a             	movzbl (%edx),%ebx
  800ebc:	38 d9                	cmp    %bl,%cl
  800ebe:	74 0a                	je     800eca <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ec0:	0f b6 c1             	movzbl %cl,%eax
  800ec3:	0f b6 db             	movzbl %bl,%ebx
  800ec6:	29 d8                	sub    %ebx,%eax
  800ec8:	eb 0f                	jmp    800ed9 <memcmp+0x35>
		s1++, s2++;
  800eca:	83 c0 01             	add    $0x1,%eax
  800ecd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ed0:	39 f0                	cmp    %esi,%eax
  800ed2:	75 e2                	jne    800eb6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	53                   	push   %ebx
  800ee1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ee4:	89 c1                	mov    %eax,%ecx
  800ee6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eed:	eb 0a                	jmp    800ef9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eef:	0f b6 10             	movzbl (%eax),%edx
  800ef2:	39 da                	cmp    %ebx,%edx
  800ef4:	74 07                	je     800efd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ef6:	83 c0 01             	add    $0x1,%eax
  800ef9:	39 c8                	cmp    %ecx,%eax
  800efb:	72 f2                	jb     800eef <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800efd:	5b                   	pop    %ebx
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f0c:	eb 03                	jmp    800f11 <strtol+0x11>
		s++;
  800f0e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f11:	0f b6 01             	movzbl (%ecx),%eax
  800f14:	3c 20                	cmp    $0x20,%al
  800f16:	74 f6                	je     800f0e <strtol+0xe>
  800f18:	3c 09                	cmp    $0x9,%al
  800f1a:	74 f2                	je     800f0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f1c:	3c 2b                	cmp    $0x2b,%al
  800f1e:	75 0a                	jne    800f2a <strtol+0x2a>
		s++;
  800f20:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f23:	bf 00 00 00 00       	mov    $0x0,%edi
  800f28:	eb 11                	jmp    800f3b <strtol+0x3b>
  800f2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f2f:	3c 2d                	cmp    $0x2d,%al
  800f31:	75 08                	jne    800f3b <strtol+0x3b>
		s++, neg = 1;
  800f33:	83 c1 01             	add    $0x1,%ecx
  800f36:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f41:	75 15                	jne    800f58 <strtol+0x58>
  800f43:	80 39 30             	cmpb   $0x30,(%ecx)
  800f46:	75 10                	jne    800f58 <strtol+0x58>
  800f48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f4c:	75 7c                	jne    800fca <strtol+0xca>
		s += 2, base = 16;
  800f4e:	83 c1 02             	add    $0x2,%ecx
  800f51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f56:	eb 16                	jmp    800f6e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f58:	85 db                	test   %ebx,%ebx
  800f5a:	75 12                	jne    800f6e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f61:	80 39 30             	cmpb   $0x30,(%ecx)
  800f64:	75 08                	jne    800f6e <strtol+0x6e>
		s++, base = 8;
  800f66:	83 c1 01             	add    $0x1,%ecx
  800f69:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f73:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f76:	0f b6 11             	movzbl (%ecx),%edx
  800f79:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f7c:	89 f3                	mov    %esi,%ebx
  800f7e:	80 fb 09             	cmp    $0x9,%bl
  800f81:	77 08                	ja     800f8b <strtol+0x8b>
			dig = *s - '0';
  800f83:	0f be d2             	movsbl %dl,%edx
  800f86:	83 ea 30             	sub    $0x30,%edx
  800f89:	eb 22                	jmp    800fad <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f8e:	89 f3                	mov    %esi,%ebx
  800f90:	80 fb 19             	cmp    $0x19,%bl
  800f93:	77 08                	ja     800f9d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f95:	0f be d2             	movsbl %dl,%edx
  800f98:	83 ea 57             	sub    $0x57,%edx
  800f9b:	eb 10                	jmp    800fad <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f9d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fa0:	89 f3                	mov    %esi,%ebx
  800fa2:	80 fb 19             	cmp    $0x19,%bl
  800fa5:	77 16                	ja     800fbd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800fa7:	0f be d2             	movsbl %dl,%edx
  800faa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fb0:	7d 0b                	jge    800fbd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fb2:	83 c1 01             	add    $0x1,%ecx
  800fb5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fb9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800fbb:	eb b9                	jmp    800f76 <strtol+0x76>

	if (endptr)
  800fbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fc1:	74 0d                	je     800fd0 <strtol+0xd0>
		*endptr = (char *) s;
  800fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc6:	89 0e                	mov    %ecx,(%esi)
  800fc8:	eb 06                	jmp    800fd0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fca:	85 db                	test   %ebx,%ebx
  800fcc:	74 98                	je     800f66 <strtol+0x66>
  800fce:	eb 9e                	jmp    800f6e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fd0:	89 c2                	mov    %eax,%edx
  800fd2:	f7 da                	neg    %edx
  800fd4:	85 ff                	test   %edi,%edi
  800fd6:	0f 45 c2             	cmovne %edx,%eax
}
  800fd9:	5b                   	pop    %ebx
  800fda:	5e                   	pop    %esi
  800fdb:	5f                   	pop    %edi
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	89 c3                	mov    %eax,%ebx
  800ff1:	89 c7                	mov    %eax,%edi
  800ff3:	89 c6                	mov    %eax,%esi
  800ff5:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_cgetc>:

int
sys_cgetc(void)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801002:	ba 00 00 00 00       	mov    $0x0,%edx
  801007:	b8 01 00 00 00       	mov    $0x1,%eax
  80100c:	89 d1                	mov    %edx,%ecx
  80100e:	89 d3                	mov    %edx,%ebx
  801010:	89 d7                	mov    %edx,%edi
  801012:	89 d6                	mov    %edx,%esi
  801014:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801024:	b9 00 00 00 00       	mov    $0x0,%ecx
  801029:	b8 03 00 00 00       	mov    $0x3,%eax
  80102e:	8b 55 08             	mov    0x8(%ebp),%edx
  801031:	89 cb                	mov    %ecx,%ebx
  801033:	89 cf                	mov    %ecx,%edi
  801035:	89 ce                	mov    %ecx,%esi
  801037:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801039:	85 c0                	test   %eax,%eax
  80103b:	7e 17                	jle    801054 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	50                   	push   %eax
  801041:	6a 03                	push   $0x3
  801043:	68 64 19 80 00       	push   $0x801964
  801048:	6a 23                	push   $0x23
  80104a:	68 81 19 80 00       	push   $0x801981
  80104f:	e8 9b f5 ff ff       	call   8005ef <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	57                   	push   %edi
  801060:	56                   	push   %esi
  801061:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801062:	ba 00 00 00 00       	mov    $0x0,%edx
  801067:	b8 02 00 00 00       	mov    $0x2,%eax
  80106c:	89 d1                	mov    %edx,%ecx
  80106e:	89 d3                	mov    %edx,%ebx
  801070:	89 d7                	mov    %edx,%edi
  801072:	89 d6                	mov    %edx,%esi
  801074:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <sys_yield>:

void
sys_yield(void)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801081:	ba 00 00 00 00       	mov    $0x0,%edx
  801086:	b8 0a 00 00 00       	mov    $0xa,%eax
  80108b:	89 d1                	mov    %edx,%ecx
  80108d:	89 d3                	mov    %edx,%ebx
  80108f:	89 d7                	mov    %edx,%edi
  801091:	89 d6                	mov    %edx,%esi
  801093:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801095:	5b                   	pop    %ebx
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8010a3:	be 00 00 00 00       	mov    $0x0,%esi
  8010a8:	b8 04 00 00 00       	mov    $0x4,%eax
  8010ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b6:	89 f7                	mov    %esi,%edi
  8010b8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	7e 17                	jle    8010d5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	50                   	push   %eax
  8010c2:	6a 04                	push   $0x4
  8010c4:	68 64 19 80 00       	push   $0x801964
  8010c9:	6a 23                	push   $0x23
  8010cb:	68 81 19 80 00       	push   $0x801981
  8010d0:	e8 1a f5 ff ff       	call   8005ef <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8010e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f7:	8b 75 18             	mov    0x18(%ebp),%esi
  8010fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	7e 17                	jle    801117 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	50                   	push   %eax
  801104:	6a 05                	push   $0x5
  801106:	68 64 19 80 00       	push   $0x801964
  80110b:	6a 23                	push   $0x23
  80110d:	68 81 19 80 00       	push   $0x801981
  801112:	e8 d8 f4 ff ff       	call   8005ef <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111a:	5b                   	pop    %ebx
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112d:	b8 06 00 00 00       	mov    $0x6,%eax
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	8b 55 08             	mov    0x8(%ebp),%edx
  801138:	89 df                	mov    %ebx,%edi
  80113a:	89 de                	mov    %ebx,%esi
  80113c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	7e 17                	jle    801159 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	50                   	push   %eax
  801146:	6a 06                	push   $0x6
  801148:	68 64 19 80 00       	push   $0x801964
  80114d:	6a 23                	push   $0x23
  80114f:	68 81 19 80 00       	push   $0x801981
  801154:	e8 96 f4 ff ff       	call   8005ef <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	57                   	push   %edi
  801165:	56                   	push   %esi
  801166:	53                   	push   %ebx
  801167:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80116a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116f:	b8 08 00 00 00       	mov    $0x8,%eax
  801174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801177:	8b 55 08             	mov    0x8(%ebp),%edx
  80117a:	89 df                	mov    %ebx,%edi
  80117c:	89 de                	mov    %ebx,%esi
  80117e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801180:	85 c0                	test   %eax,%eax
  801182:	7e 17                	jle    80119b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	50                   	push   %eax
  801188:	6a 08                	push   $0x8
  80118a:	68 64 19 80 00       	push   $0x801964
  80118f:	6a 23                	push   $0x23
  801191:	68 81 19 80 00       	push   $0x801981
  801196:	e8 54 f4 ff ff       	call   8005ef <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80119b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	b8 09 00 00 00       	mov    $0x9,%eax
  8011b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bc:	89 df                	mov    %ebx,%edi
  8011be:	89 de                	mov    %ebx,%esi
  8011c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	7e 17                	jle    8011dd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	50                   	push   %eax
  8011ca:	6a 09                	push   $0x9
  8011cc:	68 64 19 80 00       	push   $0x801964
  8011d1:	6a 23                	push   $0x23
  8011d3:	68 81 19 80 00       	push   $0x801981
  8011d8:	e8 12 f4 ff ff       	call   8005ef <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8011eb:	be 00 00 00 00       	mov    $0x0,%esi
  8011f0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801201:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  801211:	b9 00 00 00 00       	mov    $0x0,%ecx
  801216:	b8 0c 00 00 00       	mov    $0xc,%eax
  80121b:	8b 55 08             	mov    0x8(%ebp),%edx
  80121e:	89 cb                	mov    %ecx,%ebx
  801220:	89 cf                	mov    %ecx,%edi
  801222:	89 ce                	mov    %ecx,%esi
  801224:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801226:	85 c0                	test   %eax,%eax
  801228:	7e 17                	jle    801241 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	50                   	push   %eax
  80122e:	6a 0c                	push   $0xc
  801230:	68 64 19 80 00       	push   $0x801964
  801235:	6a 23                	push   $0x23
  801237:	68 81 19 80 00       	push   $0x801981
  80123c:	e8 ae f3 ff ff       	call   8005ef <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  80124f:	68 90 19 80 00       	push   $0x801990
  801254:	e8 6f f4 ff ff       	call   8006c8 <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801263:	0f 85 8d 00 00 00    	jne    8012f6 <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  801269:	83 ec 0c             	sub    $0xc,%esp
  80126c:	68 b0 19 80 00       	push   $0x8019b0
  801271:	e8 52 f4 ff ff       	call   8006c8 <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801276:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  80127b:	8b 40 48             	mov    0x48(%eax),%eax
  80127e:	83 c4 0c             	add    $0xc,%esp
  801281:	6a 07                	push   $0x7
  801283:	68 00 f0 bf ee       	push   $0xeebff000
  801288:	50                   	push   %eax
  801289:	e8 0c fe ff ff       	call   80109a <sys_page_alloc>
		if(retv != 0){
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	74 14                	je     8012a9 <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	68 d4 19 80 00       	push   $0x8019d4
  80129d:	6a 27                	push   $0x27
  80129f:	68 28 1a 80 00       	push   $0x801a28
  8012a4:	e8 46 f3 ff ff       	call   8005ef <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	68 10 13 80 00       	push   $0x801310
  8012b1:	68 36 1a 80 00       	push   $0x801a36
  8012b6:	e8 0d f4 ff ff       	call   8006c8 <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  8012bb:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  8012c0:	8b 40 48             	mov    0x48(%eax),%eax
  8012c3:	83 c4 08             	add    $0x8,%esp
  8012c6:	50                   	push   %eax
  8012c7:	68 51 1a 80 00       	push   $0x801a51
  8012cc:	e8 f7 f3 ff ff       	call   8006c8 <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8012d1:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  8012d6:	8b 40 48             	mov    0x48(%eax),%eax
  8012d9:	83 c4 08             	add    $0x8,%esp
  8012dc:	68 10 13 80 00       	push   $0x801310
  8012e1:	50                   	push   %eax
  8012e2:	e8 bc fe ff ff       	call   8011a3 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  8012e7:	c7 04 24 68 1a 80 00 	movl   $0x801a68,(%esp)
  8012ee:	e8 d5 f3 ff ff       	call   8006c8 <cprintf>
  8012f3:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  8012f6:	83 ec 0c             	sub    $0xc,%esp
  8012f9:	68 00 1a 80 00       	push   $0x801a00
  8012fe:	e8 c5 f3 ff ff       	call   8006c8 <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	a3 d0 20 80 00       	mov    %eax,0x8020d0

}
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	c9                   	leave  
  80130f:	c3                   	ret    

00801310 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801310:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801311:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801316:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801318:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  80131b:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  80131d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  801321:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801325:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  801326:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  801328:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  80132f:	00 
	popl %eax
  801330:	58                   	pop    %eax
	popl %eax
  801331:	58                   	pop    %eax
	popal
  801332:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  801333:	83 c4 04             	add    $0x4,%esp
	popfl
  801336:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801337:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801338:	c3                   	ret    
  801339:	66 90                	xchg   %ax,%ax
  80133b:	66 90                	xchg   %ax,%ax
  80133d:	66 90                	xchg   %ax,%ax
  80133f:	90                   	nop

00801340 <__udivdi3>:
  801340:	55                   	push   %ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 1c             	sub    $0x1c,%esp
  801347:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80134b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80134f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801357:	85 f6                	test   %esi,%esi
  801359:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80135d:	89 ca                	mov    %ecx,%edx
  80135f:	89 f8                	mov    %edi,%eax
  801361:	75 3d                	jne    8013a0 <__udivdi3+0x60>
  801363:	39 cf                	cmp    %ecx,%edi
  801365:	0f 87 c5 00 00 00    	ja     801430 <__udivdi3+0xf0>
  80136b:	85 ff                	test   %edi,%edi
  80136d:	89 fd                	mov    %edi,%ebp
  80136f:	75 0b                	jne    80137c <__udivdi3+0x3c>
  801371:	b8 01 00 00 00       	mov    $0x1,%eax
  801376:	31 d2                	xor    %edx,%edx
  801378:	f7 f7                	div    %edi
  80137a:	89 c5                	mov    %eax,%ebp
  80137c:	89 c8                	mov    %ecx,%eax
  80137e:	31 d2                	xor    %edx,%edx
  801380:	f7 f5                	div    %ebp
  801382:	89 c1                	mov    %eax,%ecx
  801384:	89 d8                	mov    %ebx,%eax
  801386:	89 cf                	mov    %ecx,%edi
  801388:	f7 f5                	div    %ebp
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	89 d8                	mov    %ebx,%eax
  80138e:	89 fa                	mov    %edi,%edx
  801390:	83 c4 1c             	add    $0x1c,%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    
  801398:	90                   	nop
  801399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	39 ce                	cmp    %ecx,%esi
  8013a2:	77 74                	ja     801418 <__udivdi3+0xd8>
  8013a4:	0f bd fe             	bsr    %esi,%edi
  8013a7:	83 f7 1f             	xor    $0x1f,%edi
  8013aa:	0f 84 98 00 00 00    	je     801448 <__udivdi3+0x108>
  8013b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8013b5:	89 f9                	mov    %edi,%ecx
  8013b7:	89 c5                	mov    %eax,%ebp
  8013b9:	29 fb                	sub    %edi,%ebx
  8013bb:	d3 e6                	shl    %cl,%esi
  8013bd:	89 d9                	mov    %ebx,%ecx
  8013bf:	d3 ed                	shr    %cl,%ebp
  8013c1:	89 f9                	mov    %edi,%ecx
  8013c3:	d3 e0                	shl    %cl,%eax
  8013c5:	09 ee                	or     %ebp,%esi
  8013c7:	89 d9                	mov    %ebx,%ecx
  8013c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013cd:	89 d5                	mov    %edx,%ebp
  8013cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013d3:	d3 ed                	shr    %cl,%ebp
  8013d5:	89 f9                	mov    %edi,%ecx
  8013d7:	d3 e2                	shl    %cl,%edx
  8013d9:	89 d9                	mov    %ebx,%ecx
  8013db:	d3 e8                	shr    %cl,%eax
  8013dd:	09 c2                	or     %eax,%edx
  8013df:	89 d0                	mov    %edx,%eax
  8013e1:	89 ea                	mov    %ebp,%edx
  8013e3:	f7 f6                	div    %esi
  8013e5:	89 d5                	mov    %edx,%ebp
  8013e7:	89 c3                	mov    %eax,%ebx
  8013e9:	f7 64 24 0c          	mull   0xc(%esp)
  8013ed:	39 d5                	cmp    %edx,%ebp
  8013ef:	72 10                	jb     801401 <__udivdi3+0xc1>
  8013f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8013f5:	89 f9                	mov    %edi,%ecx
  8013f7:	d3 e6                	shl    %cl,%esi
  8013f9:	39 c6                	cmp    %eax,%esi
  8013fb:	73 07                	jae    801404 <__udivdi3+0xc4>
  8013fd:	39 d5                	cmp    %edx,%ebp
  8013ff:	75 03                	jne    801404 <__udivdi3+0xc4>
  801401:	83 eb 01             	sub    $0x1,%ebx
  801404:	31 ff                	xor    %edi,%edi
  801406:	89 d8                	mov    %ebx,%eax
  801408:	89 fa                	mov    %edi,%edx
  80140a:	83 c4 1c             	add    $0x1c,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	31 ff                	xor    %edi,%edi
  80141a:	31 db                	xor    %ebx,%ebx
  80141c:	89 d8                	mov    %ebx,%eax
  80141e:	89 fa                	mov    %edi,%edx
  801420:	83 c4 1c             	add    $0x1c,%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5f                   	pop    %edi
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    
  801428:	90                   	nop
  801429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801430:	89 d8                	mov    %ebx,%eax
  801432:	f7 f7                	div    %edi
  801434:	31 ff                	xor    %edi,%edi
  801436:	89 c3                	mov    %eax,%ebx
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	89 fa                	mov    %edi,%edx
  80143c:	83 c4 1c             	add    $0x1c,%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	39 ce                	cmp    %ecx,%esi
  80144a:	72 0c                	jb     801458 <__udivdi3+0x118>
  80144c:	31 db                	xor    %ebx,%ebx
  80144e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801452:	0f 87 34 ff ff ff    	ja     80138c <__udivdi3+0x4c>
  801458:	bb 01 00 00 00       	mov    $0x1,%ebx
  80145d:	e9 2a ff ff ff       	jmp    80138c <__udivdi3+0x4c>
  801462:	66 90                	xchg   %ax,%ax
  801464:	66 90                	xchg   %ax,%ax
  801466:	66 90                	xchg   %ax,%ax
  801468:	66 90                	xchg   %ax,%ax
  80146a:	66 90                	xchg   %ax,%ax
  80146c:	66 90                	xchg   %ax,%ax
  80146e:	66 90                	xchg   %ax,%ax

00801470 <__umoddi3>:
  801470:	55                   	push   %ebp
  801471:	57                   	push   %edi
  801472:	56                   	push   %esi
  801473:	53                   	push   %ebx
  801474:	83 ec 1c             	sub    $0x1c,%esp
  801477:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80147b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80147f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801487:	85 d2                	test   %edx,%edx
  801489:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80148d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801491:	89 f3                	mov    %esi,%ebx
  801493:	89 3c 24             	mov    %edi,(%esp)
  801496:	89 74 24 04          	mov    %esi,0x4(%esp)
  80149a:	75 1c                	jne    8014b8 <__umoddi3+0x48>
  80149c:	39 f7                	cmp    %esi,%edi
  80149e:	76 50                	jbe    8014f0 <__umoddi3+0x80>
  8014a0:	89 c8                	mov    %ecx,%eax
  8014a2:	89 f2                	mov    %esi,%edx
  8014a4:	f7 f7                	div    %edi
  8014a6:	89 d0                	mov    %edx,%eax
  8014a8:	31 d2                	xor    %edx,%edx
  8014aa:	83 c4 1c             	add    $0x1c,%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5f                   	pop    %edi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    
  8014b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014b8:	39 f2                	cmp    %esi,%edx
  8014ba:	89 d0                	mov    %edx,%eax
  8014bc:	77 52                	ja     801510 <__umoddi3+0xa0>
  8014be:	0f bd ea             	bsr    %edx,%ebp
  8014c1:	83 f5 1f             	xor    $0x1f,%ebp
  8014c4:	75 5a                	jne    801520 <__umoddi3+0xb0>
  8014c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8014ca:	0f 82 e0 00 00 00    	jb     8015b0 <__umoddi3+0x140>
  8014d0:	39 0c 24             	cmp    %ecx,(%esp)
  8014d3:	0f 86 d7 00 00 00    	jbe    8015b0 <__umoddi3+0x140>
  8014d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014e1:	83 c4 1c             	add    $0x1c,%esp
  8014e4:	5b                   	pop    %ebx
  8014e5:	5e                   	pop    %esi
  8014e6:	5f                   	pop    %edi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    
  8014e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014f0:	85 ff                	test   %edi,%edi
  8014f2:	89 fd                	mov    %edi,%ebp
  8014f4:	75 0b                	jne    801501 <__umoddi3+0x91>
  8014f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fb:	31 d2                	xor    %edx,%edx
  8014fd:	f7 f7                	div    %edi
  8014ff:	89 c5                	mov    %eax,%ebp
  801501:	89 f0                	mov    %esi,%eax
  801503:	31 d2                	xor    %edx,%edx
  801505:	f7 f5                	div    %ebp
  801507:	89 c8                	mov    %ecx,%eax
  801509:	f7 f5                	div    %ebp
  80150b:	89 d0                	mov    %edx,%eax
  80150d:	eb 99                	jmp    8014a8 <__umoddi3+0x38>
  80150f:	90                   	nop
  801510:	89 c8                	mov    %ecx,%eax
  801512:	89 f2                	mov    %esi,%edx
  801514:	83 c4 1c             	add    $0x1c,%esp
  801517:	5b                   	pop    %ebx
  801518:	5e                   	pop    %esi
  801519:	5f                   	pop    %edi
  80151a:	5d                   	pop    %ebp
  80151b:	c3                   	ret    
  80151c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801520:	8b 34 24             	mov    (%esp),%esi
  801523:	bf 20 00 00 00       	mov    $0x20,%edi
  801528:	89 e9                	mov    %ebp,%ecx
  80152a:	29 ef                	sub    %ebp,%edi
  80152c:	d3 e0                	shl    %cl,%eax
  80152e:	89 f9                	mov    %edi,%ecx
  801530:	89 f2                	mov    %esi,%edx
  801532:	d3 ea                	shr    %cl,%edx
  801534:	89 e9                	mov    %ebp,%ecx
  801536:	09 c2                	or     %eax,%edx
  801538:	89 d8                	mov    %ebx,%eax
  80153a:	89 14 24             	mov    %edx,(%esp)
  80153d:	89 f2                	mov    %esi,%edx
  80153f:	d3 e2                	shl    %cl,%edx
  801541:	89 f9                	mov    %edi,%ecx
  801543:	89 54 24 04          	mov    %edx,0x4(%esp)
  801547:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80154b:	d3 e8                	shr    %cl,%eax
  80154d:	89 e9                	mov    %ebp,%ecx
  80154f:	89 c6                	mov    %eax,%esi
  801551:	d3 e3                	shl    %cl,%ebx
  801553:	89 f9                	mov    %edi,%ecx
  801555:	89 d0                	mov    %edx,%eax
  801557:	d3 e8                	shr    %cl,%eax
  801559:	89 e9                	mov    %ebp,%ecx
  80155b:	09 d8                	or     %ebx,%eax
  80155d:	89 d3                	mov    %edx,%ebx
  80155f:	89 f2                	mov    %esi,%edx
  801561:	f7 34 24             	divl   (%esp)
  801564:	89 d6                	mov    %edx,%esi
  801566:	d3 e3                	shl    %cl,%ebx
  801568:	f7 64 24 04          	mull   0x4(%esp)
  80156c:	39 d6                	cmp    %edx,%esi
  80156e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801572:	89 d1                	mov    %edx,%ecx
  801574:	89 c3                	mov    %eax,%ebx
  801576:	72 08                	jb     801580 <__umoddi3+0x110>
  801578:	75 11                	jne    80158b <__umoddi3+0x11b>
  80157a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80157e:	73 0b                	jae    80158b <__umoddi3+0x11b>
  801580:	2b 44 24 04          	sub    0x4(%esp),%eax
  801584:	1b 14 24             	sbb    (%esp),%edx
  801587:	89 d1                	mov    %edx,%ecx
  801589:	89 c3                	mov    %eax,%ebx
  80158b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80158f:	29 da                	sub    %ebx,%edx
  801591:	19 ce                	sbb    %ecx,%esi
  801593:	89 f9                	mov    %edi,%ecx
  801595:	89 f0                	mov    %esi,%eax
  801597:	d3 e0                	shl    %cl,%eax
  801599:	89 e9                	mov    %ebp,%ecx
  80159b:	d3 ea                	shr    %cl,%edx
  80159d:	89 e9                	mov    %ebp,%ecx
  80159f:	d3 ee                	shr    %cl,%esi
  8015a1:	09 d0                	or     %edx,%eax
  8015a3:	89 f2                	mov    %esi,%edx
  8015a5:	83 c4 1c             	add    $0x1c,%esp
  8015a8:	5b                   	pop    %ebx
  8015a9:	5e                   	pop    %esi
  8015aa:	5f                   	pop    %edi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    
  8015ad:	8d 76 00             	lea    0x0(%esi),%esi
  8015b0:	29 f9                	sub    %edi,%ecx
  8015b2:	19 d6                	sbb    %edx,%esi
  8015b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bc:	e9 18 ff ff ff       	jmp    8014d9 <__umoddi3+0x69>
