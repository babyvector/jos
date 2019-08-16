
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 32 01 00 00       	call   800179 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 2c 02 00 00       	call   800282 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 c6 00 00 00       	call   80013b <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	b8 03 00 00 00       	mov    $0x3,%eax
  80010d:	8b 55 08             	mov    0x8(%ebp),%edx
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7e 17                	jle    800133 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	68 ca 0f 80 00       	push   $0x800fca
  800127:	6a 23                	push   $0x23
  800129:	68 e7 0f 80 00       	push   $0x800fe7
  80012e:	e8 f5 01 00 00       	call   800328 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 17                	jle    8001b4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	6a 04                	push   $0x4
  8001a3:	68 ca 0f 80 00       	push   $0x800fca
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 e7 0f 80 00       	push   $0x800fe7
  8001af:	e8 74 01 00 00       	call   800328 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 17                	jle    8001f6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 05                	push   $0x5
  8001e5:	68 ca 0f 80 00       	push   $0x800fca
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 e7 0f 80 00       	push   $0x800fe7
  8001f1:	e8 32 01 00 00       	call   800328 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 17                	jle    800238 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 06                	push   $0x6
  800227:	68 ca 0f 80 00       	push   $0x800fca
  80022c:	6a 23                	push   $0x23
  80022e:	68 e7 0f 80 00       	push   $0x800fe7
  800233:	e8 f0 00 00 00       	call   800328 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 17                	jle    80027a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	50                   	push   %eax
  800267:	6a 08                	push   $0x8
  800269:	68 ca 0f 80 00       	push   $0x800fca
  80026e:	6a 23                	push   $0x23
  800270:	68 e7 0f 80 00       	push   $0x800fe7
  800275:	e8 ae 00 00 00       	call   800328 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	b8 09 00 00 00       	mov    $0x9,%eax
  800295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7e 17                	jle    8002bc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	50                   	push   %eax
  8002a9:	6a 09                	push   $0x9
  8002ab:	68 ca 0f 80 00       	push   $0x800fca
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 e7 0f 80 00       	push   $0x800fe7
  8002b7:	e8 6c 00 00 00       	call   800328 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002ca:	be 00 00 00 00       	mov    $0x0,%esi
  8002cf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	89 cb                	mov    %ecx,%ebx
  8002ff:	89 cf                	mov    %ecx,%edi
  800301:	89 ce                	mov    %ecx,%esi
  800303:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7e 17                	jle    800320 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	50                   	push   %eax
  80030d:	6a 0c                	push   $0xc
  80030f:	68 ca 0f 80 00       	push   $0x800fca
  800314:	6a 23                	push   $0x23
  800316:	68 e7 0f 80 00       	push   $0x800fe7
  80031b:	e8 08 00 00 00       	call   800328 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80032d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800330:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800336:	e8 00 fe ff ff       	call   80013b <sys_getenvid>
  80033b:	83 ec 0c             	sub    $0xc,%esp
  80033e:	ff 75 0c             	pushl  0xc(%ebp)
  800341:	ff 75 08             	pushl  0x8(%ebp)
  800344:	56                   	push   %esi
  800345:	50                   	push   %eax
  800346:	68 f8 0f 80 00       	push   $0x800ff8
  80034b:	e8 b1 00 00 00       	call   800401 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800350:	83 c4 18             	add    $0x18,%esp
  800353:	53                   	push   %ebx
  800354:	ff 75 10             	pushl  0x10(%ebp)
  800357:	e8 54 00 00 00       	call   8003b0 <vcprintf>
	cprintf("\n");
  80035c:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  800363:	e8 99 00 00 00       	call   800401 <cprintf>
  800368:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036b:	cc                   	int3   
  80036c:	eb fd                	jmp    80036b <_panic+0x43>

