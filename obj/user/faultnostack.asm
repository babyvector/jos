
obj/user/faultnostack.debug:     file format elf32-i386


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
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
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
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ab 04 00 00       	call   800550 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 6a 1e 80 00       	push   $0x801e6a
  80011e:	6a 23                	push   $0x23
  800120:	68 87 1e 80 00       	push   $0x801e87
  800125:	e8 3e 0f 00 00       	call   801068 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 6a 1e 80 00       	push   $0x801e6a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 87 1e 80 00       	push   $0x801e87
  8001a6:	e8 bd 0e 00 00       	call   801068 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 6a 1e 80 00       	push   $0x801e6a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 87 1e 80 00       	push   $0x801e87
  8001e8:	e8 7b 0e 00 00       	call   801068 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 6a 1e 80 00       	push   $0x801e6a
  800223:	6a 23                	push   $0x23
  800225:	68 87 1e 80 00       	push   $0x801e87
  80022a:	e8 39 0e 00 00       	call   801068 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 6a 1e 80 00       	push   $0x801e6a
  800265:	6a 23                	push   $0x23
  800267:	68 87 1e 80 00       	push   $0x801e87
  80026c:	e8 f7 0d 00 00       	call   801068 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 6a 1e 80 00       	push   $0x801e6a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 87 1e 80 00       	push   $0x801e87
  8002ae:	e8 b5 0d 00 00       	call   801068 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 6a 1e 80 00       	push   $0x801e6a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 87 1e 80 00       	push   $0x801e87
  8002f0:	e8 73 0d 00 00       	call   801068 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 6a 1e 80 00       	push   $0x801e6a
  80034d:	6a 23                	push   $0x23
  80034f:	68 87 1e 80 00       	push   $0x801e87
  800354:	e8 0f 0d 00 00       	call   801068 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  80036c:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  800370:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  800375:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  800379:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  80037b:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  80037e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  80037f:	83 c4 04             	add    $0x4,%esp
	popfl
  800382:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800383:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800384:	c3                   	ret    

00800385 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	05 00 00 00 30       	add    $0x30000000,%eax
  800390:	c1 e8 0c             	shr    $0xc,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b7:	89 c2                	mov    %eax,%edx
  8003b9:	c1 ea 16             	shr    $0x16,%edx
  8003bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c3:	f6 c2 01             	test   $0x1,%dl
  8003c6:	74 11                	je     8003d9 <fd_alloc+0x2d>
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 0c             	shr    $0xc,%edx
  8003cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	75 09                	jne    8003e2 <fd_alloc+0x36>
			*fd_store = fd;
  8003d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	eb 17                	jmp    8003f9 <fd_alloc+0x4d>
  8003e2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ec:	75 c9                	jne    8003b7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800401:	83 f8 1f             	cmp    $0x1f,%eax
  800404:	77 36                	ja     80043c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800406:	c1 e0 0c             	shl    $0xc,%eax
  800409:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040e:	89 c2                	mov    %eax,%edx
  800410:	c1 ea 16             	shr    $0x16,%edx
  800413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041a:	f6 c2 01             	test   $0x1,%dl
  80041d:	74 24                	je     800443 <fd_lookup+0x48>
  80041f:	89 c2                	mov    %eax,%edx
  800421:	c1 ea 0c             	shr    $0xc,%edx
  800424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042b:	f6 c2 01             	test   $0x1,%dl
  80042e:	74 1a                	je     80044a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 02                	mov    %eax,(%edx)
	return 0;
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	eb 13                	jmp    80044f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800441:	eb 0c                	jmp    80044f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800448:	eb 05                	jmp    80044f <fd_lookup+0x54>
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045a:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80045f:	eb 13                	jmp    800474 <dev_lookup+0x23>
  800461:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800464:	39 08                	cmp    %ecx,(%eax)
  800466:	75 0c                	jne    800474 <dev_lookup+0x23>
			*dev = devtab[i];
  800468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb 2e                	jmp    8004a2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800474:	8b 02                	mov    (%edx),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	75 e7                	jne    800461 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047a:	a1 04 40 80 00       	mov    0x804004,%eax
  80047f:	8b 40 48             	mov    0x48(%eax),%eax
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	51                   	push   %ecx
  800486:	50                   	push   %eax
  800487:	68 98 1e 80 00       	push   $0x801e98
  80048c:	e8 b0 0c 00 00       	call   801141 <cprintf>
	*dev = 0;
  800491:	8b 45 0c             	mov    0xc(%ebp),%eax
  800494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	56                   	push   %esi
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 10             	sub    $0x10,%esp
  8004ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004bc:	c1 e8 0c             	shr    $0xc,%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 36 ff ff ff       	call   8003fb <fd_lookup>
  8004c5:	83 c4 08             	add    $0x8,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 05                	js     8004d1 <fd_close+0x2d>
	    || fd != fd2)
  8004cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004cf:	74 0c                	je     8004dd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d1:	84 db                	test   %bl,%bl
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	0f 44 c2             	cmove  %edx,%eax
  8004db:	eb 41                	jmp    80051e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e3:	50                   	push   %eax
  8004e4:	ff 36                	pushl  (%esi)
  8004e6:	e8 66 ff ff ff       	call   800451 <dev_lookup>
  8004eb:	89 c3                	mov    %eax,%ebx
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	78 1a                	js     80050e <fd_close+0x6a>
		if (dev->dev_close)
  8004f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ff:	85 c0                	test   %eax,%eax
  800501:	74 0b                	je     80050e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	56                   	push   %esi
  800507:	ff d0                	call   *%eax
  800509:	89 c3                	mov    %eax,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	6a 00                	push   $0x0
  800514:	e8 dc fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	89 d8                	mov    %ebx,%eax
}
  80051e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800521:	5b                   	pop    %ebx
  800522:	5e                   	pop    %esi
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 c4 fe ff ff       	call   8003fb <fd_lookup>
  800537:	83 c4 08             	add    $0x8,%esp
  80053a:	85 c0                	test   %eax,%eax
  80053c:	78 10                	js     80054e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	6a 01                	push   $0x1
  800543:	ff 75 f4             	pushl  -0xc(%ebp)
  800546:	e8 59 ff ff ff       	call   8004a4 <fd_close>
  80054b:	83 c4 10             	add    $0x10,%esp
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <close_all>:

void
close_all(void)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	53                   	push   %ebx
  800554:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800557:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055c:	83 ec 0c             	sub    $0xc,%esp
  80055f:	53                   	push   %ebx
  800560:	e8 c0 ff ff ff       	call   800525 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	83 c3 01             	add    $0x1,%ebx
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	83 fb 20             	cmp    $0x20,%ebx
  80056e:	75 ec                	jne    80055c <close_all+0xc>
		close(i);
}
  800570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	57                   	push   %edi
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
  80057b:	83 ec 2c             	sub    $0x2c,%esp
  80057e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800584:	50                   	push   %eax
  800585:	ff 75 08             	pushl  0x8(%ebp)
  800588:	e8 6e fe ff ff       	call   8003fb <fd_lookup>
  80058d:	83 c4 08             	add    $0x8,%esp
  800590:	85 c0                	test   %eax,%eax
  800592:	0f 88 c1 00 00 00    	js     800659 <dup+0xe4>
		return r;
	close(newfdnum);
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	56                   	push   %esi
  80059c:	e8 84 ff ff ff       	call   800525 <close>

	newfd = INDEX2FD(newfdnum);
  8005a1:	89 f3                	mov    %esi,%ebx
  8005a3:	c1 e3 0c             	shl    $0xc,%ebx
  8005a6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ac:	83 c4 04             	add    $0x4,%esp
  8005af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b2:	e8 de fd ff ff       	call   800395 <fd2data>
  8005b7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005b9:	89 1c 24             	mov    %ebx,(%esp)
  8005bc:	e8 d4 fd ff ff       	call   800395 <fd2data>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c7:	89 f8                	mov    %edi,%eax
  8005c9:	c1 e8 16             	shr    $0x16,%eax
  8005cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d3:	a8 01                	test   $0x1,%al
  8005d5:	74 37                	je     80060e <dup+0x99>
  8005d7:	89 f8                	mov    %edi,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e3:	f6 c2 01             	test   $0x1,%dl
  8005e6:	74 26                	je     80060e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fb:	6a 00                	push   $0x0
  8005fd:	57                   	push   %edi
  8005fe:	6a 00                	push   $0x0
  800600:	e8 ae fb ff ff       	call   8001b3 <sys_page_map>
  800605:	89 c7                	mov    %eax,%edi
  800607:	83 c4 20             	add    $0x20,%esp
  80060a:	85 c0                	test   %eax,%eax
  80060c:	78 2e                	js     80063c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800611:	89 d0                	mov    %edx,%eax
  800613:	c1 e8 0c             	shr    $0xc,%eax
  800616:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061d:	83 ec 0c             	sub    $0xc,%esp
  800620:	25 07 0e 00 00       	and    $0xe07,%eax
  800625:	50                   	push   %eax
  800626:	53                   	push   %ebx
  800627:	6a 00                	push   $0x0
  800629:	52                   	push   %edx
  80062a:	6a 00                	push   $0x0
  80062c:	e8 82 fb ff ff       	call   8001b3 <sys_page_map>
  800631:	89 c7                	mov    %eax,%edi
  800633:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800636:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800638:	85 ff                	test   %edi,%edi
  80063a:	79 1d                	jns    800659 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 00                	push   $0x0
  800642:	e8 ae fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064d:	6a 00                	push   $0x0
  80064f:	e8 a1 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	89 f8                	mov    %edi,%eax
}
  800659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5e                   	pop    %esi
  80065e:	5f                   	pop    %edi
  80065f:	5d                   	pop    %ebp
  800660:	c3                   	ret    

