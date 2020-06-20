
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 e0 	movl   $0x801de0,0x803000
  800040:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 87 04 00 00       	call   800522 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 ef 1d 80 00       	push   $0x801def
  800114:	6a 23                	push   $0x23
  800116:	68 0c 1e 80 00       	push   $0x801e0c
  80011b:	e8 1a 0f 00 00       	call   80103a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 ef 1d 80 00       	push   $0x801def
  800195:	6a 23                	push   $0x23
  800197:	68 0c 1e 80 00       	push   $0x801e0c
  80019c:	e8 99 0e 00 00       	call   80103a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 ef 1d 80 00       	push   $0x801def
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 0c 1e 80 00       	push   $0x801e0c
  8001de:	e8 57 0e 00 00       	call   80103a <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 ef 1d 80 00       	push   $0x801def
  800219:	6a 23                	push   $0x23
  80021b:	68 0c 1e 80 00       	push   $0x801e0c
  800220:	e8 15 0e 00 00       	call   80103a <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 ef 1d 80 00       	push   $0x801def
  80025b:	6a 23                	push   $0x23
  80025d:	68 0c 1e 80 00       	push   $0x801e0c
  800262:	e8 d3 0d 00 00       	call   80103a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 ef 1d 80 00       	push   $0x801def
  80029d:	6a 23                	push   $0x23
  80029f:	68 0c 1e 80 00       	push   $0x801e0c
  8002a4:	e8 91 0d 00 00       	call   80103a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 ef 1d 80 00       	push   $0x801def
  8002df:	6a 23                	push   $0x23
  8002e1:	68 0c 1e 80 00       	push   $0x801e0c
  8002e6:	e8 4f 0d 00 00       	call   80103a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 ef 1d 80 00       	push   $0x801def
  800343:	6a 23                	push   $0x23
  800345:	68 0c 1e 80 00       	push   $0x801e0c
  80034a:	e8 eb 0c 00 00       	call   80103a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 98 1e 80 00       	mov    $0x801e98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 1c 1e 80 00       	push   $0x801e1c
  80045e:	e8 b0 0c 00 00       	call   801113 <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 5d 1e 80 00       	push   $0x801e5d
  800688:	e8 86 0a 00 00       	call   801113 <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 79 1e 80 00       	push   $0x801e79
  80075d:	e8 b1 09 00 00       	call   801113 <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 3c 1e 80 00       	push   $0x801e3c
  800812:	e8 fc 08 00 00       	call   801113 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 dc 01 00 00       	call   800ab7 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 a7 11 00 00       	call   801ac9 <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 49 11 00 00       	call   801a86 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 df 10 00 00       	call   801a29 <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 0f 0d 00 00       	call   8016e2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800a02:	8b 52 0c             	mov    0xc(%edx),%edx
  800a05:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a0b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a10:	50                   	push   %eax
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	68 08 50 80 00       	push   $0x805008
  800a19:	e8 56 0e 00 00       	call   801874 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	b8 04 00 00 00       	mov    $0x4,%eax
  800a28:	e8 d9 fe ff ff       	call   800906 <fsipc>
	//panic("devfile_write not implemented");
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a42:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a52:	e8 af fe ff ff       	call   800906 <fsipc>
  800a57:	89 c3                	mov    %eax,%ebx
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	78 51                	js     800aae <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a5d:	39 c6                	cmp    %eax,%esi
  800a5f:	73 19                	jae    800a7a <devfile_read+0x4b>
  800a61:	68 a8 1e 80 00       	push   $0x801ea8
  800a66:	68 af 1e 80 00       	push   $0x801eaf
  800a6b:	68 80 00 00 00       	push   $0x80
  800a70:	68 c4 1e 80 00       	push   $0x801ec4
  800a75:	e8 c0 05 00 00       	call   80103a <_panic>
	assert(r <= PGSIZE);
  800a7a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7f:	7e 19                	jle    800a9a <devfile_read+0x6b>
  800a81:	68 cf 1e 80 00       	push   $0x801ecf
  800a86:	68 af 1e 80 00       	push   $0x801eaf
  800a8b:	68 81 00 00 00       	push   $0x81
  800a90:	68 c4 1e 80 00       	push   $0x801ec4
  800a95:	e8 a0 05 00 00       	call   80103a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a9a:	83 ec 04             	sub    $0x4,%esp
  800a9d:	50                   	push   %eax
  800a9e:	68 00 50 80 00       	push   $0x805000
  800aa3:	ff 75 0c             	pushl  0xc(%ebp)
  800aa6:	e8 c9 0d 00 00       	call   801874 <memmove>
	return r;
  800aab:	83 c4 10             	add    $0x10,%esp
}
  800aae:	89 d8                	mov    %ebx,%eax
  800ab0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	83 ec 20             	sub    $0x20,%esp
  800abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac1:	53                   	push   %ebx
  800ac2:	e8 e2 0b 00 00       	call   8016a9 <strlen>
  800ac7:	83 c4 10             	add    $0x10,%esp
  800aca:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800acf:	7f 67                	jg     800b38 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad1:	83 ec 0c             	sub    $0xc,%esp
  800ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad7:	50                   	push   %eax
  800ad8:	e8 a1 f8 ff ff       	call   80037e <fd_alloc>
  800add:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	78 57                	js     800b3d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	53                   	push   %ebx
  800aea:	68 00 50 80 00       	push   $0x805000
  800aef:	e8 ee 0b 00 00       	call   8016e2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800afc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aff:	b8 01 00 00 00       	mov    $0x1,%eax
  800b04:	e8 fd fd ff ff       	call   800906 <fsipc>
  800b09:	89 c3                	mov    %eax,%ebx
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	79 14                	jns    800b26 <open+0x6f>
		
		fd_close(fd, 0);
  800b12:	83 ec 08             	sub    $0x8,%esp
  800b15:	6a 00                	push   $0x0
  800b17:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1a:	e8 57 f9 ff ff       	call   800476 <fd_close>
		return r;
  800b1f:	83 c4 10             	add    $0x10,%esp
  800b22:	89 da                	mov    %ebx,%edx
  800b24:	eb 17                	jmp    800b3d <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2c:	e8 26 f8 ff ff       	call   800357 <fd2num>
  800b31:	89 c2                	mov    %eax,%edx
  800b33:	83 c4 10             	add    $0x10,%esp
  800b36:	eb 05                	jmp    800b3d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b38:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  800b3d:	89 d0                	mov    %edx,%eax
  800b3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b54:	e8 ad fd ff ff       	call   800906 <fsipc>
}
  800b59:	c9                   	leave  
  800b5a:	c3                   	ret    

00800b5b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	ff 75 08             	pushl  0x8(%ebp)
  800b69:	e8 f9 f7 ff ff       	call   800367 <fd2data>
  800b6e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b70:	83 c4 08             	add    $0x8,%esp
  800b73:	68 db 1e 80 00       	push   $0x801edb
  800b78:	53                   	push   %ebx
  800b79:	e8 64 0b 00 00       	call   8016e2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7e:	8b 46 04             	mov    0x4(%esi),%eax
  800b81:	2b 06                	sub    (%esi),%eax
  800b83:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b89:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b90:	00 00 00 
	stat->st_dev = &devpipe;
  800b93:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b9a:	30 80 00 
	return 0;
}
  800b9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb3:	53                   	push   %ebx
  800bb4:	6a 00                	push   $0x0
  800bb6:	e8 30 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bbb:	89 1c 24             	mov    %ebx,(%esp)
  800bbe:	e8 a4 f7 ff ff       	call   800367 <fd2data>
  800bc3:	83 c4 08             	add    $0x8,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 00                	push   $0x0
  800bc9:	e8 1d f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800bce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    

