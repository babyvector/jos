
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 ea 0f 80 00       	push   $0x800fea
  800116:	6a 23                	push   $0x23
  800118:	68 07 10 80 00       	push   $0x801007
  80011d:	e8 00 02 00 00       	call   800322 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 ea 0f 80 00       	push   $0x800fea
  800197:	6a 23                	push   $0x23
  800199:	68 07 10 80 00       	push   $0x801007
  80019e:	e8 7f 01 00 00       	call   800322 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 ea 0f 80 00       	push   $0x800fea
  8001d9:	6a 23                	push   $0x23
  8001db:	68 07 10 80 00       	push   $0x801007
  8001e0:	e8 3d 01 00 00       	call   800322 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 ea 0f 80 00       	push   $0x800fea
  80021b:	6a 23                	push   $0x23
  80021d:	68 07 10 80 00       	push   $0x801007
  800222:	e8 fb 00 00 00       	call   800322 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 ea 0f 80 00       	push   $0x800fea
  80025d:	6a 23                	push   $0x23
  80025f:	68 07 10 80 00       	push   $0x801007
  800264:	e8 b9 00 00 00       	call   800322 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 ea 0f 80 00       	push   $0x800fea
  80029f:	6a 23                	push   $0x23
  8002a1:	68 07 10 80 00       	push   $0x801007
  8002a6:	e8 77 00 00 00       	call   800322 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 ea 0f 80 00       	push   $0x800fea
  800303:	6a 23                	push   $0x23
  800305:	68 07 10 80 00       	push   $0x801007
  80030a:	e8 13 00 00 00       	call   800322 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp

00800322 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800327:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800330:	e8 f5 fd ff ff       	call   80012a <sys_getenvid>
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	56                   	push   %esi
  80033f:	50                   	push   %eax
  800340:	68 18 10 80 00       	push   $0x801018
  800345:	e8 b1 00 00 00       	call   8003fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034a:	83 c4 18             	add    $0x18,%esp
  80034d:	53                   	push   %ebx
  80034e:	ff 75 10             	pushl  0x10(%ebp)
  800351:	e8 54 00 00 00       	call   8003aa <vcprintf>
	cprintf("\n");
  800356:	c7 04 24 3b 10 80 00 	movl   $0x80103b,(%esp)
  80035d:	e8 99 00 00 00       	call   8003fb <cprintf>
  800362:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800365:	cc                   	int3   
  800366:	eb fd                	jmp    800365 <_panic+0x43>

00800368 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	53                   	push   %ebx
  80036c:	83 ec 04             	sub    $0x4,%esp
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800372:	8b 13                	mov    (%ebx),%edx
  800374:	8d 42 01             	lea    0x1(%edx),%eax
  800377:	89 03                	mov    %eax,(%ebx)
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800380:	3d ff 00 00 00       	cmp    $0xff,%eax
  800385:	75 1a                	jne    8003a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	68 ff 00 00 00       	push   $0xff
  80038f:	8d 43 08             	lea    0x8(%ebx),%eax
  800392:	50                   	push   %eax
  800393:	e8 14 fd ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800398:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80039e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    

008003aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8003b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ba:	00 00 00 
	b.cnt = 0;
  8003bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ca:	ff 75 08             	pushl  0x8(%ebp)
  8003cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d3:	50                   	push   %eax
  8003d4:	68 68 03 80 00       	push   $0x800368
  8003d9:	e8 54 01 00 00       	call   800532 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003de:	83 c4 08             	add    $0x8,%esp
  8003e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ed:	50                   	push   %eax
  8003ee:	e8 b9 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8003f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    

008003fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800401:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800404:	50                   	push   %eax
  800405:	ff 75 08             	pushl  0x8(%ebp)
  800408:	e8 9d ff ff ff       	call   8003aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80040d:	c9                   	leave  
  80040e:	c3                   	ret    