00800661 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	53                   	push   %ebx
  800665:	83 ec 14             	sub    $0x14,%esp
  800668:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80066e:	50                   	push   %eax
  80066f:	53                   	push   %ebx
  800670:	e8 86 fd ff ff       	call   8003fb <fd_lookup>
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	89 c2                	mov    %eax,%edx
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 6d                	js     8006eb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800684:	50                   	push   %eax
  800685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800688:	ff 30                	pushl  (%eax)
  80068a:	e8 c2 fd ff ff       	call   800451 <dev_lookup>
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	85 c0                	test   %eax,%eax
  800694:	78 4c                	js     8006e2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800696:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800699:	8b 42 08             	mov    0x8(%edx),%eax
  80069c:	83 e0 03             	and    $0x3,%eax
  80069f:	83 f8 01             	cmp    $0x1,%eax
  8006a2:	75 21                	jne    8006c5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a9:	8b 40 48             	mov    0x48(%eax),%eax
  8006ac:	83 ec 04             	sub    $0x4,%esp
  8006af:	53                   	push   %ebx
  8006b0:	50                   	push   %eax
  8006b1:	68 d9 1e 80 00       	push   $0x801ed9
  8006b6:	e8 86 0a 00 00       	call   801141 <cprintf>
		return -E_INVAL;
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c3:	eb 26                	jmp    8006eb <read+0x8a>
	}
	if (!dev->dev_read)
  8006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c8:	8b 40 08             	mov    0x8(%eax),%eax
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 17                	je     8006e6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	52                   	push   %edx
  8006d9:	ff d0                	call   *%eax
  8006db:	89 c2                	mov    %eax,%edx
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 09                	jmp    8006eb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e2:	89 c2                	mov    %eax,%edx
  8006e4:	eb 05                	jmp    8006eb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006eb:	89 d0                	mov    %edx,%eax
  8006ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	57                   	push   %edi
  8006f6:	56                   	push   %esi
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800701:	bb 00 00 00 00       	mov    $0x0,%ebx
  800706:	eb 21                	jmp    800729 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800708:	83 ec 04             	sub    $0x4,%esp
  80070b:	89 f0                	mov    %esi,%eax
  80070d:	29 d8                	sub    %ebx,%eax
  80070f:	50                   	push   %eax
  800710:	89 d8                	mov    %ebx,%eax
  800712:	03 45 0c             	add    0xc(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	57                   	push   %edi
  800717:	e8 45 ff ff ff       	call   800661 <read>
		if (m < 0)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	78 10                	js     800733 <readn+0x41>
			return m;
		if (m == 0)
  800723:	85 c0                	test   %eax,%eax
  800725:	74 0a                	je     800731 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800727:	01 c3                	add    %eax,%ebx
  800729:	39 f3                	cmp    %esi,%ebx
  80072b:	72 db                	jb     800708 <readn+0x16>
  80072d:	89 d8                	mov    %ebx,%eax
  80072f:	eb 02                	jmp    800733 <readn+0x41>
  800731:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	83 ec 14             	sub    $0x14,%esp
  800742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	53                   	push   %ebx
  80074a:	e8 ac fc ff ff       	call   8003fb <fd_lookup>
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	89 c2                	mov    %eax,%edx
  800754:	85 c0                	test   %eax,%eax
  800756:	78 68                	js     8007c0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800762:	ff 30                	pushl  (%eax)
  800764:	e8 e8 fc ff ff       	call   800451 <dev_lookup>
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 47                	js     8007b7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800773:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800777:	75 21                	jne    80079a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800779:	a1 04 40 80 00       	mov    0x804004,%eax
  80077e:	8b 40 48             	mov    0x48(%eax),%eax
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	68 f5 1e 80 00       	push   $0x801ef5
  80078b:	e8 b1 09 00 00       	call   801141 <cprintf>
		return -E_INVAL;
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800798:	eb 26                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079d:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	74 17                	je     8007bb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	50                   	push   %eax
  8007ae:	ff d2                	call   *%edx
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 09                	jmp    8007c0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	eb 05                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c0:	89 d0                	mov    %edx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 22 fc ff ff       	call   8003fb <fd_lookup>
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 0e                	js     8007ee <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 14             	sub    $0x14,%esp
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fd:	50                   	push   %eax
  8007fe:	53                   	push   %ebx
  8007ff:	e8 f7 fb ff ff       	call   8003fb <fd_lookup>
  800804:	83 c4 08             	add    $0x8,%esp
  800807:	89 c2                	mov    %eax,%edx
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 65                	js     800872 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	ff 30                	pushl  (%eax)
  800819:	e8 33 fc ff ff       	call   800451 <dev_lookup>
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	85 c0                	test   %eax,%eax
  800823:	78 44                	js     800869 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082c:	75 21                	jne    80084f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800833:	8b 40 48             	mov    0x48(%eax),%eax
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	53                   	push   %ebx
  80083a:	50                   	push   %eax
  80083b:	68 b8 1e 80 00       	push   $0x801eb8
  800840:	e8 fc 08 00 00       	call   801141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084d:	eb 23                	jmp    800872 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80084f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800852:	8b 52 18             	mov    0x18(%edx),%edx
  800855:	85 d2                	test   %edx,%edx
  800857:	74 14                	je     80086d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	50                   	push   %eax
  800860:	ff d2                	call   *%edx
  800862:	89 c2                	mov    %eax,%edx
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb 09                	jmp    800872 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800869:	89 c2                	mov    %eax,%edx
  80086b:	eb 05                	jmp    800872 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800872:	89 d0                	mov    %edx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 14             	sub    $0x14,%esp
  800880:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800883:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 6c fb ff ff       	call   8003fb <fd_lookup>
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	89 c2                	mov    %eax,%edx
  800894:	85 c0                	test   %eax,%eax
  800896:	78 58                	js     8008f0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089e:	50                   	push   %eax
  80089f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a2:	ff 30                	pushl  (%eax)
  8008a4:	e8 a8 fb ff ff       	call   800451 <dev_lookup>
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 37                	js     8008e7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b7:	74 32                	je     8008eb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c3:	00 00 00 
	stat->st_isdir = 0;
  8008c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cd:	00 00 00 
	stat->st_dev = dev;
  8008d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	ff 75 f0             	pushl  -0x10(%ebp)
  8008dd:	ff 50 14             	call   *0x14(%eax)
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 09                	jmp    8008f0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	eb 05                	jmp    8008f0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	6a 00                	push   $0x0
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 dc 01 00 00       	call   800ae5 <open>
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	85 c0                	test   %eax,%eax
  800910:	78 1b                	js     80092d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	50                   	push   %eax
  800919:	e8 5b ff ff ff       	call   800879 <fstat>
  80091e:	89 c6                	mov    %eax,%esi
	close(fd);
  800920:	89 1c 24             	mov    %ebx,(%esp)
  800923:	e8 fd fb ff ff       	call   800525 <close>
	return r;
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	89 f0                	mov    %esi,%eax
}
  80092d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800944:	75 12                	jne    800958 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	6a 01                	push   $0x1
  80094b:	e8 0c 12 00 00       	call   801b5c <ipc_find_env>
  800950:	a3 00 40 80 00       	mov    %eax,0x804000
  800955:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800958:	6a 07                	push   $0x7
  80095a:	68 00 50 80 00       	push   $0x805000
  80095f:	56                   	push   %esi
  800960:	ff 35 00 40 80 00    	pushl  0x804000
  800966:	e8 ae 11 00 00       	call   801b19 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	53                   	push   %ebx
  800971:	6a 00                	push   $0x0
  800973:	e8 44 11 00 00       	call   801abc <ipc_recv>
}
  800978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a2:	e8 8d ff ff ff       	call   800934 <fsipc>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c4:	e8 6b ff ff ff       	call   800934 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 04             	sub    $0x4,%esp
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ea:	e8 45 ff ff ff       	call   800934 <fsipc>
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	78 2c                	js     800a1f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	68 00 50 80 00       	push   $0x805000
  8009fb:	53                   	push   %ebx
  8009fc:	e8 0f 0d 00 00       	call   801710 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a01:	a1 80 50 80 00       	mov    0x805080,%eax
  800a06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a11:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a17:	83 c4 10             	add    $0x10,%esp
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 0c             	sub    $0xc,%esp
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a30:	8b 52 0c             	mov    0xc(%edx),%edx
  800a33:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a39:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a3e:	50                   	push   %eax
  800a3f:	ff 75 0c             	pushl  0xc(%ebp)
  800a42:	68 08 50 80 00       	push   $0x805008
  800a47:	e8 56 0e 00 00       	call   8018a2 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 04 00 00 00       	mov    $0x4,%eax
  800a56:	e8 d9 fe ff ff       	call   800934 <fsipc>
	//panic("devfile_write not implemented");
}
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a70:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a76:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a80:	e8 af fe ff ff       	call   800934 <fsipc>
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	85 c0                	test   %eax,%eax
  800a89:	78 51                	js     800adc <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a8b:	39 c6                	cmp    %eax,%esi
  800a8d:	73 19                	jae    800aa8 <devfile_read+0x4b>
  800a8f:	68 24 1f 80 00       	push   $0x801f24
  800a94:	68 2b 1f 80 00       	push   $0x801f2b
  800a99:	68 80 00 00 00       	push   $0x80
  800a9e:	68 40 1f 80 00       	push   $0x801f40
  800aa3:	e8 c0 05 00 00       	call   801068 <_panic>
	assert(r <= PGSIZE);
  800aa8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aad:	7e 19                	jle    800ac8 <devfile_read+0x6b>
  800aaf:	68 4b 1f 80 00       	push   $0x801f4b
  800ab4:	68 2b 1f 80 00       	push   $0x801f2b
  800ab9:	68 81 00 00 00       	push   $0x81
  800abe:	68 40 1f 80 00       	push   $0x801f40
  800ac3:	e8 a0 05 00 00       	call   801068 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ac8:	83 ec 04             	sub    $0x4,%esp
  800acb:	50                   	push   %eax
  800acc:	68 00 50 80 00       	push   $0x805000
  800ad1:	ff 75 0c             	pushl  0xc(%ebp)
  800ad4:	e8 c9 0d 00 00       	call   8018a2 <memmove>
	return r;
  800ad9:	83 c4 10             	add    $0x10,%esp
}
  800adc:	89 d8                	mov    %ebx,%eax
  800ade:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 20             	sub    $0x20,%esp
  800aec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aef:	53                   	push   %ebx
  800af0:	e8 e2 0b 00 00       	call   8016d7 <strlen>
  800af5:	83 c4 10             	add    $0x10,%esp
  800af8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800afd:	7f 67                	jg     800b66 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b05:	50                   	push   %eax
  800b06:	e8 a1 f8 ff ff       	call   8003ac <fd_alloc>
  800b0b:	83 c4 10             	add    $0x10,%esp
		return r;
  800b0e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b10:	85 c0                	test   %eax,%eax
  800b12:	78 57                	js     800b6b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b14:	83 ec 08             	sub    $0x8,%esp
  800b17:	53                   	push   %ebx
  800b18:	68 00 50 80 00       	push   $0x805000
  800b1d:	e8 ee 0b 00 00       	call   801710 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b32:	e8 fd fd ff ff       	call   800934 <fsipc>
  800b37:	89 c3                	mov    %eax,%ebx
  800b39:	83 c4 10             	add    $0x10,%esp
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	79 14                	jns    800b54 <open+0x6f>
		
		fd_close(fd, 0);
  800b40:	83 ec 08             	sub    $0x8,%esp
  800b43:	6a 00                	push   $0x0
  800b45:	ff 75 f4             	pushl  -0xc(%ebp)
  800b48:	e8 57 f9 ff ff       	call   8004a4 <fd_close>
		return r;
  800b4d:	83 c4 10             	add    $0x10,%esp
  800b50:	89 da                	mov    %ebx,%edx
  800b52:	eb 17                	jmp    800b6b <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5a:	e8 26 f8 ff ff       	call   800385 <fd2num>
  800b5f:	89 c2                	mov    %eax,%edx
  800b61:	83 c4 10             	add    $0x10,%esp
  800b64:	eb 05                	jmp    800b6b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b66:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  800b6b:	89 d0                	mov    %edx,%eax
  800b6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    