00800bd3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 1c             	sub    $0x1c,%esp
  800bdc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bdf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be1:	a1 04 40 80 00       	mov    0x804004,%eax
  800be6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	ff 75 e0             	pushl  -0x20(%ebp)
  800bef:	e8 0e 0f 00 00       	call   801b02 <pageref>
  800bf4:	89 c3                	mov    %eax,%ebx
  800bf6:	89 3c 24             	mov    %edi,(%esp)
  800bf9:	e8 04 0f 00 00       	call   801b02 <pageref>
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	39 c3                	cmp    %eax,%ebx
  800c03:	0f 94 c1             	sete   %cl
  800c06:	0f b6 c9             	movzbl %cl,%ecx
  800c09:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c0c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c12:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c15:	39 ce                	cmp    %ecx,%esi
  800c17:	74 1b                	je     800c34 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c19:	39 c3                	cmp    %eax,%ebx
  800c1b:	75 c4                	jne    800be1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1d:	8b 42 58             	mov    0x58(%edx),%eax
  800c20:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c23:	50                   	push   %eax
  800c24:	56                   	push   %esi
  800c25:	68 e2 1e 80 00       	push   $0x801ee2
  800c2a:	e8 e4 04 00 00       	call   801113 <cprintf>
  800c2f:	83 c4 10             	add    $0x10,%esp
  800c32:	eb ad                	jmp    800be1 <_pipeisclosed+0xe>
	}
}
  800c34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 28             	sub    $0x28,%esp
  800c48:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c4b:	56                   	push   %esi
  800c4c:	e8 16 f7 ff ff       	call   800367 <fd2data>
  800c51:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c53:	83 c4 10             	add    $0x10,%esp
  800c56:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5b:	eb 4b                	jmp    800ca8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c5d:	89 da                	mov    %ebx,%edx
  800c5f:	89 f0                	mov    %esi,%eax
  800c61:	e8 6d ff ff ff       	call   800bd3 <_pipeisclosed>
  800c66:	85 c0                	test   %eax,%eax
  800c68:	75 48                	jne    800cb2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c6a:	e8 d8 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c72:	8b 0b                	mov    (%ebx),%ecx
  800c74:	8d 51 20             	lea    0x20(%ecx),%edx
  800c77:	39 d0                	cmp    %edx,%eax
  800c79:	73 e2                	jae    800c5d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c82:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c85:	89 c2                	mov    %eax,%edx
  800c87:	c1 fa 1f             	sar    $0x1f,%edx
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c92:	83 e2 1f             	and    $0x1f,%edx
  800c95:	29 ca                	sub    %ecx,%edx
  800c97:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c9b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9f:	83 c0 01             	add    $0x1,%eax
  800ca2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca5:	83 c7 01             	add    $0x1,%edi
  800ca8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cab:	75 c2                	jne    800c6f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cad:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb0:	eb 05                	jmp    800cb7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 18             	sub    $0x18,%esp
  800cc8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ccb:	57                   	push   %edi
  800ccc:	e8 96 f6 ff ff       	call   800367 <fd2data>
  800cd1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd3:	83 c4 10             	add    $0x10,%esp
  800cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdb:	eb 3d                	jmp    800d1a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cdd:	85 db                	test   %ebx,%ebx
  800cdf:	74 04                	je     800ce5 <devpipe_read+0x26>
				return i;
  800ce1:	89 d8                	mov    %ebx,%eax
  800ce3:	eb 44                	jmp    800d29 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	89 f8                	mov    %edi,%eax
  800ce9:	e8 e5 fe ff ff       	call   800bd3 <_pipeisclosed>
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	75 32                	jne    800d24 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf2:	e8 50 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf7:	8b 06                	mov    (%esi),%eax
  800cf9:	3b 46 04             	cmp    0x4(%esi),%eax
  800cfc:	74 df                	je     800cdd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cfe:	99                   	cltd   
  800cff:	c1 ea 1b             	shr    $0x1b,%edx
  800d02:	01 d0                	add    %edx,%eax
  800d04:	83 e0 1f             	and    $0x1f,%eax
  800d07:	29 d0                	sub    %edx,%eax
  800d09:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d14:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d17:	83 c3 01             	add    $0x1,%ebx
  800d1a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d1d:	75 d8                	jne    800cf7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d22:	eb 05                	jmp    800d29 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d24:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d3c:	50                   	push   %eax
  800d3d:	e8 3c f6 ff ff       	call   80037e <fd_alloc>
  800d42:	83 c4 10             	add    $0x10,%esp
  800d45:	89 c2                	mov    %eax,%edx
  800d47:	85 c0                	test   %eax,%eax
  800d49:	0f 88 2c 01 00 00    	js     800e7b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4f:	83 ec 04             	sub    $0x4,%esp
  800d52:	68 07 04 00 00       	push   $0x407
  800d57:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5a:	6a 00                	push   $0x0
  800d5c:	e8 05 f4 ff ff       	call   800166 <sys_page_alloc>
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	89 c2                	mov    %eax,%edx
  800d66:	85 c0                	test   %eax,%eax
  800d68:	0f 88 0d 01 00 00    	js     800e7b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d6e:	83 ec 0c             	sub    $0xc,%esp
  800d71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d74:	50                   	push   %eax
  800d75:	e8 04 f6 ff ff       	call   80037e <fd_alloc>
  800d7a:	89 c3                	mov    %eax,%ebx
  800d7c:	83 c4 10             	add    $0x10,%esp
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	0f 88 e2 00 00 00    	js     800e69 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d87:	83 ec 04             	sub    $0x4,%esp
  800d8a:	68 07 04 00 00       	push   $0x407
  800d8f:	ff 75 f0             	pushl  -0x10(%ebp)
  800d92:	6a 00                	push   $0x0
  800d94:	e8 cd f3 ff ff       	call   800166 <sys_page_alloc>
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	0f 88 c3 00 00 00    	js     800e69 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	ff 75 f4             	pushl  -0xc(%ebp)
  800dac:	e8 b6 f5 ff ff       	call   800367 <fd2data>
  800db1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db3:	83 c4 0c             	add    $0xc,%esp
  800db6:	68 07 04 00 00       	push   $0x407
  800dbb:	50                   	push   %eax
  800dbc:	6a 00                	push   $0x0
  800dbe:	e8 a3 f3 ff ff       	call   800166 <sys_page_alloc>
  800dc3:	89 c3                	mov    %eax,%ebx
  800dc5:	83 c4 10             	add    $0x10,%esp
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	0f 88 89 00 00 00    	js     800e59 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd6:	e8 8c f5 ff ff       	call   800367 <fd2data>
  800ddb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de2:	50                   	push   %eax
  800de3:	6a 00                	push   $0x0
  800de5:	56                   	push   %esi
  800de6:	6a 00                	push   $0x0
  800de8:	e8 bc f3 ff ff       	call   8001a9 <sys_page_map>
  800ded:	89 c3                	mov    %eax,%ebx
  800def:	83 c4 20             	add    $0x20,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	78 55                	js     800e4b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dff:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e04:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e0b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e14:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e19:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	ff 75 f4             	pushl  -0xc(%ebp)
  800e26:	e8 2c f5 ff ff       	call   800357 <fd2num>
  800e2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e30:	83 c4 04             	add    $0x4,%esp
  800e33:	ff 75 f0             	pushl  -0x10(%ebp)
  800e36:	e8 1c f5 ff ff       	call   800357 <fd2num>
  800e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	ba 00 00 00 00       	mov    $0x0,%edx
  800e49:	eb 30                	jmp    800e7b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	56                   	push   %esi
  800e4f:	6a 00                	push   $0x0
  800e51:	e8 95 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e56:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e59:	83 ec 08             	sub    $0x8,%esp
  800e5c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5f:	6a 00                	push   $0x0
  800e61:	e8 85 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e66:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6f:	6a 00                	push   $0x0
  800e71:	e8 75 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e7b:	89 d0                	mov    %edx,%eax
  800e7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8d:	50                   	push   %eax
  800e8e:	ff 75 08             	pushl  0x8(%ebp)
  800e91:	e8 37 f5 ff ff       	call   8003cd <fd_lookup>
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	78 18                	js     800eb5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e9d:	83 ec 0c             	sub    $0xc,%esp
  800ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea3:	e8 bf f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ead:	e8 21 fd ff ff       	call   800bd3 <_pipeisclosed>
  800eb2:	83 c4 10             	add    $0x10,%esp
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec7:	68 fa 1e 80 00       	push   $0x801efa
  800ecc:	ff 75 0c             	pushl  0xc(%ebp)
  800ecf:	e8 0e 08 00 00       	call   8016e2 <strcpy>
	return 0;
}
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eec:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef2:	eb 2d                	jmp    800f21 <devcons_write+0x46>
		m = n - tot;
  800ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800efc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f01:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f04:	83 ec 04             	sub    $0x4,%esp
  800f07:	53                   	push   %ebx
  800f08:	03 45 0c             	add    0xc(%ebp),%eax
  800f0b:	50                   	push   %eax
  800f0c:	57                   	push   %edi
  800f0d:	e8 62 09 00 00       	call   801874 <memmove>
		sys_cputs(buf, m);
  800f12:	83 c4 08             	add    $0x8,%esp
  800f15:	53                   	push   %ebx
  800f16:	57                   	push   %edi
  800f17:	e8 8e f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1c:	01 de                	add    %ebx,%esi
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	89 f0                	mov    %esi,%eax
  800f23:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f26:	72 cc                	jb     800ef4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 08             	sub    $0x8,%esp
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3f:	74 2a                	je     800f6b <devcons_read+0x3b>
  800f41:	eb 05                	jmp    800f48 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f43:	e8 ff f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f48:	e8 7b f1 ff ff       	call   8000c8 <sys_cgetc>
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	74 f2                	je     800f43 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f51:	85 c0                	test   %eax,%eax
  800f53:	78 16                	js     800f6b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f55:	83 f8 04             	cmp    $0x4,%eax
  800f58:	74 0c                	je     800f66 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5d:	88 02                	mov    %al,(%edx)
	return 1;
  800f5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f64:	eb 05                	jmp    800f6b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f79:	6a 01                	push   $0x1
  800f7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7e:	50                   	push   %eax
  800f7f:	e8 26 f1 ff ff       	call   8000aa <sys_cputs>
}
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	c9                   	leave  
  800f88:	c3                   	ret    