0080036e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	53                   	push   %ebx
  800372:	83 ec 04             	sub    $0x4,%esp
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800378:	8b 13                	mov    (%ebx),%edx
  80037a:	8d 42 01             	lea    0x1(%edx),%eax
  80037d:	89 03                	mov    %eax,(%ebx)
  80037f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800382:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800386:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038b:	75 1a                	jne    8003a7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	68 ff 00 00 00       	push   $0xff
  800395:	8d 43 08             	lea    0x8(%ebx),%eax
  800398:	50                   	push   %eax
  800399:	e8 1f fd ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  80039e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8003b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c0:	00 00 00 
	b.cnt = 0;
  8003c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cd:	ff 75 0c             	pushl  0xc(%ebp)
  8003d0:	ff 75 08             	pushl  0x8(%ebp)
  8003d3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d9:	50                   	push   %eax
  8003da:	68 6e 03 80 00       	push   $0x80036e
  8003df:	e8 54 01 00 00       	call   800538 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e4:	83 c4 08             	add    $0x8,%esp
  8003e7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f3:	50                   	push   %eax
  8003f4:	e8 c4 fc ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  8003f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800407:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040a:	50                   	push   %eax
  80040b:	ff 75 08             	pushl  0x8(%ebp)
  80040e:	e8 9d ff ff ff       	call   8003b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800413:	c9                   	leave  
  800414:	c3                   	ret    

00800415 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	57                   	push   %edi
  800419:	56                   	push   %esi
  80041a:	53                   	push   %ebx
  80041b:	83 ec 1c             	sub    $0x1c,%esp
  80041e:	89 c7                	mov    %eax,%edi
  800420:	89 d6                	mov    %edx,%esi
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800431:	bb 00 00 00 00       	mov    $0x0,%ebx
  800436:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800439:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80043c:	39 d3                	cmp    %edx,%ebx
  80043e:	72 05                	jb     800445 <printnum+0x30>
  800440:	39 45 10             	cmp    %eax,0x10(%ebp)
  800443:	77 45                	ja     80048a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800445:	83 ec 0c             	sub    $0xc,%esp
  800448:	ff 75 18             	pushl  0x18(%ebp)
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800451:	53                   	push   %ebx
  800452:	ff 75 10             	pushl  0x10(%ebp)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 e4             	pushl  -0x1c(%ebp)
  80045b:	ff 75 e0             	pushl  -0x20(%ebp)
  80045e:	ff 75 dc             	pushl  -0x24(%ebp)
  800461:	ff 75 d8             	pushl  -0x28(%ebp)
  800464:	e8 b7 08 00 00       	call   800d20 <__udivdi3>
  800469:	83 c4 18             	add    $0x18,%esp
  80046c:	52                   	push   %edx
  80046d:	50                   	push   %eax
  80046e:	89 f2                	mov    %esi,%edx
  800470:	89 f8                	mov    %edi,%eax
  800472:	e8 9e ff ff ff       	call   800415 <printnum>
  800477:	83 c4 20             	add    $0x20,%esp
  80047a:	eb 18                	jmp    800494 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	56                   	push   %esi
  800480:	ff 75 18             	pushl  0x18(%ebp)
  800483:	ff d7                	call   *%edi
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	eb 03                	jmp    80048d <printnum+0x78>
  80048a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80048d:	83 eb 01             	sub    $0x1,%ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	7f e8                	jg     80047c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	56                   	push   %esi
  800498:	83 ec 04             	sub    $0x4,%esp
  80049b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049e:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a7:	e8 a4 09 00 00       	call   800e50 <__umoddi3>
  8004ac:	83 c4 14             	add    $0x14,%esp
  8004af:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  8004b6:	50                   	push   %eax
  8004b7:	ff d7                	call   *%edi
}
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bf:	5b                   	pop    %ebx
  8004c0:	5e                   	pop    %esi
  8004c1:	5f                   	pop    %edi
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c7:	83 fa 01             	cmp    $0x1,%edx
  8004ca:	7e 0e                	jle    8004da <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004cc:	8b 10                	mov    (%eax),%edx
  8004ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d1:	89 08                	mov    %ecx,(%eax)
  8004d3:	8b 02                	mov    (%edx),%eax
  8004d5:	8b 52 04             	mov    0x4(%edx),%edx
  8004d8:	eb 22                	jmp    8004fc <getuint+0x38>
	else if (lflag)
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	74 10                	je     8004ee <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e3:	89 08                	mov    %ecx,(%eax)
  8004e5:	8b 02                	mov    (%edx),%eax
  8004e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ec:	eb 0e                	jmp    8004fc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ee:	8b 10                	mov    (%eax),%edx
  8004f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f3:	89 08                	mov    %ecx,(%eax)
  8004f5:	8b 02                	mov    (%edx),%eax
  8004f7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800504:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800508:	8b 10                	mov    (%eax),%edx
  80050a:	3b 50 04             	cmp    0x4(%eax),%edx
  80050d:	73 0a                	jae    800519 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800512:	89 08                	mov    %ecx,(%eax)
  800514:	8b 45 08             	mov    0x8(%ebp),%eax
  800517:	88 02                	mov    %al,(%edx)
}
  800519:	5d                   	pop    %ebp
  80051a:	c3                   	ret    