0080040f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	57                   	push   %edi
  800413:	56                   	push   %esi
  800414:	53                   	push   %ebx
  800415:	83 ec 1c             	sub    $0x1c,%esp
  800418:	89 c7                	mov    %eax,%edi
  80041a:	89 d6                	mov    %edx,%esi
  80041c:	8b 45 08             	mov    0x8(%ebp),%eax
  80041f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800422:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800425:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800428:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800430:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800433:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800436:	39 d3                	cmp    %edx,%ebx
  800438:	72 05                	jb     80043f <printnum+0x30>
  80043a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043d:	77 45                	ja     800484 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80043f:	83 ec 0c             	sub    $0xc,%esp
  800442:	ff 75 18             	pushl  0x18(%ebp)
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044b:	53                   	push   %ebx
  80044c:	ff 75 10             	pushl  0x10(%ebp)
  80044f:	83 ec 08             	sub    $0x8,%esp
  800452:	ff 75 e4             	pushl  -0x1c(%ebp)
  800455:	ff 75 e0             	pushl  -0x20(%ebp)
  800458:	ff 75 dc             	pushl  -0x24(%ebp)
  80045b:	ff 75 d8             	pushl  -0x28(%ebp)
  80045e:	e8 dd 08 00 00       	call   800d40 <__udivdi3>
  800463:	83 c4 18             	add    $0x18,%esp
  800466:	52                   	push   %edx
  800467:	50                   	push   %eax
  800468:	89 f2                	mov    %esi,%edx
  80046a:	89 f8                	mov    %edi,%eax
  80046c:	e8 9e ff ff ff       	call   80040f <printnum>
  800471:	83 c4 20             	add    $0x20,%esp
  800474:	eb 18                	jmp    80048e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	56                   	push   %esi
  80047a:	ff 75 18             	pushl  0x18(%ebp)
  80047d:	ff d7                	call   *%edi
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	eb 03                	jmp    800487 <printnum+0x78>
  800484:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800487:	83 eb 01             	sub    $0x1,%ebx
  80048a:	85 db                	test   %ebx,%ebx
  80048c:	7f e8                	jg     800476 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	56                   	push   %esi
  800492:	83 ec 04             	sub    $0x4,%esp
  800495:	ff 75 e4             	pushl  -0x1c(%ebp)
  800498:	ff 75 e0             	pushl  -0x20(%ebp)
  80049b:	ff 75 dc             	pushl  -0x24(%ebp)
  80049e:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a1:	e8 ca 09 00 00       	call   800e70 <__umoddi3>
  8004a6:	83 c4 14             	add    $0x14,%esp
  8004a9:	0f be 80 3d 10 80 00 	movsbl 0x80103d(%eax),%eax
  8004b0:	50                   	push   %eax
  8004b1:	ff d7                	call   *%edi
}
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c1:	83 fa 01             	cmp    $0x1,%edx
  8004c4:	7e 0e                	jle    8004d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c6:	8b 10                	mov    (%eax),%edx
  8004c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cb:	89 08                	mov    %ecx,(%eax)
  8004cd:	8b 02                	mov    (%edx),%eax
  8004cf:	8b 52 04             	mov    0x4(%edx),%edx
  8004d2:	eb 22                	jmp    8004f6 <getuint+0x38>
	else if (lflag)
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	74 10                	je     8004e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e6:	eb 0e                	jmp    8004f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e8:	8b 10                	mov    (%eax),%edx
  8004ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ed:	89 08                	mov    %ecx,(%eax)
  8004ef:	8b 02                	mov    (%edx),%eax
  8004f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800502:	8b 10                	mov    (%eax),%edx
  800504:	3b 50 04             	cmp    0x4(%eax),%edx
  800507:	73 0a                	jae    800513 <sprintputch+0x1b>
		*b->buf++ = ch;
  800509:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050c:	89 08                	mov    %ecx,(%eax)
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	88 02                	mov    %al,(%edx)
}
  800513:	5d                   	pop    %ebp
  800514:	c3                   	ret    

00800515 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051e:	50                   	push   %eax
  80051f:	ff 75 10             	pushl  0x10(%ebp)
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	ff 75 08             	pushl  0x8(%ebp)
  800528:	e8 05 00 00 00       	call   800532 <vprintfmt>
	va_end(ap);
}
  80052d:	83 c4 10             	add    $0x10,%esp
  800530:	c9                   	leave  
  800531:	c3                   	ret    