00800f89 <getchar>:

int
getchar(void)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f8f:	6a 01                	push   $0x1
  800f91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f94:	50                   	push   %eax
  800f95:	6a 00                	push   $0x0
  800f97:	e8 97 f6 ff ff       	call   800633 <read>
	if (r < 0)
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	78 0f                	js     800fb2 <getchar+0x29>
		return r;
	if (r < 1)
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	7e 06                	jle    800fad <getchar+0x24>
		return -E_EOF;
	return c;
  800fa7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fab:	eb 05                	jmp    800fb2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fad:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbd:	50                   	push   %eax
  800fbe:	ff 75 08             	pushl  0x8(%ebp)
  800fc1:	e8 07 f4 ff ff       	call   8003cd <fd_lookup>
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 11                	js     800fde <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd6:	39 10                	cmp    %edx,(%eax)
  800fd8:	0f 94 c0             	sete   %al
  800fdb:	0f b6 c0             	movzbl %al,%eax
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <opencons>:

int
opencons(void)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	e8 8f f3 ff ff       	call   80037e <fd_alloc>
  800fef:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 3e                	js     801036 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff8:	83 ec 04             	sub    $0x4,%esp
  800ffb:	68 07 04 00 00       	push   $0x407
  801000:	ff 75 f4             	pushl  -0xc(%ebp)
  801003:	6a 00                	push   $0x0
  801005:	e8 5c f1 ff ff       	call   800166 <sys_page_alloc>
  80100a:	83 c4 10             	add    $0x10,%esp
		return r;
  80100d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 23                	js     801036 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801013:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801021:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	50                   	push   %eax
  80102c:	e8 26 f3 ff ff       	call   800357 <fd2num>
  801031:	89 c2                	mov    %eax,%edx
  801033:	83 c4 10             	add    $0x10,%esp
}
  801036:	89 d0                	mov    %edx,%eax
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801042:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801048:	e8 db f0 ff ff       	call   800128 <sys_getenvid>
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	ff 75 0c             	pushl  0xc(%ebp)
  801053:	ff 75 08             	pushl  0x8(%ebp)
  801056:	56                   	push   %esi
  801057:	50                   	push   %eax
  801058:	68 08 1f 80 00       	push   $0x801f08
  80105d:	e8 b1 00 00 00       	call   801113 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801062:	83 c4 18             	add    $0x18,%esp
  801065:	53                   	push   %ebx
  801066:	ff 75 10             	pushl  0x10(%ebp)
  801069:	e8 54 00 00 00       	call   8010c2 <vcprintf>
	cprintf("\n");
  80106e:	c7 04 24 f3 1e 80 00 	movl   $0x801ef3,(%esp)
  801075:	e8 99 00 00 00       	call   801113 <cprintf>
  80107a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107d:	cc                   	int3   
  80107e:	eb fd                	jmp    80107d <_panic+0x43>

00801080 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	53                   	push   %ebx
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80108a:	8b 13                	mov    (%ebx),%edx
  80108c:	8d 42 01             	lea    0x1(%edx),%eax
  80108f:	89 03                	mov    %eax,(%ebx)
  801091:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801094:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801098:	3d ff 00 00 00       	cmp    $0xff,%eax
  80109d:	75 1a                	jne    8010b9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	68 ff 00 00 00       	push   $0xff
  8010a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8010aa:	50                   	push   %eax
  8010ab:	e8 fa ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8010cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d2:	00 00 00 
	b.cnt = 0;
  8010d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010df:	ff 75 0c             	pushl  0xc(%ebp)
  8010e2:	ff 75 08             	pushl  0x8(%ebp)
  8010e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010eb:	50                   	push   %eax
  8010ec:	68 80 10 80 00       	push   $0x801080
  8010f1:	e8 54 01 00 00       	call   80124a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f6:	83 c4 08             	add    $0x8,%esp
  8010f9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	e8 9f ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  80110b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801111:	c9                   	leave  
  801112:	c3                   	ret    

00801113 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801119:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80111c:	50                   	push   %eax
  80111d:	ff 75 08             	pushl  0x8(%ebp)
  801120:	e8 9d ff ff ff       	call   8010c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	57                   	push   %edi
  80112b:	56                   	push   %esi
  80112c:	53                   	push   %ebx
  80112d:	83 ec 1c             	sub    $0x1c,%esp
  801130:	89 c7                	mov    %eax,%edi
  801132:	89 d6                	mov    %edx,%esi
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801140:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801143:	bb 00 00 00 00       	mov    $0x0,%ebx
  801148:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80114b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114e:	39 d3                	cmp    %edx,%ebx
  801150:	72 05                	jb     801157 <printnum+0x30>
  801152:	39 45 10             	cmp    %eax,0x10(%ebp)
  801155:	77 45                	ja     80119c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	ff 75 18             	pushl  0x18(%ebp)
  80115d:	8b 45 14             	mov    0x14(%ebp),%eax
  801160:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801163:	53                   	push   %ebx
  801164:	ff 75 10             	pushl  0x10(%ebp)
  801167:	83 ec 08             	sub    $0x8,%esp
  80116a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116d:	ff 75 e0             	pushl  -0x20(%ebp)
  801170:	ff 75 dc             	pushl  -0x24(%ebp)
  801173:	ff 75 d8             	pushl  -0x28(%ebp)
  801176:	e8 c5 09 00 00       	call   801b40 <__udivdi3>
  80117b:	83 c4 18             	add    $0x18,%esp
  80117e:	52                   	push   %edx
  80117f:	50                   	push   %eax
  801180:	89 f2                	mov    %esi,%edx
  801182:	89 f8                	mov    %edi,%eax
  801184:	e8 9e ff ff ff       	call   801127 <printnum>
  801189:	83 c4 20             	add    $0x20,%esp
  80118c:	eb 18                	jmp    8011a6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	56                   	push   %esi
  801192:	ff 75 18             	pushl  0x18(%ebp)
  801195:	ff d7                	call   *%edi
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	eb 03                	jmp    80119f <printnum+0x78>
  80119c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80119f:	83 eb 01             	sub    $0x1,%ebx
  8011a2:	85 db                	test   %ebx,%ebx
  8011a4:	7f e8                	jg     80118e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	56                   	push   %esi
  8011aa:	83 ec 04             	sub    $0x4,%esp
  8011ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b9:	e8 b2 0a 00 00       	call   801c70 <__umoddi3>
  8011be:	83 c4 14             	add    $0x14,%esp
  8011c1:	0f be 80 2b 1f 80 00 	movsbl 0x801f2b(%eax),%eax
  8011c8:	50                   	push   %eax
  8011c9:	ff d7                	call   *%edi
}
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d9:	83 fa 01             	cmp    $0x1,%edx
  8011dc:	7e 0e                	jle    8011ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011de:	8b 10                	mov    (%eax),%edx
  8011e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011e3:	89 08                	mov    %ecx,(%eax)
  8011e5:	8b 02                	mov    (%edx),%eax
  8011e7:	8b 52 04             	mov    0x4(%edx),%edx
  8011ea:	eb 22                	jmp    80120e <getuint+0x38>
	else if (lflag)
  8011ec:	85 d2                	test   %edx,%edx
  8011ee:	74 10                	je     801200 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011f0:	8b 10                	mov    (%eax),%edx
  8011f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f5:	89 08                	mov    %ecx,(%eax)
  8011f7:	8b 02                	mov    (%edx),%eax
  8011f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fe:	eb 0e                	jmp    80120e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801200:	8b 10                	mov    (%eax),%edx
  801202:	8d 4a 04             	lea    0x4(%edx),%ecx
  801205:	89 08                	mov    %ecx,(%eax)
  801207:	8b 02                	mov    (%edx),%eax
  801209:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801216:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80121a:	8b 10                	mov    (%eax),%edx
  80121c:	3b 50 04             	cmp    0x4(%eax),%edx
  80121f:	73 0a                	jae    80122b <sprintputch+0x1b>
		*b->buf++ = ch;
  801221:	8d 4a 01             	lea    0x1(%edx),%ecx
  801224:	89 08                	mov    %ecx,(%eax)
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	88 02                	mov    %al,(%edx)
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801233:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801236:	50                   	push   %eax
  801237:	ff 75 10             	pushl  0x10(%ebp)
  80123a:	ff 75 0c             	pushl  0xc(%ebp)
  80123d:	ff 75 08             	pushl  0x8(%ebp)
  801240:	e8 05 00 00 00       	call   80124a <vprintfmt>
	va_end(ap);
}
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	c9                   	leave  
  801249:	c3                   	ret    