00800b72 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b82:	e8 ad fd ff ff       	call   800934 <fsipc>
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	ff 75 08             	pushl  0x8(%ebp)
  800b97:	e8 f9 f7 ff ff       	call   800395 <fd2data>
  800b9c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b9e:	83 c4 08             	add    $0x8,%esp
  800ba1:	68 57 1f 80 00       	push   $0x801f57
  800ba6:	53                   	push   %ebx
  800ba7:	e8 64 0b 00 00       	call   801710 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bac:	8b 46 04             	mov    0x4(%esi),%eax
  800baf:	2b 06                	sub    (%esi),%eax
  800bb1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bbe:	00 00 00 
	stat->st_dev = &devpipe;
  800bc1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc8:	30 80 00 
	return 0;
}
  800bcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be1:	53                   	push   %ebx
  800be2:	6a 00                	push   $0x0
  800be4:	e8 0c f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be9:	89 1c 24             	mov    %ebx,(%esp)
  800bec:	e8 a4 f7 ff ff       	call   800395 <fd2data>
  800bf1:	83 c4 08             	add    $0x8,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 00                	push   $0x0
  800bf7:	e8 f9 f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800bfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 1c             	sub    $0x1c,%esp
  800c0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c0d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c0f:	a1 04 40 80 00       	mov    0x804004,%eax
  800c14:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	ff 75 e0             	pushl  -0x20(%ebp)
  800c1d:	e8 73 0f 00 00       	call   801b95 <pageref>
  800c22:	89 c3                	mov    %eax,%ebx
  800c24:	89 3c 24             	mov    %edi,(%esp)
  800c27:	e8 69 0f 00 00       	call   801b95 <pageref>
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	39 c3                	cmp    %eax,%ebx
  800c31:	0f 94 c1             	sete   %cl
  800c34:	0f b6 c9             	movzbl %cl,%ecx
  800c37:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c3a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c40:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c43:	39 ce                	cmp    %ecx,%esi
  800c45:	74 1b                	je     800c62 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c47:	39 c3                	cmp    %eax,%ebx
  800c49:	75 c4                	jne    800c0f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c4b:	8b 42 58             	mov    0x58(%edx),%eax
  800c4e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c51:	50                   	push   %eax
  800c52:	56                   	push   %esi
  800c53:	68 5e 1f 80 00       	push   $0x801f5e
  800c58:	e8 e4 04 00 00       	call   801141 <cprintf>
  800c5d:	83 c4 10             	add    $0x10,%esp
  800c60:	eb ad                	jmp    800c0f <_pipeisclosed+0xe>
	}
}
  800c62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 28             	sub    $0x28,%esp
  800c76:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c79:	56                   	push   %esi
  800c7a:	e8 16 f7 ff ff       	call   800395 <fd2data>
  800c7f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c81:	83 c4 10             	add    $0x10,%esp
  800c84:	bf 00 00 00 00       	mov    $0x0,%edi
  800c89:	eb 4b                	jmp    800cd6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c8b:	89 da                	mov    %ebx,%edx
  800c8d:	89 f0                	mov    %esi,%eax
  800c8f:	e8 6d ff ff ff       	call   800c01 <_pipeisclosed>
  800c94:	85 c0                	test   %eax,%eax
  800c96:	75 48                	jne    800ce0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c98:	e8 b4 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c9d:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca0:	8b 0b                	mov    (%ebx),%ecx
  800ca2:	8d 51 20             	lea    0x20(%ecx),%edx
  800ca5:	39 d0                	cmp    %edx,%eax
  800ca7:	73 e2                	jae    800c8b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb3:	89 c2                	mov    %eax,%edx
  800cb5:	c1 fa 1f             	sar    $0x1f,%edx
  800cb8:	89 d1                	mov    %edx,%ecx
  800cba:	c1 e9 1b             	shr    $0x1b,%ecx
  800cbd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc0:	83 e2 1f             	and    $0x1f,%edx
  800cc3:	29 ca                	sub    %ecx,%edx
  800cc5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ccd:	83 c0 01             	add    $0x1,%eax
  800cd0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd3:	83 c7 01             	add    $0x1,%edi
  800cd6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cd9:	75 c2                	jne    800c9d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cdb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cde:	eb 05                	jmp    800ce5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 18             	sub    $0x18,%esp
  800cf6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cf9:	57                   	push   %edi
  800cfa:	e8 96 f6 ff ff       	call   800395 <fd2data>
  800cff:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	eb 3d                	jmp    800d48 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d0b:	85 db                	test   %ebx,%ebx
  800d0d:	74 04                	je     800d13 <devpipe_read+0x26>
				return i;
  800d0f:	89 d8                	mov    %ebx,%eax
  800d11:	eb 44                	jmp    800d57 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d13:	89 f2                	mov    %esi,%edx
  800d15:	89 f8                	mov    %edi,%eax
  800d17:	e8 e5 fe ff ff       	call   800c01 <_pipeisclosed>
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	75 32                	jne    800d52 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d20:	e8 2c f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d25:	8b 06                	mov    (%esi),%eax
  800d27:	3b 46 04             	cmp    0x4(%esi),%eax
  800d2a:	74 df                	je     800d0b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d2c:	99                   	cltd   
  800d2d:	c1 ea 1b             	shr    $0x1b,%edx
  800d30:	01 d0                	add    %edx,%eax
  800d32:	83 e0 1f             	and    $0x1f,%eax
  800d35:	29 d0                	sub    %edx,%eax
  800d37:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d42:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d45:	83 c3 01             	add    $0x1,%ebx
  800d48:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d4b:	75 d8                	jne    800d25 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d50:	eb 05                	jmp    800d57 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d52:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6a:	50                   	push   %eax
  800d6b:	e8 3c f6 ff ff       	call   8003ac <fd_alloc>
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	89 c2                	mov    %eax,%edx
  800d75:	85 c0                	test   %eax,%eax
  800d77:	0f 88 2c 01 00 00    	js     800ea9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	68 07 04 00 00       	push   $0x407
  800d85:	ff 75 f4             	pushl  -0xc(%ebp)
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 e1 f3 ff ff       	call   800170 <sys_page_alloc>
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	89 c2                	mov    %eax,%edx
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 0d 01 00 00    	js     800ea9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da2:	50                   	push   %eax
  800da3:	e8 04 f6 ff ff       	call   8003ac <fd_alloc>
  800da8:	89 c3                	mov    %eax,%ebx
  800daa:	83 c4 10             	add    $0x10,%esp
  800dad:	85 c0                	test   %eax,%eax
  800daf:	0f 88 e2 00 00 00    	js     800e97 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	68 07 04 00 00       	push   $0x407
  800dbd:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc0:	6a 00                	push   $0x0
  800dc2:	e8 a9 f3 ff ff       	call   800170 <sys_page_alloc>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	0f 88 c3 00 00 00    	js     800e97 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dda:	e8 b6 f5 ff ff       	call   800395 <fd2data>
  800ddf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de1:	83 c4 0c             	add    $0xc,%esp
  800de4:	68 07 04 00 00       	push   $0x407
  800de9:	50                   	push   %eax
  800dea:	6a 00                	push   $0x0
  800dec:	e8 7f f3 ff ff       	call   800170 <sys_page_alloc>
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	83 c4 10             	add    $0x10,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	0f 88 89 00 00 00    	js     800e87 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfe:	83 ec 0c             	sub    $0xc,%esp
  800e01:	ff 75 f0             	pushl  -0x10(%ebp)
  800e04:	e8 8c f5 ff ff       	call   800395 <fd2data>
  800e09:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e10:	50                   	push   %eax
  800e11:	6a 00                	push   $0x0
  800e13:	56                   	push   %esi
  800e14:	6a 00                	push   $0x0
  800e16:	e8 98 f3 ff ff       	call   8001b3 <sys_page_map>
  800e1b:	89 c3                	mov    %eax,%ebx
  800e1d:	83 c4 20             	add    $0x20,%esp
  800e20:	85 c0                	test   %eax,%eax
  800e22:	78 55                	js     800e79 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e24:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e32:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e42:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e47:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e4e:	83 ec 0c             	sub    $0xc,%esp
  800e51:	ff 75 f4             	pushl  -0xc(%ebp)
  800e54:	e8 2c f5 ff ff       	call   800385 <fd2num>
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e5e:	83 c4 04             	add    $0x4,%esp
  800e61:	ff 75 f0             	pushl  -0x10(%ebp)
  800e64:	e8 1c f5 ff ff       	call   800385 <fd2num>
  800e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	eb 30                	jmp    800ea9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	56                   	push   %esi
  800e7d:	6a 00                	push   $0x0
  800e7f:	e8 71 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e84:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e87:	83 ec 08             	sub    $0x8,%esp
  800e8a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8d:	6a 00                	push   $0x0
  800e8f:	e8 61 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e94:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 51 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ea9:	89 d0                	mov    %edx,%eax
  800eab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebb:	50                   	push   %eax
  800ebc:	ff 75 08             	pushl  0x8(%ebp)
  800ebf:	e8 37 f5 ff ff       	call   8003fb <fd_lookup>
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	78 18                	js     800ee3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed1:	e8 bf f4 ff ff       	call   800395 <fd2data>
	return _pipeisclosed(fd, p);
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edb:	e8 21 fd ff ff       	call   800c01 <_pipeisclosed>
  800ee0:	83 c4 10             	add    $0x10,%esp
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ef5:	68 76 1f 80 00       	push   $0x801f76
  800efa:	ff 75 0c             	pushl  0xc(%ebp)
  800efd:	e8 0e 08 00 00       	call   801710 <strcpy>
	return 0;
}
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f15:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f1a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f20:	eb 2d                	jmp    800f4f <devcons_write+0x46>
		m = n - tot;
  800f22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f25:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f27:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f2a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f2f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f32:	83 ec 04             	sub    $0x4,%esp
  800f35:	53                   	push   %ebx
  800f36:	03 45 0c             	add    0xc(%ebp),%eax
  800f39:	50                   	push   %eax
  800f3a:	57                   	push   %edi
  800f3b:	e8 62 09 00 00       	call   8018a2 <memmove>
		sys_cputs(buf, m);
  800f40:	83 c4 08             	add    $0x8,%esp
  800f43:	53                   	push   %ebx
  800f44:	57                   	push   %edi
  800f45:	e8 6a f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f4a:	01 de                	add    %ebx,%esi
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	89 f0                	mov    %esi,%eax
  800f51:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f54:	72 cc                	jb     800f22 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f59:	5b                   	pop    %ebx
  800f5a:	5e                   	pop    %esi
  800f5b:	5f                   	pop    %edi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	83 ec 08             	sub    $0x8,%esp
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f6d:	74 2a                	je     800f99 <devcons_read+0x3b>
  800f6f:	eb 05                	jmp    800f76 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f71:	e8 db f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f76:	e8 57 f1 ff ff       	call   8000d2 <sys_cgetc>
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	74 f2                	je     800f71 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 16                	js     800f99 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f83:	83 f8 04             	cmp    $0x4,%eax
  800f86:	74 0c                	je     800f94 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8b:	88 02                	mov    %al,(%edx)
	return 1;
  800f8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f92:	eb 05                	jmp    800f99 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fa7:	6a 01                	push   $0x1
  800fa9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	e8 02 f1 ff ff       	call   8000b4 <sys_cputs>
}
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    