00800532 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	57                   	push   %edi
  800536:	56                   	push   %esi
  800537:	53                   	push   %ebx
  800538:	83 ec 2c             	sub    $0x2c,%esp
  80053b:	8b 75 08             	mov    0x8(%ebp),%esi
  80053e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800541:	8b 7d 10             	mov    0x10(%ebp),%edi
  800544:	eb 12                	jmp    800558 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800546:	85 c0                	test   %eax,%eax
  800548:	0f 84 d3 03 00 00    	je     800921 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	50                   	push   %eax
  800553:	ff d6                	call   *%esi
  800555:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800558:	83 c7 01             	add    $0x1,%edi
  80055b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055f:	83 f8 25             	cmp    $0x25,%eax
  800562:	75 e2                	jne    800546 <vprintfmt+0x14>
  800564:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800568:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80056f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800576:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057d:	ba 00 00 00 00       	mov    $0x0,%edx
  800582:	eb 07                	jmp    80058b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800587:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8d 47 01             	lea    0x1(%edi),%eax
  80058e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800591:	0f b6 07             	movzbl (%edi),%eax
  800594:	0f b6 c8             	movzbl %al,%ecx
  800597:	83 e8 23             	sub    $0x23,%eax
  80059a:	3c 55                	cmp    $0x55,%al
  80059c:	0f 87 64 03 00 00    	ja     800906 <vprintfmt+0x3d4>
  8005a2:	0f b6 c0             	movzbl %al,%eax
  8005a5:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b3:	eb d6                	jmp    80058b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005cd:	83 fa 09             	cmp    $0x9,%edx
  8005d0:	77 39                	ja     80060b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d5:	eb e9                	jmp    8005c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 48 04             	lea    0x4(%eax),%ecx
  8005dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e8:	eb 27                	jmp    800611 <vprintfmt+0xdf>
  8005ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ed:	85 c0                	test   %eax,%eax
  8005ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f4:	0f 49 c8             	cmovns %eax,%ecx
  8005f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fd:	eb 8c                	jmp    80058b <vprintfmt+0x59>
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800602:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800609:	eb 80                	jmp    80058b <vprintfmt+0x59>
  80060b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060e:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800611:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800615:	0f 89 70 ff ff ff    	jns    80058b <vprintfmt+0x59>
				width = precision, precision = -1;
  80061b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80061e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800621:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800628:	e9 5e ff ff ff       	jmp    80058b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800633:	e9 53 ff ff ff       	jmp    80058b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	ff 30                	pushl  (%eax)
  800647:	ff d6                	call   *%esi
			break;
  800649:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80064f:	e9 04 ff ff ff       	jmp    800558 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	99                   	cltd   
  800660:	31 d0                	xor    %edx,%eax
  800662:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800664:	83 f8 08             	cmp    $0x8,%eax
  800667:	7f 0b                	jg     800674 <vprintfmt+0x142>
  800669:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  800670:	85 d2                	test   %edx,%edx
  800672:	75 18                	jne    80068c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800674:	50                   	push   %eax
  800675:	68 55 10 80 00       	push   $0x801055
  80067a:	53                   	push   %ebx
  80067b:	56                   	push   %esi
  80067c:	e8 94 fe ff ff       	call   800515 <printfmt>
  800681:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800687:	e9 cc fe ff ff       	jmp    800558 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068c:	52                   	push   %edx
  80068d:	68 5e 10 80 00       	push   $0x80105e
  800692:	53                   	push   %ebx
  800693:	56                   	push   %esi
  800694:	e8 7c fe ff ff       	call   800515 <printfmt>
  800699:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069f:	e9 b4 fe ff ff       	jmp    800558 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006af:	85 ff                	test   %edi,%edi
  8006b1:	b8 4e 10 80 00       	mov    $0x80104e,%eax
  8006b6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bd:	0f 8e 94 00 00 00    	jle    800757 <vprintfmt+0x225>
  8006c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c7:	0f 84 98 00 00 00    	je     800765 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	ff 75 c8             	pushl  -0x38(%ebp)
  8006d3:	57                   	push   %edi
  8006d4:	e8 d0 02 00 00       	call   8009a9 <strnlen>
  8006d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006dc:	29 c1                	sub    %eax,%ecx
  8006de:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006e1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006eb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ee:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f0:	eb 0f                	jmp    800701 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fb:	83 ef 01             	sub    $0x1,%edi
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	85 ff                	test   %edi,%edi
  800703:	7f ed                	jg     8006f2 <vprintfmt+0x1c0>
  800705:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800708:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80070b:	85 c9                	test   %ecx,%ecx
  80070d:	b8 00 00 00 00       	mov    $0x0,%eax
  800712:	0f 49 c1             	cmovns %ecx,%eax
  800715:	29 c1                	sub    %eax,%ecx
  800717:	89 75 08             	mov    %esi,0x8(%ebp)
  80071a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80071d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800720:	89 cb                	mov    %ecx,%ebx
  800722:	eb 4d                	jmp    800771 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800724:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800728:	74 1b                	je     800745 <vprintfmt+0x213>
  80072a:	0f be c0             	movsbl %al,%eax
  80072d:	83 e8 20             	sub    $0x20,%eax
  800730:	83 f8 5e             	cmp    $0x5e,%eax
  800733:	76 10                	jbe    800745 <vprintfmt+0x213>
					putch('?', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	6a 3f                	push   $0x3f
  80073d:	ff 55 08             	call   *0x8(%ebp)
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb 0d                	jmp    800752 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	52                   	push   %edx
  80074c:	ff 55 08             	call   *0x8(%ebp)
  80074f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800752:	83 eb 01             	sub    $0x1,%ebx
  800755:	eb 1a                	jmp    800771 <vprintfmt+0x23f>
  800757:	89 75 08             	mov    %esi,0x8(%ebp)
  80075a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80075d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800760:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800763:	eb 0c                	jmp    800771 <vprintfmt+0x23f>
  800765:	89 75 08             	mov    %esi,0x8(%ebp)
  800768:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80076b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800771:	83 c7 01             	add    $0x1,%edi
  800774:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800778:	0f be d0             	movsbl %al,%edx
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 23                	je     8007a2 <vprintfmt+0x270>
  80077f:	85 f6                	test   %esi,%esi
  800781:	78 a1                	js     800724 <vprintfmt+0x1f2>
  800783:	83 ee 01             	sub    $0x1,%esi
  800786:	79 9c                	jns    800724 <vprintfmt+0x1f2>
  800788:	89 df                	mov    %ebx,%edi
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800790:	eb 18                	jmp    8007aa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 20                	push   $0x20
  800798:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079a:	83 ef 01             	sub    $0x1,%edi
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	eb 08                	jmp    8007aa <vprintfmt+0x278>
  8007a2:	89 df                	mov    %ebx,%edi
  8007a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007aa:	85 ff                	test   %edi,%edi
  8007ac:	7f e4                	jg     800792 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b1:	e9 a2 fd ff ff       	jmp    800558 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b6:	83 fa 01             	cmp    $0x1,%edx
  8007b9:	7e 16                	jle    8007d1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8d 50 08             	lea    0x8(%eax),%edx
  8007c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c4:	8b 50 04             	mov    0x4(%eax),%edx
  8007c7:	8b 00                	mov    (%eax),%eax
  8007c9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007cc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007cf:	eb 32                	jmp    800803 <vprintfmt+0x2d1>
	else if (lflag)
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	74 18                	je     8007ed <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 50 04             	lea    0x4(%eax),%edx
  8007db:	89 55 14             	mov    %edx,0x14(%ebp)
  8007de:	8b 00                	mov    (%eax),%eax
  8007e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007e3:	89 c1                	mov    %eax,%ecx
  8007e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007eb:	eb 16                	jmp    800803 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 50 04             	lea    0x4(%eax),%edx
  8007f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f6:	8b 00                	mov    (%eax),%eax
  8007f8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007fb:	89 c1                	mov    %eax,%ecx
  8007fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800800:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800803:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800806:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800809:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800814:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800818:	0f 89 b0 00 00 00    	jns    8008ce <vprintfmt+0x39c>
				putch('-', putdat);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	53                   	push   %ebx
  800822:	6a 2d                	push   $0x2d
  800824:	ff d6                	call   *%esi
				num = -(long long) num;
  800826:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800829:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80082c:	f7 d8                	neg    %eax
  80082e:	83 d2 00             	adc    $0x0,%edx
  800831:	f7 da                	neg    %edx
  800833:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800836:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800839:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 88 00 00 00       	jmp    8008ce <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 70 fc ff ff       	call   8004be <getuint>
  80084e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800851:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800854:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800859:	eb 73                	jmp    8008ce <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
  80085e:	e8 5b fc ff ff       	call   8004be <getuint>
  800863:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800866:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	53                   	push   %ebx
  80086d:	6a 58                	push   $0x58
  80086f:	ff d6                	call   *%esi
			putch('X', putdat);
  800871:	83 c4 08             	add    $0x8,%esp
  800874:	53                   	push   %ebx
  800875:	6a 58                	push   $0x58
  800877:	ff d6                	call   *%esi
			putch('X', putdat);
  800879:	83 c4 08             	add    $0x8,%esp
  80087c:	53                   	push   %ebx
  80087d:	6a 58                	push   $0x58
  80087f:	ff d6                	call   *%esi
			goto number;
  800881:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800884:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800889:	eb 43                	jmp    8008ce <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	6a 30                	push   $0x30
  800891:	ff d6                	call   *%esi
			putch('x', putdat);
  800893:	83 c4 08             	add    $0x8,%esp
  800896:	53                   	push   %ebx
  800897:	6a 78                	push   $0x78
  800899:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80089b:	8b 45 14             	mov    0x14(%ebp),%eax
  80089e:	8d 50 04             	lea    0x4(%eax),%edx
  8008a1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008b9:	eb 13                	jmp    8008ce <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008be:	e8 fb fb ff ff       	call   8004be <getuint>
  8008c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008c9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ce:	83 ec 0c             	sub    $0xc,%esp
  8008d1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008d5:	52                   	push   %edx
  8008d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d9:	50                   	push   %eax
  8008da:	ff 75 dc             	pushl  -0x24(%ebp)
  8008dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8008e0:	89 da                	mov    %ebx,%edx
  8008e2:	89 f0                	mov    %esi,%eax
  8008e4:	e8 26 fb ff ff       	call   80040f <printnum>
			break;
  8008e9:	83 c4 20             	add    $0x20,%esp
  8008ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ef:	e9 64 fc ff ff       	jmp    800558 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	53                   	push   %ebx
  8008f8:	51                   	push   %ecx
  8008f9:	ff d6                	call   *%esi
			break;
  8008fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800901:	e9 52 fc ff ff       	jmp    800558 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	6a 25                	push   $0x25
  80090c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	eb 03                	jmp    800916 <vprintfmt+0x3e4>
  800913:	83 ef 01             	sub    $0x1,%edi
  800916:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80091a:	75 f7                	jne    800913 <vprintfmt+0x3e1>
  80091c:	e9 37 fc ff ff       	jmp    800558 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800921:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	83 ec 18             	sub    $0x18,%esp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800935:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800938:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80093f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800946:	85 c0                	test   %eax,%eax
  800948:	74 26                	je     800970 <vsnprintf+0x47>
  80094a:	85 d2                	test   %edx,%edx
  80094c:	7e 22                	jle    800970 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094e:	ff 75 14             	pushl  0x14(%ebp)
  800951:	ff 75 10             	pushl  0x10(%ebp)
  800954:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800957:	50                   	push   %eax
  800958:	68 f8 04 80 00       	push   $0x8004f8
  80095d:	e8 d0 fb ff ff       	call   800532 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800962:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800965:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800968:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096b:	83 c4 10             	add    $0x10,%esp
  80096e:	eb 05                	jmp    800975 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800970:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800980:	50                   	push   %eax
  800981:	ff 75 10             	pushl  0x10(%ebp)
  800984:	ff 75 0c             	pushl  0xc(%ebp)
  800987:	ff 75 08             	pushl  0x8(%ebp)
  80098a:	e8 9a ff ff ff       	call   800929 <vsnprintf>
	va_end(ap);

	return rc;
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
  80099c:	eb 03                	jmp    8009a1 <strlen+0x10>
		n++;
  80099e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a5:	75 f7                	jne    80099e <strlen+0xd>
		n++;
	return n;
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	eb 03                	jmp    8009bc <strnlen+0x13>
		n++;
  8009b9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bc:	39 c2                	cmp    %eax,%edx
  8009be:	74 08                	je     8009c8 <strnlen+0x1f>
  8009c0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c4:	75 f3                	jne    8009b9 <strnlen+0x10>
  8009c6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	53                   	push   %ebx
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d4:	89 c2                	mov    %eax,%edx
  8009d6:	83 c2 01             	add    $0x1,%edx
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e3:	84 db                	test   %bl,%bl
  8009e5:	75 ef                	jne    8009d6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f1:	53                   	push   %ebx
  8009f2:	e8 9a ff ff ff       	call   800991 <strlen>
  8009f7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	01 d8                	add    %ebx,%eax
  8009ff:	50                   	push   %eax
  800a00:	e8 c5 ff ff ff       	call   8009ca <strcpy>
	return dst;
}
  800a05:	89 d8                	mov    %ebx,%eax
  800a07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 75 08             	mov    0x8(%ebp),%esi
  800a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1c:	89 f2                	mov    %esi,%edx
  800a1e:	eb 0f                	jmp    800a2f <strncpy+0x23>
		*dst++ = *src;
  800a20:	83 c2 01             	add    $0x1,%edx
  800a23:	0f b6 01             	movzbl (%ecx),%eax
  800a26:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a29:	80 39 01             	cmpb   $0x1,(%ecx)
  800a2c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2f:	39 da                	cmp    %ebx,%edx
  800a31:	75 ed                	jne    800a20 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a33:	89 f0                	mov    %esi,%eax
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a44:	8b 55 10             	mov    0x10(%ebp),%edx
  800a47:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a49:	85 d2                	test   %edx,%edx
  800a4b:	74 21                	je     800a6e <strlcpy+0x35>
  800a4d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a51:	89 f2                	mov    %esi,%edx
  800a53:	eb 09                	jmp    800a5e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a5e:	39 c2                	cmp    %eax,%edx
  800a60:	74 09                	je     800a6b <strlcpy+0x32>
  800a62:	0f b6 19             	movzbl (%ecx),%ebx
  800a65:	84 db                	test   %bl,%bl
  800a67:	75 ec                	jne    800a55 <strlcpy+0x1c>
  800a69:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a6e:	29 f0                	sub    %esi,%eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7d:	eb 06                	jmp    800a85 <strcmp+0x11>
		p++, q++;
  800a7f:	83 c1 01             	add    $0x1,%ecx
  800a82:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a85:	0f b6 01             	movzbl (%ecx),%eax
  800a88:	84 c0                	test   %al,%al
  800a8a:	74 04                	je     800a90 <strcmp+0x1c>
  800a8c:	3a 02                	cmp    (%edx),%al
  800a8e:	74 ef                	je     800a7f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a90:	0f b6 c0             	movzbl %al,%eax
  800a93:	0f b6 12             	movzbl (%edx),%edx
  800a96:	29 d0                	sub    %edx,%eax
}
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa9:	eb 06                	jmp    800ab1 <strncmp+0x17>
		n--, p++, q++;
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab1:	39 d8                	cmp    %ebx,%eax
  800ab3:	74 15                	je     800aca <strncmp+0x30>
  800ab5:	0f b6 08             	movzbl (%eax),%ecx
  800ab8:	84 c9                	test   %cl,%cl
  800aba:	74 04                	je     800ac0 <strncmp+0x26>
  800abc:	3a 0a                	cmp    (%edx),%cl
  800abe:	74 eb                	je     800aab <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac0:	0f b6 00             	movzbl (%eax),%eax
  800ac3:	0f b6 12             	movzbl (%edx),%edx
  800ac6:	29 d0                	sub    %edx,%eax
  800ac8:	eb 05                	jmp    800acf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800adc:	eb 07                	jmp    800ae5 <strchr+0x13>
		if (*s == c)
  800ade:	38 ca                	cmp    %cl,%dl
  800ae0:	74 0f                	je     800af1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	0f b6 10             	movzbl (%eax),%edx
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	75 f2                	jne    800ade <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afd:	eb 03                	jmp    800b02 <strfind+0xf>
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b05:	38 ca                	cmp    %cl,%dl
  800b07:	74 04                	je     800b0d <strfind+0x1a>
  800b09:	84 d2                	test   %dl,%dl
  800b0b:	75 f2                	jne    800aff <strfind+0xc>
			break;
	return (char *) s;
}
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1b:	85 c9                	test   %ecx,%ecx
  800b1d:	74 36                	je     800b55 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b25:	75 28                	jne    800b4f <memset+0x40>
  800b27:	f6 c1 03             	test   $0x3,%cl
  800b2a:	75 23                	jne    800b4f <memset+0x40>
		c &= 0xFF;
  800b2c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	c1 e3 08             	shl    $0x8,%ebx
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	c1 e6 18             	shl    $0x18,%esi
  800b3a:	89 d0                	mov    %edx,%eax
  800b3c:	c1 e0 10             	shl    $0x10,%eax
  800b3f:	09 f0                	or     %esi,%eax
  800b41:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b43:	89 d8                	mov    %ebx,%eax
  800b45:	09 d0                	or     %edx,%eax
  800b47:	c1 e9 02             	shr    $0x2,%ecx
  800b4a:	fc                   	cld    
  800b4b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4d:	eb 06                	jmp    800b55 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	fc                   	cld    
  800b53:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b55:	89 f8                	mov    %edi,%eax
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6a:	39 c6                	cmp    %eax,%esi
  800b6c:	73 35                	jae    800ba3 <memmove+0x47>
  800b6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b71:	39 d0                	cmp    %edx,%eax
  800b73:	73 2e                	jae    800ba3 <memmove+0x47>
		s += n;
		d += n;
  800b75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	09 fe                	or     %edi,%esi
  800b7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b82:	75 13                	jne    800b97 <memmove+0x3b>
  800b84:	f6 c1 03             	test   $0x3,%cl
  800b87:	75 0e                	jne    800b97 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b89:	83 ef 04             	sub    $0x4,%edi
  800b8c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8f:	c1 e9 02             	shr    $0x2,%ecx
  800b92:	fd                   	std    
  800b93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b95:	eb 09                	jmp    800ba0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b97:	83 ef 01             	sub    $0x1,%edi
  800b9a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9d:	fd                   	std    
  800b9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba0:	fc                   	cld    
  800ba1:	eb 1d                	jmp    800bc0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba3:	89 f2                	mov    %esi,%edx
  800ba5:	09 c2                	or     %eax,%edx
  800ba7:	f6 c2 03             	test   $0x3,%dl
  800baa:	75 0f                	jne    800bbb <memmove+0x5f>
  800bac:	f6 c1 03             	test   $0x3,%cl
  800baf:	75 0a                	jne    800bbb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb1:	c1 e9 02             	shr    $0x2,%ecx
  800bb4:	89 c7                	mov    %eax,%edi
  800bb6:	fc                   	cld    
  800bb7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb9:	eb 05                	jmp    800bc0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbb:	89 c7                	mov    %eax,%edi
  800bbd:	fc                   	cld    
  800bbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc7:	ff 75 10             	pushl  0x10(%ebp)
  800bca:	ff 75 0c             	pushl  0xc(%ebp)
  800bcd:	ff 75 08             	pushl  0x8(%ebp)
  800bd0:	e8 87 ff ff ff       	call   800b5c <memmove>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be2:	89 c6                	mov    %eax,%esi
  800be4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be7:	eb 1a                	jmp    800c03 <memcmp+0x2c>
		if (*s1 != *s2)
  800be9:	0f b6 08             	movzbl (%eax),%ecx
  800bec:	0f b6 1a             	movzbl (%edx),%ebx
  800bef:	38 d9                	cmp    %bl,%cl
  800bf1:	74 0a                	je     800bfd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf3:	0f b6 c1             	movzbl %cl,%eax
  800bf6:	0f b6 db             	movzbl %bl,%ebx
  800bf9:	29 d8                	sub    %ebx,%eax
  800bfb:	eb 0f                	jmp    800c0c <memcmp+0x35>
		s1++, s2++;
  800bfd:	83 c0 01             	add    $0x1,%eax
  800c00:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c03:	39 f0                	cmp    %esi,%eax
  800c05:	75 e2                	jne    800be9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	53                   	push   %ebx
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c17:	89 c1                	mov    %eax,%ecx
  800c19:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c20:	eb 0a                	jmp    800c2c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c22:	0f b6 10             	movzbl (%eax),%edx
  800c25:	39 da                	cmp    %ebx,%edx
  800c27:	74 07                	je     800c30 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c29:	83 c0 01             	add    $0x1,%eax
  800c2c:	39 c8                	cmp    %ecx,%eax
  800c2e:	72 f2                	jb     800c22 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3f:	eb 03                	jmp    800c44 <strtol+0x11>
		s++;
  800c41:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c44:	0f b6 01             	movzbl (%ecx),%eax
  800c47:	3c 20                	cmp    $0x20,%al
  800c49:	74 f6                	je     800c41 <strtol+0xe>
  800c4b:	3c 09                	cmp    $0x9,%al
  800c4d:	74 f2                	je     800c41 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4f:	3c 2b                	cmp    $0x2b,%al
  800c51:	75 0a                	jne    800c5d <strtol+0x2a>
		s++;
  800c53:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c56:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5b:	eb 11                	jmp    800c6e <strtol+0x3b>
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c62:	3c 2d                	cmp    $0x2d,%al
  800c64:	75 08                	jne    800c6e <strtol+0x3b>
		s++, neg = 1;
  800c66:	83 c1 01             	add    $0x1,%ecx
  800c69:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c74:	75 15                	jne    800c8b <strtol+0x58>
  800c76:	80 39 30             	cmpb   $0x30,(%ecx)
  800c79:	75 10                	jne    800c8b <strtol+0x58>
  800c7b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c7f:	75 7c                	jne    800cfd <strtol+0xca>
		s += 2, base = 16;
  800c81:	83 c1 02             	add    $0x2,%ecx
  800c84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c89:	eb 16                	jmp    800ca1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8b:	85 db                	test   %ebx,%ebx
  800c8d:	75 12                	jne    800ca1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c94:	80 39 30             	cmpb   $0x30,(%ecx)
  800c97:	75 08                	jne    800ca1 <strtol+0x6e>
		s++, base = 8;
  800c99:	83 c1 01             	add    $0x1,%ecx
  800c9c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca9:	0f b6 11             	movzbl (%ecx),%edx
  800cac:	8d 72 d0             	lea    -0x30(%edx),%esi
  800caf:	89 f3                	mov    %esi,%ebx
  800cb1:	80 fb 09             	cmp    $0x9,%bl
  800cb4:	77 08                	ja     800cbe <strtol+0x8b>
			dig = *s - '0';
  800cb6:	0f be d2             	movsbl %dl,%edx
  800cb9:	83 ea 30             	sub    $0x30,%edx
  800cbc:	eb 22                	jmp    800ce0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cbe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc1:	89 f3                	mov    %esi,%ebx
  800cc3:	80 fb 19             	cmp    $0x19,%bl
  800cc6:	77 08                	ja     800cd0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cc8:	0f be d2             	movsbl %dl,%edx
  800ccb:	83 ea 57             	sub    $0x57,%edx
  800cce:	eb 10                	jmp    800ce0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd3:	89 f3                	mov    %esi,%ebx
  800cd5:	80 fb 19             	cmp    $0x19,%bl
  800cd8:	77 16                	ja     800cf0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cda:	0f be d2             	movsbl %dl,%edx
  800cdd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce3:	7d 0b                	jge    800cf0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce5:	83 c1 01             	add    $0x1,%ecx
  800ce8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cec:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cee:	eb b9                	jmp    800ca9 <strtol+0x76>

	if (endptr)
  800cf0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf4:	74 0d                	je     800d03 <strtol+0xd0>
		*endptr = (char *) s;
  800cf6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf9:	89 0e                	mov    %ecx,(%esi)
  800cfb:	eb 06                	jmp    800d03 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfd:	85 db                	test   %ebx,%ebx
  800cff:	74 98                	je     800c99 <strtol+0x66>
  800d01:	eb 9e                	jmp    800ca1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d03:	89 c2                	mov    %eax,%edx
  800d05:	f7 da                	neg    %edx
  800d07:	85 ff                	test   %edi,%edi
  800d09:	0f 45 c2             	cmovne %edx,%eax
}
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d17:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d1e:	75 14                	jne    800d34 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d20:	83 ec 04             	sub    $0x4,%esp
  800d23:	68 84 12 80 00       	push   $0x801284
  800d28:	6a 20                	push   $0x20
  800d2a:	68 a8 12 80 00       	push   $0x8012a8
  800d2f:	e8 ee f5 ff ff       	call   800322 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__udivdi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 f6                	test   %esi,%esi
  800d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d5d:	89 ca                	mov    %ecx,%edx
  800d5f:	89 f8                	mov    %edi,%eax
  800d61:	75 3d                	jne    800da0 <__udivdi3+0x60>
  800d63:	39 cf                	cmp    %ecx,%edi
  800d65:	0f 87 c5 00 00 00    	ja     800e30 <__udivdi3+0xf0>
  800d6b:	85 ff                	test   %edi,%edi
  800d6d:	89 fd                	mov    %edi,%ebp
  800d6f:	75 0b                	jne    800d7c <__udivdi3+0x3c>
  800d71:	b8 01 00 00 00       	mov    $0x1,%eax
  800d76:	31 d2                	xor    %edx,%edx
  800d78:	f7 f7                	div    %edi
  800d7a:	89 c5                	mov    %eax,%ebp
  800d7c:	89 c8                	mov    %ecx,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f5                	div    %ebp
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	89 d8                	mov    %ebx,%eax
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	f7 f5                	div    %ebp
  800d8a:	89 c3                	mov    %eax,%ebx
  800d8c:	89 d8                	mov    %ebx,%eax
  800d8e:	89 fa                	mov    %edi,%edx
  800d90:	83 c4 1c             	add    $0x1c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    
  800d98:	90                   	nop
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	39 ce                	cmp    %ecx,%esi
  800da2:	77 74                	ja     800e18 <__udivdi3+0xd8>
  800da4:	0f bd fe             	bsr    %esi,%edi
  800da7:	83 f7 1f             	xor    $0x1f,%edi
  800daa:	0f 84 98 00 00 00    	je     800e48 <__udivdi3+0x108>
  800db0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	89 c5                	mov    %eax,%ebp
  800db9:	29 fb                	sub    %edi,%ebx
  800dbb:	d3 e6                	shl    %cl,%esi
  800dbd:	89 d9                	mov    %ebx,%ecx
  800dbf:	d3 ed                	shr    %cl,%ebp
  800dc1:	89 f9                	mov    %edi,%ecx
  800dc3:	d3 e0                	shl    %cl,%eax
  800dc5:	09 ee                	or     %ebp,%esi
  800dc7:	89 d9                	mov    %ebx,%ecx
  800dc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dcd:	89 d5                	mov    %edx,%ebp
  800dcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dd3:	d3 ed                	shr    %cl,%ebp
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e2                	shl    %cl,%edx
  800dd9:	89 d9                	mov    %ebx,%ecx
  800ddb:	d3 e8                	shr    %cl,%eax
  800ddd:	09 c2                	or     %eax,%edx
  800ddf:	89 d0                	mov    %edx,%eax
  800de1:	89 ea                	mov    %ebp,%edx
  800de3:	f7 f6                	div    %esi
  800de5:	89 d5                	mov    %edx,%ebp
  800de7:	89 c3                	mov    %eax,%ebx
  800de9:	f7 64 24 0c          	mull   0xc(%esp)
  800ded:	39 d5                	cmp    %edx,%ebp
  800def:	72 10                	jb     800e01 <__udivdi3+0xc1>
  800df1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	d3 e6                	shl    %cl,%esi
  800df9:	39 c6                	cmp    %eax,%esi
  800dfb:	73 07                	jae    800e04 <__udivdi3+0xc4>
  800dfd:	39 d5                	cmp    %edx,%ebp
  800dff:	75 03                	jne    800e04 <__udivdi3+0xc4>
  800e01:	83 eb 01             	sub    $0x1,%ebx
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 d8                	mov    %ebx,%eax
  800e08:	89 fa                	mov    %edi,%edx
  800e0a:	83 c4 1c             	add    $0x1c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
  800e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e18:	31 ff                	xor    %edi,%edi
  800e1a:	31 db                	xor    %ebx,%ebx
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 1c             	add    $0x1c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	89 d8                	mov    %ebx,%eax
  800e32:	f7 f7                	div    %edi
  800e34:	31 ff                	xor    %edi,%edi
  800e36:	89 c3                	mov    %eax,%ebx
  800e38:	89 d8                	mov    %ebx,%eax
  800e3a:	89 fa                	mov    %edi,%edx
  800e3c:	83 c4 1c             	add    $0x1c,%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    
  800e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e48:	39 ce                	cmp    %ecx,%esi
  800e4a:	72 0c                	jb     800e58 <__udivdi3+0x118>
  800e4c:	31 db                	xor    %ebx,%ebx
  800e4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e52:	0f 87 34 ff ff ff    	ja     800d8c <__udivdi3+0x4c>
  800e58:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e5d:	e9 2a ff ff ff       	jmp    800d8c <__udivdi3+0x4c>
  800e62:	66 90                	xchg   %ax,%ax
  800e64:	66 90                	xchg   %ax,%ax
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__umoddi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 d2                	test   %edx,%edx
  800e89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f3                	mov    %esi,%ebx
  800e93:	89 3c 24             	mov    %edi,(%esp)
  800e96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e9a:	75 1c                	jne    800eb8 <__umoddi3+0x48>
  800e9c:	39 f7                	cmp    %esi,%edi
  800e9e:	76 50                	jbe    800ef0 <__umoddi3+0x80>
  800ea0:	89 c8                	mov    %ecx,%eax
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	f7 f7                	div    %edi
  800ea6:	89 d0                	mov    %edx,%eax
  800ea8:	31 d2                	xor    %edx,%edx
  800eaa:	83 c4 1c             	add    $0x1c,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
  800eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb8:	39 f2                	cmp    %esi,%edx
  800eba:	89 d0                	mov    %edx,%eax
  800ebc:	77 52                	ja     800f10 <__umoddi3+0xa0>
  800ebe:	0f bd ea             	bsr    %edx,%ebp
  800ec1:	83 f5 1f             	xor    $0x1f,%ebp
  800ec4:	75 5a                	jne    800f20 <__umoddi3+0xb0>
  800ec6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eca:	0f 82 e0 00 00 00    	jb     800fb0 <__umoddi3+0x140>
  800ed0:	39 0c 24             	cmp    %ecx,(%esp)
  800ed3:	0f 86 d7 00 00 00    	jbe    800fb0 <__umoddi3+0x140>
  800ed9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800edd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ee1:	83 c4 1c             	add    $0x1c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	85 ff                	test   %edi,%edi
  800ef2:	89 fd                	mov    %edi,%ebp
  800ef4:	75 0b                	jne    800f01 <__umoddi3+0x91>
  800ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	f7 f7                	div    %edi
  800eff:	89 c5                	mov    %eax,%ebp
  800f01:	89 f0                	mov    %esi,%eax
  800f03:	31 d2                	xor    %edx,%edx
  800f05:	f7 f5                	div    %ebp
  800f07:	89 c8                	mov    %ecx,%eax
  800f09:	f7 f5                	div    %ebp
  800f0b:	89 d0                	mov    %edx,%eax
  800f0d:	eb 99                	jmp    800ea8 <__umoddi3+0x38>
  800f0f:	90                   	nop
  800f10:	89 c8                	mov    %ecx,%eax
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	83 c4 1c             	add    $0x1c,%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    
  800f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f20:	8b 34 24             	mov    (%esp),%esi
  800f23:	bf 20 00 00 00       	mov    $0x20,%edi
  800f28:	89 e9                	mov    %ebp,%ecx
  800f2a:	29 ef                	sub    %ebp,%edi
  800f2c:	d3 e0                	shl    %cl,%eax
  800f2e:	89 f9                	mov    %edi,%ecx
  800f30:	89 f2                	mov    %esi,%edx
  800f32:	d3 ea                	shr    %cl,%edx
  800f34:	89 e9                	mov    %ebp,%ecx
  800f36:	09 c2                	or     %eax,%edx
  800f38:	89 d8                	mov    %ebx,%eax
  800f3a:	89 14 24             	mov    %edx,(%esp)
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	d3 e2                	shl    %cl,%edx
  800f41:	89 f9                	mov    %edi,%ecx
  800f43:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f4b:	d3 e8                	shr    %cl,%eax
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	d3 e3                	shl    %cl,%ebx
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 d0                	mov    %edx,%eax
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	09 d8                	or     %ebx,%eax
  800f5d:	89 d3                	mov    %edx,%ebx
  800f5f:	89 f2                	mov    %esi,%edx
  800f61:	f7 34 24             	divl   (%esp)
  800f64:	89 d6                	mov    %edx,%esi
  800f66:	d3 e3                	shl    %cl,%ebx
  800f68:	f7 64 24 04          	mull   0x4(%esp)
  800f6c:	39 d6                	cmp    %edx,%esi
  800f6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f72:	89 d1                	mov    %edx,%ecx
  800f74:	89 c3                	mov    %eax,%ebx
  800f76:	72 08                	jb     800f80 <__umoddi3+0x110>
  800f78:	75 11                	jne    800f8b <__umoddi3+0x11b>
  800f7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f7e:	73 0b                	jae    800f8b <__umoddi3+0x11b>
  800f80:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f84:	1b 14 24             	sbb    (%esp),%edx
  800f87:	89 d1                	mov    %edx,%ecx
  800f89:	89 c3                	mov    %eax,%ebx
  800f8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f8f:	29 da                	sub    %ebx,%edx
  800f91:	19 ce                	sbb    %ecx,%esi
  800f93:	89 f9                	mov    %edi,%ecx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	d3 e0                	shl    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	d3 ea                	shr    %cl,%edx
  800f9d:	89 e9                	mov    %ebp,%ecx
  800f9f:	d3 ee                	shr    %cl,%esi
  800fa1:	09 d0                	or     %edx,%eax
  800fa3:	89 f2                	mov    %esi,%edx
  800fa5:	83 c4 1c             	add    $0x1c,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    
  800fad:	8d 76 00             	lea    0x0(%esi),%esi
  800fb0:	29 f9                	sub    %edi,%ecx
  800fb2:	19 d6                	sbb    %edx,%esi
  800fb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fbc:	e9 18 ff ff ff       	jmp    800ed9 <__umoddi3+0x69>