0080051b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800521:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800524:	50                   	push   %eax
  800525:	ff 75 10             	pushl  0x10(%ebp)
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	ff 75 08             	pushl  0x8(%ebp)
  80052e:	e8 05 00 00 00       	call   800538 <vprintfmt>
	va_end(ap);
}
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	57                   	push   %edi
  80053c:	56                   	push   %esi
  80053d:	53                   	push   %ebx
  80053e:	83 ec 2c             	sub    $0x2c,%esp
  800541:	8b 75 08             	mov    0x8(%ebp),%esi
  800544:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800547:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054a:	eb 12                	jmp    80055e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80054c:	85 c0                	test   %eax,%eax
  80054e:	0f 84 d3 03 00 00    	je     800927 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	50                   	push   %eax
  800559:	ff d6                	call   *%esi
  80055b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055e:	83 c7 01             	add    $0x1,%edi
  800561:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800565:	83 f8 25             	cmp    $0x25,%eax
  800568:	75 e2                	jne    80054c <vprintfmt+0x14>
  80056a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800575:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80057c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800583:	ba 00 00 00 00       	mov    $0x0,%edx
  800588:	eb 07                	jmp    800591 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80058d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8d 47 01             	lea    0x1(%edi),%eax
  800594:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800597:	0f b6 07             	movzbl (%edi),%eax
  80059a:	0f b6 c8             	movzbl %al,%ecx
  80059d:	83 e8 23             	sub    $0x23,%eax
  8005a0:	3c 55                	cmp    $0x55,%al
  8005a2:	0f 87 64 03 00 00    	ja     80090c <vprintfmt+0x3d4>
  8005a8:	0f b6 c0             	movzbl %al,%eax
  8005ab:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b9:	eb d6                	jmp    800591 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005be:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005cd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005d0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005d3:	83 fa 09             	cmp    $0x9,%edx
  8005d6:	77 39                	ja     800611 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005db:	eb e9                	jmp    8005c6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ee:	eb 27                	jmp    800617 <vprintfmt+0xdf>
  8005f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fa:	0f 49 c8             	cmovns %eax,%ecx
  8005fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800603:	eb 8c                	jmp    800591 <vprintfmt+0x59>
  800605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800608:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060f:	eb 80                	jmp    800591 <vprintfmt+0x59>
  800611:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800614:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800617:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061b:	0f 89 70 ff ff ff    	jns    800591 <vprintfmt+0x59>
				width = precision, precision = -1;
  800621:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800624:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800627:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80062e:	e9 5e ff ff ff       	jmp    800591 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800633:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800639:	e9 53 ff ff ff       	jmp    800591 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	ff 30                	pushl  (%eax)
  80064d:	ff d6                	call   *%esi
			break;
  80064f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800655:	e9 04 ff ff ff       	jmp    80055e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	99                   	cltd   
  800666:	31 d0                	xor    %edx,%eax
  800668:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066a:	83 f8 08             	cmp    $0x8,%eax
  80066d:	7f 0b                	jg     80067a <vprintfmt+0x142>
  80066f:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800676:	85 d2                	test   %edx,%edx
  800678:	75 18                	jne    800692 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80067a:	50                   	push   %eax
  80067b:	68 36 10 80 00       	push   $0x801036
  800680:	53                   	push   %ebx
  800681:	56                   	push   %esi
  800682:	e8 94 fe ff ff       	call   80051b <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80068d:	e9 cc fe ff ff       	jmp    80055e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800692:	52                   	push   %edx
  800693:	68 3f 10 80 00       	push   $0x80103f
  800698:	53                   	push   %ebx
  800699:	56                   	push   %esi
  80069a:	e8 7c fe ff ff       	call   80051b <printfmt>
  80069f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a5:	e9 b4 fe ff ff       	jmp    80055e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 04             	lea    0x4(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b5:	85 ff                	test   %edi,%edi
  8006b7:	b8 2f 10 80 00       	mov    $0x80102f,%eax
  8006bc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c3:	0f 8e 94 00 00 00    	jle    80075d <vprintfmt+0x225>
  8006c9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006cd:	0f 84 98 00 00 00    	je     80076b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	ff 75 c8             	pushl  -0x38(%ebp)
  8006d9:	57                   	push   %edi
  8006da:	e8 d0 02 00 00       	call   8009af <strnlen>
  8006df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e2:	29 c1                	sub    %eax,%ecx
  8006e4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006e7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ea:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f6:	eb 0f                	jmp    800707 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ff:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800701:	83 ef 01             	sub    $0x1,%edi
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	85 ff                	test   %edi,%edi
  800709:	7f ed                	jg     8006f8 <vprintfmt+0x1c0>
  80070b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800711:	85 c9                	test   %ecx,%ecx
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
  800718:	0f 49 c1             	cmovns %ecx,%eax
  80071b:	29 c1                	sub    %eax,%ecx
  80071d:	89 75 08             	mov    %esi,0x8(%ebp)
  800720:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800723:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800726:	89 cb                	mov    %ecx,%ebx
  800728:	eb 4d                	jmp    800777 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072e:	74 1b                	je     80074b <vprintfmt+0x213>
  800730:	0f be c0             	movsbl %al,%eax
  800733:	83 e8 20             	sub    $0x20,%eax
  800736:	83 f8 5e             	cmp    $0x5e,%eax
  800739:	76 10                	jbe    80074b <vprintfmt+0x213>
					putch('?', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	ff 75 0c             	pushl  0xc(%ebp)
  800741:	6a 3f                	push   $0x3f
  800743:	ff 55 08             	call   *0x8(%ebp)
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb 0d                	jmp    800758 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	ff 75 0c             	pushl  0xc(%ebp)
  800751:	52                   	push   %edx
  800752:	ff 55 08             	call   *0x8(%ebp)
  800755:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800758:	83 eb 01             	sub    $0x1,%ebx
  80075b:	eb 1a                	jmp    800777 <vprintfmt+0x23f>
  80075d:	89 75 08             	mov    %esi,0x8(%ebp)
  800760:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800763:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800766:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800769:	eb 0c                	jmp    800777 <vprintfmt+0x23f>
  80076b:	89 75 08             	mov    %esi,0x8(%ebp)
  80076e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800771:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800774:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800777:	83 c7 01             	add    $0x1,%edi
  80077a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077e:	0f be d0             	movsbl %al,%edx
  800781:	85 d2                	test   %edx,%edx
  800783:	74 23                	je     8007a8 <vprintfmt+0x270>
  800785:	85 f6                	test   %esi,%esi
  800787:	78 a1                	js     80072a <vprintfmt+0x1f2>
  800789:	83 ee 01             	sub    $0x1,%esi
  80078c:	79 9c                	jns    80072a <vprintfmt+0x1f2>
  80078e:	89 df                	mov    %ebx,%edi
  800790:	8b 75 08             	mov    0x8(%ebp),%esi
  800793:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800796:	eb 18                	jmp    8007b0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	53                   	push   %ebx
  80079c:	6a 20                	push   $0x20
  80079e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a0:	83 ef 01             	sub    $0x1,%edi
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb 08                	jmp    8007b0 <vprintfmt+0x278>
  8007a8:	89 df                	mov    %ebx,%edi
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b0:	85 ff                	test   %edi,%edi
  8007b2:	7f e4                	jg     800798 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b7:	e9 a2 fd ff ff       	jmp    80055e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007bc:	83 fa 01             	cmp    $0x1,%edx
  8007bf:	7e 16                	jle    8007d7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 50 08             	lea    0x8(%eax),%edx
  8007c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ca:	8b 50 04             	mov    0x4(%eax),%edx
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007d2:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007d5:	eb 32                	jmp    800809 <vprintfmt+0x2d1>
	else if (lflag)
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	74 18                	je     8007f3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 50 04             	lea    0x4(%eax),%edx
  8007e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e4:	8b 00                	mov    (%eax),%eax
  8007e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007e9:	89 c1                	mov    %eax,%ecx
  8007eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007f1:	eb 16                	jmp    800809 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 50 04             	lea    0x4(%eax),%edx
  8007f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fc:	8b 00                	mov    (%eax),%eax
  8007fe:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800801:	89 c1                	mov    %eax,%ecx
  800803:	c1 f9 1f             	sar    $0x1f,%ecx
  800806:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800809:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80080c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80080f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800812:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800815:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80081e:	0f 89 b0 00 00 00    	jns    8008d4 <vprintfmt+0x39c>
				putch('-', putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	53                   	push   %ebx
  800828:	6a 2d                	push   $0x2d
  80082a:	ff d6                	call   *%esi
				num = -(long long) num;
  80082c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80082f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800832:	f7 d8                	neg    %eax
  800834:	83 d2 00             	adc    $0x0,%edx
  800837:	f7 da                	neg    %edx
  800839:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80083f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800842:	b8 0a 00 00 00       	mov    $0xa,%eax
  800847:	e9 88 00 00 00       	jmp    8008d4 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
  80084f:	e8 70 fc ff ff       	call   8004c4 <getuint>
  800854:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800857:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80085a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80085f:	eb 73                	jmp    8008d4 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800861:	8d 45 14             	lea    0x14(%ebp),%eax
  800864:	e8 5b fc ff ff       	call   8004c4 <getuint>
  800869:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80086c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 58                	push   $0x58
  800875:	ff d6                	call   *%esi
			putch('X', putdat);
  800877:	83 c4 08             	add    $0x8,%esp
  80087a:	53                   	push   %ebx
  80087b:	6a 58                	push   $0x58
  80087d:	ff d6                	call   *%esi
			putch('X', putdat);
  80087f:	83 c4 08             	add    $0x8,%esp
  800882:	53                   	push   %ebx
  800883:	6a 58                	push   $0x58
  800885:	ff d6                	call   *%esi
			goto number;
  800887:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80088a:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80088f:	eb 43                	jmp    8008d4 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800891:	83 ec 08             	sub    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	6a 30                	push   $0x30
  800897:	ff d6                	call   *%esi
			putch('x', putdat);
  800899:	83 c4 08             	add    $0x8,%esp
  80089c:	53                   	push   %ebx
  80089d:	6a 78                	push   $0x78
  80089f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8d 50 04             	lea    0x4(%eax),%edx
  8008a7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008bf:	eb 13                	jmp    8008d4 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c4:	e8 fb fb ff ff       	call   8004c4 <getuint>
  8008c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008cf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d4:	83 ec 0c             	sub    $0xc,%esp
  8008d7:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008db:	52                   	push   %edx
  8008dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8008df:	50                   	push   %eax
  8008e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8008e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8008e6:	89 da                	mov    %ebx,%edx
  8008e8:	89 f0                	mov    %esi,%eax
  8008ea:	e8 26 fb ff ff       	call   800415 <printnum>
			break;
  8008ef:	83 c4 20             	add    $0x20,%esp
  8008f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f5:	e9 64 fc ff ff       	jmp    80055e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008fa:	83 ec 08             	sub    $0x8,%esp
  8008fd:	53                   	push   %ebx
  8008fe:	51                   	push   %ecx
  8008ff:	ff d6                	call   *%esi
			break;
  800901:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800904:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800907:	e9 52 fc ff ff       	jmp    80055e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	53                   	push   %ebx
  800910:	6a 25                	push   $0x25
  800912:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800914:	83 c4 10             	add    $0x10,%esp
  800917:	eb 03                	jmp    80091c <vprintfmt+0x3e4>
  800919:	83 ef 01             	sub    $0x1,%edi
  80091c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800920:	75 f7                	jne    800919 <vprintfmt+0x3e1>
  800922:	e9 37 fc ff ff       	jmp    80055e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800927:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 18             	sub    $0x18,%esp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800942:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800945:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094c:	85 c0                	test   %eax,%eax
  80094e:	74 26                	je     800976 <vsnprintf+0x47>
  800950:	85 d2                	test   %edx,%edx
  800952:	7e 22                	jle    800976 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800954:	ff 75 14             	pushl  0x14(%ebp)
  800957:	ff 75 10             	pushl  0x10(%ebp)
  80095a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095d:	50                   	push   %eax
  80095e:	68 fe 04 80 00       	push   $0x8004fe
  800963:	e8 d0 fb ff ff       	call   800538 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800968:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80096b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	eb 05                	jmp    80097b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800976:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800983:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800986:	50                   	push   %eax
  800987:	ff 75 10             	pushl  0x10(%ebp)
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	ff 75 08             	pushl  0x8(%ebp)
  800990:	e8 9a ff ff ff       	call   80092f <vsnprintf>
	va_end(ap);

	return rc;
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a2:	eb 03                	jmp    8009a7 <strlen+0x10>
		n++;
  8009a4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ab:	75 f7                	jne    8009a4 <strlen+0xd>
		n++;
	return n;
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	eb 03                	jmp    8009c2 <strnlen+0x13>
		n++;
  8009bf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c2:	39 c2                	cmp    %eax,%edx
  8009c4:	74 08                	je     8009ce <strnlen+0x1f>
  8009c6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009ca:	75 f3                	jne    8009bf <strnlen+0x10>
  8009cc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	53                   	push   %ebx
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009da:	89 c2                	mov    %eax,%edx
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	83 c1 01             	add    $0x1,%ecx
  8009e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e9:	84 db                	test   %bl,%bl
  8009eb:	75 ef                	jne    8009dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	53                   	push   %ebx
  8009f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f7:	53                   	push   %ebx
  8009f8:	e8 9a ff ff ff       	call   800997 <strlen>
  8009fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	01 d8                	add    %ebx,%eax
  800a05:	50                   	push   %eax
  800a06:	e8 c5 ff ff ff       	call   8009d0 <strcpy>
	return dst;
}
  800a0b:	89 d8                	mov    %ebx,%eax
  800a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1d:	89 f3                	mov    %esi,%ebx
  800a1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a22:	89 f2                	mov    %esi,%edx
  800a24:	eb 0f                	jmp    800a35 <strncpy+0x23>
		*dst++ = *src;
  800a26:	83 c2 01             	add    $0x1,%edx
  800a29:	0f b6 01             	movzbl (%ecx),%eax
  800a2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a32:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a35:	39 da                	cmp    %ebx,%edx
  800a37:	75 ed                	jne    800a26 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a39:	89 f0                	mov    %esi,%eax
  800a3b:	5b                   	pop    %ebx
  800a3c:	5e                   	pop    %esi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 75 08             	mov    0x8(%ebp),%esi
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4f:	85 d2                	test   %edx,%edx
  800a51:	74 21                	je     800a74 <strlcpy+0x35>
  800a53:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a57:	89 f2                	mov    %esi,%edx
  800a59:	eb 09                	jmp    800a64 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a64:	39 c2                	cmp    %eax,%edx
  800a66:	74 09                	je     800a71 <strlcpy+0x32>
  800a68:	0f b6 19             	movzbl (%ecx),%ebx
  800a6b:	84 db                	test   %bl,%bl
  800a6d:	75 ec                	jne    800a5b <strlcpy+0x1c>
  800a6f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a71:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a74:	29 f0                	sub    %esi,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a83:	eb 06                	jmp    800a8b <strcmp+0x11>
		p++, q++;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	84 c0                	test   %al,%al
  800a90:	74 04                	je     800a96 <strcmp+0x1c>
  800a92:	3a 02                	cmp    (%edx),%al
  800a94:	74 ef                	je     800a85 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a96:	0f b6 c0             	movzbl %al,%eax
  800a99:	0f b6 12             	movzbl (%edx),%edx
  800a9c:	29 d0                	sub    %edx,%eax
}
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaa:	89 c3                	mov    %eax,%ebx
  800aac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aaf:	eb 06                	jmp    800ab7 <strncmp+0x17>
		n--, p++, q++;
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab7:	39 d8                	cmp    %ebx,%eax
  800ab9:	74 15                	je     800ad0 <strncmp+0x30>
  800abb:	0f b6 08             	movzbl (%eax),%ecx
  800abe:	84 c9                	test   %cl,%cl
  800ac0:	74 04                	je     800ac6 <strncmp+0x26>
  800ac2:	3a 0a                	cmp    (%edx),%cl
  800ac4:	74 eb                	je     800ab1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac6:	0f b6 00             	movzbl (%eax),%eax
  800ac9:	0f b6 12             	movzbl (%edx),%edx
  800acc:	29 d0                	sub    %edx,%eax
  800ace:	eb 05                	jmp    800ad5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae2:	eb 07                	jmp    800aeb <strchr+0x13>
		if (*s == c)
  800ae4:	38 ca                	cmp    %cl,%dl
  800ae6:	74 0f                	je     800af7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae8:	83 c0 01             	add    $0x1,%eax
  800aeb:	0f b6 10             	movzbl (%eax),%edx
  800aee:	84 d2                	test   %dl,%dl
  800af0:	75 f2                	jne    800ae4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b03:	eb 03                	jmp    800b08 <strfind+0xf>
  800b05:	83 c0 01             	add    $0x1,%eax
  800b08:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b0b:	38 ca                	cmp    %cl,%dl
  800b0d:	74 04                	je     800b13 <strfind+0x1a>
  800b0f:	84 d2                	test   %dl,%dl
  800b11:	75 f2                	jne    800b05 <strfind+0xc>
			break;
	return (char *) s;
}
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b21:	85 c9                	test   %ecx,%ecx
  800b23:	74 36                	je     800b5b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2b:	75 28                	jne    800b55 <memset+0x40>
  800b2d:	f6 c1 03             	test   $0x3,%cl
  800b30:	75 23                	jne    800b55 <memset+0x40>
		c &= 0xFF;
  800b32:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	c1 e3 08             	shl    $0x8,%ebx
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	c1 e6 18             	shl    $0x18,%esi
  800b40:	89 d0                	mov    %edx,%eax
  800b42:	c1 e0 10             	shl    $0x10,%eax
  800b45:	09 f0                	or     %esi,%eax
  800b47:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b49:	89 d8                	mov    %ebx,%eax
  800b4b:	09 d0                	or     %edx,%eax
  800b4d:	c1 e9 02             	shr    $0x2,%ecx
  800b50:	fc                   	cld    
  800b51:	f3 ab                	rep stos %eax,%es:(%edi)
  800b53:	eb 06                	jmp    800b5b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	fc                   	cld    
  800b59:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5b:	89 f8                	mov    %edi,%eax
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b70:	39 c6                	cmp    %eax,%esi
  800b72:	73 35                	jae    800ba9 <memmove+0x47>
  800b74:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b77:	39 d0                	cmp    %edx,%eax
  800b79:	73 2e                	jae    800ba9 <memmove+0x47>
		s += n;
		d += n;
  800b7b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	09 fe                	or     %edi,%esi
  800b82:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b88:	75 13                	jne    800b9d <memmove+0x3b>
  800b8a:	f6 c1 03             	test   $0x3,%cl
  800b8d:	75 0e                	jne    800b9d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b8f:	83 ef 04             	sub    $0x4,%edi
  800b92:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b95:	c1 e9 02             	shr    $0x2,%ecx
  800b98:	fd                   	std    
  800b99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9b:	eb 09                	jmp    800ba6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9d:	83 ef 01             	sub    $0x1,%edi
  800ba0:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba3:	fd                   	std    
  800ba4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba6:	fc                   	cld    
  800ba7:	eb 1d                	jmp    800bc6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba9:	89 f2                	mov    %esi,%edx
  800bab:	09 c2                	or     %eax,%edx
  800bad:	f6 c2 03             	test   $0x3,%dl
  800bb0:	75 0f                	jne    800bc1 <memmove+0x5f>
  800bb2:	f6 c1 03             	test   $0x3,%cl
  800bb5:	75 0a                	jne    800bc1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb7:	c1 e9 02             	shr    $0x2,%ecx
  800bba:	89 c7                	mov    %eax,%edi
  800bbc:	fc                   	cld    
  800bbd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbf:	eb 05                	jmp    800bc6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc1:	89 c7                	mov    %eax,%edi
  800bc3:	fc                   	cld    
  800bc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bcd:	ff 75 10             	pushl  0x10(%ebp)
  800bd0:	ff 75 0c             	pushl  0xc(%ebp)
  800bd3:	ff 75 08             	pushl  0x8(%ebp)
  800bd6:	e8 87 ff ff ff       	call   800b62 <memmove>
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be8:	89 c6                	mov    %eax,%esi
  800bea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bed:	eb 1a                	jmp    800c09 <memcmp+0x2c>
		if (*s1 != *s2)
  800bef:	0f b6 08             	movzbl (%eax),%ecx
  800bf2:	0f b6 1a             	movzbl (%edx),%ebx
  800bf5:	38 d9                	cmp    %bl,%cl
  800bf7:	74 0a                	je     800c03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf9:	0f b6 c1             	movzbl %cl,%eax
  800bfc:	0f b6 db             	movzbl %bl,%ebx
  800bff:	29 d8                	sub    %ebx,%eax
  800c01:	eb 0f                	jmp    800c12 <memcmp+0x35>
		s1++, s2++;
  800c03:	83 c0 01             	add    $0x1,%eax
  800c06:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c09:	39 f0                	cmp    %esi,%eax
  800c0b:	75 e2                	jne    800bef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	53                   	push   %ebx
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1d:	89 c1                	mov    %eax,%ecx
  800c1f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c22:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c26:	eb 0a                	jmp    800c32 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c28:	0f b6 10             	movzbl (%eax),%edx
  800c2b:	39 da                	cmp    %ebx,%edx
  800c2d:	74 07                	je     800c36 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2f:	83 c0 01             	add    $0x1,%eax
  800c32:	39 c8                	cmp    %ecx,%eax
  800c34:	72 f2                	jb     800c28 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c36:	5b                   	pop    %ebx
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c45:	eb 03                	jmp    800c4a <strtol+0x11>
		s++;
  800c47:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4a:	0f b6 01             	movzbl (%ecx),%eax
  800c4d:	3c 20                	cmp    $0x20,%al
  800c4f:	74 f6                	je     800c47 <strtol+0xe>
  800c51:	3c 09                	cmp    $0x9,%al
  800c53:	74 f2                	je     800c47 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c55:	3c 2b                	cmp    $0x2b,%al
  800c57:	75 0a                	jne    800c63 <strtol+0x2a>
		s++;
  800c59:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c61:	eb 11                	jmp    800c74 <strtol+0x3b>
  800c63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c68:	3c 2d                	cmp    $0x2d,%al
  800c6a:	75 08                	jne    800c74 <strtol+0x3b>
		s++, neg = 1;
  800c6c:	83 c1 01             	add    $0x1,%ecx
  800c6f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c7a:	75 15                	jne    800c91 <strtol+0x58>
  800c7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7f:	75 10                	jne    800c91 <strtol+0x58>
  800c81:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c85:	75 7c                	jne    800d03 <strtol+0xca>
		s += 2, base = 16;
  800c87:	83 c1 02             	add    $0x2,%ecx
  800c8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8f:	eb 16                	jmp    800ca7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c91:	85 db                	test   %ebx,%ebx
  800c93:	75 12                	jne    800ca7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9d:	75 08                	jne    800ca7 <strtol+0x6e>
		s++, base = 8;
  800c9f:	83 c1 01             	add    $0x1,%ecx
  800ca2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800caf:	0f b6 11             	movzbl (%ecx),%edx
  800cb2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb5:	89 f3                	mov    %esi,%ebx
  800cb7:	80 fb 09             	cmp    $0x9,%bl
  800cba:	77 08                	ja     800cc4 <strtol+0x8b>
			dig = *s - '0';
  800cbc:	0f be d2             	movsbl %dl,%edx
  800cbf:	83 ea 30             	sub    $0x30,%edx
  800cc2:	eb 22                	jmp    800ce6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc7:	89 f3                	mov    %esi,%ebx
  800cc9:	80 fb 19             	cmp    $0x19,%bl
  800ccc:	77 08                	ja     800cd6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cce:	0f be d2             	movsbl %dl,%edx
  800cd1:	83 ea 57             	sub    $0x57,%edx
  800cd4:	eb 10                	jmp    800ce6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd9:	89 f3                	mov    %esi,%ebx
  800cdb:	80 fb 19             	cmp    $0x19,%bl
  800cde:	77 16                	ja     800cf6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ce0:	0f be d2             	movsbl %dl,%edx
  800ce3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce9:	7d 0b                	jge    800cf6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ceb:	83 c1 01             	add    $0x1,%ecx
  800cee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf4:	eb b9                	jmp    800caf <strtol+0x76>

	if (endptr)
  800cf6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cfa:	74 0d                	je     800d09 <strtol+0xd0>
		*endptr = (char *) s;
  800cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cff:	89 0e                	mov    %ecx,(%esi)
  800d01:	eb 06                	jmp    800d09 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d03:	85 db                	test   %ebx,%ebx
  800d05:	74 98                	je     800c9f <strtol+0x66>
  800d07:	eb 9e                	jmp    800ca7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d09:	89 c2                	mov    %eax,%edx
  800d0b:	f7 da                	neg    %edx
  800d0d:	85 ff                	test   %edi,%edi
  800d0f:	0f 45 c2             	cmovne %edx,%eax
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    
  800d17:	66 90                	xchg   %ax,%ax
  800d19:	66 90                	xchg   %ax,%ax
  800d1b:	66 90                	xchg   %ax,%ax
  800d1d:	66 90                	xchg   %ax,%ax
  800d1f:	90                   	nop

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