00800fb7 <getchar>:

int
getchar(void)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fbd:	6a 01                	push   $0x1
  800fbf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 97 f6 ff ff       	call   800661 <read>
	if (r < 0)
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 0f                	js     800fe0 <getchar+0x29>
		return r;
	if (r < 1)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7e 06                	jle    800fdb <getchar+0x24>
		return -E_EOF;
	return c;
  800fd5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fd9:	eb 05                	jmp    800fe0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fdb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	ff 75 08             	pushl  0x8(%ebp)
  800fef:	e8 07 f4 ff ff       	call   8003fb <fd_lookup>
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 11                	js     80100c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801004:	39 10                	cmp    %edx,(%eax)
  801006:	0f 94 c0             	sete   %al
  801009:	0f b6 c0             	movzbl %al,%eax
}
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    

0080100e <opencons>:

int
opencons(void)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801014:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801017:	50                   	push   %eax
  801018:	e8 8f f3 ff ff       	call   8003ac <fd_alloc>
  80101d:	83 c4 10             	add    $0x10,%esp
		return r;
  801020:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801022:	85 c0                	test   %eax,%eax
  801024:	78 3e                	js     801064 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801026:	83 ec 04             	sub    $0x4,%esp
  801029:	68 07 04 00 00       	push   $0x407
  80102e:	ff 75 f4             	pushl  -0xc(%ebp)
  801031:	6a 00                	push   $0x0
  801033:	e8 38 f1 ff ff       	call   800170 <sys_page_alloc>
  801038:	83 c4 10             	add    $0x10,%esp
		return r;
  80103b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 23                	js     801064 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801041:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801047:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80104c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	50                   	push   %eax
  80105a:	e8 26 f3 ff ff       	call   800385 <fd2num>
  80105f:	89 c2                	mov    %eax,%edx
  801061:	83 c4 10             	add    $0x10,%esp
}
  801064:	89 d0                	mov    %edx,%eax
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	56                   	push   %esi
  80106c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80106d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801070:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801076:	e8 b7 f0 ff ff       	call   800132 <sys_getenvid>
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	ff 75 0c             	pushl  0xc(%ebp)
  801081:	ff 75 08             	pushl  0x8(%ebp)
  801084:	56                   	push   %esi
  801085:	50                   	push   %eax
  801086:	68 84 1f 80 00       	push   $0x801f84
  80108b:	e8 b1 00 00 00       	call   801141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801090:	83 c4 18             	add    $0x18,%esp
  801093:	53                   	push   %ebx
  801094:	ff 75 10             	pushl  0x10(%ebp)
  801097:	e8 54 00 00 00       	call   8010f0 <vcprintf>
	cprintf("\n");
  80109c:	c7 04 24 6f 1f 80 00 	movl   $0x801f6f,(%esp)
  8010a3:	e8 99 00 00 00       	call   801141 <cprintf>
  8010a8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ab:	cc                   	int3   
  8010ac:	eb fd                	jmp    8010ab <_panic+0x43>

008010ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	53                   	push   %ebx
  8010b2:	83 ec 04             	sub    $0x4,%esp
  8010b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010b8:	8b 13                	mov    (%ebx),%edx
  8010ba:	8d 42 01             	lea    0x1(%edx),%eax
  8010bd:	89 03                	mov    %eax,(%ebx)
  8010bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010cb:	75 1a                	jne    8010e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	68 ff 00 00 00       	push   $0xff
  8010d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d8:	50                   	push   %eax
  8010d9:	e8 d6 ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ee:	c9                   	leave  
  8010ef:	c3                   	ret    

008010f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8010f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801100:	00 00 00 
	b.cnt = 0;
  801103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80110a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80110d:	ff 75 0c             	pushl  0xc(%ebp)
  801110:	ff 75 08             	pushl  0x8(%ebp)
  801113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	68 ae 10 80 00       	push   $0x8010ae
  80111f:	e8 54 01 00 00       	call   801278 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80112d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801133:	50                   	push   %eax
  801134:	e8 7b ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80113f:	c9                   	leave  
  801140:	c3                   	ret    

00801141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80114a:	50                   	push   %eax
  80114b:	ff 75 08             	pushl  0x8(%ebp)
  80114e:	e8 9d ff ff ff       	call   8010f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    