0080124a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	57                   	push   %edi
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	83 ec 2c             	sub    $0x2c,%esp
  801253:	8b 75 08             	mov    0x8(%ebp),%esi
  801256:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801259:	8b 7d 10             	mov    0x10(%ebp),%edi
  80125c:	eb 12                	jmp    801270 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80125e:	85 c0                	test   %eax,%eax
  801260:	0f 84 d3 03 00 00    	je     801639 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	53                   	push   %ebx
  80126a:	50                   	push   %eax
  80126b:	ff d6                	call   *%esi
  80126d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801270:	83 c7 01             	add    $0x1,%edi
  801273:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801277:	83 f8 25             	cmp    $0x25,%eax
  80127a:	75 e2                	jne    80125e <vprintfmt+0x14>
  80127c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801280:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801287:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80128e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801295:	ba 00 00 00 00       	mov    $0x0,%edx
  80129a:	eb 07                	jmp    8012a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80129f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a3:	8d 47 01             	lea    0x1(%edi),%eax
  8012a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a9:	0f b6 07             	movzbl (%edi),%eax
  8012ac:	0f b6 c8             	movzbl %al,%ecx
  8012af:	83 e8 23             	sub    $0x23,%eax
  8012b2:	3c 55                	cmp    $0x55,%al
  8012b4:	0f 87 64 03 00 00    	ja     80161e <vprintfmt+0x3d4>
  8012ba:	0f b6 c0             	movzbl %al,%eax
  8012bd:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8012c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012cb:	eb d6                	jmp    8012a3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012db:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012df:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012e2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012e5:	83 fa 09             	cmp    $0x9,%edx
  8012e8:	77 39                	ja     801323 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ea:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012ed:	eb e9                	jmp    8012d8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f2:	8d 48 04             	lea    0x4(%eax),%ecx
  8012f5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012f8:	8b 00                	mov    (%eax),%eax
  8012fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801300:	eb 27                	jmp    801329 <vprintfmt+0xdf>
  801302:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801305:	85 c0                	test   %eax,%eax
  801307:	b9 00 00 00 00       	mov    $0x0,%ecx
  80130c:	0f 49 c8             	cmovns %eax,%ecx
  80130f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801315:	eb 8c                	jmp    8012a3 <vprintfmt+0x59>
  801317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80131a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801321:	eb 80                	jmp    8012a3 <vprintfmt+0x59>
  801323:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801326:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  801329:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132d:	0f 89 70 ff ff ff    	jns    8012a3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801333:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801336:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801339:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801340:	e9 5e ff ff ff       	jmp    8012a3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801345:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80134b:	e9 53 ff ff ff       	jmp    8012a3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801350:	8b 45 14             	mov    0x14(%ebp),%eax
  801353:	8d 50 04             	lea    0x4(%eax),%edx
  801356:	89 55 14             	mov    %edx,0x14(%ebp)
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	53                   	push   %ebx
  80135d:	ff 30                	pushl  (%eax)
  80135f:	ff d6                	call   *%esi
			break;
  801361:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801367:	e9 04 ff ff ff       	jmp    801270 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136c:	8b 45 14             	mov    0x14(%ebp),%eax
  80136f:	8d 50 04             	lea    0x4(%eax),%edx
  801372:	89 55 14             	mov    %edx,0x14(%ebp)
  801375:	8b 00                	mov    (%eax),%eax
  801377:	99                   	cltd   
  801378:	31 d0                	xor    %edx,%eax
  80137a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80137c:	83 f8 0f             	cmp    $0xf,%eax
  80137f:	7f 0b                	jg     80138c <vprintfmt+0x142>
  801381:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801388:	85 d2                	test   %edx,%edx
  80138a:	75 18                	jne    8013a4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80138c:	50                   	push   %eax
  80138d:	68 43 1f 80 00       	push   $0x801f43
  801392:	53                   	push   %ebx
  801393:	56                   	push   %esi
  801394:	e8 94 fe ff ff       	call   80122d <printfmt>
  801399:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80139f:	e9 cc fe ff ff       	jmp    801270 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013a4:	52                   	push   %edx
  8013a5:	68 c1 1e 80 00       	push   $0x801ec1
  8013aa:	53                   	push   %ebx
  8013ab:	56                   	push   %esi
  8013ac:	e8 7c fe ff ff       	call   80122d <printfmt>
  8013b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013b7:	e9 b4 fe ff ff       	jmp    801270 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bf:	8d 50 04             	lea    0x4(%eax),%edx
  8013c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013c7:	85 ff                	test   %edi,%edi
  8013c9:	b8 3c 1f 80 00       	mov    $0x801f3c,%eax
  8013ce:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d5:	0f 8e 94 00 00 00    	jle    80146f <vprintfmt+0x225>
  8013db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013df:	0f 84 98 00 00 00    	je     80147d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	ff 75 c8             	pushl  -0x38(%ebp)
  8013eb:	57                   	push   %edi
  8013ec:	e8 d0 02 00 00       	call   8016c1 <strnlen>
  8013f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013f4:	29 c1                	sub    %eax,%ecx
  8013f6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8013f9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013fc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801400:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801403:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801406:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801408:	eb 0f                	jmp    801419 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	53                   	push   %ebx
  80140e:	ff 75 e0             	pushl  -0x20(%ebp)
  801411:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801413:	83 ef 01             	sub    $0x1,%edi
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	85 ff                	test   %edi,%edi
  80141b:	7f ed                	jg     80140a <vprintfmt+0x1c0>
  80141d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801420:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801423:	85 c9                	test   %ecx,%ecx
  801425:	b8 00 00 00 00       	mov    $0x0,%eax
  80142a:	0f 49 c1             	cmovns %ecx,%eax
  80142d:	29 c1                	sub    %eax,%ecx
  80142f:	89 75 08             	mov    %esi,0x8(%ebp)
  801432:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801435:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801438:	89 cb                	mov    %ecx,%ebx
  80143a:	eb 4d                	jmp    801489 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80143c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801440:	74 1b                	je     80145d <vprintfmt+0x213>
  801442:	0f be c0             	movsbl %al,%eax
  801445:	83 e8 20             	sub    $0x20,%eax
  801448:	83 f8 5e             	cmp    $0x5e,%eax
  80144b:	76 10                	jbe    80145d <vprintfmt+0x213>
					putch('?', putdat);
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	ff 75 0c             	pushl  0xc(%ebp)
  801453:	6a 3f                	push   $0x3f
  801455:	ff 55 08             	call   *0x8(%ebp)
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	eb 0d                	jmp    80146a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	ff 75 0c             	pushl  0xc(%ebp)
  801463:	52                   	push   %edx
  801464:	ff 55 08             	call   *0x8(%ebp)
  801467:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80146a:	83 eb 01             	sub    $0x1,%ebx
  80146d:	eb 1a                	jmp    801489 <vprintfmt+0x23f>
  80146f:	89 75 08             	mov    %esi,0x8(%ebp)
  801472:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801478:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80147b:	eb 0c                	jmp    801489 <vprintfmt+0x23f>
  80147d:	89 75 08             	mov    %esi,0x8(%ebp)
  801480:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801483:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801489:	83 c7 01             	add    $0x1,%edi
  80148c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801490:	0f be d0             	movsbl %al,%edx
  801493:	85 d2                	test   %edx,%edx
  801495:	74 23                	je     8014ba <vprintfmt+0x270>
  801497:	85 f6                	test   %esi,%esi
  801499:	78 a1                	js     80143c <vprintfmt+0x1f2>
  80149b:	83 ee 01             	sub    $0x1,%esi
  80149e:	79 9c                	jns    80143c <vprintfmt+0x1f2>
  8014a0:	89 df                	mov    %ebx,%edi
  8014a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a8:	eb 18                	jmp    8014c2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	53                   	push   %ebx
  8014ae:	6a 20                	push   $0x20
  8014b0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014b2:	83 ef 01             	sub    $0x1,%edi
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	eb 08                	jmp    8014c2 <vprintfmt+0x278>
  8014ba:	89 df                	mov    %ebx,%edi
  8014bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c2:	85 ff                	test   %edi,%edi
  8014c4:	7f e4                	jg     8014aa <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c9:	e9 a2 fd ff ff       	jmp    801270 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ce:	83 fa 01             	cmp    $0x1,%edx
  8014d1:	7e 16                	jle    8014e9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d6:	8d 50 08             	lea    0x8(%eax),%edx
  8014d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014dc:	8b 50 04             	mov    0x4(%eax),%edx
  8014df:	8b 00                	mov    (%eax),%eax
  8014e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8014e7:	eb 32                	jmp    80151b <vprintfmt+0x2d1>
	else if (lflag)
  8014e9:	85 d2                	test   %edx,%edx
  8014eb:	74 18                	je     801505 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f0:	8d 50 04             	lea    0x4(%eax),%edx
  8014f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f6:	8b 00                	mov    (%eax),%eax
  8014f8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014fb:	89 c1                	mov    %eax,%ecx
  8014fd:	c1 f9 1f             	sar    $0x1f,%ecx
  801500:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801503:	eb 16                	jmp    80151b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801505:	8b 45 14             	mov    0x14(%ebp),%eax
  801508:	8d 50 04             	lea    0x4(%eax),%edx
  80150b:	89 55 14             	mov    %edx,0x14(%ebp)
  80150e:	8b 00                	mov    (%eax),%eax
  801510:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801513:	89 c1                	mov    %eax,%ecx
  801515:	c1 f9 1f             	sar    $0x1f,%ecx
  801518:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80151b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80151e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801524:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801527:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80152c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801530:	0f 89 b0 00 00 00    	jns    8015e6 <vprintfmt+0x39c>
				putch('-', putdat);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	53                   	push   %ebx
  80153a:	6a 2d                	push   $0x2d
  80153c:	ff d6                	call   *%esi
				num = -(long long) num;
  80153e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801541:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801544:	f7 d8                	neg    %eax
  801546:	83 d2 00             	adc    $0x0,%edx
  801549:	f7 da                	neg    %edx
  80154b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801551:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801554:	b8 0a 00 00 00       	mov    $0xa,%eax
  801559:	e9 88 00 00 00       	jmp    8015e6 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80155e:	8d 45 14             	lea    0x14(%ebp),%eax
  801561:	e8 70 fc ff ff       	call   8011d6 <getuint>
  801566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801569:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80156c:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801571:	eb 73                	jmp    8015e6 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  801573:	8d 45 14             	lea    0x14(%ebp),%eax
  801576:	e8 5b fc ff ff       	call   8011d6 <getuint>
  80157b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	6a 58                	push   $0x58
  801587:	ff d6                	call   *%esi
			putch('X', putdat);
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 58                	push   $0x58
  80158f:	ff d6                	call   *%esi
			putch('X', putdat);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	6a 58                	push   $0x58
  801597:	ff d6                	call   *%esi
			goto number;
  801599:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80159c:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8015a1:	eb 43                	jmp    8015e6 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	6a 30                	push   $0x30
  8015a9:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	53                   	push   %ebx
  8015af:	6a 78                	push   $0x78
  8015b1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b6:	8d 50 04             	lea    0x4(%eax),%edx
  8015b9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015bc:	8b 00                	mov    (%eax),%eax
  8015be:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015cc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d1:	eb 13                	jmp    8015e6 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d6:	e8 fb fb ff ff       	call   8011d6 <getuint>
  8015db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015de:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8015e1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8015ed:	52                   	push   %edx
  8015ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f1:	50                   	push   %eax
  8015f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8015f8:	89 da                	mov    %ebx,%edx
  8015fa:	89 f0                	mov    %esi,%eax
  8015fc:	e8 26 fb ff ff       	call   801127 <printnum>
			break;
  801601:	83 c4 20             	add    $0x20,%esp
  801604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801607:	e9 64 fc ff ff       	jmp    801270 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	53                   	push   %ebx
  801610:	51                   	push   %ecx
  801611:	ff d6                	call   *%esi
			break;
  801613:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801619:	e9 52 fc ff ff       	jmp    801270 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	53                   	push   %ebx
  801622:	6a 25                	push   $0x25
  801624:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	eb 03                	jmp    80162e <vprintfmt+0x3e4>
  80162b:	83 ef 01             	sub    $0x1,%edi
  80162e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801632:	75 f7                	jne    80162b <vprintfmt+0x3e1>
  801634:	e9 37 fc ff ff       	jmp    801270 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163c:	5b                   	pop    %ebx
  80163d:	5e                   	pop    %esi
  80163e:	5f                   	pop    %edi
  80163f:	5d                   	pop    %ebp
  801640:	c3                   	ret    

