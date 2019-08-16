
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
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 aa 10 80 00       	push   $0x8010aa
  800116:	6a 23                	push   $0x23
  800118:	68 c7 10 80 00       	push   $0x8010c7
  80011d:	e8 1e 02 00 00       	call   800340 <_panic>

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
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 aa 10 80 00       	push   $0x8010aa
  800197:	6a 23                	push   $0x23
  800199:	68 c7 10 80 00       	push   $0x8010c7
  80019e:	e8 9d 01 00 00       	call   800340 <_panic>

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
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 aa 10 80 00       	push   $0x8010aa
  8001d9:	6a 23                	push   $0x23
  8001db:	68 c7 10 80 00       	push   $0x8010c7
  8001e0:	e8 5b 01 00 00       	call   800340 <_panic>
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
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 aa 10 80 00       	push   $0x8010aa
  80021b:	6a 23                	push   $0x23
  80021d:	68 c7 10 80 00       	push   $0x8010c7
  800222:	e8 19 01 00 00       	call   800340 <_panic>
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
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 aa 10 80 00       	push   $0x8010aa
  80025d:	6a 23                	push   $0x23
  80025f:	68 c7 10 80 00       	push   $0x8010c7
  800264:	e8 d7 00 00 00       	call   800340 <_panic>

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
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 aa 10 80 00       	push   $0x8010aa
  80029f:	6a 23                	push   $0x23
  8002a1:	68 c7 10 80 00       	push   $0x8010c7
  8002a6:	e8 95 00 00 00       	call   800340 <_panic>

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
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 aa 10 80 00       	push   $0x8010aa
  800303:	6a 23                	push   $0x23
  800305:	68 c7 10 80 00       	push   $0x8010c7
  80030a:	e8 31 00 00 00       	call   800340 <_panic>

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
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  800322:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  800324:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  800328:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  80032c:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  80032d:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  80032f:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  800336:	00 
	popl %eax
  800337:	58                   	pop    %eax
	popl %eax
  800338:	58                   	pop    %eax
	popal
  800339:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  80033a:	83 c4 04             	add    $0x4,%esp
	popfl
  80033d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80033e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80033f:	c3                   	ret    

00800340 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800345:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800348:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034e:	e8 d7 fd ff ff       	call   80012a <sys_getenvid>
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 0c             	pushl  0xc(%ebp)
  800359:	ff 75 08             	pushl  0x8(%ebp)
  80035c:	56                   	push   %esi
  80035d:	50                   	push   %eax
  80035e:	68 d8 10 80 00       	push   $0x8010d8
  800363:	e8 b1 00 00 00       	call   800419 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800368:	83 c4 18             	add    $0x18,%esp
  80036b:	53                   	push   %ebx
  80036c:	ff 75 10             	pushl  0x10(%ebp)
  80036f:	e8 54 00 00 00       	call   8003c8 <vcprintf>
	cprintf("\n");
  800374:	c7 04 24 38 14 80 00 	movl   $0x801438,(%esp)
  80037b:	e8 99 00 00 00       	call   800419 <cprintf>
  800380:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800383:	cc                   	int3   
  800384:	eb fd                	jmp    800383 <_panic+0x43>

00800386 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	53                   	push   %ebx
  80038a:	83 ec 04             	sub    $0x4,%esp
  80038d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800390:	8b 13                	mov    (%ebx),%edx
  800392:	8d 42 01             	lea    0x1(%edx),%eax
  800395:	89 03                	mov    %eax,(%ebx)
  800397:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a3:	75 1a                	jne    8003bf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	68 ff 00 00 00       	push   $0xff
  8003ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b0:	50                   	push   %eax
  8003b1:	e8 f6 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003bc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8003d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d8:	00 00 00 
	b.cnt = 0;
  8003db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f1:	50                   	push   %eax
  8003f2:	68 86 03 80 00       	push   $0x800386
  8003f7:	e8 54 01 00 00       	call   800550 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fc:	83 c4 08             	add    $0x8,%esp
  8003ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800405:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040b:	50                   	push   %eax
  80040c:	e8 9b fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800411:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800417:	c9                   	leave  
  800418:	c3                   	ret    

00800419 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800422:	50                   	push   %eax
  800423:	ff 75 08             	pushl  0x8(%ebp)
  800426:	e8 9d ff ff ff       	call   8003c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042b:	c9                   	leave  
  80042c:	c3                   	ret    