00801155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 1c             	sub    $0x1c,%esp
  80115e:	89 c7                	mov    %eax,%edi
  801160:	89 d6                	mov    %edx,%esi
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	8b 55 0c             	mov    0xc(%ebp),%edx
  801168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80116b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80116e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801171:	bb 00 00 00 00       	mov    $0x0,%ebx
  801176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80117c:	39 d3                	cmp    %edx,%ebx
  80117e:	72 05                	jb     801185 <printnum+0x30>
  801180:	39 45 10             	cmp    %eax,0x10(%ebp)
  801183:	77 45                	ja     8011ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	ff 75 18             	pushl  0x18(%ebp)
  80118b:	8b 45 14             	mov    0x14(%ebp),%eax
  80118e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801191:	53                   	push   %ebx
  801192:	ff 75 10             	pushl  0x10(%ebp)
  801195:	83 ec 08             	sub    $0x8,%esp
  801198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119b:	ff 75 e0             	pushl  -0x20(%ebp)
  80119e:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a4:	e8 27 0a 00 00       	call   801bd0 <__udivdi3>
  8011a9:	83 c4 18             	add    $0x18,%esp
  8011ac:	52                   	push   %edx
  8011ad:	50                   	push   %eax
  8011ae:	89 f2                	mov    %esi,%edx
  8011b0:	89 f8                	mov    %edi,%eax
  8011b2:	e8 9e ff ff ff       	call   801155 <printnum>
  8011b7:	83 c4 20             	add    $0x20,%esp
  8011ba:	eb 18                	jmp    8011d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011bc:	83 ec 08             	sub    $0x8,%esp
  8011bf:	56                   	push   %esi
  8011c0:	ff 75 18             	pushl  0x18(%ebp)
  8011c3:	ff d7                	call   *%edi
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	eb 03                	jmp    8011cd <printnum+0x78>
  8011ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011cd:	83 eb 01             	sub    $0x1,%ebx
  8011d0:	85 db                	test   %ebx,%ebx
  8011d2:	7f e8                	jg     8011bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	56                   	push   %esi
  8011d8:	83 ec 04             	sub    $0x4,%esp
  8011db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011de:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8011e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e7:	e8 14 0b 00 00       	call   801d00 <__umoddi3>
  8011ec:	83 c4 14             	add    $0x14,%esp
  8011ef:	0f be 80 a7 1f 80 00 	movsbl 0x801fa7(%eax),%eax
  8011f6:	50                   	push   %eax
  8011f7:	ff d7                	call   *%edi
}
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5f                   	pop    %edi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801207:	83 fa 01             	cmp    $0x1,%edx
  80120a:	7e 0e                	jle    80121a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80120c:	8b 10                	mov    (%eax),%edx
  80120e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801211:	89 08                	mov    %ecx,(%eax)
  801213:	8b 02                	mov    (%edx),%eax
  801215:	8b 52 04             	mov    0x4(%edx),%edx
  801218:	eb 22                	jmp    80123c <getuint+0x38>
	else if (lflag)
  80121a:	85 d2                	test   %edx,%edx
  80121c:	74 10                	je     80122e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80121e:	8b 10                	mov    (%eax),%edx
  801220:	8d 4a 04             	lea    0x4(%edx),%ecx
  801223:	89 08                	mov    %ecx,(%eax)
  801225:	8b 02                	mov    (%edx),%eax
  801227:	ba 00 00 00 00       	mov    $0x0,%edx
  80122c:	eb 0e                	jmp    80123c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80122e:	8b 10                	mov    (%eax),%edx
  801230:	8d 4a 04             	lea    0x4(%edx),%ecx
  801233:	89 08                	mov    %ecx,(%eax)
  801235:	8b 02                	mov    (%edx),%eax
  801237:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801244:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801248:	8b 10                	mov    (%eax),%edx
  80124a:	3b 50 04             	cmp    0x4(%eax),%edx
  80124d:	73 0a                	jae    801259 <sprintputch+0x1b>
		*b->buf++ = ch;
  80124f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801252:	89 08                	mov    %ecx,(%eax)
  801254:	8b 45 08             	mov    0x8(%ebp),%eax
  801257:	88 02                	mov    %al,(%edx)
}
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801261:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801264:	50                   	push   %eax
  801265:	ff 75 10             	pushl  0x10(%ebp)
  801268:	ff 75 0c             	pushl  0xc(%ebp)
  80126b:	ff 75 08             	pushl  0x8(%ebp)
  80126e:	e8 05 00 00 00       	call   801278 <vprintfmt>
	va_end(ap);
}
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	57                   	push   %edi
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	83 ec 2c             	sub    $0x2c,%esp
  801281:	8b 75 08             	mov    0x8(%ebp),%esi
  801284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801287:	8b 7d 10             	mov    0x10(%ebp),%edi
  80128a:	eb 12                	jmp    80129e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80128c:	85 c0                	test   %eax,%eax
  80128e:	0f 84 d3 03 00 00    	je     801667 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	53                   	push   %ebx
  801298:	50                   	push   %eax
  801299:	ff d6                	call   *%esi
  80129b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80129e:	83 c7 01             	add    $0x1,%edi
  8012a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012a5:	83 f8 25             	cmp    $0x25,%eax
  8012a8:	75 e2                	jne    80128c <vprintfmt+0x14>
  8012aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012b5:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8012bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c8:	eb 07                	jmp    8012d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012cd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d1:	8d 47 01             	lea    0x1(%edi),%eax
  8012d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d7:	0f b6 07             	movzbl (%edi),%eax
  8012da:	0f b6 c8             	movzbl %al,%ecx
  8012dd:	83 e8 23             	sub    $0x23,%eax
  8012e0:	3c 55                	cmp    $0x55,%al
  8012e2:	0f 87 64 03 00 00    	ja     80164c <vprintfmt+0x3d4>
  8012e8:	0f b6 c0             	movzbl %al,%eax
  8012eb:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  8012f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012f5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012f9:	eb d6                	jmp    8012d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801309:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80130d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801310:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801313:	83 fa 09             	cmp    $0x9,%edx
  801316:	77 39                	ja     801351 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80131b:	eb e9                	jmp    801306 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80131d:	8b 45 14             	mov    0x14(%ebp),%eax
  801320:	8d 48 04             	lea    0x4(%eax),%ecx
  801323:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801326:	8b 00                	mov    (%eax),%eax
  801328:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80132e:	eb 27                	jmp    801357 <vprintfmt+0xdf>
  801330:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801333:	85 c0                	test   %eax,%eax
  801335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80133a:	0f 49 c8             	cmovns %eax,%ecx
  80133d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801343:	eb 8c                	jmp    8012d1 <vprintfmt+0x59>
  801345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801348:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80134f:	eb 80                	jmp    8012d1 <vprintfmt+0x59>
  801351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801354:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  801357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80135b:	0f 89 70 ff ff ff    	jns    8012d1 <vprintfmt+0x59>
				width = precision, precision = -1;
  801361:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801364:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801367:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80136e:	e9 5e ff ff ff       	jmp    8012d1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801373:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801379:	e9 53 ff ff ff       	jmp    8012d1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80137e:	8b 45 14             	mov    0x14(%ebp),%eax
  801381:	8d 50 04             	lea    0x4(%eax),%edx
  801384:	89 55 14             	mov    %edx,0x14(%ebp)
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	53                   	push   %ebx
  80138b:	ff 30                	pushl  (%eax)
  80138d:	ff d6                	call   *%esi
			break;
  80138f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801395:	e9 04 ff ff ff       	jmp    80129e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80139a:	8b 45 14             	mov    0x14(%ebp),%eax
  80139d:	8d 50 04             	lea    0x4(%eax),%edx
  8013a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a3:	8b 00                	mov    (%eax),%eax
  8013a5:	99                   	cltd   
  8013a6:	31 d0                	xor    %edx,%eax
  8013a8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013aa:	83 f8 0f             	cmp    $0xf,%eax
  8013ad:	7f 0b                	jg     8013ba <vprintfmt+0x142>
  8013af:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013b6:	85 d2                	test   %edx,%edx
  8013b8:	75 18                	jne    8013d2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013ba:	50                   	push   %eax
  8013bb:	68 bf 1f 80 00       	push   $0x801fbf
  8013c0:	53                   	push   %ebx
  8013c1:	56                   	push   %esi
  8013c2:	e8 94 fe ff ff       	call   80125b <printfmt>
  8013c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013cd:	e9 cc fe ff ff       	jmp    80129e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013d2:	52                   	push   %edx
  8013d3:	68 3d 1f 80 00       	push   $0x801f3d
  8013d8:	53                   	push   %ebx
  8013d9:	56                   	push   %esi
  8013da:	e8 7c fe ff ff       	call   80125b <printfmt>
  8013df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013e5:	e9 b4 fe ff ff       	jmp    80129e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ed:	8d 50 04             	lea    0x4(%eax),%edx
  8013f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013f5:	85 ff                	test   %edi,%edi
  8013f7:	b8 b8 1f 80 00       	mov    $0x801fb8,%eax
  8013fc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801403:	0f 8e 94 00 00 00    	jle    80149d <vprintfmt+0x225>
  801409:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80140d:	0f 84 98 00 00 00    	je     8014ab <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801413:	83 ec 08             	sub    $0x8,%esp
  801416:	ff 75 c8             	pushl  -0x38(%ebp)
  801419:	57                   	push   %edi
  80141a:	e8 d0 02 00 00       	call   8016ef <strnlen>
  80141f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801422:	29 c1                	sub    %eax,%ecx
  801424:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801427:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80142a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80142e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801431:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801434:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801436:	eb 0f                	jmp    801447 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	53                   	push   %ebx
  80143c:	ff 75 e0             	pushl  -0x20(%ebp)
  80143f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801441:	83 ef 01             	sub    $0x1,%edi
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	85 ff                	test   %edi,%edi
  801449:	7f ed                	jg     801438 <vprintfmt+0x1c0>
  80144b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80144e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801451:	85 c9                	test   %ecx,%ecx
  801453:	b8 00 00 00 00       	mov    $0x0,%eax
  801458:	0f 49 c1             	cmovns %ecx,%eax
  80145b:	29 c1                	sub    %eax,%ecx
  80145d:	89 75 08             	mov    %esi,0x8(%ebp)
  801460:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801463:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801466:	89 cb                	mov    %ecx,%ebx
  801468:	eb 4d                	jmp    8014b7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80146a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80146e:	74 1b                	je     80148b <vprintfmt+0x213>
  801470:	0f be c0             	movsbl %al,%eax
  801473:	83 e8 20             	sub    $0x20,%eax
  801476:	83 f8 5e             	cmp    $0x5e,%eax
  801479:	76 10                	jbe    80148b <vprintfmt+0x213>
					putch('?', putdat);
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	ff 75 0c             	pushl  0xc(%ebp)
  801481:	6a 3f                	push   $0x3f
  801483:	ff 55 08             	call   *0x8(%ebp)
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb 0d                	jmp    801498 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	ff 75 0c             	pushl  0xc(%ebp)
  801491:	52                   	push   %edx
  801492:	ff 55 08             	call   *0x8(%ebp)
  801495:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801498:	83 eb 01             	sub    $0x1,%ebx
  80149b:	eb 1a                	jmp    8014b7 <vprintfmt+0x23f>
  80149d:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8014a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a9:	eb 0c                	jmp    8014b7 <vprintfmt+0x23f>
  8014ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8014ae:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8014b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b7:	83 c7 01             	add    $0x1,%edi
  8014ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014be:	0f be d0             	movsbl %al,%edx
  8014c1:	85 d2                	test   %edx,%edx
  8014c3:	74 23                	je     8014e8 <vprintfmt+0x270>
  8014c5:	85 f6                	test   %esi,%esi
  8014c7:	78 a1                	js     80146a <vprintfmt+0x1f2>
  8014c9:	83 ee 01             	sub    $0x1,%esi
  8014cc:	79 9c                	jns    80146a <vprintfmt+0x1f2>
  8014ce:	89 df                	mov    %ebx,%edi
  8014d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d6:	eb 18                	jmp    8014f0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	53                   	push   %ebx
  8014dc:	6a 20                	push   $0x20
  8014de:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014e0:	83 ef 01             	sub    $0x1,%edi
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	eb 08                	jmp    8014f0 <vprintfmt+0x278>
  8014e8:	89 df                	mov    %ebx,%edi
  8014ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f0:	85 ff                	test   %edi,%edi
  8014f2:	7f e4                	jg     8014d8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f7:	e9 a2 fd ff ff       	jmp    80129e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014fc:	83 fa 01             	cmp    $0x1,%edx
  8014ff:	7e 16                	jle    801517 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801501:	8b 45 14             	mov    0x14(%ebp),%eax
  801504:	8d 50 08             	lea    0x8(%eax),%edx
  801507:	89 55 14             	mov    %edx,0x14(%ebp)
  80150a:	8b 50 04             	mov    0x4(%eax),%edx
  80150d:	8b 00                	mov    (%eax),%eax
  80150f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801512:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801515:	eb 32                	jmp    801549 <vprintfmt+0x2d1>
	else if (lflag)
  801517:	85 d2                	test   %edx,%edx
  801519:	74 18                	je     801533 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80151b:	8b 45 14             	mov    0x14(%ebp),%eax
  80151e:	8d 50 04             	lea    0x4(%eax),%edx
  801521:	89 55 14             	mov    %edx,0x14(%ebp)
  801524:	8b 00                	mov    (%eax),%eax
  801526:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801529:	89 c1                	mov    %eax,%ecx
  80152b:	c1 f9 1f             	sar    $0x1f,%ecx
  80152e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801531:	eb 16                	jmp    801549 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801533:	8b 45 14             	mov    0x14(%ebp),%eax
  801536:	8d 50 04             	lea    0x4(%eax),%edx
  801539:	89 55 14             	mov    %edx,0x14(%ebp)
  80153c:	8b 00                	mov    (%eax),%eax
  80153e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801541:	89 c1                	mov    %eax,%ecx
  801543:	c1 f9 1f             	sar    $0x1f,%ecx
  801546:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801549:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80154c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80154f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801552:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801555:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80155a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80155e:	0f 89 b0 00 00 00    	jns    801614 <vprintfmt+0x39c>
				putch('-', putdat);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	53                   	push   %ebx
  801568:	6a 2d                	push   $0x2d
  80156a:	ff d6                	call   *%esi
				num = -(long long) num;
  80156c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80156f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801572:	f7 d8                	neg    %eax
  801574:	83 d2 00             	adc    $0x0,%edx
  801577:	f7 da                	neg    %edx
  801579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80157f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801582:	b8 0a 00 00 00       	mov    $0xa,%eax
  801587:	e9 88 00 00 00       	jmp    801614 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80158c:	8d 45 14             	lea    0x14(%ebp),%eax
  80158f:	e8 70 fc ff ff       	call   801204 <getuint>
  801594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801597:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80159a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80159f:	eb 73                	jmp    801614 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8015a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a4:	e8 5b fc ff ff       	call   801204 <getuint>
  8015a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	6a 58                	push   $0x58
  8015b5:	ff d6                	call   *%esi
			putch('X', putdat);
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	53                   	push   %ebx
  8015bb:	6a 58                	push   $0x58
  8015bd:	ff d6                	call   *%esi
			putch('X', putdat);
  8015bf:	83 c4 08             	add    $0x8,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	6a 58                	push   $0x58
  8015c5:	ff d6                	call   *%esi
			goto number;
  8015c7:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8015ca:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8015cf:	eb 43                	jmp    801614 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	6a 30                	push   $0x30
  8015d7:	ff d6                	call   *%esi
			putch('x', putdat);
  8015d9:	83 c4 08             	add    $0x8,%esp
  8015dc:	53                   	push   %ebx
  8015dd:	6a 78                	push   $0x78
  8015df:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e4:	8d 50 04             	lea    0x4(%eax),%edx
  8015e7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ea:	8b 00                	mov    (%eax),%eax
  8015ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015f7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015ff:	eb 13                	jmp    801614 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801601:	8d 45 14             	lea    0x14(%ebp),%eax
  801604:	e8 fb fb ff ff       	call   801204 <getuint>
  801609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80160c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80160f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801614:	83 ec 0c             	sub    $0xc,%esp
  801617:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80161b:	52                   	push   %edx
  80161c:	ff 75 e0             	pushl  -0x20(%ebp)
  80161f:	50                   	push   %eax
  801620:	ff 75 dc             	pushl  -0x24(%ebp)
  801623:	ff 75 d8             	pushl  -0x28(%ebp)
  801626:	89 da                	mov    %ebx,%edx
  801628:	89 f0                	mov    %esi,%eax
  80162a:	e8 26 fb ff ff       	call   801155 <printnum>
			break;
  80162f:	83 c4 20             	add    $0x20,%esp
  801632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801635:	e9 64 fc ff ff       	jmp    80129e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	53                   	push   %ebx
  80163e:	51                   	push   %ecx
  80163f:	ff d6                	call   *%esi
			break;
  801641:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801647:	e9 52 fc ff ff       	jmp    80129e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	53                   	push   %ebx
  801650:	6a 25                	push   $0x25
  801652:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	eb 03                	jmp    80165c <vprintfmt+0x3e4>
  801659:	83 ef 01             	sub    $0x1,%edi
  80165c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801660:	75 f7                	jne    801659 <vprintfmt+0x3e1>
  801662:	e9 37 fc ff ff       	jmp    80129e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166a:	5b                   	pop    %ebx
  80166b:	5e                   	pop    %esi
  80166c:	5f                   	pop    %edi
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 18             	sub    $0x18,%esp
  801675:	8b 45 08             	mov    0x8(%ebp),%eax
  801678:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80167b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80167e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801682:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80168c:	85 c0                	test   %eax,%eax
  80168e:	74 26                	je     8016b6 <vsnprintf+0x47>
  801690:	85 d2                	test   %edx,%edx
  801692:	7e 22                	jle    8016b6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801694:	ff 75 14             	pushl  0x14(%ebp)
  801697:	ff 75 10             	pushl  0x10(%ebp)
  80169a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	68 3e 12 80 00       	push   $0x80123e
  8016a3:	e8 d0 fb ff ff       	call   801278 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	eb 05                	jmp    8016bb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c6:	50                   	push   %eax
  8016c7:	ff 75 10             	pushl  0x10(%ebp)
  8016ca:	ff 75 0c             	pushl  0xc(%ebp)
  8016cd:	ff 75 08             	pushl  0x8(%ebp)
  8016d0:	e8 9a ff ff ff       	call   80166f <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e2:	eb 03                	jmp    8016e7 <strlen+0x10>
		n++;
  8016e4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016eb:	75 f7                	jne    8016e4 <strlen+0xd>
		n++;
	return n;
}
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fd:	eb 03                	jmp    801702 <strnlen+0x13>
		n++;
  8016ff:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801702:	39 c2                	cmp    %eax,%edx
  801704:	74 08                	je     80170e <strnlen+0x1f>
  801706:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80170a:	75 f3                	jne    8016ff <strnlen+0x10>
  80170c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	53                   	push   %ebx
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80171a:	89 c2                	mov    %eax,%edx
  80171c:	83 c2 01             	add    $0x1,%edx
  80171f:	83 c1 01             	add    $0x1,%ecx
  801722:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801726:	88 5a ff             	mov    %bl,-0x1(%edx)
  801729:	84 db                	test   %bl,%bl
  80172b:	75 ef                	jne    80171c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80172d:	5b                   	pop    %ebx
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801737:	53                   	push   %ebx
  801738:	e8 9a ff ff ff       	call   8016d7 <strlen>
  80173d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	01 d8                	add    %ebx,%eax
  801745:	50                   	push   %eax
  801746:	e8 c5 ff ff ff       	call   801710 <strcpy>
	return dst;
}
  80174b:	89 d8                	mov    %ebx,%eax
  80174d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
  801757:	8b 75 08             	mov    0x8(%ebp),%esi
  80175a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175d:	89 f3                	mov    %esi,%ebx
  80175f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801762:	89 f2                	mov    %esi,%edx
  801764:	eb 0f                	jmp    801775 <strncpy+0x23>
		*dst++ = *src;
  801766:	83 c2 01             	add    $0x1,%edx
  801769:	0f b6 01             	movzbl (%ecx),%eax
  80176c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80176f:	80 39 01             	cmpb   $0x1,(%ecx)
  801772:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801775:	39 da                	cmp    %ebx,%edx
  801777:	75 ed                	jne    801766 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801779:	89 f0                	mov    %esi,%eax
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
  801784:	8b 75 08             	mov    0x8(%ebp),%esi
  801787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178a:	8b 55 10             	mov    0x10(%ebp),%edx
  80178d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80178f:	85 d2                	test   %edx,%edx
  801791:	74 21                	je     8017b4 <strlcpy+0x35>
  801793:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801797:	89 f2                	mov    %esi,%edx
  801799:	eb 09                	jmp    8017a4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80179b:	83 c2 01             	add    $0x1,%edx
  80179e:	83 c1 01             	add    $0x1,%ecx
  8017a1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017a4:	39 c2                	cmp    %eax,%edx
  8017a6:	74 09                	je     8017b1 <strlcpy+0x32>
  8017a8:	0f b6 19             	movzbl (%ecx),%ebx
  8017ab:	84 db                	test   %bl,%bl
  8017ad:	75 ec                	jne    80179b <strlcpy+0x1c>
  8017af:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b4:	29 f0                	sub    %esi,%eax
}
  8017b6:	5b                   	pop    %ebx
  8017b7:	5e                   	pop    %esi
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c3:	eb 06                	jmp    8017cb <strcmp+0x11>
		p++, q++;
  8017c5:	83 c1 01             	add    $0x1,%ecx
  8017c8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017cb:	0f b6 01             	movzbl (%ecx),%eax
  8017ce:	84 c0                	test   %al,%al
  8017d0:	74 04                	je     8017d6 <strcmp+0x1c>
  8017d2:	3a 02                	cmp    (%edx),%al
  8017d4:	74 ef                	je     8017c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d6:	0f b6 c0             	movzbl %al,%eax
  8017d9:	0f b6 12             	movzbl (%edx),%edx
  8017dc:	29 d0                	sub    %edx,%eax
}
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	53                   	push   %ebx
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ea:	89 c3                	mov    %eax,%ebx
  8017ec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ef:	eb 06                	jmp    8017f7 <strncmp+0x17>
		n--, p++, q++;
  8017f1:	83 c0 01             	add    $0x1,%eax
  8017f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017f7:	39 d8                	cmp    %ebx,%eax
  8017f9:	74 15                	je     801810 <strncmp+0x30>
  8017fb:	0f b6 08             	movzbl (%eax),%ecx
  8017fe:	84 c9                	test   %cl,%cl
  801800:	74 04                	je     801806 <strncmp+0x26>
  801802:	3a 0a                	cmp    (%edx),%cl
  801804:	74 eb                	je     8017f1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801806:	0f b6 00             	movzbl (%eax),%eax
  801809:	0f b6 12             	movzbl (%edx),%edx
  80180c:	29 d0                	sub    %edx,%eax
  80180e:	eb 05                	jmp    801815 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801810:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801815:	5b                   	pop    %ebx
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801822:	eb 07                	jmp    80182b <strchr+0x13>
		if (*s == c)
  801824:	38 ca                	cmp    %cl,%dl
  801826:	74 0f                	je     801837 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801828:	83 c0 01             	add    $0x1,%eax
  80182b:	0f b6 10             	movzbl (%eax),%edx
  80182e:	84 d2                	test   %dl,%dl
  801830:	75 f2                	jne    801824 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801832:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801843:	eb 03                	jmp    801848 <strfind+0xf>
  801845:	83 c0 01             	add    $0x1,%eax
  801848:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80184b:	38 ca                	cmp    %cl,%dl
  80184d:	74 04                	je     801853 <strfind+0x1a>
  80184f:	84 d2                	test   %dl,%dl
  801851:	75 f2                	jne    801845 <strfind+0xc>
			break;
	return (char *) s;
}
  801853:	5d                   	pop    %ebp
  801854:	c3                   	ret    