00801641 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	83 ec 18             	sub    $0x18,%esp
  801647:	8b 45 08             	mov    0x8(%ebp),%eax
  80164a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80164d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801650:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801654:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80165e:	85 c0                	test   %eax,%eax
  801660:	74 26                	je     801688 <vsnprintf+0x47>
  801662:	85 d2                	test   %edx,%edx
  801664:	7e 22                	jle    801688 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801666:	ff 75 14             	pushl  0x14(%ebp)
  801669:	ff 75 10             	pushl  0x10(%ebp)
  80166c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	68 10 12 80 00       	push   $0x801210
  801675:	e8 d0 fb ff ff       	call   80124a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80167a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	eb 05                	jmp    80168d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801688:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801695:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801698:	50                   	push   %eax
  801699:	ff 75 10             	pushl  0x10(%ebp)
  80169c:	ff 75 0c             	pushl  0xc(%ebp)
  80169f:	ff 75 08             	pushl  0x8(%ebp)
  8016a2:	e8 9a ff ff ff       	call   801641 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016af:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b4:	eb 03                	jmp    8016b9 <strlen+0x10>
		n++;
  8016b6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016bd:	75 f7                	jne    8016b6 <strlen+0xd>
		n++;
	return n;
}
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cf:	eb 03                	jmp    8016d4 <strnlen+0x13>
		n++;
  8016d1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d4:	39 c2                	cmp    %eax,%edx
  8016d6:	74 08                	je     8016e0 <strnlen+0x1f>
  8016d8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016dc:	75 f3                	jne    8016d1 <strnlen+0x10>
  8016de:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	53                   	push   %ebx
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ec:	89 c2                	mov    %eax,%edx
  8016ee:	83 c2 01             	add    $0x1,%edx
  8016f1:	83 c1 01             	add    $0x1,%ecx
  8016f4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016fb:	84 db                	test   %bl,%bl
  8016fd:	75 ef                	jne    8016ee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016ff:	5b                   	pop    %ebx
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	53                   	push   %ebx
  801706:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801709:	53                   	push   %ebx
  80170a:	e8 9a ff ff ff       	call   8016a9 <strlen>
  80170f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801712:	ff 75 0c             	pushl  0xc(%ebp)
  801715:	01 d8                	add    %ebx,%eax
  801717:	50                   	push   %eax
  801718:	e8 c5 ff ff ff       	call   8016e2 <strcpy>
	return dst;
}
  80171d:	89 d8                	mov    %ebx,%eax
  80171f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	8b 75 08             	mov    0x8(%ebp),%esi
  80172c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172f:	89 f3                	mov    %esi,%ebx
  801731:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801734:	89 f2                	mov    %esi,%edx
  801736:	eb 0f                	jmp    801747 <strncpy+0x23>
		*dst++ = *src;
  801738:	83 c2 01             	add    $0x1,%edx
  80173b:	0f b6 01             	movzbl (%ecx),%eax
  80173e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801741:	80 39 01             	cmpb   $0x1,(%ecx)
  801744:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801747:	39 da                	cmp    %ebx,%edx
  801749:	75 ed                	jne    801738 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80174b:	89 f0                	mov    %esi,%eax
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	56                   	push   %esi
  801755:	53                   	push   %ebx
  801756:	8b 75 08             	mov    0x8(%ebp),%esi
  801759:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175c:	8b 55 10             	mov    0x10(%ebp),%edx
  80175f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801761:	85 d2                	test   %edx,%edx
  801763:	74 21                	je     801786 <strlcpy+0x35>
  801765:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801769:	89 f2                	mov    %esi,%edx
  80176b:	eb 09                	jmp    801776 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176d:	83 c2 01             	add    $0x1,%edx
  801770:	83 c1 01             	add    $0x1,%ecx
  801773:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801776:	39 c2                	cmp    %eax,%edx
  801778:	74 09                	je     801783 <strlcpy+0x32>
  80177a:	0f b6 19             	movzbl (%ecx),%ebx
  80177d:	84 db                	test   %bl,%bl
  80177f:	75 ec                	jne    80176d <strlcpy+0x1c>
  801781:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801783:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801786:	29 f0                	sub    %esi,%eax
}
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801792:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801795:	eb 06                	jmp    80179d <strcmp+0x11>
		p++, q++;
  801797:	83 c1 01             	add    $0x1,%ecx
  80179a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80179d:	0f b6 01             	movzbl (%ecx),%eax
  8017a0:	84 c0                	test   %al,%al
  8017a2:	74 04                	je     8017a8 <strcmp+0x1c>
  8017a4:	3a 02                	cmp    (%edx),%al
  8017a6:	74 ef                	je     801797 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a8:	0f b6 c0             	movzbl %al,%eax
  8017ab:	0f b6 12             	movzbl (%edx),%edx
  8017ae:	29 d0                	sub    %edx,%eax
}
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    