0080042d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	57                   	push   %edi
  800431:	56                   	push   %esi
  800432:	53                   	push   %ebx
  800433:	83 ec 1c             	sub    $0x1c,%esp
  800436:	89 c7                	mov    %eax,%edi
  800438:	89 d6                	mov    %edx,%esi
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800440:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800443:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800446:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800449:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800451:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800454:	39 d3                	cmp    %edx,%ebx
  800456:	72 05                	jb     80045d <printnum+0x30>
  800458:	39 45 10             	cmp    %eax,0x10(%ebp)
  80045b:	77 45                	ja     8004a2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045d:	83 ec 0c             	sub    $0xc,%esp
  800460:	ff 75 18             	pushl  0x18(%ebp)
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800469:	53                   	push   %ebx
  80046a:	ff 75 10             	pushl  0x10(%ebp)
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	ff 75 e4             	pushl  -0x1c(%ebp)
  800473:	ff 75 e0             	pushl  -0x20(%ebp)
  800476:	ff 75 dc             	pushl  -0x24(%ebp)
  800479:	ff 75 d8             	pushl  -0x28(%ebp)
  80047c:	e8 7f 09 00 00       	call   800e00 <__udivdi3>
  800481:	83 c4 18             	add    $0x18,%esp
  800484:	52                   	push   %edx
  800485:	50                   	push   %eax
  800486:	89 f2                	mov    %esi,%edx
  800488:	89 f8                	mov    %edi,%eax
  80048a:	e8 9e ff ff ff       	call   80042d <printnum>
  80048f:	83 c4 20             	add    $0x20,%esp
  800492:	eb 18                	jmp    8004ac <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	56                   	push   %esi
  800498:	ff 75 18             	pushl  0x18(%ebp)
  80049b:	ff d7                	call   *%edi
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	eb 03                	jmp    8004a5 <printnum+0x78>
  8004a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	85 db                	test   %ebx,%ebx
  8004aa:	7f e8                	jg     800494 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	56                   	push   %esi
  8004b0:	83 ec 04             	sub    $0x4,%esp
  8004b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bf:	e8 6c 0a 00 00       	call   800f30 <__umoddi3>
  8004c4:	83 c4 14             	add    $0x14,%esp
  8004c7:	0f be 80 fb 10 80 00 	movsbl 0x8010fb(%eax),%eax
  8004ce:	50                   	push   %eax
  8004cf:	ff d7                	call   *%edi
}
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004df:	83 fa 01             	cmp    $0x1,%edx
  8004e2:	7e 0e                	jle    8004f2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004e4:	8b 10                	mov    (%eax),%edx
  8004e6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e9:	89 08                	mov    %ecx,(%eax)
  8004eb:	8b 02                	mov    (%edx),%eax
  8004ed:	8b 52 04             	mov    0x4(%edx),%edx
  8004f0:	eb 22                	jmp    800514 <getuint+0x38>
	else if (lflag)
  8004f2:	85 d2                	test   %edx,%edx
  8004f4:	74 10                	je     800506 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f6:	8b 10                	mov    (%eax),%edx
  8004f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004fb:	89 08                	mov    %ecx,(%eax)
  8004fd:	8b 02                	mov    (%edx),%eax
  8004ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800504:	eb 0e                	jmp    800514 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800506:	8b 10                	mov    (%eax),%edx
  800508:	8d 4a 04             	lea    0x4(%edx),%ecx
  80050b:	89 08                	mov    %ecx,(%eax)
  80050d:	8b 02                	mov    (%edx),%eax
  80050f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80051c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800520:	8b 10                	mov    (%eax),%edx
  800522:	3b 50 04             	cmp    0x4(%eax),%edx
  800525:	73 0a                	jae    800531 <sprintputch+0x1b>
		*b->buf++ = ch;
  800527:	8d 4a 01             	lea    0x1(%edx),%ecx
  80052a:	89 08                	mov    %ecx,(%eax)
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	88 02                	mov    %al,(%edx)
}
  800531:	5d                   	pop    %ebp
  800532:	c3                   	ret    