00801855 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	57                   	push   %edi
  801859:	56                   	push   %esi
  80185a:	53                   	push   %ebx
  80185b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801861:	85 c9                	test   %ecx,%ecx
  801863:	74 36                	je     80189b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801865:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80186b:	75 28                	jne    801895 <memset+0x40>
  80186d:	f6 c1 03             	test   $0x3,%cl
  801870:	75 23                	jne    801895 <memset+0x40>
		c &= 0xFF;
  801872:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801876:	89 d3                	mov    %edx,%ebx
  801878:	c1 e3 08             	shl    $0x8,%ebx
  80187b:	89 d6                	mov    %edx,%esi
  80187d:	c1 e6 18             	shl    $0x18,%esi
  801880:	89 d0                	mov    %edx,%eax
  801882:	c1 e0 10             	shl    $0x10,%eax
  801885:	09 f0                	or     %esi,%eax
  801887:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801889:	89 d8                	mov    %ebx,%eax
  80188b:	09 d0                	or     %edx,%eax
  80188d:	c1 e9 02             	shr    $0x2,%ecx
  801890:	fc                   	cld    
  801891:	f3 ab                	rep stos %eax,%es:(%edi)
  801893:	eb 06                	jmp    80189b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801895:	8b 45 0c             	mov    0xc(%ebp),%eax
  801898:	fc                   	cld    
  801899:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80189b:	89 f8                	mov    %edi,%eax
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5f                   	pop    %edi
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	57                   	push   %edi
  8018a6:	56                   	push   %esi
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b0:	39 c6                	cmp    %eax,%esi
  8018b2:	73 35                	jae    8018e9 <memmove+0x47>
  8018b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b7:	39 d0                	cmp    %edx,%eax
  8018b9:	73 2e                	jae    8018e9 <memmove+0x47>
		s += n;
		d += n;
  8018bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018be:	89 d6                	mov    %edx,%esi
  8018c0:	09 fe                	or     %edi,%esi
  8018c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c8:	75 13                	jne    8018dd <memmove+0x3b>
  8018ca:	f6 c1 03             	test   $0x3,%cl
  8018cd:	75 0e                	jne    8018dd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018cf:	83 ef 04             	sub    $0x4,%edi
  8018d2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d5:	c1 e9 02             	shr    $0x2,%ecx
  8018d8:	fd                   	std    
  8018d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018db:	eb 09                	jmp    8018e6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018dd:	83 ef 01             	sub    $0x1,%edi
  8018e0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018e3:	fd                   	std    
  8018e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e6:	fc                   	cld    
  8018e7:	eb 1d                	jmp    801906 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e9:	89 f2                	mov    %esi,%edx
  8018eb:	09 c2                	or     %eax,%edx
  8018ed:	f6 c2 03             	test   $0x3,%dl
  8018f0:	75 0f                	jne    801901 <memmove+0x5f>
  8018f2:	f6 c1 03             	test   $0x3,%cl
  8018f5:	75 0a                	jne    801901 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018f7:	c1 e9 02             	shr    $0x2,%ecx
  8018fa:	89 c7                	mov    %eax,%edi
  8018fc:	fc                   	cld    
  8018fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ff:	eb 05                	jmp    801906 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801901:	89 c7                	mov    %eax,%edi
  801903:	fc                   	cld    
  801904:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801906:	5e                   	pop    %esi
  801907:	5f                   	pop    %edi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80190d:	ff 75 10             	pushl  0x10(%ebp)
  801910:	ff 75 0c             	pushl  0xc(%ebp)
  801913:	ff 75 08             	pushl  0x8(%ebp)
  801916:	e8 87 ff ff ff       	call   8018a2 <memmove>
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	8b 55 0c             	mov    0xc(%ebp),%edx
  801928:	89 c6                	mov    %eax,%esi
  80192a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80192d:	eb 1a                	jmp    801949 <memcmp+0x2c>
		if (*s1 != *s2)
  80192f:	0f b6 08             	movzbl (%eax),%ecx
  801932:	0f b6 1a             	movzbl (%edx),%ebx
  801935:	38 d9                	cmp    %bl,%cl
  801937:	74 0a                	je     801943 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801939:	0f b6 c1             	movzbl %cl,%eax
  80193c:	0f b6 db             	movzbl %bl,%ebx
  80193f:	29 d8                	sub    %ebx,%eax
  801941:	eb 0f                	jmp    801952 <memcmp+0x35>
		s1++, s2++;
  801943:	83 c0 01             	add    $0x1,%eax
  801946:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801949:	39 f0                	cmp    %esi,%eax
  80194b:	75 e2                	jne    80192f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80194d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	53                   	push   %ebx
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80195d:	89 c1                	mov    %eax,%ecx
  80195f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801962:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801966:	eb 0a                	jmp    801972 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801968:	0f b6 10             	movzbl (%eax),%edx
  80196b:	39 da                	cmp    %ebx,%edx
  80196d:	74 07                	je     801976 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196f:	83 c0 01             	add    $0x1,%eax
  801972:	39 c8                	cmp    %ecx,%eax
  801974:	72 f2                	jb     801968 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801976:	5b                   	pop    %ebx
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    