008017b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	53                   	push   %ebx
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017bc:	89 c3                	mov    %eax,%ebx
  8017be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c1:	eb 06                	jmp    8017c9 <strncmp+0x17>
		n--, p++, q++;
  8017c3:	83 c0 01             	add    $0x1,%eax
  8017c6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c9:	39 d8                	cmp    %ebx,%eax
  8017cb:	74 15                	je     8017e2 <strncmp+0x30>
  8017cd:	0f b6 08             	movzbl (%eax),%ecx
  8017d0:	84 c9                	test   %cl,%cl
  8017d2:	74 04                	je     8017d8 <strncmp+0x26>
  8017d4:	3a 0a                	cmp    (%edx),%cl
  8017d6:	74 eb                	je     8017c3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d8:	0f b6 00             	movzbl (%eax),%eax
  8017db:	0f b6 12             	movzbl (%edx),%edx
  8017de:	29 d0                	sub    %edx,%eax
  8017e0:	eb 05                	jmp    8017e7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e7:	5b                   	pop    %ebx
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f4:	eb 07                	jmp    8017fd <strchr+0x13>
		if (*s == c)
  8017f6:	38 ca                	cmp    %cl,%dl
  8017f8:	74 0f                	je     801809 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017fa:	83 c0 01             	add    $0x1,%eax
  8017fd:	0f b6 10             	movzbl (%eax),%edx
  801800:	84 d2                	test   %dl,%dl
  801802:	75 f2                	jne    8017f6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801804:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801815:	eb 03                	jmp    80181a <strfind+0xf>
  801817:	83 c0 01             	add    $0x1,%eax
  80181a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181d:	38 ca                	cmp    %cl,%dl
  80181f:	74 04                	je     801825 <strfind+0x1a>
  801821:	84 d2                	test   %dl,%dl
  801823:	75 f2                	jne    801817 <strfind+0xc>
			break;
	return (char *) s;
}
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    

00801827 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	57                   	push   %edi
  80182b:	56                   	push   %esi
  80182c:	53                   	push   %ebx
  80182d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801830:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801833:	85 c9                	test   %ecx,%ecx
  801835:	74 36                	je     80186d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801837:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183d:	75 28                	jne    801867 <memset+0x40>
  80183f:	f6 c1 03             	test   $0x3,%cl
  801842:	75 23                	jne    801867 <memset+0x40>
		c &= 0xFF;
  801844:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801848:	89 d3                	mov    %edx,%ebx
  80184a:	c1 e3 08             	shl    $0x8,%ebx
  80184d:	89 d6                	mov    %edx,%esi
  80184f:	c1 e6 18             	shl    $0x18,%esi
  801852:	89 d0                	mov    %edx,%eax
  801854:	c1 e0 10             	shl    $0x10,%eax
  801857:	09 f0                	or     %esi,%eax
  801859:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80185b:	89 d8                	mov    %ebx,%eax
  80185d:	09 d0                	or     %edx,%eax
  80185f:	c1 e9 02             	shr    $0x2,%ecx
  801862:	fc                   	cld    
  801863:	f3 ab                	rep stos %eax,%es:(%edi)
  801865:	eb 06                	jmp    80186d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801867:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186a:	fc                   	cld    
  80186b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186d:	89 f8                	mov    %edi,%eax
  80186f:	5b                   	pop    %ebx
  801870:	5e                   	pop    %esi
  801871:	5f                   	pop    %edi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    