00800533 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800539:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053c:	50                   	push   %eax
  80053d:	ff 75 10             	pushl  0x10(%ebp)
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	ff 75 08             	pushl  0x8(%ebp)
  800546:	e8 05 00 00 00       	call   800550 <vprintfmt>
	va_end(ap);
}
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 2c             	sub    $0x2c,%esp
  800559:	8b 75 08             	mov    0x8(%ebp),%esi
  80055c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800562:	eb 12                	jmp    800576 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800564:	85 c0                	test   %eax,%eax
  800566:	0f 84 d3 03 00 00    	je     80093f <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	50                   	push   %eax
  800571:	ff d6                	call   *%esi
  800573:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800576:	83 c7 01             	add    $0x1,%edi
  800579:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057d:	83 f8 25             	cmp    $0x25,%eax
  800580:	75 e2                	jne    800564 <vprintfmt+0x14>
  800582:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800586:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80058d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800594:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80059b:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a0:	eb 07                	jmp    8005a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8d 47 01             	lea    0x1(%edi),%eax
  8005ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005af:	0f b6 07             	movzbl (%edi),%eax
  8005b2:	0f b6 c8             	movzbl %al,%ecx
  8005b5:	83 e8 23             	sub    $0x23,%eax
  8005b8:	3c 55                	cmp    $0x55,%al
  8005ba:	0f 87 64 03 00 00    	ja     800924 <vprintfmt+0x3d4>
  8005c0:	0f b6 c0             	movzbl %al,%eax
  8005c3:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005cd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005d1:	eb d6                	jmp    8005a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005e5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005e8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005eb:	83 fa 09             	cmp    $0x9,%edx
  8005ee:	77 39                	ja     800629 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005f3:	eb e9                	jmp    8005de <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 48 04             	lea    0x4(%eax),%ecx
  8005fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800606:	eb 27                	jmp    80062f <vprintfmt+0xdf>
  800608:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060b:	85 c0                	test   %eax,%eax
  80060d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800612:	0f 49 c8             	cmovns %eax,%ecx
  800615:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061b:	eb 8c                	jmp    8005a9 <vprintfmt+0x59>
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800620:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800627:	eb 80                	jmp    8005a9 <vprintfmt+0x59>
  800629:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062c:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 89 70 ff ff ff    	jns    8005a9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800639:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80063c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80063f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800646:	e9 5e ff ff ff       	jmp    8005a9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80064b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800651:	e9 53 ff ff ff       	jmp    8005a9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	ff 30                	pushl  (%eax)
  800665:	ff d6                	call   *%esi
			break;
  800667:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80066d:	e9 04 ff ff ff       	jmp    800576 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	99                   	cltd   
  80067e:	31 d0                	xor    %edx,%eax
  800680:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800682:	83 f8 08             	cmp    $0x8,%eax
  800685:	7f 0b                	jg     800692 <vprintfmt+0x142>
  800687:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  80068e:	85 d2                	test   %edx,%edx
  800690:	75 18                	jne    8006aa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800692:	50                   	push   %eax
  800693:	68 13 11 80 00       	push   $0x801113
  800698:	53                   	push   %ebx
  800699:	56                   	push   %esi
  80069a:	e8 94 fe ff ff       	call   800533 <printfmt>
  80069f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006a5:	e9 cc fe ff ff       	jmp    800576 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006aa:	52                   	push   %edx
  8006ab:	68 1c 11 80 00       	push   $0x80111c
  8006b0:	53                   	push   %ebx
  8006b1:	56                   	push   %esi
  8006b2:	e8 7c fe ff ff       	call   800533 <printfmt>
  8006b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bd:	e9 b4 fe ff ff       	jmp    800576 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 04             	lea    0x4(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006cd:	85 ff                	test   %edi,%edi
  8006cf:	b8 0c 11 80 00       	mov    $0x80110c,%eax
  8006d4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006db:	0f 8e 94 00 00 00    	jle    800775 <vprintfmt+0x225>
  8006e1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006e5:	0f 84 98 00 00 00    	je     800783 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	ff 75 c8             	pushl  -0x38(%ebp)
  8006f1:	57                   	push   %edi
  8006f2:	e8 d0 02 00 00       	call   8009c7 <strnlen>
  8006f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006fa:	29 c1                	sub    %eax,%ecx
  8006fc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006ff:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800702:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800706:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800709:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80070c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070e:	eb 0f                	jmp    80071f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	ff 75 e0             	pushl  -0x20(%ebp)
  800717:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800719:	83 ef 01             	sub    $0x1,%edi
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 ff                	test   %edi,%edi
  800721:	7f ed                	jg     800710 <vprintfmt+0x1c0>
  800723:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800726:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800729:	85 c9                	test   %ecx,%ecx
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
  800730:	0f 49 c1             	cmovns %ecx,%eax
  800733:	29 c1                	sub    %eax,%ecx
  800735:	89 75 08             	mov    %esi,0x8(%ebp)
  800738:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80073b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073e:	89 cb                	mov    %ecx,%ebx
  800740:	eb 4d                	jmp    80078f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800742:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800746:	74 1b                	je     800763 <vprintfmt+0x213>
  800748:	0f be c0             	movsbl %al,%eax
  80074b:	83 e8 20             	sub    $0x20,%eax
  80074e:	83 f8 5e             	cmp    $0x5e,%eax
  800751:	76 10                	jbe    800763 <vprintfmt+0x213>
					putch('?', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	ff 75 0c             	pushl  0xc(%ebp)
  800759:	6a 3f                	push   $0x3f
  80075b:	ff 55 08             	call   *0x8(%ebp)
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb 0d                	jmp    800770 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	52                   	push   %edx
  80076a:	ff 55 08             	call   *0x8(%ebp)
  80076d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800770:	83 eb 01             	sub    $0x1,%ebx
  800773:	eb 1a                	jmp    80078f <vprintfmt+0x23f>
  800775:	89 75 08             	mov    %esi,0x8(%ebp)
  800778:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80077b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800781:	eb 0c                	jmp    80078f <vprintfmt+0x23f>
  800783:	89 75 08             	mov    %esi,0x8(%ebp)
  800786:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800789:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80078c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80078f:	83 c7 01             	add    $0x1,%edi
  800792:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800796:	0f be d0             	movsbl %al,%edx
  800799:	85 d2                	test   %edx,%edx
  80079b:	74 23                	je     8007c0 <vprintfmt+0x270>
  80079d:	85 f6                	test   %esi,%esi
  80079f:	78 a1                	js     800742 <vprintfmt+0x1f2>
  8007a1:	83 ee 01             	sub    $0x1,%esi
  8007a4:	79 9c                	jns    800742 <vprintfmt+0x1f2>
  8007a6:	89 df                	mov    %ebx,%edi
  8007a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ae:	eb 18                	jmp    8007c8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	53                   	push   %ebx
  8007b4:	6a 20                	push   $0x20
  8007b6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b8:	83 ef 01             	sub    $0x1,%edi
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb 08                	jmp    8007c8 <vprintfmt+0x278>
  8007c0:	89 df                	mov    %ebx,%edi
  8007c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c8:	85 ff                	test   %edi,%edi
  8007ca:	7f e4                	jg     8007b0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007cf:	e9 a2 fd ff ff       	jmp    800576 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d4:	83 fa 01             	cmp    $0x1,%edx
  8007d7:	7e 16                	jle    8007ef <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 08             	lea    0x8(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e2:	8b 50 04             	mov    0x4(%eax),%edx
  8007e5:	8b 00                	mov    (%eax),%eax
  8007e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007ea:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007ed:	eb 32                	jmp    800821 <vprintfmt+0x2d1>
	else if (lflag)
  8007ef:	85 d2                	test   %edx,%edx
  8007f1:	74 18                	je     80080b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 50 04             	lea    0x4(%eax),%edx
  8007f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fc:	8b 00                	mov    (%eax),%eax
  8007fe:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800801:	89 c1                	mov    %eax,%ecx
  800803:	c1 f9 1f             	sar    $0x1f,%ecx
  800806:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800809:	eb 16                	jmp    800821 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 04             	lea    0x4(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)
  800814:	8b 00                	mov    (%eax),%eax
  800816:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800819:	89 c1                	mov    %eax,%ecx
  80081b:	c1 f9 1f             	sar    $0x1f,%ecx
  80081e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800821:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800824:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800827:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80082d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800832:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800836:	0f 89 b0 00 00 00    	jns    8008ec <vprintfmt+0x39c>
				putch('-', putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	53                   	push   %ebx
  800840:	6a 2d                	push   $0x2d
  800842:	ff d6                	call   *%esi
				num = -(long long) num;
  800844:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800847:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80084a:	f7 d8                	neg    %eax
  80084c:	83 d2 00             	adc    $0x0,%edx
  80084f:	f7 da                	neg    %edx
  800851:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800854:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800857:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80085a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085f:	e9 88 00 00 00       	jmp    8008ec <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800864:	8d 45 14             	lea    0x14(%ebp),%eax
  800867:	e8 70 fc ff ff       	call   8004dc <getuint>
  80086c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80086f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800872:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800877:	eb 73                	jmp    8008ec <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800879:	8d 45 14             	lea    0x14(%ebp),%eax
  80087c:	e8 5b fc ff ff       	call   8004dc <getuint>
  800881:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800884:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	53                   	push   %ebx
  80088b:	6a 58                	push   $0x58
  80088d:	ff d6                	call   *%esi
			putch('X', putdat);
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	53                   	push   %ebx
  800893:	6a 58                	push   $0x58
  800895:	ff d6                	call   *%esi
			putch('X', putdat);
  800897:	83 c4 08             	add    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	6a 58                	push   $0x58
  80089d:	ff d6                	call   *%esi
			goto number;
  80089f:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8008a2:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8008a7:	eb 43                	jmp    8008ec <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	6a 30                	push   $0x30
  8008af:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b1:	83 c4 08             	add    $0x8,%esp
  8008b4:	53                   	push   %ebx
  8008b5:	6a 78                	push   $0x78
  8008b7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8d 50 04             	lea    0x4(%eax),%edx
  8008bf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008c2:	8b 00                	mov    (%eax),%eax
  8008c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008cf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d7:	eb 13                	jmp    8008ec <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008dc:	e8 fb fb ff ff       	call   8004dc <getuint>
  8008e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ec:	83 ec 0c             	sub    $0xc,%esp
  8008ef:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008f3:	52                   	push   %edx
  8008f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8008f7:	50                   	push   %eax
  8008f8:	ff 75 dc             	pushl  -0x24(%ebp)
  8008fb:	ff 75 d8             	pushl  -0x28(%ebp)
  8008fe:	89 da                	mov    %ebx,%edx
  800900:	89 f0                	mov    %esi,%eax
  800902:	e8 26 fb ff ff       	call   80042d <printnum>
			break;
  800907:	83 c4 20             	add    $0x20,%esp
  80090a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80090d:	e9 64 fc ff ff       	jmp    800576 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	53                   	push   %ebx
  800916:	51                   	push   %ecx
  800917:	ff d6                	call   *%esi
			break;
  800919:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80091f:	e9 52 fc ff ff       	jmp    800576 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	53                   	push   %ebx
  800928:	6a 25                	push   $0x25
  80092a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	eb 03                	jmp    800934 <vprintfmt+0x3e4>
  800931:	83 ef 01             	sub    $0x1,%edi
  800934:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800938:	75 f7                	jne    800931 <vprintfmt+0x3e1>
  80093a:	e9 37 fc ff ff       	jmp    800576 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80093f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	83 ec 18             	sub    $0x18,%esp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800953:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800956:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80095a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80095d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800964:	85 c0                	test   %eax,%eax
  800966:	74 26                	je     80098e <vsnprintf+0x47>
  800968:	85 d2                	test   %edx,%edx
  80096a:	7e 22                	jle    80098e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80096c:	ff 75 14             	pushl  0x14(%ebp)
  80096f:	ff 75 10             	pushl  0x10(%ebp)
  800972:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800975:	50                   	push   %eax
  800976:	68 16 05 80 00       	push   $0x800516
  80097b:	e8 d0 fb ff ff       	call   800550 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800980:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800983:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800986:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800989:	83 c4 10             	add    $0x10,%esp
  80098c:	eb 05                	jmp    800993 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80098e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80099b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80099e:	50                   	push   %eax
  80099f:	ff 75 10             	pushl  0x10(%ebp)
  8009a2:	ff 75 0c             	pushl  0xc(%ebp)
  8009a5:	ff 75 08             	pushl  0x8(%ebp)
  8009a8:	e8 9a ff ff ff       	call   800947 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	eb 03                	jmp    8009bf <strlen+0x10>
		n++;
  8009bc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009bf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c3:	75 f7                	jne    8009bc <strlen+0xd>
		n++;
	return n;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d5:	eb 03                	jmp    8009da <strnlen+0x13>
		n++;
  8009d7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009da:	39 c2                	cmp    %eax,%edx
  8009dc:	74 08                	je     8009e6 <strnlen+0x1f>
  8009de:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009e2:	75 f3                	jne    8009d7 <strnlen+0x10>
  8009e4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	53                   	push   %ebx
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f2:	89 c2                	mov    %eax,%edx
  8009f4:	83 c2 01             	add    $0x1,%edx
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009fe:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a01:	84 db                	test   %bl,%bl
  800a03:	75 ef                	jne    8009f4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a05:	5b                   	pop    %ebx
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	53                   	push   %ebx
  800a0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a0f:	53                   	push   %ebx
  800a10:	e8 9a ff ff ff       	call   8009af <strlen>
  800a15:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a18:	ff 75 0c             	pushl  0xc(%ebp)
  800a1b:	01 d8                	add    %ebx,%eax
  800a1d:	50                   	push   %eax
  800a1e:	e8 c5 ff ff ff       	call   8009e8 <strcpy>
	return dst;
}
  800a23:	89 d8                	mov    %ebx,%eax
  800a25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a35:	89 f3                	mov    %esi,%ebx
  800a37:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3a:	89 f2                	mov    %esi,%edx
  800a3c:	eb 0f                	jmp    800a4d <strncpy+0x23>
		*dst++ = *src;
  800a3e:	83 c2 01             	add    $0x1,%edx
  800a41:	0f b6 01             	movzbl (%ecx),%eax
  800a44:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a47:	80 39 01             	cmpb   $0x1,(%ecx)
  800a4a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a4d:	39 da                	cmp    %ebx,%edx
  800a4f:	75 ed                	jne    800a3e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a51:	89 f0                	mov    %esi,%eax
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a62:	8b 55 10             	mov    0x10(%ebp),%edx
  800a65:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a67:	85 d2                	test   %edx,%edx
  800a69:	74 21                	je     800a8c <strlcpy+0x35>
  800a6b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a6f:	89 f2                	mov    %esi,%edx
  800a71:	eb 09                	jmp    800a7c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	83 c1 01             	add    $0x1,%ecx
  800a79:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a7c:	39 c2                	cmp    %eax,%edx
  800a7e:	74 09                	je     800a89 <strlcpy+0x32>
  800a80:	0f b6 19             	movzbl (%ecx),%ebx
  800a83:	84 db                	test   %bl,%bl
  800a85:	75 ec                	jne    800a73 <strlcpy+0x1c>
  800a87:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a89:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a8c:	29 f0                	sub    %esi,%eax
}
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a9b:	eb 06                	jmp    800aa3 <strcmp+0x11>
		p++, q++;
  800a9d:	83 c1 01             	add    $0x1,%ecx
  800aa0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa3:	0f b6 01             	movzbl (%ecx),%eax
  800aa6:	84 c0                	test   %al,%al
  800aa8:	74 04                	je     800aae <strcmp+0x1c>
  800aaa:	3a 02                	cmp    (%edx),%al
  800aac:	74 ef                	je     800a9d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aae:	0f b6 c0             	movzbl %al,%eax
  800ab1:	0f b6 12             	movzbl (%edx),%edx
  800ab4:	29 d0                	sub    %edx,%eax
}
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	53                   	push   %ebx
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac2:	89 c3                	mov    %eax,%ebx
  800ac4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac7:	eb 06                	jmp    800acf <strncmp+0x17>
		n--, p++, q++;
  800ac9:	83 c0 01             	add    $0x1,%eax
  800acc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800acf:	39 d8                	cmp    %ebx,%eax
  800ad1:	74 15                	je     800ae8 <strncmp+0x30>
  800ad3:	0f b6 08             	movzbl (%eax),%ecx
  800ad6:	84 c9                	test   %cl,%cl
  800ad8:	74 04                	je     800ade <strncmp+0x26>
  800ada:	3a 0a                	cmp    (%edx),%cl
  800adc:	74 eb                	je     800ac9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ade:	0f b6 00             	movzbl (%eax),%eax
  800ae1:	0f b6 12             	movzbl (%edx),%edx
  800ae4:	29 d0                	sub    %edx,%eax
  800ae6:	eb 05                	jmp    800aed <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afa:	eb 07                	jmp    800b03 <strchr+0x13>
		if (*s == c)
  800afc:	38 ca                	cmp    %cl,%dl
  800afe:	74 0f                	je     800b0f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	0f b6 10             	movzbl (%eax),%edx
  800b06:	84 d2                	test   %dl,%dl
  800b08:	75 f2                	jne    800afc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b1b:	eb 03                	jmp    800b20 <strfind+0xf>
  800b1d:	83 c0 01             	add    $0x1,%eax
  800b20:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b23:	38 ca                	cmp    %cl,%dl
  800b25:	74 04                	je     800b2b <strfind+0x1a>
  800b27:	84 d2                	test   %dl,%dl
  800b29:	75 f2                	jne    800b1d <strfind+0xc>
			break;
	return (char *) s;
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b39:	85 c9                	test   %ecx,%ecx
  800b3b:	74 36                	je     800b73 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b43:	75 28                	jne    800b6d <memset+0x40>
  800b45:	f6 c1 03             	test   $0x3,%cl
  800b48:	75 23                	jne    800b6d <memset+0x40>
		c &= 0xFF;
  800b4a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	c1 e3 08             	shl    $0x8,%ebx
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	c1 e6 18             	shl    $0x18,%esi
  800b58:	89 d0                	mov    %edx,%eax
  800b5a:	c1 e0 10             	shl    $0x10,%eax
  800b5d:	09 f0                	or     %esi,%eax
  800b5f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b61:	89 d8                	mov    %ebx,%eax
  800b63:	09 d0                	or     %edx,%eax
  800b65:	c1 e9 02             	shr    $0x2,%ecx
  800b68:	fc                   	cld    
  800b69:	f3 ab                	rep stos %eax,%es:(%edi)
  800b6b:	eb 06                	jmp    800b73 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b70:	fc                   	cld    
  800b71:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b73:	89 f8                	mov    %edi,%eax
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b88:	39 c6                	cmp    %eax,%esi
  800b8a:	73 35                	jae    800bc1 <memmove+0x47>
  800b8c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b8f:	39 d0                	cmp    %edx,%eax
  800b91:	73 2e                	jae    800bc1 <memmove+0x47>
		s += n;
		d += n;
  800b93:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	09 fe                	or     %edi,%esi
  800b9a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba0:	75 13                	jne    800bb5 <memmove+0x3b>
  800ba2:	f6 c1 03             	test   $0x3,%cl
  800ba5:	75 0e                	jne    800bb5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ba7:	83 ef 04             	sub    $0x4,%edi
  800baa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bad:	c1 e9 02             	shr    $0x2,%ecx
  800bb0:	fd                   	std    
  800bb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb3:	eb 09                	jmp    800bbe <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb5:	83 ef 01             	sub    $0x1,%edi
  800bb8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bbb:	fd                   	std    
  800bbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bbe:	fc                   	cld    
  800bbf:	eb 1d                	jmp    800bde <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc1:	89 f2                	mov    %esi,%edx
  800bc3:	09 c2                	or     %eax,%edx
  800bc5:	f6 c2 03             	test   $0x3,%dl
  800bc8:	75 0f                	jne    800bd9 <memmove+0x5f>
  800bca:	f6 c1 03             	test   $0x3,%cl
  800bcd:	75 0a                	jne    800bd9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bcf:	c1 e9 02             	shr    $0x2,%ecx
  800bd2:	89 c7                	mov    %eax,%edi
  800bd4:	fc                   	cld    
  800bd5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd7:	eb 05                	jmp    800bde <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	fc                   	cld    
  800bdc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800be5:	ff 75 10             	pushl  0x10(%ebp)
  800be8:	ff 75 0c             	pushl  0xc(%ebp)
  800beb:	ff 75 08             	pushl  0x8(%ebp)
  800bee:	e8 87 ff ff ff       	call   800b7a <memmove>
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c00:	89 c6                	mov    %eax,%esi
  800c02:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c05:	eb 1a                	jmp    800c21 <memcmp+0x2c>
		if (*s1 != *s2)
  800c07:	0f b6 08             	movzbl (%eax),%ecx
  800c0a:	0f b6 1a             	movzbl (%edx),%ebx
  800c0d:	38 d9                	cmp    %bl,%cl
  800c0f:	74 0a                	je     800c1b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c11:	0f b6 c1             	movzbl %cl,%eax
  800c14:	0f b6 db             	movzbl %bl,%ebx
  800c17:	29 d8                	sub    %ebx,%eax
  800c19:	eb 0f                	jmp    800c2a <memcmp+0x35>
		s1++, s2++;
  800c1b:	83 c0 01             	add    $0x1,%eax
  800c1e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c21:	39 f0                	cmp    %esi,%eax
  800c23:	75 e2                	jne    800c07 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	53                   	push   %ebx
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c35:	89 c1                	mov    %eax,%ecx
  800c37:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c3e:	eb 0a                	jmp    800c4a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c40:	0f b6 10             	movzbl (%eax),%edx
  800c43:	39 da                	cmp    %ebx,%edx
  800c45:	74 07                	je     800c4e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c47:	83 c0 01             	add    $0x1,%eax
  800c4a:	39 c8                	cmp    %ecx,%eax
  800c4c:	72 f2                	jb     800c40 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5d:	eb 03                	jmp    800c62 <strtol+0x11>
		s++;
  800c5f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c62:	0f b6 01             	movzbl (%ecx),%eax
  800c65:	3c 20                	cmp    $0x20,%al
  800c67:	74 f6                	je     800c5f <strtol+0xe>
  800c69:	3c 09                	cmp    $0x9,%al
  800c6b:	74 f2                	je     800c5f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c6d:	3c 2b                	cmp    $0x2b,%al
  800c6f:	75 0a                	jne    800c7b <strtol+0x2a>
		s++;
  800c71:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c74:	bf 00 00 00 00       	mov    $0x0,%edi
  800c79:	eb 11                	jmp    800c8c <strtol+0x3b>
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c80:	3c 2d                	cmp    $0x2d,%al
  800c82:	75 08                	jne    800c8c <strtol+0x3b>
		s++, neg = 1;
  800c84:	83 c1 01             	add    $0x1,%ecx
  800c87:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c92:	75 15                	jne    800ca9 <strtol+0x58>
  800c94:	80 39 30             	cmpb   $0x30,(%ecx)
  800c97:	75 10                	jne    800ca9 <strtol+0x58>
  800c99:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c9d:	75 7c                	jne    800d1b <strtol+0xca>
		s += 2, base = 16;
  800c9f:	83 c1 02             	add    $0x2,%ecx
  800ca2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca7:	eb 16                	jmp    800cbf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ca9:	85 db                	test   %ebx,%ebx
  800cab:	75 12                	jne    800cbf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cad:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb2:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb5:	75 08                	jne    800cbf <strtol+0x6e>
		s++, base = 8;
  800cb7:	83 c1 01             	add    $0x1,%ecx
  800cba:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc7:	0f b6 11             	movzbl (%ecx),%edx
  800cca:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ccd:	89 f3                	mov    %esi,%ebx
  800ccf:	80 fb 09             	cmp    $0x9,%bl
  800cd2:	77 08                	ja     800cdc <strtol+0x8b>
			dig = *s - '0';
  800cd4:	0f be d2             	movsbl %dl,%edx
  800cd7:	83 ea 30             	sub    $0x30,%edx
  800cda:	eb 22                	jmp    800cfe <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cdc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cdf:	89 f3                	mov    %esi,%ebx
  800ce1:	80 fb 19             	cmp    $0x19,%bl
  800ce4:	77 08                	ja     800cee <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ce6:	0f be d2             	movsbl %dl,%edx
  800ce9:	83 ea 57             	sub    $0x57,%edx
  800cec:	eb 10                	jmp    800cfe <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cee:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf1:	89 f3                	mov    %esi,%ebx
  800cf3:	80 fb 19             	cmp    $0x19,%bl
  800cf6:	77 16                	ja     800d0e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cf8:	0f be d2             	movsbl %dl,%edx
  800cfb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cfe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d01:	7d 0b                	jge    800d0e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d03:	83 c1 01             	add    $0x1,%ecx
  800d06:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d0a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d0c:	eb b9                	jmp    800cc7 <strtol+0x76>

	if (endptr)
  800d0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d12:	74 0d                	je     800d21 <strtol+0xd0>
		*endptr = (char *) s;
  800d14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d17:	89 0e                	mov    %ecx,(%esi)
  800d19:	eb 06                	jmp    800d21 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d1b:	85 db                	test   %ebx,%ebx
  800d1d:	74 98                	je     800cb7 <strtol+0x66>
  800d1f:	eb 9e                	jmp    800cbf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d21:	89 c2                	mov    %eax,%edx
  800d23:	f7 da                	neg    %edx
  800d25:	85 ff                	test   %edi,%edi
  800d27:	0f 45 c2             	cmovne %edx,%eax
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  800d35:	68 44 13 80 00       	push   $0x801344
  800d3a:	e8 da f6 ff ff       	call   800419 <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d49:	0f 85 8d 00 00 00    	jne    800ddc <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	68 64 13 80 00       	push   $0x801364
  800d57:	e8 bd f6 ff ff       	call   800419 <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  800d5c:	a1 04 20 80 00       	mov    0x802004,%eax
  800d61:	8b 40 48             	mov    0x48(%eax),%eax
  800d64:	83 c4 0c             	add    $0xc,%esp
  800d67:	6a 07                	push   $0x7
  800d69:	68 00 f0 bf ee       	push   $0xeebff000
  800d6e:	50                   	push   %eax
  800d6f:	e8 f4 f3 ff ff       	call   800168 <sys_page_alloc>
		if(retv != 0){
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	74 14                	je     800d8f <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	68 88 13 80 00       	push   $0x801388
  800d83:	6a 27                	push   $0x27
  800d85:	68 dc 13 80 00       	push   $0x8013dc
  800d8a:	e8 b1 f5 ff ff       	call   800340 <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  800d8f:	83 ec 08             	sub    $0x8,%esp
  800d92:	68 17 03 80 00       	push   $0x800317
  800d97:	68 ea 13 80 00       	push   $0x8013ea
  800d9c:	e8 78 f6 ff ff       	call   800419 <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  800da1:	a1 04 20 80 00       	mov    0x802004,%eax
  800da6:	8b 40 48             	mov    0x48(%eax),%eax
  800da9:	83 c4 08             	add    $0x8,%esp
  800dac:	50                   	push   %eax
  800dad:	68 05 14 80 00       	push   $0x801405
  800db2:	e8 62 f6 ff ff       	call   800419 <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800db7:	a1 04 20 80 00       	mov    0x802004,%eax
  800dbc:	8b 40 48             	mov    0x48(%eax),%eax
  800dbf:	83 c4 08             	add    $0x8,%esp
  800dc2:	68 17 03 80 00       	push   $0x800317
  800dc7:	50                   	push   %eax
  800dc8:	e8 a4 f4 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  800dcd:	c7 04 24 1c 14 80 00 	movl   $0x80141c,(%esp)
  800dd4:	e8 40 f6 ff ff       	call   800419 <cprintf>
  800dd9:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	68 b4 13 80 00       	push   $0x8013b4
  800de4:	e8 30 f6 ff ff       	call   800419 <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	a3 08 20 80 00       	mov    %eax,0x802008

}
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	c9                   	leave  
  800df5:	c3                   	ret    
  800df6:	66 90                	xchg   %ax,%ax
  800df8:	66 90                	xchg   %ax,%ax
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	66 90                	xchg   %ax,%ax
  800dfe:	66 90                	xchg   %ax,%ax

00800e00 <__udivdi3>:
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 1c             	sub    $0x1c,%esp
  800e07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e17:	85 f6                	test   %esi,%esi
  800e19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e1d:	89 ca                	mov    %ecx,%edx
  800e1f:	89 f8                	mov    %edi,%eax
  800e21:	75 3d                	jne    800e60 <__udivdi3+0x60>
  800e23:	39 cf                	cmp    %ecx,%edi
  800e25:	0f 87 c5 00 00 00    	ja     800ef0 <__udivdi3+0xf0>
  800e2b:	85 ff                	test   %edi,%edi
  800e2d:	89 fd                	mov    %edi,%ebp
  800e2f:	75 0b                	jne    800e3c <__udivdi3+0x3c>
  800e31:	b8 01 00 00 00       	mov    $0x1,%eax
  800e36:	31 d2                	xor    %edx,%edx
  800e38:	f7 f7                	div    %edi
  800e3a:	89 c5                	mov    %eax,%ebp
  800e3c:	89 c8                	mov    %ecx,%eax
  800e3e:	31 d2                	xor    %edx,%edx
  800e40:	f7 f5                	div    %ebp
  800e42:	89 c1                	mov    %eax,%ecx
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	89 cf                	mov    %ecx,%edi
  800e48:	f7 f5                	div    %ebp
  800e4a:	89 c3                	mov    %eax,%ebx
  800e4c:	89 d8                	mov    %ebx,%eax
  800e4e:	89 fa                	mov    %edi,%edx
  800e50:	83 c4 1c             	add    $0x1c,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    
  800e58:	90                   	nop
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 ce                	cmp    %ecx,%esi
  800e62:	77 74                	ja     800ed8 <__udivdi3+0xd8>
  800e64:	0f bd fe             	bsr    %esi,%edi
  800e67:	83 f7 1f             	xor    $0x1f,%edi
  800e6a:	0f 84 98 00 00 00    	je     800f08 <__udivdi3+0x108>
  800e70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	89 c5                	mov    %eax,%ebp
  800e79:	29 fb                	sub    %edi,%ebx
  800e7b:	d3 e6                	shl    %cl,%esi
  800e7d:	89 d9                	mov    %ebx,%ecx
  800e7f:	d3 ed                	shr    %cl,%ebp
  800e81:	89 f9                	mov    %edi,%ecx
  800e83:	d3 e0                	shl    %cl,%eax
  800e85:	09 ee                	or     %ebp,%esi
  800e87:	89 d9                	mov    %ebx,%ecx
  800e89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e8d:	89 d5                	mov    %edx,%ebp
  800e8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e93:	d3 ed                	shr    %cl,%ebp
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	d3 e2                	shl    %cl,%edx
  800e99:	89 d9                	mov    %ebx,%ecx
  800e9b:	d3 e8                	shr    %cl,%eax
  800e9d:	09 c2                	or     %eax,%edx
  800e9f:	89 d0                	mov    %edx,%eax
  800ea1:	89 ea                	mov    %ebp,%edx
  800ea3:	f7 f6                	div    %esi
  800ea5:	89 d5                	mov    %edx,%ebp
  800ea7:	89 c3                	mov    %eax,%ebx
  800ea9:	f7 64 24 0c          	mull   0xc(%esp)
  800ead:	39 d5                	cmp    %edx,%ebp
  800eaf:	72 10                	jb     800ec1 <__udivdi3+0xc1>
  800eb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800eb5:	89 f9                	mov    %edi,%ecx
  800eb7:	d3 e6                	shl    %cl,%esi
  800eb9:	39 c6                	cmp    %eax,%esi
  800ebb:	73 07                	jae    800ec4 <__udivdi3+0xc4>
  800ebd:	39 d5                	cmp    %edx,%ebp
  800ebf:	75 03                	jne    800ec4 <__udivdi3+0xc4>
  800ec1:	83 eb 01             	sub    $0x1,%ebx
  800ec4:	31 ff                	xor    %edi,%edi
  800ec6:	89 d8                	mov    %ebx,%eax
  800ec8:	89 fa                	mov    %edi,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	31 ff                	xor    %edi,%edi
  800eda:	31 db                	xor    %ebx,%ebx
  800edc:	89 d8                	mov    %ebx,%eax
  800ede:	89 fa                	mov    %edi,%edx
  800ee0:	83 c4 1c             	add    $0x1c,%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    
  800ee8:	90                   	nop
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	f7 f7                	div    %edi
  800ef4:	31 ff                	xor    %edi,%edi
  800ef6:	89 c3                	mov    %eax,%ebx
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	89 fa                	mov    %edi,%edx
  800efc:	83 c4 1c             	add    $0x1c,%esp
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	39 ce                	cmp    %ecx,%esi
  800f0a:	72 0c                	jb     800f18 <__udivdi3+0x118>
  800f0c:	31 db                	xor    %ebx,%ebx
  800f0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f12:	0f 87 34 ff ff ff    	ja     800e4c <__udivdi3+0x4c>
  800f18:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f1d:	e9 2a ff ff ff       	jmp    800e4c <__udivdi3+0x4c>
  800f22:	66 90                	xchg   %ax,%ax
  800f24:	66 90                	xchg   %ax,%ax
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__umoddi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 1c             	sub    $0x1c,%esp
  800f37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f47:	85 d2                	test   %edx,%edx
  800f49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f51:	89 f3                	mov    %esi,%ebx
  800f53:	89 3c 24             	mov    %edi,(%esp)
  800f56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f5a:	75 1c                	jne    800f78 <__umoddi3+0x48>
  800f5c:	39 f7                	cmp    %esi,%edi
  800f5e:	76 50                	jbe    800fb0 <__umoddi3+0x80>
  800f60:	89 c8                	mov    %ecx,%eax
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	f7 f7                	div    %edi
  800f66:	89 d0                	mov    %edx,%eax
  800f68:	31 d2                	xor    %edx,%edx
  800f6a:	83 c4 1c             	add    $0x1c,%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    
  800f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f78:	39 f2                	cmp    %esi,%edx
  800f7a:	89 d0                	mov    %edx,%eax
  800f7c:	77 52                	ja     800fd0 <__umoddi3+0xa0>
  800f7e:	0f bd ea             	bsr    %edx,%ebp
  800f81:	83 f5 1f             	xor    $0x1f,%ebp
  800f84:	75 5a                	jne    800fe0 <__umoddi3+0xb0>
  800f86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f8a:	0f 82 e0 00 00 00    	jb     801070 <__umoddi3+0x140>
  800f90:	39 0c 24             	cmp    %ecx,(%esp)
  800f93:	0f 86 d7 00 00 00    	jbe    801070 <__umoddi3+0x140>
  800f99:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fa1:	83 c4 1c             	add    $0x1c,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	85 ff                	test   %edi,%edi
  800fb2:	89 fd                	mov    %edi,%ebp
  800fb4:	75 0b                	jne    800fc1 <__umoddi3+0x91>
  800fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	f7 f7                	div    %edi
  800fbf:	89 c5                	mov    %eax,%ebp
  800fc1:	89 f0                	mov    %esi,%eax
  800fc3:	31 d2                	xor    %edx,%edx
  800fc5:	f7 f5                	div    %ebp
  800fc7:	89 c8                	mov    %ecx,%eax
  800fc9:	f7 f5                	div    %ebp
  800fcb:	89 d0                	mov    %edx,%eax
  800fcd:	eb 99                	jmp    800f68 <__umoddi3+0x38>
  800fcf:	90                   	nop
  800fd0:	89 c8                	mov    %ecx,%eax
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	83 c4 1c             	add    $0x1c,%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5f                   	pop    %edi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    
  800fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	8b 34 24             	mov    (%esp),%esi
  800fe3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fe8:	89 e9                	mov    %ebp,%ecx
  800fea:	29 ef                	sub    %ebp,%edi
  800fec:	d3 e0                	shl    %cl,%eax
  800fee:	89 f9                	mov    %edi,%ecx
  800ff0:	89 f2                	mov    %esi,%edx
  800ff2:	d3 ea                	shr    %cl,%edx
  800ff4:	89 e9                	mov    %ebp,%ecx
  800ff6:	09 c2                	or     %eax,%edx
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	89 14 24             	mov    %edx,(%esp)
  800ffd:	89 f2                	mov    %esi,%edx
  800fff:	d3 e2                	shl    %cl,%edx
  801001:	89 f9                	mov    %edi,%ecx
  801003:	89 54 24 04          	mov    %edx,0x4(%esp)
  801007:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	89 e9                	mov    %ebp,%ecx
  80100f:	89 c6                	mov    %eax,%esi
  801011:	d3 e3                	shl    %cl,%ebx
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 d0                	mov    %edx,%eax
  801017:	d3 e8                	shr    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	09 d8                	or     %ebx,%eax
  80101d:	89 d3                	mov    %edx,%ebx
  80101f:	89 f2                	mov    %esi,%edx
  801021:	f7 34 24             	divl   (%esp)
  801024:	89 d6                	mov    %edx,%esi
  801026:	d3 e3                	shl    %cl,%ebx
  801028:	f7 64 24 04          	mull   0x4(%esp)
  80102c:	39 d6                	cmp    %edx,%esi
  80102e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801032:	89 d1                	mov    %edx,%ecx
  801034:	89 c3                	mov    %eax,%ebx
  801036:	72 08                	jb     801040 <__umoddi3+0x110>
  801038:	75 11                	jne    80104b <__umoddi3+0x11b>
  80103a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80103e:	73 0b                	jae    80104b <__umoddi3+0x11b>
  801040:	2b 44 24 04          	sub    0x4(%esp),%eax
  801044:	1b 14 24             	sbb    (%esp),%edx
  801047:	89 d1                	mov    %edx,%ecx
  801049:	89 c3                	mov    %eax,%ebx
  80104b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80104f:	29 da                	sub    %ebx,%edx
  801051:	19 ce                	sbb    %ecx,%esi
  801053:	89 f9                	mov    %edi,%ecx
  801055:	89 f0                	mov    %esi,%eax
  801057:	d3 e0                	shl    %cl,%eax
  801059:	89 e9                	mov    %ebp,%ecx
  80105b:	d3 ea                	shr    %cl,%edx
  80105d:	89 e9                	mov    %ebp,%ecx
  80105f:	d3 ee                	shr    %cl,%esi
  801061:	09 d0                	or     %edx,%eax
  801063:	89 f2                	mov    %esi,%edx
  801065:	83 c4 1c             	add    $0x1c,%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	29 f9                	sub    %edi,%ecx
  801072:	19 d6                	sbb    %edx,%esi
  801074:	89 74 24 04          	mov    %esi,0x4(%esp)
  801078:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80107c:	e9 18 ff ff ff       	jmp    800f99 <__umoddi3+0x69>