00801979 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	57                   	push   %edi
  80197d:	56                   	push   %esi
  80197e:	53                   	push   %ebx
  80197f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801982:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801985:	eb 03                	jmp    80198a <strtol+0x11>
		s++;
  801987:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198a:	0f b6 01             	movzbl (%ecx),%eax
  80198d:	3c 20                	cmp    $0x20,%al
  80198f:	74 f6                	je     801987 <strtol+0xe>
  801991:	3c 09                	cmp    $0x9,%al
  801993:	74 f2                	je     801987 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801995:	3c 2b                	cmp    $0x2b,%al
  801997:	75 0a                	jne    8019a3 <strtol+0x2a>
		s++;
  801999:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80199c:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a1:	eb 11                	jmp    8019b4 <strtol+0x3b>
  8019a3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a8:	3c 2d                	cmp    $0x2d,%al
  8019aa:	75 08                	jne    8019b4 <strtol+0x3b>
		s++, neg = 1;
  8019ac:	83 c1 01             	add    $0x1,%ecx
  8019af:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019ba:	75 15                	jne    8019d1 <strtol+0x58>
  8019bc:	80 39 30             	cmpb   $0x30,(%ecx)
  8019bf:	75 10                	jne    8019d1 <strtol+0x58>
  8019c1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c5:	75 7c                	jne    801a43 <strtol+0xca>
		s += 2, base = 16;
  8019c7:	83 c1 02             	add    $0x2,%ecx
  8019ca:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019cf:	eb 16                	jmp    8019e7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019d1:	85 db                	test   %ebx,%ebx
  8019d3:	75 12                	jne    8019e7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019da:	80 39 30             	cmpb   $0x30,(%ecx)
  8019dd:	75 08                	jne    8019e7 <strtol+0x6e>
		s++, base = 8;
  8019df:	83 c1 01             	add    $0x1,%ecx
  8019e2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ec:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ef:	0f b6 11             	movzbl (%ecx),%edx
  8019f2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f5:	89 f3                	mov    %esi,%ebx
  8019f7:	80 fb 09             	cmp    $0x9,%bl
  8019fa:	77 08                	ja     801a04 <strtol+0x8b>
			dig = *s - '0';
  8019fc:	0f be d2             	movsbl %dl,%edx
  8019ff:	83 ea 30             	sub    $0x30,%edx
  801a02:	eb 22                	jmp    801a26 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a04:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a07:	89 f3                	mov    %esi,%ebx
  801a09:	80 fb 19             	cmp    $0x19,%bl
  801a0c:	77 08                	ja     801a16 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a0e:	0f be d2             	movsbl %dl,%edx
  801a11:	83 ea 57             	sub    $0x57,%edx
  801a14:	eb 10                	jmp    801a26 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a16:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a19:	89 f3                	mov    %esi,%ebx
  801a1b:	80 fb 19             	cmp    $0x19,%bl
  801a1e:	77 16                	ja     801a36 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a20:	0f be d2             	movsbl %dl,%edx
  801a23:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a26:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a29:	7d 0b                	jge    801a36 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a2b:	83 c1 01             	add    $0x1,%ecx
  801a2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a32:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a34:	eb b9                	jmp    8019ef <strtol+0x76>

	if (endptr)
  801a36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a3a:	74 0d                	je     801a49 <strtol+0xd0>
		*endptr = (char *) s;
  801a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3f:	89 0e                	mov    %ecx,(%esi)
  801a41:	eb 06                	jmp    801a49 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a43:	85 db                	test   %ebx,%ebx
  801a45:	74 98                	je     8019df <strtol+0x66>
  801a47:	eb 9e                	jmp    8019e7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a49:	89 c2                	mov    %eax,%edx
  801a4b:	f7 da                	neg    %edx
  801a4d:	85 ff                	test   %edi,%edi
  801a4f:	0f 45 c2             	cmovne %edx,%eax
}
  801a52:	5b                   	pop    %ebx
  801a53:	5e                   	pop    %esi
  801a54:	5f                   	pop    %edi
  801a55:	5d                   	pop    %ebp
  801a56:	c3                   	ret    