00801874 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	57                   	push   %edi
  801878:	56                   	push   %esi
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801882:	39 c6                	cmp    %eax,%esi
  801884:	73 35                	jae    8018bb <memmove+0x47>
  801886:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801889:	39 d0                	cmp    %edx,%eax
  80188b:	73 2e                	jae    8018bb <memmove+0x47>
		s += n;
		d += n;
  80188d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801890:	89 d6                	mov    %edx,%esi
  801892:	09 fe                	or     %edi,%esi
  801894:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189a:	75 13                	jne    8018af <memmove+0x3b>
  80189c:	f6 c1 03             	test   $0x3,%cl
  80189f:	75 0e                	jne    8018af <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a1:	83 ef 04             	sub    $0x4,%edi
  8018a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a7:	c1 e9 02             	shr    $0x2,%ecx
  8018aa:	fd                   	std    
  8018ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ad:	eb 09                	jmp    8018b8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018af:	83 ef 01             	sub    $0x1,%edi
  8018b2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b5:	fd                   	std    
  8018b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b8:	fc                   	cld    
  8018b9:	eb 1d                	jmp    8018d8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bb:	89 f2                	mov    %esi,%edx
  8018bd:	09 c2                	or     %eax,%edx
  8018bf:	f6 c2 03             	test   $0x3,%dl
  8018c2:	75 0f                	jne    8018d3 <memmove+0x5f>
  8018c4:	f6 c1 03             	test   $0x3,%cl
  8018c7:	75 0a                	jne    8018d3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018c9:	c1 e9 02             	shr    $0x2,%ecx
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	fc                   	cld    
  8018cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d1:	eb 05                	jmp    8018d8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d3:	89 c7                	mov    %eax,%edi
  8018d5:	fc                   	cld    
  8018d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d8:	5e                   	pop    %esi
  8018d9:	5f                   	pop    %edi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018df:	ff 75 10             	pushl  0x10(%ebp)
  8018e2:	ff 75 0c             	pushl  0xc(%ebp)
  8018e5:	ff 75 08             	pushl  0x8(%ebp)
  8018e8:	e8 87 ff ff ff       	call   801874 <memmove>
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	56                   	push   %esi
  8018f3:	53                   	push   %ebx
  8018f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fa:	89 c6                	mov    %eax,%esi
  8018fc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ff:	eb 1a                	jmp    80191b <memcmp+0x2c>
		if (*s1 != *s2)
  801901:	0f b6 08             	movzbl (%eax),%ecx
  801904:	0f b6 1a             	movzbl (%edx),%ebx
  801907:	38 d9                	cmp    %bl,%cl
  801909:	74 0a                	je     801915 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80190b:	0f b6 c1             	movzbl %cl,%eax
  80190e:	0f b6 db             	movzbl %bl,%ebx
  801911:	29 d8                	sub    %ebx,%eax
  801913:	eb 0f                	jmp    801924 <memcmp+0x35>
		s1++, s2++;
  801915:	83 c0 01             	add    $0x1,%eax
  801918:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191b:	39 f0                	cmp    %esi,%eax
  80191d:	75 e2                	jne    801901 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80191f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	53                   	push   %ebx
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80192f:	89 c1                	mov    %eax,%ecx
  801931:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801934:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801938:	eb 0a                	jmp    801944 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193a:	0f b6 10             	movzbl (%eax),%edx
  80193d:	39 da                	cmp    %ebx,%edx
  80193f:	74 07                	je     801948 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801941:	83 c0 01             	add    $0x1,%eax
  801944:	39 c8                	cmp    %ecx,%eax
  801946:	72 f2                	jb     80193a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801948:	5b                   	pop    %ebx
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	57                   	push   %edi
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801954:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801957:	eb 03                	jmp    80195c <strtol+0x11>
		s++;
  801959:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195c:	0f b6 01             	movzbl (%ecx),%eax
  80195f:	3c 20                	cmp    $0x20,%al
  801961:	74 f6                	je     801959 <strtol+0xe>
  801963:	3c 09                	cmp    $0x9,%al
  801965:	74 f2                	je     801959 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801967:	3c 2b                	cmp    $0x2b,%al
  801969:	75 0a                	jne    801975 <strtol+0x2a>
		s++;
  80196b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80196e:	bf 00 00 00 00       	mov    $0x0,%edi
  801973:	eb 11                	jmp    801986 <strtol+0x3b>
  801975:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197a:	3c 2d                	cmp    $0x2d,%al
  80197c:	75 08                	jne    801986 <strtol+0x3b>
		s++, neg = 1;
  80197e:	83 c1 01             	add    $0x1,%ecx
  801981:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801986:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80198c:	75 15                	jne    8019a3 <strtol+0x58>
  80198e:	80 39 30             	cmpb   $0x30,(%ecx)
  801991:	75 10                	jne    8019a3 <strtol+0x58>
  801993:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801997:	75 7c                	jne    801a15 <strtol+0xca>
		s += 2, base = 16;
  801999:	83 c1 02             	add    $0x2,%ecx
  80199c:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a1:	eb 16                	jmp    8019b9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a3:	85 db                	test   %ebx,%ebx
  8019a5:	75 12                	jne    8019b9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ac:	80 39 30             	cmpb   $0x30,(%ecx)
  8019af:	75 08                	jne    8019b9 <strtol+0x6e>
		s++, base = 8;
  8019b1:	83 c1 01             	add    $0x1,%ecx
  8019b4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019be:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c1:	0f b6 11             	movzbl (%ecx),%edx
  8019c4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c7:	89 f3                	mov    %esi,%ebx
  8019c9:	80 fb 09             	cmp    $0x9,%bl
  8019cc:	77 08                	ja     8019d6 <strtol+0x8b>
			dig = *s - '0';
  8019ce:	0f be d2             	movsbl %dl,%edx
  8019d1:	83 ea 30             	sub    $0x30,%edx
  8019d4:	eb 22                	jmp    8019f8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019d6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d9:	89 f3                	mov    %esi,%ebx
  8019db:	80 fb 19             	cmp    $0x19,%bl
  8019de:	77 08                	ja     8019e8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e0:	0f be d2             	movsbl %dl,%edx
  8019e3:	83 ea 57             	sub    $0x57,%edx
  8019e6:	eb 10                	jmp    8019f8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019e8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019eb:	89 f3                	mov    %esi,%ebx
  8019ed:	80 fb 19             	cmp    $0x19,%bl
  8019f0:	77 16                	ja     801a08 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019f2:	0f be d2             	movsbl %dl,%edx
  8019f5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019fb:	7d 0b                	jge    801a08 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019fd:	83 c1 01             	add    $0x1,%ecx
  801a00:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a04:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a06:	eb b9                	jmp    8019c1 <strtol+0x76>

	if (endptr)
  801a08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a0c:	74 0d                	je     801a1b <strtol+0xd0>
		*endptr = (char *) s;
  801a0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a11:	89 0e                	mov    %ecx,(%esi)
  801a13:	eb 06                	jmp    801a1b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a15:	85 db                	test   %ebx,%ebx
  801a17:	74 98                	je     8019b1 <strtol+0x66>
  801a19:	eb 9e                	jmp    8019b9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a1b:	89 c2                	mov    %eax,%edx
  801a1d:	f7 da                	neg    %edx
  801a1f:	85 ff                	test   %edi,%edi
  801a21:	0f 45 c2             	cmovne %edx,%eax
}
  801a24:	5b                   	pop    %ebx
  801a25:	5e                   	pop    %esi
  801a26:	5f                   	pop    %edi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	56                   	push   %esi
  801a2d:	53                   	push   %ebx
  801a2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a31:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	ff 75 0c             	pushl  0xc(%ebp)
  801a3a:	e8 d7 e8 ff ff       	call   800316 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	85 f6                	test   %esi,%esi
  801a44:	74 1c                	je     801a62 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a46:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4b:	8b 40 78             	mov    0x78(%eax),%eax
  801a4e:	89 06                	mov    %eax,(%esi)
  801a50:	eb 10                	jmp    801a62 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a52:	83 ec 0c             	sub    $0xc,%esp
  801a55:	68 20 22 80 00       	push   $0x802220
  801a5a:	e8 b4 f6 ff ff       	call   801113 <cprintf>
  801a5f:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a62:	a1 04 40 80 00       	mov    0x804004,%eax
  801a67:	8b 50 74             	mov    0x74(%eax),%edx
  801a6a:	85 d2                	test   %edx,%edx
  801a6c:	74 e4                	je     801a52 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a6e:	85 db                	test   %ebx,%ebx
  801a70:	74 05                	je     801a77 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a72:	8b 40 74             	mov    0x74(%eax),%eax
  801a75:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a77:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7c:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    

00801a86 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a92:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801a98:	85 db                	test   %ebx,%ebx
  801a9a:	75 13                	jne    801aaf <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801a9c:	6a 00                	push   $0x0
  801a9e:	68 00 00 c0 ee       	push   $0xeec00000
  801aa3:	56                   	push   %esi
  801aa4:	57                   	push   %edi
  801aa5:	e8 49 e8 ff ff       	call   8002f3 <sys_ipc_try_send>
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	eb 0e                	jmp    801abd <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801aaf:	ff 75 14             	pushl  0x14(%ebp)
  801ab2:	53                   	push   %ebx
  801ab3:	56                   	push   %esi
  801ab4:	57                   	push   %edi
  801ab5:	e8 39 e8 ff ff       	call   8002f3 <sys_ipc_try_send>
  801aba:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801abd:	85 c0                	test   %eax,%eax
  801abf:	75 d7                	jne    801a98 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5f                   	pop    %edi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801add:	8b 52 50             	mov    0x50(%edx),%edx
  801ae0:	39 ca                	cmp    %ecx,%edx
  801ae2:	75 0d                	jne    801af1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aec:	8b 40 48             	mov    0x48(%eax),%eax
  801aef:	eb 0f                	jmp    801b00 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af1:	83 c0 01             	add    $0x1,%eax
  801af4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af9:	75 d9                	jne    801ad4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b00:	5d                   	pop    %ebp
  801b01:	c3                   	ret    

00801b02 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b08:	89 d0                	mov    %edx,%eax
  801b0a:	c1 e8 16             	shr    $0x16,%eax
  801b0d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b19:	f6 c1 01             	test   $0x1,%cl
  801b1c:	74 1d                	je     801b3b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1e:	c1 ea 0c             	shr    $0xc,%edx
  801b21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b28:	f6 c2 01             	test   $0x1,%dl
  801b2b:	74 0e                	je     801b3b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b2d:	c1 ea 0c             	shr    $0xc,%edx
  801b30:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b37:	ef 
  801b38:	0f b7 c0             	movzwl %ax,%eax
}
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    
  801b3d:	66 90                	xchg   %ax,%ax
  801b3f:	90                   	nop

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 1c             	sub    $0x1c,%esp
  801b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b57:	85 f6                	test   %esi,%esi
  801b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5d:	89 ca                	mov    %ecx,%edx
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	75 3d                	jne    801ba0 <__udivdi3+0x60>
  801b63:	39 cf                	cmp    %ecx,%edi
  801b65:	0f 87 c5 00 00 00    	ja     801c30 <__udivdi3+0xf0>
  801b6b:	85 ff                	test   %edi,%edi
  801b6d:	89 fd                	mov    %edi,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f7                	div    %edi
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 c8                	mov    %ecx,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c1                	mov    %eax,%ecx
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	89 cf                	mov    %ecx,%edi
  801b88:	f7 f5                	div    %ebp
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	89 fa                	mov    %edi,%edx
  801b90:	83 c4 1c             	add    $0x1c,%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
  801b98:	90                   	nop
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	39 ce                	cmp    %ecx,%esi
  801ba2:	77 74                	ja     801c18 <__udivdi3+0xd8>
  801ba4:	0f bd fe             	bsr    %esi,%edi
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	0f 84 98 00 00 00    	je     801c48 <__udivdi3+0x108>
  801bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	89 c5                	mov    %eax,%ebp
  801bb9:	29 fb                	sub    %edi,%ebx
  801bbb:	d3 e6                	shl    %cl,%esi
  801bbd:	89 d9                	mov    %ebx,%ecx
  801bbf:	d3 ed                	shr    %cl,%ebp
  801bc1:	89 f9                	mov    %edi,%ecx
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	09 ee                	or     %ebp,%esi
  801bc7:	89 d9                	mov    %ebx,%ecx
  801bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcd:	89 d5                	mov    %edx,%ebp
  801bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bd3:	d3 ed                	shr    %cl,%ebp
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	d3 e2                	shl    %cl,%edx
  801bd9:	89 d9                	mov    %ebx,%ecx
  801bdb:	d3 e8                	shr    %cl,%eax
  801bdd:	09 c2                	or     %eax,%edx
  801bdf:	89 d0                	mov    %edx,%eax
  801be1:	89 ea                	mov    %ebp,%edx
  801be3:	f7 f6                	div    %esi
  801be5:	89 d5                	mov    %edx,%ebp
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	f7 64 24 0c          	mull   0xc(%esp)
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	72 10                	jb     801c01 <__udivdi3+0xc1>
  801bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e6                	shl    %cl,%esi
  801bf9:	39 c6                	cmp    %eax,%esi
  801bfb:	73 07                	jae    801c04 <__udivdi3+0xc4>
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	75 03                	jne    801c04 <__udivdi3+0xc4>
  801c01:	83 eb 01             	sub    $0x1,%ebx
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	83 c4 1c             	add    $0x1c,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    
  801c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c18:	31 ff                	xor    %edi,%edi
  801c1a:	31 db                	xor    %ebx,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	f7 f7                	div    %edi
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	83 c4 1c             	add    $0x1c,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 ce                	cmp    %ecx,%esi
  801c4a:	72 0c                	jb     801c58 <__udivdi3+0x118>
  801c4c:	31 db                	xor    %ebx,%ebx
  801c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c52:	0f 87 34 ff ff ff    	ja     801b8c <__udivdi3+0x4c>
  801c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c5d:	e9 2a ff ff ff       	jmp    801b8c <__udivdi3+0x4c>
  801c62:	66 90                	xchg   %ax,%ax
  801c64:	66 90                	xchg   %ax,%ax
  801c66:	66 90                	xchg   %ax,%ax
  801c68:	66 90                	xchg   %ax,%ax
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c87:	85 d2                	test   %edx,%edx
  801c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f3                	mov    %esi,%ebx
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	75 1c                	jne    801cb8 <__umoddi3+0x48>
  801c9c:	39 f7                	cmp    %esi,%edi
  801c9e:	76 50                	jbe    801cf0 <__umoddi3+0x80>
  801ca0:	89 c8                	mov    %ecx,%eax
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	f7 f7                	div    %edi
  801ca6:	89 d0                	mov    %edx,%eax
  801ca8:	31 d2                	xor    %edx,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	77 52                	ja     801d10 <__umoddi3+0xa0>
  801cbe:	0f bd ea             	bsr    %edx,%ebp
  801cc1:	83 f5 1f             	xor    $0x1f,%ebp
  801cc4:	75 5a                	jne    801d20 <__umoddi3+0xb0>
  801cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	39 0c 24             	cmp    %ecx,(%esp)
  801cd3:	0f 86 d7 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	85 ff                	test   %edi,%edi
  801cf2:	89 fd                	mov    %edi,%ebp
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 c8                	mov    %ecx,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	eb 99                	jmp    801ca8 <__umoddi3+0x38>
  801d0f:	90                   	nop
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 1c             	add    $0x1c,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	8b 34 24             	mov    (%esp),%esi
  801d23:	bf 20 00 00 00       	mov    $0x20,%edi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	29 ef                	sub    %ebp,%edi
  801d2c:	d3 e0                	shl    %cl,%eax
  801d2e:	89 f9                	mov    %edi,%ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	d3 ea                	shr    %cl,%edx
  801d34:	89 e9                	mov    %ebp,%ecx
  801d36:	09 c2                	or     %eax,%edx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 14 24             	mov    %edx,(%esp)
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	d3 e2                	shl    %cl,%edx
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	89 c6                	mov    %eax,%esi
  801d51:	d3 e3                	shl    %cl,%ebx
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	09 d8                	or     %ebx,%eax
  801d5d:	89 d3                	mov    %edx,%ebx
  801d5f:	89 f2                	mov    %esi,%edx
  801d61:	f7 34 24             	divl   (%esp)
  801d64:	89 d6                	mov    %edx,%esi
  801d66:	d3 e3                	shl    %cl,%ebx
  801d68:	f7 64 24 04          	mull   0x4(%esp)
  801d6c:	39 d6                	cmp    %edx,%esi
  801d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d72:	89 d1                	mov    %edx,%ecx
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	72 08                	jb     801d80 <__umoddi3+0x110>
  801d78:	75 11                	jne    801d8b <__umoddi3+0x11b>
  801d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d7e:	73 0b                	jae    801d8b <__umoddi3+0x11b>
  801d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d84:	1b 14 24             	sbb    (%esp),%edx
  801d87:	89 d1                	mov    %edx,%ecx
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d8f:	29 da                	sub    %ebx,%edx
  801d91:	19 ce                	sbb    %ecx,%esi
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e0                	shl    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	d3 ee                	shr    %cl,%esi
  801da1:	09 d0                	or     %edx,%eax
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	83 c4 1c             	add    $0x1c,%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 f9                	sub    %edi,%ecx
  801db2:	19 d6                	sbb    %edx,%esi
  801db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dbc:	e9 18 ff ff ff       	jmp    801cd9 <__umoddi3+0x69>