00801a57 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801a5d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a64:	75 4c                	jne    801ab2 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801a66:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6b:	8b 40 48             	mov    0x48(%eax),%eax
  801a6e:	83 ec 04             	sub    $0x4,%esp
  801a71:	6a 07                	push   $0x7
  801a73:	68 00 f0 bf ee       	push   $0xeebff000
  801a78:	50                   	push   %eax
  801a79:	e8 f2 e6 ff ff       	call   800170 <sys_page_alloc>
		if(retv != 0){
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	74 14                	je     801a99 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	68 a0 22 80 00       	push   $0x8022a0
  801a8d:	6a 27                	push   $0x27
  801a8f:	68 cc 22 80 00       	push   $0x8022cc
  801a94:	e8 cf f5 ff ff       	call   801068 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801a99:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9e:	8b 40 48             	mov    0x48(%eax),%eax
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	68 61 03 80 00       	push   $0x800361
  801aa9:	50                   	push   %eax
  801aaa:	e8 0c e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801aaf:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab5:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ac4:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801ac7:	83 ec 0c             	sub    $0xc,%esp
  801aca:	ff 75 0c             	pushl  0xc(%ebp)
  801acd:	e8 4e e8 ff ff       	call   800320 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 f6                	test   %esi,%esi
  801ad7:	74 1c                	je     801af5 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801ad9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ade:	8b 40 78             	mov    0x78(%eax),%eax
  801ae1:	89 06                	mov    %eax,(%esi)
  801ae3:	eb 10                	jmp    801af5 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	68 da 22 80 00       	push   $0x8022da
  801aed:	e8 4f f6 ff ff       	call   801141 <cprintf>
  801af2:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801af5:	a1 04 40 80 00       	mov    0x804004,%eax
  801afa:	8b 50 74             	mov    0x74(%eax),%edx
  801afd:	85 d2                	test   %edx,%edx
  801aff:	74 e4                	je     801ae5 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801b01:	85 db                	test   %ebx,%ebx
  801b03:	74 05                	je     801b0a <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801b05:	8b 40 74             	mov    0x74(%eax),%eax
  801b08:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0f:	8b 40 70             	mov    0x70(%eax),%eax

}
  801b12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	57                   	push   %edi
  801b1d:	56                   	push   %esi
  801b1e:	53                   	push   %ebx
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801b2b:	85 db                	test   %ebx,%ebx
  801b2d:	75 13                	jne    801b42 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801b2f:	6a 00                	push   $0x0
  801b31:	68 00 00 c0 ee       	push   $0xeec00000
  801b36:	56                   	push   %esi
  801b37:	57                   	push   %edi
  801b38:	e8 c0 e7 ff ff       	call   8002fd <sys_ipc_try_send>
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	eb 0e                	jmp    801b50 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801b42:	ff 75 14             	pushl  0x14(%ebp)
  801b45:	53                   	push   %ebx
  801b46:	56                   	push   %esi
  801b47:	57                   	push   %edi
  801b48:	e8 b0 e7 ff ff       	call   8002fd <sys_ipc_try_send>
  801b4d:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801b50:	85 c0                	test   %eax,%eax
  801b52:	75 d7                	jne    801b2b <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b57:	5b                   	pop    %ebx
  801b58:	5e                   	pop    %esi
  801b59:	5f                   	pop    %edi
  801b5a:	5d                   	pop    %ebp
  801b5b:	c3                   	ret    

00801b5c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b67:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b6a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b70:	8b 52 50             	mov    0x50(%edx),%edx
  801b73:	39 ca                	cmp    %ecx,%edx
  801b75:	75 0d                	jne    801b84 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b77:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b7a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b7f:	8b 40 48             	mov    0x48(%eax),%eax
  801b82:	eb 0f                	jmp    801b93 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b84:	83 c0 01             	add    $0x1,%eax
  801b87:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b8c:	75 d9                	jne    801b67 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9b:	89 d0                	mov    %edx,%eax
  801b9d:	c1 e8 16             	shr    $0x16,%eax
  801ba0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ba7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bac:	f6 c1 01             	test   $0x1,%cl
  801baf:	74 1d                	je     801bce <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb1:	c1 ea 0c             	shr    $0xc,%edx
  801bb4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bbb:	f6 c2 01             	test   $0x1,%dl
  801bbe:	74 0e                	je     801bce <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc0:	c1 ea 0c             	shr    $0xc,%edx
  801bc3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bca:	ef 
  801bcb:	0f b7 c0             	movzwl %ax,%eax
}
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801be7:	85 f6                	test   %esi,%esi
  801be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bed:	89 ca                	mov    %ecx,%edx
  801bef:	89 f8                	mov    %edi,%eax
  801bf1:	75 3d                	jne    801c30 <__udivdi3+0x60>
  801bf3:	39 cf                	cmp    %ecx,%edi
  801bf5:	0f 87 c5 00 00 00    	ja     801cc0 <__udivdi3+0xf0>
  801bfb:	85 ff                	test   %edi,%edi
  801bfd:	89 fd                	mov    %edi,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f7                	div    %edi
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 c8                	mov    %ecx,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c1                	mov    %eax,%ecx
  801c14:	89 d8                	mov    %ebx,%eax
  801c16:	89 cf                	mov    %ecx,%edi
  801c18:	f7 f5                	div    %ebp
  801c1a:	89 c3                	mov    %eax,%ebx
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
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 74                	ja     801ca8 <__udivdi3+0xd8>
  801c34:	0f bd fe             	bsr    %esi,%edi
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	0f 84 98 00 00 00    	je     801cd8 <__udivdi3+0x108>
  801c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	89 c5                	mov    %eax,%ebp
  801c49:	29 fb                	sub    %edi,%ebx
  801c4b:	d3 e6                	shl    %cl,%esi
  801c4d:	89 d9                	mov    %ebx,%ecx
  801c4f:	d3 ed                	shr    %cl,%ebp
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	09 ee                	or     %ebp,%esi
  801c57:	89 d9                	mov    %ebx,%ecx
  801c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5d:	89 d5                	mov    %edx,%ebp
  801c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c63:	d3 ed                	shr    %cl,%ebp
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 d9                	mov    %ebx,%ecx
  801c6b:	d3 e8                	shr    %cl,%eax
  801c6d:	09 c2                	or     %eax,%edx
  801c6f:	89 d0                	mov    %edx,%eax
  801c71:	89 ea                	mov    %ebp,%edx
  801c73:	f7 f6                	div    %esi
  801c75:	89 d5                	mov    %edx,%ebp
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	f7 64 24 0c          	mull   0xc(%esp)
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	72 10                	jb     801c91 <__udivdi3+0xc1>
  801c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	39 c6                	cmp    %eax,%esi
  801c8b:	73 07                	jae    801c94 <__udivdi3+0xc4>
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	75 03                	jne    801c94 <__udivdi3+0xc4>
  801c91:	83 eb 01             	sub    $0x1,%ebx
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	89 fa                	mov    %edi,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	31 ff                	xor    %edi,%edi
  801caa:	31 db                	xor    %ebx,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	72 0c                	jb     801ce8 <__udivdi3+0x118>
  801cdc:	31 db                	xor    %ebx,%ebx
  801cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce2:	0f 87 34 ff ff ff    	ja     801c1c <__udivdi3+0x4c>
  801ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ced:	e9 2a ff ff ff       	jmp    801c1c <__udivdi3+0x4c>
  801cf2:	66 90                	xchg   %ax,%ax
  801cf4:	66 90                	xchg   %ax,%ax
  801cf6:	66 90                	xchg   %ax,%ax
  801cf8:	66 90                	xchg   %ax,%ax
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	85 d2                	test   %edx,%edx
  801d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f3                	mov    %esi,%ebx
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2a:	75 1c                	jne    801d48 <__umoddi3+0x48>
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	76 50                	jbe    801d80 <__umoddi3+0x80>
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	f7 f7                	div    %edi
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	31 d2                	xor    %edx,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	77 52                	ja     801da0 <__umoddi3+0xa0>
  801d4e:	0f bd ea             	bsr    %edx,%ebp
  801d51:	83 f5 1f             	xor    $0x1f,%ebp
  801d54:	75 5a                	jne    801db0 <__umoddi3+0xb0>
  801d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d5a:	0f 82 e0 00 00 00    	jb     801e40 <__umoddi3+0x140>
  801d60:	39 0c 24             	cmp    %ecx,(%esp)
  801d63:	0f 86 d7 00 00 00    	jbe    801e40 <__umoddi3+0x140>
  801d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	85 ff                	test   %edi,%edi
  801d82:	89 fd                	mov    %edi,%ebp
  801d84:	75 0b                	jne    801d91 <__umoddi3+0x91>
  801d86:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f7                	div    %edi
  801d8f:	89 c5                	mov    %eax,%ebp
  801d91:	89 f0                	mov    %esi,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f5                	div    %ebp
  801d97:	89 c8                	mov    %ecx,%eax
  801d99:	f7 f5                	div    %ebp
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	eb 99                	jmp    801d38 <__umoddi3+0x38>
  801d9f:	90                   	nop
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	83 c4 1c             	add    $0x1c,%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5f                   	pop    %edi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    
  801dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db0:	8b 34 24             	mov    (%esp),%esi
  801db3:	bf 20 00 00 00       	mov    $0x20,%edi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	29 ef                	sub    %ebp,%edi
  801dbc:	d3 e0                	shl    %cl,%eax
  801dbe:	89 f9                	mov    %edi,%ecx
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	d3 ea                	shr    %cl,%edx
  801dc4:	89 e9                	mov    %ebp,%ecx
  801dc6:	09 c2                	or     %eax,%edx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 14 24             	mov    %edx,(%esp)
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	d3 e2                	shl    %cl,%edx
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ddb:	d3 e8                	shr    %cl,%eax
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	d3 e3                	shl    %cl,%ebx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	09 d8                	or     %ebx,%eax
  801ded:	89 d3                	mov    %edx,%ebx
  801def:	89 f2                	mov    %esi,%edx
  801df1:	f7 34 24             	divl   (%esp)
  801df4:	89 d6                	mov    %edx,%esi
  801df6:	d3 e3                	shl    %cl,%ebx
  801df8:	f7 64 24 04          	mull   0x4(%esp)
  801dfc:	39 d6                	cmp    %edx,%esi
  801dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e02:	89 d1                	mov    %edx,%ecx
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	72 08                	jb     801e10 <__umoddi3+0x110>
  801e08:	75 11                	jne    801e1b <__umoddi3+0x11b>
  801e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e0e:	73 0b                	jae    801e1b <__umoddi3+0x11b>
  801e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e14:	1b 14 24             	sbb    (%esp),%edx
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 c3                	mov    %eax,%ebx
  801e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e1f:	29 da                	sub    %ebx,%edx
  801e21:	19 ce                	sbb    %ecx,%esi
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	d3 e0                	shl    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	d3 ea                	shr    %cl,%edx
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	d3 ee                	shr    %cl,%esi
  801e31:	09 d0                	or     %edx,%eax
  801e33:	89 f2                	mov    %esi,%edx
  801e35:	83 c4 1c             	add    $0x1c,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	29 f9                	sub    %edi,%ecx
  801e42:	19 d6                	sbb    %edx,%esi
  801e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e4c:	e9 18 ff ff ff       	jmp    801d69 <__umoddi3+0x69>
